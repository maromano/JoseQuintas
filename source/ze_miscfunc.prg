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

   // ATENÇÃO: Se algum dia mexer, lembrar que alguns módulos usam o formato de data/hora

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

FUNCTION GoDos()

   IF AppUserLevel() == 0
      ShellExecuteOpen( GetEnv( "COMSPEC" ) )
   ENDIF

   RETURN NIL

FUNCTION ShellExecuteOpen( cFileName, cParameters, nShow )

   wapi_ShellExecute( NIL, "open", cFileName, cParameters,, hb_DefaultValue( nShow, WIN_SW_SHOWNORMAL ) )

   RETURN NIL

FUNCTION ShellExecutePrint( cFileName, cParameters, nShow )

   wapi_ShellExecute( NIL, "print", cFileName, cParameters,, hb_DefaultValue( nShow, WIN_SW_SHOWMINNOACTIVE ) )

   RETURN NIL

FUNCTION MacroType( cExpression )

   LOCAL cType := "U", bBlock

   BEGIN SEQUENCE WITH __BreakBlock()
      bBlock := hb_MacroBlock( cExpression )
      cType  := ValType( Eval( bBlock ) )
   END SEQUENCE

   RETURN cType

FUNCTION IsInternet( cUrl, nPort )

   LOCAL lOk := .F. , aAddr

   hb_Default( @cUrl, "www.google.com" )
   hb_Default( @nPort, 80 )
   aAddr := hb_socketResolveINetAddr( cUrl, nPort )
   IF ! Empty( aAddr )
      lOk := hb_socketConnect( hb_socketOpen(), aAddr, 2000 )
   ENDIF

   RETURN lOk

FUNCTION PicVal( nTamanho, nDecimais )

   LOCAL cPicture

   hb_Default( @nDecimais, 0 )
   cPicture  := Replicate( "9", nTamanho - nDecimais )
   cPicture  := LTrim( Transform( Val( cPicture ), "999,999,999,999,999,999" ) )
   IF nDecimais != 0
      cPicture := cPicture + "." + Replicate( "9", nDecimais )
   ENDIF
   cPicture := "@E " + cPicture

   RETURN cPicture

FUNCTION MToH( nMinutes )

   RETURN StrZero( Int( nMinutes / 60 ), 3 ) + ":" + StrZero( Mod( nMinutes, 60 ), 2 )


FUNCTION UltDia( dData )

   dData += ( 40 - Day( dData ) )
   dData -= Day( dData )

   RETURN dData

FUNCTION Idade( dDataNasc, dDataCalc )

   LOCAL nDias, nMeses, nAnos

   hb_Default( @dDataCalc, Date() )
   IF Dtoc( dDataNasc ) == "  /  /  "
      RETURN "*Indefinido*"
   ENDIF
   nAnos := Year( dDataCalc ) - Year( dDataNasc )
   IF Substr( Dtos( dDataCalc ), 5 ) < Substr( Dtos( dDataNasc ), 5 )
      nAnos = nAnos - 1
   ENDIF
   nMeses = ( 12 - Month( dDataNasc ) ) + Month( dDataCalc )
   DO CASE
   CASE Day( dDataCalc ) = Day( dDataNasc )
      nDias := 0
   CASE Day( dDataCalc ) < Day( dDataNasc )
      nMeses = nMeses - 1
      nDias := Day( UltDia( dDataNasc ) ) - Day( dDataNasc ) + Day( dDataCalc )
   OTHERWISE
      nDias := Day( dDataCalc ) - Day( dDataNasc )
   ENDCASE
   nMeses = Mod( nMeses, 12 )

   RETURN LTrim( Str( nAnos, 3 ) ) + " ano(s), " + LTrim( Str( nMeses, 3 ) ) + " mes(es), " + LTrim( Str( nDias, 3 ) ) + " dia(s)"

FUNCTION TimeAdd( cTime, cTipo, nQtde )

   LOCAL nHora, nMinuto, nSegundo, cResultado

   nHora    := Val( Substr( cTime, 1, 2 ) )
   nMinuto  := Val( Substr( cTime, 4, 2 ) )
   nSegundo := Val( Substr( cTime, 7, 2 ) )
   DO CASE
   CASE cTipo == "H"
      nHora += nQtde
   CASE cTipo == "M"
      nMinuto += nQtde
   CASE cTipo == "S"
      nSegundo += nQtde
   ENDCASE
   IF nSegundo >= 60
      nMinuto += Int( nSegundo / 60 )
      nSegundo -= ( Int( nSegundo / 60 ) * 60 )
   ENDIF
   IF nMinuto >= 60
      nHora += Int( nMinuto / 60 )
      nMinuto -= ( Int( nMinuto / 60 ) * 60 )
   ENDIF
   IF nHora > 23
      cResultado := "23:59:59"
   ELSE
      nHora := nHora - ( Int( nHora / 24 ) * 24 )
      cResultado := StrZero( nHora, 2 ) + ":" + StrZero( nMinuto, 2 ) + ":" + StrZero( nSegundo, 2 )
   ENDIF

   RETURN cResultado
