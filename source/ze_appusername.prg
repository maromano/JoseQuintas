/*
ZE_APPUSERNAME
José Quintas
*/

FUNCTION AppUserName( xValue )

   STATIC AppUserName := "JPA"

   IF xValue != NIL
      AppUserName := Trim( xValue )
   ENDIF

   RETURN AppUserName

