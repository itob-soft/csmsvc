unit UnitFrmTest;

interface

uses
  CsmSvcHandlier,
  Compressor,
  itob_points_work,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TeEngine, Series, ExtCtrls, TeeProcs, Chart;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    fCsmHandlier: TCsmSvcHandlier;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation


{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  //

  fCsmHandlier := TCsmSvcHandlier.Create;
  try

     fCsmHandlier.Start;

     //fCsmHandlier.Stop;
  except
     On E: Exception do begin
        ShowMessage(E.Message);

     end;

  end;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  //
  fCsmHandlier.Stop;

end;

procedure TForm1.Button3Click(Sender: TObject);
var Stream: TMemoryStream;
    DataFileVersion: Byte;
    DataFileRecordsCount: Integer;
    i: integer;
    PointsCollection: TPointDataCollection;
    GpsPoint: TPointData;
begin
   //
   DecompressFile('D:\_Temp\GetTerminalData4', 'D:\_Temp\GetTerminalData4.bin');


   PointsCollection := TPointDataCollection.Create;

   Stream := TMemoryStream.Create;
     try
        Stream.LoadFromFile('D:\_Temp\GetTerminalData4.bin');
        Stream.Position := 0;

        Stream.Read(DataFileVersion, SizeOf(Byte));
        Stream.Read(DataFileRecordsCount, SizeOf(Integer));

        for i := 0 to DataFileRecordsCount - 1 do begin
           GpsPoint := TPointData.Create;
           GpsPoint.LoadFromStream(Stream);
           Memo1.Lines.Add(IntToStr(GpsPoint.RecordCounter));
           PointsCollection.Add(GpsPoint);
        end;
     finally
        FreeAndNil(Stream);
     end;

   PointsCollection.Clear;

end;

end.
