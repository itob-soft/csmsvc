unit UnitService;

interface

uses
  CsmSvcHandlier, ImcsUtils,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type
  TCsmService = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    fCsmHandlier: TCsmSvcHandlier;

  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  CsmService: TCsmService;

implementation

uses itob_ext_functions;

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  CsmService.Controller(CtrlCode);
end;

function TCsmService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TCsmService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  fCsmHandlier := TCsmSvcHandlier.Create;
  try
     fCsmHandlier.Start;
     WriteToLog('CsmService started');
  except
     On E: Exception do begin
         WriteToLog('CsmService start error: '+E.Message);
     end;
  end;
end;

procedure TCsmService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  try
     fCsmHandlier.Stop;
     WriteToLog('CsmService stopped');
  except
     On E: Exception do begin
         WriteToLog('CsmService stop error: '+E.Message);
     end;
  end;

end;

end.
