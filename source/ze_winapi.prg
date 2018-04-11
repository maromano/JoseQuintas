/*
ZE_WINAPI - Funções de API
*/

FUNCTION win_GetShortPathName( cPath )

   LOCAL cShort := Space(5000)

   wapi_GetShortPathName( cPath, @cShort, Len( cShort) )

   RETURN cShort
