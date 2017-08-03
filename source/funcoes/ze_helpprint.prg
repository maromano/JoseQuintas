/*
ZE_HELPPRINT - Imprime manual do sistema
José Quintas
*/

PROCEDURE HELPPRINT

   LOCAL cText, cModulo, nTotal, nAtual := 0, cDescri, cnJoseQuintas := ADOClass():New( AppcnJoseQuintas() )
   LOCAL oPDF := PDFClass():New(), nPos, aText, acMenu, oElement

   IF ! MsgYesNo( "Gera PDF?" )
      RETURN
   ENDIF
   cnJoseQuintas:Open()
   cnJoseQuintas:cSql := "UPDATE JPHELP SET HLEXISTE = 'N' WHERE HLMODULO <> 'JPA'"
   cnJoseQuintas:Execute()
   oPDF:acHeader := { "HELP DO SISTEMA", "" }
   oPDF:nPrinterType := 2
   oPDF:Begin()
   acMenu := OpcoesDoMenu( cnJoseQuintas )
   oPDF:MaxRowTest()
   oPDF:DrawZebrado(2)
   oPDF:DrawText( oPDF:nRow, 0, "OPÇÕES DO MENU/ÍNDICE" )
   oPDF:nRow += 2
   FOR EACH oElement IN acMenu
      oPDF:MaxRowTest()
      oPDF:DrawText( oPDF:nRow++, 0, oElement )
   NEXT
   oPDF:MaxRowTest( 1000 ) // muda página
   cnJoseQuintas:cSql := "SELECT COUNT(*) AS QTD FROM JPHELP WHERE HLOLD='N'"
   cnJoseQuintas:Execute()
   nTotal := cnJoseQuintas:NumberSql( "QTD" )
   cnJoseQuintas:CloseRecordset()
   cnJoseQuintas:cSql := "SELECT * FROM JPHELP WHERE HLOLD='N' ORDER BY HLMODULO"
   cnJoseQuintas:Execute()
   GrafTempo( "Gerando manual em PDF" )
   DO WHILE ! cnJoseQuintas:Eof()
      GrafTempo( nAtual++, nTotal )
      cModulo := cnJoseQuintas:StringSql( "HLMODULO" )
      cDescri := cnJoseQuintas:StringSql( "HLDESCRI" )
      cText   := cnJoseQuintas:StringSql( "HLTEXTO" )
      IF Empty( cText )
         cnJoseQuintas:MoveNext()
         LOOP
      ENDIF
      oPDF:nRow += 2
      oPDF:MaxRowTest()
      oPDF:DrawZebrado(2)
      oPDF:DrawText( oPDF:nRow, 0, cModulo + " - " + cDescri )
      oPDF:nRow += 2
      DO WHILE Len( cText ) > 0
         oPDF:MaxRowTest(2)
         nPos := At( hb_eol(), cText + hb_eol() )
         aText := TextToArray( Substr( cText, 1, nPos - 1 ), oPDF:MaxCol )
         FOR EACH oElement IN aText
            oPDF:DrawText( oPDF:nRow, 0, oElement )
            oPDF:nRow += 1
         NEXT
         cText := Substr( cText, nPos )
         IF Left( cText, 2 ) == hb_eol()
            cText := Substr( cText, 3 )
         ENDIF
      ENDDO
      cnJoseQuintas:MoveNext()
   ENDDO
   cnJoseQuintas:CloseRecordset()
   cnJoseQuintas:CloseConnection()
   oPDF:End()

   RETURN

STATIC FUNCTION OpcoesDoMenu( cnJoseQuintas )

   LOCAL mOpcoes, acMenu := {}

   mOpcoes := MenuCria()
   ListaOpcoes( mOpcoes,,, acMenu, cnJoseQuintas )

   RETURN acMenu

STATIC FUNCTION ListaOpcoes( mOpcoes, nLevel, cSelecao, acMenu, cnJoseQuintas )

   LOCAL cModule, cDescription, oElement, nNumOpcao

   hb_Default( @nLevel, 0 )
   hb_Default( @cSelecao, "" )
   nLevel    := nLevel + 1
   nNumOpcao := 1

   FOR EACH oElement IN mOpcoes
      cModule := oElement[ 3 ]
      IF ValType( cModule ) != "C"
         cModule := ""
      ENDIF
      cDescription := oElement[ 1 ]
      Aadd( acMenu, Pad( cSelecao + StrZero( nNumOpcao, 2 ) + ".", 15 ) + Space( nLevel * 3 ) + cDescription + iif( Len( cModule ) !=  0, " (" + oElement[ 3 ] + ")", "" ) )
      IF ! Empty( cModule )
         cnJoseQuintas:cSql := "UPDATE JPHELP SET HLEXISTE='S', HLDESCRI=" + StringSql( cDescription ) + " WHERE HLMODULO=" + StringSql( AllTrim( cModule ) )
         cnJoseQuintas:ExecuteCmd()
      ENDIF
      IF Len( oElement[ 2 ] ) != 0
         ListaOpcoes( oElement[ 2 ], nLevel, cSelecao + StrZero( nNumOpcao, 2 ) + ".", acMenu, cnJoseQuintas )
      ENDIF
      nNumOpcao += 1
   NEXT

   RETURN NIL
