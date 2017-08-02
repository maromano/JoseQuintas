/*
ZE_INTERNET
José Quintas
*/

FUNCTION IsInternet( cUrl, nPort )

   LOCAL lOk := .F. , aAddr

   hb_Default( @cUrl, "www.google.com" )
   hb_Default( @nPort, 80 )
   aAddr := hb_socketResolveINetAddr( cUrl, nPort )
   IF ! Empty( aAddr )
      lOk := hb_socketConnect( hb_socketOpen(), aAddr, 2000 )
   ENDIF

   RETURN lOk

