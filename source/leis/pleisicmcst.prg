/*
PLEISICMCST - CST/CSOSN DE ICMS
2013.01.15 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisIcmCst

   LOCAL oFrm := AUXICMCSTClass():New()
   MEMVAR m_Prog

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_ICMCST
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXICMCSTClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_ICMCST
   METHOD Especifico ( lExiste )
   METHOD Valida( cCodigo, lShow )

   ENDCLASS

METHOD Especifico( lExiste ) CLASS AUXICMCSTClass

   LOCAL GetList := {}
   LOCAL maxCodigo := Left( jptabel->axCodigo, 3 )

   IF ::cOpc == "I"
      maxCodigo := Space(3)
   ENDIF
   @ Row()+1, 22 GET maxCodigo PICTURE "@K 999" VALID ! Empty( maxCodigo )
   Mensagem( "Digite código para cadastro, F9 pesquisa, ESC volta" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Empty( maxCodigo )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK AUX_ICMCST + maxCodigo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { maxCodigo }

   RETURN .T.

METHOD Valida( cCodigo, lSHow ) CLASS AUXICMCSTClass

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
