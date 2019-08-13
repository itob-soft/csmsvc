unit uFileSaver;

interface

uses
    SysUtils, Classes, SyncObjs, uProjConst, itob_ext_functions, uIHTSConst,
    SQLite3, SQLite3Wrap, Windows;
type

  TOneFileInfo   = class
  private
    FpStream: TMemoryStream;
  { TODO -oawod : Требуется проследить за тем чтобы правильно удалялся поток с данными тайла. Сейчас не понятно почему и как он удалется }    FsLParam: string;
    FsPath: string;
    FsFileName: string;
    FsZParam: string;
    FsXParam: string;
    FsYParam: string;
    FsSParam: string;
    procedure SetpStream(const Value: TMemoryStream);
    procedure SetsFileName(const Value: string);
    procedure SetsLParam(const Value: string);
    procedure SetsPath(const Value: string);
    procedure SetsSParam(const Value: string);
    procedure SetsXParam(const Value: string);
    procedure SetsYParam(const Value: string);
    procedure SetsZParam(const Value: string);
  public
    constructor Create(_pStream : TMemoryStream; const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string);
    destructor Destroy(); override;
    property pStream : TMemoryStream read FpStream write SetpStream;
    property sFileName : string read FsFileName write SetsFileName;
    property sPath : string read FsPath write SetsPath;

    property sLParam : string read FsLParam write SetsLParam;

    property sZParam : string read FsZParam write SetsZParam;
    property sXParam : string read FsXParam write SetsXParam;
    property sYParam : string read FsYParam write SetsYParam;
    property sSParam : string read FsSParam write SetsSParam;
  end;

    TFileSaverBuff = class
    private
        pFileList : TStringList;
        pThreads  : TList;
        ffInDB: integer;
    public
        function pushFile(_pStream : TMemoryStream;  const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath : string) : HRESULT;
        function getFile(var _sFileName, _sPath : string) : TOneFileInfo;
        constructor Create(const _bInDB : integer = I_CACHE_MODE_NAN);
        destructor Destroy(); override;
        procedure SetDBMode(_bInDB : integer);
        property fInDB : integer  read ffInDB;
    end;

    TFileBaseThread = class(TThread)
    private
      pBuff : TFileSaverBuff;
    protected
      procedure Execute(); override;
      function IsExistFile(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string) : Boolean;virtual;abstract;
      function SaveFile(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string; _pStream : TMemoryStream) : Boolean;virtual;abstract;
    public
      constructor Create(_pBuff : TFileSaverBuff);
      function WriteLogFile(const _sMessage : string; const _iCode : Integer) : Boolean;
    end;

    TFileSaverThread = class(TFileBaseThread)
    protected
        function IsExistFile(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string) : Boolean;override;
        function SaveFile(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string; _pStream : TMemoryStream): Boolean;override;
    end;

    TDBList = class
    private
      pDBLists : TStringList;
      fbReadOnly : boolean;
      function GetDB(const _sFileName, _sLParam: string): TSQLite3Database;
    public
      constructor Create(const _bReadOnly : boolean);
      destructor Destroy; override;
      property DB[const _sFileName: string; const _sLParam : string] : TSQLite3Database read GetDB;
      property bReadOnly : Boolean read fbReadOnly;
    end;

    TFileDBSaverThread = class(TFileBaseThread)
    private
        pDBLists : TDBList;
    protected
        function IsExistFile(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string) : Boolean;override;
        function SaveFile(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string; _pStream : TMemoryStream): Boolean;override;
    public
        constructor Create(_pBuff : TFileSaverBuff);
        destructor Destroy; override;
    end;

    TCheckTileBase = class
    public
      constructor Create;
      function IsExistFile(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string; _fForce : Boolean = true) : Boolean;virtual;abstract;
      function GetTileStream(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string) : TStream;virtual;abstract;
    end;

    TCheckTileFile = class(TCheckTileBase)
    public
      constructor Create;
      function IsExistFile(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string; _fForce : Boolean = true) : Boolean;override;
      function GetTileStream(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string) : TStream;override;
    end;

    TCheckTileDB = class(TCheckTileBase)
    private
      pDBLists : TDBList;
    public
      constructor Create;
      destructor Destroy;override;
      function IsExistFile(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string; _fForce : Boolean = true) : Boolean;override;
      function GetTileStream(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string) : TStream;override;
    end;

var
    pSection : TCriticalSection;

implementation

// Функция по созданию на основе имя файла и названия сервера тайлов путь до БД SQLite
function GetDBFileName(const _sFileName, _sLParam : string): string;
var
  i : integer;
begin
  i := Pos(_sLParam,_sFileName);
  if (i > 0) then
    Result := Copy(_sFileName,1,i+length(_sLParam)-1)+S_CASHE_TILE_DB_EXT
  else result := '';
end;

// Функция по получению относительного имени тайла на основе имя файла и названия сервера тайлов
function GetDBTileFileName(const _sFileName, _sLParam : string): string;
var
  i : integer;
begin
  i := Pos(_sLParam,_sFileName);
  if (i > 0) then
    Result := Copy(_sFileName,i+length(_sLParam),length(_sFileName))
  else result := '';
end;

{ TFileSaverBuff }

constructor TFileSaverBuff.Create(const _bInDB : integer);
begin
    inherited Create;
    pFileList := TStringList.Create();
    pThreads  := TList.Create();
    ffInDB := I_CACHE_MODE_NAN;
    SetDBMode(_bInDB);
end;
// ---------------------------------------------------------------------

destructor TFileSaverBuff.Destroy;
var
    i     : Integer;
begin
    for i := 0 to pred(pThreads.Count) do
    begin
        TFileBaseThread(pThreads.Items[i]).Terminate;
    end;
    for i := 0 to pred(pFileList.Count) do
      TOneFileInfo(pFileList.Objects[i]).Free();
    FreeAndNil(pFileList);
    FreeAndNil(pThreads);
    inherited;
end;
// ---------------------------------------------------------------------

function TFileSaverBuff.getFile(var _sFileName, _sPath : string) : TOneFileInfo;
begin
    Result := nil;
    pSection.Enter;
    try
        if(pFileList.Count > 0) then
        begin
            Result := TOneFileInfo(pFileList.Objects[0]);
            _sFileName := pFileList.Strings[0];
            pFileList.Delete(0);
        end;
    finally
        pSection.Leave();
    end;
end;
// ---------------------------------------------------------------------

function TFileSaverBuff.pushFile(_pStream : TMemoryStream; const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string): HRESULT;
begin
    Result := S_OK;
    pSection.Enter;
    try
        if(Assigned(_pStream)) then
        begin
            pFileList.AddObject(_sFileName,
                                TOneFileInfo.Create(
                                  _pStream, _sFileName, _sLParam, _sZParam,
                                  _sXParam, _sYParam, _sSParam, _sPath));
        end;
    finally
        pSection.Leave();
    end
end;
procedure TFileSaverBuff.SetDBMode(_bInDB: integer);
var
    i     : Integer;
    pThr  : TFileBaseThread;
begin
  if _bInDB = fInDB then exit
  else begin
    ffInDB := _bInDB;
    for i := 0 to pred(pThreads.Count) do
    begin
        TFileBaseThread(pThreads.Items[i]).Terminate;
    end;
    pThreads.Clear;

    for i := 0 to 4 do
    begin
      if fInDB = I_CACHE_MODE_DB then
        pThr := TFileDBSaverThread.Create(Self)
      else if fInDB = I_CACHE_MODE_FILE then
        pThr := TFileSaverThread.Create(Self)
      else pThr := nil;
      if Assigned(pThr) then begin
        pThr.FreeOnTerminate := true;

        pThreads.Add(pThr);
        pThr.Resume();
      end;
    end;

  end;
end;

// ---------------------------------------------------------------------

{ TFileSaverThread }

// ---------------------------------------------------------------------

function TFileSaverThread.IsExistFile(const _sFileName, _sLParam, _sZParam,
  _sXParam, _sYParam, _sSParam, _sPath: string) : Boolean;
begin
    Result := false;
    // Не может создать папку
    if(not ForceDirectories(_sPath)) then Exit;
    Result := FileExists(_sFileName);
end;
// ---------------------------------------------------------------------

{ TFileDBSaverThread }

constructor TFileDBSaverThread.Create(_pBuff : TFileSaverBuff);
begin
  inherited Create(_pBuff);
  pDBLists := TDBList.Create(False);
end;
// ---------------------------------------------------------------------

function TFileDBSaverThread.IsExistFile(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string) : Boolean;
var
  tTileSQL: TSQLite3Statement;
  fDB : TSQLite3Database;
begin
  result := false;
  fDB := pDBLists.DB[_sFileName,_sLParam];
  if Assigned(fDB) then begin
    tTileSQL := fDB.Prepare(S_CACHE_TILE_EXS);
    try
      tTileSQL.BindText(1,_sXParam);
      tTileSQL.BindText(2,_sYParam);
      tTileSQL.BindText(3,_sZParam);
      tTileSQL.BindText(4,_sSParam);
      if tTileSQL.Step = SQLITE_ROW then
        result := tTileSQL.ColumnInt(0) > 0;
      tTileSQL.Reset;
    finally
      tTileSQL.Free;
    end;
  end;
end;

function TFileDBSaverThread.SaveFile(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _SSParam, _sPath: string;
  _pStream: TMemoryStream): Boolean;
var
  tTileSQL: TSQLite3Statement;
  fDB : TSQLite3Database;
begin
  fDB := pDBLists.DB[_sFileName,_sLParam];
  if Assigned(fDB) then begin
    tTileSQL := fDB.Prepare(S_CACHE_TILE_INS);
    try
      tTileSQL.BindBlob(1,_pStream.Memory,_pStream.Size);
      tTileSQL.BindText(2,_sXParam);
      tTileSQL.BindText(3,_sYParam);
      tTileSQL.BindText(4,_sZParam);
      tTileSQL.BindText(5,_sSParam);
      result := tTileSQL.StepAndReset in [SQLITE_ROW,SQLITE_DONE];
    finally
      tTileSQL.Free;
    end;
    if Result then begin
      tTileSQL := fDB.Prepare(S_CACHE_INFO_SET);
      try
        tTileSQL.BindInt(1,StrToIntDef(_sZParam,-1));
        tTileSQL.BindInt(2,StrToIntDef(_sZParam,1000000000));
        result := tTileSQL.StepAndReset in [SQLITE_ROW,SQLITE_DONE];
      finally
        tTileSQL.Free;
      end;
    end;
  end;
end;

destructor TFileDBSaverThread.Destroy;
begin
  FreeAndNil(pDBLists);
  inherited;
end;

{ TFileBaseThread }

constructor TFileBaseThread.Create(_pBuff: TFileSaverBuff);
begin
    inherited Create(true);
    FreeOnTerminate := true;
    pBuff := _pBuff;
end;

procedure TFileBaseThread.Execute;
var
    sFileName, sPath    : string;
    pOneFile            : TOneFileInfo;
begin
    inherited;

    while(not Terminated) do
    begin
        try
            pOneFile := pBuff.getFile(sFileName, sPath);
            if(Assigned(pOneFile)) then
                try
                    if(not IsExistFile(sFileName, pOneFile.sLParam, pOneFile.sZParam,
                      pOneFile.sXParam, pOneFile.sYParam, pOneFile.sSParam, pOneFile.sPath)) then
                        SaveFile(sFileName, pOneFile.sLParam, pOneFile.sZParam, pOneFile.sXParam,
                          pOneFile.sYParam, pOneFile.sSParam, pOneFile.sPath, pOneFile.pStream);
                finally
                    FreeAndNil(pOneFile);
                end
            else
                Sleep(1000);
        except
            on E : Exception do
            begin
                try
                    WriteLogFile(S_E_REQUEST_PROCESS + #13#10 + E.Message, E_GEN_ERROR);
                    Sleep(1000);
                except
                    // ничего не пишем
                end;
            end;
        end;
    end;
end;

function TFileBaseThread.WriteLogFile(const _sMessage: string;
  const _iCode: Integer): Boolean;
var
    pList     : TStringList;
    gFileID   : TGUID;
begin
    try
        pList := TStringList.Create();
        try
            pList.Add(S_CODE + IntToStr(_iCode));
            pList.Add('');
            pList.Add(_sMessage);
            CreateGUID(gFileID);
            ForceDirectories(GetInstancePath() + S_LOG_PATH);
            pList.SaveToFile(GetInstancePath() + Format(S_LOG_FIELD, [GUIDToString(gFileID)]));
        finally
            FreeAndNil(pList);
        end;
        Result := true;
    except
        Result := false;
    end;
end;

function TFileSaverThread.SaveFile(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string;
  _pStream : TMemoryStream): Boolean;
var
    pFileStream : TFileStream;
begin
    pFileStream := TFileStream.Create(_sFileName, fmCreate);
    try
      _pStream.Position := 0;
      pFileStream.CopyFrom(_pStream, _pStream.Size);
    finally
      FreeAndNil(pFileStream);
    end;
end;

{ TCheckTileBase }

constructor TCheckTileBase.Create;
begin
  inherited;
end;

{ TCheckTileFile }

constructor TCheckTileFile.Create;
begin
  inherited;

end;

function TCheckTileFile.GetTileStream(const _sFileName, _sLParam, _sZParam,
  _sXParam, _sYParam, _sSParam, _sPath: string): TStream;
begin
  result := TFileStream.Create(_sFileName, fmShareDenyWrite);
end;

function TCheckTileFile.IsExistFile(const _sFileName, _sLParam, _sZParam,
  _sXParam, _sYParam, _sSParam, _sPath: string;
  _fForce: Boolean): Boolean;
begin
    Result := false;
    // Не может создать папку
    if(_fForce) then
        if(not ForceDirectories(_sPath)) then Exit;
    Result := FileExists(_sFileName);
end;

{ TCheckTileDB }

constructor TCheckTileDB.Create;
begin
  inherited;
  pDBLists := TDBList.Create(true);
end;

destructor TCheckTileDB.Destroy;
begin
  FreeAndNil(pDBLists);
  inherited;
end;

function TCheckTileDB.GetTileStream(const _sFileName, _sLParam, _sZParam,
  _sXParam, _sYParam, _sSParam, _sPath: string): TStream;
var
  locMem : TMemoryStream;
  tTileSQL: TSQLite3Statement;
  tmp : array of byte;
  locVar : Pointer;
  fDB : TSQLite3Database;
begin
  locMem := TMemoryStream.Create();
  fDB := pDBLists.DB[_sFileName,_sLParam];
  if Assigned(fDB) then begin
    tTileSQL := fDB.Prepare(S_CACHE_TILE_SEL);
    try
      tTileSQL.BindText(1,_sXParam);
      tTileSQL.BindText(2,_sYParam);
      tTileSQL.BindText(3,_sZParam);
      tTileSQL.BindText(4,_sSParam);
      if tTileSQL.Step = SQLITE_ROW then
      begin
        setlength(tmp,tTileSQL.ColumnBytes(0));
        FillChar(tmp[0],length(tmp),0);
        locVar := tTileSQL.ColumnBlob(0);
        CopyMemory(@tmp[0],locvar,length(tmp));
        locMem.WriteBuffer(@tmp[0],Length(tmp));
      end;
      tTileSQL.Reset;
    finally
      tTileSQL.Free;
    end;

  end;
  Result := locMem;
end;

function TCheckTileDB.IsExistFile(const _sFileName, _sLParam, _sZParam,
  _sXParam, _sYParam, _sSParam, _sPath: string;
  _fForce: Boolean): Boolean;
var
  tTileSQL: TSQLite3Statement;
  fDB : TSQLite3Database;
begin
  result := false;
  fDB := pDBLists.DB[_sFileName,_sLParam];
  if Assigned(fDB) then begin
    tTileSQL := fDB.Prepare(S_CACHE_TILE_EXS);
    try
      tTileSQL.BindText(1,_sXParam);
      tTileSQL.BindText(2,_sYParam);
      tTileSQL.BindText(3,_sZParam);
      tTileSQL.BindText(4,_sSParam);
      if tTileSQL.Step = SQLITE_ROW then
      begin
        result := tTileSQL.ColumnInt(0) > 0;
      end;
      tTileSQL.Reset;
    finally
      tTileSQL.Free;
    end;
  end;
end;

{ TOneFileInfo }

constructor TOneFileInfo.Create(_pStream : TMemoryStream; const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string);
begin
  inherited Create;
  pStream := _pStream;
  sFileName := _sFileName;
  sPath := _sPath;

  sLParam := _sLParam;

  sXParam := _sXParam;
  sYParam := _sYParam;
  sZParam := _sZParam;
  sSParam := _sSParam;// По требованию из ТЗ  должно быть 0 : https://itob.planfix.ru/task/551/?comment=29182978
end;

destructor TOneFileInfo.Destroy;
begin
  FpStream.Free;
  inherited;
end;

procedure TOneFileInfo.SetpStream(const Value: TMemoryStream);
begin
  FpStream := Value;
end;

procedure TOneFileInfo.SetsFileName(const Value: string);
begin
  FsFileName := Value;
end;

procedure TOneFileInfo.SetsLParam(const Value: string);
begin
  FsLParam := Value;
end;

procedure TOneFileInfo.SetsPath(const Value: string);
begin
  FsPath := Value;
end;

procedure TOneFileInfo.SetsSParam(const Value: string);
begin
  FsSParam := Value;
end;

procedure TOneFileInfo.SetsXParam(const Value: string);
begin
  FsXParam := Value;
end;

procedure TOneFileInfo.SetsYParam(const Value: string);
begin
  FsYParam := Value;
end;

procedure TOneFileInfo.SetsZParam(const Value: string);
begin
  FsZParam := Value;
end;

{ TDBList }

constructor TDBList.Create;
begin
  pDBLists := TStringList.Create;
  fbReadOnly := _bReadOnly;
end;

destructor TDBList.Destroy;
begin
  while pDBLists.Count > 0 do
  begin
    pDBLists.Objects[0].Free;
    pDBLists.Delete(0);
  end;
  FreeAndNil(pDBLists);

  inherited;
end;

function TDBList.GetDB(const _sFileName, _sLParam: string): TSQLite3Database;
var
  i : integer;
  tTileSQL: TSQLite3Statement;
begin
  i := pDBLists.IndexOf(_sLParam);
  if i >= 0 then
    result := TSQLite3Database(pDBLists.Objects[i])
  else begin
    Result := TSQLite3Database.Create;
    pDBLists.AddObject(_sLParam,Result);
  end;

  if not Assigned(Result.Handle) then begin
    if bReadOnly then begin
      if FileExists(GetDBFileName(_sFileName,_sLParam)) then
        Result.Open(GetDBFileName(_sFileName,_sLParam),SQLITE_OPEN_READONLY)
      else Result := nil;
    end else begin
      Result.Open(GetDBFileName(_sFileName,_sLParam));
      Result.Execute(S_CACHE_TILE_CREATE);
      Result.Execute(S_CACHE_INFO_CREATE);


      tTileSQL := Result.Prepare(S_CACHE_INFO_CHECK);
      try
        if tTileSQL.Step = SQLITE_ROW then
          i := tTileSQL.ColumnInt(0)
        else i := 0;
        tTileSQL.Reset;
      finally
        tTileSQL.Free;
      end;

      if i = 0 then
        Result.Execute(S_CACHE_INFO_INS_INI);//Инициализация инфо
    end;
  end;
end;

initialization
    pSection := TCriticalSection.Create();
end.
