/*
PLEISREFCTA - PLANO DE CONTAS REFERENCIAL
2010.05.13 - José Quintas
*/

#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisRefCta

   LOCAL oFrm := LeisRefCtaClass():New()

   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi", "jprefcta", "ctplano" )
      RETURN
   ENDIF
   SELECT jprefcta
   oFrm:Execute()

   RETURN

CREATE CLASS LeisRefCtaClass INHERIT FrmCadastroClass

   METHOD Especifico( lExiste )
   METHOD TelaDados( lEdit )
   METHOD GridSelection()

   ENDCLASS

METHOD GridSelection() CLASS LeisRefCtaClass

   LOCAL nSelect := Select(), oTBrowse

   oTBrowse := { ;
      { "CÓDIGO",    { || jprefcta->rcCodigo } }, ;
      { "DESCRIÇÃO", { || Substr( jprefcta->rcDescri, 1, 40 ) } } }
   SELECT jprefcta
   FazBrowse( oTBrowse )
   IF LastKey() != K_ESC .AND. ! Eof()
      KEYBOARD jprefcta->rcCodigo + Chr( K_ENTER )
   ENDIF
   SELECT ( nSelect )

   RETURN NIL

METHOD Especifico(lExiste) CLASS LeisRefCtaClass

   LOCAL GetList := {}
   LOCAL mrcCodigo := jprefcta->rcCodigo

   IF ::cOpc == "I"
      mrcCodigo := EmptyValue( mrcCodigo )
   ENDIF
   @ Row()+1, 20 GET mrcCodigo PICTURE "@K!"  VALID ! Empty( mrcCodigo )
   Mensagem( "Digite código, F9 pesquisa, ESC volta" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Empty( mrcCodigo )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK mrcCodigo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { mrcCodigo }

   RETURN .T.

METHOD TelaDados(lEdit) CLASS LeisRefCtaClass

   LOCAL GetList := {}
   LOCAL mrcCodigo := jprefcta->rcCodigo
   LOCAL mrcDescri := jprefcta->rcDescri
   LOCAL mrcValDe  := jprefcta->rcValDe
   LOCAL mrcValAte := jprefcta->rcValAte
   LOCAL mrcTipo   := jprefcta->rcTipo
   LOCAL mrcInfInc := jprefcta->rcInfInc
   LOCAL mrcInfAlt := jprefcta->rcInfAlt

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      mrcCodigo := ::axKeyValue[ 1 ]
   ENDIF
   DO WHILE .T.
      ::ShowTabs()
      DO CASE
      CASE ::nNumTab == 1
         @ Row() + 1, 1 SAY "Código...........:" GET mrcCodigo WHEN .F.
         @ Row() + 2, 1 SAY "Descrição........:" GET mrcDescri PICTURE "@!"
         @ Row() + 1, 1 SAY "Validade desde...:" GET mrcValDe
         @ Row() + 1, 1 SAY "Validate Até.....:" GET mrcValAte
         @ Row() + 1, 1 SAY "Analítica/Sintét.:" GET mrcTipo PICTURE "!A" VALID mrcTipo $ "AS"
         @ Row() + 2, 1 SAY "Inf.Inclusão.....:" GET mrcInfInc WHEN .F.
         @ Row() + 1, 1 SAY "Inf.Alteração....:" GET mrcInfAlt WHEN .F.
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
      IF ::nNumTab == Len( ::acTabName ) + 1
         EXIT
      ENDIF
   ENDDO
   IF ! lEdit
      RETURN NIL
   ENDIF
   IF LastKey() != K_ESC
      IF ::cOpc == "I"
         mrcCodigo := ::axKeyValue[ 1 ]
         RecAppend()
         REPLACE ;
            jprefcta->rcCodigo WITH mrcCodigo, ;
            jprefcta->rcInfInc WITH LogInfo()
         RecUnlock()
      ENDIF
      RecLock()
      REPLACE ;
         jprefcta->rcDescri WITH mrcDescri, ;
         jprefcta->rcValDe  WITH mrcValDe, ;
         jprefcta->rcValAte WITH mrcValAte, ;
         jprefcta->rcTipo   WITH mrcTipo
      IF ::cOpc == "A"
         REPLACE jprefcta->rcInfAlt WITH LogInfo()
      ENDIF
      RecUnlock()
   ENDIF
   ::nNumTab := 1

   RETURN NIL
