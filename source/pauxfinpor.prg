/*
PAUXFINPOR - FINANCEIRO PORTADOR
2013.01 José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE PAUXFINPOR

   LOCAL oFrm := AuxFinPorClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_FINPOR
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AuxFinPorClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_FINPOR

   ENDCLASS
