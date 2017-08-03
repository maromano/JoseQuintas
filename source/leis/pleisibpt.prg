/*
PLEISIBPT PIBPT - TABELA IBPT
2013.05.29 José Quintas
*/

#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisIbpt

   LOCAL oFrm := LeisIbptClass():New()

   IF ! AbreArquivos( "jpibpt" )
      RETURN
   ENDIF
   SELECT jpibpt
   oFrm:Execute()

   RETURN

CREATE CLASS LeisIbptClass INHERIT FrmCadastroClass

   METHOD GridSelection()
   METHOD Especifico( lExiste )
   METHOD TelaDados( lEdit )
   METHOD Valida( cCodigo )

   ENDCLASS

METHOD GridSelection() CLASS LeisIbptClass

   LOCAL oTBrowse, nSelect := Select()

   SELECT jpibpt
   oTBrowse := { ;
      { "CÓDIGO",  { || jpibpt->ibCodigo } }, ;
      { "EX",      { || jpibpt->ibExcecao } }, ;
      { "NCM/NBS", { || jpibpt->ibNcmNbs } }, ;
      { "% NAC",   { || Transform( jpibpt->ibNacAli, PicVal(7,2) ) } }, ;
      { "% IMP",   { || Transform( jpibpt->ibImpAli, PicVal(7,2) ) } } }
   FazBrowse( oTBrowse )
   IF LastKey() != K_ESC .AND. ! Eof()
      KEYBOARD jpibpt->ibCodigo + Chr( K_ENTER )
   ENDIF
   SELECT ( nSelect )

   RETURN NIL

METHOD Especifico( lExiste ) CLASS LeisIbptClass

   LOCAL GetList := {}
   LOCAL mibCodigo := jpibpt->ibCodigo

   @ Row()+1, 20 GET mibCodigo PICTURE "@K 999999999" VALID ! Empty( mibCodigo )
   Mensagem( "Digite código, F9 pesquisa, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Empty( mibCodigo )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK mibCodigo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { mibCodigo }

   RETURN .T.

METHOD TelaDados( lEdit ) CLASS LeisIbptClass

   LOCAL GetList := {}
   LOCAL mibCodigo  := jpibpt->ibCodigo
   LOCAL mibExcecao := jpibpt->ibExcecao
   LOCAL mibNcmNbs  := jpibpt->ibNcmNbs
   LOCAL mibNacAli  := jpibpt->ibNacAli
   LOCAL mibImpAli  := jpibpt->ibImpAli
   LOCAL mibInfInc  := jpibpt->ibinfinc
   LOCAL mibInfAlt  := jpibpt->ibInfAlt

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      mibCodigo := ::axKeyValue[ 1 ]
      ::nNumTab := 1
   ENDIF
   DO WHILE .T.
      ::ShowTabs()
      DO CASE
      CASE ::nNumTab == 1
         @ Row()+1, 1  SAY "Código...........:" GET mibCodigo  WHEN .F.
         @ Row()+2, 1  SAY "Exceção..........:" GET mibExcecao PICTURE "@!"
         @ Row()+1, 1  SAY "NBM / NBS .......:" GET mibNcmNbs  PICTURE PicNcm()
         @ Row()+1, 1  SAY "% Prod.Nacional..:" GET mibNacAli  PICTURE "9999.99"  VALID mibNacAli >= 0
         @ Row()+1, 1  SAY "% Prod.Importado.:" GET mibImpAli  PICTURE "9999.99"  VALID mibNacAli >= 0
         @ Row()+2, 1  SAY "Inf.Inclusão.....:" GET mibinfinc  WHEN .F.
         @ Row()+1, 1  SAY "Inf.Alteração....:" GET mibInfAlt  WHEN .F.
      ENDCASE
      //SetPaintGetList( GetList )
      IF ! lEdit
         CLEAR GETS
         EXIT
      ENDIF
      Mensagem( "Digite campos, F9 Pesquisa, ESC Sai" )
      READ
      Mensagem()
      ::nNumTab += 1
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      IF ::nNumTab > Len( ::acTabName )
         EXIT
      ENDIF
   ENDDO
   IF ! lEdit
      RETURN NIL
   ENDIF
   ::nNumTab := 1
   IF LastKey() == K_ESC
      RETURN NIL
   ENDIF
   IF ::cOpc == "I"
      mibCodigo := ::axKeyValue[ 1 ]
      RecAppend()
      REPLACE ;
         jpibpt->ibCodigo WITH mibCodigo, ;
         jpibpt->ibinfinc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE ;
      jpibpt->ibExcecao WITH mibExcecao, ;
      jpibpt->ibNcmNbs  WITH mibNcmNbs, ;
      jpibpt->ibNacAli  WITH mibNacAli, ;
      jpibpt->ibImpAli  WITH mibImpAli
   IF ::cOpc == "A"
      REPLACE jpibpt->ibInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL

METHOD Valida( cCodigo ) CLASS LeisIbptClass

   LOCAL lOk := .T.

   IF ! Encontra( cCodigo, "jpibpt", "numlan" )
      MsgWarning( "Código não cadastrado!" )
      lOk := .F.
   ENDIF

   RETURN lOk
