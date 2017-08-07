/*
PLEISTRIEMP - TRIBUTACAO DA EMPRESA
2013.02 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisTriEmp

   LOCAL oFrm := AUXTRIEMPClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_TRIEMP
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXTRIEMPClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_TRIEMP

   ENDCLASS
