unit uINGITPoole;

interface
uses
    ActiveX, Windows, SysUtils, Classes, OleCtrls, GWXLib_TLB, PNGImage,
    XmlIntf, XmlDoc, Math, Graphics, EPSG900913, ExtCtrls, System.SyncObjs,
    uINGITConst, Controls, uLengthCounter, StrUtils, Variants, uProjConst,
    uGlobalUtils, frmIngit, Contnrs;
type
    TINGITPoole = class;
    // Элемент позволяющий содержать в себе INGIT - компонент
    TINGITElem = class
    private
         fiRouteCount  : Integer;
         fiPrevZ       : Integer;
         fsMap         : string;
         fpCurRoute    : IGWRoute;
         pCurForm      : TfrIngit;// Форма на которой находится INGIT-компонент для получения данных
         fpGWC         : TGWControl;   // INGIT-компонент
         fpPoole       : TINGITPoole;
         pLenCnt       : TLenCounter;
         procedure BitmapFileToPNG(const Source, Dest: String);
    public
      function  RenderTile(_iZ, _iX, _iY : Integer; var _pImg : TPNGImage) : HRESULT;
      function  GetAddress(_rLat, _rLon : Double; var _sAddr : string) : HRESULT;
      function  GetCoord(const _sAddr : string; var _rLat, _rLon : Double) : HRESULT;
      function  GetLength(const pXMLIn : IXMLDocument; var _pXMLRes : IXMLDocument) : HRESULT;
      function  GetRoute(_rRouteRatio : Double;_arPointLat, _arPointsLon : array of Double;
        var _pStream : TMemoryStream; const _FormatOut : string = S_TYPE_OUT_XML) : HRESULT;
      function  GetRouteList(_pPointList : TObjectList; var _pStream : TMemoryStream) : HRESULT;
      function  Init(const sMapPath  : string; _pPanel : TfrIngit; _iRouteCount : Integer) : HRESULT;
      constructor Create();
      destructor Destroy(); override;
      property pPoole    : TINGITPoole    read fpPoole     write fpPoole;
    end;

    // Пул элементов INGIT (TINGITElem)
    TINGITPoole = class
    private
        fiLockCount    : Integer; // Кол-во занятых сейчас
        fpElemList     : TList;  // Список элементов
        fpElemListFree : TList;  // Список флагов - занят/незанят
        function GetCount() : Integer;
        function GetCountLock() : Integer;
        function GetCountFree() : Integer;
        function GetErrorDescr(_iCode : Integer) : string;
    public
        function Init(_iElemCount : Integer;
          const _sMapPath : string;
          _iRouteCount : Integer) : HRESULT;
        function LockElement(var _pElem : TINGITElem) : HRESULT;
        function UnLockElement(_pElem : TINGITElem) : HRESULT;
        function AddDataToLogTS(const _sString : string; const _iCode : Integer; const _sError : string = '') : Boolean;
        constructor Create();
        destructor Destroy(); override;
        property iCount     : Integer    read GetCount;
        property iCountLock : Integer    read GetCountLock;
        property iCountFree : Integer    read GetCountFree;
    end;

    TNasPunkt  = class
        fsName  : string;
        frLat   : Double;
        frLon   : Double;
        frLat1  : Double;
        frLon1  : Double;
        frLat2  : Double;
        frLon2  : Double;
        fiLen   : Integer;
        constructor Create();
    end;

implementation

uses itob_ext_functions, superxmlparser, superobject, uAdds, uRotesUtils;

var
    pElemSection  : TCriticalSection;
    pElemSection2 : TCriticalSection;
    pElemSection3 : TCriticalSection;

{ TINGITElem }


constructor TINGITElem.Create;
begin
    inherited;
    fpCurRoute := nil;
    fiPrevZ    := -1;
    pLenCnt    := nil;
end;
// ---------------------------------------------------------------------------

destructor TINGITElem.Destroy;
begin
    // Освобождение
    pCurForm.Close();
    if(Assigned(pLenCnt)) then FreeAndNil(pLenCnt);
    inherited;
end;
// ---------------------------------------------------------------------------

function TINGITElem.GetAddress(_rLat, _rLon: Double; var _sAddr: string): HRESULT;
var
    rLat, rLon             : Double;
    iRes, iRes2            : Integer;
    arTemp                 : Variant;
    pPunkt                 : TNasPunkt;
    i, iLen, k             : Integer;
    pPunkts                : TList;
    rNativeScale           : Double;
    iLenSq                 : Integer;
    rDelta                 : Double;
    sObjName               : string;
    pGWCTable, pTable2     : IGWTable;
    pSetting               : TFormatSettings;
    rCurLat, rCurLon       : Double;
    rDelLat, rDelLon       : Double;
const
    I_LEN_SCALE            = 15000;
    I_SQ_LEN               = 5000;
    I_DELTA_CONST          = 103000;
    S_F_LAT                = 'First lat';
    S_F_LON                = 'First lon';
    S_SOUTH_SIDE           = 'South side';
    S_WEST_SIDE            = 'West side';
    S_NORTH_SIDE           = 'North side';
    S_EAST_SIDE            = 'East side';
    S_NAME_1               = '09 - Собственное название';
    S_NAME_2               = 'AR - Региональная принадлежность';
    S_NAME_3               = 'Имя (номер) объекта, текст';
begin
		Result := E_NO_INGIT_COMP;
    if(not Assigned(fpGWC)) then Exit;
//    _sAddr := fpGWC.FindNearestAddress(_rlat, _rLon);
//    Result := S_OK;
// >> new 05.05.12
	try

			_sAddr := fpGWC.FindNearestAddress(_rlat, _rLon);
		// Проверим, насколько близко находится найденный адрес от точки
		rLat := 0;
		rLon := 0;
		arTemp := VarArrayCreate([0, 3], varDouble);

		if(fpGWC.SearchAddress(_sAddr, rLat, rLon) = 0) then
				_sAddr := ''
		else begin
				 arTemp[0] := _rLat;
				 arTemp[1] := _rLon;
				 arTemp[2] := rLat;
				 arTemp[3] := rLon;
				 if(fpGWC.getMeasure(arTemp) > I_MAX_LEN_TO_ADDR) then _sAddr := '';
		end;
		Result := S_OK;
		if(_sAddr <> '') then Exit;
		pSetting.DecimalSeparator := S_SYM_POINT;
		rNativeScale :=  fpGWC.CurScale;
		pPunkts := TList.Create();
		try
				// попробуем найти через поиск объектов на карте
				fpGWC.CurScale := I_LEN_SCALE;
				for i := 1 to 10 do
				begin
						iLenSq := i * I_SQ_LEN;
						rDelta := (iLenSq/ 2) / I_DELTA_CONST;
						pGWCTable := fpGWC.GetInfoRect((_rLat - rDelta), (_rLon - rDelta), (_rLat + rDelta), (_rLon + rDelta));
						if(pGWCTable.moveFirst >= 0) then
						begin
								iRes := 0;
								while(iRes >= 0) do
								begin
										sObjName := pGWCTable.getValue(2);
										if(Copy(sObjName, 1, 2) = 'CT') then
										begin
												pPunkt := TNasPunkt.Create();
												pPunkts.Add(pPunkt);
												pTable2 := fpGWC.getObjectTable(pGWCTable.getValue(0));
												if(pTable2.moveFirst >= 0) then
												begin
														iRes2 := 0;
														while(iRes2 >= 0) do
														begin
																sObjName := pTable2.getValue(0);
																if(PosEx(S_F_LAT, pTable2.getValue(0)) > 0) then pPunkt.frLat       := StrToFloat(pTable2.getValue(1), pSetting);
																if(PosEx(S_F_LON, pTable2.getValue(0)) > 0) then pPunkt.frLon       := StrToFloat(pTable2.getValue(1), pSetting);
																if(PosEx(S_SOUTH_SIDE, pTable2.getValue(0)) > 0) then pPunkt.frLat1 := StrToFloat(pTable2.getValue(1), pSetting);
																if(PosEx(S_WEST_SIDE, pTable2.getValue(0)) > 0) then pPunkt.frLon1  := StrToFloat(pTable2.getValue(1), pSetting);
																if(PosEx(S_NORTH_SIDE, pTable2.getValue(0)) > 0) then pPunkt.frLat2 := StrToFloat(pTable2.getValue(1), pSetting);
																if(PosEx(S_EAST_SIDE, pTable2.getValue(0)) > 0) then pPunkt.frLon2  := StrToFloat(pTable2.getValue(1), pSetting);
																if(PosEx(S_NAME_2, pTable2.getValue(0)) > 0) then
																		 pPunkt.fsName     :=pTable2.getValue(1);
																if(PosEx(S_NAME_3, pTable2.getValue(0)) > 0) then
																		 pPunkt.fsName     := pTable2.getValue(1);
																if(PosEx(S_NAME_1, pTable2.getValue(0)) > 0) then
																		 pPunkt.fsName     := pTable2.getValue(1);
																iRes2 := pTable2.moveNext();
														end;
												end;
												if((Min(pPunkt.frLat1, pPunkt.frLat2) <= _rLat) and (Max(pPunkt.frLat1, pPunkt.frLat2) >=_rLat) and
													 (Min(pPunkt.frLon1, pPunkt.frLon2) <= _rLon) and (Max(pPunkt.frLon1, pPunkt.frLon2) >= _rLon)) then
												begin
														// Находиться как раз в пределах
														pPunkt.frLat := _rLat;
														pPunkt.frLon := _rLon;
												end else begin
														rCurLat      := pPunkt.frLat;
														rCurLon      := pPunkt.frLon;
														rDelLat      := abs(rCurLat - _rLat);
														rDelLon      := abs(rCurLon - _rLon);
														if(Abs(_rLat - pPunkt.frLat1) < rDelLat) then
														begin
																rDelLat := Abs(_rLat - pPunkt.frLat1);
																rCurLat := pPunkt.frLat1;
														end;
														if(Abs(_rLon - pPunkt.frLon1) < rDelLon) then
														begin
																rDelLon := Abs(_rLon - pPunkt.frLon1);
																rCurLon := pPunkt.frLon1;
														end;
														if(Abs(_rLat - pPunkt.frLat2) < rDelLat) then rCurLat := pPunkt.frLat2;
														if(Abs(_rLon - pPunkt.frLon2) < rDelLon) then rCurLon := pPunkt.frLon2;
														pPunkt.frLat := rCurLat;
														pPunkt.frLon := rCurLon;
												end;
												if((pPunkt.frLat > 0) and (pPunkt.frLon > 0))  then
												begin
														arTemp[0] := _rLat;
														arTemp[1] := _rLon;
														arTemp[2] := pPunkt.frLat;
														arTemp[3] := pPunkt.frLon;
														pPunkt.fiLen := fpGWC.getMeasure(arTemp);
												end else begin
														pPunkts.Remove(pPunkt);
														FreeAndNil(pPunkt);
												end;
										end;
										iRes := pGWCTable.moveNext();
								end;
						end;
						// Проход по списку и указание близжайшего
						if(pPunkts.Count <> 0) then
						begin
								iLen   := TNasPunkt(pPunkts.Items[0]).fiLen;
								_sAddr := TNasPunkt(pPunkts.Items[0]).fsName;
								for k := 0 to pred(pPunkts.Count) do
										if(TNasPunkt(pPunkts.Items[k]).fiLen < iLen) then
										begin
												iLen := TNasPunkt(pPunkts.Items[k]).fiLen;
												_sAddr := TNasPunkt(pPunkts.Items[k]).fsName;
												if(iLen > 1000) then _sAddr := FloatToStr(iLen / 1000) + ' км от ' + _sAddr;
										end;
								break;
						end;
				end;
		finally
				for i := 0 to pred(pPunkts.Count) do TNasPunkt(pPunkts.Items[i]).Free();
				FreeAndNil(pPunkts);
				fpGWC.CurScale := rNativeScale;
		end;
	except
		on E : Exception do
				begin
						Result := E_INGIT_COM_ERROR;
						_sAddr := 'TINGITElem.GetAddress. '+E.Message;
						fpPoole.AddDataToLogTS('TINGITElem.GetAddress. '+E.Message,Result);
				end;
	end;
// << new 05.05.12
end;
// ---------------------------------------------------------------------------

function TINGITElem.GetCoord(const _sAddr: string; var _rLat, _rLon: Double): HRESULT;
begin
		Result := E_NO_INGIT_COMP;
		if(not Assigned(fpGWC)) then Exit;
	try
		Result := E_NO_ADDRES_FOUND;
		if(fpGWC.SearchAddress(_sAddr, _rLat, _rLon) <> 0) then Result := S_OK;
	except
		on E : Exception do
				begin
						Result := E_INGIT_COM_ERROR;
						fpPoole.AddDataToLogTS('TINGITElem.GetCoord. '+E.Message,Result);
				end;
	end;
end;
// ---------------------------------------------------------------------------

function TINGITElem.GetLength(const pXMLIn : IXMLDocument; var _pXMLRes : IXMLDocument): HRESULT;
var
    i                           : Integer;
    pRoot, pNode, pRNode        : IXMLNode;
    pFSetting                   : TFormatSettings;
    pElem                       : TLenComp;
    pRes                        : TStringList;
    rRatio                      : Double;
begin
    try
        Result := S_OK;
        if(not Assigned(pXMLIn)) then Exit;
        // Создание выходного XML
        _pXMLRes := TXMLDocument.Create(nil);
				_pXMLRes.Active := true;
				_pXMLRes.Encoding := 'UTF-8';
				_pXMLRes.Version := '1.0';
				pRNode := _pXMLRes.AddChild('Lengths');
        // Разбор входящего XML
        GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, pFSetting);
        pFSetting.DecimalSeparator := S_SYM_POINT;

        pRoot := pXMLIn.DocumentElement;
        if(not pRoot.HasChildNodes) then Exit;
        if(not pRoot.HasAttribute(S_OPT_NODE)) then Exit;
        if(not TryStrToFloat(pRoot.Attributes[S_OPT_NODE],  rRatio, pFSetting))then Exit;
        if(not Assigned(pLenCnt)) then pLenCnt := TLenCounter.Create();

        pLenCnt.rOpt := rRatio;
        for i := 0 to pred(pRoot.ChildNodes.Count) do
        begin
            pNode       := pRoot.ChildNodes[i];
            pElem       := TLenComp.Create();
            pElem.rLat0 := StrToFLoat(pNode.ChildNodes.FindNode(S_ROUTE_POINT_LAT0).NodeValue, pFSetting);
            pElem.rLat1 := StrToFLoat(pNode.ChildNodes.FindNode(S_ROUTE_POINT_LAT1).NodeValue, pFSetting);
            pElem.rLon0 := StrToFLoat(pNode.ChildNodes.FindNode(S_ROUTE_POINT_LON0).NodeValue, pFSetting);
            pElem.rLon1 := StrToFLoat(pNode.ChildNodes.FindNode(S_ROUTE_POINT_LON1).NodeValue, pFSetting);
            pElem.iId   := StrToInt(pNode.ChildNodes.FindNode(S_ROUTE_POINT_ID).NodeValue);
            pLenCnt.AddElem(pElem);
        end;
        pRes := nil;
        try
             pLenCnt.pGWC := fpGWC;
             pLenCnt.resume(fiRouteCount);
             while(not pLenCnt.isFull) do Sleep(100);
             pRes := pLenCnt.ExtractElems();
             for i := 0 to pred(pRes.Count) do
             begin
                 pElem   := TLenComp(pRes.Objects[i]);
                 pNode   := pRNode.AddChild(S_LENGTH_NODE);
                 pNode.Attributes[S_LENGTH_ID] := IntToStr(pElem.iId);
                 pNode.Attributes[S_LENGTH_LEN] := IntToStr(pElem.iLen);
                 pNode.Attributes[S_LENGTH_DUR] := IntToStr(pElem.iDuration);
             end;
             Result := S_OK;
        finally
            pLenCnt.ClearsElem();
            FreeAndNil(pRes);
        end;
		except
			on E : Exception do
				begin
						Result := E_GEN_LENGTH_GET;
						// Предполгаем не безостновательно что _pXMLRes будет не пустой :)
						_pXMLRes.AddChild('Exception').NodeValue := E.Message;
						fpPoole.AddDataToLogTS('TINGITElem.GetLength. '+E.Message,Result);
				end;
	end;
end;
// ---------------------------------------------------------------------------

function TINGITElem.GetRoute(_rRouteRatio : Double; _arPointLat, _arPointsLon : array of Double;
  var _pStream : TMemoryStream; const _FormatOut : string) : HRESULT;
var
    pGwTable, pPathTable                      : IGWTable;
    p, p2                                     : Integer;
    pFormatSettings                           : TFormatSettings;
    iPointType                                : Cardinal;
    i                                         : Integer;
    pXML                                      : IXMLDocument;
    pNode, pCurNode, pCurNode2, pCurNode3     : IXMLNode;

    locJson : ISuperObject;
begin
	CoInitialize(nil);
	try
		_pStream := TMemoryStream.Create();
		// Проверка входных параметров
		Result := E_NO_PARAMS;
		if(Length(_arPointLat) <> Length(_arPointsLon)) then Exit;
		Result := E_NO_INGIT_COMP;
		if(not Assigned(fpGWC)) then Exit;
		Result := E_POINT_HAVE_TO_MORE_2;
//    if(_pPoints.Count < 2) then Exit;
		if(Length(_arPointLat) < 2) then Exit;
		Result := E_NO_ROUTE_CREATE;
		// Создание пути
		if(not Assigned(fpCurRoute)) then fpCurRoute := fpGWC.CreateGWRoute('');
		if(not Assigned(fpCurRoute)) then Exit;
		fpCurRoute.DeletePoints();
		iPointType := GWX_RoutePointStart;
		// Сборка точек
		for i := 0 to pred(Length(_arPointsLon)) do
		begin
//        pItPoint := TItineraryPoint(_pPoints.Items[i]);
//        fpCurRoute.AddPoint(pItPoint.rLatitude,pItPoint.rLongitude, iPointType, IntToStr(i), i);
				 fpCurRoute.AddPoint(_arPointLat[i], _arPointsLon[i], iPointType, IntToStr(i), i);

				iPointType := GWX_RoutePointIntermediate;
				if(i = pred(pred(Length(_arPointsLon)))) then iPointType := GWX_RoutePointFinish;
		end;
		Result := E_CANT_MAKE_ROUTE;
		if(fpCurRoute.CalculateRoute() = 0) then Exit;
		// Преобразование в xml
		pFormatSettings.DecimalSeparator := '.';
		pNode := InitXML(S_ROUTE_ROOT, pXML);
		AddSNode(pNode, S_ROUTE_LENGTH,      IntToStr(fpCurRoute.RouteLength));
		AddSNode(pNode, S_ROUTE_DURAT,       IntToStr(fpCurRoute.RouteDuration));
		AddSNode(pNode, S_ROUTE_POINTS_CNT,  IntToStr(fpCurRoute.RoutePointsCount));

		pGwTable := fpCurRoute.GetRoute;
		p := pGwTable.moveFirst;
		while(p >= 0) do
		begin
				pCurNode := AddSNode(pNode, S_ROUTE_POINTS_ROOT, '');
				AddSNode(pCurNode, S_ROUTE_POINT_LAT, pGwTable.getText(1));
				AddSNode(pCurNode, S_ROUTE_POINT_LON, pGwTable.getText(2));
				AddSNode(pCurNode, S_ROUTE_POINT_INDEX, pGwTable.getText(3));
				AddSNode(pCurNode, S_ROUTE_POINT_LENGTH, FloatToStr(pGwTable.getValue(5) / 10, pFormatSettings));
				AddSNode(pCurNode, S_ROUTE_POINT_DURAT, pGwTable.getText(6));

				pCurNode2 := AddSNode(pCurNode, S_ROUTE_POINT_PATH, '');
				pPathTable := IDispatch(pGwTable.getValue(7)) as IGWTable;
				p2 := pPathTable.moveFirst();
				while(p2 >= 0) do
				begin
						pCurNode3 := AddSNode(pCurNode2, S_PATH_POINT, '');
						AddSNode(pCurNode3, S_PATH_POINT_INDEX, IntToStr(pPathTable.getIndex));
						AddSNode(pCurNode3, S_PATH_POINT_LAT,   pPathTable.getText(0));
						AddSNode(pCurNode3, S_PATH_POINT_LON,   pPathTable.getText(1));
						AddSNode(pCurNode3, S_PATH_POINT_NAME,  pPathTable.getText(2));
						p2 := pPathTable.moveNext;
				end;
				p := pGwTable.MoveNext;
		end;
	except
		on E : Exception do
				begin
						Result := E_INGIT_COM_ERROR;
						// Предполгаем не безостновательно что _pXMLRes будет не пустой :)
						pXML.AddChild('Exception').NodeValue := E.Message;
						fpPoole.AddDataToLogTS('TINGITElem.GetRoute. '+E.Message,Result);
				end;
	end;
		// Освободит DOM парсер
		pXML.SaveToStream(_pStream);
		if AnsiSameText(_FormatOut,'json') then
		begin
			locJson := XMLParseStream(_pStream,true);
			_pStream.Clear;
			locJson.SaveTo(_pStream);
			locJson := nil;
		end;
		CoUninitialize;
end;

function TINGITElem.GetRouteList(_pPointList: TObjectList;
	var _pStream: TMemoryStream): HRESULT;
var
		pGwTable : IGWTable;
		i                                      : Integer;
		pXML                                      : IXMLDocument;
		pNode, pCurNode           : IXMLNode;
    pFormatSettings : TFormatSettings ;
begin
  CoInitialize(nil);
    _pStream := TMemoryStream.Create();
    // Проверка входных параметров
    Result := E_NO_PARAMS;
    if _pPointList.Count = 0 then Exit;
    Result := E_NO_INGIT_COMP;
    if(not Assigned(fpGWC)) then Exit;
		Result := E_NO_ROUTE_CREATE;
	try
		// Создание пути
		if(not Assigned(fpCurRoute)) then fpCurRoute := fpGWC.CreateGWRoute('');
		if(not Assigned(fpCurRoute)) then Exit;

		pNode := InitXML(S_ROUTES_ROOT, pXML);

		for i := 0 to _pPointList.Count-1 do
		begin
			fpCurRoute.DeletePoints();
			fpCurRoute.AddPoint(
				TRoteInfo(_pPointList[i]).Lat1, TRoteInfo(_pPointList[i]).Lon1,
				GWX_RoutePointStart, IntToStr(i), i);
			fpCurRoute.AddPoint(
				TRoteInfo(_pPointList[i]).Lat2, TRoteInfo(_pPointList[i]).Lon2,
				GWX_RoutePointFinish, IntToStr(i), i);
			Result := E_CANT_MAKE_ROUTE;
			if(fpCurRoute.CalculateRoute() = 0) then Continue;

			pCurNode := AddSNode(pNode, S_ROUTE_ROOT, '');
			AddSNode(pCurNode, S_ROUTE_POINT_ID,    inttostr(TRoteInfo(_pPointList[i]).ID));


			//AddSNode(pCurNode, S_ROUTE_POINT_LENGTH, IntToStr(fpCurRoute.RouteLength));
			//AddSNode(pCurNode, S_ROUTE_POINT_DURAT,  IntToStr(fpCurRoute.RouteDuration));

			pGwTable := fpCurRoute.GetRoute;
			pGwTable.moveFirst;
			pFormatSettings.DecimalSeparator := '.';
			AddSNode(pCurNode, S_ROUTE_POINT_LENGTH, FloatToStr(pGwTable.getValue(5) / 10, pFormatSettings));
			AddSNode(pCurNode, S_ROUTE_POINT_DURAT, pGwTable.getText(6));

		end;
		// Освободит DOM парсер
	except
			on E : Exception do
				begin
						Result := E_INGIT_COM_ERROR;
						// Предполгаем не безостновательно что _pXMLRes будет не пустой :)
						pXML.AddChild('Exception').NodeValue := E.Message;
						fpPoole.AddDataToLogTS('TINGITElem.GetRouteList. '+E.Message,Result);
				end;
  end;
		pXML.SaveToStream(_pStream);
	CoUninitialize;
end;

// ---------------------------------------------------------------------------

function TINGITElem.Init(const sMapPath : string; _pPanel : TfrIngit; _iRouteCount : Integer) : HRESULT;
var
	i : integer;
	lst : TStringList;
	locRs : HRESULT;

		procedure locLoadChart();
		var
			fileList 		: TStrings;
			cnt 				  : integer;
		begin
			fileList := TStringList.Create;
			try
				if 		SameText(ExtractFileExt(sMapPath),S_MAP_LST_EXT) then begin
					if AnsiPos('\',sMapPath) = 0 then
						fsMap := ExtractFilePath(ParamStr(0))+sMapPath;
					if not FileExists(fsMap) then begin
						raise Exception.Create('Ошибка доступа к файлу '+fsMap)
					end;
					fileList.LoadFromFile(fsMap);
				end else fileList.Add(sMapPath);
				cnt := 0;
				while cnt < filelist.Count do begin
					Result := fpGWC.AddMap(fileList[cnt], '');
					inc(cnt);
				end;
			finally
				fileList.Free;
      end;
		end;

begin
	try
	fpGWC          := _pPanel.GWControl;
	fiRouteCount   :=  _iRouteCount;
	Result := S_OK;

	if RightStr(sMapPath,1) = S_BACK_SLASH then begin
		lst := getDirFilesList(sMapPath,'*.chart',true);
		try
			i := 0;
			while i < lst.Count do begin
				locRs := fpGWC.AddMap(lst[i], '');
				if Result = S_OK then
					Result := locRs;
				inc(i);
			end;

		finally
			lst.Free;
		end;
	end else begin
		locLoadChart();
  end;

	pCurForm       := _pPanel;
	fsMap          := sMapPath;
	except
			on E : Exception do
				begin
						Result := E_INGIT_COM_ERROR;
						fpPoole.AddDataToLogTS('TINGITElem.Init. '+E.Message,Result);
				end;
  end;
end;
// ------------------------------------------------------------------------------

procedure TINGITElem.BitmapFileToPNG(const Source, Dest: String);
var
  pBitmap, pTempMap  : TBitmap;
  pPNGBM   : TPNGImage;
begin
  pBitmap   := TBitmap.Create();
  pTempMap  := TBitmap.Create();
  pPNGBM := TPNGImage.Create;
  { In case something goes wrong, free booth Bitmap and PNG }
  try
    pBitmap.LoadFromFile(Source);
    pTempMap.Width := 256;
    pTempMap.Height := 256;

    pTempMap.Canvas.CopyRect(Rect(0, 0, 256, 256), pBitmap.Canvas, Rect(256 , 256, 256 * 2, 256 * 2));
    pPNGBM.Assign(pTempMap); // Convert data into png
    pPNGBM.SaveToFile(Dest);
  finally
    FreeAndNil(pBitmap);
    FreeAndNil(pTempMap);
    FreeAndNil(pPNGBM);
  end
end;
// ------------------------------------------------------------------------------

function TINGITElem.RenderTile(_iZ, _iX, _iY : Integer; var _pImg : TPNGImage): HRESULT;
var
    PixelX0, PixelY0                   : Integer;
    GetLat0, GetLon0, GetLat1, GetLon1 : Double;
    Guid                               : TGUID;
    ImgFileName                        : string;
    sPath, sFileName                   : string;
    iCnt                               : Integer;
begin
   // Проверка наличия тайла
   sPath := GetInstancePath() + S_TILES_FOLDER + IntToStr(_iZ) + S_BACK_SLASH + IntToStr(_iX) + S_BACK_SLASH;
   sFileName := sPath + IntToStr(_iY) + S_PNG_EXT;
   if(ForceDirectories(sPath)) then
      if(FileExists(sFileName)) then
      begin
          _pImg := TPNGImage.Create();
          _pImg.LoadFromFile(sFileName);
          Result := S_OK;
          Exit;
      end;
   // Тайла нет - рассчитываем
   PixelX0 := _iX * 256;
   PixelY0 := _iY * 256;
   XYToLonLat(PixelX0 - 256 ,        PixelY0 - 256,     _iZ, GetLat0, GetLon0);
   XYToLonLat(PixelX0 + 256 * 2,     PixelY0 + 256 * 2, _iZ, GetLat1, GetLon1);
   CreateGUID(Guid);
   ImgFileName := sPath + GUIDToString(Guid) + S_PNG_EXT;
   iCnt := 0;
   // Создание старым способом
   try
       while(true) do
       try
           pElemSection2.Enter();
           try
               if(fiPrevZ <> _iZ) then
               begin
                   fpGWC.CurScale := Ceil(225943577 / power(2, _iZ - 1));
                   fiPrevZ := _iZ;
               end;
               fpGWC.getBitmap(ImgFileName + S_BMP_EXT, GetLat0, GetLon0, GetLat1, GetLon1, 256 * 3, 256 * 3, 10);
           finally
               pElemSection2.Leave();
           end;
           BitmapFileToPNG(ImgFileName + S_BMP_EXT, sFileName);
           break;
           Sleep(100);
           Inc(iCnt);
       except
           on E : Exception do
           begin
               if(iCnt > 10) then break;
               Result := E_NO_TILE_INGIT;
               fpPoole.AddDataToLogTS(Format(S_GET_TILE, [FloatToStr(GetLat0), FloatToStr(GetLon0),
                                                          FloatToStr(GetLat1), FloatToStr(GetLon1),
                                                          IntToStr(_iX), IntToStr(_iY), IntToStr(_iZ),
                                                          ImgFileName]), Result, E.Message);
           end;
       end;
   finally
       DeleteFile(ImgFileName + S_BMP_EXT);
   end;
   _pImg := TPNGImage.Create();
   _pImg.LoadFromFile(sFileName);
   Result := S_OK;
end;
// ---------------------------------------------------------------------------

{ TINGITPoole }

constructor TINGITPoole.Create();
begin
    inherited;
    fpElemList     := TList.Create();
    fpElemListFree := TList.Create();
    AddDataToLogTS(S_CREATE_POOLE, S_OK);
end;
// ---------------------------------------------------------------------------

destructor TINGITPoole.Destroy();
var
    n : Integer;
begin
    for n := 0 to pred(fpElemList.Count) do begin
        TINGITElem(fpElemList.Items[n]).Free();
        // Yolkin +++
        CoUninitialize;
        // Yolkin ---
    end;
    FreeAndNil(fpElemList);
    FreeAndNil(fpElemListFree);
    AddDataToLogTS(S_DESTROY_POOLE, S_OK);
    inherited;
end;
// ---------------------------------------------------------------------------

function TINGITPoole.GetCount() : Integer;
begin
    pElemSection.Enter();
    try
        Result := fpElemList.Count;
    finally
        pElemSection.Leave();
    end;
end;
// ---------------------------------------------------------------------------

function TINGITPoole.GetCountFree() : Integer;
var
    n, iCount : Integer;
begin
    pElemSection.Enter();
    try
        iCount := 0;
        for n := 0 to pred(fpElemListFree.Count) do
            if(Integer(fpElemListFree.Items[n]) = 0) then Inc(iCount);
        Result := iCount;
    finally
        pElemSection.Leave();
    end;
end;
// ---------------------------------------------------------------------------

function TINGITPoole.GetCountLock() : Integer;
begin
    pElemSection.Enter();
    try
        Result := fiLockCount;
    finally
        pElemSection.Leave();
    end;
end;
// ----------------------------------------------------------------------

function TINGITPoole.GetErrorDescr(_iCode: Integer): string;
begin
    case _iCode of
       S_OK                   : Result := 'OK';
       E_POOLE_MAP_ERR        : Result := 'Общая ошибка инициализации карты';
       E_CANT_MAKE_ROUTE      : Result := 'Не получилось проложить маршрут';
       E_NO_ROUTE_CREATE      : Result := 'Не получилось создать объект маршрута';
       E_NO_INGIT_COMP        : Result := 'Не инициализирован компонент INGIT';
       E_POINT_HAVE_TO_MORE_2 : Result := 'В пути должно быть по меньшей мере 2 точки';
       E_NO_PARAMS            : Result := 'Не инициализированны выходщие данные';
       E_NO_ADDRES_FOUND      : Result := 'Адрес не найден';
       E_NO_TILE_INGIT        : Result := 'Не удалось извлечь тайл';
    else Result := IntToStr(_iCode);
    end;
end;
// ----------------------------------------------------------------------

function TINGITPoole.Init(_iElemCount : Integer; const _sMapPath : string; _iRouteCount : Integer): HRESULT;
var
    n       : Integer;
    pElem   : TINGITElem;
    pForm   : TfrIngit;
begin
    Result := E_POOLE_ALREADY_INIT;
    if(fpElemList.Count <> 0) then Exit;
    Result := S_OK;
    AddDataToLogTS(Format(S_INIT_POOLE, [IntToStr(_iElemCount), _sMapPath]), S_OK);

    pElemSection.Enter();
    try
        try
            for n := 0 to pred(_iElemCount) do
            begin
                //AddDataToLogTS('start '+Format(S_LOAD_MAP, [IntToStr(n+1), IntToStr(_iElemCount), _sMapPath]), S_OK);
                pElem := TINGITElem.Create();
                fpElemList.Add(pElem);
                // Отметка о том, что он свободен
                fpElemListFree.Add(Pointer(0));
                // Yolkin +++
                CoInitialize(nil);
                // Yolkin ---
                //AddDataToLogTS('start 2 '+Format(S_LOAD_MAP, [IntToStr(n+1), IntToStr(_iElemCount), _sMapPath]), S_OK);
                pForm := TfrIngit.Create(nil);
                pForm.Init();
                pForm.Show();
                pElem.pPoole := Self;
                Result := pElem.Init(_sMapPath, pForm, _iRouteCount);
                if(Result <> S_OK) then
                begin
                   Result := E_POOLE_MAP_ERR;
                   AddDataToLogTS(Format(S_LOAD_MAP, [IntToStr(n+1), IntToStr(_iElemCount), _sMapPath]), Result);
                end;
            end;
            fiLockCount := 0;
        except
            on E : Exception do
                AddDataToLogTS(Format(S_LOAD_MAP, ['-', IntToStr(_iElemCount), _sMapPath]), Result, E.Message);
        end;
    finally
        pElemSection.Leave();
    end;
end;
// ---------------------------------------------------------------------------

function TINGITPoole.LockElement(var _pElem : TINGITElem): HRESULT;
var
    n   : Integer;
begin
    _pElem := nil;
    Result := E_PM_NO_FREE_ELEM;
    pElemSection.Enter();
    try
        for n := 0 to pred(fpElemListFree.Count) do
            if(Integer(fpElemListFree.Items[n]) = 0) then
            begin
                _pElem := fpElemList.Items[n];
                fpElemListFree.Items[n] := Pointer(1);
                Result := S_OK;
                Exit;
            end;
    finally
        pElemSection.Leave();
    end;
end;
// ---------------------------------------------------------------------------

function TINGITPoole.UnLockElement(_pElem: TINGITElem): HRESULT;
var
    iIter : Integer;
begin
    Result := E_NO_PARAMS;
    if(not Assigned(_pElem)) then Exit;
    Result := E_LOCK_NO_ELEM;
    pElemSection.Enter();
    try
        iIter := fpElemList.IndexOf(_pElem);
        if((iIter >= 0) and (iIter < fpElemList.Count)) then
        begin
            Result := E_NO_LOCK_ELEM;
            if(Integer(fpElemListFree.Items[iIter]) = 0) then Exit;
            fpElemListFree.Items[iIter] := Pointer(0);
            Result := S_OK;
        end;
    finally
        pElemSection.Leave();
    end;
end;
// ---------------------------------------------------------------------------

function TINGITPoole.AddDataToLogTS(const _sString : string; const _iCode : Integer; const _sError : string = '') : Boolean;
var
    pLog    : TStringList;
    sData   : string;
    sErr    : string;
begin
    Result := true;
    pLog := TStringList.Create();
    pElemSection3.Enter();
    try
        try
            try
                pLog.LoadFromFile(GetInstancePath() + S_LOG_FILE_NAME);
            except
                pLog.Clear();
            end;
            if(_iCode = S_OK) then
                sData := Format(S_LOG_F_STR_S, [DateTimeToStr(Now()), _sString])
            else begin
                sErr  :=  GetErrorDescr(_iCode);
                if(sErr = '') then
                    sData := Format(S_LOG_F_STR, [DateTimeToStr(Now()), IntToStr(_iCode), _sString])
                else
                    sData := Format(S_LOG_F_STR_E, [DateTimeToStr(Now()), IntToStr(_iCode), sErr, _sString]);
            end;
            if(_sError <> '') then sData := sData + S_EXP_STR + _sError;
            pLog.Insert(0, sData);
            pLog.SaveToFile(GetInstancePath() + S_LOG_FILE_NAME);
        except
            Result := false;
        end;
    finally
        pElemSection3.Leave();
        FreeAndNil(pLog);
    end;
end;
// ----------------------------------------------------------------------

{ TNasPunkt }

constructor TNasPunkt.Create;
begin
    inherited;
    fsName  := '';
    frLat   := 0;
    frLon   := 0;
    frLat1  := 0;
    frLon1  := 0;
    frLat2  := 0;
    frLon2  := 0;
    fiLen   := 0;
end;
// ----------------------------------------------------------------------

Initialization
    pElemSection := TCriticalSection.Create();
    pElemSection2 := TCriticalSection.Create();
    pElemSection3 := TCriticalSection.Create();
end.
