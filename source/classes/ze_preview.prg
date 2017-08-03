/*
ZE_PREVIEW - ROTINAS PARA RELATORIOS
1991.04.07 José Quintas
*/

#include "hbclass.ch"
#include "inkey.ch"

FUNCTION PrintPreview( cFileName, lCompress )

   LOCAL oFrm := PrintPreviewClass():New()

   hb_Default( @lCompress, .F. )
   Aadd( oFrm:acMoreOptions, "<M>Email" )
   Aadd( oFrm:acMoreOptions, "<L>Imprime" )
   oFrm:cOptions       := "C"
   oFrm:lPrintCompress := lCompress
   wSave()
   oFrm:Execute( cFileName )
   wRestore()

   RETURN NIL

CREATE CLASS PrintPreviewClass STATIC INHERIT frmGuiClass

   VAR    acFileList     INIT {}
   VAR    nPageNumber    INIT 1
   VAR    lPrintCompress INIT .T.
   METHOD Execute( cFileName )
   METHOD SeparaPaginas( cFileFullReport )
   METHOD MoveFirst()
   METHOD MoveLast()
   METHOD MoveNext()
   METHOD MovePrevious()
   METHOD Especifico()
   METHOD Print( lIsPrinter )

   ENDCLASS

METHOD MoveFirst() CLASS PrintPreviewClass

   ::nPageNumber := 1

   RETURN NIL

METHOD MoveNext()  CLASS PrintPreviewClass

   IF ::nPageNumber < Len( ::acFileList )
      ::nPageNumber += 1
   ENDIF

   RETURN NIL

METHOD MovePrevious() CLASS PrintPreviewClass

   IF ::nPageNumber > 1
      ::nPageNumber -= 1
   ENDIF

   RETURN NIL

METHOD MoveLast() CLASS PrintPreviewClass

   ::nPageNumber := Len( ::acFileList )

   RETURN NIL

METHOD Especifico() CLASS PrintPreviewClass

   LOCAL nNumPag, GetList := {}

   ::GUIDisable()
   nNumPag = ::nPageNumber
   DO WHILE .T.
      Mensagem( "Folha desejada (Pela ordem e não pelo número):" )
      @ Row(), Col() + 2 GET nNumPag PICTURE "999999" VALID nNumPag > 0 .AND. nNumPag <= Len( ::acFileList )
      READ
      Mensagem()
      IF LastKey() == K_ESC
         EXIT
      ELSEIF nNumPag < 1 .OR. nNumPag > Len( ::acFileList )
         MsgWarning( "Folha inválida!" )
      ELSE
         ::nPageNumber := nNumPag
         EXIT
      ENDIF
   ENDDO
   ::GUIEnable()

   RETURN NIL

METHOD Execute( cFileName ) CLASS PrintPreviewClass

   LOCAL mCorAnt, nRowIni, cTmpFile, oElement, nSelect
   LOCAL acLstTeclas := { K_CTRL_C, K_CTRL_R, K_CTRL_PGUP, K_CTRL_PGDN, Asc( "9" ), Asc( "3" ), Asc( "7" ), Asc( "1" ), Asc( "L" ), Asc( "l" ), Asc( "C" ), Asc( "c" ), ;
      Asc( "P" ), Asc( "p" ), Asc( "U" ), Asc( "u" ), Asc( "M" ), Asc( "m" ), Asc( "+" ), Asc( "-" ) }
   // Asc( "1" ), Asc( "7" ), K_HOME, K_END
   MEMVAR cOpc
   PRIVATE cOpc

   ::SeparaPaginas( cFileName )
   IF Len( ::acFileList ) < 1
      RETURN NIL
   ENDIF

   mCorAnt  := SetColor()
   SetColor( SetColorNormal() )
   ::FormBegin()
   WSave()
   @ MaxRow() - 2, 0 TO MaxRow() - 2, MaxCol() COLOR SetColorMensagem()
   ::RowIni()
   nRowIni := Row()
   Scroll( nRowIni, 0, MaxRow() - 3, MaxCol(), 0 )
   DO WHILE .T.
      //m_Texto = MemoRead( ::acFileList[ ::nPageNumber ] )
      // @ 1, 0 SAY StrZero( ::nPageNumber, 6 ) COLOR SetColorTitulo()
      Mensagem( "Folha " + StrZero( ::nPageNumber, 6 ) + " (" + ::acFileList[ ::nPageNumber ] + "), Use setas, HOME, END, M Email, L Imprime, C escolhe folha, PGUP Anterior, PGDN Seguinte, ESC Sai" )
      FOR EACH oElement IN acLstTeclas
         SET KEY oElement TO TeclaPrintPreview
      NEXT
      nSelect := Select()
      SELECT 0
      cTmpFile := MyTempFile( "DBF" )
      dbCreate( cTmpFile, { { "TEXTO", "C", 132, 0 } } )
      USE ( cTmpFile ) ALIAS tmppreview
      APPEND FROM ( ::acFileList[ ::nPageNumber ] ) SDF
      GOTO TOP
      cOpc := " "
      dbView( ::RowIni(), 0, MaxRow() - 4, MaxCol(), { { "", { || tmppreview->Texto } } } )
      USE
      fErase( cTmpFile )
      SELECT ( nSelect )
      FOR EACH oElement IN acLstTeclas
         SET KEY oElement TO
      NEXT
      ::cOpc := cOpc
      DO CASE
      CASE ::cOpc == "-"      ; ::MovePrevious()
      CASE ::cOpc == "+"      ; ::MoveNext()
      CASE ::cOpc == "P"      ; ::MoveFirst()
      CASE ::cOpc == "U"      ; ::MoveLast()
      CASE ::cOpc $ "LM"      ; ::Print( ::cOpc == "L" )
      CASE ::cOpc == "C"      ; ::Especifico()
      CASE LastKey() == K_ESC ; EXIT // Última, senão problemas
      ENDCASE
   ENDDO
   FOR EACH oElement IN ::acFileList
      Mensagem( "Excluindo arquivo temporário " + oElement + "   " + StrZero( oElement:__EnumIndex, 6 ) + "/" + StrZero( Len( ::acFileList ), 6 ) + "..." )
      fErase( oElement )
   NEXT
   WRestore()
   SetColor( mCorAnt )
   ::FormEnd()

   RETURN NIL

METHOD Print( lIsPrinter ) CLASS PrintPreviewClass

   LOCAL cTmpFile, cEmailDest, cAssunto, nPageIni, nPageFim, nCont, nPos, cPageRange, nKey, cPageRangeList, cText
   LOCAL GetList := {}

   ::GUIDisable()
   cPageRangeList = Pad( "1-" + Ltrim( Str( Len( ::acFileList ) ) ), 78 )
   wOpen( 5, 5, 10, MaxCol()-1, "Intervalos a imprimir (núm,núm-núm), ESC Sai" )
   @ 7, 7 GET cPageRangeList PICTURE "@K!"
   READ
   wClose()
   Mensagem()
   IF Lastkey() == K_ESC
      ::GUIEnable()
      RETURN NIL
   ENDIF
   IF ! ConfirmaImpressao()
      ::GUIEnable()
      RETURN NIL
   ENDIF
   cTmpFile := MyTempFile( "TXT" )
   IF ! lIsPrinter
      SET PRINTER TO ( cTmpFile )
   ENDIF
   SET DEVICE TO PRINT
   SetPrc( 0, 0 )
   cPageRangeList := Trim( cPageRangeList ) + ","
   nKey := 0
   DO WHILE nKey != K_ESC
      nKey := Inkey()
      nPos := At( ",", cPageRangeList )
      IF nPos < 2
         EXIT
      ENDIF
      cPageRange = Substr( cPageRangeList, 1, nPos - 1 )
      cPageRangeList = Substr( cPageRangeList, nPos + 1 )
      IF "-" $ cPageRange
         nPos     := At( "-", cPageRange )
         nPageIni := Val( Substr( cPageRange, 1, nPos - 1 ) )
         nPageFim := Val( Substr( cPageRange, nPos + 1 ) )
      ELSE
         nPageIni := Val( cPageRange )
         nPageFim := nPageIni
      ENDIF
      IF nPageIni == 0 .OR. nPageFim == 0
         LOOP
      ENDIF
      IF nPageFim < nPageIni
         LOOP
      ENDIF
      FOR nCont = nPageIni TO nPageFim
         nKey := Inkey()
         IF nKey == K_ESC
            EXIT
         ENDIF
         IF nCont > 0 .AND. nCont <= Len( ::acFileList )
            cText := MemoRead( ::acFileList[ nCont ] )
            IF lIsPrinter
               @ 0, 0 SAY iif( ::lPrintCompress, Chr(15), Chr(18) ) + cText + Chr(18)
            ELSE
               @ 0, 0 SAY cText
            ENDIF
            EJECT
         ENDIF
      NEXT
   ENDDO
   SET PRINTER TO
   SET DEVICE TO SCREEN
   IF ! lIsPrinter
      Mensagem()
      cEmailDest := Space(200)
      cAssunto   := Space(200)
      @ Row(),     0 SAY "Email(s):" GET cEmailDest PICTURE "@S60" VALID ! Empty( cEmailDest )
      @ Row() + 1, 0 SAY "Assunto.:" GET cAssunto   PICTURE "@S60" VALID ! Empty( cAssunto )
      READ
      Mensagem()
      IF LastKey() != K_ESC
         EnviaEmail( { cEmailDest },, cAssunto, "", { cTmpFile } )
      ENDIF
      fErase( cTmpFile )
   ENDIF
   ::GUIEnable()

   RETURN NIL

METHOD SeparaPaginas( cFileFullReport ) CLASS PrintPreviewClass

   LOCAL cReportName, cTextFullReport, nNumPag := 1, cFilePage, cTextPage

   cReportName     := Substr( cFileFullReport, 1, RAt( ".", cFileFullReport ) - 1 )
   cTextFullReport := MemoRead( cFileFullReport ) + Chr(12)
   TokenInit( @cTextFullReport, Chr(12) )
   DO WHILE ! TokenEnd()
      cTextPage := TokenNext( cTextFullReport )
      IF Len( cTextPage ) > 1
         IF Substr( cTextPage, 1, 1 ) == Chr(13)
            cTextPage := Substr( cTextPage, 2 )
         ENDIF
         cFilePage := cReportName + StrZero( nNumPag++, 6 ) + ".LST"
         AAdd( ::acFileList, cFilePage )
         HB_MemoWrit( cFilePage, cTextPage )
      ENDIF
   ENDDO

   RETURN NIL

STATIC PROCEDURE TeclaPrintPreview

   LOCAL nKey
   MEMVAR cOpc

   nKey := LastKey()
   cOpc := Upper( Chr( nKey ) )
   DO CASE
   CASE nKey == K_PGDN .OR. cOpc $ "3"
      cOpc := "+"
   CASE nKey == K_PGUP .OR. cOpc $ "9"
      cOpc := "-"
   CASE nKey == K_CTRL_PGUP // .OR. cOpc $ "7"
      cOpc := "P"
   CASE nKey == K_CTRL_PGDN // .OR. cOpc == "1"
      cOpc := "U"
   ENDCASE
   KEYBOARD Chr( K_ESC )

   RETURN
