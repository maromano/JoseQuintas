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
