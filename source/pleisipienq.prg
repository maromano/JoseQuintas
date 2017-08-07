/*
PLEISIPIENQ - ENQUADRAMENTO DE IPI
2013.01 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisIpiEnq

   LOCAL oFrm := AUXIPIENQClass():New()
   MEMVAR m_Prog

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_IPIENQ
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXIPIENQClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_IPIENQ
   METHOD TelaDados( lEdit )
   METHOD Especifico ( lExiste )
   METHOD Valida( cCodigo, lShow )

   ENDCLASS

METHOD TelaDados( lEdit ) CLASS AUXIPIENQClass

   LOCAL GetList := {}
   LOCAL maxCodigo := Left( jptabel->axCodigo, 3 )
   LOCAL maxDescri := jptabel->axDescri

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      maxCodigo := ::axKeyValue[1]
   ENDIF
   ::ShowTabs()
   @ Row() + 1, 1 SAY "Enq.IPI............:" GET maxCodigo  WHEN .F.
   @ Row() + 2, 1 SAY "Descrição..........:" GET maxDescri PICTURE "@!" VALID ! Empty( maxDescri )
   @ Row() + 5, 22 SAY "Código composto de CST + Código de enquadramento"
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
      REPLACE jptabel->axTabela WITH AUX_IPIENQ, jptabel->axCodigo WITH maxCodigo, jptabel->axInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE jptabel->axDescri With maxDescri
   IF ::cOpc == "A"
      REPLACE jptabel->axInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL

METHOD Especifico( lExiste ) CLASS AUXIPIENQClass

   LOCAL GetList := {}
   LOCAL maxCodigo := Left( jptabel->axCodigo, 3 )

   IF ::cOpc == "I"
      maxCodigo := "999"
   ENDIF
   @ Row() + 1, 22 GET maxCodigo PICTURE "@K 999" VALID Val( maxCodigo ) > 0
   @ Row() + 5, 22 SAY "Código composto de CST + Código de enquadramento"
   Mensagem( "Digite código para cadastro, F9 pesquisa, ESC volta" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Val( maxCodigo ) == 0
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK AUX_IPIENQ + maxCodigo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { maxCodigo }

   RETURN .T.

METHOD Valida( cCodigo, lShow ) CLASS AUXIPIENQClass

   hb_Default( @lShow, .T. )
   IF lSHow
      @ Row(), 32 SAY EmptyValue( jptabel->axDescri )
   ENDIF
   IF ! Encontra( ::cTabelaAuxiliar + cCodigo, "jptabel", "numlan" )
      MsgExclamation( "Código não cadastrado" )
      RETURN .F.
   ENDIF
   IF lSHow
      @ Row(), 32 SAY jptabel->axDescri
   ENDIF

   RETURN .T.
