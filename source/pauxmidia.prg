/*
PAUXMIDIA - MIDIA
2013.08.06.0954 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE PAUXMIDIA

   LOCAL oFrm := AUXMIDIAClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_MIDIA
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXMIDIAClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_MIDIA

   ENDCLASS
