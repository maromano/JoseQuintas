/*
PCONTCTAADM - CONTAS ADMINISTRATIVAS
2013.01 José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pContCtaAdm

   LOCAL oFrm := ContCtaAdmClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_CTAADM
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS ContCtaAdmClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_CTAADM

   ENDCLASS
