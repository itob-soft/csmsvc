unit uCGTSMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs, IniFiles,
  // SELF
  uCGTS_Server, uCGTS_ServerConst, uAdds;

type
  TCGTS_1_0 = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    pServ : TCGTSServer;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  CGTS_1_0: TCGTS_1_0;

implementation

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  CGTS_1_0.Controller(CtrlCode);
end;

function TCGTS_1_0.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TCGTS_1_0.ServiceStart(Sender: TService; var Started: Boolean);
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
// ---------------------------------------------------------------------------
procedure TCGTS_1_0.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
    FreeAndNil(pServ);
end;
// -------------------------------------------------------------------------------

end.
