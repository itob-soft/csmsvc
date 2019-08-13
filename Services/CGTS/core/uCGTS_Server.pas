unit uCGTS_Server;

interface

uses SysUtils, Classes, CityGuideSDK_TLB, IniFiles, IdHTTPServer, IdContext, IdCustomHTTPServer,
     PNGImage, ComObj, ActiveX, StrUtils, XmlIntf, XmlDoc, Math, SyncObjs,
     // Self
     uINGITConst, uCGTS_ServerConst, uCSMExtServer, uAdds;

type    
    TArD   = array of Double;

    TCGTSServer = class; // Forward

    // Элемент для обработки
    TReqElem = class
    private
       fpReq        : TIdHTTPRequestInfo; 
       fpResp       : TIdHTTPResponseInfo; 
       ffProcessed  : Boolean;
       fiRes        : HRESULT;
       ffFailed     : Boolean;
       function getProcessed() : Boolean;
       procedure setProcessed(Value : Boolean);
       function getFailed() : Boolean;
       function setFailed() : Boolean;
    public
       constructor Create(_pReq  : TIdHTTPRequestInfo; _pResp  : TIdHTTPResponseInfo);
       // ==================== PROPERTIES ===========================================
       property pReq        : TIdHTTPRequestInfo     read fpReq         write fpReq; 
       property pResp       : TIdHTTPResponseInfo    read fpResp        write fpResp;
       property fProcessed  : Boolean                read getProcessed  write setProcessed;       
       property fFailed     : Boolean                read getFailed;
       property iRes        : HRESULT                read fiRes         write fiRes;
    end;

    // Поток обработки
    TProcElem = class(TThread)
    private
        fpSDKCreator   : CgSdkLocalCreator;
        fpCityUser     : CityGuideUser;
        fpProjection   : Projection;

        fpCoordConv    : CoordinateConverter;

        fsDir          : string;
        fsMap          : string;
        fpServ         : TCGTSServer;
    protected 
        // Инициация карты 
        function InitMap() : Boolean;
        // Обработка элемента
        procedure ProcessElem(_pElem : TReqElem);  
        // Основные функции обработки
        function GetTileResponse(_pReq : TIdHTTPRequestInfo; _pResp: TIdHTTPResponseInfo) : HRESULT;
        function GetRouteResponse(_pReq : TIdHTTPRequestInfo; _pResp: TIdHTTPResponseInfo) : HRESULT;
        function GetRouteListResponse(_pReq : TIdHTTPRequestInfo; _pResp: TIdHTTPResponseInfo) : HRESULT;
        function GetAdrResponse(_pReq : TIdHTTPRequestInfo; _pResp: TIdHTTPResponseInfo) : HRESULT;
        function GetLenResponse(_pReq : TIdHTTPRequestInfo; _pResp: TIdHTTPResponseInfo) : HRESULT;
        function GetCoordResponse(_pReq : TIdHTTPRequestInfo; _pResp: TIdHTTPResponseInfo) : HRESULT;
        // Вспомогательные
        function GetPointListByParams(ARequestInfo: TIdHTTPRequestInfo;
                                      var _arPoints : TArD; var _rRatio : Double;
                                      var _TypeOutput    : string) :  Boolean;
        // Извлекает значение из строки и преобразует в радианы
        function GetCoordByStrRad(_sValue : string) : Double;
        // Обработка типа
        function GetCoordByNodeValueStrRad(_pNode : IXMLNode; _sSubNodeName : string) : Double;
        // Запрос параметра
        function getParamsByName(_sParamName : string; _pParams : TStrings) : string;
        procedure SaveXMLToResp(_pXML : IXMLDocument; _pResp: TIdHTTPResponseInfo;
          const _TypeOutput: string = 'xml');
        procedure SaveStrToResp(_sData : string; _pResp: TIdHTTPResponseInfo);

        // Цикл
        procedure Execute(); override;
    public
        constructor Create(_sMap, _sDir : string; _pServ : TCGTSServer);
    end;


    // Сервер - обертка
    TCGTSServer = class(TCSMAdditionServer)
    private
        fsDir          : string;               // Папка с файлами
        fsMap          : string;               // Путь к карте
        fpReqElems     : TList;
        fpProcElems    : TList;
        function InitMaps(_iCnt : Integer) : HRESULT;
    public
        // Очищает папку с тайлами
        procedure ClearTileDir();
        // Функция для извлечение
        function GetNewElem() : TReqElem;
        procedure PutElem(_pElem : TReqElem);
        // Запуск
        function Init(const _sMap : string; _iCntMaps : Integer) : Boolean;
        // Добавить лог
        procedure AddToLog(_sPos, _sError : string; _iRes : HRESULT);

        //Считывание параметров из ini-файла
        function LoadFromIni(_pIniFile : TIniFile) : Boolean; override;
        // =================== Конструкторы
        constructor Create;
        destructor Destroy(); override;
        // Обработка запроса тайлов
        function ProcessTile(const _sLParam, _sZParam, _sXParam, _sYParam, _sHost, _sPath: string; _pStream : TStream) : HRESULT;

        // Обработка данных запроса сервером
        function ProcessRequest(_pReq : TIdHTTPRequestInfo; _pResp : TIdHTTPResponseInfo) : HRESULT; override;
        // ==================== PROPERTIES ===================
        property sDir  : string    read fsDir    write fsDir;
        property sMap  : string    read fsMap    write fsMap;

    end;

var
    pMapSect : TCriticalSection;
    pLog     : TCriticalSection;
    
implementation

uses
    ShellAPI, itob_ext_functions, uGlobalUtils, uProjConst, uRotesUtils, Contnrs,
    superxmlparser, superobject;

{ TCGTSServer }

procedure TCGTSServer.AddToLog(_sPos, _sError: string; _iRes: HRESULT);
var
    pList     : TStringList; 
    sFileName : string;
begin
    sFileName := GetInstancePath() + 'CityGUID.log';
    pList := TStringList.Create();
    pLog.Enter;
    try
        try
            if(FileExists(sFileName)) then
                pList.LoadFromFile(sFileName);
            pList.Add(DateTimeToStr(Now()) + ' : ' + _sPos + ' - ' + _sError + '(' + IntToStr(_iRes) + ')');
            pLIst.SaveToFile(sFileName);        
        except
            // Отправлять далее некуда
        end;
    finally
        pLog.Release;
        FreeAndNil(pList);
    end;
end;
// -------------------------------------------------------------------------

procedure TCGTSServer.ClearTileDir;
begin
    DeleteDir(fsDir, false);
end;
// -------------------------------------------------------------------------

constructor TCGTSServer.Create;
begin
    inherited Create(asCGTS);
    fpReqElems     := TList.Create();
    fpProcElems    := TList.Create();
    SetURLParts([S_RENDER_REQ, S_ROUTE_REQ, S_ADDR_REQ ,S_LEN_REQ, S_COORD_REQ, S_ROUTE_LIST]);
end;
// -------------------------------------------------------------------------

destructor TCGTSServer.Destroy;
var
    i : Integer;
begin
    for i := 0 to pred(fpProcElems.Count) do
        TProcElem(fpProcElems.Items[i]).Terminate;
    FreeAndNil(fpProcElems);    

    for i := 0 to pred(fpReqElems.Count) do
        TObject(fpReqElems.Items[i]).Free();
    FreeAndNil(fpReqElems);
    AddToLog('TCGTSServer.Destroy', 'Server stopped', 0);

    inherited;
end;
// ---------------------------------------------------------------------------------

function TCGTSServer.Init(const _sMap : string; _iCntMaps : Integer) : Boolean;
begin
	Result := false;
  fsMap  := _sMap;
  fsDir  := GetInstancePath() + 'tiles\';
  if Enabled then begin
    try
			InitMaps(_iCntMaps);
      Result := result;
      AddToLog('TCGTSServer.Init', 'Server started', 0)
    except
      on E : Exception do
      begin
        AddToLog('TCGTSServer.Init', E.Message, 0);
        Result := false;
      end;
    end;
  end;
end;
// -------------------------------------------------------------------------

function TCGTSServer.InitMaps(_iCnt: Integer): HRESULT;
var
		 i            : Integer;
		 pProcElem    : TProcElem;
begin
		Result := S_OK;
		for i := 0 to pred(_iCnt) do
		begin
			pProcElem := TProcElem.Create(fsMap, fsDir, Self);
				fpProcElems.Add(pProcElem);
				pProcElem.Resume();
		end;
end;

function TCGTSServer.LoadFromIni(_pIniFile: TIniFile): Boolean;
var
    iCount        : Integer;
    sMapPath      : string;
    iEnabled      : Integer;
begin
  try
    with _pIniFile do
    begin
        iCount      := ReadInteger(S_CGTS_ROOT, S_CGTS_COUNT,   10);
				sMapPath    := ReadString(S_CGTS_ROOT,  S_IIPS_MAPPATH, '');
        iEnabled    := ReadInteger(S_CGTS_ROOT, S_IIPS_ENABLED, 0);
    end;
    FEnabled := iEnabled = 1;

		Result := Init(sMapPath,iCount);
  except
    Result := false;
  end;
end;

// -------------------------------------------------------------------------

function TCGTSServer.ProcessRequest(_pReq: TIdHTTPRequestInfo;
  _pResp: TIdHTTPResponseInfo): HRESULT;
var
    iReqType     : TReqType;
    iRes         : HRESULT;
    pElem        : TReqElem;
    i            : Integer;
begin
    iRes := S_OK;
    CoInitialize(nil);
    try
        try
            iReqType := GetReqTypeByStr(_pReq.Document);
            if(iReqType <> rtNone) then
            begin
                pElem := TReqElem.Create(_pReq, _pResp);
                PutElem(pElem);
                for i := 0 to 150 do
                begin
                    Sleep(100);
                    if(pElem.fProcessed) then break;
                end;
                // Если все ок - освобождаем если нет освободиться потом
                if(not pElem.fProcessed) then
                begin
                    if(pElem.SetFailed()) then FreeAndNil(pElem);
                    _pResp.ResponseNo := 404;
                    _pResp.ResponseText := 'Error ' + IntToStr(iRes);
                    _pResp.ContentType := 'txt';
                    iRes := S_FALSE;
                end else
                    FreeAndNil(pElem);
            end;
        except
            on E : Exception do
                AddToLog('TCGTSServer.ServerCommandGet(' + _pReq.Document + ') ', E.Message, iRes);
        end;
    finally
        CoUnInitialize();
    end;
    Result := iRes;
end;

function TCGTSServer.ProcessTile(const _sLParam, _sZParam, _sXParam,
  _sYParam, _sHost, _sPath: string; _pStream: TStream): HRESULT;
var
  locpReq: TIdHTTPRequestInfo;
  locpResp: TIdHTTPResponseInfo;
begin
  locpReq := TIdHTTPRequestInfo.Create(nil);
  locpResp := TIdHTTPResponseInfo.Create(nil,locpReq,nil);
  try
    locpReq.Document := '/render/'+_sZParam+'/'+_sXParam+'/'+_sYParam;
    Result := ProcessRequest(locpReq,locpResp);
    if Assigned(locpResp.ContentStream) then
      _pStream.CopyFrom(locpResp.ContentStream,locpResp.ContentStream.Size);
  finally
    locpReq.Free;
    locpResp.free;
  end;
end;

procedure TCGTSServer.PutElem(_pElem: TReqElem);
begin
    pMapSect.Enter();
    try
        fpReqElems.Add(_pElem);
    finally
        pMapSect.Leave();
    end;
end;
// -------------------------------------------------------------------------

function TCGTSServer.GetNewElem: TReqElem;
begin
    pMapSect.Enter();
    try
        Result := nil;
        if(fpReqElems.Count > 0) then
        begin
            Result := fpReqElems.Items[0];
            fpReqElems.Delete(0);
        end; 
    finally
        pMapSect.Leave();
    end;
end;
// -------------------------------------------------------------------------

function TProcElem.getParamsByName(_sParamName : string; _pParams : TStrings) : string;
var
    i     : Integer;
    sName : string;
begin
    Result := '';
    sName := AnsiUpperCase(_sParamName);
    for i := 0 to pred(_pParams.Count) do
        if(AnsiUpperCase(_pParams.Names[i]) = sName) then
            Result := _pParams.ValueFromIndex[i];
end;
// -------------------------------------------------------------------------


procedure TProcElem.SaveStrToResp(_sData : string;  _pResp: TIdHTTPResponseInfo);
var
    pStream : TStringStream;
begin
    pStream := TStringStream.Create(string(AnsiToUTF8(_sData)), TEncoding.UTF8);
    _pResp.ContentStream := pStream;
    _pResp.ContentLength := pStream.Size;
end;
// -------------------------------------------------------------------------

procedure TProcElem.SaveXMLToResp(_pXML : IXMLDocument; _pResp: TIdHTTPResponseInfo;
  const _TypeOutput: string);
var
    pStream : TMemoryStream;
    locJson : ISuperObject;
begin
    pStream := TMemoryStream.Create();
    _pXML.SaveToStream(pStream);
    if AnsiSameText(_TypeOutput,'json') then
    begin
      locJson := XMLParseStream(pStream,true);
      pStream.Clear;
      locJson.SaveTo(pStream);
      locJson := nil;
    end;

    _pResp.ContentStream := pStream;
    _pResp.ContentLength := pStream.Size;
end;
// -------------------------------------------------------------------------


function TProcElem.GetCoordResponse(_pReq : TIdHTTPRequestInfo; _pResp: TIdHTTPResponseInfo) : HRESULT;
const
    I_SEARCH_R = 5000;
var
    sAddr        : string;
    pList        : TStringList;
    pCatalog     : Catalog;
    pChart       : Chart;
    pAddrInfo    : AddressInfo;
    pSetInfo     : ISettlementsInfo;
    i, k, m      : Integer;
    pCurPoint    : GeoPoint;
    sHouse       : string;
    sRes         : string;
    rLat, rLon   : Double;
    pStream      : TMemoryStream;
    pXML         : IXMLDocument;
    pNode        : IXMLNode;
    pFSetting    : TFormatSettings;
    fHouse       : Boolean;
    sDHouse      : string;
begin
    pFSetting.DecimalSeparator := '.';
    rLat := 0;
    rLon := 0;
    try
        // Определяем входящие параметры
        Result :=  E_CITY_GUID_NO_PARAMS;
        _pReq.Params.Text := IMCS2URLDecodeNew(_pReq.UnparsedParams);
        sAddr := getParamsByName('Address', _pReq.Params);
        pList := TStringList.Create();
        try
            pList.Delimiter := ',';
            pList.StrictDelimiter := true;
            pList.DelimitedText := sAddr;
            if(pList.Count < 3) then Exit;
            pCatalog    := Catalog(fpCityUser.GetCatalog());
            if(pCatalog.GetChartsCount = 0) then Exit;
            pChart     :=  Chart(pCatalog.GetChartInfoByNumber(0));
            pSetInfo := ISettlementsInfo(pChart.SettlementsInfo(Trim(pList.Strings[2])));
            if(pSetInfo.GetCount() = 0) then Exit;
            fHouse := false;
            for i := 0 to pred(pSetInfo.GetCount()) do
            begin
                pAddrInfo := AddressInfo(pChart.AddressInfo2(pSetInfo.GetCookie(i), Trim(pList.Strings[0])));
                Result := E_CITY_GUID_E_NO_STREET;
                if(pAddrInfo.GetStreetsCount() = 0) then continue;
                for m := 0 to pred(pAddrInfo.GetStreetsCount()) do
                begin
                   pCurPoint := GeoPoint(pAddrInfo.GetPosition(m, -1));
                   for k := 0 to pred(pAddrInfo.GetHousesCount(m)) do
                   begin
                       sHouse := Trim(StringReplace(AnsiUpperCase(pList.Strings[1]), 'ДОМ', '', [rfReplaceAll, rfIgnoreCase]));
                       sDHouse := AnsiUpperCase(pAddrInfo.GetTitle(m, k));
                       if(sHouse = sDHouse) then
                       begin
                           pCurPoint := GeoPoint(pAddrInfo.GetPosition(m, k));
                           fHouse := true;
                           break;
                       end;
                   end;
                   rLat := pCurPoint.Lat / pi * 180;
                   rLon := pCurPoint.Lon / pi * 180;
                   // Сборка XML
                   Result := S_OK;
                   if(fHouse) then break;
                end;
                if(fHouse) then break;
            end;
            if((Trim(pList.Strings[1]) <> '') and (Result = S_OK) and not fHouse) then Result := E_CITY_GUID_E_NO_HOUSE;
            sRes := S_SEARCH_FALSE;
            if(Result = S_OK) then sRes := S_SEARCH_OK;

            pNode  := InitXML(S_COORD_XML_ADDR, pXML);
            AddSNode(pNode, S_COORD_XML_RES, sRes);
            AddSNode(pNode, S_COORD_XML_LAT, FloatToStr(rLat, pFSetting));
            AddSNode(pNode, S_COORD_XML_LON, FloatToStr(rLon, pFSetting));
            pStream := TMemoryStream.Create();
            pXML.SaveToStream(pStream);
            _pResp.ContentStream := pStream;
            _pResp.ContentLength := pStream.Size;
        finally
            FreeAndNil(pList);
        end;
    except
       on E : Exception do
       begin
           Result := E_CITY_GUID_TOT_COORD_RESP;
           fpServ.AddToLog('TProcElem.GetCoordResponse', E.Message, Result);
       end;
    end;
end;
// -------------------------------------------------------------------------

{ TReqElem }

constructor TReqElem.Create(_pReq: TIdHTTPRequestInfo; _pResp: TIdHTTPResponseInfo);
begin
    inherited Create();
    fpReq        := _pReq;
    fpResp       := _pResp;
    ffProcessed  := false;
    ffFailed     := false;
end;
// ----------------------------------------------------------

function TReqElem.getFailed() : Boolean;
begin
    pMapSect.Enter;
    try
        Result := ffFailed;
    finally
        pMapSect.Leave;
    end;
end;
// ----------------------------------------------------------

function TReqElem.getProcessed: Boolean;
begin
    pMapSect.Enter;
    try
        Result := ffProcessed;
    finally
        pMapSect.Leave;
    end;
end;
// ----------------------------------------------------------

function TReqElem.setFailed(): Boolean;
begin
    pMapSect.Enter;
    try
        Result := ffProcessed;
        ffFailed := true;
    finally
        pMapSect.Leave;
    end;
end;
// ----------------------------------------------------------

procedure TReqElem.setProcessed(Value: Boolean);
begin
    pMapSect.Enter;
    try
        ffProcessed := Value;
    finally
        pMapSect.Leave;
    end;
end;
// ----------------------------------------------------------

{ TProcElem }

constructor TProcElem.Create(_sMap, _sDir: string; _pServ : TCGTSServer);
begin
    inherited Create(true);
    FreeOnTerminate := true;
    fpServ := _pServ;
    fsDir := _sDir;
    fsMap := _sMap;
end;
// ----------------------------------------------------------

procedure TProcElem.ProcessElem(_pElem : TReqElem); 
var
    iReqType : TReqType;
    iRes     : HRESULT;    
begin
    if(not Assigned(_pElem)) then Exit;
    iRes := S_OK;
    try
        iReqType := GetReqTypeByStr(_pElem.fpReq.Document);
        case iReqType of
            rtNone    : iRes := E_CITY_GUID_NO_SUPPORT;
            rtTile    : iRes := GetTileResponse(_pElem.fpReq, _pElem.fpResp);
            rtRoute   : iRes := GetRouteResponse(_pElem.fpReq, _pElem.fpResp);
            rtAdr     : iRes := GetAdrResponse(_pElem.fpReq, _pElem.fpResp);
            rtLen     : iRes := GetLenResponse(_pElem.fpReq, _pElem.fpResp);
            rtCoord   : iRes := GetCoordResponse(_pElem.fpReq, _pElem.fpResp);
            rtRoutelist : iRes := GetRouteListResponse(_pElem.fpReq, _pElem.fpResp);
        end;
        // Ошибочный ответ
        if(iRes <> S_OK) then
        begin
            _pElem.fpResp.ResponseNo := 404;
            _pElem.fpResp.ResponseText := 'Error ' + IntToStr(iRes);    
            _pElem.fpResp.ContentType := 'txt';
        end;
        _pElem.iRes := iRes;       
    except
        on E : Exception do
            fpServ.AddToLog('TProcElem.ProcessElem', E.Message, iRes);
    end;    
end;
// ----------------------------------------------------------

procedure TProcElem.Execute;
var
    ffInited    : Boolean;
    pElem       : TReqElem;
begin
    CoInitialize(nil);
    try
        ffInited := InitMap();
        while(not Terminated) do
        begin
            Sleep(10);
            if(not ffInited) then continue;
            try
                 pElem := fpServ.GetNewElem();
                 try
                     if(not Assigned(pElem)) then continue;
                     ProcessElem(pElem); 
                 finally
                     // Зачистка
                     if(Assigned(pElem)) then
                     begin
                         pElem.fProcessed := true;
                         if(pElem.ffFailed) then FreeAndNil(pElem);
                         pElem := nil;
                     end;
                 end;
            except
               on E : Exception do
                   fpServ.AddToLog('TProcElem.Execute', E.Message, 0);
            end;
        end;
    finally
        fpSDKCreator   := nil;
        fpCityUser     := nil;
        fpProjection   := nil;
        CoUnInitialize();
    end;
end;
// ----------------------------------------------------------

function TProcElem.GetTileResponse(_pReq : TIdHTTPRequestInfo; _pResp: TIdHTTPResponseInfo) : HRESULT;
var
    pList                        : TStringList;
    iX, iY, iZ, iPixY0, iPixX0   : Integer;
    rLat0, rLon0                 : Double;
    rScale                       : Double;
    sFileName                    : string;
    pRes                         : TMemoryStream;
    fpMapView      : MapView;
begin
    Result := E_CITY_GUID_NO_PARAMS;
    pList := TStringList.Create();
    try
        // Извлечение входящих данных
        pList.Delimiter := S_SLASH;
        pList.DelimitedText := _pReq.Document;
        if(pList.Count = 0) then Exit;
        if(pList.Strings[0] = '') then pList.Delete(0);
        if(pList.Count = 0) then Exit;
        iZ := StrToIntDef(pList.Strings[1],0);
        iX := StrToIntDef(pList.Strings[2],0);
        iY := StrToIntDef(pList.Strings[3],0);
        // Проверка наличия файла
        sFileName := fsDir + IntToStr(iZ) + S_BACK_SLASH + IntToStr(iX) +
                                            S_BACK_SLASH + IntToStr(iY) + S_PNG_EXT;
        ForceDirectories(ExtractFilePath(sFileName));
        if(not FileExists(sFileName)) then
        begin
            // Расчет координат
            iPixX0 := iX * 256;
            iPixY0 := iY * 256;
            XYToLonLatRad(iPixX0 {- 256},        iPixY0 {- 256},     iZ, rLat0, rLon0);
            // Расчет масштаба
            rScale := 225943577 / power(2, iZ - 1) * 5 * 0.97360230594;

    //       XYToLonLatRad(iPixX0 - 256 ,        iPixY0 - 256,     iZ, rLat0, rLon0);
        //    XYToLonLatRad(iPixX0 + 256 * 2,     iPixY0 + 256 * 2, iZ, rLat1, rLon1);

            rScale := Ceil(225943577 / power(2, iZ - 1)) ;

            // Hассчитываем изображение
           // fpCoordConv.ScreenToGeo(iPixX0,iPixY0,rLat0,rLon0);
//            fpProjection.SetPosition(rLat0, rLon0, 0, 0 );
            fpProjection.SetScale(rScale, 0, 0);
            fpProjection.SetPosition(rLat0, rLon0, 0, 0);
          //  fpProjection.SetPosition((55.75 / 180 * 3.14), (37.62 / 180  * 3.14), 0, 0 );
        //    fpProjection.SetScale(rScale, 0, 0);

        fpMapView := MapView(fpCityUser.GetMapView);
        fpMapView.SetScreenSize(256, 256);

            fpMapView.DrawToFile(sFileName);
        end;
        // Отпрвка
        if(FileExists(sFileName)) then
        begin
            pRes := TMemoryStream.Create();
            pRes.LoadFromFile(sFileName);
            _pResp.ContentStream := pRes;
            _pResp.ContentLength := pRes.Size;
            _pResp.ContentType := 'image/png';
            Result := S_OK;
        end else
            Result := E_CITY_GUID_NO_MAP;
    finally
        FreeAndNil(pList);
    end;
end;
// -------------------------------------------------------------------------

function TProcElem.InitMap: Boolean;
var
    pCatalog        : Catalog;
    pJams           : Jams;
		pSett           : ContextSettings;

		procedure locLoadChart();
		var
			fileList 		: TStrings;
			cnt 				  : integer;
		begin
			fileList := TStringList.Create;
			try
				if 		SameText(ExtractFileExt(fsMap),S_MAP_LST_EXT) then begin
					if AnsiPos('\',fsMap) = 0 then
						fsMap := ExtractFilePath(ParamStr(0))+fsMap;
					if not FileExists(fsMap) then begin
						raise Exception.Create('Ошибка доступа к файлу '+fsMap)
					end;
					fileList.LoadFromFile(fsMap);
				end else fileList.Add(fsMap);
				cnt := 0;
				while cnt < filelist.Count do begin
					pCatalog.InsertChart(fileList[cnt]);
					inc(cnt);
				end;
			finally
				fileList.Free;
      end;
		end;

begin
		// Установка старта
		try
				// Базоый класс отрисовки
				OleCheck(CoCreateInstance(CLASS_CgSdkLocalCreator, nil, CLSCTX_INPROC_SERVER or
																	CLSCTX_LOCAL_SERVER, IDispatch, fpSDKCreator));
				// CityGUID пользователь
				fpCityUser := CityGuideUser(fpSDKCreator.CreateCityGuideUser);
				pJams := Jams(fpCityUser.GetJams);
				pJams.AutoApplying := true;
				// Установка карты
				pCatalog    := Catalog(fpCityUser.GetCatalog());
				locLoadChart;
        pSett := ContextSettings(fpCityUser.GetContextSettings);
        pSett.ShowJamsMode := 3;
        // Установка басового масштаба ?
        fpProjection := Projection(fpCityUser.GetProjection());
        // >> ?
        fpProjection.SetPosition((60.90 / 180 * pi), (30.13 / 180 * pi), 100, 100);
        fpProjection.SetScale(1000000, 100, 100);
        // <<
        //fpMapView := MapView(fpCityUser.GetMapView);
        //fpMapView.SetScreenSize(256, 256);

        fpCoordConv := CoordinateConverter(fpCityUser.GetCoordinateConverter);

        Result := true;
    except
        on E : Exception do
        begin
            Result := false;
            fpServ.AddToLog('TProcElem.InitMap(' + fsMap + ')', E.Message, 0);
        end;
    end;
end;
// -------------------------------------------------------------------------

function TProcElem.GetRouteListResponse(_pReq: TIdHTTPRequestInfo;
  _pResp: TIdHTTPResponseInfo): HRESULT;
var
    pRoute                    : Route;
    pInfo                     : RouteInfo;
    pNode                     : IXMLNode;
    pXMl                      : IXMLDocument;
    pXMlIn                    : IXMLDocument;
    pFormatSettings           : TFormatSettings;
    pCurNode                  : IXMLNode;
    i                         : Integer;
    pStr      : string;
    pStr1     : TStringStream;
		roteList  : TObjectList;
		step : integer;
begin
				step := 0;
		Result := E_CITY_GUID_NO_PARAMS;
		try
			pStr1 := TStringStream.Create;
			try
				step := 1;
				pStr1.CopyFrom(_pReq.PostStream,_pReq.ContentLength);
				step := 2;
				pStr := pStr1.DataString;
				step := 3;

			finally
				pStr1.Free;
			end;
			step := 4;
			if OpenXML(pStr,pXMlIn) <> S_OK then exit;
			step := 5;

			roteList := TObjectList.Create(true);
			try
			step := 6;
				RoutesLoadFromXML(pXMlIn.ChildNodes.FindNode('RoutesRequest'),roteList);
			step := 7;
				if roteList.Count = 0 then exit;
			step := 8;

				pRoute := Route(fpCityUser.GetRoute);
			step := 9;
				pRoute.SetRouteType(I_ROUTE_TYPE_1);
			step := 10;
				// Сохранение в XML
				pFormatSettings.DecimalSeparator := '.';
			step := 11;
				pNode := InitXML(S_ROUTES_ROOT, pXML);
			step := 12;
				for i := 0 to roteList.Count-1  do
				begin
						pRoute.Drop();
						pRoute.SetStart(TRoteInfo(roteList[i]).Lat1 * pi / 180 , TRoteInfo(roteList[i]).Lon1 * pi / 180);
						pRoute.SetFinish(TRoteInfo(roteList[i]).Lat2 * pi / 180 , TRoteInfo(roteList[i]).Lon2 * pi / 180);
						pInfo := RouteInfo(pRoute.GetRouteInfo);

						pCurNode := AddSNode(pNode, S_ROUTE_ROOT, '');
						AddSNode(pCurNode, S_ROUTE_POINT_ID,    inttostr(TRoteInfo(roteList[i]).ID));
						AddSNode(pCurNode, S_ROUTE_POINT_LENGTH, IntToStr(trunc(pInfo.GetDistance())));
						AddSNode(pCurNode, S_ROUTE_POINT_DURAT,  IntToStr(trunc(pInfo.GetTime())));
				end;
			step := 13;
				// Освободит DOM парсер
				SaveXMLToResp(pXML, _pResp);
			step := 14;
			finally
				roteList.Free;
			end;
			Result := S_OK;
		except
			on E : Exception do
			begin
				Result := E_CITY_GUID_GEN_ROUTE_LIST;
				fpServ.AddToLog('TProcElem.GetRouteListResponse', 'Строка с ошибкой = '+inttostr(step)+'. '
					+ E.Message , Result);
			end;
		end;
end;

function TProcElem.GetRouteResponse(_pReq : TIdHTTPRequestInfo; _pResp: TIdHTTPResponseInfo) : HRESULT;
var
		pRoute                    : Route;
		pInfo                     : RouteInfo;
		arData, arPoints          : TArD;
		rRatio                    : Double;
		pNode                     : IXMLNode;
		pXMl                      : IXMLDocument;
		pFormatSettings           : TFormatSettings;
		pCurNode                  : IXMLNode;
		i, k                      : Integer;
		pCurNode2, pCurNode3      : IXMLNode;
		sTypeOutput               : string;

		step : integer;
begin
	step := 0;
		Result := E_CITY_GUID_NO_PARAMS;
		try
	step := 1;
				if(not GetPointListByParams(_pReq, arPoints, rRatio,sTypeOutput)) then Exit;
	step := 2;
		pRoute := Route(fpCityUser.GetRoute);
	step := 3;
				pRoute.SetRouteType(1);
	step := 4;
				// Сохранение в XML
		pFormatSettings.DecimalSeparator := '.';
	step := 5;
				pNode := InitXML(S_ROUTE_ROOT, pXML);
	step := 6;
		for i := 0 to pred(pred(Length(arPoints) div 2)) do
		begin
			pCurNode := AddSNode(pNode, S_ROUTE_POINTS_ROOT, '');
			AddSNode(pCurNode, S_ROUTE_POINT_LAT,    FloatToStr(arPoints[i * 2 + 2] / pi * 180, pFormatSettings));
			AddSNode(pCurNode, S_ROUTE_POINT_LON,    FloatToStr(arPoints[i * 2 + 3] / pi * 180, pFormatSettings));
			AddSNode(pCurNode, S_ROUTE_POINT_INDEX,  IntToStr(i + 1));

			pCurNode2 := AddSNode(pCurNode, S_ROUTE_POINT_PATH, '');

			if (arPoints[i * 2] =  arPoints[i * 2 + 2] ) and
				(arPoints[i * 2 + 1] =  arPoints[i * 2 + 3] ) then
			begin// Если две соседние точки маршрута совпадают
				AddSNode(pCurNode, S_ROUTE_POINT_LENGTH, IntToStr(0));
				AddSNode(pCurNode, S_ROUTE_POINT_DURAT,  IntToStr(0));

				pCurNode3 := AddSNode(pCurNode2, S_PATH_POINT, '');
				for k := 0 to 1 do
				begin
					AddSNode(pCurNode3, S_PATH_POINT_INDEX, IntToStr(k + 1));
					AddSNode(pCurNode3, S_PATH_POINT_LAT,   FloatToStr(arPoints[i * 2] / pi * 180, pFormatSettings));
					AddSNode(pCurNode3, S_PATH_POINT_LON,   FloatToStr(arPoints[i * 2 + 1] / pi * 180, pFormatSettings));
					AddSNode(pCurNode3, S_PATH_POINT_NAME,  '');
				end;
			end else begin
				pRoute.Drop();
				pRoute.SetStart(arPoints[i * 2], arPoints[i * 2 + 1]);
				pRoute.SetFinish(arPoints[i * 2 + 2], arPoints[i * 2 + 3]);
				pInfo := RouteInfo(pRoute.GetRouteInfo);

				AddSNode(pCurNode, S_ROUTE_POINT_LENGTH, IntToStr(trunc(pInfo.GetDistance())));
				AddSNode(pCurNode, S_ROUTE_POINT_DURAT,  IntToStr(trunc(pInfo.GetTime())));


				arData := pInfo.GetTrack();
				for k := 0 to pred(Length(arData) div 2) do
				begin
					pCurNode3 := AddSNode(pCurNode2, S_PATH_POINT, '');
					AddSNode(pCurNode3, S_PATH_POINT_INDEX, IntToStr(k + 1));
					AddSNode(pCurNode3, S_PATH_POINT_LAT,   FloatToStr(arData[k * 2] / pi * 180, pFormatSettings));
					AddSNode(pCurNode3, S_PATH_POINT_LON,   FloatToStr(arData[k * 2 + 1] / pi * 180, pFormatSettings));
					AddSNode(pCurNode3, S_PATH_POINT_NAME,  '');
				end;
				pRoute.Drop();
			end;
		end;
	step := 7;
		// Освободит DOM парсер
	step := 8;
				SaveXMLToResp(pXML, _pResp,sTypeOutput);
	step := 9;
				Result := S_OK;
		except
				on E : Exception do
				begin
						Result := E_CITY_GUID_GEN_ROUTE;
						fpServ.AddToLog('TProcElem.GetRouteResponse',  'Строка с ошибкой = '+inttostr(step)+'. '+E.Message, Result);
				end;
		end;
end;
// -------------------------------------------------------------------------

function TProcElem.GetAdrResponse(_pReq : TIdHTTPRequestInfo; _pResp: TIdHTTPResponseInfo) : HRESULT;
const
   I_SEARCH_R = 5000;
var
   sLat, sLon   : string;
   rLat, rLon   : Double;
   pCatalog     : Catalog;
   pChart       : Chart;
   pAddrInfo    : AddressInfo;
   pSett        : TFormatSettings;
   iAddr, iLen  : Integer;
   iHouse       : Integer;
   rScale       : Double;
   sRes         : string;
begin
    pSett.DecimalSeparator := '.';
    try
        // Определяем входящие параметры
        sLat := getParamsByName('Lat', _pReq.Params);
        sLon := getParamsByName('Lon', _pReq.Params);
        Result := E_CITY_GUID_NO_VALID_COORD;
        if(not TryStrToFLoat(sLat, rLat, pSett) or
           not TryStrToFLoat(sLon, rLon, pSett)) then Exit;
        // Извлекаем карту -> интерфейс обргеокодера
        Result := E_CITY_GUID_NO_MAP;
        pCatalog    := Catalog(fpCityUser.GetCatalog());
        if(pCatalog.GetChartsCount = 0) then Exit;
        pChart     :=  Chart(pCatalog.GetChartInfoByNumber(0));
        pAddrInfo  := AddressInfo(pChart.AddressInfo);
        // Определение расстояния
        rScale := fpProjection.GetScale();
        iLen := trunc(I_SEARCH_R / (0.000033796476 * rScale));
        // Определение улицы и дома
        iAddr := pAddrInfo.GetNearestStreet(rLat / 180 * pi, rLon / 180 * pi, iLen);
        iHouse := -1;
        if(iAddr > 0) then iHouse := pAddrInfo.GetNearestHouse(iAddr, rLat / 180 * pi, rLon / 180 * pi, iLen);
        if(iHouse and $800  > 0) then iHouse  := -1;
        sRes := pAddrInfo.GetTitle(iAddr, -1);
        if(iHouse > 0) then
            sRes := sRes + ',' + pAddrInfo.GetTitle(iAddr, iHouse);
        if(sRes <> '') then SaveStrToResp(sRes, _pResp);
        // Вывод результата
        Result := S_OK;
    except
       on E : Exception do
       begin
           Result := E_CITY_GUID_TOT_COORD_RESP;
           fpServ.AddToLog('TProcElem.GetAdrResponse', E.Message, Result);
       end;
    end;
end;
// -------------------------------------------------------------------------

function TProcElem.GetCoordByStrRad(_sValue : string) : Double;
var
    pFSetting  : TFormatSettings;
begin
    pFSetting.DecimalSeparator := S_SYM_POINT;
    Result := StrToFLoat(_sValue, pFSetting) / 180 * pi; 
end;
// -------------------------------------------------------------------------

function TProcElem.GetCoordByNodeValueStrRad(_pNode : IXMLNode; _sSubNodeName : string) : Double;
var
    sValue : string;
begin
    Result := 0;
    sValue := _pNode.ChildNodes.FindNode(_sSubNodeName).NodeValue;
    if(sValue <> '') then
        Result := GetCoordByStrRad(sValue);
end;
// -------------------------------------------------------------------------

function TProcElem.GetLenResponse(_pReq : TIdHTTPRequestInfo; _pResp: TIdHTTPResponseInfo) : HRESULT;
var
    i                           : Integer;
    pRoot, pNode, pRNode        : IXMLNode;
    pXMLIn, pXMLOut             : IXMLDocument;
    pNodeOut                    : IXMLNode;
    pRoute                      : Route;
    pInfo                       : RouteInfo;    
begin
    try
        Result := S_OK;
        pXMLIn := TXMLDocument.Create(nil);
        pXMLIn.LoadFromStream(_pReq.PostStream);
        // Создание выходного XML
        // ['{2987C4DC-A697-44FE-A5D8-8C82A0F8DB63}']
        pRNode := InitXML('Lengths', pXMLOut);
        // Разбор входящего XML
        pRoot := pXMLIn.DocumentElement;
        if(not pRoot.HasChildNodes) then Exit;

        for i := 0 to pred(pRoot.ChildNodes.Count) do
        begin
            pNode       := pRoot.ChildNodes[i];
            pNodeOut    := pRNode.AddChild(S_LENGTH_NODE);
            
            pRoute := Route(fpCityUser.GetRoute);
            pRoute.SetRouteType(1);
            pRoute.SetStart(GetCoordByNodeValueStrRad(pNode, S_ROUTE_POINT_LAT0), 
                            GetCoordByNodeValueStrRad(pNode, S_ROUTE_POINT_LON0));
            pRoute.SetFinish(GetCoordByNodeValueStrRad(pNode, S_ROUTE_POINT_LAT1), 
                            GetCoordByNodeValueStrRad(pNode, S_ROUTE_POINT_LON1));
            // Расчет расстояния
            pInfo := RouteInfo(pRoute.GetRouteInfo);
            pNodeOut.Attributes[S_LENGTH_ID] := pNode.ChildNodes.FindNode(S_ROUTE_POINT_ID).NodeValue;
            pNodeOut.Attributes[S_LENGTH_LEN] := IntToStr(trunc(pInfo.GetDistance()));
            pNodeOut.Attributes[S_LENGTH_DUR] := IntToStr(trunc(pInfo.GetTime()));
        end;
        // Сохранение
        _pResp.ContentStream := SaveXMLToStream(pXMLOut);
        _pResp.ContentLength := _pResp.ContentStream.Size;
    except
        on E : Exception do
        begin
            Result := E_GEN_LENGTH_GET;
            fpServ.AddToLog('TProcElem.GetLenResponse', E.Message, Result);
        end;    
    end;
end;
// -------------------------------------------------------------------------

// Вспомогательные CopyPaste из сервера INIT
function TProcElem.GetPointListByParams(ARequestInfo: TIdHTTPRequestInfo;
  var _arPoints : TArD; var _rRatio : Double; var _TypeOutput : string) :  Boolean;
var
    n, iSep        : Integer;
    sTemp          : string;
    iCount, iIter  : Integer;
    pSettings      : TFormatSettings;
begin
    Result := true;
    try
        iCount := 0;
        pSettings.DecimalSeparator := S_SYM_POINT;
        for n := 0 to pred(ARequestInfo.Params.Count) do
            if(PosEx('POINT', UpperCase(ARequestInfo.Params.Strings[n])) <> 0) then
                Inc(iCount);
        SetLength(_arPoints, iCount * 2);
        iIter := 0;
        _TypeOutput := 'xml';
        for n := 0 to pred(ARequestInfo.Params.Count) do
        begin
            if(PosEx('POINT', UpperCase(ARequestInfo.Params.Strings[n])) <> 0) then
            begin
                sTemp := StringReplace(ARequestInfo.Params.ValueFromIndex[n], '.', ',', [rfReplaceAll, rfIgnoreCase]);
                iSep := PosEx(';', sTemp);
                _arPoints[iIter * 2] := StrToFloat(Copy(sTemp, 1, iSep - 1)) / 180 * pi;
                _arPoints[iIter * 2 + 1] := StrToFloat(Copy(sTemp, iSep + 1, Length(sTemp) - iSep)) / 180 * pi;
                Inc(iIter);
            end else
            if(PosEx('OPTIMIZATIONTIMERATIO', UpperCase(ARequestInfo.Params.Strings[n])) <> 0) then
                _rRatio := StrToFloat(ARequestInfo.Params.ValueFromIndex[n], pSettings)
            else
            if(PosEx('OUTPUT', UpperCase(ARequestInfo.Params.Strings[n])) <> 0) then
                _TypeOutput := ARequestInfo.Params.ValueFromIndex[n];
        end;
    except
        on E : Exception do
        begin
            Result := false;
            fpServ.AddToLog('TProcElem.GetPointListByParams', E.Message, 0);
        end;    
    end;
end;
// ----------------------------------------------------------
Initialization
    pMapSect := TCriticalSection.Create();
    pLog     := TCriticalSection.Create();
end.
