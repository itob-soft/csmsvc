unit Compressor;

interface

function CompressFile(FileName, CompressedFileName: string): boolean;
function DecompressFile(FileName, DecompressedFileName: string): boolean;

implementation

uses SysUtils, ZLib, Classes;

const buffer_size: integer = 1024;

function CompressFile(FileName, CompressedFileName: string): boolean;
var
  source,dest:TFileStream;//поток-источноик, поток-приЄмник
  CompresSstream:TCompressionStream;    // поток Ц архиватор
  bytesread:integer;
  mainbuffer:array[0..1023] of char; // буфер
begin

  Result := false;

  source := TFileStream.Create(FileName,fmOpenRead);   // создаЄм поток Ц источник
  dest := TFileStream.Create(CompressedFileName, fmCreate); // создаЄм поток Ц приЄмник
  CompresSstream:=TCompressionStream.Create(clMax,dest);// создаЄм поток Ц архиватор c                   //          максимальной степенью сжати€

  try                // Ќј ¬—я »… ѕќ∆ј–Ќџ…
     repeat
        bytesread:=source.Read(mainbuffer, buffer_size);    // считываем из источника в буфер
        CompresSstream.Write(mainbuffer,bytesread);     //   записываем из буфера в поток Ц архиватор
     until bytesread<1024;   // всЄ это до тех пор пока весь источник не будет считан
  except    //   если всЄ же возникнет кака€-нибудь оЅшибка!!!
     CompresSstream.free;
     source.Free;
     dest.Free;
     exit;
  end;   // всЄ прошло успешно

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
