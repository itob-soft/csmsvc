program TestCsmSvc;

uses
  SimpleShareMem,
  Forms,
  UnitFrmTest in 'UnitFrmTest.pas' {Form1},
  CsmSvcHandlier in '..\CsmSvcHandlier.pas',
  ImcsUtils in '..\ImcsUtils.pas',
  Compressor in '..\Compressor.pas',
  uIHTSConst in '..\TileServer\uIHTSConst.pas',
  uFileSaver in '..\TileServer\uFileSaver.pas',
  uTileServer in '..\TileServer\uTileServer.pas',
  SQLite3 in '..\sqlite\SQLite3.pas',
  SQLite3Utils in '..\sqlite\SQLite3Utils.pas',
  SQLite3Wrap in '..\sqlite\SQLite3Wrap.pas',
  ActiveX,
  frmIngit in '..\Services\INGIT\frmIngit.pas' {frIngit},
  uCSM_INGITServer in '..\Services\INGIT\uCSM_INGITServer.pas',
  uINGITPoole in '..\Services\INGIT\uINGITPoole.pas',
  uLengthCounter in '..\Services\INGIT\uLengthCounter.pas',
  uCGTS_Server in '..\Services\CGTS\core\uCGTS_Server.pas',
  uCGTS_ServerConst in '..\Services\CGTS\core\uCGTS_ServerConst.pas',
  CityGuideSDK_TLB in '..\com\CityGuideSDK_TLB.pas',
  uINGITConst in '..\..\imcs_sdk\source\CommonSDK\coreServ\uINGITConst.pas',
  uRotesUtils in '..\..\imcs_sdk\source\CommonSDK\coreServ\uRotesUtils.pas',
  superdate in '..\..\imcs_sdk\source\superobject\superdate.pas',
  superobject in '..\..\imcs_sdk\source\superobject\superobject.pas',
  supertimezone in '..\..\imcs_sdk\source\superobject\supertimezone.pas',
  supertypes in '..\..\imcs_sdk\source\superobject\supertypes.pas',
  superxmlparser in '..\..\imcs_sdk\source\superobject\superxmlparser.pas';

{$R *.res}

begin
  CoInitialize(nil);
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrIngit, frIngit);
  Application.Run;
//  CoUninitialize();
end.
