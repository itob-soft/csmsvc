unit ImcsUtils;

interface
uses SysUtils, Windows, ShellApi, StrUtils, itob_ext_functions;

type
  TFileVersionInfo = record 
    FileType,
    CompanyName,
    FileDescription, 
    FileVersion, 
    InternalName, 
    LegalCopyRight, 
    LegalTradeMarks, 
    OriginalFileName, 
    ProductName, 
    ProductVersion, 
    Comments, 
    SpecialBuildStr, 
    PrivateBuildStr, 
    FileFunction : string; 
    DebugBuild, 
    PreRelease, 
    SpecialBuild, 
    PrivateBuild, 
    Patched, 
    InfoInferred : Boolean; 
  end;

procedure WriteToLog(Text :string);
function GetTempDir: string;
function FileVersion(AFileName: string): string;
function FileVersionInfo(const sAppNamePath: TFileName): TFileVersionInfo;
function String2Sql(str: string): string;
function Hex2Int(HexString: string): Int64;
function ClearDir( Dir: string ): boolean;

var Log_file_name: string;
    File_version: string;

implementation

procedure WriteToLog(Text :string);
var
  f: TextFile;
  strDateTime: string;
begin

  if Log_file_name = '' then exit;

  Assign(f,Log_file_name);
  if FileExists(Log_file_name) then
     Append(f)
  else
     Rewrite(f);
  DateTimeToString(strDateTime,'yyyy-mm-dd hh:nn:ss',Now);
  Writeln(f,strDateTime+' '+Text);
  Close(f);
end;  // WriteToLog

function GetTempDir: string;
var P: string;
begin
  SetLength(P, MAX_PATH);
  SetLength(P, GetTempPath(MAX_PATH, PChar(P)));
  Result := P;
end;

function FileVersion(AFileName: string): string;
var
  szName: array[0..255] of Char;
  P: Pointer;
  Value: Pointer;
  Len: UINT;
  GetTranslationString: string;
  FFileName: PChar;
  FValid: boolean;
  FSize: DWORD;
  FHandle: DWORD;
  FBuffer: PChar;
begin
  FFileName := '';
  FSize := 0;
  try
    FFileName := StrPCopy(StrAlloc(Length(AFileName) + 1), AFileName);
    FValid := False;
    FSize := GetFileVersionInfoSize(FFileName, FHandle);
    if FSize > 0 then
    try
      GetMem(FBuffer, FSize);
      FValid := GetFileVersionInfo(FFileName, FHandle, FSize, FBuffer);
    except
//      FValid := False;
      raise;
    end;
    Result := '';
    if FValid then
      VerQueryValue(FBuffer, '\VarFileInfo\Translation', p, Len)
    else
      p := nil;
    if P <> nil then
      GetTranslationString := IntToHex(MakeLong(HiWord(Longint(P^)),
        LoWord(Longint(P^))), 8);
    if FValid then
    begin
      StrPCopy(szName, '\StringFileInfo\' + GetTranslationString +
        '\FileVersion');
      if VerQueryValue(FBuffer, szName, Value, Len) then
        Result := StrPas(PChar(Value));
    end;
  finally
    try
      if FBuffer <> nil then
        FreeMem(FBuffer, FSize);
    except
    end;
    try
      StrDispose(FFileName);
    except
    end;
  end;
end;

function FileVersionInfo(const sAppNamePath: TFileName): TFileVersionInfo;
var
  rSHFI: TSHFileInfo;
  iRet: Integer;
  VerSize: Integer; 
  VerBuf: PChar; 
  VerBufValue: Pointer; 
  VerHandle: Cardinal; 
  VerBufLen: Cardinal; 
  VerKey: string; 
  FixedFileInfo: PVSFixedFileInfo; 

  // dwFileType, dwFileSubtype 
  function GetFileSubType(FixedFileInfo: PVSFixedFileInfo) : string; 
  begin 
    case FixedFileInfo.dwFileType of 

      VFT_UNKNOWN: Result := 'Unknown'; 
      VFT_APP: Result := 'Application'; 
      VFT_DLL: Result := 'DLL'; 
      VFT_STATIC_LIB: Result := 'Static-link Library'; 

      VFT_DRV: 
        case 
          FixedFileInfo.dwFileSubtype of 
          VFT2_UNKNOWN: Result := 'Unknown Driver'; 
          VFT2_DRV_COMM: Result := 'Communications Driver'; 
          VFT2_DRV_PRINTER: Result := 'Printer Driver'; 
          VFT2_DRV_KEYBOARD: Result := 'Keyboard Driver'; 
          VFT2_DRV_LANGUAGE: Result := 'Language Driver'; 
          VFT2_DRV_DISPLAY: Result := 'Display Driver'; 
          VFT2_DRV_MOUSE: Result := 'Mouse Driver'; 
          VFT2_DRV_NETWORK: Result := 'Network Driver'; 
          VFT2_DRV_SYSTEM: Result := 'System Driver'; 
          VFT2_DRV_INSTALLABLE: Result := 'InstallableDriver'; 
          VFT2_DRV_SOUND: Result := 'Sound Driver'; 
        end; 
      VFT_FONT: 
         case FixedFileInfo.dwFileSubtype of 
          VFT2_UNKNOWN: Result := 'Unknown Font'; 
          VFT2_FONT_RASTER: Result := 'Raster Font'; 
          VFT2_FONT_VECTOR: Result := 'Vector Font'; 
          VFT2_FONT_TRUETYPE: Result :='Truetype Font'; 
          else; 
        end; 
      VFT_VXD: Result :='Virtual Defice Identifier = ' + 
          IntToHex(FixedFileInfo.dwFileSubtype, 8); 
    end; 
  end; 


  function HasdwFileFlags(FixedFileInfo: PVSFixedFileInfo;
  Flag : Word) : Boolean;
  begin 
    Result := (FixedFileInfo.dwFileFlagsMask and 
              FixedFileInfo.dwFileFlags and 
              Flag) = Flag; 
  end; 

  function GetFixedFileInfo: PVSFixedFileInfo; 
  begin 
    if not VerQueryValue(VerBuf, '', Pointer(Result), VerBufLen) then 
      Result := nil 
  end; 

  function GetInfo(const aKey: string): string; 
  begin 
    Result := ''; 
    VerKey := Format('\StringFileInfo\%.4x%.4x\%s', 
              [LoWord(Integer(VerBufValue^)), 
               HiWord(Integer(VerBufValue^)), aKey]); 
    if VerQueryValue(VerBuf, PChar(VerKey),VerBufValue,VerBufLen) then 
      Result := String(StrPas(PAnsiChar(VerBufValue)));
  end; 

  function QueryValue(const aValue: string): string; 
  begin 
    Result := ''; 
    // obtain version information about the specified file 
    if GetFileVersionInfo(PChar(sAppNamePath), VerHandle,
    VerSize, VerBuf) and
       // return selected version information 
       VerQueryValue(VerBuf, '\VarFileInfo\Translation',
       VerBufValue, VerBufLen) then
         Result := GetInfo(aValue); 
  end;


begin 
  // Initialize the Result
  with Result do 
  begin 
    FileType := ''; 
    CompanyName := ''; 
    FileDescription := ''; 
    FileVersion := ''; 
    InternalName := ''; 
    LegalCopyRight := ''; 
    LegalTradeMarks := ''; 
    OriginalFileName := ''; 
    ProductName := ''; 
    ProductVersion := ''; 
    Comments := ''; 
    SpecialBuildStr:= ''; 
    PrivateBuildStr := ''; 
    FileFunction := ''; 
    DebugBuild := False; 
    Patched := False; 
    PreRelease:= False; 
    SpecialBuild:= False; 
    PrivateBuild:= False; 
    InfoInferred := False; 
  end; 

  // Get the file type 
  if SHGetFileInfo(PChar(sAppNamePath), 0, rSHFI, SizeOf(rSHFI), 
    SHGFI_TYPENAME) <> 0 then 
  begin 
    Result.FileType := rSHFI.szTypeName; 
  end; 

  iRet := SHGetFileInfo(PChar(sAppNamePath), 0, rSHFI,
  SizeOf(rSHFI), SHGFI_EXETYPE); 
  if iRet <> 0 then 
  begin 
    // determine whether the OS can obtain version information 
    VerSize := GetFileVersionInfoSize(PChar(sAppNamePath), VerHandle); 
    if VerSize > 0 then 
    begin 
      VerBuf := AllocMem(VerSize); 
      try 
        with Result do 
        begin 
          CompanyName      := QueryValue('CompanyName'); 
          FileDescription  := QueryValue('FileDescription'); 
          FileVersion      := QueryValue('FileVersion'); 
          InternalName     := QueryValue('InternalName'); 
          LegalCopyRight   := QueryValue('LegalCopyRight'); 
          LegalTradeMarks  := QueryValue('LegalTradeMarks'); 
          OriginalFileName := QueryValue('OriginalFileName'); 
          ProductName      := QueryValue('ProductName'); 
          ProductVersion   := QueryValue('ProductVersion'); 
          Comments         := QueryValue('Comments'); 
          SpecialBuildStr  := QueryValue('SpecialBuild'); 
          PrivateBuildStr  := QueryValue('PrivateBuild'); 
          // Fill the  VS_FIXEDFILEINFO structure
          FixedFileInfo    := GetFixedFileInfo;
          DebugBuild       := HasdwFileFlags(FixedFileInfo,VS_FF_DEBUG); 
          PreRelease       := HasdwFileFlags(FixedFileInfo,VS_FF_PRERELEASE); 
          PrivateBuild     := HasdwFileFlags(FixedFileInfo,VS_FF_PRIVATEBUILD); 
          SpecialBuild     := HasdwFileFlags(FixedFileInfo,VS_FF_SPECIALBUILD); 
          Patched          := HasdwFileFlags(FixedFileInfo,VS_FF_PATCHED); 
          InfoInferred     := HasdwFileFlags(FixedFileInfo,VS_FF_INFOINFERRED); 
          FileFunction     := GetFileSubType(FixedFileInfo);
        end; 
      finally
        FreeMem(VerBuf, VerSize);
      end 
    end; 
  end 
end; // FileVersionInfo

function String2Sql(str: string): string;
begin
   String2Sql := AnsiReplaceStr(str, '''', '''''');
end;

function Hex2Int(HexString: string): Int64;
CONST HEX : ARRAY['A'..'F'] OF INTEGER = (10,11,12,13,14,15);
VAR
  Int: Int64;
  i   : integer;
begin
  Int := 0;
  FOR i := 1 TO Length(HexString) DO
    IF HexString[i] < 'A' THEN
      Int := Int * 16 + ORD(HexString[i]) - 48
    ELSE
      Int := Int * 16 + HEX[HexString[i]];

  result := Int;
end;

function ClearDir( Dir: string ): boolean;
var
  isFound: boolean;
  sRec: TSearchRec;
begin
   Result := false;
   ChDir( Dir );
   if IOResult <> 0 then
   begin
      Exit;
   end;
   if Dir[Length(Dir)] <> '\' then Dir := Dir + '\';
   isFound := SysUtils.FindFirst( Dir + '*.*', faAnyFile, sRec ) = 0;
   while isFound do
   begin
   if ( sRec.Name <> '.' ) and ( sRec.Name <> '..' ) then
      if ( sRec.Attr and faDirectory ) = faDirectory then
      begin
         if not ClearDir( Dir + sRec.Name ) then
            Exit;
         if ( sRec.Name <> '.' ) and ( sRec.Name <> '..' ) then
            if ( Dir + sRec.Name ) <> Dir then
            begin
               ChDir( '..' );
               RmDir( Dir + sRec.Name );
            end;
      end
      else
         if not SysUtils.DeleteFile( Dir + sRec.Name ) then
         begin
            Exit;
         end;
      isFound := SysUtils.FindNext( sRec ) = 0;
   end;
   SysUtils.FindClose( sRec );
   Result := IOResult = 0;
end;

initialization
  begin
     Log_file_name := GetInstancePath + 'CsmSvc.log';
     File_version := FileVersionInfo(GetInstancePath+'CsmSvc.exe').FileVersion;
  end;

end.
