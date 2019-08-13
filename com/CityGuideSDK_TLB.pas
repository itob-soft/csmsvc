unit CityGuideSDK_TLB;

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
// File generated on 15.02.2017 12:04:59 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\CgSdk8.150929\com\CityGuideSDK.tlb (1)
// LIBID: {2069B674-B7BF-4DF9-9DD8-BC33B0FCDEEF}
// LCID: 0
// Helpfile: 
// HelpString: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// Errors:
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Member 'String' of 'IUserObjectText' changed to 'String_'
//   Hint: Parameter 'Type' of IUserObjectsContainer.CreateUserObject changed to 'Type_'
//   Hint: Parameter 'Object' of IGeoDataUser.AddHighlightObject changed to 'Object_'
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleServer, Winapi.ActiveX;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  CityGuideSDKMajorVersion = 1;
  CityGuideSDKMinorVersion = 0;

  LIBID_CityGuideSDK: TGUID = '{2069B674-B7BF-4DF9-9DD8-BC33B0FCDEEF}';

  DIID_ICityGuideUser: TGUID = '{1C938F49-8CF8-4B2F-B98D-D60119C6A8BA}';
  CLASS_CityGuideUser: TGUID = '{CC8DF449-AE51-4717-AEE8-57E1E30A4799}';
  DIID_IEngine: TGUID = '{D16FD295-D202-4396-89CD-466BE7A84A6C}';
  CLASS_Engine: TGUID = '{171FED89-1204-42CD-9ECC-63E391AADC20}';
  DIID_IMapView: TGUID = '{01F25414-6010-4DCD-A0C1-4790C05AB70B}';
  CLASS_MapView: TGUID = '{4C95D66B-4F31-4E27-A053-0D404D7D666F}';
  DIID_IProjection: TGUID = '{54C5D4D1-FCC1-4C5E-9138-827F23C3A055}';
  CLASS_Projection: TGUID = '{C15B96A3-163A-4D81-A4DD-402D362D164F}';
  DIID_ICatalog: TGUID = '{578BD783-0FA3-4979-B530-1FF4DD939E30}';
  CLASS_Catalog: TGUID = '{966E1A57-785B-4699-9A34-16D84D65D7B6}';
  DIID_IChart: TGUID = '{9EB20132-0A18-4C12-B6F3-AA9B8989E56C}';
  CLASS_Chart: TGUID = '{605EDA8B-9E09-4B18-83F6-09071A90D7C9}';
  DIID_IJams: TGUID = '{612C42FA-4497-4814-94D0-22AD15A1DC7B}';
  CLASS_Jams: TGUID = '{08D1EDE4-5E8A-4279-844C-5FC81BCE8B57}';
  DIID_IRoute: TGUID = '{A6958AD0-83C3-410B-8171-C3FFE254C40F}';
  CLASS_Route: TGUID = '{6FC4D12E-40CF-405C-81F8-1829EA09C7EC}';
  DIID_IRouteParameters: TGUID = '{207987D4-7890-4609-B172-22C08A707CF9}';
  CLASS_RouteParameters: TGUID = '{FEAFAA94-14DE-4A92-A4DB-9C30118E0AD4}';
  DIID_IRouteInfo: TGUID = '{A5F234FF-E90B-4B74-A5D1-6207462DB899}';
  CLASS_RouteInfo: TGUID = '{55E27C68-BF57-4F1A-AC5F-4A872C42CBE8}';
  DIID_IRoutePointInfo: TGUID = '{A8A13EDB-18DA-47BB-BDA7-9728ABF5B14D}';
  CLASS_RoutePointInfo: TGUID = '{0E103E70-67A4-482A-BCF7-6F9B0EBA0245}';
  DIID_IGeoQueryInfo: TGUID = '{317EBC8E-0A5B-4E8F-8D2B-77989DDDC6CC}';
  CLASS_GeoQueryInfo: TGUID = '{80EE66D3-E801-4DA3-8904-34CA792EC176}';
  DIID_IAddressInfo: TGUID = '{ECD27A0E-A7A0-4235-9262-20C3C9A4E23F}';
  CLASS_AddressInfo: TGUID = '{86115A96-B7E0-4276-9C98-D3ED1D80EAF2}';
  DIID_ISettlementsInfo: TGUID = '{F27FDCBB-6967-4C38-A131-C25C05484DA2}';
  CLASS_SettlementsInfo: TGUID = '{DC2F3571-6627-4339-81A5-4C0BCFBD4CB3}';
  DIID_IPoiType: TGUID = '{7A5D865D-99CC-47AD-B63F-8BDB7870A6F2}';
  CLASS_PoiType: TGUID = '{E38B2013-D1A4-405E-949A-60C530674828}';
  DIID_IPoiTypes: TGUID = '{F0F291B8-420B-40D3-8974-1F0E4FC7781D}';
  CLASS_PoiTypes: TGUID = '{426A5774-C507-417B-B08F-CAE7E943E865}';
  DIID_IPoiInfo: TGUID = '{8AC03374-52BC-4116-A3E6-E55F73F26349}';
  DIID_IPoiInfos: TGUID = '{A8090966-4208-498E-AF23-AC2222DEAA8B}';
  CLASS_PoiInfos: TGUID = '{ED133277-D04B-4B30-A3E3-3BE65A32C513}';
  CLASS_PoiInfo: TGUID = '{F5AAF840-4B11-4DED-9BF5-C1B5FC5BCC3F}';
  DIID_IInfoLevels: TGUID = '{A60CC4A9-65A9-4A2F-8905-E2A9F688FBF9}';
  CLASS_InfoLevels: TGUID = '{69539DF0-B1E8-49AD-AC85-D35DF9984AF2}';
  DIID_ICrossroadsInfo: TGUID = '{D122C654-EE55-42D6-B9A0-13D8654F3F73}';
  CLASS_CrossroadsInfo: TGUID = '{2784A7CD-5D2D-4EB0-B25F-4B8391908B25}';
  DIID_IContextSettings: TGUID = '{B5B6033C-3F0D-44B4-B4AF-782ED884C2A3}';
  CLASS_ContextSettings: TGUID = '{9CD01F9C-E5EC-4709-AABF-716251DF2627}';
  DIID_IUserObject: TGUID = '{6F890FE7-F4F9-455C-96DC-9D5740583874}';
  CLASS_UserObject: TGUID = '{6AB1E9A5-8D11-4CDD-A413-CE2C287032D2}';
  DIID_IUserObjectLocator: TGUID = '{1AEC9E04-35D2-47F3-994C-98F502F640F4}';
  CLASS_UserObjectLocator: TGUID = '{A0911779-1350-4C5F-AAF9-DF4560076C41}';
  DIID_IUserObjectGeometry: TGUID = '{AEA3120D-2F69-4B72-9209-E2D503975E1C}';
  CLASS_UserObjectGeometry: TGUID = '{5CF2EB85-B8D0-4375-9CA7-20EA3EBC708B}';
  DIID_IUserObjectText: TGUID = '{4CE2F005-043E-428E-872B-A43429C1631F}';
  CLASS_UserObjectText: TGUID = '{8A27C36C-9E48-4209-BB8A-230EF1FF31D3}';
  DIID_IUserObjectEmpty: TGUID = '{37592E88-2725-4AF6-9515-56E647E7A659}';
  CLASS_UserObjectEmpty: TGUID = '{049496A6-5613-4C61-8D96-10BD181F96A7}';
  DIID_IUserObjectBoxed: TGUID = '{6446AFD7-CF60-49CC-AB43-6E90541252F2}';
  CLASS_UserObjectBoxed: TGUID = '{83A5FEF5-FDB3-49B2-A801-12963F296016}';
  DIID_IUserObjectPicture: TGUID = '{8585820E-2750-4000-93E1-4C2191EEE2BA}';
  CLASS_UserObjectPicture: TGUID = '{0A26E6A1-C6B5-4673-9C4A-87CF55F2EA03}';
  DIID_IUserObjectLine: TGUID = '{7EF44F32-7B78-43FF-B461-6537CE51CEEB}';
  CLASS_UserObjectLine: TGUID = '{5C5E27E6-CB22-4A3A-AAF4-630EBC9049C1}';
  DIID_IUserObjectPolygon: TGUID = '{09A6DAE1-DB09-4793-B396-11F60CCBFBBE}';
  CLASS_UserObjectPolygon: TGUID = '{E13A77AB-9AE5-4820-85A2-BAE8E4F8EF69}';
  DIID_IUserObjectExtraParameters: TGUID = '{14498E86-B9C0-4A51-8AF7-4086FA89844A}';
  CLASS_UserObjectExtraParameters: TGUID = '{DECE1BDA-B2EF-4527-BA2A-5A17AEFB9DA6}';
  DIID_IUserObjectsContainer: TGUID = '{86FAA230-10D5-433F-AA81-77DA001AACC7}';
  CLASS_UserObjectsContainer: TGUID = '{357A6451-439D-4522-A772-99B45C1EFF41}';
  DIID_IHighlighter: TGUID = '{CE044627-4640-4701-810C-D99E77D741A9}';
  CLASS_Highlighter: TGUID = '{C4F601F3-701A-4444-861F-F0A9709834BF}';
  DIID_IGeoPoint: TGUID = '{B29B45DE-8BFC-4300-8292-E329FBFEF939}';
  CLASS_GeoPoint: TGUID = '{5F69A4E6-E148-4697-8411-4B117BAA0ADD}';
  DIID_IGeoArea: TGUID = '{E190F0B8-CE5A-4E22-BDC2-5269690B758B}';
  CLASS_GeoArea: TGUID = '{8E0F8014-F3E3-47E6-9515-A7EEDD27F3A3}';
  DIID_IScrPoint: TGUID = '{D6848E2A-AC16-4810-9F48-E0A2731FDB0A}';
  CLASS_ScrPoint: TGUID = '{1C2BC204-41D7-4AF9-BAAC-21117C7FEAAF}';
  DIID_ICoordinateConverter: TGUID = '{513697D7-D387-44A7-9E8E-AB7D8AC5F063}';
  CLASS_CoordinateConverter: TGUID = '{A9D6C935-BF9E-4CF5-9C3A-488C72F0E055}';
  DIID_IGeoDataUser: TGUID = '{3E2DFBD0-8FBA-4DCD-ABDB-CE139A6307B4}';
  CLASS_GeoDataUser: TGUID = '{DDEF3A6A-F231-445E-844F-EC2576EF41BC}';
  DIID_IComUtils: TGUID = '{7DBF119A-10A0-4154-ADFD-CD3E60B2E946}';
  CLASS_ComUtils: TGUID = '{61228F1D-1032-4AA3-AF68-E5A9CE9F7121}';
  DIID_ILibraryInfo: TGUID = '{6149EB48-A3BC-4FF4-888B-2A1DCFB46603}';
  CLASS_LibraryInfo: TGUID = '{66333088-D5EB-42A3-A27D-E20F5540BF02}';
  DIID_IFullAddress: TGUID = '{18FBB5D0-3312-4F14-90BA-6147EA08A20E}';
  CLASS_FullAddress: TGUID = '{4EDEB264-99E0-4547-A09C-316AD490C2C6}';
  DIID_ICgSdkLocalCreator: TGUID = '{7EE839BF-1B9A-4231-8FA9-BE1766A886BF}';
  CLASS_CgSdkLocalCreator: TGUID = '{BCE39848-7CCC-4C2C-8CFC-42E9A2D4CD99}';
  DIID_IInfoQuery: TGUID = '{2DE60319-A782-4CE8-B6A8-71529FDB10C7}';
  CLASS_InfoQuery: TGUID = '{BBA9A5D1-826C-46F8-A4F8-F741AE57D7E9}';
  DIID_IInfoQueryResultsSet: TGUID = '{BED5D04F-5C9E-4A32-82DE-1FB9E47DC7E8}';
  CLASS_InfoQueryResultsSet: TGUID = '{E8316BF7-FF87-4DCF-83EE-172A7EB7234D}';
  DIID_IInfoQueryResult: TGUID = '{570CA1BD-1788-4F4C-8C57-35E694C1572C}';
  CLASS_InfoQueryResult: TGUID = '{57E87084-8EF8-4738-AEF0-6372D452B6AF}';
  DIID_IDistricts: TGUID = '{FE8B14C3-DBF1-4A47-A355-71B57F752F0F}';
  CLASS_Districts: TGUID = '{D663E1A4-3E52-450A-AD69-863C174436A0}';
  DIID_IDistrict: TGUID = '{3833A22E-EC65-4963-A0F1-B80F1A896ACF}';
  CLASS_District: TGUID = '{B1353E82-1990-428E-83EB-930240687C0B}';
  DIID_IDistrictTypes: TGUID = '{472E5C80-AE6C-4914-B6B9-EC97C40CBF64}';
  CLASS_DistrictTypes: TGUID = '{44C18DDB-7E42-42D5-AB19-3F384CB196A1}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ICityGuideUser = dispinterface;
  IEngine = dispinterface;
  IMapView = dispinterface;
  IProjection = dispinterface;
  ICatalog = dispinterface;
  IChart = dispinterface;
  IJams = dispinterface;
  IRoute = dispinterface;
  IRouteParameters = dispinterface;
  IRouteInfo = dispinterface;
  IRoutePointInfo = dispinterface;
  IGeoQueryInfo = dispinterface;
  IAddressInfo = dispinterface;
  ISettlementsInfo = dispinterface;
  IPoiType = dispinterface;
  IPoiTypes = dispinterface;
  IPoiInfo = dispinterface;
  IPoiInfos = dispinterface;
  IInfoLevels = dispinterface;
  ICrossroadsInfo = dispinterface;
  IContextSettings = dispinterface;
  IUserObject = dispinterface;
  IUserObjectLocator = dispinterface;
  IUserObjectGeometry = dispinterface;
  IUserObjectText = dispinterface;
  IUserObjectEmpty = dispinterface;
  IUserObjectBoxed = dispinterface;
  IUserObjectPicture = dispinterface;
  IUserObjectLine = dispinterface;
  IUserObjectPolygon = dispinterface;
  IUserObjectExtraParameters = dispinterface;
  IUserObjectsContainer = dispinterface;
  IHighlighter = dispinterface;
  IGeoPoint = dispinterface;
  IGeoArea = dispinterface;
  IScrPoint = dispinterface;
  ICoordinateConverter = dispinterface;
  IGeoDataUser = dispinterface;
  IComUtils = dispinterface;
  ILibraryInfo = dispinterface;
  IFullAddress = dispinterface;
  ICgSdkLocalCreator = dispinterface;
  IInfoQuery = dispinterface;
  IInfoQueryResultsSet = dispinterface;
  IInfoQueryResult = dispinterface;
  IDistricts = dispinterface;
  IDistrict = dispinterface;
  IDistrictTypes = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  CityGuideUser = ICityGuideUser;
  Engine = IEngine;
  MapView = IMapView;
  Projection = IProjection;
  Catalog = ICatalog;
  Chart = IChart;
  Jams = IJams;
  Route = IRoute;
  RouteParameters = IRouteParameters;
  RouteInfo = IRouteInfo;
  RoutePointInfo = IRoutePointInfo;
  GeoQueryInfo = IGeoQueryInfo;
  AddressInfo = IAddressInfo;
  SettlementsInfo = ISettlementsInfo;
  PoiType = IPoiType;
  PoiTypes = IPoiTypes;
  PoiInfos = IPoiInfos;
  PoiInfo = IPoiInfo;
  InfoLevels = IInfoLevels;
  CrossroadsInfo = ICrossroadsInfo;
  ContextSettings = IContextSettings;
  UserObject = IUserObject;
  UserObjectLocator = IUserObjectLocator;
  UserObjectGeometry = IUserObjectGeometry;
  UserObjectText = IUserObjectText;
  UserObjectEmpty = IUserObjectEmpty;
  UserObjectBoxed = IUserObjectBoxed;
  UserObjectPicture = IUserObjectPicture;
  UserObjectLine = IUserObjectLine;
  UserObjectPolygon = IUserObjectPolygon;
  UserObjectExtraParameters = IUserObjectExtraParameters;
  UserObjectsContainer = IUserObjectsContainer;
  Highlighter = IHighlighter;
  GeoPoint = IGeoPoint;
  GeoArea = IGeoArea;
  ScrPoint = IScrPoint;
  CoordinateConverter = ICoordinateConverter;
  GeoDataUser = IGeoDataUser;
  ComUtils = IComUtils;
  LibraryInfo = ILibraryInfo;
  FullAddress = IFullAddress;
  CgSdkLocalCreator = ICgSdkLocalCreator;
  InfoQuery = IInfoQuery;
  InfoQueryResultsSet = IInfoQueryResultsSet;
  InfoQueryResult = IInfoQueryResult;
  Districts = IDistricts;
  District = IDistrict;
  DistrictTypes = IDistrictTypes;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PDouble1 = ^Double; {*}


// *********************************************************************//
// DispIntf:  ICityGuideUser
// Flags:     (4096) Dispatchable
// GUID:      {1C938F49-8CF8-4B2F-B98D-D60119C6A8BA}
// *********************************************************************//
  ICityGuideUser = dispinterface
    ['{1C938F49-8CF8-4B2F-B98D-D60119C6A8BA}']
    function Initialize(const ReadFolder: WideString; const WriteFolder: WideString; 
                        const LogName: WideString; const IniFilePath: WideString): WordBool; dispid 1;
    function GetMapView: IDispatch; dispid 2;
    function GetProjection: IDispatch; dispid 3;
    function GetCoordinateConverter: IDispatch; dispid 4;
    function GetCatalog: IDispatch; dispid 5;
    function GetRoute: IDispatch; dispid 6;
    function GetJams: IDispatch; dispid 7;
    function GetContextSettings: IDispatch; dispid 8;
    function GetHighlighter: IDispatch; dispid 9;
    function GetUserObjectContainer: IDispatch; dispid 10;
    function GetLibraryInfo: IDispatch; dispid 11;
    function GetInfoQuery: IDispatch; dispid 12;
  end;

// *********************************************************************//
// DispIntf:  IEngine
// Flags:     (4096) Dispatchable
// GUID:      {D16FD295-D202-4396-89CD-466BE7A84A6C}
// *********************************************************************//
  IEngine = dispinterface
    ['{D16FD295-D202-4396-89CD-466BE7A84A6C}']
    property Chart: IDispatch readonly dispid 1;
    property Route: IDispatch readonly dispid 2;
    property Jams: IDispatch readonly dispid 3;
    property ContextSettings: IDispatch readonly dispid 4;
    property ChartsCatalog: IDispatch readonly dispid 5;
    function Init(const szMapFName: WideString): WordBool; dispid 100;
    procedure DropHighlighted; dispid 101;
    procedure Highlight(dLat: Double; dLon: Double; const szText: WideString); dispid 102;
    function GeoQuery(dLat: Double; dLon: Double): IDispatch; dispid 103;
    function UserObjectContainer: IDispatch; dispid 104;
    function CityGuideUser: IDispatch; dispid 105;
  end;

// *********************************************************************//
// DispIntf:  IMapView
// Flags:     (4096) Dispatchable
// GUID:      {01F25414-6010-4DCD-A0C1-4790C05AB70B}
// *********************************************************************//
  IMapView = dispinterface
    ['{01F25414-6010-4DCD-A0C1-4790C05AB70B}']
    procedure SetScreenSize(Dx: Integer; Dy: Integer); dispid 100;
    procedure Draw(hDc: OLE_HANDLE); dispid 200;
    procedure DrawToFile(const FilePath: WideString); dispid 300;
  end;

// *********************************************************************//
// DispIntf:  IProjection
// Flags:     (4096) Dispatchable
// GUID:      {54C5D4D1-FCC1-4C5E-9138-827F23C3A055}
// *********************************************************************//
  IProjection = dispinterface
    ['{54C5D4D1-FCC1-4C5E-9138-827F23C3A055}']
    function GetScale: Double; dispid 1;
    procedure SetScale(Scale: Double; ScreenX: Double; ScreenY: Double); dispid 2;
    procedure SetPosition(Lat: Double; Lon: Double; X: Double; Y: Double); dispid 3;
    procedure ShiftScreen(DeltaX: Integer; DeltaY: Integer); dispid 4;
    procedure CenterPoint(X: Integer; Y: Integer); dispid 5;
    procedure SetByGeoFrame(N: Double; W: Double; S: Double; E: Double; ScaleMultiplier: Double); dispid 6;
    procedure GetParameters(var Scale: Double; var LatRad: Double; var LonRad: Double; 
                            var ScrX: Double; var ScrY: Double; var ScrResolution: Double; 
                            var MapResolution: Double); dispid 7;
    procedure SetCallbackVariant(Callback: OleVariant); dispid 8;
    function GetAngle: Double; dispid 900;
    procedure SetAngle(AngleRad: Double); dispid 1000;
  end;

// *********************************************************************//
// DispIntf:  ICatalog
// Flags:     (4096) Dispatchable
// GUID:      {578BD783-0FA3-4979-B530-1FF4DD939E30}
// *********************************************************************//
  ICatalog = dispinterface
    ['{578BD783-0FA3-4979-B530-1FF4DD939E30}']
    function InsertChart(const ChartPath: WideString): WordBool; dispid 1;
    function GetChartsCount: LongWord; dispid 2;
    function RemoveChart(const ChartPath: WideString): WordBool; dispid 3;
    procedure RemoveAllCharts; dispid 4;
    function SetActiveChart(const ChartPath: WideString): WordBool; dispid 5;
    function GetActiveChartInfo: IDispatch; dispid 6;
    function GetChartInfo(const ChartPath: WideString): IDispatch; dispid 7;
    function GetChartInfoByNumber(ChartNumber: LongWord): IDispatch; dispid 8;
    function GetChartInfoByPosition(Lat: Double; Lon: Double): IDispatch; dispid 9;
    function InsertChart2(const ChartPath: WideString): Integer; dispid 10;
    function NumberByPath(const ChartPath: WideString): LongWord; dispid 110;
    function IsLicenseValid: WordBool; dispid 120;
  end;

// *********************************************************************//
// DispIntf:  IChart
// Flags:     (4096) Dispatchable
// GUID:      {9EB20132-0A18-4C12-B6F3-AA9B8989E56C}
// *********************************************************************//
  IChart = dispinterface
    ['{9EB20132-0A18-4C12-B6F3-AA9B8989E56C}']
    property Title: WideString readonly dispid 1;
    property Version: Integer readonly dispid 2;
    property SubVersion: Integer readonly dispid 3;
    property LocalTitle: WideString readonly dispid 4;
    property Path: WideString readonly dispid 5;
    property Update: TDateTime readonly dispid 6;
    property Scale: Integer readonly dispid 7;
    property JamDate: TDateTime readonly dispid 8;
    procedure Overview; dispid 100;
    function GetOriginGeoPoint: IDispatch; dispid 109;
    function GetGeoArea(out N: Double; out W: Double; out S: Double; out E: Double): WordBool; dispid 101;
    function GetGeoArea2: IDispatch; dispid 102;
    procedure SetUserUpdFolder(const Folder: WideString); dispid 104;
    function AddressInfo: IDispatch; dispid 103;
    function PoiTypes: IDispatch; dispid 105;
    function InfoLevels: IDispatch; dispid 106;
    function SettlementsInfo(const TitlePrefix: WideString): IDispatch; dispid 107;
    function AddressInfo2(RegionCookie: Integer; const TitlePrefix: WideString): IDispatch; dispid 108;
    function InfoQuery: IDispatch; dispid 1900;
    function GetDistricts(DistrictType: Integer): IDispatch; dispid 2000;
    function GetDistrictTypes: IDispatch; dispid 2100;
  end;

// *********************************************************************//
// DispIntf:  IJams
// Flags:     (4096) Dispatchable
// GUID:      {612C42FA-4497-4814-94D0-22AD15A1DC7B}
// *********************************************************************//
  IJams = dispinterface
    ['{612C42FA-4497-4814-94D0-22AD15A1DC7B}']
    property AutoApplying: WordBool dispid 102;
    property UseOnlyClosedStreets: WordBool dispid 103;
    property DoDownload: WordBool dispid 120;
    property Applied: WordBool readonly dispid 1;
    function Apply(const strFName: WideString): WordBool; dispid 100;
    procedure Drop; dispid 101;
  end;

// *********************************************************************//
// DispIntf:  IRoute
// Flags:     (4096) Dispatchable
// GUID:      {A6958AD0-83C3-410B-8171-C3FFE254C40F}
// *********************************************************************//
  IRoute = dispinterface
    ['{A6958AD0-83C3-410B-8171-C3FFE254C40F}']
    property LegendMaking: WordBool dispid 1;
    property Parameters: IDispatch dispid 2;
    property RecalcMode: Integer dispid 5;
    property DrawAlpha: Byte dispid 10;
    function SetStart(dLat: Double; dLon: Double): WordBool; dispid 100;
    function SetFinish(dLat: Double; dLon: Double): WordBool; dispid 101;
    procedure Drop; dispid 102;
    procedure Overview; dispid 103;
    procedure SetRouteType(RouteType: Integer); dispid 104;
    function GetRouteInfo: IDispatch; dispid 105;
    procedure SetDrawMode(DrawMode: Integer); dispid 106;
    function AddPoint(dLat: Double; dLon: Double): WordBool; dispid 107;
    function SetAllPoints(Points: OleVariant): WordBool; dispid 108;
    procedure TravelingSalesman; dispid 109;
    function GetRouteInfoCount: Integer; dispid 110;
    function GetRouteInfoEx(Index: Integer): IDispatch; dispid 111;
    function GetRoutesInfoDump: OleVariant; dispid 115;
    function EstimateDepartureTime(FinishTimeUtc: TDateTime): TDateTime; dispid 120;
    function GetAllPoints: OleVariant; dispid 200;
    procedure RecalcRoute; dispid 300;
  end;

// *********************************************************************//
// DispIntf:  IRouteParameters
// Flags:     (4096) Dispatchable
// GUID:      {207987D4-7890-4609-B172-22C08A707CF9}
// *********************************************************************//
  IRouteParameters = dispinterface
    ['{207987D4-7890-4609-B172-22C08A707CF9}']
    property type_: Integer dispid 1;
    property PointsInterpretation: Integer dispid 2;
    property AllowYards: WordBool dispid 10;
    property AllowSideWays: WordBool dispid 11;
    property AllowGroundRoads: WordBool dispid 12;
    property AllowPaidRoads: WordBool dispid 13;
    property UseLimitsUpd: WordBool dispid 14;
    property UseJams: WordBool dispid 20;
    property UseForecast: WordBool dispid 21;
    property ForecastDateTimeUtc: TDateTime dispid 22;
    property SalesmanTimeRestrictionSec: LongWord dispid 23;
    property CheckTwoWay: WordBool dispid 24;
    function Save: Integer; dispid 100;
    function Restore: Integer; dispid 101;
  end;

// *********************************************************************//
// DispIntf:  IRouteInfo
// Flags:     (4096) Dispatchable
// GUID:      {A5F234FF-E90B-4B74-A5D1-6207462DB899}
// *********************************************************************//
  IRouteInfo = dispinterface
    ['{A5F234FF-E90B-4B74-A5D1-6207462DB899}']
    function GetDistance: Double; dispid 1;
    function GetTime: Double; dispid 2;
    function GetNumberOfPoints: Integer; dispid 3;
    function GetPoint(Number: Integer): IDispatch; dispid 4;
    function GetTrack: OleVariant; dispid 5;
    procedure Overview; dispid 6;
  end;

// *********************************************************************//
// DispIntf:  IRoutePointInfo
// Flags:     (4096) Dispatchable
// GUID:      {A8A13EDB-18DA-47BB-BDA7-9728ABF5B14D}
// *********************************************************************//
  IRoutePointInfo = dispinterface
    ['{A8A13EDB-18DA-47BB-BDA7-9728ABF5B14D}']
    function GetTime: Double; dispid 1;
    function GetDistance: Double; dispid 2;
    function GetStreetName: WideString; dispid 3;
    function GetType: Integer; dispid 4;
    function GetLat: Double; dispid 5;
    function GetLon: Double; dispid 6;
    function GetMapName: WideString; dispid 7;
  end;

// *********************************************************************//
// DispIntf:  IGeoQueryInfo
// Flags:     (4096) Dispatchable
// GUID:      {317EBC8E-0A5B-4E8F-8D2B-77989DDDC6CC}
// *********************************************************************//
  IGeoQueryInfo = dispinterface
    ['{317EBC8E-0A5B-4E8F-8D2B-77989DDDC6CC}']
    function GetTitle: WideString; dispid 1;
  end;

// *********************************************************************//
// DispIntf:  IAddressInfo
// Flags:     (4096) Dispatchable
// GUID:      {ECD27A0E-A7A0-4235-9262-20C3C9A4E23F}
// *********************************************************************//
  IAddressInfo = dispinterface
    ['{ECD27A0E-A7A0-4235-9262-20C3C9A4E23F}']
    function GetStreetsCount: Integer; dispid 1;
    function GetHousesCount(StreetNumber: Integer): Integer; dispid 2;
    function GetTitle(StreetNumber: Integer; HouseNumber: Integer): WideString; dispid 3;
    procedure Highlight(StreetNumber: Integer; HouseNumber: Integer); dispid 4;
    procedure Overview(StreetNumber: Integer; HouseNumber: Integer); dispid 5;
    function GetPosition(StreetNumber: Integer; HouseNumber: Integer): IDispatch; dispid 6;
    function GetStreetInfo(StreetNumber: Integer): IDispatch; dispid 7;
    function GetCrossroadsInfo(StreetNumber: Integer): IDispatch; dispid 8;
    function GetNearestAddress(Lat: Double; Lon: Double; DeltaPix: Smallint): Integer; dispid 9;
    function GetNearestStreet(Lat: Double; Lon: Double; DeltaPix: Smallint): Integer; dispid 10;
    function GetNearestHouse(StreetNumber: Integer; Lat: Double; Lon: Double; DeltaPix: Smallint): Integer; dispid 11;
    function GetNearestStreetPosition(Lat: Double; Lon: Double; DeltaPix: Smallint): IDispatch; dispid 12;
    function GetStreetHints: WideString; dispid 13;
    function GetNearestFullAddress(LatRad: Double; LonRad: Double; DeltaPix: Smallint; 
                                   DeltaMet: Double): IDispatch; dispid 1000;
  end;

// *********************************************************************//
// DispIntf:  ISettlementsInfo
// Flags:     (4096) Dispatchable
// GUID:      {F27FDCBB-6967-4C38-A131-C25C05484DA2}
// *********************************************************************//
  ISettlementsInfo = dispinterface
    ['{F27FDCBB-6967-4C38-A131-C25C05484DA2}']
    function GetCount: Integer; dispid 1;
    function GetTitle(Index: Integer): WideString; dispid 2;
    function GetAddressInfo(Index: Integer): IDispatch; dispid 3;
    function GetPosition(Index: Integer): IDispatch; dispid 4;
    function GetCookie(Index: Integer): Integer; dispid 5;
    procedure Highlight(Index: Integer); dispid 6;
    procedure Overview(Index: Integer); dispid 7;
    function GetHints: WideString; dispid 8;
  end;

// *********************************************************************//
// DispIntf:  IPoiType
// Flags:     (4096) Dispatchable
// GUID:      {7A5D865D-99CC-47AD-B63F-8BDB7870A6F2}
// *********************************************************************//
  IPoiType = dispinterface
    ['{7A5D865D-99CC-47AD-B63F-8BDB7870A6F2}']
    property Visible: WordBool dispid 10;
    function GetPoiTypes: IDispatch; dispid 1;
    function GetPoiInfos(const TitlePrefix: WideString): IDispatch; dispid 2;
    function GetTitle: WideString; dispid 3;
  end;

// *********************************************************************//
// DispIntf:  IPoiTypes
// Flags:     (4096) Dispatchable
// GUID:      {F0F291B8-420B-40D3-8974-1F0E4FC7781D}
// *********************************************************************//
  IPoiTypes = dispinterface
    ['{F0F291B8-420B-40D3-8974-1F0E4FC7781D}']
    function GetTypeCount: Integer; dispid 1;
    function GetTypeTitle(TypeNumber: Integer): WideString; dispid 2;
    function GetInfoCount(TypeNumber: Integer): Integer; dispid 3;
    function GetPoiType(TypeNumber: Integer): IDispatch; dispid 4;
    function GetPoiTypes(TypeNumber: Integer): IDispatch; dispid 5;
    function GetPoiInfo(TypeNumber: Integer; InfoNumber: Integer): IDispatch; dispid 6;
    function GetPoiInfos(TypeNumber: Integer): IDispatch; dispid 7;
  end;

// *********************************************************************//
// DispIntf:  IPoiInfo
// Flags:     (4096) Dispatchable
// GUID:      {8AC03374-52BC-4116-A3E6-E55F73F26349}
// *********************************************************************//
  IPoiInfo = dispinterface
    ['{8AC03374-52BC-4116-A3E6-E55F73F26349}']
    function GetTitle: WideString; dispid 1;
    function GetPosition: IDispatch; dispid 2;
    procedure Highlight; dispid 3;
    procedure Overview; dispid 4;
    function GetAddress: WideString; dispid 5;
    function GetAttrFullAddress: IDispatch; dispid 600;
    function GetNearestFullAddress: IDispatch; dispid 1000;
  end;

// *********************************************************************//
// DispIntf:  IPoiInfos
// Flags:     (4096) Dispatchable
// GUID:      {A8090966-4208-498E-AF23-AC2222DEAA8B}
// *********************************************************************//
  IPoiInfos = dispinterface
    ['{A8090966-4208-498E-AF23-AC2222DEAA8B}']
    function GetCount: Integer; dispid 1;
    function GetInfo(InfoNumber: Integer): IDispatch; dispid 2;
    function GetHints: WideString; dispid 3;
  end;

// *********************************************************************//
// DispIntf:  IInfoLevels
// Flags:     (4096) Dispatchable
// GUID:      {A60CC4A9-65A9-4A2F-8905-E2A9F688FBF9}
// *********************************************************************//
  IInfoLevels = dispinterface
    ['{A60CC4A9-65A9-4A2F-8905-E2A9F688FBF9}']
    function GetCount: Integer; dispid 1;
    function GetTitle(Number: Integer): WideString; dispid 2;
    function IsVisible(Number: Integer): WordBool; dispid 3;
    function SetVisibility(Number: Integer; IsVisible: WordBool): WordBool; dispid 4;
  end;

// *********************************************************************//
// DispIntf:  ICrossroadsInfo
// Flags:     (4096) Dispatchable
// GUID:      {D122C654-EE55-42D6-B9A0-13D8654F3F73}
// *********************************************************************//
  ICrossroadsInfo = dispinterface
    ['{D122C654-EE55-42D6-B9A0-13D8654F3F73}']
    function GetCrossroadsCount: Integer; dispid 1;
    function GetTitle(Number: Integer): WideString; dispid 2;
    function GetPosition(Number: Integer): IDispatch; dispid 3;
    procedure Highlight(Number: Integer); dispid 4;
    procedure Overview(Number: Integer); dispid 5;
    function GetStreet(Number: Integer): Integer; dispid 6;
  end;

// *********************************************************************//
// DispIntf:  IContextSettings
// Flags:     (4096) Dispatchable
// GUID:      {B5B6033C-3F0D-44B4-B4AF-782ED884C2A3}
// *********************************************************************//
  IContextSettings = dispinterface
    ['{B5B6033C-3F0D-44B4-B4AF-782ED884C2A3}']
    property ShowJamsMode: Integer dispid 1;
    property ShowOneWay: Integer dispid 2;
    property IsJamsOnlyOnActiveChart: WordBool dispid 3;
    property ShowChart: WordBool dispid 4;
    property ShowScale: Integer dispid 5;
    property ShowTrafficSigns: WordBool dispid 8;
    property MapDetalization: Integer dispid 600;
    property TextSize: Integer dispid 700;
  end;

// *********************************************************************//
// DispIntf:  IUserObject
// Flags:     (4096) Dispatchable
// GUID:      {6F890FE7-F4F9-455C-96DC-9D5740583874}
// *********************************************************************//
  IUserObject = dispinterface
    ['{6F890FE7-F4F9-455C-96DC-9D5740583874}']
    property Visible: WordBool dispid 1;
    property Priority: Double dispid 2;
    property MinScale: Double dispid 3;
    property Alpha: Byte dispid 4;
    function GetType: Integer; dispid 100;
    function GetGeometry: IDispatch; dispid 101;
    function GetPresentation: IDispatch; dispid 102;
    function GetExtraText: IDispatch; dispid 103;
    function GetLocator: IDispatch; dispid 104;
    procedure HighlightEx(SubNumber: Integer; ShowHide: WordBool); dispid 199;
    procedure Highlight; dispid 200;
    procedure Overview; dispid 201;
  end;

// *********************************************************************//
// DispIntf:  IUserObjectLocator
// Flags:     (4096) Dispatchable
// GUID:      {1AEC9E04-35D2-47F3-994C-98F502F640F4}
// *********************************************************************//
  IUserObjectLocator = dispinterface
    ['{1AEC9E04-35D2-47F3-994C-98F502F640F4}']
    function LocateByScreenPoint(X: Double; Y: Double; SubNumber: Integer; DeltaPix: Word): Integer; dispid 10;
  end;

// *********************************************************************//
// DispIntf:  IUserObjectGeometry
// Flags:     (4096) Dispatchable
// GUID:      {AEA3120D-2F69-4B72-9209-E2D503975E1C}
// *********************************************************************//
  IUserObjectGeometry = dispinterface
    ['{AEA3120D-2F69-4B72-9209-E2D503975E1C}']
    property type_: Integer dispid 1;
    procedure AddPoint(X: Double; Y: Double); dispid 100;
    function GetPointsCount: LongWord; dispid 101;
    function GetPoint(PointNumber: LongWord): IDispatch; dispid 102;
    function SetPoint(PointNumber: LongWord; X: Double; Y: Double): WordBool; dispid 103;
    procedure RemoveAllPoints; dispid 104;
    function RemovePoint(PointNumber: LongWord): WordBool; dispid 110;
    function InsertPoint(PointNumber: LongWord; X: Double; Y: Double): WordBool; dispid 120;
    function PointExtraParameters(PointNumber: Integer): IDispatch; dispid 200;
    function AddPointEx(X: Double; Y: Double): IDispatch; dispid 201;
  end;

// *********************************************************************//
// DispIntf:  IUserObjectText
// Flags:     (4096) Dispatchable
// GUID:      {4CE2F005-043E-428E-872B-A43429C1631F}
// *********************************************************************//
  IUserObjectText = dispinterface
    ['{4CE2F005-043E-428E-872B-A43429C1631F}']
    property String_: WideString dispid 1;
    property Color: OLE_COLOR dispid 2;
    property AlignX: LongWord dispid 3;
    property AlignY: LongWord dispid 4;
    property FontName: WideString dispid 5;
    property FontSize: Integer dispid 6;
    property BackColor: OLE_COLOR dispid 7;
  end;

// *********************************************************************//
// DispIntf:  IUserObjectEmpty
// Flags:     (4096) Dispatchable
// GUID:      {37592E88-2725-4AF6-9515-56E647E7A659}
// *********************************************************************//
  IUserObjectEmpty = dispinterface
    ['{37592E88-2725-4AF6-9515-56E647E7A659}']
  end;

// *********************************************************************//
// DispIntf:  IUserObjectBoxed
// Flags:     (4096) Dispatchable
// GUID:      {6446AFD7-CF60-49CC-AB43-6E90541252F2}
// *********************************************************************//
  IUserObjectBoxed = dispinterface
    ['{6446AFD7-CF60-49CC-AB43-6E90541252F2}']
    property type_: LongWord dispid 1;
    property Width: LongWord dispid 2;
    property Height: LongWord dispid 3;
    property ColorBrush: OLE_COLOR dispid 4;
    property ColorPen: OLE_COLOR dispid 5;
    property SubType: LongWord dispid 6;
    property SizeType: LongWord dispid 7;
    property Angle: Double dispid 8;
    property PenWidth: LongWord dispid 9;
  end;

// *********************************************************************//
// DispIntf:  IUserObjectPicture
// Flags:     (4096) Dispatchable
// GUID:      {8585820E-2750-4000-93E1-4C2191EEE2BA}
// *********************************************************************//
  IUserObjectPicture = dispinterface
    ['{8585820E-2750-4000-93E1-4C2191EEE2BA}']
    property FilePath: WideString dispid 1;
    property ColorZero: OLE_COLOR dispid 2;
    property ColorOne: OLE_COLOR dispid 3;
    property PivotX: Integer dispid 4;
    property PivotY: Integer dispid 5;
    property PivotPosition: Integer dispid 6;
    procedure ClearCache; dispid 100;
  end;

// *********************************************************************//
// DispIntf:  IUserObjectLine
// Flags:     (4096) Dispatchable
// GUID:      {7EF44F32-7B78-43FF-B461-6537CE51CEEB}
// *********************************************************************//
  IUserObjectLine = dispinterface
    ['{7EF44F32-7B78-43FF-B461-6537CE51CEEB}']
    property Color: OLE_COLOR dispid 1;
    property Width: LongWord dispid 2;
    property Style: Integer dispid 3;
  end;

// *********************************************************************//
// DispIntf:  IUserObjectPolygon
// Flags:     (4096) Dispatchable
// GUID:      {09A6DAE1-DB09-4793-B396-11F60CCBFBBE}
// *********************************************************************//
  IUserObjectPolygon = dispinterface
    ['{09A6DAE1-DB09-4793-B396-11F60CCBFBBE}']
    property ColorBrush: OLE_COLOR dispid 1;
    property ColorPen: OLE_COLOR dispid 2;
  end;

// *********************************************************************//
// DispIntf:  IUserObjectExtraParameters
// Flags:     (4096) Dispatchable
// GUID:      {14498E86-B9C0-4A51-8AF7-4086FA89844A}
// *********************************************************************//
  IUserObjectExtraParameters = dispinterface
    ['{14498E86-B9C0-4A51-8AF7-4086FA89844A}']
    property ColorMain: OLE_COLOR dispid 100;
    property ColorAux: OLE_COLOR dispid 200;
    property LengthMain: LongWord dispid 300;
    property LengthAux: LongWord dispid 400;
    function Text: IDispatch; dispid 1000;
    procedure MakeText(const Text: WideString; SetDefaultIfExists: WordBool); dispid 1100;
  end;

// *********************************************************************//
// DispIntf:  IUserObjectsContainer
// Flags:     (4096) Dispatchable
// GUID:      {86FAA230-10D5-433F-AA81-77DA001AACC7}
// *********************************************************************//
  IUserObjectsContainer = dispinterface
    ['{86FAA230-10D5-433F-AA81-77DA001AACC7}']
    function CreateUserObject(Type_: Integer; InsertItself: WordBool): IDispatch; dispid 1;
    function InsertUserObject(const UserObject: IDispatch): WordBool; dispid 2;
    function InsertUserObjectEx(UserObjectNumber: LongWord; const UserObject: IDispatch): WordBool; dispid 8;
    function AppendUserObject(const UserObject: IDispatch): WordBool; dispid 9;
    function RemoveUserObject(const UserObject: IDispatch): WordBool; dispid 3;
    procedure RemoveAllUserObjects; dispid 4;
    function GetUserObjectsCount: LongWord; dispid 5;
    function GetUserObject(UserObjectNumber: LongWord): IDispatch; dispid 6;
    function GetOwner: IDispatch; dispid 7;
  end;

// *********************************************************************//
// DispIntf:  IHighlighter
// Flags:     (4096) Dispatchable
// GUID:      {CE044627-4640-4701-810C-D99E77D741A9}
// *********************************************************************//
  IHighlighter = dispinterface
    ['{CE044627-4640-4701-810C-D99E77D741A9}']
    procedure Highlight(Lat: Double; Lon: Double; const Title: WideString); dispid 1;
    procedure DropHighlighted; dispid 2;
  end;

// *********************************************************************//
// DispIntf:  IGeoPoint
// Flags:     (4096) Dispatchable
// GUID:      {B29B45DE-8BFC-4300-8292-E329FBFEF939}
// *********************************************************************//
  IGeoPoint = dispinterface
    ['{B29B45DE-8BFC-4300-8292-E329FBFEF939}']
    function Lat: Double; dispid 1;
    function Lon: Double; dispid 2;
    function LatRad: Double; dispid 100;
    function LonRad: Double; dispid 150;
    function LatDeg: Double; dispid 200;
    function LonDeg: Double; dispid 250;
    procedure SetRad(LatRad: Double; LonRad: Double); dispid 300;
    procedure SetDeg(LatDeg: Double; LonDeg: Double); dispid 400;
  end;

// *********************************************************************//
// DispIntf:  IGeoArea
// Flags:     (4096) Dispatchable
// GUID:      {E190F0B8-CE5A-4E22-BDC2-5269690B758B}
// *********************************************************************//
  IGeoArea = dispinterface
    ['{E190F0B8-CE5A-4E22-BDC2-5269690B758B}']
    function N: Double; dispid 1;
    function W: Double; dispid 2;
    function S: Double; dispid 3;
    function E: Double; dispid 4;
    procedure Make(N: Double; W: Double; S: Double; E: Double); dispid 5;
    function IsValid: WordBool; dispid 6;
  end;

// *********************************************************************//
// DispIntf:  IScrPoint
// Flags:     (4096) Dispatchable
// GUID:      {D6848E2A-AC16-4810-9F48-E0A2731FDB0A}
// *********************************************************************//
  IScrPoint = dispinterface
    ['{D6848E2A-AC16-4810-9F48-E0A2731FDB0A}']
    function X: Double; dispid 1;
    function Y: Double; dispid 2;
  end;

// *********************************************************************//
// DispIntf:  ICoordinateConverter
// Flags:     (4096) Dispatchable
// GUID:      {513697D7-D387-44A7-9E8E-AB7D8AC5F063}
// *********************************************************************//
  ICoordinateConverter = dispinterface
    ['{513697D7-D387-44A7-9E8E-AB7D8AC5F063}']
    function ScreenToGeo(X: Double; Y: Double; var Lat: Double; var Lon: Double): WordBool; dispid 1;
    function GeoToScreen(Lat: Double; Lon: Double; var X: Double; var Y: Double): WordBool; dispid 2;
    function ScreenToGeo2(X: Double; Y: Double): IDispatch; dispid 3;
    function GeoToScreen2(Lat: Double; Lon: Double): IDispatch; dispid 4;
    function ScreenToGeoArray(ScreenArray: OleVariant): OleVariant; dispid 5;
    function GeoToScreenArray(GeoArray: OleVariant): OleVariant; dispid 6;
  end;

// *********************************************************************//
// DispIntf:  IGeoDataUser
// Flags:     (4096) Dispatchable
// GUID:      {3E2DFBD0-8FBA-4DCD-ABDB-CE139A6307B4}
// *********************************************************************//
  IGeoDataUser = dispinterface
    ['{3E2DFBD0-8FBA-4DCD-ABDB-CE139A6307B4}']
    property PathGif: WideString dispid 1;
    property GeoProjection: Integer dispid 26;
    property AutoGeoProjection: WordBool dispid 27;
    procedure Draw; dispid 2;
    function GetGeoParam(var Scale: Double; var CenterLat: Double; var CenterLon: Double): SCODE; dispid 3;
    procedure SetGeoParam(Lat: Double; Lon: Double; Scale: Double); dispid 4;
    procedure SetScreenSize(Dx: Integer; Dy: Integer); dispid 5;
    procedure CenterPoint(X: Integer; Y: Integer); dispid 6;
    procedure SetScale(Scale: Double; X: Integer; Y: Integer); dispid 7;
    function GetScale: Double; dispid 8;
    procedure ShowGeoArea(N: Double; W: Double; S: Double; E: Double); dispid 9;
    procedure SetGeoLimit(N: Double; W: Double; S: Double; E: Double); dispid 10;
    procedure ClearGeoLimit; dispid 11;
    function ScreenToGeo(X: Double; Y: Double; var Lat: Double; var Lon: Double): Integer; dispid 12;
    function ScreenToGeo2(X: Double; Y: Double): IDispatch; dispid 13;
    function GeoToScreen(Lat: Double; Lon: Double; var X: Double; var Y: Double): Integer; dispid 14;
    function GeoToScreen2(Lat: Double; Lon: Double): IDispatch; dispid 15;
    function LatToString(Lat: Double; Format: Word; Prec: Word): WideString; dispid 16;
    function LonToString(Lon: Double; Format: Word; Prec: Word): WideString; dispid 17;
    function StringToCrd(const Str: WideString): Double; dispid 18;
    procedure ShowOverview(ShowMode: Smallint); dispid 19;
    procedure AddHighlightObject(const Object_: IDispatch; Color: OLE_COLOR); dispid 20;
    procedure ClearHighlightObject; dispid 21;
    function GetPlugInInterface(const ClassId: WideString): IDispatch; dispid 22;
    property PresParam[ePresParamType: Integer]: OleVariant dispid 23;
    function CalculateLoxodromicDistance(LatFrom: Double; LonFrom: Double; LatTo: Double; 
                                         LonTo: Double): Double; dispid 24;
    function CalculateOrthodromicDistance(LatFrom: Double; LonFrom: Double; LatTo: Double; 
                                          LonTo: Double): Double; dispid 25;
    procedure SetOriginalScale; dispid 28;
    function GetChartListUnderPoint(Lat: Double; Lon: Double): IDispatch; dispid 29;
    procedure SetShowHideHighlightMode(ShowNoHide: WordBool); dispid 30;
    function GetCoordinateConverter: IDispatch; dispid 31;
    procedure ShiftScreen(Dx: Integer; Dy: Integer); dispid 32;
    procedure SetPosition(Lat: Double; Lon: Double; ScrX: Double; ScrY: Double); dispid 33;
  end;

// *********************************************************************//
// DispIntf:  IComUtils
// Flags:     (4096) Dispatchable
// GUID:      {7DBF119A-10A0-4154-ADFD-CD3E60B2E946}
// *********************************************************************//
  IComUtils = dispinterface
    ['{7DBF119A-10A0-4154-ADFD-CD3E60B2E946}']
    function MarshalInterface(const IFace: IDispatch): OleVariant; dispid 1;
  end;

// *********************************************************************//
// DispIntf:  ILibraryInfo
// Flags:     (4096) Dispatchable
// GUID:      {6149EB48-A3BC-4FF4-888B-2A1DCFB46603}
// *********************************************************************//
  ILibraryInfo = dispinterface
    ['{6149EB48-A3BC-4FF4-888B-2A1DCFB46603}']
    function Version: LongWord; dispid 10;
    function SubVersion: LongWord; dispid 11;
    function ReleaseDate: TDateTime; dispid 12;
    function SpecialBuild: WideString; dispid 13;
    function SerialNumber: WideString; dispid 50;
    function SecurityKeyId: WideString; dispid 100;
  end;

// *********************************************************************//
// DispIntf:  IFullAddress
// Flags:     (4096) Dispatchable
// GUID:      {18FBB5D0-3312-4F14-90BA-6147EA08A20E}
// *********************************************************************//
  IFullAddress = dispinterface
    ['{18FBB5D0-3312-4F14-90BA-6147EA08A20E}']
    property Region: WideString dispid 100;
    property Settlement: WideString dispid 200;
    property Street: WideString dispid 300;
    property House: WideString dispid 400;
  end;

// *********************************************************************//
// DispIntf:  ICgSdkLocalCreator
// Flags:     (4096) Dispatchable
// GUID:      {7EE839BF-1B9A-4231-8FA9-BE1766A886BF}
// *********************************************************************//
  ICgSdkLocalCreator = dispinterface
    ['{7EE839BF-1B9A-4231-8FA9-BE1766A886BF}']
    function CreateCityGuideUser: IDispatch; dispid 100;
  end;

// *********************************************************************//
// DispIntf:  IInfoQuery
// Flags:     (4096) Dispatchable
// GUID:      {2DE60319-A782-4CE8-B6A8-71529FDB10C7}
// *********************************************************************//
  IInfoQuery = dispinterface
    ['{2DE60319-A782-4CE8-B6A8-71529FDB10C7}']
    function QueryByTemplate(const Template: WideString): IDispatch; dispid 100;
  end;

// *********************************************************************//
// DispIntf:  IInfoQueryResultsSet
// Flags:     (4096) Dispatchable
// GUID:      {BED5D04F-5C9E-4A32-82DE-1FB9E47DC7E8}
// *********************************************************************//
  IInfoQueryResultsSet = dispinterface
    ['{BED5D04F-5C9E-4A32-82DE-1FB9E47DC7E8}']
    function GetResultsCount: LongWord; dispid 100;
    function GetResult(Index: LongWord): IDispatch; dispid 200;
    function StartEnumeration: WordBool; dispid 500;
    function GetNextResult: IDispatch; dispid 600;
  end;

// *********************************************************************//
// DispIntf:  IInfoQueryResult
// Flags:     (4096) Dispatchable
// GUID:      {570CA1BD-1788-4F4C-8C57-35E694C1572C}
// *********************************************************************//
  IInfoQueryResult = dispinterface
    ['{570CA1BD-1788-4F4C-8C57-35E694C1572C}']
    function GetInfoType: LongWord; dispid 100;
    function GetTitle: WideString; dispid 200;
    function GetPosition: IDispatch; dispid 300;
    function GetInformation: IDispatch; dispid 400;
    function GetFullAddress: IFontDisp; dispid 500;
    function GetCategory: WideString; dispid 600;
  end;

// *********************************************************************//
// DispIntf:  IDistricts
// Flags:     (4096) Dispatchable
// GUID:      {FE8B14C3-DBF1-4A47-A355-71B57F752F0F}
// *********************************************************************//
  IDistricts = dispinterface
    ['{FE8B14C3-DBF1-4A47-A355-71B57F752F0F}']
    function GetCount: LongWord; dispid 100;
    function GetDistrictByIndex(Index: LongWord): IDispatch; dispid 200;
    function LocateByGeoPoint(LatRad: Double; LonRad: Double): Integer; dispid 300;
  end;

// *********************************************************************//
// DispIntf:  IDistrict
// Flags:     (4096) Dispatchable
// GUID:      {3833A22E-EC65-4963-A0F1-B80F1A896ACF}
// *********************************************************************//
  IDistrict = dispinterface
    ['{3833A22E-EC65-4963-A0F1-B80F1A896ACF}']
    function GetName: WideString; dispid 100;
    function GetGeoArea: IDispatch; dispid 200;
    function GetGeoPoints: OleVariant; dispid 300;
  end;

// *********************************************************************//
// DispIntf:  IDistrictTypes
// Flags:     (4096) Dispatchable
// GUID:      {472E5C80-AE6C-4914-B6B9-EC97C40CBF64}
// *********************************************************************//
  IDistrictTypes = dispinterface
    ['{472E5C80-AE6C-4914-B6B9-EC97C40CBF64}']
    function GetTypesCount: LongWord; dispid 100;
    function GetTypeByIndex(Index: LongWord): Integer; dispid 200;
  end;

// *********************************************************************//
// The Class CoCityGuideUser provides a Create and CreateRemote method to          
// create instances of the default interface ICityGuideUser exposed by              
// the CoClass CityGuideUser. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCityGuideUser = class
    class function Create: ICityGuideUser;
    class function CreateRemote(const MachineName: string): ICityGuideUser;
  end;

// *********************************************************************//
// The Class CoEngine provides a Create and CreateRemote method to          
// create instances of the default interface IEngine exposed by              
// the CoClass Engine. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoEngine = class
    class function Create: IEngine;
    class function CreateRemote(const MachineName: string): IEngine;
  end;

// *********************************************************************//
// The Class CoMapView provides a Create and CreateRemote method to          
// create instances of the default interface IMapView exposed by              
// the CoClass MapView. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoMapView = class
    class function Create: IMapView;
    class function CreateRemote(const MachineName: string): IMapView;
  end;

// *********************************************************************//
// The Class CoProjection provides a Create and CreateRemote method to          
// create instances of the default interface IProjection exposed by              
// the CoClass Projection. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoProjection = class
    class function Create: IProjection;
    class function CreateRemote(const MachineName: string): IProjection;
  end;

// *********************************************************************//
// The Class CoCatalog provides a Create and CreateRemote method to          
// create instances of the default interface ICatalog exposed by              
// the CoClass Catalog. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCatalog = class
    class function Create: ICatalog;
    class function CreateRemote(const MachineName: string): ICatalog;
  end;

// *********************************************************************//
// The Class CoChart provides a Create and CreateRemote method to          
// create instances of the default interface IChart exposed by              
// the CoClass Chart. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoChart = class
    class function Create: IChart;
    class function CreateRemote(const MachineName: string): IChart;
  end;

// *********************************************************************//
// The Class CoJams provides a Create and CreateRemote method to          
// create instances of the default interface IJams exposed by              
// the CoClass Jams. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoJams = class
    class function Create: IJams;
    class function CreateRemote(const MachineName: string): IJams;
  end;

// *********************************************************************//
// The Class CoRoute provides a Create and CreateRemote method to          
// create instances of the default interface IRoute exposed by              
// the CoClass Route. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRoute = class
    class function Create: IRoute;
    class function CreateRemote(const MachineName: string): IRoute;
  end;

// *********************************************************************//
// The Class CoRouteParameters provides a Create and CreateRemote method to          
// create instances of the default interface IRouteParameters exposed by              
// the CoClass RouteParameters. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRouteParameters = class
    class function Create: IRouteParameters;
    class function CreateRemote(const MachineName: string): IRouteParameters;
  end;

// *********************************************************************//
// The Class CoRouteInfo provides a Create and CreateRemote method to          
// create instances of the default interface IRouteInfo exposed by              
// the CoClass RouteInfo. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRouteInfo = class
    class function Create: IRouteInfo;
    class function CreateRemote(const MachineName: string): IRouteInfo;
  end;

// *********************************************************************//
// The Class CoRoutePointInfo provides a Create and CreateRemote method to          
// create instances of the default interface IRoutePointInfo exposed by              
// the CoClass RoutePointInfo. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRoutePointInfo = class
    class function Create: IRoutePointInfo;
    class function CreateRemote(const MachineName: string): IRoutePointInfo;
  end;

// *********************************************************************//
// The Class CoGeoQueryInfo provides a Create and CreateRemote method to          
// create instances of the default interface IGeoQueryInfo exposed by              
// the CoClass GeoQueryInfo. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoGeoQueryInfo = class
    class function Create: IGeoQueryInfo;
    class function CreateRemote(const MachineName: string): IGeoQueryInfo;
  end;

// *********************************************************************//
// The Class CoAddressInfo provides a Create and CreateRemote method to          
// create instances of the default interface IAddressInfo exposed by              
// the CoClass AddressInfo. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoAddressInfo = class
    class function Create: IAddressInfo;
    class function CreateRemote(const MachineName: string): IAddressInfo;
  end;

// *********************************************************************//
// The Class CoSettlementsInfo provides a Create and CreateRemote method to          
// create instances of the default interface ISettlementsInfo exposed by              
// the CoClass SettlementsInfo. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSettlementsInfo = class
    class function Create: ISettlementsInfo;
    class function CreateRemote(const MachineName: string): ISettlementsInfo;
  end;

// *********************************************************************//
// The Class CoPoiType provides a Create and CreateRemote method to          
// create instances of the default interface IPoiType exposed by              
// the CoClass PoiType. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPoiType = class
    class function Create: IPoiType;
    class function CreateRemote(const MachineName: string): IPoiType;
  end;

// *********************************************************************//
// The Class CoPoiTypes provides a Create and CreateRemote method to          
// create instances of the default interface IPoiTypes exposed by              
// the CoClass PoiTypes. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPoiTypes = class
    class function Create: IPoiTypes;
    class function CreateRemote(const MachineName: string): IPoiTypes;
  end;

// *********************************************************************//
// The Class CoPoiInfos provides a Create and CreateRemote method to          
// create instances of the default interface IPoiInfos exposed by              
// the CoClass PoiInfos. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPoiInfos = class
    class function Create: IPoiInfos;
    class function CreateRemote(const MachineName: string): IPoiInfos;
  end;

// *********************************************************************//
// The Class CoPoiInfo provides a Create and CreateRemote method to          
// create instances of the default interface IPoiInfo exposed by              
// the CoClass PoiInfo. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPoiInfo = class
    class function Create: IPoiInfo;
    class function CreateRemote(const MachineName: string): IPoiInfo;
  end;

// *********************************************************************//
// The Class CoInfoLevels provides a Create and CreateRemote method to          
// create instances of the default interface IInfoLevels exposed by              
// the CoClass InfoLevels. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoInfoLevels = class
    class function Create: IInfoLevels;
    class function CreateRemote(const MachineName: string): IInfoLevels;
  end;

// *********************************************************************//
// The Class CoCrossroadsInfo provides a Create and CreateRemote method to          
// create instances of the default interface ICrossroadsInfo exposed by              
// the CoClass CrossroadsInfo. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCrossroadsInfo = class
    class function Create: ICrossroadsInfo;
    class function CreateRemote(const MachineName: string): ICrossroadsInfo;
  end;

// *********************************************************************//
// The Class CoContextSettings provides a Create and CreateRemote method to          
// create instances of the default interface IContextSettings exposed by              
// the CoClass ContextSettings. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoContextSettings = class
    class function Create: IContextSettings;
    class function CreateRemote(const MachineName: string): IContextSettings;
  end;

// *********************************************************************//
// The Class CoUserObject provides a Create and CreateRemote method to          
// create instances of the default interface IUserObject exposed by              
// the CoClass UserObject. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUserObject = class
    class function Create: IUserObject;
    class function CreateRemote(const MachineName: string): IUserObject;
  end;

// *********************************************************************//
// The Class CoUserObjectLocator provides a Create and CreateRemote method to          
// create instances of the default interface IUserObjectLocator exposed by              
// the CoClass UserObjectLocator. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUserObjectLocator = class
    class function Create: IUserObjectLocator;
    class function CreateRemote(const MachineName: string): IUserObjectLocator;
  end;

// *********************************************************************//
// The Class CoUserObjectGeometry provides a Create and CreateRemote method to          
// create instances of the default interface IUserObjectGeometry exposed by              
// the CoClass UserObjectGeometry. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUserObjectGeometry = class
    class function Create: IUserObjectGeometry;
    class function CreateRemote(const MachineName: string): IUserObjectGeometry;
  end;

// *********************************************************************//
// The Class CoUserObjectText provides a Create and CreateRemote method to          
// create instances of the default interface IUserObjectText exposed by              
// the CoClass UserObjectText. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUserObjectText = class
    class function Create: IUserObjectText;
    class function CreateRemote(const MachineName: string): IUserObjectText;
  end;

// *********************************************************************//
// The Class CoUserObjectEmpty provides a Create and CreateRemote method to          
// create instances of the default interface IUserObjectEmpty exposed by              
// the CoClass UserObjectEmpty. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUserObjectEmpty = class
    class function Create: IUserObjectEmpty;
    class function CreateRemote(const MachineName: string): IUserObjectEmpty;
  end;

// *********************************************************************//
// The Class CoUserObjectBoxed provides a Create and CreateRemote method to          
// create instances of the default interface IUserObjectBoxed exposed by              
// the CoClass UserObjectBoxed. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUserObjectBoxed = class
    class function Create: IUserObjectBoxed;
    class function CreateRemote(const MachineName: string): IUserObjectBoxed;
  end;

// *********************************************************************//
// The Class CoUserObjectPicture provides a Create and CreateRemote method to          
// create instances of the default interface IUserObjectPicture exposed by              
// the CoClass UserObjectPicture. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUserObjectPicture = class
    class function Create: IUserObjectPicture;
    class function CreateRemote(const MachineName: string): IUserObjectPicture;
  end;

// *********************************************************************//
// The Class CoUserObjectLine provides a Create and CreateRemote method to          
// create instances of the default interface IUserObjectLine exposed by              
// the CoClass UserObjectLine. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUserObjectLine = class
    class function Create: IUserObjectLine;
    class function CreateRemote(const MachineName: string): IUserObjectLine;
  end;

// *********************************************************************//
// The Class CoUserObjectPolygon provides a Create and CreateRemote method to          
// create instances of the default interface IUserObjectPolygon exposed by              
// the CoClass UserObjectPolygon. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUserObjectPolygon = class
    class function Create: IUserObjectPolygon;
    class function CreateRemote(const MachineName: string): IUserObjectPolygon;
  end;

// *********************************************************************//
// The Class CoUserObjectExtraParameters provides a Create and CreateRemote method to          
// create instances of the default interface IUserObjectExtraParameters exposed by              
// the CoClass UserObjectExtraParameters. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUserObjectExtraParameters = class
    class function Create: IUserObjectExtraParameters;
    class function CreateRemote(const MachineName: string): IUserObjectExtraParameters;
  end;

// *********************************************************************//
// The Class CoUserObjectsContainer provides a Create and CreateRemote method to          
// create instances of the default interface IUserObjectsContainer exposed by              
// the CoClass UserObjectsContainer. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUserObjectsContainer = class
    class function Create: IUserObjectsContainer;
    class function CreateRemote(const MachineName: string): IUserObjectsContainer;
  end;

// *********************************************************************//
// The Class CoHighlighter provides a Create and CreateRemote method to          
// create instances of the default interface IHighlighter exposed by              
// the CoClass Highlighter. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoHighlighter = class
    class function Create: IHighlighter;
    class function CreateRemote(const MachineName: string): IHighlighter;
  end;

// *********************************************************************//
// The Class CoGeoPoint provides a Create and CreateRemote method to          
// create instances of the default interface IGeoPoint exposed by              
// the CoClass GeoPoint. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoGeoPoint = class
    class function Create: IGeoPoint;
    class function CreateRemote(const MachineName: string): IGeoPoint;
  end;

// *********************************************************************//
// The Class CoGeoArea provides a Create and CreateRemote method to          
// create instances of the default interface IGeoArea exposed by              
// the CoClass GeoArea. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoGeoArea = class
    class function Create: IGeoArea;
    class function CreateRemote(const MachineName: string): IGeoArea;
  end;

// *********************************************************************//
// The Class CoScrPoint provides a Create and CreateRemote method to          
// create instances of the default interface IScrPoint exposed by              
// the CoClass ScrPoint. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoScrPoint = class
    class function Create: IScrPoint;
    class function CreateRemote(const MachineName: string): IScrPoint;
  end;

// *********************************************************************//
// The Class CoCoordinateConverter provides a Create and CreateRemote method to          
// create instances of the default interface ICoordinateConverter exposed by              
// the CoClass CoordinateConverter. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCoordinateConverter = class
    class function Create: ICoordinateConverter;
    class function CreateRemote(const MachineName: string): ICoordinateConverter;
  end;

// *********************************************************************//
// The Class CoGeoDataUser provides a Create and CreateRemote method to          
// create instances of the default interface IGeoDataUser exposed by              
// the CoClass GeoDataUser. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoGeoDataUser = class
    class function Create: IGeoDataUser;
    class function CreateRemote(const MachineName: string): IGeoDataUser;
  end;

// *********************************************************************//
// The Class CoComUtils provides a Create and CreateRemote method to          
// create instances of the default interface IComUtils exposed by              
// the CoClass ComUtils. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoComUtils = class
    class function Create: IComUtils;
    class function CreateRemote(const MachineName: string): IComUtils;
  end;

// *********************************************************************//
// The Class CoLibraryInfo provides a Create and CreateRemote method to          
// create instances of the default interface ILibraryInfo exposed by              
// the CoClass LibraryInfo. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoLibraryInfo = class
    class function Create: ILibraryInfo;
    class function CreateRemote(const MachineName: string): ILibraryInfo;
  end;

// *********************************************************************//
// The Class CoFullAddress provides a Create and CreateRemote method to          
// create instances of the default interface IFullAddress exposed by              
// the CoClass FullAddress. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFullAddress = class
    class function Create: IFullAddress;
    class function CreateRemote(const MachineName: string): IFullAddress;
  end;

// *********************************************************************//
// The Class CoCgSdkLocalCreator provides a Create and CreateRemote method to          
// create instances of the default interface ICgSdkLocalCreator exposed by              
// the CoClass CgSdkLocalCreator. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCgSdkLocalCreator = class
    class function Create: ICgSdkLocalCreator;
    class function CreateRemote(const MachineName: string): ICgSdkLocalCreator;
  end;

// *********************************************************************//
// The Class CoInfoQuery provides a Create and CreateRemote method to          
// create instances of the default interface IInfoQuery exposed by              
// the CoClass InfoQuery. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoInfoQuery = class
    class function Create: IInfoQuery;
    class function CreateRemote(const MachineName: string): IInfoQuery;
  end;

// *********************************************************************//
// The Class CoInfoQueryResultsSet provides a Create and CreateRemote method to          
// create instances of the default interface IInfoQueryResultsSet exposed by              
// the CoClass InfoQueryResultsSet. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoInfoQueryResultsSet = class
    class function Create: IInfoQueryResultsSet;
    class function CreateRemote(const MachineName: string): IInfoQueryResultsSet;
  end;

// *********************************************************************//
// The Class CoInfoQueryResult provides a Create and CreateRemote method to          
// create instances of the default interface IInfoQueryResult exposed by              
// the CoClass InfoQueryResult. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoInfoQueryResult = class
    class function Create: IInfoQueryResult;
    class function CreateRemote(const MachineName: string): IInfoQueryResult;
  end;

// *********************************************************************//
// The Class CoDistricts provides a Create and CreateRemote method to          
// create instances of the default interface IDistricts exposed by              
// the CoClass Districts. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDistricts = class
    class function Create: IDistricts;
    class function CreateRemote(const MachineName: string): IDistricts;
  end;

// *********************************************************************//
// The Class CoDistrict provides a Create and CreateRemote method to          
// create instances of the default interface IDistrict exposed by              
// the CoClass District. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDistrict = class
    class function Create: IDistrict;
    class function CreateRemote(const MachineName: string): IDistrict;
  end;

// *********************************************************************//
// The Class CoDistrictTypes provides a Create and CreateRemote method to          
// create instances of the default interface IDistrictTypes exposed by              
// the CoClass DistrictTypes. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDistrictTypes = class
    class function Create: IDistrictTypes;
    class function CreateRemote(const MachineName: string): IDistrictTypes;
  end;

implementation

uses System.Win.ComObj;

class function CoCityGuideUser.Create: ICityGuideUser;
begin
  Result := CreateComObject(CLASS_CityGuideUser) as ICityGuideUser;
end;

class function CoCityGuideUser.CreateRemote(const MachineName: string): ICityGuideUser;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CityGuideUser) as ICityGuideUser;
end;

class function CoEngine.Create: IEngine;
begin
  Result := CreateComObject(CLASS_Engine) as IEngine;
end;

class function CoEngine.CreateRemote(const MachineName: string): IEngine;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Engine) as IEngine;
end;

class function CoMapView.Create: IMapView;
begin
  Result := CreateComObject(CLASS_MapView) as IMapView;
end;

class function CoMapView.CreateRemote(const MachineName: string): IMapView;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_MapView) as IMapView;
end;

class function CoProjection.Create: IProjection;
begin
  Result := CreateComObject(CLASS_Projection) as IProjection;
end;

class function CoProjection.CreateRemote(const MachineName: string): IProjection;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Projection) as IProjection;
end;

class function CoCatalog.Create: ICatalog;
begin
  Result := CreateComObject(CLASS_Catalog) as ICatalog;
end;

class function CoCatalog.CreateRemote(const MachineName: string): ICatalog;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Catalog) as ICatalog;
end;

class function CoChart.Create: IChart;
begin
  Result := CreateComObject(CLASS_Chart) as IChart;
end;

class function CoChart.CreateRemote(const MachineName: string): IChart;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Chart) as IChart;
end;

class function CoJams.Create: IJams;
begin
  Result := CreateComObject(CLASS_Jams) as IJams;
end;

class function CoJams.CreateRemote(const MachineName: string): IJams;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Jams) as IJams;
end;

class function CoRoute.Create: IRoute;
begin
  Result := CreateComObject(CLASS_Route) as IRoute;
end;

class function CoRoute.CreateRemote(const MachineName: string): IRoute;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Route) as IRoute;
end;

class function CoRouteParameters.Create: IRouteParameters;
begin
  Result := CreateComObject(CLASS_RouteParameters) as IRouteParameters;
end;

class function CoRouteParameters.CreateRemote(const MachineName: string): IRouteParameters;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RouteParameters) as IRouteParameters;
end;

class function CoRouteInfo.Create: IRouteInfo;
begin
  Result := CreateComObject(CLASS_RouteInfo) as IRouteInfo;
end;

class function CoRouteInfo.CreateRemote(const MachineName: string): IRouteInfo;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RouteInfo) as IRouteInfo;
end;

class function CoRoutePointInfo.Create: IRoutePointInfo;
begin
  Result := CreateComObject(CLASS_RoutePointInfo) as IRoutePointInfo;
end;

class function CoRoutePointInfo.CreateRemote(const MachineName: string): IRoutePointInfo;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RoutePointInfo) as IRoutePointInfo;
end;

class function CoGeoQueryInfo.Create: IGeoQueryInfo;
begin
  Result := CreateComObject(CLASS_GeoQueryInfo) as IGeoQueryInfo;
end;

class function CoGeoQueryInfo.CreateRemote(const MachineName: string): IGeoQueryInfo;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_GeoQueryInfo) as IGeoQueryInfo;
end;

class function CoAddressInfo.Create: IAddressInfo;
begin
  Result := CreateComObject(CLASS_AddressInfo) as IAddressInfo;
end;

class function CoAddressInfo.CreateRemote(const MachineName: string): IAddressInfo;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_AddressInfo) as IAddressInfo;
end;

class function CoSettlementsInfo.Create: ISettlementsInfo;
begin
  Result := CreateComObject(CLASS_SettlementsInfo) as ISettlementsInfo;
end;

class function CoSettlementsInfo.CreateRemote(const MachineName: string): ISettlementsInfo;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SettlementsInfo) as ISettlementsInfo;
end;

class function CoPoiType.Create: IPoiType;
begin
  Result := CreateComObject(CLASS_PoiType) as IPoiType;
end;

class function CoPoiType.CreateRemote(const MachineName: string): IPoiType;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PoiType) as IPoiType;
end;

class function CoPoiTypes.Create: IPoiTypes;
begin
  Result := CreateComObject(CLASS_PoiTypes) as IPoiTypes;
end;

class function CoPoiTypes.CreateRemote(const MachineName: string): IPoiTypes;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PoiTypes) as IPoiTypes;
end;

class function CoPoiInfos.Create: IPoiInfos;
begin
  Result := CreateComObject(CLASS_PoiInfos) as IPoiInfos;
end;

class function CoPoiInfos.CreateRemote(const MachineName: string): IPoiInfos;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PoiInfos) as IPoiInfos;
end;

class function CoPoiInfo.Create: IPoiInfo;
begin
  Result := CreateComObject(CLASS_PoiInfo) as IPoiInfo;
end;

class function CoPoiInfo.CreateRemote(const MachineName: string): IPoiInfo;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PoiInfo) as IPoiInfo;
end;

class function CoInfoLevels.Create: IInfoLevels;
begin
  Result := CreateComObject(CLASS_InfoLevels) as IInfoLevels;
end;

class function CoInfoLevels.CreateRemote(const MachineName: string): IInfoLevels;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_InfoLevels) as IInfoLevels;
end;

class function CoCrossroadsInfo.Create: ICrossroadsInfo;
begin
  Result := CreateComObject(CLASS_CrossroadsInfo) as ICrossroadsInfo;
end;

class function CoCrossroadsInfo.CreateRemote(const MachineName: string): ICrossroadsInfo;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CrossroadsInfo) as ICrossroadsInfo;
end;

class function CoContextSettings.Create: IContextSettings;
begin
  Result := CreateComObject(CLASS_ContextSettings) as IContextSettings;
end;

class function CoContextSettings.CreateRemote(const MachineName: string): IContextSettings;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ContextSettings) as IContextSettings;
end;

class function CoUserObject.Create: IUserObject;
begin
  Result := CreateComObject(CLASS_UserObject) as IUserObject;
end;

class function CoUserObject.CreateRemote(const MachineName: string): IUserObject;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UserObject) as IUserObject;
end;

class function CoUserObjectLocator.Create: IUserObjectLocator;
begin
  Result := CreateComObject(CLASS_UserObjectLocator) as IUserObjectLocator;
end;

class function CoUserObjectLocator.CreateRemote(const MachineName: string): IUserObjectLocator;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UserObjectLocator) as IUserObjectLocator;
end;

class function CoUserObjectGeometry.Create: IUserObjectGeometry;
begin
  Result := CreateComObject(CLASS_UserObjectGeometry) as IUserObjectGeometry;
end;

class function CoUserObjectGeometry.CreateRemote(const MachineName: string): IUserObjectGeometry;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UserObjectGeometry) as IUserObjectGeometry;
end;

class function CoUserObjectText.Create: IUserObjectText;
begin
  Result := CreateComObject(CLASS_UserObjectText) as IUserObjectText;
end;

class function CoUserObjectText.CreateRemote(const MachineName: string): IUserObjectText;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UserObjectText) as IUserObjectText;
end;

class function CoUserObjectEmpty.Create: IUserObjectEmpty;
begin
  Result := CreateComObject(CLASS_UserObjectEmpty) as IUserObjectEmpty;
end;

class function CoUserObjectEmpty.CreateRemote(const MachineName: string): IUserObjectEmpty;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UserObjectEmpty) as IUserObjectEmpty;
end;

class function CoUserObjectBoxed.Create: IUserObjectBoxed;
begin
  Result := CreateComObject(CLASS_UserObjectBoxed) as IUserObjectBoxed;
end;

class function CoUserObjectBoxed.CreateRemote(const MachineName: string): IUserObjectBoxed;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UserObjectBoxed) as IUserObjectBoxed;
end;

class function CoUserObjectPicture.Create: IUserObjectPicture;
begin
  Result := CreateComObject(CLASS_UserObjectPicture) as IUserObjectPicture;
end;

class function CoUserObjectPicture.CreateRemote(const MachineName: string): IUserObjectPicture;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UserObjectPicture) as IUserObjectPicture;
end;

class function CoUserObjectLine.Create: IUserObjectLine;
begin
  Result := CreateComObject(CLASS_UserObjectLine) as IUserObjectLine;
end;

class function CoUserObjectLine.CreateRemote(const MachineName: string): IUserObjectLine;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UserObjectLine) as IUserObjectLine;
end;

class function CoUserObjectPolygon.Create: IUserObjectPolygon;
begin
  Result := CreateComObject(CLASS_UserObjectPolygon) as IUserObjectPolygon;
end;

class function CoUserObjectPolygon.CreateRemote(const MachineName: string): IUserObjectPolygon;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UserObjectPolygon) as IUserObjectPolygon;
end;

class function CoUserObjectExtraParameters.Create: IUserObjectExtraParameters;
begin
  Result := CreateComObject(CLASS_UserObjectExtraParameters) as IUserObjectExtraParameters;
end;

class function CoUserObjectExtraParameters.CreateRemote(const MachineName: string): IUserObjectExtraParameters;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UserObjectExtraParameters) as IUserObjectExtraParameters;
end;

class function CoUserObjectsContainer.Create: IUserObjectsContainer;
begin
  Result := CreateComObject(CLASS_UserObjectsContainer) as IUserObjectsContainer;
end;

class function CoUserObjectsContainer.CreateRemote(const MachineName: string): IUserObjectsContainer;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UserObjectsContainer) as IUserObjectsContainer;
end;

class function CoHighlighter.Create: IHighlighter;
begin
  Result := CreateComObject(CLASS_Highlighter) as IHighlighter;
end;

class function CoHighlighter.CreateRemote(const MachineName: string): IHighlighter;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Highlighter) as IHighlighter;
end;

class function CoGeoPoint.Create: IGeoPoint;
begin
  Result := CreateComObject(CLASS_GeoPoint) as IGeoPoint;
end;

class function CoGeoPoint.CreateRemote(const MachineName: string): IGeoPoint;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_GeoPoint) as IGeoPoint;
end;

class function CoGeoArea.Create: IGeoArea;
begin
  Result := CreateComObject(CLASS_GeoArea) as IGeoArea;
end;

class function CoGeoArea.CreateRemote(const MachineName: string): IGeoArea;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_GeoArea) as IGeoArea;
end;

class function CoScrPoint.Create: IScrPoint;
begin
  Result := CreateComObject(CLASS_ScrPoint) as IScrPoint;
end;

class function CoScrPoint.CreateRemote(const MachineName: string): IScrPoint;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ScrPoint) as IScrPoint;
end;

class function CoCoordinateConverter.Create: ICoordinateConverter;
begin
  Result := CreateComObject(CLASS_CoordinateConverter) as ICoordinateConverter;
end;

class function CoCoordinateConverter.CreateRemote(const MachineName: string): ICoordinateConverter;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CoordinateConverter) as ICoordinateConverter;
end;

class function CoGeoDataUser.Create: IGeoDataUser;
begin
  Result := CreateComObject(CLASS_GeoDataUser) as IGeoDataUser;
end;

class function CoGeoDataUser.CreateRemote(const MachineName: string): IGeoDataUser;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_GeoDataUser) as IGeoDataUser;
end;

class function CoComUtils.Create: IComUtils;
begin
  Result := CreateComObject(CLASS_ComUtils) as IComUtils;
end;

class function CoComUtils.CreateRemote(const MachineName: string): IComUtils;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ComUtils) as IComUtils;
end;

class function CoLibraryInfo.Create: ILibraryInfo;
begin
  Result := CreateComObject(CLASS_LibraryInfo) as ILibraryInfo;
end;

class function CoLibraryInfo.CreateRemote(const MachineName: string): ILibraryInfo;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_LibraryInfo) as ILibraryInfo;
end;

class function CoFullAddress.Create: IFullAddress;
begin
  Result := CreateComObject(CLASS_FullAddress) as IFullAddress;
end;

class function CoFullAddress.CreateRemote(const MachineName: string): IFullAddress;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FullAddress) as IFullAddress;
end;

class function CoCgSdkLocalCreator.Create: ICgSdkLocalCreator;
begin
  Result := CreateComObject(CLASS_CgSdkLocalCreator) as ICgSdkLocalCreator;
end;

class function CoCgSdkLocalCreator.CreateRemote(const MachineName: string): ICgSdkLocalCreator;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CgSdkLocalCreator) as ICgSdkLocalCreator;
end;

class function CoInfoQuery.Create: IInfoQuery;
begin
  Result := CreateComObject(CLASS_InfoQuery) as IInfoQuery;
end;

class function CoInfoQuery.CreateRemote(const MachineName: string): IInfoQuery;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_InfoQuery) as IInfoQuery;
end;

class function CoInfoQueryResultsSet.Create: IInfoQueryResultsSet;
begin
  Result := CreateComObject(CLASS_InfoQueryResultsSet) as IInfoQueryResultsSet;
end;

class function CoInfoQueryResultsSet.CreateRemote(const MachineName: string): IInfoQueryResultsSet;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_InfoQueryResultsSet) as IInfoQueryResultsSet;
end;

class function CoInfoQueryResult.Create: IInfoQueryResult;
begin
  Result := CreateComObject(CLASS_InfoQueryResult) as IInfoQueryResult;
end;

class function CoInfoQueryResult.CreateRemote(const MachineName: string): IInfoQueryResult;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_InfoQueryResult) as IInfoQueryResult;
end;

class function CoDistricts.Create: IDistricts;
begin
  Result := CreateComObject(CLASS_Districts) as IDistricts;
end;

class function CoDistricts.CreateRemote(const MachineName: string): IDistricts;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Districts) as IDistricts;
end;

class function CoDistrict.Create: IDistrict;
begin
  Result := CreateComObject(CLASS_District) as IDistrict;
end;

class function CoDistrict.CreateRemote(const MachineName: string): IDistrict;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_District) as IDistrict;
end;

class function CoDistrictTypes.Create: IDistrictTypes;
begin
  Result := CreateComObject(CLASS_DistrictTypes) as IDistrictTypes;
end;

class function CoDistrictTypes.CreateRemote(const MachineName: string): IDistrictTypes;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_DistrictTypes) as IDistrictTypes;
end;

end.
