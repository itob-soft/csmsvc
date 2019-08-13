unit uLengthCounter;

interface
uses Windows, SysUtils, Classes, OleCtrls, GWXLib_TLB, SyncObjs, PNGImage,
     XmlIntf, XmlDoc, Math, Graphics, EPSG900913, ExtCtrls,
     uINGITConst, Controls, uProjConst;
type
     TLenCounter = class; // forward
     // Ёлемент
     TLenComp = class
        rLat0      : Double;
        rLat1      : Double;
        rLon0      : Double;
        rLon1      : Double;
        iLen       : Integer;
        iDuration  : Integer;
        iId        : Integer;
     end;

     // Ёлемент работы
     TLenCounterElem = class(TThread)
     private
         fpCurRoute : IGWRoute;
         fpManager  : TLenCounter;
     protected
         procedure Execute(); override;
     public
         function SetParent(_pPar : TLenCounter) : HRESULT;
         function SetRoot(_pRoute : IGWRoute) : HRESULT;
         constructor Create();
     end;

     // ѕроходчик по рассто€ни€м
     TLenCounter = class
     private
         fpElements : TStringList;
         fpThreads  : TList;
         fiIter     : Integer;
         fpGWC      : TGWControl;   // INGIT-компонент
         frOpt      : Double;
     public
         function AddElem(var _pElem : TLenComp) : HRESULT;
         function getElement(var _pElem : TLenComp) : HRESULT;
         function setElementOk(var _pElem : TLenComp) : HRESULT;
         function isFull() : Boolean;
         function ExtractElems() : TStringList;
         function ClearsElem() : HRESULT;
         function resume(_iCount : Integer) : HRESULT;
         constructor Create();
         destructor Destroy(); override;
         property pGWC      : TGWControl     read fpGWC      write fpGWC;
         property rOpt      : Double         read frOpt      write frOpt;
     end;

implementation

var
    pElemSection : TCriticalSection;

{ TLenCounterElem }

constructor TLenCounterElem.Create;
begin
    inherited Create(true);
    FreeOnTerminate := true;
end;
// --------------------------------------------------------------------

procedure TLenCounterElem.Execute;
var
    iPointType : Cardinal;
    pElem      : TLenComp;
    iRes       : HRESULT;
begin
    while(not Terminated) do
    begin
        iRes := fpManager.getElement(pElem);
        if((iRes <> S_OK) or (not Assigned(pElem))) then
        begin
            Sleep(100);
            continue;
        end;
        fpCurRoute.DeletePoints();
        iPointType := GWX_RoutePointStart;
        fpCurRoute.AddPoint(pElem.rLat0, pElem.rLon0, iPointType, '0', 0);
        iPointType := GWX_RoutePointFinish;
        fpCurRoute.AddPoint(pElem.rLat1, pElem.rLon1, iPointType, '1', 1);
        if(fpCurRoute.CalculateRoute() <> 0) then
        begin
            pElem.iDuration := fpCurRoute.RouteDuration;
            pElem.iLen      := fpCurRoute.RouteLength;
        end;
        fpManager.setElementOk(pElem);
        Sleep(1);
    end;
end;
// --------------------------------------------------------------------

function TLenCounterElem.SetParent(_pPar : TLenCounter): HRESULT;
begin
    Result := E_NO_PARAMS;
    if(not Assigned(_pPar)) then  Exit;
    fpManager := _pPar;
    Result := S_OK;
end;
// --------------------------------------------------------------------

function TLenCounterElem.SetRoot(_pRoute: IGWRoute): HRESULT;
begin
    Result := E_NO_PARAMS;
    if(not Assigned(_pRoute)) then Exit;
    fpCurRoute := _pRoute;
    Result := S_OK;
end;
// --------------------------------------------------------------------

{ TLenCounter }

function TLenCounter.AddElem(var _pElem : TLenComp): HRESULT;
begin
    Result := E_NO_PARAMS;
    if(not Assigned(_pElem)) then Exit;
    pElemSection.Enter();
    try
        fpElements.AddObject('todo', _pElem);
    finally
        pElemSection.Leave();
    end;
end;
// --------------------------------------------------------------------

constructor TLenCounter.Create;
begin
    fpElements := TStringList.Create();
    fpThreads := TList.Create();
    fiIter := -1;
    inherited;
end;
// --------------------------------------------------------------------

destructor TLenCounter.Destroy;
var
    i : Integer;
begin
    for i := 0 to pred(fpElements.Count) do
        fpElements.Objects[i].Free();
    for i := 0 to pred(fpThreads.Count) do
        TLenCounterElem(fpThreads.Items[i]).Terminate;
    FreeAndNil(fpElements);
    FreeAndNil(fpThreads);
    inherited;
end;
// --------------------------------------------------------------------

function TLenCounter.ExtractElems() : TStringList;
begin
    Result := nil;
    if(not isFull()) then Exit;
    Result := TStringList.Create();
    Result.AddStrings(fpElements);
end;
// --------------------------------------------------------------------

function TLenCounter.ClearsElem() : HRESULT;
var
    i : Integer;
begin
    for i := 0 to pred(fpElements.Count) do
        fpElements.Objects[i].Free();
    fpElements.Clear;
    fiIter := -1;
    Result := S_OK;
end;
// --------------------------------------------------------------------

function TLenCounter.getElement(var _pElem : TLenComp): HRESULT;
begin
    pElemSection.Enter();
    try
        Result := S_OK;
        _pElem := nil;
        if(fiIter >= pred(fpElements.Count)) then Exit;
        Inc(fiIter);
        _pElem := TLenComp(fpElements.Objects[fiIter]);
    finally
        pElemSection.Leave();
    end;
end;
// --------------------------------------------------------------------

function TLenCounter.isFull() : Boolean;
var
    i : Integer;
begin
    pElemSection.Enter();
    try
        Result := true;
        for i := 0 to pred(fpElements.Count) do
            Result := Result and (fpElements.Strings[i] = '');
    finally
        pElemSection.Leave();
    end;
end;
// --------------------------------------------------------------------

function TLenCounter.resume(_iCount : Integer): HRESULT;
var
    i      : Integer;
    pElem  : TLenCounterElem;
    pRoute : IGWRoute;
begin
    // ”же работают
    Result := S_OK;
    if(fpThreads.Count <> 0)  then Exit;
    for i := 0 to pred(_iCount) do
    begin
        pElem  := TLenCounterElem.Create();
        pElem.fpManager := Self;
        pRoute := fpGWC.CreateGWRoute('');
        pRoute.OptimizeTimeRatio := frOpt;
        pElem.fpCurRoute := pRoute;
        fpThreads.Add(pElem);
    end;
    for i := 0 to pred(fpThreads.Count) do
        TLenCounterElem(fpThreads.Items[i]).Resume;
    Result := S_OK;
end;
// --------------------------------------------------------------------

function TLenCounter.setElementOk(var _pElem: TLenComp): HRESULT;
var
    iIndex : Integer;
begin
    pElemSection.Enter();
    try
        Result := S_OK;
        iIndex := fpElements.IndexOfObject(_pElem);
        if(iIndex < 0) then Exit;
        fpElements.Strings[iIndex] := '';
    finally
        pElemSection.Leave();
    end;
end;
// --------------------------------------------------------------------

Initialization
    pElemSection := TCriticalSection.Create();
end.
