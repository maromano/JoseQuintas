/*
PAUXBANCO - BANCOS
2013.01 José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE PAUXBANCO

   LOCAL oFrm := AUXBANCOClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_BANCO
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXBANCOClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_BANCO

   ENDCLASS
