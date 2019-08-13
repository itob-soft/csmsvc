program CGTS;

uses
  SvcMgr,
  uCGTSMain in 'forms\uCGTSMain.pas' {CGTS_1_0: TService},
  uCGTS_ServerConst in 'core\uCGTS_ServerConst.pas',
  uCGTS_Server in 'core\uCGTS_Server.pas',
  uINGITConst in '..\..\utils\IIPS_App\core\uINGITConst.pas',
  uAdds in '..\..\utils\IIPS_App\core\uAdds.pas',
  CityGuideSDK_TLB in '..\..\lib\CityGuideSDK_TLB.pas';

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
  Application.CreateForm(TCGTS_1_0, CGTS_1_0);
  Application.Run;
end.
