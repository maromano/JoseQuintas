/*
ZE_WINAPI - Funções de API
*/

FUNCTION win_GetShortPathName( cPath )

   LOCAL cShort := Space(5000)

   wapi_GetShortPathName( cPath, @cShort, Len( cShort) )

   RETURN cShort

FUNCTION win_GetWindowWidth( hWnd )

   LOCAL aWindowRect := {}, nWidth

   wapi_GetWindowRect( hWnd, @aWindowRect )
   nWidth  := Int( ( aWindowRect[ 3 ] - aWindowRect[ 1 ] ) )

   RETURN nWidth

FUNCTION win_GetWindowHeight( hWnd )

   LOCAL aWindowRect := {}, nHeight

   wapi_GetWindowRect( hWnd, @aWindowRect )
   nHeight := Int( ( aWindowRect[ 4 ] - aWindowRect[ 2 ] ) )

   RETURN nHeight
