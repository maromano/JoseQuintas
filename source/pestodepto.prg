/*
PESTODEPTO - DEPTO PRODUTO
2013.01 José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pEstoDepto

   LOCAL oFrm := AUXPRODEPClass():New()

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpconfi", "jptabel", "jpitem", "jpnumero", "jpsenha", "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_PRODEP
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXPRODEPClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_PRODEP
   METHOD Intervalo( nLini, nColi, nOpc, mieprodep )

   ENDCLASS

METHOD Intervalo( nLini, nColi, nOpc, mieprodep ) CLASS AUXPRODEPClass

   LOCAL acTxtOpc := { "Todos", "Específico" }
   LOCAL GetList := {}

   WAchoice( nLini, nColi, acTxtOpc, @nOpc, "Depto de produto" )
   IF nOpc == 2
      wOpen( nLini, nColi + 10, nLini + 3,  nColi + 50, "Depto de produto" )
      @ nLini + 2, nColi + 12 GET mieProDep PICTURE "@K 999999" VALID ::Valida( @mieProDep )
      Mensagem( "Digite Departamento de Produto, F9 Pesquisa, ESC Sai" )
      READ
      wClose()
   ENDIF

   RETURN nOpc
