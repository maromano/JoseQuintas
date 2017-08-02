/*
PAUXCCUSTO - CENTROS DE CUSTO
2013.01.24 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE PAUXCCUSTO

   LOCAL oFrm := AUXCCUSTOClass():New()

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "ctdiari", "jptabel", "jpconfi", "jpfinan", "jplfisc", "jpnumero", "jpsenha", "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_CCUSTO
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXCCUSTOClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_CCUSTO

   ENDCLASS
