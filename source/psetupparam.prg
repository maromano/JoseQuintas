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
      use jpconfi
   ENDIF
   SELECT ( Select( "jpconfi" ) )
   Locate For Trim( jpconfi->Cnf_Nome ) == mParametro
   IF ! Eof()
      RecDelete()
   ENDIF
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

   LOCAL nOpc, cParametro, cConteudo, oElement, aConfigList := {}

   hb_Default( @cTipoConfiguracao, "GERAL" )

   IF cTipoConfiguracao == "CLIENTE" .OR. cTipoConfiguracao == "GERAL"
      AAdd( aConfigList, { "CNPJ/CPF CLI ERRADO",   "Clientes CNPJ/CPF Correto" } )
      AAdd( aConfigList, { "CNPJ/CPF CLI REPETIDO", "Clientes CNPJ/CPF Repetido" } )
      AAdd( aConfigList, { "CLI C/END.ENTREGA",     "Clientes c/End.Entrega" } )
      AAdd( aConfigList, { "CLI C/END.COBRANCA",    "Clientes c/End.Cobranca" } )
      AAdd( aConfigList, { "CLI CONSULTA MYSQL",    "Situacao MySql" } )
      AAdd( aConfigList, { "CLI CONSULTA SEFAZ",    "Situacao Sefaz (SEFAZ)" } )
   ENDIF

   IF cTipoConfiguracao == "ESTOQUE" .OR. cTipoConfiguracao == "GERAL"
      AAdd( aConfigList, { "ESTOQUE CFOP",        "Estoque com CFOP"} )
      AAdd( aConfigList, { "ESTOQUE CONTABIL",    "Estoque com Contabilidade"} )
      AAdd( aConfigList, { "ESTOQUE CCUSTO",      "Estoque Digita C.Custo"} )
   ENDIF

   IF cTipoConfiguracao == "GERAL"
      AAdd( aConfigList, { "PEDIDO VENDEDOR=CLIENTE", "Vendedor do Pedido=Cad.Cliente" } )
      AAdd( aConfigList, { "NOTA OBS POR CLIENTE",    "Repete Observacao de Cliente nas Notas" } )
      AAdd( aConfigList, { "LFISCAL C/ CONTABIL",     "Livro Fiscal com Contabil" } )
      AAdd( aConfigList, { "LFISCAL C/ C.CUSTO",      "Livro Fiscal com C.Custo" } )
      AAdd( aConfigList, { "BLOQUEIA ABAIXO CUSTO",   "Bloqueia Venda abaixo do Custo" } )
   ENDIF

   WOpen( 2, 5, MaxRow() - 3, MaxCol() - 10, "Configuracao " + cTipoConfiguracao )
   nOpc := 1
   DO WHILE .T.
      FOR EACH oElement IN aConfigList
         MousePrompt( 4 + oElement:__EnumIndex, 10, iif( LeCnf( oElement[ 1 ] ) == "SIM", "SIM", "NAO" ) + " " + oElement[ 2 ] )
      NEXT
      nOpc := MouseMenuTo( nOpc )
      IF nOpc == 0 .OR. LastKey() == K_ESC
         EXIT
      ENDIF
      cParametro := aConfigList[ nOpc, 1 ]
      cConteudo  := LeCnf( cParametro )
      cConteudo  := iif( cConteudo == "SIM", "SIM", "NAO" ) // Default
      cConteudo  := iif( cConteudo == "SIM", "NAO", "SIM" ) // Inverte
      GravaCnf( cParametro, cConteudo )
   ENDDO
   WClose()

   RETURN
