unit Compressor;

interface

function CompressFile(FileName, CompressedFileName: string): boolean;
function DecompressFile(FileName, DecompressedFileName: string): boolean;

implementation

uses SysUtils, ZLib, Classes;

const buffer_size: integer = 1024;

function CompressFile(FileName, CompressedFileName: string): boolean;
var
  source,dest:TFileStream;//�����-���������, �����-�������
  CompresSstream:TCompressionStream;    // ����� � ���������
  bytesread:integer;
  mainbuffer:array[0..1023] of char; // �����
begin

  Result := false;

  source := TFileStream.Create(FileName,fmOpenRead);   // ������ ����� � ��������
  dest := TFileStream.Create(CompressedFileName, fmCreate); // ������ ����� � �������
  CompresSstream:=TCompressionStream.Create(clMax,dest);// ������ ����� � ��������� c                   //          ������������ �������� ������

  try                // �� ������ ��������
     repeat
        bytesread:=source.Read(mainbuffer, buffer_size);    // ��������� �� ��������� � �����
        CompresSstream.Write(mainbuffer,bytesread);     //   ���������� �� ������ � ����� � ���������
     until bytesread<1024;   // �� ��� �� ��� ��� ���� ���� �������� �� ����� ������
  except    //   ���� �� �� ��������� �����-������ �������!!!
     CompresSstream.free;
     source.Free;
     dest.Free;
     exit;
  end;   // �� ������ �������

  CompresSstream.free;
  source.Free;
  dest.Free;

  Result := true;

end;

function DecompressFile(FileName, DecompressedFileName: string): boolean;
var
  source,dest:TFileStream;
  decompressStream:TDecompressionStream;
  bytesread:integer;
  mainbuffer:array[0..1023] of char;
begin

  Result := false;

  source := TFileStream.Create(FileName,fmOpenRead);
  dest   := TFileStream.Create(DecompressedFileName,fmCreate);
  decompressStream := TDecompressionStream.Create(source);

  try
     repeat
        bytesread:=decompressStream.Read(mainbuffer,buffer_size);
        dest.Write(mainbuffer,bytesread);
     until bytesread<1024;
  except
     decompressStream.Free;
     source.Free;
     dest.Free;
     exit;
  end;

  decompressStream.Free;
  source.Free;
  dest.Free;

  Result := true;

end;

end.
