/*
PLEISIPICST - CST DE IPI
2013.01 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisIpiCst

   LOCAL oFrm := AuxIpiCstClass():New()
   MEMVAR m_Prog

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_IPICST
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXIPICSTClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_IPICST
   METHOD TelaDados( lEdit )
   METHOD Especifico( lExiste )
   METHOD Valida( cCst, nAliquota )

   ENDCLASS

METHOD TelaDados( lEdit ) CLASS AUXIPICSTClass

   LOCAL GetList := {}
   LOCAL maxCodigo := Left( jptabel->axCodigo, 2 )
   LOCAL maxDescri := jptabel->axDescri

   lEdit := Iif( lEdit==NIL, .F., lEdit )
   IF ::cOpc == "I" .AND. lEdit
      maxCodigo := ::axKeyValue[1]
   ENDIF
   ::ShowTabs()
   @ Row()+1, 1 SAY "CST IPI............:" GET maxCodigo WHEN .F.
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
      REPLACE jptabel->axTabela WITH AUX_IPICST, jptabel->axCodigo WITH maxCodigo, jptabel->axInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE jptabel->axDescri With maxDescri
   IF ::cOpc == "A"
      REPLACE jptabel->axInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL

METHOD Especifico( lExiste ) CLASS AUXIPICSTClass

   LOCAL GetList := {}
   LOCAL maxCodigo := Left( jptabel->axCodigo, 2 )

   IF ::cOpc == "I"
      maxCodigo := Space(2)
   ENDIF
   @ Row()+1, 22 GET maxCodigo PICTURE "@K 99" VALID ! Empty( maxCodigo )
   Mensagem( "Digite código para cadastro, F9 pesquisa, ESC volta" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Empty( maxCodigo )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK AUX_IPICST + maxCodigo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { maxCodigo }

   RETURN .T.

METHOD Valida( cCst, nAliquota ) CLASS AUXIPICSTClass

   IF ! Encontra( AUX_IPICST + cCst, "jptabel", "numlan" )
      MsgStop( "CST de IPI não cadastrado!" )
      RETURN .F.
   ENDIF
   IF cCst $ "01,02,03,04,05,51,52,53,55"
      nAliquota := 0
   ENDIF
   @ Row(), 32 SAY jptabel->axDescri

   RETURN .T.
