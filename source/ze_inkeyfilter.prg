/*
ZE_INKEYFILTER
José Quintas
*/

#include "hbgtinfo.ch"
#include "inkey.ch"

FUNCTION MyInkeyFilter( nKey )

   LOCAL nBits, lIsKeyCtrl

   nBits      := hb_GtInfo( HB_GTI_KBDSHIFTS )
   lIsKeyCtrl := ( nBits == hb_BitOr( nBits, HB_GTI_KBD_CTRL ) )
   SWITCH nKey
   CASE HB_K_CLOSE     ; RETURN K_ESC
   CASE K_MWBACKWARD   ; RETURN K_DOWN
   CASE K_MWFORWARD    ; RETURN K_UP
   CASE K_RBUTTONDOWN  ; RETURN K_ESC
   CASE K_RBUTTONUP    ; RETURN NIL
   CASE K_RDBLCLK      ; RETURN K_ESC
   CASE K_TAB          ; RETURN K_DOWN
   CASE K_SH_TAB       ; RETURN K_UP
   CASE K_CTRL_V
      IF lIsKeyCtrl
         hb_GtInfo( HB_GTI_CLIPBOARDPASTE )
         RETURN NIL
      ENDIF
   CASE K_CTRL_C
      IF lIsKeyCtrl
         IF GetActive() != NIL
            hb_gtInfo( HB_GTI_CLIPBOARDDATA, Transform( GetActive():VarGet(), "" ) )
            RETURN NIL
         ENDIF
      ENDIF
   ENDSWITCH

   RETURN nKey
