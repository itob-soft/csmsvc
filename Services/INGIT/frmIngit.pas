unit frmIngit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GWXLib_TLB, ClipBrd;

type
  TfrIngit = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    fGWControl : TGWControl;
    procedure LocGWControlMouseAction(ASender: TObject; Action: GWX_MouseAction; uMsg: Integer;
      x: Integer; y: Integer; out bHandled: Integer);
  public
    { Public declarations }
    function Init() : Boolean;
    constructor Create(AOwner : TComponent);
    destructor Destroy; override;
    property GWControl : TGWControl read fGWControl;
  end;

var
  frIngit: TfrIngit;

implementation

{$R *.dfm}

{ TfrIngit }

constructor TfrIngit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fGWControl := TGWControl.Create(Self);
  GWControl.Parent := self;
  GWControl.Align := alClient;
  GWControl.Visible := true;
  GWControl.OnMouseAction := LocGWControlMouseAction;
end;

destructor TfrIngit.Destroy;
begin
  fGWControl.Free;
  inherited;
end;

procedure TfrIngit.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

function TfrIngit.Init: Boolean;
begin
    if(WindowState = wsMinimized) then
       WindowState := wsNormal;
    Result := true;
end;

procedure TfrIngit.LocGWControlMouseAction(ASender: TObject;
  Action: GWX_MouseAction; uMsg, x, y: Integer; out bHandled: Integer);
var
  slat, slon : WideString;
begin
  if Action = GWX_LButtonDblClk then begin
    fGWControl.Dev2GeoString(x,y,slat,slon);
    Clipboard.AsText := 'POINT='+slat+';'+slon;
  end;
end;

end.
