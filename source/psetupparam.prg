/*
PSETUPPARAM - CONFIGURACAO GERAL
1999.12.20 - José Quintas

*  HP Paisagem     Chr(27)+"&l1O"
*  HP Vertical     Chr(27)+"&01O"
*/

#include "inkey.ch"

PROCEDURE pSetupParamAll

   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi" )
      RETURN
   ENDIF

   pSetupParam( "GERAL" )
   CLOSE DATABASES

   RETURN

PROCEDURE pSetupParamRound

   LOCAL GetList := {}, mCriterio

   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi" )
      RETURN
   ENDIF
   SELECT jptabel
   mCriterio := Trim( LeCnf( "PRECO ARREDONDA" ) )
   IF Empty( mCriterio )
      mCriterio := "6"
   ENDIF
   @ 3, 3 SAY "Critérios disponíveis para arredondamento"
   @ 4, 3 SAY "0 - Sem arrredondar, o que for possível na tabela"
   @ 5, 3 SAY "1 - Valor com centavos, cortando excedente (1.999999=1.99)"
   @ 6, 3 SAY "2 - Valor com centavos, arredondando a partir de 0.005"
   @ 7, 3 SAY "3 - Valor com centavos, arredondando tudo (1.01001=1.02)"
   @ 8, 3 SAY "4 - Valor SEM centavos, cortando centavos (1.99=1.00)"
   @ 9, 3 SAY "5 - Valor SEM centavos, arredondando a partir de 0.50"
   @ 10,3 SAY "6 - Valor SEM centavos, arredondando tudo (1.01=2.00)"
   @ 12, 3 SAY "Critério:" GET mCriterio PICTURE "9" VALID mCriterio $ "123456"
   Mensagem("Digite critério de arredondamento, ESC sai")
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. ! mCriterio $ "123456"
      CLOSE DATABASES
      RETURN
   ENDIF
   IF ! MsgYesNo( "Confirma critério?" )
      RETURN
   ENDIF
   GravaCnf( "PRECO ARREDONDA", Str( mCriterio, 1 ) )
   CLOSE DATABASES

   RETURN

FUNCTION LeCnfRel( mDefault )

   LOCAL mCont, mTemp
   MEMVAR m_Prog

   mDefault := {}
   mTemp := Trim( LeCnf( m_Prog ) ) + ",,,,,,,,,,"
   FOR mCont = 1 TO 20
      AAdd( mDefault, Val( Substr( mTemp, 1, At( ",", mTemp ) - 1 ) ) )
      IF mDefault[ mCont ] == 0
         mDefault[ mCont ] := 1000 // Assim pega default
      ENDIF
      mTemp := Substr( mTemp, At( ",", mTemp ) + 1 )
   NEXT
   *if mSequencia != NIL
   *   mDefault := mDefault[ mSequencia ]
   *   mDefault := iif( mDefault > mMaximo .OR. mDefault < 1, 1, mDefault )
   *ENDIF

   RETURN mDefault

FUNCTION GravaCnfRel( mDefault )

   LOCAL mCont
   LOCAL mTemp := ""
   MEMVAR m_Prog

   FOR mCont = 1 TO Len( mDefault )
      mTemp += AllTrim( Str( mDefault[ mCont ] ) ) + ","
   NEXT
   GravaCnf( m_Prog, mTemp )

   RETURN NIL

FUNCTION DelCnf( mParametro, lMysql )

   LOCAL mSelect, cnMySql := ADOClass():new( AppcnMySqlLocal() )

   hb_Default( @lMySql, .F. )

   IF lMySql .AND. AppcnMySqlLocal() != NIL
      cnMySql:cSql := "DELETE FORM JPCONFI WHERE CNF_NOME=" + StringSql( mParametro )
      cnMySql:ExecuteCmd()
      RETURN NIL
   ENDIF

   mSelect := Select()
   IF Select( "jpconfi" ) == 0
      SELECT 0
      USE jpconfi
   ENDIF
   SELECT ( Select( "jpconfi" ) )
   GOTO TOP
   DO WHILE ! Eof()
      IF AllTrim( jpconfi->Cnf_Nome ) == mParametro
         RecDelete()
      ENDIF
      SKIP
   ENDDO
   SELECT ( mSelect )

   RETURN NIL

FUNCTION LeCnf( cParametro, cDefault, lMySql )

   LOCAL nSelect, nSelectJPCONFI, cValue, cnMySql := ADOClass():New( AppcnMySqlLocal() )

   hb_Default( @lMySql, .F. )

   IF lMySql
      cnMySql:cSql := "SELECT COUNT(*) AS QTD FROM JPCONFI WHERE CNF_NOME=" + StringSql( cParametro )
      IF cnMySql:ReturnValueAndClose( "QTD" ) == 0
         cValue := ""
      ELSE
         cnMySql:cSql := "SELECT CNF_PARAM FROM JPCONFI WHERE CNF_NOME=" + StringSql( cParametro )
         cValue := cnMySql:ReturnValueAndClose( "CNF_PARAM" )
      ENDIF
      IF Empty( cValue ) .AND. cDefault != NIL
         cValue := cDefault
      ENDIF
   ELSE
      nSelect        := Select()
      nSelectJPCONFI := ( Select( "jpconfi" ) )
      SELECT ( nSelectJPCONFI )
      IF nSelectJPCONFI == 0
         AbreArquivos( "jpconfi" )
      ENDIF
      SEEK cParametro
      cValue := Trim( jpconfi->Cnf_Param )
      IF Empty( cValue ) .AND. cDefault != NIL
         cValue := cDefault
      ENDIF
      IF nSelectJPCONFI == 0
         USE
      ENDIF
      SELECT ( nSelect )
   ENDIF

   RETURN cValue

FUNCTION ChecaCnf( cParametro, cDefault, lMySql )

   LOCAL mSelecta := Select()
   LOCAL mSelect  := Select( "jpconfi" )
   LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() )

   hb_Default( lMySql, .F. )

   IF lMySql
      cnMySql:cSql := "SELECT COUNT(*) AS QTD FROM JPCONFI WHERE CNF_NOME=" + StringSql( cParametro )
      IF cnMySql:ReturnValueAndClose( "QTD" ) == 0
         GravaCnf( cParametro, cDefault, .T. )
         RETURN NIL
      ENDIF
   ENDIF

   SELECT ( mSelect )
   IF mSelect == 0
      AbreArquivos( "jpconfi" )
   ENDIF
   SEEK cParametro
   IF Eof()
      RecAppend()
      REPLACE ;
         jpconfi->cnf_nome  WITH cParametro, ;
         jpconfi->cnf_param WITH cDefault
      RecUnlock()
   ENDIF
   IF mSelect == 0
      USE
   ENDIF
   SELECT ( mSelecta )

   RETURN NIL

FUNCTION GravaCnf( cParametro, cConteudo, lMySql )

   LOCAL nSelect, nSelectAnt := Select(), cnMySql := ADOClass():New( AppcnMySqlLocal() )

   hb_Default( @lMySql, .F. )

   IF lMySql
      cnMySql:cSql := "SELECT COUNT(*) AS QTD FROM JPCONFI WHERE CNF_NOME=" + StringSql( cParametro )
      IF cnMySql:ReturnValueAndClose( "QTD" ) == 0
         cnMySql:cSql := "INSERT INTO JPCONFI ( CNF_NOME.CNF_INFINC ) VALUES ( " + StringSql( cParametro ) + ", " + StringSql( LogInfo() ) + " )"
         cnMySql:ExecuteCmd()
      ENDIF
      cnMySql:cSql := "UPDATE JPCONFI SET CNF_PARAM=" + StringSql( cConteudo ) + " WHERE CNF_NOME=" + StringSql( cParametro )
      cnMySql:ExecuteCmd()
      RETURN NIL
   ENDIF
   nSelect := ( Select( "jpconfi" ) )
   SELECT ( nSelect )
   IF nSelect == 0
      AbreArquivos( "jpconfi" )
   ENDIF
   SEEK cParametro
   IF Eof()
      RecAppend()
      REPLACE jpconfi->cnf_Nome WITH  cParametro
   ENDIF
   RecLock()
   REPLACE jpconfi->cnf_param WITH cConteudo
   RecUnlock()
   SELECT ( nSelectAnt )

   RETURN .T.

PROCEDURE pSetupParam( cTipoConfiguracao )

   LOCAL cCnpjErrado, cCnpjRepetido, cEndEntrega, cEndCobranca, cConsultaMySql, cConsultaSefaz
   LOCAL cEstoCfop, cEstoContabil, cEstoCCusto
   LOCAL cPedidoVendedor, cObsCliente, cFiscContabil, cFiscCCusto, cAbaixoCusto
   LOCAL GetList := {}

   cCnpjErrado     := iif( LeCnf( "CNPJ/CPF CLI ERRADO" )     == "SIM", "SIM", "NAO" )
   cCnpjRepetido   := iif( LeCnf( "CNPJ/CPF CLI REPETIDO" )   == "SIM", "SIM", "NAO" )
   cEndEntrega     := iif( LeCnf( "CLI C/END.ENTREGA" )       == "SIM", "SIM", "NAO" )
   cEndCobranca    := iif( LeCnf( "CLI C/END.COBRANCA" )      == "SIM", "SIM", "NAO" )
   cConsultaMySql  := iif( LeCnf( "CLI CONSULTA MYSQL" )      == "SIM", "SIM", "NAO" )
   cConsultaSefaz  := iif( LeCnf( "CLI CONSULTA SEFAZ" )      == "SIM", "SIM", "NAO" )
   cEstoCfOp       := iif( LeCnf( "ESTOQUE CFOP" )            == "SIM", "SIM", "NAO" )
   cEstoContabil   := iif( LeCnf( "ESTOQUE CONTABIL" )        == "SIM", "SIM", "NAO" )
   cEstoCCusto     := iif( LeCnf( "ESTOQUE CCUSTO" )          == "SIM", "SIM", "NAO" )
   cPedidoVendedor := iif( LeCnf( "PEDIDO VENDEDOR=CLIENTE" ) == "SIM", "SIM", "NAO" )
   cObsCliente     := iif( LeCnf( "NOTA OBS POR CLIENTE" )    == "SIM", "SIM", "NAO" )
   cFiscContabil   := iif( LeCnf( "LFISCAL C/ CONTABIL" )     == "SIM", "SIM", "NAO" )
   cFiscCCusto     := iif( LeCnf( "LFISCAL C/ C.CUSTO" )      == "SIM", "SIM", "NAO" )
   cAbaixoCusto    := iif( LeCnf( "BLOQUEIA ABAIXO CUSTO" )   == "SIM", "SIM", "NAO" )

   hb_Default( @cTipoConfiguracao, "GERAL" )

   wSave()
   Cls()

   @ 2, 0 SAY ""

   IF cTipoConfiguracao == "CLIENTE" .OR. cTipoConfiguracao == "GERAL"
      @ Row() + 1, 5 SAY "Aceita CNPJ errado........:" GET cCnpjErrado     PICTURE "@!A" VALID cCnpjErrado $ "SIM~NAO"
      @ Row() + 1, 5 SAY "Aceita CCNPJ repetido.....:" GET cCnpjRepetido   PICTURE "@!A" VALID cCnpjErrado $ "SIM~NAO"
      @ Row() + 1, 5 SAY "Cliente c/ End. Entrega...:" GET cEndEntrega     PICTURE "@!A" VALID cCnpjErrado $ "SIM~NAO"
      @ Row() + 1, 5 SAY "Cliente c/ End. Cobrança..:" GET cEndCobranca    PICTURE "@!A" VALID cCnpjErrado $ "SIM~NAO"
      @ Row() + 1, 5 SAY "Consulta Cliente no MySQL.:" GET cConsultaMySql  PICTURE "@!A" VALID cCnpjErrado $ "SIM~NAO"
      @ Row() + 1, 5 SAY "Consulta Cliente Sefaz....:" GET cConsultaSefaz  PICTURE "@!A" VALID cCnpjErrado $ "SIM~NAO"
   ENDIF

   IF cTipoConfiguracao == "ESTOQUE" .OR. cTipoConfiguracao == "GERAL"
      @ Row() + 1, 5 SAY "Estoque c/ CFOP...........:" GET cEstoCfop       PICTURE "@!A" VALID cCnpjErrado $ "SIM~NAO"
      @ Row() + 1, 5 SAY "Estoque c/ contabilidade..:" GET cEstoContabil   PICTURE "@!A" VALID cCnpjErrado $ "SIM~NAO"
      @ Row() + 1, 5 SAY "Estoque c/ CCusto.........:" GET cEstoCCusto     PICTURE "@!A" VALID cCnpjErrado $ "SIM~NAO"
   ENDIF

   IF cTipoConfiguracao == "PEDIDO" .OR. cTipoConfiguracao == "GERAL"
      @ Row() + 1, 5 SAY "No Pedido Vendedor=CadCli.:" GET cPedidoVendedor PICTURE "@!A" VALID cCnpjErrado $ "SIM~NAO"
      @ Row() + 1, 5 SAY "Bloqueia abaixo do custo..:" GET cAbaixoCusto    PICTURE "@!A" VALID cCnpjErrado $ "SIM~NAO"
   ENDIF
   IF cTipoConfiguracao == "GERAL"
      @ Row() + 1, 5 SAY "Nota Obs. por Cliente.....:" GET cObsCliente     PICTURE "@!A" VALID cCnpjErrado $ "SIM~NAO"
      @ Row() + 1, 5 SAY "LFiscal c/ Contabil.......:" GET cFiscContabil   PICTURE "@!A" VALID cCnpjErrado $ "SIM~NAO"
      @ Row() + 1, 5 SAY "LFiscal c/ CCusto.........:" GET cFiscCCusto     PICTURE "@!A" VALID cCnpjErrado $ "SIM~NAO"
   ENDIF
   IF Len( GetList ) == 0
      CLEAR GETS
      wRestore()
      RETURN
   ENDIF
   Mensagem( "Preencha com SIM ou NAO, ESC abandona" )
   READ
   IF LastKey() == K_ESC
      wRestore()
      RETURN
   ENDIF

   IF cTipoConfiguracao == "CLIENTE" .OR. cTipoConfiguracao == "GERAL"
      GravaCnf( "CNPJ/CPF CLI ERRADO", cCnpjErrado )
      GravaCnf( "CNPJ/CPF CLI REPETIDO", cCnpjRepetido )
      GravaCnf( "CLI C/END.ENTREGA", cEndEntrega )
      GravaCnf( "CLI C/END.COBRANCA", cEndCobranca )
      GravaCnf( "CLI CONSULTA MYSQL", cConsultaMySql )
      GravaCnf( "CLI CONSULTA SEFAZ", cConsultaSefaz )
   ENDIF
   IF cTipoConfiguracao == "ESTOQUE" .OR. cTipoConfiguracao == "GERAL"
      GravaCnf( "ESTOQUE CFOP", cEstoCfop )
      GravaCnf( "ESTOQUE CONTABIL", cEstoContabil )
      GravaCnf( "ESTOQUE CCUSTO", cEstoCCusto )
   ENDIF
   IF cTipoConfiguracao == "PEDIDO" .OR. cTipoConfiguracao == "GERAL"
      GravaCnf( "PEDIDO VENDEDOR=CLIENTE", cPedidoVendedor )
      GravaCnf( "BLOQUEIA ABAIXO CUSTO", cAbaixoCusto )
   ENDIF
   IF cTipoConfiguracao == "GERAL"
      GravaCnf( "NOTA OBS POR CLIENTE", cObsCliente )
      GravaCnf( "LFISCAL C/ CONTABIL", cFiscContabil )
      GravaCnf( "LFISCAL C/ C.CUSTO", cFiscCCusto )
   ENDIF
   wRestore()

   RETURN
