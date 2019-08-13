unit uCGTS_ServerConst;

interface
const
    S_SLASH          = '\';
    S_SYM_POINT      = '.';

    S_CGTS_ROOT      = 'CGTS';   
    S_CGTS_COUNT     = 'MapsCount';
		S_IIPS_MAPPATH   = 'MapPath';

		S_CGTS_LST_EXT	 = '.lst' ;

    I_ROUTE_TYPE_0  = 0;// кратчайший по времени
    I_ROUTE_TYPE_1  = 1;// кратчайший по расстоянию
    I_ROUTE_TYPE_2  = 2;// без ограничений (пешеходный)

    // Ошибки
    E_CITY_GUID_USR_SHIFT      = -20000;
    E_CITY_GUID_NO_PARAMS      = E_CITY_GUID_USR_SHIFT -   1;
    E_CITY_GUID_NO_SUPPORT     = E_CITY_GUID_USR_SHIFT -   2;
    E_CITY_GUID_GEN_ROUTE      = E_CITY_GUID_USR_SHIFT -   3;
    E_CITY_GUID_NO_MAP         = E_CITY_GUID_USR_SHIFT -   4;
    E_NO_AWAITING_MAPS         = E_CITY_GUID_USR_SHIFT -   5;
    E_CITY_GUID_NO_VALID_COORD = E_CITY_GUID_USR_SHIFT -   6;
    E_CITY_GUID_TOT_COORD_RESP = E_CITY_GUID_USR_SHIFT -   7;
    E_CITY_GUID_E_NO_STREET    = E_CITY_GUID_USR_SHIFT -   8;
		E_CITY_GUID_E_NO_HOUSE     = E_CITY_GUID_USR_SHIFT -   9;
		E_CITY_GUID_GEN_ROUTE_LIST = E_CITY_GUID_USR_SHIFT -   10;

implementation

end.
