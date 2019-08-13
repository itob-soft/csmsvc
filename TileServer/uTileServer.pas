unit uTileServer;

interface
uses
    Classes, SysUtils, uIHTSConst, StrUtils, IdTCPConnection, IdTCPClient, IdHTTP, IdBaseComponent, IdComponent,
    IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer, IdContext, SyncObjs, IdIOHandler, IdIOHandlerSocket,
    IdIOHandlerStack, IdConnectThroughHttpProxy, itob_ext_functions, uFileSaver, IniFiles, IdSSLOpenSSL,
    IdGlobal, uCSM_IngitServer, uCGTS_Server;
type
    TTileHTTPServer = class
    private
        pHTTPServer        : TIdHTTPServer;   // HTTP Server
        pFileSaver         : TFileSaverBuff;  // Сохранялка файлов
        fsCatchFilePath    : string;          // Адрес файлоы кэша
        fiHTTPPort         : Integer;         // Необходимость следующего прокси
        ffProxyNeed        : Boolean;         // Необходимость следующего прокси
        fsProxyHost        : string;          // Хост следующего прокси
        fiProxyPort        : Integer;         // Порт следующего прокси
        ffProxyPassNeed    : Boolean;         // Необходим пароль
        fsProxyUser        : string;          // Пользователь следующего прокси
        fsProxyPass        : string;          // Пароль следующего прокси
        ffEnabled          : boolean;         // Используется сервер или нет

        //переменные для работы с SSL

        pSSLHandler : TIdServerIOHandlerSSLOpenSSL;

        ffSSL: boolean;
        fsSSLMainCert: string;
        fsSSLKey: string;
        fsSSLRootCert: string;
        ffCacheinDB: integer;

        pCheckTile          : TCheckTileBase;
        pIngitServer        : TCSM_INGITServer;  //  Сервер реализующий ИГИТ
        pCGTSServer         : TCGTSServer;       //  Сервер реализующий

        procedure SetfCacheinDB(const Value: integer);
    public
        // Проверяет наличие файла паралельно создавая весь путь до него если такового нет
        function IsExistFile(const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string; _fForce : Boolean = true) : Boolean;
        //Возвращает тайл в виде потока либо из файла, либо из БД
        function GetTileStream(
          const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string) : TStream;
        // Проверяет общие для двух действий параметры
        function CheckGeneralParams(const _pParams : TStrings;
                                    var _sFileName, _sLParam, _sZParam,
                                        _sXParam, _sYParam, _sHost, _sPath : string) : Boolean;
        // Извлекает необходимый путь файла
        function GetFilePath(const _sLParam, _sZParam, _sXParam, _sYParam, _sExt : string;
                             var _sPath, _sFileName : string) : Boolean;
        // Функция обработки входящего запроса
        procedure pHTTPServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
                                        AResponseInfo: TIdHTTPResponseInfo);
        procedure pHTTPServerOnQuerySSLPort (APort: TIdPort; var VUseSSL: Boolean);

        // Функция для отправки данных
        procedure WriteContent(AResponseInfo: TIdHTTPResponseInfo);
        // Прописывает при необходимости прокси
        function InitClient(_pClient : TIdHTTP) : Boolean;
        // Записвает в логи всю информацию о случае
        function WriteLogFile(const _sMessage : string; const _iCode : Integer) : Boolean;
        // Функция инициализации
        function Init(_sIniFileName : string) : HRESULT;
        constructor Create();
        destructor Destroy(); override;
        // =============================== PROPERTY ======================================================
        property sCatchFilePath    : string     read fsCatchFilePath    write fsCatchFilePath;
        property fProxyNeed        : Boolean    read ffProxyNeed        write ffProxyNeed;
        property sProxyHost        : string     read fsProxyHost        write fsProxyHost;
        property iProxyPort        : Integer    read fiProxyPort        write fiProxyPort;
        property fProxyPassNeed    : Boolean    read ffProxyPassNeed    write ffProxyPassNeed;
        property sProxyUser        : string     read fsProxyUser        write fsProxyUser;
        property sProxyPass        : string     read fsProxyPass        write fsProxyPass;
        property iHTTPPort         : Integer    read fiHTTPPort         write fiHTTPPort;
        property fEnabled          : Boolean    read ffEnabled          write ffEnabled;
        property fCacheinDB        : integer    read ffCacheinDB        write SetfCacheinDB;

        property fSSL              : boolean    read ffSSL              write ffSSL;
        property sSSLMainCert      : string     read fsSSLMainCert      write fsSSLMainCert;
        property sSSLRootCert      : string     read fsSSLRootCert      write fsSSLRootCert;
        property sSSLKey           : string     read fsSSLKey           write fsSSLKey;

    end;



implementation

uses uINGITConst, uCSMConst;

function TTileHTTPServer.Init(_sIniFileName : string) : HRESULT;
var
    pIni : TIniFile;

    function _locGetRelPath(const _locPath : string): string;
    begin
      if (Pos(':',LeftStr(_locPath,2))=0) AND (LeftStr(_locPath,2) <> '\\') then
        // Название папки кеша не содержит ни диск ни сетевую шару
        // Путь строится относительно расположения службы
        result := GetInstancePath() + _locPath
      else result := _locPath;
    end;

begin
    pIni := TIniFile.Create(GetInstancePath() + _sIniFileName);
    with pIni do
    begin
        iHTTPPort         := ReadInteger(S_IHTS_SERVICE, S_PORT, 6767);
        sCatchFilePath    := ReadString (S_IHTS_SERVICE, S_FILES_PATH, GetInstancePath() + S_FILES_DIR);
        if sCatchFilePath='' then sCatchFilePath := GetInstancePath() + S_FILES_DIR;
        sCatchFilePath := _locGetRelPath(sCatchFilePath);
        if RightStr(sCatchFilePath,1) <> '\' then sCatchFilePath := sCatchFilePath + '\';

        fProxyNeed        := ReadInteger(S_IHTS_SERVICE, S_NEXT_PROXY_NEED, 0) = 1;
        fProxyPassNeed    := ReadInteger(S_IHTS_SERVICE, S_NEXT_PROXY_AYTH, 0) = 1;
        sProxyHost        := ReadString (S_IHTS_SERVICE, S_NEXT_PROXY_HOST, '');
        iProxyPort        := ReadInteger(S_IHTS_SERVICE, S_NEXT_PROXY_PORT, -1);
        sProxyUser        := ReadString (S_IHTS_SERVICE, S_NEXT_PROXY_USER, '');
        sProxyPass        := ReadString (S_IHTS_SERVICE, S_NEXT_PROXY_PASS, '');
        fEnabled          := ReadBool   (S_IHTS_SERVICE, S_ENABLED, False);
        fCacheinDB        := ReadInteger(S_IHTS_SERVICE, S_CACHEINDB, I_CACHE_MODE_NAN);

        fSSL              := ReadBool   (S_IHTS_SERVICE, S_SSL, False);
        sSSLMainCert      := _locGetRelPath(ReadString (S_IHTS_SERVICE, S_SSLMainCert, ''));
        sSSLRootCert      := _locGetRelPath(ReadString (S_IHTS_SERVICE, S_SSLRootCert, ''));
        sSSLKey           := _locGetRelPath(ReadString (S_IHTS_SERVICE, S_SSLKey, ''));

        pIngitServer.LoadFromIni(pIni);

        pCGTSServer.LoadFromIni(pIni);
    end;
    FreeAndNil(pIni);

    Result := E_NO_DIR;
    if(fsCatchFilePath = '') then Exit;
    Result := E_NOT_PORT;
    if(fiHTTPPort < 1) then Exit;
    Result := E_NOT_PROXY;
    if(ffProxyNeed) and ((fsProxyHost = '') or (fiProxyPort < 1)) then Exit;
    Result := S_OK;
    pHTTPServer.DefaultPort := fiHTTPPort;


    {*
http://stackoverflow.com/questions/8646781/simple-tidhttpserver-example-supporting-ssl

ServerIOHandler.SSLOptions.CertFile := 'mycert.pem';
ServerIOHandler.SSLOptions.KeyFile := 'mycert.pem';
ServerIOHandler.SSLOptions.RootCertFile := 'mycert.pem';
ServerIOHandler.SSLOptions.Method := sslvSSLv23;
ServerIOHandler.SSLOptions.Mode := sslmServer;

ServerIOHandler.SSLOptions.VerifyDepth := 1;
ServerIOHandler.SSLOptions.VerifyMode := [sslvrfPeer,sslvrfFailIfNoPeerCert,sslvrfClientOnce];

IdHTTPServer1 := TIdHTTPServer.Create;
IdHTTPServer1.AutoStartSession := True;
IdHTTPServer1.SessionState := True;
IdHTTPServer1.OnCommandGet := IdHTTPServer1CommandGet;
idHttpServer1.ParseParams := True;
idHttpServer1.DefaultPort := 80;
idHttpServer1.IOHandler := ServerIOHandler;
IdHTTPServer1.Active := True;
    *}
    pHTTPServer.IOHandler := nil;

    if fSSL then begin
      pSSLHandler.SSLOptions.CertFile := sSSLMainCert;
      pSSLHandler.SSLOptions.KeyFile := sSSLKey;
      pSSLHandler.SSLOptions.RootCertFile := sSSLRootCert;

      //pHTTPServer.Bindings.Add.IP := '172.0.0.1';
      pSSLHandler.SSLOptions.Method := sslvSSLv23;
      pSSLHandler.SSLOptions.SSLVersions := [sslvSSLv23,sslvTLSv1,sslvTLSv1_1,sslvTLSv1_2];
      pSSLHandler.SSLOptions.Mode := sslmServer;

      pSSLHandler.SSLOptions.VerifyDepth := 0;
      pSSLHandler.SSLOptions.VerifyMode := [];//sslvrfPeer,sslvrfFailIfNoPeerCert,sslvrfClientOnce];

      pHTTPServer.IOHandler := pSSLHandler;


      pHTTPServer.AutoStartSession := true;
      pHTTPServer.SessionState := true;
      pHTTPServer.ParseParams := true;
    end;

    pHTTPServer.Active := fEnabled;
end;
// ---------------------------------------------------------

function TTileHTTPServer.IsExistFile(const _sFileName, _sLParam, _sZParam,
  _sXParam, _sYParam, _sSParam, _sPath : string; _fForce : Boolean = true): Boolean;
begin
  if Assigned(pCheckTile) then
    Result := pCheckTile.IsExistFile(_sFileName, _sLParam, _sZParam,
      _sXParam, _sYParam, _sSParam, _sPath, _fForce)
  else
    Result := false;
end;
// ---------------------------------------------------------

constructor TTileHTTPServer.Create;
begin
    inherited;
    pFileSaver  := TFileSaverBuff.Create(fCacheinDB);
    pHTTPServer := TIdHTTPServer.Create(nil);
    pHTTPServer.OnCommandGet := pHTTPServerCommandGet;
    pHTTPServer.OnQuerySSLPort := pHTTPServerOnQuerySSLPort;
    pSSLHandler := TIdServerIOHandlerSSLOpenSSL.Create(nil);
    pCheckTile := nil;
    pIngitServer := TCSM_INGITServer.Create;
    pCGTSServer := TCGTSServer.Create;
end;
// ---------------------------------------------------------

destructor TTileHTTPServer.Destroy;
begin
    FreeAndNil(pHTTPServer);
    FreeAndNil(pSSLHandler);
    FreeAndNil(pFileSaver);
    FreeAndNil(pCheckTile);
    FreeAndNil(pIngitServer);
    FreeAndNil(pCGTSServer);
    inherited;
end;
// ---------------------------------------------------------

function TTileHTTPServer.GetFilePath(const _sLParam, _sZParam, _sXParam, _sYParam, _sExt : string;
                           var _sPath, _sFileName : string) : Boolean;
var
    iXTemp, iYTemp : Integer;
    slocDBName : string;
begin
    Result := true;
    iXTemp := StrToInt(_sXParam) div 1024;
    iYTemp := StrToInt(_sYParam) div 1024;
    // FROM SAS http://sasgis.ru/forum/viewtopic.php?f=2&t=23&start=0#p470
    // result:=path+'\z'+zoom+'\'+(x div 1024)+'\x'+x+'\'+(y div 1024)+'\y'+y+ext;
    slocDBName :=  S_BACK_SLASH_SYMB +
                 S_Z_SYMB + _sZParam + S_BACK_SLASH_SYMB +
                 IntToStr(iXTemp) + S_BACK_SLASH_SYMB + S_X_SYMB + _sXParam + S_BACK_SLASH_SYMB +
                 IntToStr(iYTemp) + S_BACK_SLASH_SYMB;
    _sPath := fsCatchFilePath +
                 _sLParam + slocDBName;

    _sFileName := _sPath + S_Y_SYMB + _sYParam + _sExt;
end;

function TTileHTTPServer.GetTileStream(
          const _sFileName, _sLParam, _sZParam,
                _sXParam, _sYParam, _sSParam, _sPath: string): TStream;
begin
  if Assigned(pCheckTile) then
    Result := pCheckTile.GetTileStream(_sFileName, _sLParam, _sZParam,
      _sXParam, _sYParam, _sSParam, _sPath)
  else result := nil;
end;

// ---------------------------------------------------------

function TTileHTTPServer.CheckGeneralParams(
  const _pParams : TStrings;
  var _sFileName, _sLParam, _sZParam, _sXParam, _sYParam, _sHost, _sPath: string) : Boolean;
var
    iExt, n    : Integer;
begin
    Result := false;
    // Извлечение интересующих параметров
    _sZParam := _pParams.Values[S_Z_PARAM];
    _sLParam := _pParams.Values[S_L_PARAM];
    _sXParam := _pParams.Values[S_X_PARAM];
    _sYParam := _pParams.Values[S_Y_PARAM];
    _sHost   := _pParams.Values[S_HOST];
    _sHost   := ReplaceStr(_sHost, '%26', '&');
    // Проверяем расширение
    iExt := -1;
    for n := 0 to pred(Length(A_EXT_LIST)) do
        if(PosEx(A_EXT_LIST[n], _sHost) <> 0) then
        begin
            iExt := n;
            break;
        end;

    // По умолчанию - PNG
    if (iExt = -1) then iExt := 2;

    // Без нужного расширения или параметра работать нельзя
    if( (iExt < 0) or (_sXParam = '') or (_sYParam = '') or
       (_sZParam = '') or (_sLParam = '') or (_sHost = '')) then Exit;
    // Извлечение пути к файлу
    _sFileName := '';
    _sPath     := '';
    GetFilePath(_sLParam, _sZParam, _sXParam, _sYParam, A_EXT_LIST[iExt], _sPath, _sFileName);
    Result := true;
end;
// ---------------------------------------------------------

procedure TTileHTTPServer.WriteContent(AResponseInfo: TIdHTTPResponseInfo);
var
    fFlag : Boolean;
    n     : Integer;
begin
    try
        AResponseInfo.ContentLength := AResponseInfo.ContentStream.Size;
        AResponseInfo.WriteHeader;
        AResponseInfo.WriteContent;
    except
        on E : Exception do
        begin
            // Если не ошибка отказа принять соединение - то логируем
            fFlag := true;
            for n := 0 to pred(Length(AS_MARK_NO_ERROR)) do
                fFlag := fFlag and (PosEx(AS_MARK_NO_ERROR[n], E.Message) <> 0);
            if(fFlag) then
                WriteLogFile(S_E_WRITE_CONTEXT + #13#10 + E.Message, E_GEN_ERROR);
        end;
    end;
end;
// ---------------------------------------------------------

procedure TTileHTTPServer.pHTTPServerCommandGet(AContext: TIdContext; ARequestInfo : TIdHTTPRequestInfo;
                                                AResponseInfo: TIdHTTPResponseInfo);
var
    sFileName, sLParam, sZParam,
    sXParam, sYParam, sHost, sPath   : string;
    pClient                          : TIdHTTP;
    pStream                          : TMemoryStream;
    fSent                            : Boolean;

    procedure locSaveFileInX(_pStream : TStream);
    var
      pStream2 : TMemoryStream;
    begin
      pStream2 := TMemoryStream.Create();
      _pStream.Position := 0;
      pStream2.CopyFrom(_pStream, _pStream.Size);
      //pStream2 - удаление происходит в потоке, который занимается сохранением данный в файл или БД
      pFileSaver.pushFile(pStream2, sFileName, sLParam, sZParam, sXParam, sYParam, S_TILE_DEF_SPARAM, sPath);
      AResponseInfo.ContentStream := _pStream;
      WriteContent(AResponseInfo);
    end;

begin
// Эту часть требутеся сделать в виде плагинов которые будут проходиться по циклу для выбора сервера отвечающего за запрос.
  if pIngitServer.IsThisServerRequest(ARequestInfo.Document) then begin
    pIngitServer.ProcessRequest(ARequestInfo,AResponseInfo);
  end else if pCGTSServer.IsThisServerRequest(ARequestInfo.Document) then begin
    pCGTSServer.ProcessRequest(ARequestInfo,AResponseInfo);
  end else begin
// Эту часть требутеся сделать в виде плагинов которые будут проходиться по циклу для выбора сервера отвечающего за запрос.
    fSent := false;
    AResponseInfo.ContentType   := 'application/octet-stream';
    try
        // Извлечение и проверка всех запросов
        if(not CheckGeneralParams(ARequestInfo.Params, sFileName, sLParam,
                                  sZParam, sXParam, sYParam, sHost, sPath)) then begin
           AResponseInfo.ContentType   := S_CT_UTF8;
           AResponseInfo.ResponseNo := 404;
           AResponseInfo.ResponseText := 'CheckGeneralParams error';
           Exit;
        end;
        if(IsExistFile(sFileName, sLParam, sZParam, sXParam, sYParam, S_TILE_DEF_SPARAM, sPath)) then
        begin
          AResponseInfo.ContentStream := GetTileStream(sFileName, sLParam, sZParam, sXParam, sYParam, S_TILE_DEF_SPARAM, sPath);
          WriteContent(AResponseInfo);
        end else begin
          pStream   := TMemoryStream.Create();
          try
// Эту часть требутеся сделать в виде плагинов которые будут проходиться по циклу для выбора сервера отвечающего за запрос.
            if AnsiSameText(L_PARAM_INGIT,sLParam) then begin
              if pIngitServer.ProcessTile(sLParam,
                sZParam, sXParam, sYParam, sHost, sPath,pStream) <> S_OK then
                exit;// если получение данный по тайлу не получилось, то выходим.
            end else if AnsiSameText(L_PARAM_CITYGIT,sLParam) then begin
              if pCGTSServer.ProcessTile(sLParam,
                sZParam, sXParam, sYParam, sHost, sPath,pStream) <> S_OK then
                exit;// если получение данный по тайлу не получилось, то выходим.
// Эту часть требутеся сделать в виде плагинов которые будут проходиться по циклу для выбора сервера отвечающего за запрос.
            end else begin
              // Запрос на большой сервер
              pClient := TIdHTTP.Create(nil);
              pClient.Request.UserAgent := 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.7 (KHTML, like Gecko) Chrome/7.0.517.44 Safari/534.7';
              pClient.Request.AcceptLanguage := 'ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4';
              pClient.Request.AcceptEncoding := 'gzip,deflate,sdch';
              pClient.Request.AcceptCharSet  := 'windows-1251,utf-8;q=0.7,*;q=0.3';
              pClient.ReadTimeout := 20000;

              try
                if(not InitClient(pClient)) then Exit;
                pClient.Get(sHost// + '?' + ARequestInfo.UnparsedParams
                            , pStream);
              finally
                  FreeAndNil(pClient);
              end;
            end;
            locSaveFileInX(pStream);
            fSent := true;
          finally
            if(not fSent) then
              FreeAndNil(pStream);
          end;
        end;
        // Проверка наличия такого файла
    except
        on E : Exception do
        begin
            WriteLogFile(S_E_REQUEST_PROCESS + #13#10 + 'URL '+sHost+ #13#10+ E.Message, E_GEN_ERROR);
            AResponseInfo.ResponseNo := 404;
            AResponseInfo.ContentType:=S_CT_UTF8;
            AResponseInfo.ContentText:='404: NOT FOUND';
        end;
    end;
  end;
end;
procedure TTileHTTPServer.pHTTPServerOnQuerySSLPort(APort: TIdPort;
  var VUseSSL: Boolean);
begin
  VUseSSL := fSSL;
end;

procedure TTileHTTPServer.SetfCacheinDB(const Value: integer);
begin
  ffCacheinDB := Value;
  //Выставляем куда сохраняем тайлы.
  pFileSaver.SetDBMode(fCacheinDB);

  FreeAndNil(pCheckTile);

  if fCacheinDB = I_CACHE_MODE_DB then
    pCheckTile := TCheckTileDB.Create
  else if fCacheinDB = I_CACHE_MODE_FILE then
    pCheckTile := TCheckTileFile.Create
  else pCheckTile := nil;
end;

// --------------------------------------------------------------------------

function TTileHTTPServer.InitClient(_pClient : TIdHTTP) : Boolean;
//var
//    pIOHandlerStack                           : TIdIOHandlerStack;
//    pProxy                                    : TIdConnectThroughHttpProxy;
begin
    try
        Result := true;
        if(ffProxyNeed) then
        begin
            _pClient.ProxyParams.ProxyServer := fsProxyHost;
            _pClient.ProxyParams.ProxyPort := fiProxyPort;
            if(ffProxyPassNeed) then
            begin
                _pClient.ProxyParams.ProxyUsername := fsProxyUser;
                _pClient.ProxyParams.ProxyPassword := fsProxyPass;
            end;
//            pIOHandlerStack.TransparentProxy := pProxy;
        end;
    except
        on E : Exception do
        begin
            WriteLogFile(S_E_INIT_CLIENT + #13#10 + E.Message, E_GEN_ERROR);
            Result := false;
        end;
    end;
end;
// --------------------------------------------------------------------------

function TTileHTTPServer.WriteLogFile(const _sMessage : string; const _iCode : Integer) : Boolean;
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
// --------------------------------------------------------------------------


Initialization
//    pWriteSection := TCriticalSection.Create;
end.
