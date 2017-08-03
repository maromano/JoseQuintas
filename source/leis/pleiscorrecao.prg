/*
PLEISCORRECAO - CODIGOS P/ CARTA DE CORRECAO
2013.02.01 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisCorrecao

   LOCAL oFrm := AUXCARCORClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_CARCOR
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXCARCORClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_CARCOR

   ENDCLASS
