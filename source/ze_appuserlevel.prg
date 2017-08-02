/*
ZE_APPUSERLEVEL
José Quintas
*/

FUNCTION AppUserLevel( xValue )

   STATIC AppUserLevel := 2

   IF xValue != NIL
      AppUserLevel := xValue
   ENDIF

   RETURN AppUserLevel

