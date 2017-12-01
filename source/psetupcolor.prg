/*
PSETUPCOLOR
José Quintas
*/

#include "hbgtinfo.ch"
#include "inkey.ch"

PROCEDURE pSetupColor

   LOCAL cCorAnt, cCor, nCont, nCont2, nOpc, aPalette, wTela, nColor, nRGB

   aPalette := hb_gtInfo( HB_GTI_PALETTE )
   cCorAnt  := SetColor()
   SAVE SCREEN TO wTela
   DO WHILE .T.
      RESTORE SCREEN FROM wTela
      @ 1, 0 SAY ""
      FOR nCont = 0 TO 15
         @ Row()+2, 0 SAY ""
         nColor := aPalette[ nCont + 1 ]
         nRgb := { 0, 0, 0, nColor }
         nRgb[ 1 ] := Mod( nColor, 256 )
         nRgb[ 2 ] := Mod( Int( nColor / 256 ), 256 )
         nRgb[ 3 ] := Int( nColor / 256 / 256 )

         MousePrompt( Row(), 0, Pad( Str( nCont, 2 ) + " : " + Str( nRgb[ 1 ], 3 ) + "." + Str( nRgb[ 2 ], 3 ) + "." + Str( nRgb[ 3 ], 3 ), 20 ) )
         FOR nCont2 = 0 TO 15
            cCor := LTrim( Str( nCont2 ) ) + "/" + LTrim( Str( nCont ) )
            @ Row(), 21 + nCont2 * 6 SAY Pad( cCor, 6 ) COLOR cCor
         NEXT
      NEXT
      nOpc := MouseMenuTo( nOpc )
      IF nOpc == 0 .OR. LastKey() == K_ESC
         EXIT
      ENDIF
      nColor := wvt_ChooseColor( aPalette[ nOpc ] )
      IF nColor >= 0
         aPalette[ nOpc ] := nColor
      ENDIF
      hb_gtInfo( HB_GTI_PALETTE, aPalette )
   ENDDO
   SetColor( cCorAnt )
   MsgExclamation( "Ok" )

   RETURN
