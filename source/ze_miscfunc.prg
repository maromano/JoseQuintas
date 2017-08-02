/*
ZE_MISCFUNC - Funções gerais
José Quintas
*/

#include "hbgtinfo.ch"
#include "inkey.ch"

FUNCTION ReturnValue( xValue, ... )

   RETURN xValue

FUNCTION VSay( nRow, nCol, cText )

   LOCAL nRowAnt := Row(), nColAnt := Col()

   @ nRow, nCol SAY cText COLOR iif( nRow < MaxRow() - 1, SetColorNormal(), SetColorMensagem() )
   @ nRowAnt, nColAnt SAY ""

   RETURN .T.

FUNCTION Percent( nParcial, nTotal )

   LOCAL nPercent := 100

   IF nTotal != 0
      nPercent := nParcial * 100 / nTotal
   ENDIF

   RETURN nPercent

FUNCTION BuildBlockHB_KeyPut( nKey )

   RETURN { || HB_KeyPut( nKey ) }

FUNCTION EmptyValue( xValue )

   DO CASE
   CASE ValType( xValue ) == "N"
      xValue := 0
   CASE ValType( xValue ) == "D"
      xValue := Ctod("")
   OTHERWISE
      xValue := Space( Len( xValue ) )
   ENDCASE

   RETURN xValue

FUNCTION DriveSerial( cDisk )

   hb_Default( @cDisk, "C:\" )

   RETURN Transform( Padl( hb_NumToHex( VolSerial( cDisk ) ), 8 ), "@R XXXX-XXXX" )

FUNCTION LogInfo()

   LOCAL cLogInfo
   MEMVAR m_Prog

   cLogInfo := Transform( Dtos( Date() ), "@R 9999/99/99" ) + " " + Left( Time(), 5 )
   cLogInfo += " " + Pad( AppUserName(), 10 ) + " " + Pad( AppEmpresaApelido(), 10 )
   cLogInfo += " " + Pad( m_Prog, 10 ) + " " + DriveSerial()
   cLogInfo += " " + AppVersaoExe()

   RETURN cLogInfo

FUNCTION AltC()

   LOCAL nCont := 2, cText := "", cSetDevice

   cSetDevice := Set( _SET_DEVICE, "SCREEN" )
   DO WHILE ( ! Empty( ProcName( nCont ) ) )
      cText += "Called from " + Trim( ProcName( nCont ) ) + "(" + Ltrim( Str( ProcLine( nCont ) ) ) + ")" + hb_eol()
      nCont++
   ENDDO
   cText += hb_eol()
   cText += "Alias: " + Transform( Alias(), "" ) + hb_eol()
   cText += "RecNo: " + Ltrim( Str( RecNo() ) ) + hb_eol()
   cText += hb_eol()
   cText += "Realmente abandonar o sistema?"
   IF MsgYesNo( cText )
      CLOSE DATABASES
      QUIT
   ENDIF
   Set( _SET_DEVICE, cSetDevice )
   SET KEY K_ALT_Q TO AltC()

   RETURN NIL

FUNCTION RunCmd( cComando )

   LOCAL cFileName

   cFileName := MyTempFile( "BAT" )
   cComando  := cComando + Chr(13) + Chr(10) + "EXIT" + hb_eol()
   HB_MemoWrit( cFileName, cComando )
   RUN ( cFileName )
   fErase( cFileName )

   RETURN NIL
