/*
ZE_MENSAGEM - ROTINAS DE MENSAGEM
2012.07 José Quintas
*/

#include "hbgtinfo.ch"
#include "inkey.ch"
#include "set.ch"

FUNCTION Mensagem( cTexto, mAceita, mCentral, mBeep )

   LOCAL cCorAnt, mSetDevice, nKey, cResposta, cTexto1, cTexto2 //, oSetKey

   hb_Default( @mBeep, 0 )
   hb_Default( @mCentral, 0 )
   hb_Default( @mAceita, "" )
   hb_Default( @cTexto, "" )
   //oSetkey := SaveSetKey( K_F9, K_F10, K_SH_F9, K_SH_F10 )
   cCorAnt    := SetColor()
   mSetDevice := Set( _SET_DEVICE, "SCREEN" )
   cResposta     := " "
   SetColor( SetColorMensagem() )
   IF mCentral == 0
      IF mAceita == "S,N"
         cTexto += " (Sim ou Não)"
      ENDIF
      hb_ThreadStart( { || PlayText( cTexto ) } )
      Scroll( MaxRow() - 1, 0, MaxRow(), MaxCol(), 0 )
      IF Len( cTexto ) < MaxCol() - 1
         @ MaxRow() - 1, 1 SAY cTexto
      ELSE
         cTexto = cTexto + " "
         cTexto1 := Substr( cTexto, 1, Rat( " ", Substr( cTexto, 1, MaxCol() - 1 ) ) - 1 )
         cTexto2 := Substr( cTexto, Len( cTexto1 ) + 2 )
         @ MaxRow() - 1, 1 SAY cTexto1
         @ MaxRow(), 1 SAY cTexto2
      ENDIF
      IF mBeep == 1
         wapi_MessageBeep()
      ENDIF
      IF Len( Trim( mAceita ) ) != 0
         IF Col() > MaxCol() - 1 .AND. Row() == 1
            @ MaxRow()-1, 0 SAY ""
         ENDIF
         @ Row(), Col() + 1 SAY ""
         cResposta = "  0"
         DO WHILE ! ( "," + cResposta + "," ) $ ( "," + mAceita + "," )
            nKey := Inkey(600)
            cResposta := iif( nKey > 31, Upper( Chr( nKey ) ), Str( nKey, 3 ) )
            IF nKey == 0
               KEYBOARD Chr( K_ESC )
            ENDIF
         ENDDO
         @ MaxRow() - 1, 0 CLEAR TO MaxRow(), MaxCol()
      ENDIF
   ELSE
      cResposta := MensagemCentral( cTexto, mAceita, mBeep )
   ENDIF
   SetColor( cCorAnt )
   Set( _SET_DEVICE, mSetDevice )
   //RestoreSetKey( oSetKey )
   SET CURSOR ON

   RETURN cResposta

STATIC FUNCTION MensagemCentral( cTexto, mAceita, mBeep )

   LOCAL nRow, nCol, nRowAnt, nColAnt, nOpc := 1, cResposta, cTexto1, cTexto2, cTexto3

   nRowAnt   := Row()
   nColAnt   := Col()
   wSave( MaxRow() - 1, 0, MaxRow(), MaxCol() )
   Mensagem()
   cTexto  = cTexto + " "
   cTexto1 = SubStr( cTexto, 1, RAt( " ", SubStr( cTexto, 1, 39 ) ) - 1 )
   cTexto  = SubStr( cTexto, Len( cTexto1 ) + 2 )
   cTexto1 = AllTrim( cTexto1 )

   cTexto2 = SubStr( cTexto, 1, RAt( " ", SubStr( cTexto, 1, 39 ) ) - 1 )
   cTexto  = SubStr( cTexto, Len( cTexto2 ) + 2 )
   cTexto2 = AllTrim( cTexto2 )

   cTexto3 = SubStr( cTexto, 1, RAt( " ", SubStr( cTexto, 1, 39 ) ) - 1 )
   cTexto3 = AllTrim( cTexto3 )

   IF Len( cTexto3 ) == 0
      IF Len( cTexto2 ) == 0
         cTexto2 = cTexto1
         cTexto1 = ""
      ELSE
         cTexto3 = cTexto2
         cTexto2 = ""
      ENDIF
   ENDIF

   nRow = Int( ( MaxRow() - 10 ) / 2 )
   nCol = Int( ( MaxCol() - 45 ) / 2 )
   wSave( nRow - 1, nCol, nRow + 8, nCol + 44 )
   SetColor( SetColorMensagem() )
   Scroll( nRow - 1, nCol, nRow + 8, nCol + 44, 0 )
   @ nRow - 1, nCol SAY " - " COLOR SetColorTituloBox()
   @ nRow - 1, nCol + 3 SAY Pad( " Atencao", 42 ) COLOR SetColorTituloBox()
   @ nRow + 2, nCol + 1 SAY PadC( cTexto1, 42 )
   @ nRow + 3, nCol + 1 SAY PadC( cTexto2, 42 )
   @ nRow + 4, nCol + 1 SAY PadC( cTexto3, 42 )
   IF mBeep == 1
      wapi_MessageBeep()
   ENDIF
   IF Len( Trim( mAceita ) ) != 0
      DO CASE
      CASE mAceita == "S,N"
         MousePrompt( nRow + 6, nCol + 14, "Sim" )
         MousePrompt( nRow + 6, nCol + 25, "Não" )
         MouseMenuTo( @nOpc )
         cResposta := iif( nOpc == 1, "S", "N" )

      CASE mAceita == " 13"
         MousePrompt( nRow + 6, nCol + 15, "ENTER" )
         MouseMenuTo( @nOpc )
         cResposta := Str( 13, 3 )

      CASE mAceita == " 27"
         MousePrompt( nRow + 6, nCol + 15, "ENTER" )
         MouseMenuTo( @nOpc )
         cResposta := Str( 27, 3 )

      CASE mAceita == " 13, 27"
         MousePrompt( nRow + 6, nCol + 9, "Continua" )
         MousePrompt( nRow + 6, nCol + 22, "Suspende" )
         MouseMenuTo( @nOpc )
         cResposta := iif( nOpc == 1, " 13", " 27" )

      ENDCASE
   ENDIF
   WClose()
   wRestore()
   @ nRowAnt, nColAnt SAY ""

   RETURN cResposta
