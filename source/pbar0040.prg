/*
PBAR0040 - CONSULTA A CODIGOS DE BARRA
2007.05 José Quintas
*/

#include "inkey.ch"

PROCEDURE PBAR0040

   LOCAL GetList := {}, mCodBar, cTexto
   LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() )

   IF .T.
      MsgExclamation( "Módulo necessita atualização para MySQL" )
      RETURN
   ENDIF

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso", "jpbarra", "jpdecret" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpcadas", "jpcidade", "jpclista", "jpcomiss", "jpconfi", "jpempre", ;
      "jpestoq", "jpfinan", "jpforpag", "jpimpos", "jpitem", "jpitped", "jplfisc", "jpnota", "jpnumero", "jppedi", ;
      "jppreco", "jpsenha", "jptabel", "jptransa", "jpuf", "jpveicul", "jpvended" )
      RETURN
   ENDIF
   SELECT jpbarra

   mCodBar := Space(22)

   DO WHILE .T.
      @ 2, 0 SAY "Código de Barras....:" GET mCodBar PICTURE "@K!"
      Mensagem("Digite Código de Barras, ESC Sai")
      READ
      Mensagem()
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      IF ! Encontra( StrZero( Val( mCodBar ), 10 ), "jpbarra", "codbar1" )
         IF ! Encontra( mCodBar, "jpbarra", "codbar2" )
            MsgWarning( "Código de Barras não Encontrado" )
            LOOP
         ENDIF
      ENDIF
      @  4, 0 SAY "Num. Lançto.........: " + jpbarra->brNumLan
      @  5, 0 SAY "Produto.............: " + jpbarra->brItem
      Encontra( jpbarra->brItem, "jpitem", "item" )
      @ Row(), 32 SAY jpitem->ieDescri
      @  6, 0 SAY "Pedido de Compra....: " + jpbarra->brPedCom
      Encontra( jpbarra->brPedCom, "jppedi", "pedido" )
      @  Row(), Col()+2 SAY jppedi->pdDatEmi
      @  7, 0 SAY "Num.Pedido/NF Fornec: " + jppedi->pdPedCli
      @  8, 0 SAY "Fornecedor..........: " + jppedi->pdCliFor
      Encontra(jppedi->pdCliFor,"jpcadas","numlan")
      @ Row(), 32 SAY jpcadas->cdNome
      @  9, 0 SAY "Data do Cadastro....: " // + Dtoc(jpbarra->brDatCad)
      @ 10, 0 SAY "Garantia de Compra..: " + Dtoc( jpbarra->brGarCom )
      @ 11, 0 SAY "Pedido de Venda.....: " + jpbarra->brPedVen
      Encontra( jpbarra->brPedVen,"jppedi", "pedido" )
      @ Row(), Col()+2 SAY jppedi->pdDatEmi
      Encontra( jppedi->pdPedido, "jpnota", "pedido" )
      @ 12, 0 SAY "Nota Fiscal de Venda: " + jpnota->nfNotFis
      Encontra( jppedi->pdPedido, "jpnota", "pedido" )
      @ Row(), Col()+2 SAY jpnota->nfDatEmi
      @ 13, 0 SAY "Cliente.............: " + jppedi->pdCliFor
      Encontra( jppedi->pdCliFor, "jpcadas", "numlan" )
      @ Row(), 32 SAY jpcadas->cdNome
      Encontra( jppedi->pdPedido, "jpnota", "pedido" )
      @ 15, 0 SAY "Garantia de Venda...: " + Dtoc( jpbarra->brGarVen )
      @ 16, 0 SAY "Cód.Barras Próprio..: " + jpbarra->brCodBar
      @ 17, 0 SAY "Cód.Barras Forneced.: " + jpbarra->brCodBar2
      @ 18, 0 SAY "Qtd.Ocorrências.....: " + lTrim( Str( QtdOcorrencias( "JPBARRA", jpbarra->brNumLan ) ) )
      Scroll( 19, 0, MaxRow() - 3, MaxCol(), 0 )
      IF AppcnMySqlLocal() == NIL
         SELECT jpreguso
         SEEK Pad( "JPBARRA", 9 ) + jpbarra->brNumLan
         DO WHILE jpreguso->ruArquivo == Pad( "JPBARRA", 9 ) .AND. jpreguso->ruCodigo == StrZero( Val( jpbarra->brNumLan ), 9 ) .AND. ! Eof()
            Scroll( 19, 5, MaxRow() - 3, MaxCol(), -1 )
            @ 19, 2 SAY Pad( jpreguso->ruInfInc, 30 ) + " " + jpreguso->ruTexto
            SKIP
         ENDDO
         SELECT jpbarra
      ELSE
         WITH OBJECT cnMySql
            :cSql := "SELECT * FROM JPREGUSO WHERE RUARQUIVO=" + StringSql( "JPBARRA" ) + ;
               " AND RUCODIGO=" + StringSql( StrZero( Val( jpbarra->brNumLan ), 9 ) ) + " ORDER BY RUID"
            :Execute( :cSql )
            DO WHILE ! :Eof()
               Scroll( 19, 5, MaxRow() - 3, MaxCol(), -1 )
               @ 19, 2 SAY :StringSql( "RUINFINC", 30 ) + " " + :StringSql( "RUTEXTO" )
               :MoveNext()
            ENDDO
            :CloseRecordset()
         END WITH
      ENDIF
      IF MsgYesNo( "Registra teste/outros" )
         wOpen( 10, 0, 14, MaxCol(), "Teste/Outros" )
         cTexto := Space(100)
         @ 12, 5 GET cTexto PICTURE "@!"
         READ
         wClose()
         IF LastKey() != K_ESC .AND. ! Empty( cTexto )
            IF AppcnMySqlLocal() == NIL
               SELECT jpreguso
               RecAppend()
               REPLACE ;
                  jpreguso->ruArquivo WITH "JPBARRA", ;
                  jpreguso->ruCodigo  WITH StrZero( Val( jpbarra->brNumLan ), 9 ), ;
                  jpreguso->ruTexto   WITH cTexto, ;
                  jpreguso->ruInfInc  WITH LogInfo()
               RecUnlock()
               SELECT jpbarra
            ELSE
               WITH OBJECT cnMySql
                  :QueryCreate()
                  :QueryAdd( "RUARQUIVO", "JPBARRA" )
                  :QueryAdd( "RUCODIGO",  StrZero( Val( jpbarra->brNumLan ), 9 ) )
                  :QueryAdd( "RUTEXTO",   cTexto )
                  :QueryAdd( "RUINFINC",  LogInfo() )
                  :QueryExecuteInsert( "JPREGUSO" )
               END WITH
            ENDIF
         ENDIF
      ENDIF
   ENDDO

   RETURN
