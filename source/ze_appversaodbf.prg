/*
ZE_APPVERSAODBF
José Quintas
*/

FUNCTION AppVersaoDbf( xValue )

   STATIC AppVersaoDbf := 0

   IF xValue != NIL
      AppVersaoDbf := xValue
   ENDIF

   RETURN AppVersaoDbf

