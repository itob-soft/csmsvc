unit CityGuideControlLib_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 52393 $
// File generated on 15.02.2017 12:03:35 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\CgSdk8.150929\com\CityGuideControl.tlb (1)
// LIBID: {758B9B4B-4175-489D-B550-602C9E2EB658}
// LCID: 0
// Helpfile: C:\CgSdk8.150929\com\CityGuideControl.hlp 
// HelpString: CityGuideControl ActiveX Control module
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleCtrls, Vcl.OleServer, Winapi.ActiveX;
  


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  CityGuideControlLibMajorVersion = 1;
  CityGuideControlLibMinorVersion = 0;

  LIBID_CityGuideControlLib: TGUID = '{758B9B4B-4175-489D-B550-602C9E2EB658}';

  DIID__DCityGuideControl: TGUID = '{41438A04-16CC-42EE-8EFC-62512838D6C4}';
  DIID__DCityGuideControlEvents: TGUID = '{4E5A8A13-E04E-4965-8B58-609A609DA74B}';
  CLASS_CityGuideControl: TGUID = '{5515FAD2-996E-4576-95C6-91286C31C316}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _DCityGuideControl = dispinterface;
  _DCityGuideControlEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  CityGuideControl = _DCityGuideControl;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PDouble1 = ^Double; {*}
  PSmallint1 = ^Smallint; {*}


// *********************************************************************//
// DispIntf:  _DCityGuideControl
// Flags:     (4096) Dispatchable
// GUID:      {41438A04-16CC-42EE-8EFC-62512838D6C4}
// *********************************************************************//
  _DCityGuideControl = dispinterface
    ['{41438A04-16CC-42EE-8EFC-62512838D6C4}']
    procedure CenterGeoPoint(Lat: Double; Lon: Double); dispid 1;
    procedure CenterScreenPoint(X: Integer; Y: Integer); dispid 2;
    procedure SetScale(Scale: Double; X: Integer; Y: Integer); dispid 3;
    function GetScale: Double; dispid 4;
    function ScreenToGeo(X: Double; Y: Double; var Lat: Double; var Lon: Double): WordBool; dispid 5;
    function GeoToScreen(Lat: Double; Lon: Double; var X: Double; var Y: Double): WordBool; dispid 6;
    function InsertChart(const ChartPath: WideString): WordBool; dispid 7;
    function RemoveChart(const ChartPath: WideString): WordBool; dispid 8;
    function GetNumberOfCharts: LongWord; dispid 9;
    function GetChartInfo(Number: LongWord): IDispatch; dispid 10;
    function MakeRoute(LatFrom: Double; LonFrom: Double; LatTo: Double; LonTo: Double; 
                       RouteType: Integer): IDispatch; dispid 11;
    procedure SetRouteDrawMode(DrawMode: Integer); dispid 12;
    function GetCoordinateConverter: IDispatch; dispid 13;
    function GeoQuery(Lat: Double; Lon: Double): IDispatch; dispid 14;
    procedure DropHighlight; dispid 15;
    function GetContextSettings: IDispatch; dispid 16;
    function GetIRoute: IDispatch; dispid 17;
    procedure ShiftScreen(Dx: Integer; Dy: Integer); dispid 18;
    function GetIJams: IDispatch; dispid 19;
    procedure ShowGeoArea(N: Double; W: Double; S: Double; E: Double); dispid 20;
    function GetIChartsCatalog: IDispatch; dispid 21;
    procedure EnableMouseWheel(Enable: WordBool); dispid 22;
    procedure EnableLazyRedraw(Enable: WordBool); dispid 23;
    procedure ForceRedraw; dispid 24;
    procedure EnableDoubleBufferRedraw(Enable: WordBool); dispid 25;
    procedure SetMouseButtonAction(ButtonNumber: Integer; Action: Integer); dispid 26;
    function UserObjectContainer: IDispatch; dispid 27;
    function DrawToPictureFile(const FilePath: WideString): WordBool; dispid 28;
    function GetCityGuideUser: IDispatch; dispid 30;
    function GetAngle: Double; dispid 40;
    procedure SetAngle(AngleRad: Double); dispid 44;
  end;

// *********************************************************************//
// DispIntf:  _DCityGuideControlEvents
// Flags:     (4096) Dispatchable
// GUID:      {4E5A8A13-E04E-4965-8B58-609A609DA74B}
// *********************************************************************//
  _DCityGuideControlEvents = dispinterface
    ['{4E5A8A13-E04E-4965-8B58-609A609DA74B}']
    procedure Click; dispid -600;
    procedure DblClick; dispid -601;
    procedure MouseDown(Button: Smallint; Shift: Smallint; X: OLE_XPOS_PIXELS; Y: OLE_YPOS_PIXELS); dispid -605;
    procedure MouseUp(Button: Smallint; Shift: Smallint; X: OLE_XPOS_PIXELS; Y: OLE_YPOS_PIXELS); dispid -607;
    procedure MouseMove(Button: Smallint; Shift: Smallint; X: OLE_XPOS_PIXELS; Y: OLE_YPOS_PIXELS); dispid -606;
    procedure SelfDraw(hDc: OLE_HANDLE; Left: Integer; Top: Integer; Right: Integer; Bottom: Integer); dispid 1;
    procedure KeyDown(var KeyCode: Smallint; Shift: Smallint); dispid -602;
    procedure KeyPress(var KeyAscii: Smallint); dispid -603;
    procedure KeyUp(var KeyCode: Smallint; Shift: Smallint); dispid -604;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TCityGuideControl
// Help String      : CityGuideControl Control
// Default Interface: _DCityGuideControl
// Def. Intf. DISP? : Yes
// Event   Interface: _DCityGuideControlEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TCityGuideControlSelfDraw = procedure(ASender: TObject; hDc: OLE_HANDLE; Left: Integer; 
                                                          Top: Integer; Right: Integer; 
                                                          Bottom: Integer) of object;

  TCityGuideControl = class(TOleControl)
  private
    FOnSelfDraw: TCityGuideControlSelfDraw;
    FIntf: _DCityGuideControl;
    function  GetControlInterface: _DCityGuideControl;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    procedure CenterGeoPoint(Lat: Double; Lon: Double);
    procedure CenterScreenPoint(X: Integer; Y: Integer);
    procedure SetScale(Scale: Double; X: Integer; Y: Integer);
    function GetScale: Double;
    function ScreenToGeo(X: Double; Y: Double; var Lat: Double; var Lon: Double): WordBool;
    function GeoToScreen(Lat: Double; Lon: Double; var X: Double; var Y: Double): WordBool;
    function InsertChart(const ChartPath: WideString): WordBool;
    function RemoveChart(const ChartPath: WideString): WordBool;
    function GetNumberOfCharts: LongWord;
    function GetChartInfo(Number: LongWord): IDispatch;
    function MakeRoute(LatFrom: Double; LonFrom: Double; LatTo: Double; LonTo: Double; 
                       RouteType: Integer): IDispatch;
    procedure SetRouteDrawMode(DrawMode: Integer);
    function GetCoordinateConverter: IDispatch;
    function GeoQuery(Lat: Double; Lon: Double): IDispatch;
    procedure DropHighlight;
    function GetContextSettings: IDispatch;
    function GetIRoute: IDispatch;
    procedure ShiftScreen(Dx: Integer; Dy: Integer);
    function GetIJams: IDispatch;
    procedure ShowGeoArea(N: Double; W: Double; S: Double; E: Double);
    function GetIChartsCatalog: IDispatch;
    procedure EnableMouseWheel(Enable: WordBool);
    procedure EnableLazyRedraw(Enable: WordBool);
    procedure ForceRedraw;
    procedure EnableDoubleBufferRedraw(Enable: WordBool);
    procedure SetMouseButtonAction(ButtonNumber: Integer; Action: Integer);
    function UserObjectContainer: IDispatch;
    function DrawToPictureFile(const FilePath: WideString): WordBool;
    function GetCityGuideUser: IDispatch;
    function GetAngle: Double;
    procedure SetAngle(AngleRad: Double);
    property  ControlInterface: _DCityGuideControl read GetControlInterface;
    property  DefaultInterface: _DCityGuideControl read GetControlInterface;
  published
    property Anchors;
    property  TabStop;
    property  Align;
    property  DragCursor;
    property  DragMode;
    property  ParentShowHint;
    property  PopupMenu;
    property  ShowHint;
    property  TabOrder;
    property  Visible;
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property  OnMouseUp;
    property  OnMouseMove;
    property  OnMouseDown;
    property  OnKeyUp;
    property  OnKeyPress;
    property  OnKeyDown;
    property  OnDblClick;
    property  OnClick;
    property OnSelfDraw: TCityGuideControlSelfDraw read FOnSelfDraw write FOnSelfDraw;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses System.Win.ComObj;

procedure TCityGuideControl.InitControlData;
const
  CEventDispIDs: array [0..0] of DWORD = (
    $00000001);
  CControlData: TControlData2 = (
    ClassID:      '{5515FAD2-996E-4576-95C6-91286C31C316}';
    EventIID:     '{4E5A8A13-E04E-4965-8B58-609A609DA74B}';
    EventCount:   1;
    EventDispIDs: @CEventDispIDs;
    LicenseKey:   nil (*HR:$80004005*);
    Flags:        $00000000;
    Version:      500);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := UIntPtr(@@FOnSelfDraw) - UIntPtr(Self);
end;

procedure TCityGuideControl.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DCityGuideControl;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TCityGuideControl.GetControlInterface: _DCityGuideControl;
begin
  CreateControl;
  Result := FIntf;
end;

procedure TCityGuideControl.CenterGeoPoint(Lat: Double; Lon: Double);
begin
  DefaultInterface.CenterGeoPoint(Lat, Lon);
end;

procedure TCityGuideControl.CenterScreenPoint(X: Integer; Y: Integer);
begin
  DefaultInterface.CenterScreenPoint(X, Y);
end;

procedure TCityGuideControl.SetScale(Scale: Double; X: Integer; Y: Integer);
begin
  DefaultInterface.SetScale(Scale, X, Y);
end;

function TCityGuideControl.GetScale: Double;
begin
  Result := DefaultInterface.GetScale;
end;

function TCityGuideControl.ScreenToGeo(X: Double; Y: Double; var Lat: Double; var Lon: Double): WordBool;
begin
  Result := DefaultInterface.ScreenToGeo(X, Y, Lat, Lon);
end;

function TCityGuideControl.GeoToScreen(Lat: Double; Lon: Double; var X: Double; var Y: Double): WordBool;
begin
  Result := DefaultInterface.GeoToScreen(Lat, Lon, X, Y);
end;

function TCityGuideControl.InsertChart(const ChartPath: WideString): WordBool;
begin
  Result := DefaultInterface.InsertChart(ChartPath);
end;

function TCityGuideControl.RemoveChart(const ChartPath: WideString): WordBool;
begin
  Result := DefaultInterface.RemoveChart(ChartPath);
end;

function TCityGuideControl.GetNumberOfCharts: LongWord;
begin
  Result := DefaultInterface.GetNumberOfCharts;
end;

function TCityGuideControl.GetChartInfo(Number: LongWord): IDispatch;
begin
  Result := DefaultInterface.GetChartInfo(Number);
end;

function TCityGuideControl.MakeRoute(LatFrom: Double; LonFrom: Double; LatTo: Double; 
                                     LonTo: Double; RouteType: Integer): IDispatch;
begin
  Result := DefaultInterface.MakeRoute(LatFrom, LonFrom, LatTo, LonTo, RouteType);
end;

procedure TCityGuideControl.SetRouteDrawMode(DrawMode: Integer);
begin
  DefaultInterface.SetRouteDrawMode(DrawMode);
end;

function TCityGuideControl.GetCoordinateConverter: IDispatch;
begin
  Result := DefaultInterface.GetCoordinateConverter;
end;

function TCityGuideControl.GeoQuery(Lat: Double; Lon: Double): IDispatch;
begin
  Result := DefaultInterface.GeoQuery(Lat, Lon);
end;

procedure TCityGuideControl.DropHighlight;
begin
  DefaultInterface.DropHighlight;
end;

function TCityGuideControl.GetContextSettings: IDispatch;
begin
  Result := DefaultInterface.GetContextSettings;
end;

function TCityGuideControl.GetIRoute: IDispatch;
begin
  Result := DefaultInterface.GetIRoute;
end;

procedure TCityGuideControl.ShiftScreen(Dx: Integer; Dy: Integer);
begin
  DefaultInterface.ShiftScreen(Dx, Dy);
end;

function TCityGuideControl.GetIJams: IDispatch;
begin
  Result := DefaultInterface.GetIJams;
end;

procedure TCityGuideControl.ShowGeoArea(N: Double; W: Double; S: Double; E: Double);
begin
  DefaultInterface.ShowGeoArea(N, W, S, E);
end;

function TCityGuideControl.GetIChartsCatalog: IDispatch;
begin
  Result := DefaultInterface.GetIChartsCatalog;
end;

procedure TCityGuideControl.EnableMouseWheel(Enable: WordBool);
begin
  DefaultInterface.EnableMouseWheel(Enable);
end;

procedure TCityGuideControl.EnableLazyRedraw(Enable: WordBool);
begin
  DefaultInterface.EnableLazyRedraw(Enable);
end;

procedure TCityGuideControl.ForceRedraw;
begin
  DefaultInterface.ForceRedraw;
end;

procedure TCityGuideControl.EnableDoubleBufferRedraw(Enable: WordBool);
begin
  DefaultInterface.EnableDoubleBufferRedraw(Enable);
end;

procedure TCityGuideControl.SetMouseButtonAction(ButtonNumber: Integer; Action: Integer);
begin
  DefaultInterface.SetMouseButtonAction(ButtonNumber, Action);
end;

function TCityGuideControl.UserObjectContainer: IDispatch;
begin
  Result := DefaultInterface.UserObjectContainer;
end;

function TCityGuideControl.DrawToPictureFile(const FilePath: WideString): WordBool;
begin
  Result := DefaultInterface.DrawToPictureFile(FilePath);
end;

function TCityGuideControl.GetCityGuideUser: IDispatch;
begin
  Result := DefaultInterface.GetCityGuideUser;
end;

function TCityGuideControl.GetAngle: Double;
begin
  Result := DefaultInterface.GetAngle;
end;

procedure TCityGuideControl.SetAngle(AngleRad: Double);
begin
  DefaultInterface.SetAngle(AngleRad);
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TCityGuideControl]);
end;

end.
