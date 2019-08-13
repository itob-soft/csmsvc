unit uCSM_INGITServer;

interface

uses
    Windows, IdCustomHTTPServer, IdContext, IniFiles, SysUtils, uCSMExtServer, PNGImage, 
    Classes, Graphics, EPSG900913, StrUtils, XmlDoc, XmlIntf, frmIngit, uAdds,
    // Self
    uINGITPoole, uCSMUtils, uCSMConst, uProjConst, uINGITConst, uCSMTypes, uBitUtils, uGlobalUtils;
type
    // Добавочный сервер для работы с INGIT
    TCSM_INGITServer = class(TCSMAdditionServer)
    private
        pPoole : TINGITPoole;      // Пул обработчиков
        // ============================= Функции обработки запросов ============================
        // Отрисовка картинки
        function ProcessRender(_pElem : TINGITElem; _pReq : TIdHTTPRequestInfo; var _pStream : TMemoryStream) : HRESULT;
        // Выдача пути между двумя точками
        function ProcessRoute(_pElem : TINGITElem; _pReq : TIdHTTPRequestInfo; var _pStream : TMemoryStream) : HRESULT;
        // Выдача расстояний между точками
        function GetRouteListResponse(_pElem : TINGITElem; _pReq : TIdHTTPRequestInfo; var _pStream : TMemoryStream) : HRESULT;
        // Выдача адреса по координатам. Обратное геокодирование
        function ProcessAddr(_pElem : TINGITElem; _pReq : TIdHTTPRequestInfo; var _pStream : TMemoryStream) : HRESULT;
        // Выдача длинны пути
        function ProcessLength(_pElem : TINGITElem; _pReq : TIdHTTPRequestInfo; var _pStream : TMemoryStream) : HRESULT;
        // Выдача координат по адресу. Прямое геокодирование
        function ProcessCoord(_pElem : TINGITElem; _pReq : TIdHTTPRequestInfo; var _pStream : TMemoryStream) : HRESULT;
    public 
        // Обработка данных запроса сервером
        function ProcessRequest(_pReq : TIdHTTPRequestInfo; _pResp : TIdHTTPResponseInfo) : HRESULT; override;
        // Обработка запроса тайлов
        function ProcessTile(const _sLParam, _sZParam, _sXParam, _sYParam, _sHost, _sPath: string; _pStream : TStream) : HRESULT;
        // Загрузть данные из INi
        function LoadFromIni(_pIniFile : TIniFile) : Boolean; override;       
        // Удаление всех связанных с сервером файлов        
        procedure  ClearTempFiles(); override;
        // Конструкторы
        constructor Create();
        destructor Destroy(); override;
    end;

implementation

uses ActiveX, Contnrs, uRotesUtils, System.JSON;

{ TCSM_INGITServer }

procedure TCSM_INGITServer.ClearTempFiles();
begin
    inherited;

end;
// --------------------------------------------------------------------------

constructor TCSM_INGITServer.Create;
begin
    inherited Create(asIngit);
    pPoole     := TINGITPoole.Create();
    // Установка перехода
    SetURLParts([S_RENDER_REQ, S_ROUTE_REQ, S_ADDR_REQ ,S_LEN_REQ, S_COORD_REQ, S_ROUTE_LIST]);
end;
// --------------------------------------------------------------------------

destructor TCSM_INGITServer.Destroy;
begin
    FreeAndNil(pPoole);
    inherited;
end;

function TCSM_INGITServer.GetRouteListResponse(_pElem: TINGITElem;
  _pReq: TIdHTTPRequestInfo; var _pStream: TMemoryStream): HRESULT;
var
    pStr : string;
    pStr1 : TStringStream;
    roteList : TObjectList;
    pXMlIn : IXMLDocument;
begin
  CoInitialize(nil);
    pStr1 := TStringStream.Create;
    try
      pStr1.CopyFrom(_pReq.PostStream,_pReq.ContentLength);
      pStr := pStr1.DataString;
    finally
      pStr1.Free;
    end;
    if OpenXML(pStr,pXMlIn) <> S_OK then exit;
    roteList := TObjectList.Create(true);
    try
      RoutesLoadFromXML(pXMlIn.ChildNodes.FindNode('RoutesRequest'),roteList);
      if roteList.Count = 0 then exit;

      // Вызов определения путей
      Result := _pElem.GetRouteList(roteList, _pStream);

    finally
      roteList.Free;
    end;
  CoUninitialize;
end;

// --------------------------------------------------------------------------

function TCSM_INGITServer.LoadFromIni(_pIniFile: TIniFile): Boolean;
var
    iCount        : Integer;
    iRouteCount   : Integer;
    sMapPath      : string;
    iEnabled      : Integer;
begin
    try
        with _pIniFile do
        begin
            iRouteCount := ReadInteger(S_IIPS_ROOT, S_IIPS_COUNT_ROUTES,  2);
            iCount      := ReadInteger(S_IIPS_ROOT, S_IIPS_COUNT,        10);
            sMapPath    := ReadString(S_IIPS_ROOT,  S_IIPS_MAPPATH,      '');
            iEnabled    := ReadInteger(S_IIPS_ROOT, S_IIPS_ENABLED,       0);
        end;
        FEnabled := iEnabled = 1;
        if FEnabled then begin
          pPoole.Init(iCount, sMapPath, iRouteCount);
          pPoole.AddDataToLogTS(S_INIT_SERVER, S_OK);
        end else
          pPoole.AddDataToLogTS(S_INIT_SERVER, E_NO_DLL_INIT);
        Result := true;
    except
        Result := false;
    end;
end;
// --------------------------------------------------------------------------

function TCSM_INGITServer.ProcessRender(_pElem : TINGITElem; _pReq : TIdHTTPRequestInfo; 
                                        var _pStream : TMemoryStream) : HRESULT;
var 
    pList : TStringList;
    pImg  : TPNGImage;
begin
    Result := S_OK;
    pList := TStringList.Create();
    pImg  := nil;
    try
        pList.Delimiter := S_SLASH;
        pList.DelimitedText := _pReq.Document;
        if(pList.Count = 0) then Exit;
        if(pList.Strings[0] = '') then pList.Delete(0);
    
        if(pList.Count < 4) then Exit;
        Result := _pElem.RenderTile(StrToInt(pList.Strings[1]), StrToInt(pList.Strings[2]),
                                   StrToInt(Copy(pList.Strings[3], 1, Length(pList.Strings[3]) - 4)), pImg);

        if(Result <> S_OK) then
        begin
            pPoole.AddDataToLogTS(Format(S_NOT_RENDER_TILE, [pList.Strings[2],
                                                             StrToInt(Copy(pList.Strings[3], 1, Length(pList.Strings[3]) - 4)),
                                                             pList.Strings[1]]), Result);
            Exit;
        end;
        _pStream := TMemoryStream.Create();
        pImg.SaveToStream(_pStream);
    finally
        FreeAndNil(pList);
        FreeAndNil(pImg);
    end;
end;
// --------------------------------------------------------------------------

function TCSM_INGITServer.ProcessRoute(_pElem : TINGITElem; _pReq : TIdHTTPRequestInfo;
                                       var _pStream : TMemoryStream) : HRESULT;
var
    n, iSep        : Integer;
    sTemp          : string;
    iCount, iIter  : Integer;
    arLat, arLon   : TArD;
    pSettings      : TFormatSettings;
    rRatio         : Double;
    sTypeOutput    : string;
begin
    // Формирование набора точек
    iCount := 0;
    rRatio := 1;
    pSettings.DecimalSeparator := S_SYM_POINT;
    for n := 0 to pred(_pReq.Params.Count) do
        if(PosEx('POINT', UpperCase(_pReq.Params.Strings[n])) <> 0) then
            Inc(iCount);
    SetLength(arLat, iCount);
    SetLength(arLon, iCount);
    iIter := 0;
    sTypeOutput := 'xml';
    for n := 0 to pred(_pReq.Params.Count) do
    begin
        if(PosEx('POINT', UpperCase(_pReq.Params.Strings[n])) <> 0) then
        begin
            sTemp := StringReplace(_pReq.Params.ValueFromIndex[n], '.', ',', [rfReplaceAll, rfIgnoreCase]);
            iSep := PosEx(';', sTemp);
            arLat[iIter] := StrToFloat(Copy(sTemp, 1, iSep - 1));
            arLon[iIter] := StrToFloat(Copy(sTemp, iSep + 1, Length(sTemp) - iSep));
            Inc(iIter);
        end else
        if(PosEx('OPTIMIZATIONTIMERATIO', UpperCase(_pReq.Params.Strings[n])) <> 0) then
           rRatio := StrToFloat(_pReq.Params.ValueFromIndex[n], pSettings)
        else
        if(PosEx('OUTPUT', UpperCase(_pReq.Params.Strings[n])) <> 0) then
           sTypeOutput := _pReq.Params.ValueFromIndex[n];
    end;
    // Вызов определения пути
    Result := _pElem.GetRoute(rRatio, arLat, arLon, _pStream,sTypeOutput);
end;

function TCSM_INGITServer.ProcessTile(const _sLParam, _sZParam,
  _sXParam, _sYParam, _sHost, _sPath: string; _pStream: TStream): HRESULT;
var
    pList : TStringList;
    pImg  : TPNGImage;

    // new
    iCnt : Integer;
    pElem        : TIngitElem;
begin
  if not Enabled then begin
    result := E_NO_DLL_INIT;
    exit;
  end;
  // Извлечение свободного элемента
  Result := E_PM_NO_FREE_ELEM;
  iCnt := I_MAX_AVAILIBLE div I_STEP;
  while((Result = E_PM_NO_FREE_ELEM) and (iCnt > 0)) do
  begin
    Result := pPoole.LockElement(pElem);
    Sleep(I_STEP);
    Dec(iCnt);
  end;
  if((Result <> S_OK) or (not Assigned(pElem))) then
  begin
    if(Result <> E_PM_NO_FREE_ELEM) then pPoole.AddDataToLogTS(S_NOT_GETELEM, Result);
    if Assigned(pElem) then pPoole.UnLockElement(pElem);
    
    Exit;
  end;
  try
    Result := S_OK;
    pImg  := nil;
    try
        Result := pElem.RenderTile(StrToInt(_sZParam),StrToInt(_sXParam),StrToInt(_sYParam), pImg);

        if(Result <> S_OK) then
        begin
            pPoole.AddDataToLogTS(Format(S_NOT_RENDER_TILE, [pList.Strings[2],
                                                             StrToInt(Copy(pList.Strings[3], 1, Length(pList.Strings[3]) - 4)),                                                             pList.Strings[1]]), Result);
            Exit;
        end;
        pImg.SaveToStream(_pStream);
    finally
        FreeAndNil(pImg);
    end;
  finally
    pPoole.UnLockElement(pElem);
  end;
end;

// --------------------------------------------------------------------------

function TCSM_INGITServer.ProcessAddr(_pElem : TINGITElem; _pReq : TIdHTTPRequestInfo; 
                                      var _pStream : TMemoryStream) : HRESULT;
var
    pFSetting   : TFormatSettings;                                      
    sSep, sRes  : string;
    rLat, rLon  : Double;
begin
    Result := S_OK;
    GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, pFSetting);
    sSep := pFSetting.DecimalSeparator;
    sRes := '';
    if(TryStrToFloat(StringReplace(_pReq.Params.Values[S_ADDR_LAT_PARAM],
                                   S_SYM_POINT, sSep, [rfReplaceAll, rfIgnoreCase]), rLat) and
       TryStrToFloat(StringReplace(_pReq.Params.Values[S_ADDR_LON_PARAM],
                                   S_SYM_POINT, sSep, [rfReplaceAll, rfIgnoreCase]), rLon)) then
    begin
        Result := _pElem.GetAddress(rLat, rLon, sRes);
        if(Result <> S_OK) then
        begin
            pPoole.AddDataToLogTS(Format(S_NOT_ADDR_REQ, [FloatToStr(rLat), FloatToStr(rLon)]), Result);
            sRes := '';
        end;
        _pStream := TStringStream.Create(string(AnsiToUTF8(sRes)), TEncoding.UTF8);
    end;
end;
// --------------------------------------------------------------------------

function TCSM_INGITServer.ProcessLength(_pElem : TINGITElem; _pReq : TIdHTTPRequestInfo; 
                                        var _pStream : TMemoryStream) : HRESULT;
var                                        
    pFSetting   : TFormatSettings;                                      
    sRes        : string;
    pIn, pOut   : IXMLDocument;
begin
    GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, pFSetting);
    pFSetting.DecimalSeparator := S_SYM_POINT;
    sRes := '';
    pIn := TXMLDocument.Create(nil);
    pIn.LoadFromStream(_pReq.PostStream);
    Result := _pElem.GetLength(pIn, pOut);
    if(Result <> S_OK) then
    begin
        pPoole.AddDataToLogTS(S_NOT_LEN_REQ, Result);
        sRes := '';
    end else
        sRes := pOut.XML.Text;
    _pStream := TStringStream.Create(string(AnsiToUTF8(sRes)), TEncoding.UTF8);
end;
// --------------------------------------------------------------------------

function TCSM_INGITServer.ProcessCoord(_pElem : TINGITElem; _pReq : TIdHTTPRequestInfo;
                                       var _pStream : TMemoryStream) : HRESULT;
var                                        
    pFSetting         : TFormatSettings;                                      
    sRes, sAdr        : string;
    rLat, rLon        : Double;
    pNode             : IXMlNode;
    pXML              : IXMLDocument;
begin
  CoInitialize(nil);
  try
    GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, pFSetting);
    pFSetting.DecimalSeparator := S_SYM_POINT;
    rLat := 0;
    rLon := 0;
    _pReq.Params.Text := //F8ToAnsi(
      IMCS2URLDecodeNew(_pReq.UnparsedParams)
      //)
      ;
    sAdr := _pReq.Params.Values[S_COORD_ADDR_PARAM];
    sRes := S_SEARCH_FALSE;
    Result := _pElem.GetCoord(sAdr, rLat, rLon);
    if(Result = S_OK) then
        sRes := S_SEARCH_OK
    else
        pPoole.AddDataToLogTS(Format(S_NOT_GET_ADDR, [sAdr]), Result);
    // Сборка XML
    pNode  := InitXML(S_COORD_XML_ADDR, pXML);
    AddSNode(pNode, S_COORD_XML_RES, sRes);
    AddSNode(pNode, S_COORD_XML_LAT, FloatToStr(rLat, pFSetting));
    AddSNode(pNode, S_COORD_XML_LON, FloatToStr(rLon, pFSetting));
    // Выгрузка наружу
    _pStream := TMemoryStream.Create();
    pXML.SaveToStream(_pStream);
  finally
    CoUninitialize;
  end;
end;
// --------------------------------------------------------------------------




function TCSM_INGITServer.ProcessRequest(_pReq: TIdHTTPRequestInfo; _pResp: TIdHTTPResponseInfo): HRESULT;
var
    iCnt : Integer;
    pElem        : TIngitElem;
    pStream      : TMemoryStream;
    iReqType     : TReqType;
begin
  if not Enabled then begin
    result := E_NO_DLL_INIT;
    exit;
  end;
    // Извлечение свободного элемента
    Result := E_PM_NO_FREE_ELEM;
    iCnt := I_MAX_AVAILIBLE div I_STEP;
    while((Result = E_PM_NO_FREE_ELEM) and (iCnt > 0)) do
    begin
        Result := pPoole.LockElement(pElem);
        Sleep(I_STEP);
        Dec(iCnt);
    end;
    if((Result <> S_OK) or (not Assigned(pElem))) then
    begin
        if(Result <> E_PM_NO_FREE_ELEM) then pPoole.AddDataToLogTS(S_NOT_GETELEM, Result);
        Exit;
    end;
    try
        // Вызов функции обработки
        iReqType := GetReqTypeByStr(_pReq.Document);
        pStream := nil;
        case iReqType of
            rtNone : Result := E_NO_SUCH_CODE;
            rtTile : Result := ProcessRender(pElem, _pReq, pStream);
            rtRoute : Result := ProcessRoute(pElem,  _pReq, pStream);
            rtAdr : Result := ProcessAddr(pElem,   _pReq, pStream);
            rtLen : Result := ProcessLength(pElem, _pReq, pStream);
            rtCoord : Result := ProcessCoord(pElem,  _pReq, pStream);
            rtRoutelist : Result := GetRouteListResponse(pElem,  _pReq, pStream);
        end;
        // загрузка в ответ
       if(Assigned(pStream)) then
        begin
            _pResp.ContentType   := S_RESP_CONT_TYPE_TXT;
            pStream.Position := 0;
            _pResp.ContentStream := pStream;
            _pResp.ContentLength := _pResp.ContentStream.Size;
            _pResp.WriteHeader;
            _pResp.WriteContent;
        end;
    finally
        pPoole.UnLockElement(pElem);
    end;    
end;
// --------------------------------------------------------------------------

end.
