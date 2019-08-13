program CsmSvc;

uses
  SimpleShareMem,
  SvcMgr,
  UnitService in 'UnitService.pas' {CsmService: TService},
  CsmSvcHandlier in 'CsmSvcHandlier.pas',
  ImcsUtils in 'ImcsUtils.pas',
  Compressor in 'Compressor.pas',
  uTileServer in 'TileServer\uTileServer.pas',
  uFileSaver in 'TileServer\uFileSaver.pas',
  uIHTSConst in 'TileServer\uIHTSConst.pas',
  SQLite3 in 'sqlite\SQLite3.pas',
  SQLite3Utils in 'sqlite\SQLite3Utils.pas',
  SQLite3Wrap in 'sqlite\SQLite3Wrap.pas',
  ActiveX,
  frmIngit in 'Services\INGIT\frmIngit.pas' {frIngit},
  uCSM_INGITServer in 'Services\INGIT\uCSM_INGITServer.pas',
  uINGITPoole in 'Services\INGIT\uINGITPoole.pas',
  uLengthCounter in 'Services\INGIT\uLengthCounter.pas',
  uCGTS_Server in 'Services\CGTS\core\uCGTS_Server.pas',
  CityGuideControlLib_TLB in 'com\CityGuideControlLib_TLB.pas',
  CityGuideSDK_TLB in 'com\CityGuideSDK_TLB.pas',
  uCGTS_ServerConst in 'Services\CGTS\core\uCGTS_ServerConst.pas',
  superdate in '..\imcs_sdk\source\superobject\superdate.pas',
  superobject in '..\imcs_sdk\source\superobject\superobject.pas',
  supertimezone in '..\imcs_sdk\source\superobject\supertimezone.pas',
  supertypes in '..\imcs_sdk\source\superobject\supertypes.pas',
  superxmlparser in '..\imcs_sdk\source\superobject\superxmlparser.pas';

{$R *.RES}

begin
  // Windows 2003 Server requires StartServiceCtrlDispatcher to be
  // called before CoRegisterClassObject, which can be called indirectly
  // by Application.Initialize. TServiceApplication.DelayInitialize allows
  // Application.Initialize to be called from TService.Main (after
  // StartServiceCtrlDispatcher has been called).
  //
  // Delayed initialization of the Application object may affect
  // events which then occur prior to initialization, such as
  // TService.OnCreate. It is only recommended if the ServiceApplication
  // registers a class object with OLE and is intended for use with
  // Windows 2003 Server.
  //
  // Application.DelayInitialize := True;
  //
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TCsmService, CsmService);
  Application.CreateForm(TfrIngit, frIngit);
  Application.Run;
end.
