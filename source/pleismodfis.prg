/*
PLEISMODFIS - MODELOS DE DOCTO FISCAL
2013.02 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisModFis

   LOCAL oFrm := AUXMODFISClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_MODFIS
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXMODFISClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_MODFIS
   METHOD Especifico( lExiste )
   METHOD TelaDados( lEdit )
   METHOD GridSelection()
   METHOD Valida( cCodigo, lShow )

   ENDCLASS

METHOD GridSelection() CLASS AUXMODFISClass

   LOCAL oTBrowse, nSelect := Select(), cOrdSetFocus

   SELECT jptabel
   oTBrowse := { ;
      { "NOME",   { || jptabel->axDescri } }, ;
      { "CÓDIGO", { || Left( jptabel->axCodigo, 2 ) } } }
   cOrdSetFocus := OrdSetFocus( "descricao" )
   FazBrowse( oTBrowse,, ::cTabelaAuxiliar )
   IF LastKey() != K_ESC .AND. ! Eof()
      KEYBOARD Left( jptabel->axCodigo, 2 ) + Chr( K_ENTER )
   ENDIF
   OrdSetFocus( cOrdSetFocus )
   SELECT ( nSelect )

   RETURN NIL

METHOD Especifico( lExiste ) CLASS AUXMODFISClass

   LOCAL GetList := {}
   LOCAL maxCodigo := Left( jptabel->axCodigo, 2 )

   IF ::cOpc == "I"
      maxCodigo := Space(2)
   ENDIF
   @ Row()+1, 20 GET maxCodigo PICTURE "@K!!" VALID ! Empty( maxCodigo )
   Mensagem( "Digite código, F9 pesquisa, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Empty( maxCodigo )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK AUX_MODFIS + maxCodigo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { maxCodigo }

   RETURN .T.

METHOD TelaDados( lEdit ) CLASS AUXMODFISClass

   LOCAL GetList := {}
   LOCAL maxCodigo := Left( jptabel->axCodigo, 2 )
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
         @ Row()+1, 1 SAY "Código...........:" GET maxCodigo WHEN .F.
         @ Row()+2, 1 SAY "Descrição........:" GET maxDescri PICTURE "@!"       VALID ! Empty( maxDescri )
         @ Row()+2, 1 SAY "Inf.Inclusão.....:" GET maxInfInc WHEN .F.
         @ Row()+1, 1 SAY "Inf.Alteração....:" GET maxInfAlt WHEN .F.
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
      maxCodigo := ::axKeyValue[1]
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_MODFIS, jptabel->axCodigo WITH maxCodigo, jptabel->axInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE jptabel->axDescri WITH maxDescri
   IF ::cOpc == "A"
      REPLACE jptabel->axInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL

METHOD Valida( cCodigo, lShow ) CLASS AUXMODFISClass

   LOCAL lOk := .T., nRow := Row()
   MEMVAR m_Prog

   hb_Default( @lShow, .T. )

   IF lShow
      @ nRow, 32 SAY EmptyValue( jptabel->axDescri )
   ENDIF
   IF ! Encontra( ::cTabelaAuxiliar + Left( cCodigo, 2 ), "jptabel", "numlan" )
      MsgWarning( "Código não cadastrado!" )
      lOk := .F.
   ENDIF
   IF lShow
      @ nRow, 32 SAY jptabel->axDescri
   ENDIF

   RETURN lOk
