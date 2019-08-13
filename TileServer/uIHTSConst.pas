unit uIHTSConst;

interface
const
    // Константы для разбора запросов
    S_Z_PARAM           = 'itob_z';     // Параметр
    S_L_PARAM           = 'itob_map_id';
    S_HOST              = 'itob_host';
    S_X_PARAM           = 'itob_x';
    S_Y_PARAM           = 'itob_y';
    S_QUEST_SYMB        = '?';
    S_CP_SYMB           = '&';
    S_EQUAL_SYMB        = '=';
    S_SLASH_SYMB        = '/';
    S_BACK_SLASH_SYMB   = '\';
    S_Z_SYMB            = 'z';
    S_X_SYMB            = 'x';
    S_Y_SYMB            = 'y';
    A_EXT_LIST          : array [0..2] of string = ('.gif', '.jpeg', '.png');
    // Константы ini
    S_INI_FILE          = 'UtilServices.ini';
    S_IHTS_SERVICE      = 'TileServer';
    S_FILES_DIR         = 'CacheFiles\';
    S_FILES_PATH        = 'CacheFilesPath';
    S_PORT              = 'Port';
    S_NEXT_PROXY_NEED   = 'NeedChainProxy';
    S_NEXT_PROXY_PORT   = 'ChainProxyPort';
    S_NEXT_PROXY_HOST   = 'ChainProxyHost';
    S_NEXT_PROXY_AYTH   = 'ChainProxyNeedAuthentication';
    S_NEXT_PROXY_USER   = 'ChainProxyUser';
    S_NEXT_PROXY_PASS   = 'ChainProxyPass';
    S_ENABLED           = 'Enabled';
    S_CACHEINDB         = 'CacheInDB';

    I_CACHE_MODE_NAN    = -1;
    I_CACHE_MODE_FILE   = 0;
    I_CACHE_MODE_DB     = 1;

    // Поддержка SSL для сервера тайлов
    S_SSL               = 'ssl';
    S_SSLMainCert       = 'SSLMainCert';
    S_SSLRootCert       = 'SSLRootCert';
    S_SSLKey            = 'SSLKey';

    // Поддержка SQLITE
    S_CASHE_TILE        = 'cacheTile.sqlitedb';
    S_CASHE_TILE_DB_EXT = '.sqlitedb';
    S_CACHE_TILE_CREATE = 'CREATE TABLE IF NOT EXISTS TILES (X INTEGER, Y INTEGER, Z INTEGER, S INTEGER, IMAGE BLOB, PRIMARY KEY (x,y,z,s))';
    S_CACHE_INFO_CREATE = 'CREATE TABLE IF NOT EXISTS INFO (maxzoom INTEGER, minzoom INTEGER)';
    S_CACHE_INFO_CHECK  = 'SELECT count(*) FROM INFO';
    S_CACHE_INFO_INS_INI= 'INSERT INTO INFO (maxzoom, minzoom) values (-1 , 1000000000)';
    S_CACHE_INFO_SET    = 'UPDATE INFO set maxzoom = max(maxzoom, ?) , minzoom = min (minzoom, ?)';
    S_CACHE_TILE_INS    = 'INSERT INTO TILES (IMAGE, X, Y, Z, S) VALUES (?, ?, ?, ?, ?)';
    S_CACHE_TILE_EXS    = 'SELECT count(*) FROM TILES WHERE X = ? and Y = ? and Z = ? and S = ?';
    S_CACHE_TILE_SEL    = 'SELECT IMAGE FROM TILES WHERE X = ? and Y = ? and Z = ? and S = ?';
    S_TILE_DEF_SPARAM   = '0'; // На основании https://itob.planfix.ru/task/551/?comment=29182978


    S_LOG_FIELD         = 'UtilServicesLogs\IHTS_%s.txt';
    S_LOG_PATH          = 'UtilServicesLogs\';
    S_CODE              = 'Код ошибки :';
    S_ERROR_OPEN        = 'Ошиюка при инициализации сервера';
    S_REQ_NEW_TILE_PROF = '/GetTile';
    AS_MARK_NO_ERROR   : array [0..4] of string = ('Socket Error # 10053', 'Software caused connection abort.',
                                                  'Connection reset by peer', 'Connection timed out',
                                                  'Address already in use');
    S_E_INIT_CLIENT     = 'Ошибка инициализации клиента запроса внешнего сервера';
    S_E_REQUEST_PROCESS = 'Ошибка общей обработки запроса';
    S_E_WRITE_CONTEXT   = 'Ошибка при пересыле результата адресату';

// Ошибки
    E_IPTS_SHIFT        = -20000;
    E_NO_DIR            = E_IPTS_SHIFT - 1; // Дирректория не указанна корректно
    E_NOT_PORT          = E_IPTS_SHIFT - 2; // Не указан порт
    E_NOT_PROXY         = E_IPTS_SHIFT - 3; // Не указаны параметры прокси при этом он - требуется
    E_GEN_ERROR         = E_IPTS_SHIFT - 4; // Обшая ошибка (try.. except)

implementation

end.
