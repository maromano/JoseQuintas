/*
PJPTRANSA - TRANSACOES
2013.01 José Quintas
*/

#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE PJPTRANSA

   LOCAL oFrm := JPTRANSAClass():New()
   MEMVAR m_Prog

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpconfi", "jpempre", "jpestoq", "jpimpos", "jpnota", "jpnumero", "jppedi", "jpsenha", "jptabel", "jptransa" )
      RETURN
   ENDIF
   SELECT jptransa
   oFrm:Execute()

   RETURN

CREATE CLASS JPTRANSAClass INHERIT frmCadastroClass

   METHOD GridSelection()
   METHOD TelaDados( lEdit )
   METHOD Especifico( lExiste )
   METHOD Valida( cTransacao, lMostra )
   METHOD Delete()
   METHOD Intervalo( nLini, nColi, nOpc, mpdTransa )

   ENDCLASS

METHOD GridSelection() CLASS JPTRANSAClass

   LOCAL nSelect := Select(), cOrdSetFocus

   SELECT jptransa
   cOrdSetFocus := OrdSetFocus( "descricao" )
   FazBrowse()
   IF Lastkey() != K_ESC .AND. ! Eof()
      KEYBOARD jptransa->trTransa + Chr( K_ENTER )
   ENDIF
   OrdSetFocus( cOrdSetFocus )
   SELECT ( nSelect )

   RETURN NIL

METHOD TelaDados( lEdit ) CLASS JPTRANSAClass

   LOCAL GetList := {}
   LOCAL mtrTransa := jptransa->trTransa
   LOCAL mtrDescri := jptransa->trDescri
   LOCAL mtrReacao := jptransa->trReacao

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      mtrTransa := ::axKeyValue[1]
   ENDIF
   ::ShowTabs()
   @ Row() + 1, 1 SAY "Código.............:" GET mtrTransa PICTURE "@KR 999.999" WHEN .F.
   @ Row() + 2, 1 SAY "Descrição..........:" GET mtrDescri PICTURE "@!"
   @ Row() + 2, 1 SAY "Reação pedido......:" GET mtrReacao PICTURE "@!"
   @ Row() + 2, 1 SAY "TTT.RRR => TTT = Transação atual, sendo 001 a 499 para entradas, e 500 a 999 pra saídas"
   @ Row() + 1, 1 SAY "           RRR = Transação que deve existir para baixa"
   @ Row() + 1, 1 SAY "C+R,C+R1,C+1,C-1 => Confirmação afeta estoque, +R soma ao reservado, +1 soma ao estoque 1, -1 tira do estoque 1, +2 Soma ao estoque 2"
   @ Row() + 1, 1 SAY "N-R,N-R1,N-1,N+2,N+3,N+4 => Emissão de nota afeta estoque, -R tira do reservado, -1 Tira do estoque 1, +2 soma ao estoque 2"
   @ Row() + 1, 1 SAY "CCUSCON,NCUSCON => Atualização do custo contábil, na C=Confirmação ou N=Emissao da nota"
   @ Row() + 1, 1 SAY "CULTENT,NULTENT => Atualização da última entrada, na C=Confirmação ou N=Emissão da nota"
   @ Row() + 1, 1 SAY "CULTSAI,NULTSAI => Atualização da última saida, na C=Confirmação ou N=Emissão da nota"
   @ Row() + 1, 1 SAY "CDEVCOM,CDEVVEN,NDEVCOM,NDEVVEN => Devolução de compra ou venda, se afeta estoque na C=Confirmação ou N=Emissão da nota"
   @ Row() + 1, 1 SAY "VENDA,COMPRA => Se o pedido entra nos relatórios de compra ou venda"
   @ Row() + 1, 1 SAY "ATRASO => Não permite confirmar ou emitir nota se houver pagamento em atraso"
   @ Row() + 1, 1 SAY "LIMCRE => Não permite confirmar ou emitir nota se ultrapassar limite de crédito em aberto"
   @ Row() + 1, 1 SAY "SEMFIN => Não gera informação para o financeiro"
   @ Row() + 1, 1 SAY "PEDREL => Exige pedido relacionado (DEVCOM e DEVVEN já fazem isso) (Transação ???999 exige 999???)"
   @ Row() + 1, 1 SAY "ADMPEDLIBn => Somente usuário com acesso à ADMPEDLIBn pode liberar - n=1 a 9"
   @ Row() + 1, 1 SAY "+AJUSTE,-AJUSTE => Nota fiscal de ajuste, pra adicionar ou remover algo (*)"
   @ Row() + 1, 1 SAY "CONSUMIDOR => Nota pra consumidor, indica finalidade consumo e mostra impostos ref. venda a consumidor"
   @ Row() + 2, 1 SAY "IMPOSTO => Deixou de ser usado"
   SEEK mtrTransa
   //SetPaintGetList( GetList )
   IF ! lEdit
      CLEAR GETS
      RETURN NIL
   ENDIF
   Mensagem( "Digite campos, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC
      GOTO ::nUltRec
      RETURN NIL
   ENDIF
   IF ::cOpc == "I"
      IF mtrTransa != "*NOVO*"
         IF Encontra( mtrTransa, "jptransa", "numlan" )
            mtrTransa := "*NOVO*"
         ENDIF
      ENDIF
      IF mtrTransa == "*NOVO*"
         mtrTransa := NovoCodigo( "jptransa->trTransa" )
      ENDIF
      RecAppend()
      REPLACE jptransa->trTransa WITH mtrTransa, jptransa->trInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE jptransa->trDescri WITH mtrDescri, jptransa->trReacao WITH mtrReacao
   IF ::cOpc == "A"
      REPLACE jptransa->trInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL

METHOD Especifico( lExiste ) CLASS JPTRANSAClass

   LOCAL GetList := {}
   LOCAL mtrTransa := jptransa->trTransa
   MEMVAR m_Prog

   IF ::cOpc == "I"
      mtrTransa = "*NOVO*"
   ENDIF
   @ Row()+1, 22 GET mtrTransa PICTURE "@KR 999.999" VALID NovoMaiorZero( @mtrTransa )
   Mensagem( "Digite código para cadastro, F9 pesquisa, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. ( Val( mtrTransa ) == 0 .AND. mtrTransa != "*NOVO*" )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK mtrTransa
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { mtrTransa }

   RETURN .T.

METHOD Delete() CLASS JPTRANSAClass

   LOCAL lExclui := .T.

   Mensagem( "Verificando se está em uso" )
   SELECT jppedi
   LOCATE FOR jppedi->pdTransa == jptransa->trTransa .AND. GrafProc()
   IF ! Eof()
      MsgExclamation( "INVÁLIDO! Transação em uso no pedido " + jppedi->pdPedido )
      lExclui := .F.
   ELSE
      SELECT jpestoq
      LOCATE FOR jpestoq->esTransa == jptransa->trTransa .AND. GrafProc()
      IF ! Eof()
         MsgExclamation( "INVÁLIDO! Transação em uso no estoque " + jpestoq->esNumLan )
         lExclui := .F.
      ELSE
         SELECT jpnota
         LOCATE FOR jpnota->nfTransa == jptransa->trTransa .AND. GrafProc()
         IF ! Eof()
            MsgExclamation( "INVÁLIDO! Transação em uso na NF lançto " + jpnota->nfNumLan )
            lExclui := .F.
         ELSE
            SELECT jpimpos
            LOCATE FOR jpimpos->imTransa == jptransa->trTransa .AND. GrafProc()
            IF ! Eof()
               MsgExclamation( "INVÁLIDO! Transação em uso na regra " + jpimpos->imNumLan )
               lExclui := .F.
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   SELECT jptransa
   IF lExclui
      ::Super:Delete()
   ENDIF

   RETURN NIL

METHOD Valida( cTransacao, lMostra ) CLASS JPTRANSAClass

   hb_Default( @lMostra, .T. )
   FillZeros( @cTransacao )
   IF lMostra
      @ Row(), 32 SAY EmptyValue( jptransa->trDescri )
   ENDIF
   IF ! Encontra( cTransacao, "jptransa", "numlan" )
      MsgStop( "Transação não cadastrada!" )
      RETURN .F.
   ENDIF
   IF lMostra
      @ Row(), 32 SAY jptransa->trDescri
   ENDIF

   RETURN .T.

METHOD Intervalo( nLini, nColi, nOpc, mpdTransa ) CLASS JPTRANSAClass

   LOCAL acTxtOpc := { "Todas", "Específica" }
   LOCAL GetList := {}

   WOpen( nLini, nColi, nLini + 3, nColi + 40, "Transação" )
   DO WHILE .T.
      FazAchoice( nLini + 1, nColi + 1, nLini + 2, nColi + 39, acTxtOpc, @nOpc )
      IF LastKey() != K_ESC .AND. nOpc == 2
         WOpen( nLini + 3, nColi, nLini + 6, nColi + 40, "Transação" )
         @ nLini + 5, nColi + 2 GET mpdTransa PICTURE "@K 999999" VALID JPTRANSAClass():Valida( @mpdTransa, .F. )
         Mensagem( "Digite a Transação, F9 Pesquisa, ESC Sai" )
         READ
         WClose()
         IF LastKey() == K_ESC
            LOOP
         ENDIF
      ENDIF
      EXIT
   ENDDO
   WClose()

   RETURN nOpc
