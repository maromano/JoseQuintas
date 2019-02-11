/*
ZE_GRAFTEMPO - GRAFICOS DE PROCESSAMENTO
1990.05 - José Quintas
*/

#include "inkey.ch"
#include "set.ch"

#define GRAFMODE 1
#define GRAFTIME 2
#define GRAF_SEC_OLD  1
#define GRAF_SEC_INI  2
#define GRAF_TXT_BAR  3
#define GRAF_TXT_TEXT 4

FUNCTION GrafProc( nRow, nCol )

   THREAD STATIC GrafInfo := { 1, "X" }
   LOCAL mSetDevice

   hb_Default( @nRow, MaxRow() - 1 )
   hb_Default( @nCol, MaxCol() - 2 )
   IF GrafInfo[ GRAFTIME ] != Time()
      mSetDevice := Set( _SET_DEVICE, "SCREEN" )
      @ nRow, nCol SAY "(" + Substr( "|/-\", GrafInfo[ GRAFMODE ], 1 ) + ")" COLOR SetColorMensagem()
      GrafInfo[ GRAFMODE ] = iif( GrafInfo[ GRAFMODE ] == 4, 1, GrafInfo[ GRAFMODE ] + 1 )
      Set( _SET_DEVICE, mSetDevice )
      GrafInfo[ GRAFTIME ] := Time()
   ENDIF

   RETURN .T.

FUNCTION GrafTempo( xContNow, xContTotal )

   THREAD STATIC aStatic := { 0, 0, "", "" }
   LOCAL nSecondsNow, nSecondsRemaining, nSecondsElapsed, nCont, nPos, cTxt, cCorAnt
   LOCAL nPercent, cTexto, mSetDevice

   xContNow := iif( xContNow == NIL, "", xContNow )
   IF Empty( aStatic[ GRAF_TXT_BAR ] )
      aStatic[ GRAF_TXT_BAR ] := Replicate( ".", MaxCol() )
      FOR nCont = 1 to 10
         nPos          := Int( Len( aStatic[ GRAF_TXT_BAR ] ) / 10 * nCont )
         cTxt          := lTrim( Str( nCont, 3 ) ) + "0%" + Chr(30)
         aStatic[ GRAF_TXT_BAR ] := Stuff( aStatic[ GRAF_TXT_BAR ], ( nPos - Len( cTxt ) ) + 1, Len( cTxt ), cTxt )
      NEXT
      aStatic[ GRAF_TXT_BAR ] := Chr(30) + aStatic[ GRAF_TXT_BAR ]
   ENDIF
   mSetDevice := Set( _SET_DEVICE, "SCREEN" )
   DO CASE
   CASE ValType( xContNow ) == "C"
      cTexto                  := xContNow
      aStatic[ GRAF_SEC_INI ] := Int( Seconds() )
   CASE xContTotal == NIL
      nPercent := xContNow
   CASE xContNow >= xContTotal
      nPercent := 100
   OTHERWISE
      nPercent := xContNow / xContTotal * 100
   ENDCASE
   xContNow   := iif( ValType( xContNow ) != "N", 0, xContNow )
   xContTotal := iif( ValType( xContTotal ) != "N", 0, xContTotal )

   cCorAnt := SetColor()
   SetColor( SetColorMensagem() )
   nSecondsNow := Int( Seconds() )
   IF nPercent == NIL
      aStatic[ GRAF_SEC_OLD ] := nSecondsNow
      Mensagem()
      @ MaxRow(), 0 SAY aStatic[ GRAF_TXT_BAR ]
      aStatic[ GRAF_TXT_TEXT ] := cTexto

   ELSEIF nPercent == 100 .OR. ( nSecondsNow != aStatic[ GRAF_SEC_OLD ] .AND. nPercent != 0 )
      aStatic[ GRAF_SEC_OLD ] := nSecondsNow
      nSecondsElapsed   := nSecondsNow - aStatic[ GRAF_SEC_INI ]
      DO WHILE nSecondsElapsed < 0
         nSecondsElapsed += ( 24 * 3600 ) // Acima de 24 horas
      ENDDO
      nSecondsRemaining := nSecondsElapsed / nPercent * ( 100 - nPercent )
      @ MaxRow()-1, 0 SAY aStatic[ GRAF_TXT_TEXT ] + " " + Ltrim( Transform( xContNow, PicVal(14,0) ) ) + "/" + Ltrim( Transform( xContTotal, PicVal(14,0) ) )
      cTxt := "Gasto:"
      cTxt += " " + Ltrim( Str( Int( nSecondsElapsed / 3600 ), 10 ) ) + "h"
      cTxt += " " + Ltrim( Str( Mod( Int( nSecondsElapsed / 60 ), 60 ), 10, 0 ) ) + "m"
      cTxt += " " + Ltrim( Str( Mod( nSecondsElapsed, 60 ), 10, 0 ) ) + "s"
      cTxt += Space(3)
      cTxt += "Falta:"
      cTxt += " " + Ltrim( Str( Int( nSecondsRemaining / 3600 ), 10 ) ) + "h"
      cTxt += " " + Ltrim( Str( Mod( Int( nSecondsRemaining / 60 ), 60 ), 10, 0 ) ) + "m"
      cTxt += " " + Ltrim( Str( Mod( nSecondsRemaining, 60 ), 10, 0 ) ) + "s"
      @ Row(), Col() SAY Padl( cTxt, MaxCol() - Col() - 4 )
      GrafProc()
      @ MaxRow(), 0 SAY Left( aStatic[ GRAF_TXT_BAR ], Len( aStatic[ GRAF_TXT_BAR ] ) * nPercent / 100 ) COLOR SetColorFocus()
   ENDIF
   SetColor( cCorAnt )
   SET( _SET_DEVICE, mSetDevice )

   RETURN .T.
