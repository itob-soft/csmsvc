program CGTS_App;

uses
  Forms,
  uCGTSAppMain in 'forms\uCGTSAppMain.pas' {Form2},
  uCGTS_Server in 'core\uCGTS_Server.pas',
  uINGITConst in '..\..\utils\IIPS_App\core\uINGITConst.pas',
  uCGTS_ServerConst in 'core\uCGTS_ServerConst.pas',
  uAdds in '..\..\utils\IIPS_App\core\uAdds.pas',
  CityGuideSDK_TLB in '..\..\lib\CityGuideSDK_TLB.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
