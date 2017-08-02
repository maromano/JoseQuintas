#include "inkey.ch"
#include "set.ch"
#include "hbgtinfo.ch"

FUNCTION Progressbar()

   LOCAL nCont//, oCrt

   hb_gtReload( hb_GTInfo( HB_GTI_VERSION ) )
   SetMode( 5, 80 )
   CLS
   HB_GtInfo( HB_GTI_ICONRES, "AppIcon" )
   HB_GtInfo( HB_GTI_WINTITLE, "progressbar" )
   HarbourInit()
   GrafTempo( "Processando" )
   FOR nCont = 1 TO 10000000
      GrafTempo( nCont, 10000000 )
      IF Inkey() == K_ESC
         EXIT
      ENDIF
   NEXT
   RETURN NIL
