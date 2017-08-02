/*
TST - Módulo principal de teste das funçòes adicionais WVG
*/

#include "inkey.ch"

PROCEDURE Main

   IF File( "rmchart.dll" )
      hb_ThreadStart( { || tstrmchart() } )
   ENDIF
   hb_ThreadStart( { || tstgtwvg() } )
   hb_ThreadWaitForAll()

   RETURN

FUNCTION AppcnMySqlLocal(); RETURN NIL
FUNCTION AppOdbcMySql(); RETURN NIL
FUNCTION EnviaEmail(); RETURN NIL
FUNCTION DbView(); RETURN NIL
FUNCTION FrmGuiClass(); RETURN NIL
FUNCTION PlayText(); RETURN NIL
FUNCTION AppUserName(); RETURN NIL
FUNCTION DelTempFiles(); RETURN NIL
FUNCTION AppVersaoExe(); RETURN NIL

