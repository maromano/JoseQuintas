/*
ZE_APPISMULTITHREAD
José Quintas
*/

FUNCTION AppIsMultithread( xValue )

   STATIC AppIsMultithread := .F.

   IF xValue != NIL
      AppIsMultithread := xValue
   ENDIF

   RETURN AppIsMultithread

PROCEDURE ChangeMultiThread

   AppIsMultithread( ! AppIsMultiThread() )
   MsgExclamation( "Alterado para modo " + iif( AppIsMultithread(), "multijanelas", "monojanela" ) )

   RETURN


