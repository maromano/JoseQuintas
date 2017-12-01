/*
ZE_PLAYTEXT
José Quintas
*/

#include "hbgtinfo.ch"

FUNCTION AppIsPlayText( xValue )

   STATIC AppIsPlayText := .F.

   IF xValue != NIL
      AppIsPlayText := xValue
   ENDIF

   RETURN AppIsPlayText

FUNCTION PlayText( cText )

   LOCAL oTalk

   IF ! AppIsPlayText() .OR. Empty( cText )
      RETURN NIL
   ENDIF
   hb_gtReload( hb_gtInfo( HB_GTI_VERSION ) )
   oTalk := win_OleCreateObject( "SAPI.SPVoice" )
   oTalk:Speak( cText ) // , SVSFDefault
   oTalk:WaitUntilDone( 1 )

   RETURN NIL
