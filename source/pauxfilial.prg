/*
PAUXFILIAL - FILIAIS
2013.01 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE PAUXFILIAL

   LOCAL oFrm := AuxFilialClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_FILIAL
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AuxFilialClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_FILIAL

   ENDCLASS
