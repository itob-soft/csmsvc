unit uCGTSAppMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer, IniFiles,
  // SELF
  uCGTS_Server, uAdds, uCGTS_ServerConst, StdCtrls;

type
  TForm2 = class(TForm)
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
      pServ : TCGTSServer;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
begin
    pServ.ClearTileDir();
end;
// ----------------------------------------------------------

procedure TForm2.FormCreate(Sender: TObject);
var
    pCGTSIniFile               : TIniFile;
    iPort, iCount              : Integer;
    sMapPath                   : string;
begin
    pCGTSIniFile := TIniFile.Create(GetInstancePath() + S_UTILS_INI_FILE);
    with pCGTSIniFile do
    try
        iCount      := ReadInteger(S_CGTS_ROOT, S_CGTS_COUNT, 10);
        iPort       := ReadInteger(S_CGTS_ROOT, S_CGTS_PORT,  2030);
        sMapPath    := ReadString(S_CGTS_ROOT,  S_IIPS_MAPPATH,   '');
    finally
        FreeAndNil(pCGTSIniFile);
    end;
    pServ := TCGTSServer.Create(sMapPath, GetInstancePath() + 'tiles\', iPort, iCount);
    pServ.Init();
end;
// ----------------------------------------------------------

procedure TForm2.FormDestroy(Sender: TObject);
begin
    FreeAndNil(pServ);
end;
// ----------------------------------------------------------

end.
