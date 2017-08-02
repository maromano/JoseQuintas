/*
PLEISTRIPRO - TRIBUTACAO DE PRODUTOS
2013.01.25 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisTriPro

   LOCAL oFrm := AUXTRIPROClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_TRIPRO
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXTRIPROClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_TRIPRO

   ENDCLASS
