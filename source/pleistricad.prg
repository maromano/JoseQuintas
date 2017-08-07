/*
PLEISTRICAD - TRIBUTACAO DE CADASTROS
2013.01 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisTriCad

   LOCAL oFrm := AUXTRICADClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_TRICAD
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXTRICADClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_TRICAD

   ENDCLASS
