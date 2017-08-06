/*
PAUXMOTIVO - MOTIVOS DE CANCELAMENTO
2013.02 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE PAUXMOTIVO

   LOCAL oFrm := AUXMOTIVOClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_MOTIVO
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXMOTIVOClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_MOTIVO

   ENDCLASS
