/*
PLEISTRIUF - TRIBUTACAO DE UF
2013.01.25 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisTriUf

   LOCAL oFrm := AUXTRIUFClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_TRIUF
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXTRIUFClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_TRIUF

   ENDCLASS
