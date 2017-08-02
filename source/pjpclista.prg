/*
PJPCLISTA - STATUS DE CLIENTES
2013.02.01 José Quintas
*/

#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE PJPCLISTA

   LOCAL oFrm := JPCLISTAClass():New()

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso", "jpdecret" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpcadas", "jpcidade", "jpclista", "jpcomiss", "jpconfi", "jpempre", ;
      "jpestoq", "jpfinan", "jpforpag", "jpimpos", "jpitem", "jpitped", "jplfisc", "jpnota", "jpnumero", "jppedi", ;
      "jppreco", "jpsenha", "jptabel", "jptransa", "jpuf", "jpveicul", "jpvended" )
      RETURN
   ENDIF
   SELECT jpclista
   oFrm:Execute()

   RETURN

CREATE CLASS JPCLISTAClass INHERIT FrmCadastroClass

   METHOD GridSelection()
   METHOD Especifico( lExiste )
   METHOD TelaDados( lEdit )
   METHOD Valida( cCodigo, lMostra )

   ENDCLASS

METHOD GridSelection() CLASS JPCLISTAClass

   LOCAL oTbrowse, nSelect := Select(), cOrdSetFocus

   SELECT jpclista
   cOrdSetFocus := OrdSetFocus( "descricao" )
   oTBrowse := { ;
      { "NOME",   { || jpclista->csDescri } }, ;
      { "CÓDIGO", { || jpclista->csNumLan } } }
   FazBrowse( oTBrowse )
   IF LastKey() != K_ESC .AND. ! Eof()
      KEYBOARD jpclista->csNumLan + Chr( K_ENTER )
   ENDIF
   OrdSetFocus( cOrdSetFocus )
   SELECT ( nSelect )

   RETURN NIL

METHOD Especifico( lExiste ) CLASS JPCLISTAClass

   LOCAL GetList := {}
   LOCAL mcsNumLan := jpclista->csNumLan

   IF ::cOpc == "I"
      mcsNumLan := "*NOVO*"
   ENDIF
   @ Row()+1, 20 GET mcsNumLan PICTURE "@K 999999" VALID NovoMaiorZero( @mcsNumLan )
   Mensagem( "Digite código, F9 pesquisa, ESC volta" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. ( Val(mcsNumLan) == 0  .AND. mcsNumLan != "*NOVO*" )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK mcsNumLan
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { mcsNumLan }

   RETURN .T.

METHOD TelaDados( lEdit ) CLASS JPCLISTAClass

   LOCAL GetList := {}
   LOCAL mcsNumLan   := jpclista->csNumLan
   LOCAL mcsDescri   := jpclista->csDescri
   LOCAL mcsBloqueio := jpclista->csBloqueio
   LOCAL mcsInfInc   := jpclista->csInfInc
   LOCAL mcsInfAlt   := jpclista->csInfAlt

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      mcsNumLan := ::axKeyValue[1]
      ::nNumTab := 1
   ENDIF
   DO WHILE .T.
      ::ShowTabs()
      DO CASE
      CASE ::nNumTab == 1
         @ Row() + 1, 1 SAY "Código...........:" GET mcsNumLan  WHEN .F.
         @ Row() + 2, 1 SAY "Descrição........:" GET mcsDescri  PICTURE "@!"       VALID ! Empty( mcsDescri )
         @ Row() + 1, 1 SAY "Nível de Bloqueio:" GET mcsBloqueio PICTURE "9"
         @ Row() + 2, 1 SAY "Inf.Inclusão.....:" GET mcsInfInc  WHEN .F.
         @ Row() + 1, 1 SAY "Inf.Alteração....:" GET mcsInfAlt  WHEN .F.
         @ Row() + 6, 1 SAY "Nível de Bloqueio:"
         @ Row() + 2, 1 SAY "0=Total"
         @ Row() + 1, 1 SAY "1=Não deixa Confirmar Pedido"
         @ Row() + 1, 1 SAY "2=Apenas Mostra Mensagem"
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
      mcsNumLan := ::axKeyValue[1]
      IF mcsNumLan == "*NOVO*"
         mcsNumLan := NovoCodigo( "jpclista->csNumLan" )
      ENDIF
      RecAppend()
      REPLACE ;
         jpclista->csNumLan WITH mcsNumLan, ;
         jpclista->csInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE ;
      jpclista->csDescri WITH mcsDescri, ;
      jpclista->csBloqueio WITH mcsBloqueio
   IF ::cOpc == "A"
      REPLACE jpclista->csInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL

METHOD Valida( cCodigo, lMostra ) CLASS JPCLISTAClass

   LOCAL lOk := .T.
   MEMVAR m_Prog

   hb_Default( @lMostra, .T. )

   cCodigo := StrZero( Val( cCodigo ), 6 )
   IF ! Encontra( cCodigo, "jpclista", "numlan" )
      MsgWarning( "Código não cadastrado!" )
      lOk := .F.
   ENDIF
   IF lMostra
      @ Row(), 32 SAY jpclista->csDescri
   ENDIF

   RETURN lOk
