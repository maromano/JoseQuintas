/*
PCONTREDRENUM - REGRAVA CODIGO REDUZIDO DAS CONTAS
1992.07.26 José Quintas
*/

PROCEDURE pContRedRenum

LOCAL nCodigo, m_Conf, GetList := {}

   IF ! AbreArquivos( "jpempre", "ctplano" )
      RETURN
   ENDIF
SELECT ctplano

SayScroll("ATENCAO!!!" )
SayScroll("Esta rotina renumera os códigos reduzidos em ordem crescente, seguindo a ordem")
SayScroll("do plano de contas. Serão alterados todos os códigos  reduzidos  do  plano  de")
SayScroll("contas")
SayScroll("Os lançamentos não seram afetados, devido  a  serem  registrados  pelo  código")
SayScroll("normal")
SayScroll("Após a execução deste  modulo,  os  códigos  anteriores  somente  poderão  ser")
SayScroll("recuperados através do retorno de um backup (Faça um backup antes de executar)")

mensagem( "Confirme a operação digitando <SIM>" )
m_conf = "NAO"
@ Row(), Col()+2 GET m_conf PICTURE "@!"
READ
mensagem()

IF m_conf == "SIM"
   Mensagem( "Aguarde... alterando códigos reduzidos..." )
   SayScroll( "Alterando códigos reduzidos do plano..." )
   GOTO TOP
   nCodigo = 1
   DO WHILE ! eof()
      grafproc()
      IF ctplano->a_tipo == "A"
         RecLock()
         REPLACE ctplano->a_reduz WITH str( nCodigo, 5 ) + CalculaDigito( str(nCodigo), "11" )
         nCodigo += 1
         RecUnlock()
      ENDIF
      SKIP
   ENDDO
   Mensagem()
   MsgExclamation( "Fim")
ENDIF
CLOSE DATABASES
RETURN
