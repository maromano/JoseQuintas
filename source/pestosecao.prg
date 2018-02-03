/*
PESTOSECAO - ESTOQUE SECAO
2013.01 José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pEstoSecao

   LOCAL oFrm := AUXPROSECClass():New()

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpconfi", "jptabel", "jpestoq", "jpitem", "jpsenha", "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_PROSEC
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXPROSECClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_PROSEC
   METHOD Intervalo( nLini, nColi, nOpc, mieProSec )

   ENDCLASS

METHOD Intervalo( nLini, nColi, nOpc, mieProSec ) CLASS AUXPROSECClass

   LOCAL acTxtOpc := { "Todos", "Específico" }
   LOCAL GetList := {}

   WAchoice( nLini, nColi, acTxtOpc, @nOpc, "Secao de produto" )
   IF nOpc == 2
      wOpen( nLini, nColi + 10, nLini + 3,  nColi + 50, "Seção de Estoque" )
      @ nLini + 2, nColi + 12 GET mieProSec PICTURE "@K 999999" VALID AUXPROSECClass():Valida( @mieProSec )
      Mensagem( "Digite Seção de Produto, F9 Pesquisa, ESC Sai" )
      READ
      wClose()
   ENDIF

   RETURN nOpc
