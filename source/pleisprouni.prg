/*
PLEISPROUNI - PRODUTO UNIDADE DE MEDIDA
2013.01 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisProUni

   LOCAL oFrm := AUXPROUNIClass():New()
   MEMVAR m_Prog

   IF ! AbreArquivos( "jpitem", "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_PROUNI
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXPROUNIClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_PROUNI
   METHOD TelaDados( lEdit )
   METHOD Especifico (lExiste )
   METHOD Valida( cCodigo )
   METHOD GridSelection()

   ENDCLASS

METHOD GridSelection() CLASS AUXPROUNIClass

   LOCAL nSelect := Select(), cOrdSetFocus

   SELECT jptabel
   cOrdSetFocus := OrdSetFocus( "descricao" )
   FazBrowse(,, AUX_PROUNI )
   IF LastKey() != K_ESC .AND. ! Eof()
      KEYBOARD jptabel->axCodigo + Chr( K_ENTER )
   ENDIF
   OrdSetFocus( cOrdSetFocus )
   SELECT ( nSelect )

   RETURN NIL

METHOD TelaDados( lEdit ) CLASS AUXPROUNIClass

   LOCAL GetList := {}
   LOCAL maxCodigo  := jptabel->axCodigo
   LOCAL maxDescri  := jptabel->axDescri

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      maxCodigo := ::axKeyValue[1]
   ENDIF
   ::ShowTabs()
   @ Row()+1, 1 SAY "Nomenclatura.......:" GET maxCodigo WHEN .F.
   @ Row()+2, 1 SAY "Descrição..........:" GET maxDescri PICTURE "@!" VALID ! Empty( maxDescri )
   //SetPaintGetList( GetList )
   IF ! lEdit
      CLEAR GETS
      RETURN NIL
   ENDIF
   Mensagem( "Digite campos, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC
      GOTO ::nUltRec
      RETURN NIL
   ENDIF
   IF ::cOpc == "I"
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_PROUNI, jptabel->axCodigo WITH maxCodigo, jptabel->axInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE jptabel->axDescri With maxDescri
   IF ::cOpc == "A"
      REPLACE jptabel->axInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL

METHOD Especifico( lExiste ) CLASS AUXPROUNIClass

   LOCAL GetList := {}
   LOCAL maxCodigo := jptabel->axCodigo

   IF ::cOpc == "I"
      maxCodigo := Space(6)
   ENDIF
   @ Row()+1, 22 GET maxCodigo PICTURE "@K!" VALID ! Empty( maxCodigo )
   Mensagem( "Digite código para cadastro, F9 pesquisa, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Empty( maxCodigo )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK AUX_PROUNI + maxCodigo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { maxCodigo }

   RETURN .T.

METHOD Valida( cCodigo ) CLASS AUXPROUNIClass

   IF ! Encontra( AUX_PROUNI + cCodigo, "jptabel", "numlan" )
      MsgWarning( "Unidade não cadastrada!" )
      RETURN .F.
   ENDIF

   RETURN .T.
