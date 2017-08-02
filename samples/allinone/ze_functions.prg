/*
ZE_FUNCTIONS - Funções de uso geral
*/

#ifdef GTWVG
   #include "wvtwin.ch"
#endif
#include "inkey.ch"
#include "hbgtinfo.ch"

THREAD STATIC AppSaveScreen := {}

FUNCTION AppMainThread( xValue )

   STATIC AppMainThread

   IF xValue != NIL
      AppMainThread := xValue
   ENDIF
   RETURN AppMainThread

FUNCTION HarbourInit()

   SET SCOREBOARD OFF
   SET DELETED    ON
   SET( _SET_EVENTMASK, INKEY_ALL - INKEY_MOVE ) // + HB_INKEY_GTEVENT )
   hb_gtInfo( HB_GTI_SELECTCOPY, .T. )
   hb_gtInfo( HB_GTI_INKEYFILTER, { | nKey |
      LOCAL nBits, lIsKeyCtrl

      nBits := hb_GtInfo( HB_GTI_KBDSHIFTS )
      lIsKeyCtrl := ( nBits == hb_BitOr( nBits, HB_GTI_KBD_CTRL ) )
      SWITCH nKey
      CASE K_MWBACKWARD
         RETURN K_DOWN
      CASE K_MWFORWARD
         RETURN K_UP
      CASE K_RBUTTONDOWN
         RETURN K_ESC
      CASE K_RDBLCLK
         RETURN K_ESC
      CASE K_INS
         IF lIsKeyCtrl
            hb_GtInfo( HB_GTI_CLIPBOARDPASTE )
            RETURN 0
         ENDIF
      CASE K_CTRL_C
         IF lIsKeyCtrl
            IF GetActive() != NIL
               hb_gtInfo( HB_GTI_CLIPBOARDDATA, Transform( GetActive():varGet(), "" ) )
               RETURN 0
            ENDIF
         ENDIF
      ENDSWITCH
      RETURN nKey
       } )
   RETURN NIL
