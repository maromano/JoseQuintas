/*
PESTOGRUPO - GRUPO PRODUTO
2013.01.25 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pEstoGrupo

   LOCAL oFrm := AUXPROGRUClass():New()

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpconfi", "jptabel", "jpitem", "jpnumero", "jpsenha", "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_PROGRU
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXPROGRUClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_PROGRU
   METHOD Intervalo( nLini, nColi, nOpc, mieProGru )

   ENDCLASS

METHOD Intervalo( nLini, nColi, nOpc, mieProGru ) CLASS AUXPROGRUClass

   LOCAL acTxtOpc := { "Todos", "Específico" }
   LOCAL GetList := {}

   WAchoice( nLini, nColi, acTxtOpc, @nOpc, "Grupo de Produto" )
   IF nOpc == 2
      wOpen( nLini, nColi + 10, nLini + 3,  nColi + 50, "Grupo de Produto" )
      @ nLini + 2, nColi + 12 GET mieProGru PICTURE "@K 999999" VALID AUXPROGRUClass():Valida( @mieProGru )
      Mensagem( "Digite Grupo de Produto, F9 Pesquisa, ESC Sai" )
      READ
      wClose()
   ENDIF

   RETURN nOpc
