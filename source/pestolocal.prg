/*
PESTOLOCAL - LOCALIZACAO PRODUTO
2013.01.25 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pEstoLocal

   LOCAL oFrm := AUXPROLOCClass():New()

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpconfi", "jptabel", "jpitem", "jpnumero", "jpsenha", "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_PROLOC
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXPROLOCClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_PROLOC
   METHOD Intervalo( nLini, nColi, nOpc, mieProLoc )

   ENDCLASS

METHOD Intervalo( nLini, nColi, nOpc, mieProLoc ) CLASS AUXPROLOCClass

   LOCAL acTxtOpc := { "Todos", "Específico" }
   LOCAL GetList := {}

   WAchoice( nLini, nColi, acTxtOpc, @nOpc, "Localização de Produto" )
   IF nOpc == 2
      wOpen( nLini, nColi + 10, nLini + 3,  nColi + 50, "Grupo de Produto" )
      @ nLini + 2, nColi + 12 GET mieProLoc PICTURE "@K 999999" VALID AUXPROLOCClass():Valida( @mieProLoc )
      Mensagem( "Digite Localização de Produto, F9 Pesquisa, ESC Sai" )
      READ
      wClose()
   ENDIF

   RETURN nOpc
