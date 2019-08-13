unit CsmSvcHandlier;

interface
uses itob_replication_thread, itob_replication_types,
  DateUtils,
  SysUtils, IdHTTPServer, IdContext, IdBaseComponent, Classes, Windows,
  IdComponent, IdCustomTCPServer, IdCustomHTTPServer, PNGImage, Graphics, SyncObjs,
  ActiveX,
	IdHTTP, IdIOHandlerStack,
  IdSSL, IdSSLOpenSSL, IdTCPConnection, IdTCPClient,   
  // SELF
  uIHZServerConst, uProfStorage, EPSG900913, uProjConst, uIHTSConst, uFileSaver, uTileServer;

type
  TCsmSvcHandlier = class
  private
     fStarted: boolean;
     //FReplicationThread: TReplicationThread;
     fHttpServer: TIdHTTPServer;
     fHtmlDir: string;
     fReplicationEnabled: boolean;
     fReplicationThreads: array of TReplicationThread;
     fDebugMode: boolean;
     fFileVersion: string;
     // >> =======================  IHTZ =========================
     fpClearImg         : TPNGImage;         // Чистая картинка
     pHTTPServer        : TIdHTTPServer;     // HTTP Server
     pStorage           : TIHZStorage;       // Хранилище профайлов
     pTileServer        : TTileHTTPServer;   // Тайловый сервер
//     fiPort             : Integer;         // Прорт сервера
     // Считывает все файлы из папки настроек
     function FillProfList() : HRESULT;
     function CheckGeneralParams(const _pParams : TStrings; var _pResParams : TTileParams) : Boolean;
     // << =======================  IHTZ =========================
     procedure SetStarted(Value: boolean);
     procedure HTTPServerCommandGet(AContext: TIdContext;
        ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
     procedure HandleSetMapData(AContext: TIdContext;
        ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
     procedure HandleCreateCacheDir(AContext: TIdContext;
				ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
     procedure HandleRemoveCacheDir(AContext: TIdContext;
				ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
		 procedure HandleGetServiceStatus(AContext: TIdContext;
        ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
		 procedure HandleCheckServiceStatus(AContext: TIdContext;
        ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
     procedure HandleProxyRequest(AContext: TIdContext;
        ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

     function ReadReplicationParams(Section:string): TReplicationParams;

  public
      procedure Start();
      procedure Stop();
      constructor Create();
      destructor Destroy(); override;
  // >> =======================  IHTZ =========================
      function GetImage(_pTile : TTileData; var _fExist : Boolean) : TPNGImage;
      // Базовая каринка - которая передается
      function GetBaseImage(_pTile : TTileData) : TPNGImage;
      // Картинка на которой рисуется
      function GetBase2Image(_pTile : TTileData; _fTransp : Boolean) : TBitMap;
      // Инициализация
      function Init() : HRESULT;
      // Извлекает данные из клиентского запроса
      function getDataFromParams(_pParams : TStrings) : TTileData;
      function CheckGeneralWorkParams(const _pParams : TStrings; var _iProfileID : Integer) : Boolean;
      function AddDataToLogTS(const _sString : string; const _iCode : Integer; const _sError : string = '') : Boolean;
      function GetErrorDescr(_iErr : HRESULT) : string;
  // << =======================  IHTZ =========================
      property Started : Boolean     read fStarted     write SetStarted;
  end;

  TProfileReqType   = (rtNone, rtIHTZDelProf, rtIHTZAddProf, rtIHTZSetProf, rtIHTZUPDProf);

implementation

uses itob_replication_socket, ImcsUtils,
   itob_ext_functions, itob_chart_render,
   IniFiles, StrUtils, ZipForge, uAdds, uCSMConst;

var
    pLogSection : TCriticalSection;

{ TCsmSvcHandlier }

constructor TCsmSvcHandlier.Create;
begin
    inherited;
    fStarted := false;
    fHttpServer := TIdHTTPServer.Create(nil);
    fHttpServer.OnCommandGet := HTTPServerCommandGet;

    fHtmlDir := GetInstancePath + 'htdocs';
    if NOT DirectoryExists(fHtmlDir) then
       CreateDir(fHtmlDir);

    if NOT DirectoryExists(fHtmlDir+'\cache') then
       CreateDir(fHtmlDir+'\cache');

    fReplicationEnabled := true;

    fFileVersion := ImcsUtils.FileVersion(GetInstancePath+'CsmSvc.exe');
    // Создание хранилища профилей
    pStorage := TIHZStorage.Create(GetInstancePath());
    pStorage.Init();
    pTileServer := TTileHTTPServer.Create();    
    pTileServer.Init('CsmSvc.ini');
end;
// --------------------------------------------------------------------

destructor TCsmSvcHandlier.Destroy();
begin
    if(fStarted) then Stop();
    if(fHttpServer.Active) then fHttpServer.Active := false;
    FreeAndNil(fHttpServer);
    FreeAndNil(pTileServer);
    FreeAndNil(pStorage);
    inherited;
end;
// ------------------------------------------------------------

procedure TCsmSvcHandlier.HandleSetMapData(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var PostedString: string;
    ByteValue: Byte;
    SL: TStringList;
    Guid: TGUID;
    CacheFileName: string;
begin
   //

   AResponseInfo.ContentType := S_CT_UTF8;

   CreateGUID(Guid);
   CacheFileName := LowerCase(GUIDToString(Guid));
   CacheFileName := LeftStr(CacheFileName, Length(CacheFileName)-1);
   CacheFileName := RightStr(CacheFileName, Length(CacheFileName)-1) +'.html';

   try

     ARequestInfo.PostStream.Position := 0;

     PostedString := '';
     ByteValue := 0;
     while ARequestInfo.PostStream.Read(ByteValue, 1) > 0 do
       PostedString := PostedString + String(AnsiChar(ByteValue));

     SL := TStringList.Create;
     try
       SL.Text := PostedString;

       if NOT DirectoryExists(fHtmlDir + '\cache') then
         CreateDir(fHtmlDir + '\cache');

       SL.SaveToFile(fHtmlDir + '\cache\' + CacheFileName);

     finally
       FreeAndNil(SL);
     end;

     AResponseInfo.ContentText := '/cache/' + CacheFileName;
   except
     On E: Exception do
     begin
       AResponseInfo.ResponseNo := 404;
       AResponseInfo.ContentText :=
         'Error insert map data to cache: ' + E.Message;

     end;
   end;

end;

procedure TCsmSvcHandlier.HandleGetServiceStatus(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var i: integer;
    CheckComStatus: string;
begin
   //

	 AResponseInfo.ContentType := S_CT_UTF8;

   if NOT fReplicationEnabled then begin
      AResponseInfo.ContentText := 'Replication is not enabled';
      exit;
   end;

   AResponseInfo.ContentText :=
      '<html>'+#13#10+
      '<head>'+#13#10+
      '<title>CsmService status</title>'+#13#10+
      '<meta http-equiv="Refresh" content="10; URL=http://'+ARequestInfo.Host+ARequestInfo.Document
         +'?'+ARequestInfo.UnparsedParams+'">'+#13#10+
      '</head>'+#13#10+
      '<body>'+#13#10+
      '<table width="700" border="1" cellspacing="0" cellpadding="0" bordercolor="#999999">'+#13#10+
      '  <tr>'+#13#10+
      '    <td width="30" align="center" valign="top"><b>#</b></td>'+#13#10+
      '    <td width="110" align="center" valign="top"><b>Thread name</b></td>'+#13#10+
      '    <td width="180" align="center" valign="top"><b>ComConnector status</b></td>'+#13#10+
      '    <td width="180" align="center" valign="top"><b>Last success replication</b></td>'+#13#10+
      '    <td width="110" align="center" valign="top"><b>Replication seconds ago</b></td>'+#13#10+
      '    <td width="90" align="center" valign="top"><b>Records counter</b></td>'+#13#10+
      '  </tr>';

   try

     for i := 0 to Length(fReplicationThreads)-1 do begin

        if fReplicationThreads[i].ReplicationSocket.CheckComConnection then
           CheckComStatus := 'OK'
        else
           CheckComStatus := 'ERROR';

        AResponseInfo.ContentText := AResponseInfo.ContentText + #13#10 +
          '  <tr>'+#13#10+
          '    <td align="center" valign="top">'+IntToStr(i+1)+'</td>'+#13#10+
          '    <td align="center" valign="top">'+fReplicationThreads[i].ThreadName+'</td>'+#13#10+
          '    <td align="center" valign="top">'+CheckComStatus+'</td>'+#13#10+
          '    <td align="center" valign="top">'
              + DateTimeToStr(fReplicationThreads[i].ReplicationSocket.LastSuccessReplication)+'</td>'+#13#10+
          '    <td align="center" valign="top">'
              + IntToStr(SecondsBetween(Now,fReplicationThreads[i].ReplicationSocket.LastSuccessReplication))+'</td>'+#13#10+
          '    <td align="center" valign="top">'
              + IntToStr(fReplicationThreads[i].ReplicationSocket.RecordedRecordsCounter)+'</td>'+#13#10+
          '  </tr>';

     end;

   except
     On E: Exception do
     begin
       AResponseInfo.ResponseNo := 404;
       AResponseInfo.ContentText :=
         'Error get service status: ' + E.Message;

     end;
   end;

   AResponseInfo.ContentText := AResponseInfo.ContentText + #13#10 +
      '</table>'+#13#10+
      '</body>'+#13#10+
      '</html>';

end;

procedure TCsmSvcHandlier.HandleCheckServiceStatus(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var i: integer;
    ParamName: string;
    ParamValue: string;
    CheckStatus: string;
    LastSuccessReplication: TDateTime;
    t: integer;
begin
   //

   t := 60 * 30; // 30 minutes timeout

	 AResponseInfo.ContentType := S_CT_UTF8;

	 if NOT fReplicationEnabled then begin
      AResponseInfo.ContentText := 'Replication is not enabled';
      exit;
   end;

   try

     for i := 0 to ARequestInfo.Params.Count - 1 do begin
        ParamName := AnsiLeftStr(ARequestInfo.Params[i], Pos('=',ARequestInfo.Params[i])-1);
        ParamValue := AnsiRightStr(ARequestInfo.Params[i], Length(ARequestInfo.Params[i]) - Pos('=',ARequestInfo.Params[i]));

        if CompareText(ParamName,'t') = 0 then t := StrToInt(ParamValue);

     end;
   except
      On E: Exception do
      begin
         AResponseInfo.ResponseNo := 404;
         AResponseInfo.ContentText :=
           'Error parsing params: ' + E.Message;

      end;
   end;

   CheckStatus := 'OK';

   try

     for i := 0 to Length(fReplicationThreads)-1 do begin

        if NOT fReplicationThreads[i].ReplicationSocket.CheckComConnection then begin
           CheckStatus := 'ERROR';
           Break;
        end;

        LastSuccessReplication := fReplicationThreads[i].ReplicationSocket.LastSuccessReplication;
        if SecondsBetween(Now,LastSuccessReplication) > t then begin
           CheckStatus := 'ERROR';
           Break;
        end;

     end;

   except
     On E: Exception do
     begin
       AResponseInfo.ResponseNo := 404;
       AResponseInfo.ContentText :=
         'Error get service status: ' + E.Message;

     end;
   end;

   AResponseInfo.ContentText := CheckStatus;

end;

// TODO -oawod : !!!Требуется перенести в SDK!!!
function UnCompressZipStream(const _sDir : string; const _pFileZip : TStream) : HRESULT;
var
	pZipArc : TZipForge;
begin
	Result := S_OK;
	pZipArc := TZipForge.Create(nil);
	try
		try
			with pZipArc do
			begin
				Options.Recurse := true;
				BaseDir := _sDir;
				OpenArchive(_pFileZip,false);
				ExtractFiles('*.*');
				CloseArchive();
			end;
		except
			on E: Exception do raise E;
		end;
	finally
		FreeAndNil(pZipArc);
	end;
end;


procedure TCsmSvcHandlier.HandleCreateCacheDir(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
	Guid: TGUID;
  CachePathName: string;
begin
	AResponseInfo.ContentType := S_CT_UTF8;

	CreateGUID(Guid);
	CachePathName := LowerCase(GUIDToString(Guid));
	CachePathName := LeftStr(CachePathName, Length(CachePathName)-1);
	CachePathName := RightStr(CachePathName, Length(CachePathName)-1);

	try
		ARequestInfo.PostStream.Position := 0;

		if NOT DirectoryExists(fHtmlDir + '\cache') then
			CreateDir(fHtmlDir + '\cache');
		if NOT DirectoryExists(fHtmlDir + '\cache\'+CachePathName) then//Проверка на всякий случай. Ясно что не повториться.
			CreateDir(fHtmlDir + '\cache\'+CachePathName);

		UnCompressZipStream(CachePathName,ARequestInfo.PostStream);;
		AResponseInfo.ContentText := '/cache/' + CachePathName;
	except
		On E: Exception do
		begin
			AResponseInfo.ResponseNo := 404;
			AResponseInfo.ContentText := 'Error insert map data to cache: ' + E.Message;
		end;
	end;
end;

procedure TCsmSvcHandlier.HandleProxyRequest(AContext: TIdContext;
        ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var 
    i                  : integer;
    ParamName          : string;
    ParamValue         : string;
    URL                : string;
    HTTPClient         : TIdHTTP;
    ReplicationParams  : TReplicationParams;
    ContentText        : string;
    pSSLHandler        : TIdSSLIOHandlerSocketOpenSSL;
begin

   URL := '';
   AResponseInfo.ContentText := '';
   AResponseInfo.ContentType := S_CT_UTF8;

   try

     for i := 0 to ARequestInfo.Params.Count - 1 do begin
        ParamName := AnsiLeftStr(ARequestInfo.Params[i], Pos('=',ARequestInfo.Params[i])-1);
        ParamValue := AnsiRightStr(ARequestInfo.Params[i], Length(ARequestInfo.Params[i]) - Pos('=',ARequestInfo.Params[i]));

        if CompareText(ParamName,'url') = 0 then URL := ParamValue;

     end;
   except
      On E: Exception do
      begin
         AResponseInfo.ResponseNo := 404;
         AResponseInfo.ContentText :=
           'Error parsing params: ' + E.Message;

      end;
   end;

   if (URL = '') then begin
      AResponseInfo.ContentText := 'Empty URL';
      exit;
   end;

   if (AnsiPos('$amp;', URL) > 0) then URL := AnsiReplaceStr(URL, '$amp;', '&');

   HTTPClient := TIdHTTP.Create(nil);
//   HTTPClient.
   HTTPClient.ConnectTimeout := 10000;
   HTTPClient.ReadTimeout    := 10000;

   HTTPClient.IOHandler := TIdIOHandlerStack.Create(nil);
   HTTPClient.IOHandler.ReadTimeout := 10000;
   HTTPClient.IOHandler.ConnectTimeout := 10000;
   pSSLHandler := nil;
   if(PosEx('HTTPS', AnsiUpperCase(URL)) > 0) then
   begin
       pSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
       HTTPClient.IOHandler := pSSLHandler;       
   end;

   ReplicationParams := ReadReplicationParams('replication');

   if ReplicationParams.ProxyType <> ptNoProxy then begin
      HTTPClient.ProxyParams.ProxyServer := ReplicationParams.ProxyHost;
      HTTPClient.ProxyParams.ProxyPort := ReplicationParams.ProxyPort;
      if ReplicationParams.ProxyAuthentication then begin
         HTTPClient.ProxyParams.BasicAuthentication := true;
         HTTPClient.ProxyParams.ProxyUsername := ReplicationParams.ProxyLogin;
         HTTPClient.ProxyParams.ProxyPassword := ReplicationParams.ProxyPwd;
      end;
   end;

   try
       ContentText := HTTPClient.Get(URL);

   except
      On E: Exception do begin
         ContentText := 'ERROR: '+E.Message;
      end;
   end;

   AResponseInfo.ContentText := ContentText;

   if HTTPClient.Connected then HTTPClient.Disconnect;
   FreeAndNil(HTTPClient);
   FreeAndNil(pSSLHandler);
end;

procedure TCsmSvcHandlier.HandleRemoveCacheDir(AContext: TIdContext;
	ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
	i: integer;
	ParamName: string;
	ParamValue: string;
//	LastSuccessReplication: TDateTime;
	lFind : boolean;
begin
	AResponseInfo.ContentType := S_CT_UTF8;

	try
  	lFind := false;
		for i := 0 to ARequestInfo.Params.Count - 1 do begin
			ParamName := AnsiLeftStr(ARequestInfo.Params[i], Pos('=',ARequestInfo.Params[i])-1);
			ParamValue := AnsiRightStr(ARequestInfo.Params[i], Length(ARequestInfo.Params[i]) - Pos('=',ARequestInfo.Params[i]));

			if CompareText(ParamName,'dir') = 0 then begin
				lFind := true;
				Break;
			end;
		end;
		if not lFind then
			raise Exception.Create('Отсутствует параметр dir');
	except
		on E: Exception do
		begin
			AResponseInfo.ResponseNo := 404;
			AResponseInfo.ContentText := 'Error parsing params: ' + E.Message;
		end;
	end;

	try
		try
			StringToGUID('{'+ParamValue+'}');
    except
			raise Exception.Create('Ошибка формата входных параметров');
    end;



		DeleteDir(fHtmlDir + '\cache\'+ParamValue,True);

		AResponseInfo.ContentText := 'OK';
	except
		on E: Exception do
		begin
			AResponseInfo.ResponseNo := 404;
			AResponseInfo.ContentText :=
				'Error in RemoveCacheDir: ' + E.Message;
		end;
	end;
end;

// ----------------------------------------------------------------

procedure IfAssignStreamThenWrite(_pRespInfo : TIdHTTPResponseInfo; _pStream : TStream; const _sType : string);
begin
    if(Assigned(_pStream)) then
    begin
        _pStream.Position := 0;
        if(_sType <> '') then _pRespInfo.ContentType := _sType;
        _pRespInfo.ContentStream := _pStream;
        _pRespInfo.ContentLength := _pRespInfo.ContentStream.Size;
        _pRespInfo.WriteHeader;
        _pRespInfo.WriteContent;
    end;
end;
// ----------------------------------------------------------------

procedure TCsmSvcHandlier.HTTPServerCommandGet(AContext: TIdContext;
                                               ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
    LFilename, LPathname: string;
    ReplicationSocket: TReplicationSocket;
    ReplicationParams: TReplicationParams;
    ConnResult, ReplicThreads: string;
    SL: TStringList;
    j: integer;
    TestPageContent: string;
    // >> DENIS
    pStream                          : TStream;
    pMStream                         : TMemoryStream;
    pImg                             : TPNGImage;
    pTile                            : TTileData;
    pRes                             : TTileParams;
    iProfID                          : Integer;
    pProfile                         : TIHZProfile;
    sPath, sResp, sLog               : string;
    iRes                             : HRESULT;
    fExists                          : Boolean;
    contentType                      : string;
    i_err                            : byte;
    // << DENIS

    procedure _locAddProfiles(const _sLogSection : string; const _ProfileOper : TProfileReqType;
      const _iLocProfileID : integer = -1);
    begin
      pMStream := TMemoryStream.Create();
      try
          if(Assigned(ARequestInfo.PostStream)) then
          begin
              AddDataToLogTS(Format(_sLogSection, [ARequestInfo.RemoteIP]), S_OK);
              if _ProfileOper = rtIHTZSetProf  then
                pProfile := pStorage.SetProfTS(_iLocProfileID)
              else if _ProfileOper = rtIHTZAddProf  then
                pProfile := pStorage.AddProfTS()
              else if _ProfileOper = rtIHTZUPDProf  then
                pProfile := pStorage.UPDProfTS(_iLocProfileID)
              else pProfile := nil;

              if not Assigned(pProfile)  then
              begin
                raise Exception.Create('Не верно передана команда для работы с профайлами. '+S_NOT_ADDED);
              end;
              ARequestInfo.PostStream.Position := 0;
              pMStream.CopyFrom(ARequestInfo.PostStream, ARequestInfo.PostStream.Size);
              sPath := GetInstancePath() + S_PROF_DIR + IntToStr(pProfile.iNum)  + S_XML_EXT;
              sLog  := S_NOT_ADDED;
              sResp := S_FALSE_RESP;
              iRes := pProfile.ReadXmlStream(sPath, pMStream, false,_ProfileOper = rtIHTZUPDProf);
              if(iRes = S_OK) then
              begin
                  sLog  := Format(_sLogSection, [IntToStr(pProfile.iNum)]);
                  sResp := IntToStr(pProfile.iNum);
              end;
              pStream := TStringStream.Create(sResp);
              AddDataToLogTS(sLog, iRes);
              IfAssignStreamThenWrite(AResponseInfo, pStream, S_TXT_D_TYPE);
              pProfile.SaveToXml(GetInstancePath() + '/Profiles/' + IntToStr(pProfile.iNum) + '.xml');
          end;
      finally
            FreeAndNil(pMStream);
      end;
    end;

begin
  i_err:=0;
  pIMG := nil;
  pTile := nil;
  CoInitialize(nil);

  AResponseInfo.CharSet := 'UTF-8';
  AResponseInfo.ContentEncoding := 'UTF-8';

  try
  try

  if CompareText(ARequestInfo.Document, '/RenderChart') = 0 then begin
      itob_chart_render.HandleRenderChart(AContext, ARequestInfo, AResponseInfo);

  end
  else if CompareText(ARequestInfo.Document, '/SetMapData') = 0 then begin
      //
      HandleSetMapData(AContext, ARequestInfo, AResponseInfo);

  end
  else if CompareText(ARequestInfo.Document, '/CreateCacheDir') = 0 then begin
      //
      HandleCreateCacheDir(AContext, ARequestInfo, AResponseInfo);

	end
	else if CompareText(ARequestInfo.Document, '/RemoveCacheDir') = 0 then begin
      //
      HandleRemoveCacheDir(AContext, ARequestInfo, AResponseInfo);

  end
  else if CompareText(ARequestInfo.Document, '/Status') = 0 then begin
      //
      HandleGetServiceStatus(AContext, ARequestInfo, AResponseInfo);

  end
  else if CompareText(ARequestInfo.Document, '/CheckStatus') = 0 then begin
      //
      HandleCheckServiceStatus(AContext, ARequestInfo, AResponseInfo);

  end
  else if CompareText(ARequestInfo.Document, '/Version') = 0 then begin
      //
      AResponseInfo.ContentType := S_CT_UTF8;
      AResponseInfo.ContentText := fFileVersion;

  end
  else if CompareText(ARequestInfo.Document, '/TestRequest') = 0 then begin
      //
      AResponseInfo.ContentType := S_CT_UTF8;
      AResponseInfo.ContentText := 'OK';

  end
  else if CompareText(ARequestInfo.Document, '/ProxyRequest') = 0 then begin
      //
      HandleProxyRequest(AContext, ARequestInfo, AResponseInfo);

  end
  else if CompareText(ARequestInfo.Document, '/Test') = 0 then begin
			AResponseInfo.ContentType := S_CT_UTF8;
{svs}//      AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Headers','*');
//       AResponseInfo.RawHeaders.AddValue();

      if fReplicationEnabled then begin
         AResponseInfo.ContentText := 'For test, you must disable replication!<br>Set [replication] enabled=0 , restart service, and refresh this page';
         exit;
      end;

      with TIniFile.Create(GetInstancePath+'CsmSvc.ini') do begin
         ReplicThreads := Trim(ReadString('replication','threads',''));
         Free;
      end;

      if (ReplicThreads='') then ReplicThreads := 'replication';

      TestPageContent :=
        '<html><head> '+
        '<meta http-equiv="Content-Type" content="text/html; charset=windows-1251" /> '+
        '<title>CsmSvc test result</title> '+
        '<style type="text/css"> '+
        '<!-- '+
        '.ok { '+
        '	color: #090; '+
        '	font-weight:bold; '+
        '} '+
        '.error { '+
        '	color: #F00; '+
        '	font-weight:bold; '+
        '} '+
        '--> '+
        '</style> '+
        '</head> '+
        '<body>';

      SL := TStringList.Create;
      try
        SL.Delimiter := ',';
        SL.DelimitedText := ReplicThreads;

        for j := 0 to SL.Count - 1 do
        begin
          ReplicationParams := ReadReplicationParams(SL.Strings[j]);

          TestPageContent := TestPageContent+
             '<h2>['+SL.Strings[j]+']</h2> ';

          if (Trim(ReplicationParams.Server) = '') OR
            (ReplicationParams.Port = 0) OR
            (Trim(ReplicationParams.Login) = '') OR
            (Trim(ReplicationParams.InfoBaseConnectionString) = '') then
          begin

            TestPageContent := TestPageContent +
                'Указано недостаточно параметров для запуска потока';

            Continue;
					end;

          ReplicationSocket := TReplicationSocket.Create(ReplicationParams);

          try

             try
                if NOT ReplicationSocket.CreateComConnector() then
                   TestPageContent := TestPageContent +
                      '<span class="error">1C COM connection error: '+ReplicationSocket.LastError+'</span>'
                else
                   TestPageContent := TestPageContent +
                      '<span class="ok">1C COM connection: OK</span>';

             except
                On E: Exception do begin
                   TestPageContent := TestPageContent +
                      '<span class="error">1C COM connection error: '+E.Message+'</span>';
                end;
             end;

             try
                ReplicationSocket.ConnectToServer(ConnResult);
                TestPageContent := TestPageContent +
                  '<br>' + '<span class="ok">Connect to replication server: '+ConnResult+'</span>';

             except
                On E: Exception do begin
                   TestPageContent := TestPageContent +
                      '<br>' +  '<span class="error">Connect to replication server ERROR: '+E.Message+'</span>';
                end;
             end;

          finally
             FreeAndNil(ReplicationSocket);
          end;

        end;

      finally
        FreeAndNil(SL);
      end;

      TestPageContent := TestPageContent + '</body></html>';
      AResponseInfo.ContentEncoding := 'windows-1251';
      AResponseInfo.ContentStream := TStringStream.Create;
      TStringStream(AResponseInfo.ContentStream).WriteString(TestPageContent);


// ================================== IHTZ ============================================
  end else if((ARequestInfo.Document = S_REQ_GENERAL)) then begin
      if(CheckGeneralParams(ARequestInfo.Params, pRes)) then
      begin
          pStream := TMemoryStream.Create();
          pTile := TTileData.Create();
          pTile.iXCoord := pRes.fiXCoord;
          pTile.iYCoord := pRes.fiYCoord;
          pTile.iZoom   := pRes.fiZoom;
          pTile.iWidth := 256;
          pTile.iHeight := 256;
          pTile.AdjustCoord(pRes);
          pTile.pProfile := pStorage.LockProfTS(pRes.fiTileFormat);
          try
              if(Assigned(pTile.pProfile)) then
              begin
                  // Проверка кэша
                  //ForceDirectories(GetInstancePath() + S_DIR_TILES);
                  i_err:=1;
                  pImg := pTile.LoadImgFromFile(GetInstancePath() + S_DIR_TILES);
                  i_err:=2;
                  //if(not Assigned(pImg)) then
                  //begin
                      pImg := GetImage(pTile, fExists);
                  i_err:=3;
                  //    if(fExists) then pTile.SaveImgToFile(GetInstancePath() + S_DIR_TILES, pImg);
                  //end;
                  pImg.SaveToStream(pStream);
                  i_err:=4;
                  IfAssignStreamThenWrite(AResponseInfo, pStream, S_IMG_D_TYPE);
              end else begin
                  AddDataToLogTS(Format(S_NO_PROFILE, [ARequestInfo.RemoteIP, IntToStr(pRes.fiTileFormat),
                                                       IntToStr(pTile.iXCoord),
                                                      IntToStr(pTile.iYCoord), IntToStr(pTile.iZoom)]), S_OK);
              end;
          finally
              if(Assigned(pTile.pProfile)) then
                  pStorage.UnLockProfTS(pRes.fiTileFormat, pTile.pProfile);
              pTile.pProfile := nil;
          end;
      end;
  end else if(ARequestInfo.Document = S_REQ_DEL_PROF) then begin
      if(not CheckGeneralWorkParams(ARequestInfo.Params, iProfID)) then
      begin
          AddDataToLogTS(Format(S_NO_DEL_PROFILE, [ARequestInfo.RemoteIP]), S_OK);
          Exit;
      end;
      AddDataToLogTS(Format(S_DEL_PROFILE, [IntToStr(iProfID), ARequestInfo.RemoteIP]), S_OK);
      sResp := S_FALSE_RESP;
      sLog  := Format(S_NOT_DEL_PROFILE, [IntToStr(iProfID)]);
      iRes := pStorage.DelProfTS(iProfID);
      if(iRes = S_OK) then
      begin
          sResp := S_OK_RESP;
          sLog  := Format(S_DELETED_PROFILE, [IntToStr(iProfID), ARequestInfo.RemoteIP]);
       end;
       pStream := TStringStream.Create(sResp);
       IfAssignStreamThenWrite(AResponseInfo, pStream, S_TXT_D_TYPE);
       AddDataToLogTS(sLog, iRes);
  end else if(ARequestInfo.Document = S_REQ_ADD_PROF) then  begin
{-svs-}
      AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Origin: *');
      AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Headers: *');
      AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Methods: *');
{-svs-}
      _locAddProfiles(S_SETING_PROFILE,rtIHTZAddProf);
  end else if(ARequestInfo.Document = S_REQ_SET_PROF) then  begin
      if(not CheckGeneralWorkParams(ARequestInfo.Params, iProfID)) then
      begin
          AddDataToLogTS(Format(S_SETING_PROFILE, [ARequestInfo.RemoteIP]), S_OK);
          Exit;
      end;
      AddDataToLogTS(Format(S_SETING_PROFILE, [IntToStr(iProfID), ARequestInfo.RemoteIP]), S_OK);
      sResp := S_FALSE_RESP;
      sLog  := Format(S_SETING_PROFILE, [IntToStr(iProfID)]);

      _locAddProfiles(S_SETING_PROFILE,rtIHTZSetProf,iProfID);
  end else if(ARequestInfo.Document = S_REQ_UPD_PROF) then  begin
      if(not CheckGeneralWorkParams(ARequestInfo.Params, iProfID)) then
      begin
          AddDataToLogTS(Format(S_SETING_PROFILE, [ARequestInfo.RemoteIP]), S_OK);
          Exit;
      end;
      AddDataToLogTS(Format(S_SETING_PROFILE, [IntToStr(iProfID), ARequestInfo.RemoteIP]), S_OK);
      sResp := S_FALSE_RESP;
      sLog  := Format(S_SETING_PROFILE, [IntToStr(iProfID)]);

      _locAddProfiles(S_SETING_PROFILE,rtIHTZUPDProf,iProfID);

// ================================== IHTZ ============================================
// ========================= Тайловый сервер ==========================================
  end  else if(ARequestInfo.Document = S_REQ_NEW_TILE_PROF) then  begin
     pTileServer.pHTTPServerCommandGet(AContext, ARequestInfo, AResponseInfo);
// ========================= Тайловый сервер ==========================================
  end  else begin // обычная передача файлов
     LFilename := ARequestInfo.Document;
     if LFilename = '/' then begin
         LFilename := '/index.html';
     end;

     LFilename := AnsiReplaceStr(LFilename, '/', '\');
     LPathname := fHtmlDir + LFilename;

     if FileExists(LPathname) then begin
        AResponseInfo.ContentStream := TFileStream.Create(LPathname, fmOpenRead + fmShareDenyWrite);
     end else begin
       AResponseInfo.ResponseNo := 404;
       AResponseInfo.ContentText := 'The requested URL ' + ARequestInfo.Document
          + ' was not found on this server.';

     end;

		 contentType := AResponseInfo.HTTPServer.MIMETable.GetFileMIMEType(LPathname);
     if Pos('charset',contentType) > 0 then begin
        contentType := LeftStr(contentType, Pos('charset',contentType)-1);
        contentType := contentType + 'charset=UTF-8';
     end
     else begin
        contentType := Trim(contentType) + '; charset=UTF-8';
     end;
     AResponseInfo.ContentType := contentType;

  end;
  except
     On E: Exception do begin
				 WriteToLog('HTTPServerCommandGet error: '+E.Message + ' . ARequestInfo.Document='+ARequestInfo.Document+'  '+IntToStr(i_err));
     end;

  end;
  finally
       CoUnInitialize();
       FreeAndNil(pImg);
       FreeAndNil(pTile);
  end;
end;

function TCsmSvcHandlier.ReadReplicationParams(Section:string): TReplicationParams;
begin
  with TIniFile.Create(GetInstancePath + 'CsmSvc.ini') do
  begin
    Result.Server := ReadString(Section, 'Server', 'gps.itob.ru');
    Result.Port := ReadInteger(Section, 'Port', 6720);
    Result.Login := ReadString(Section, 'Login', '');
    Result.Password := ReadString(Section, 'Password', '');
    Result.Interval := ReadInteger(Section, 'Interval', 60);
    Result.InfoBaseConnectionString := ReadString(Section, 'InfoBaseConnectionString', '');
    Result.EnterpriseVersion := ReadString(Section, 'EnterpriseVersion', '8.2');
    Result.fSSL     := ReadString(Section, 'SSL', '') = '1';

    Result.ProxyType := TProxyTypes(ReadInteger('replication', 'ProxyType', 0));
    Result.ProxyHost := ReadString('replication', 'ProxyHost', '');
    Result.ProxyPort := ReadInteger('replication', 'ProxyPort', 8080);
    Result.ProxyAuthentication := ReadBool('replication', 'ProxyAuthentication', false);
    Result.ProxyLogin := ReadString('replication', 'ProxyLogin', '');
    Result.ProxyPwd := ReadString('replication', 'ProxyPwd', '');

    Result.ReadTimeout := ReadInteger('replication', 'ReadTimeout', 600);

    Free;
  end;
end;

procedure TCsmSvcHandlier.SetStarted(Value: boolean);
begin

end;

procedure TCsmSvcHandlier.Start();
var ReplicationParams: TReplicationParams;
    ReplicThreads: string;
    SL: TStringList;
    j: integer;
begin

   if FStarted then Exit;

   try

      with TIniFile.Create(GetInstancePath+'CsmSvc.ini') do begin

         fHttpServer.DefaultPort     := ReadInteger('http','Port',8091);
         fReplicationEnabled         := ReadBool('replication','Enabled',true);
         ReplicThreads := Trim(ReadString('replication','threads',''));
         fDebugMode                  := ReadBool('replication','DebugMode',false);

         Free;
      end;
      // IHIZ;
//      Init();


      fHttpServer.Active := true;

      if fReplicationEnabled then begin

         // Совместимость со старой версией INI файла
         if (ReplicThreads='') then ReplicThreads := 'replication';

         SL := TStringList.Create;
         try
            SL.Delimiter := ',';
            SL.DelimitedText := ReplicThreads;

            for j := 0 to SL.Count - 1 do begin
                ReplicationParams := ReadReplicationParams(SL.Strings[j]);
                if (TRIM(ReplicationParams.Server)='')
                   OR (ReplicationParams.Port=0)
                   OR (TRIM(ReplicationParams.Login)='')
                   OR (TRIM(ReplicationParams.InfoBaseConnectionString)='') then begin

                   WriteToLog('Для секции репликации "'+SL.Strings[j]+'" указано недостаточно параметров для запуска потока');
                   Continue;
                end;

                SetLength(fReplicationThreads, Length(fReplicationThreads)+1);
                fReplicationThreads[Length(fReplicationThreads)-1] := TReplicationThread.Create(False, ReplicationParams);
                fReplicationThreads[Length(fReplicationThreads)-1].ThreadName := SL.Strings[j];
                fReplicationThreads[Length(fReplicationThreads)-1].DebugMode := fDebugMode;

                fReplicationThreads[Length(fReplicationThreads)-1].FreeOnTerminate := true;

            end;

         finally
            FreeAndNil(SL);
         end;

      end;

      // clear cache map files
      ImcsUtils.ClearDir(fHtmlDir + '\cache');

      FStarted := true;

   except
      On E: Exception do begin
         WriteToLog('CsmSvcHandlier.Start error: '+E.Message);
      end;
   end;


end;

procedure TCsmSvcHandlier.Stop;
var j: integer;
begin
   if NOT FStarted then exit;

   if fReplicationEnabled then begin

      for j := 0 to Length(fReplicationThreads) - 1 do begin
          try
             fReplicationThreads[j].ReplicationSocket.CloseComConnection;
          except
          end;
          TerminateThread(fReplicationThreads[j].Handle,0);
          fReplicationThreads[j] := nil;
      end;

   end;

   fHttpServer.StopListening;
   fHttpServer.Active := false;

   FStarted := false;

end;
// ----------------------------------------------------------

// ===========================================================================================
// ================================= IHTZ ====================================================
// ===========================================================================================

function TCsmSvcHandlier.Init() : HRESULT;
begin
    try
        Result := FillProfList();
        if(Result <> S_OK) then Exit;
        pStorage.Init();
        fpClearImg := TPngImage.Create();
        fpClearImg.LoadFromFile(GetInstancePath() + S_DIR_IMG + S_CLEAR_IMG);
    except
        Result := E_NO_INIT;
        pHTTPServer.Active := false;
    end;
end;
// -------------------------------------------------------------------------------------------------------

function TCsmSvcHandlier.FillProfList() : HRESULT;
begin
    Result := S_OK;
end;
// -----------------------------------------------------------------------------

function TCsmSvcHandlier.getDataFromParams(_pParams: TStrings): TTileData;
begin
    Result := nil;
end;
// -----------------------------------------------------------------------------

function TCsmSvcHandlier.GetBaseImage(_pTile : TTileData) : TPNGImage;
begin
    Result := TPNGImage.Create();
    if(not Assigned(_pTile)) then Exit;
    Result.Transparent := true;
end;
// -----------------------------------------------------------------------------

function TCsmSvcHandlier.GetBase2Image(_pTile : TTileData; _fTransp : Boolean) : TBitMap;
begin
    Result := TBitMap.Create();
    Result.PixelFormat := pf8bit;
    if(not Assigned(_pTile)) then Exit;
    Result.SetSize(_pTile.iWidth, _pTile.iHeight);
    Result.Canvas.Brush.Color := clWhite;
    Result.Canvas.FillRect(Rect(0,0, 256,256));
    Result.Transparent := _fTransp;
end;
// -----------------------------------------------------------------------------


function TCsmSvcHandlier.GetErrorDescr(_iErr: HRESULT): string;
begin
    case _iErr of
      E_NO_FILE_READ  : Result := 'Ошибка чтения профиля';
      E_NO_ROF_TYPE   : Result := 'Неизвестный тип профиля';
      E_ZONE_SAVE     : Result := 'Ошибка сохранения геозоны';
      E_PROFILE_SAVE  : Result := 'Ошибка сохранения профиля';
      E_DEL_TILES_ER  : Result := 'Ошибка очистки тайлов';
      E_NO_BIT_BLT    : Result := 'Ошибка копирования изображений BitBlt';
      else Result := IntToStr(E_NO_BIT_BLT);
    end;
end;
// -----------------------------------------------------------------------------

function TCsmSvcHandlier.GetImage(_pTile : TTileData; var _fExist : Boolean) : TPNGImage;
var
//    pMap, pMap2    : TBitMap;
//    pMap3          : TBitMap;
    fExists        : Boolean;
begin
    Result := GetBaseImage(_pTile);
    try
        if(Assigned(_pTile.pProfile)) then _pTile.pProfile.Draw(_pTile, fExists);
        _fExist := true;
        // Пустое изображение
        if((not fExists) and Assigned(fpClearImg))then
        begin
            Result.Assign(fpClearImg);
            _fExist := false;
            Exit;
        end;
        Result.Assign(_pTile.pProfile.pImage);
        Result.TransparentColor := clWhite;
    except
//svs    finally
//        pMap3.Free;
//        pMap2.Free();
    end;
end;
// -----------------------------------------------------------------------------

function TCsmSvcHandlier.AddDataToLogTS(const _sString: string; const _iCode: Integer; const _sError: string): Boolean;
var
    pLog    : TStringList;
    sData   : string;
    sErr    : string;
begin
    Result := true;
    pLog := TStringList.Create();
    pLogSection.Enter();
    try
        try
            try
                pLog.LoadFromFile(GetInstancePath() + S_LOG_FILE_NAME);
            except
                pLog.Clear();
            end;
            if(_iCode = S_OK) then
                sData := Format(S_LOG_F_STR_S, [DateTimeToStr(Now()), _sString])
            else begin
                sErr  :=  GetErrorDescr(_iCode);
                if(sErr = '') then
                    sData := Format(S_LOG_F_STR, [DateTimeToStr(Now()), IntToStr(_iCode), _sString])
                else
                    sData := Format(S_LOG_F_STR_E, [DateTimeToStr(Now()), IntToStr(_iCode), sErr, _sString]);
            end;
            if(_sError <> '') then sData := sData + S_EXP_STR + _sError;
            pLog.Insert(0, sData);
            pLog.SaveToFile(GetInstancePath() + S_LOG_FILE_NAME);
        except
            Result := false;
        end;
    finally
        pLogSection.Leave();
        FreeAndNil(pLog);
    end;
end;
// ----------------------------------------------------------------------


function TCsmSvcHandlier.CheckGeneralParams(const _pParams : TStrings;
                                       var _pResParams : TTileParams) : Boolean;
var
    pRec    : TTileGeoRect;
begin
    if(not Assigned(_pResParams)) then  _pResParams := TTileParams.Create();
    Result := false;
    with _pResParams do
    begin
        if((not TryStrToInt(_pParams.Values[S_X_PARAM], fiXCoord)) or
           (not TryStrToInt(_pParams.Values[S_Y_PARAM], fiYCoord)) or
           (not TryStrToInt(_pParams.Values[S_Z_PARAM], fiZoom)) or
           (not TryStrToInt(_pParams.Values[S_PROFILE_PARAM], fiTileFormat))) then Exit;
        pRec          := GetTileGeoRect(fiXCoord, fiYCoord, fiZoom);
        frTop         := pRec.Lat0;
        frLeft        := pRec.Lon0;
        frRight       := pRec.Lon1;
        frBottom      := pRec.Lat1;
    end;
    Result := true;
end;
// ---------------------------------------------------------


function TCsmSvcHandlier.CheckGeneralWorkParams(const _pParams : TStrings;
                                           var _iProfileID : Integer) : Boolean;
begin
    Result := true;
    try
        _iProfileID  := StrToInt(_pParams.Values[S_PROFILE_PARAM]);
    except
        Result := false
    end;
end;
// ---------------------------------------------------------

initialization
   pLogSection := TCriticalSection.Create();

end.
