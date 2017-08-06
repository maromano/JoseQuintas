/*
PAUXCLIGRU - GRUPO DE CLIENTES
2013.02 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE PAUXCLIGRU

   LOCAL oFrm := AUXCLIGRUClass():New()

   IF ! AbreArquivos( "jpcadas", "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_CLIGRU
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXCLIGRUClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_CLIGRU

   ENDCLASS
