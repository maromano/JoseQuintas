/*
PLEISPISCST - CST DE PIS/COFINS
2013.01.15 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisPisCst

   LOCAL oFrm := AUXPISCSTClass():New()
   MEMVAR m_Prog

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_PISCST
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXPISCSTClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_PISCST
   METHOD TelaDados( lEdit )
   METHOD Especifico (lExiste )
   METHOD Valida( cCst, lMostra )

   ENDCLASS

METHOD TelaDados( lEdit ) CLASS AUXPISCSTClass

   LOCAL GetList := {}
   LOCAL maxCodigo := Left( jptabel->axCodigo, 2 )
   LOCAL maxDescri := jptabel->axDescri

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      maxCodigo := ::axKeyValue[1]
   ENDIF
   ::ShowTabs()
   @ Row()+1, 1 SAY "CST PIS/Cofins.....:" GET maxCodigo WHEN .F.
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
      REPLACE jptabel->axTabela WITH AUX_PISCST, jptabel->axCodigo WITH maxCodigo, jptabel->axInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE jptabel->axDescri WITH maxDescri
   IF ::cOpc == "A"
      REPLACE jptabel->axInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL

METHOD Especifico( lExiste ) CLASS AUXPISCSTClass

   LOCAL GetList := {}
   LOCAL maxCodigo := Left( jptabel->axCodigo, 2 )

   IF ::cOpc == "I"
      maxCodigo := Space(2)
   ENDIF
   @ Row()+1, 22 GET maxCodigo PICTURE "@K 99" VALID ! Empty( maxCodigo )
   Mensagem( "Digite código para cadastro, F9 pesquisa, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Empty( maxCodigo )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK AUX_PISCST + maxCodigo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { maxCodigo }

   RETURN .T.

METHOD Valida( cCst, lMostra ) CLASS AUXPISCSTClass

   hb_Default( @lMostra, .T. )
   @ Row(), 32 Say EmptyValue( jptabel->axDescri )
   IF ! Encontra( AUX_PISCST + cCst, "jptabel", "numlan" )
      MsgStop( "CST PIS não cadastrado!" )
      RETURN .F.
   ENDIF
   IF lMostra
      @ Row(), 32 Say jptabel->axDescri
   ENDIF

   RETURN .T.
