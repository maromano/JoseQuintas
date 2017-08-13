/*
PAUXFINOPE - FINANCEIRO OPERACAO
2013.01 José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE PAUXFINOPE

   LOCAL oFrm := AuxFinOpeClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_FINOPE
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AuxFinOpeClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_FINOPE

   ENDCLASS
