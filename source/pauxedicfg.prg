/*
PAUXEDICFG - CODIGOS DE EDI
2013.02 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE PAUXEDICFG

   LOCAL oFrm := AUXEDICFGClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_EDICFG
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXEDICFGClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_EDICFG

   ENDCLASS
