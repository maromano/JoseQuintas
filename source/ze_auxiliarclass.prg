/*
ZE_AUXILIARCLASS - ROTINA PRA TABELAS AUXILIARES
2013.09 - José Quintas
*/

#include "inkey.ch"
#include "hbclass.ch"

/*

PROCEDURE PAUXILIAR

LOCAL oFrm := AUXILIARClass():New()

IF ! AbreArquivos( "jptabel" )

RETURN
ENDIF
SELECT jptabel
SET FILTER TO &( "jptabel->axTabela == [" + oFrm:cTabelaAuxiliar + "]" )
oFrm:Execute()
CLOSE DATABASES

RETURN
*/

CREATE CLASS AUXILIARClass INHERIT frmCadastroClass

   VAR    cTabelaAuxiliar INIT "NAOTEM"
   METHOD Especifico( lExiste )
   METHOD TelaDados( lEdit )
   METHOD Valida( cCodigo, lShow )
   METHOD GridSelection()
   METHOD Descricao( cCodigo )

   ENDCLASS

METHOD GridSelection() CLASS AUXILIARClass

   LOCAL oTBrowse, nSelect := Select(), cOrdSetFocus

   SELECT jptabel
   oTBrowse := { ;
      { "NOME",   { || jptabel->axDescri } }, ;
      { "CÓDIGO", { || jptabel->axCodigo } } }
   cOrdSetFocus := OrdSetFocus( "descricao" )
   FazBrowse( oTBrowse,, ::cTabelaAuxiliar )
   IF LastKey() != K_ESC .AND. ! Eof()
      KEYBOARD jptabel->axCodigo + Chr( K_ENTER )
   ENDIF
   OrdSetFocus( cOrdSetFocus )
   SELECT ( nSelect )

   RETURN NIL

METHOD Especifico( lExiste ) CLASS AUXILIARClass

   LOCAL GetList := {}
   LOCAL maxCodigo := jptabel->axCodigo

   IF ::cOpc == "I"
      maxCodigo := "*NOVO*"
   ENDIF
   @ Row() + 1, 20 GET maxCodigo PICTURE "@K 999999" VALID NovoMaiorZero( @maxCodigo )
   Mensagem( "Digite código, F9 pesquisa, ESC volta" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. ( Val(maxCodigo) == 0 .AND. maxCodigo != "*NOVO*" )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK ::cTabelaAuxiliar + maxCodigo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { maxCodigo }

   RETURN .T.

METHOD TelaDados( lEdit ) CLASS AUXILIARClass

   LOCAL GetList := {}
   LOCAL maxCodigo := jptabel->axCodigo
   LOCAL maxDescri := jptabel->axDescri
   LOCAL maxInfInc := jptabel->axInfInc
   LOCAL maxInfAlt := jptabel->axInfAlt

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      maxCodigo := ::axKeyValue[1]
      ::nNumTab := 1
   ENDIF
   DO WHILE .T.
      ::ShowTabs()
      DO CASE
      CASE ::nNumTab == 1
         @ Row() + 1, 1  SAY "Código...........:" GET maxCodigo  WHEN .F.
         @ Row() + 2, 1  SAY "Descrição........:" GET maxDescri  PICTURE "@!" VALID ! Empty( maxDescri )
         @ Row() + 2, 1  SAY "Inf.Inclusão.....:" GET maxInfInc  WHEN .F.
         @ Row() + 1, 1  SAY "Inf.Alteração....:" GET maxInfAlt  WHEN .F.
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
      GOTO ::nUltRec
      RETURN NIL
   ENDIF
   IF ::cOpc == "I"
      maxCodigo := ::axKeyValue[ 1 ]
      IF maxCodigo == "*NOVO*"
         GOTO BOTTOM
         maxCodigo := StrZero( Val( jptabel->axCodigo ) + 1, 6 )
      ENDIF
      RecAppend()
      REPLACE ;
         jptabel->axTabela WITH ::cTabelaAuxiliar, ;
         jptabel->axCodigo WITH  maxCodigo, ;
         jptabel->axInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE jptabel->axDescri WITH maxDescri
   IF ::cOpc == "A"
      REPLACE jptabel->axInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL

METHOD Valida( cCodigo, lShow ) CLASS AUXILIARClass

   LOCAL lOk := .T., nRow := Row()
   MEMVAR m_Prog

   hb_Default( @lShow, .T. )

   IF lShow
      @ nRow, 32 SAY EmptyValue( jptabel->axDescri )
   ENDIF
   cCodigo := StrZero( Val( cCodigo ), 6 )
   IF ! Encontra( ::cTabelaAuxiliar + cCodigo, "jptabel", "numlan" )
      MsgWarning( "Código não cadastrado!" )
      lOk := .F.
   ENDIF
   IF lShow
      @ nRow, 32 SAY jptabel->axDescri
   ENDIF

   RETURN lOk

METHOD Descricao( cCodigo ) CLASS AUXILIARClass

   Encontra( ::cTabelaAuxiliar + cCodigo, "jptabel", "numlan" )

   RETURN jptabel->axDescri
