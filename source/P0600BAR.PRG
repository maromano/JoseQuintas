/*
P0600BAR - CODIGO DE BARRAS EM COMPRAS/VENDAS
2007.04.29 - José Quintas

...
2016.09.02.0915 - Somente MySQL
*/

#include "inkey.ch"

PROCEDURE P0600Barras

   IF AppcnMySqlLocal() == NIL
      RETURN
   ENDIF
   IF jppedi->pdStatus $ "C"
      MsgStop( "Pedido cancelado!" )
      RETURN
   ENDIF
   Cls()
   Encontra( jppedi->pdTransa, "jptransa", "numlan" )
   IF "VENDA" $ jptransa->trReacao .AND. ! "DEVVEN" $ jptransa->trReacao
      P0600BarrasVendas()
   ELSEIF "COMPRA" $ jptransa->trReacao .AND. ! "DEVCOM" $ jptransa->trReacao
      P0600BarrasCompras()
   ELSE
      P0600BarrasOutros()
   ENDIF

   RETURN

STATIC FUNCTION P0600BarrasVendas()

   LOCAL GetList := {}, mbrCodBar, mbrCodBar2, mDatNota, mDigitaGarantia, mQtdMes, oElement
   LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() )
   MEMVAR m_Prog, mListaProd
   PRIVATE m_Prog := "P0600BAR", mListaProd

   mbrCodBar  := Space(22)
   mbrCodBar2 := Space(22)
   mDatNota   := Date()

   DO WHILE .T.
      @  6, 0 SAY "Registrando VENDAS/GARANTIA"
      @  7, 0 SAY "Pedido..............: " + jppedi->pdPedido
      @  8, 0 SAY "Cliente/Fornecedor..: " + jppedi->pdCliFor
      Encontra( jppedi->pdCliFor, "jpcadas", "numlan" )
      @ Row(), 32 SAY jpcadas->cdNome
      @  9, 0 SAY "Data de Referência..:" GET mDatNota
      READ
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      mListaProd := {}
      SELECT jpitped
      SEEK jppedi->pdPedido
      DO WHILE jpitped->ipPedido == jppedi->pdPedido .AND. ! Eof()
         Encontra(jpitped->ipItem,"jpitem","item")
         SELECT jpitped
         AAdd( mListaProd,{ jpitped->ipItem, jpitem->ieDescri, jpitped->ipQtde, 0 } )
         SKIP
      ENDDO
      WITH OBJECT cnMySql
         :cSql := "SELECT BRITEM FROM JPBARRA WHERE BRPEDVEN=" + StringSql( jppedi->pdPedido )
         :Execute()
         DO WHILE ! :Eof()
            P0600BarrasVendasBaixaDigitacao( cnMySql:StringSql( "BRITEM" ) )
            :MoveNext()
         ENDDO
         :CloseRecordset()
      END WITH
      mDigitaGarantia := MsgYesNo( "Digitação manual de garantia?" )
      DO WHILE .T.
         Scroll( 13, 0, MaxRow() - 3, MaxCol(), 0 )
         FOR EACH oElement IN mListaProd
            @ 12 + oElement:__EnumIndex, 0    SAY ""
            @ Row(), 0         SAY oElement[ 1 ]
            @ Row(), Col() + 2 SAY Pad( oElement[ 2 ], 30 )
            @ Row(), Col() + 2 SAY Str( oElement[ 3 ], 6 )
            @ Row(), Col() + 2 SAY Str( oElement[ 4 ], 6 )
         NEXT
         mbrCodBar  := Space(22)
         mbrCodBar2 := Space(22)
         @ 10, 0 SAY "Cód.Barras Próprio..:" GET mbrCodBar PICTURE "@K 9999999999"
         @ 11, 0 SAY "Cód.Barras Forneced.:" GET mbrCodBar2
         Mensagem( "Utilize o leitor, ESC Sai" )
         READ
         IF LastKey() == K_ESC
            EXIT
         ENDIF
         WITH OBJECT cnMySql
            :cSql := "SELECT * FROM JPBARRA WHERE BRCODBAR=" + StringSql( StrZero( Val( mbrCodBar ), 10 ) )
            :Execute()
            IF :Rs:Eof()
               MsgWarning( "Código de barras Próprio não cadastrado" )
               :CloseRecordset()
               LOOP
            ENDIF
            IF Empty( :StringSql( "BRPEDCOM" ) )
               IF ! MsgYesNo( "Pedido de compra não registrado! Continua?" )
                  :CloseRecordset()
                  LOOP
               ENDIF
            ENDIF
            IF ! Empty( :StringSql( "BRPEDVEN" ) )
               IF ! MsgYesNo( "Código de barras já atribuído ao pedido " + cnMySql:StringSql( "BRPEDVEN" ) )
                  :CloseRecordset()
                  LOOP
               ENDIF
            ENDIF
            IF ! Encontra( jppedi->pdPedido + :StringSql( "BRITEM", 6 ), "jpitped", "pedido" )
               Encontra( cnMySql:StringSql( "BRITEM", 6 ), "jpitem", "item" )
               :CloseRecordset()
               MsgStop( "Não tem " + Trim( Substr( jpitem->ieDescri, 1, 50 ) ) + " no pedido!" )
               LOOP
            ENDIF
            IF ! P0600BarrasVendasBaixaDigitacao( :StringSql( "BRITEM", 6 ) )
               MsgWarning( "Quantidade excedida!" )
               :CloseRecordset()
               LOOP
            ENDIF
            Encontra( :StringSql( "BRITEM", 6 ), "jpitem", "item" )
            mQtdMes := jpitped->ipGarantia
            @ 12, 0 SAY "Dias de Garantia....:" GET mQtdMes PICTURE "999" WHEN mDigitaGarantia VALID mQtdMes >= 0
            Mensagem( "Digite meses para garantia, ESC não registra" )
            READ
            IF LastKey() != K_ESC
               IF mQtdMes > jpitem->ieGarVen
                  IF ! MsgYesNo( "A garantia máxima é " + Ltrim( Str( jpitem->ieGarVen ) ) + hb_eol() + ;
                        "Foi digitado " + Ltrim( Str( mQtdMes ) ) + hb_eol() + " Confirma essa garantia extendida?" )
                     :CloseRecordset()
                     LOOP
                  ENDIF
               ENDIF
               :QueryCreate()
               :QueryAdd( "BRPEDVEN", jppedi->pdPedido )
               :QueryAdd( "BRCODBAR2", mbrCodBar2 )
               :QueryAdd( "BRGARVEN", mDatNota + mQtdMes )
               :QueryAdd( "BRINFVEN", LogInfo() )
               :QueryExecuteUpdate( "JPBARRA", "BRNUMLAN=" + cnMySql:StringSql( "BRNUMLAN" ) )
               Encontra( jppedi->pdTransa, "jptransa", "numlan" )
               GravaOcorrencia( "JPBARRA", cnMySql:StringSql( "BRNUMLAN" ), Trim( jptransa->trDescri ) + " Pedido " + jppedi->pdPedido + ", " + jpcadas->cdNome )
               GravaOcorrencia( "JPPEDI", jppedi->pdPedido, "REGISTRADO COD BARRAS " + Trim( mbrCodBar ) + ", " + Trim( mbrCodBar2 ) )
            ENDIF
            :CloseRecordset()
         END WITH
      ENDDO
   ENDDO

   RETURN NIL

STATIC FUNCTION P0600BarrasVendasBaixaDigitacao( mProduto )

   LOCAL nCont, mOk

   MEMVAR mListaProd

   FOR nCont = 1 TO Len( mListaProd )
      IF mListaProd[ nCont, 1 ] == mProduto
         EXIT
      ENDIF
   NEXT
   IF nCont > Len( mListaProd )
      AAdd( mListaProd, { "******", "*INVALIDO*", 0, 0 } )
   ENDIF
   mOk := ( mListaProd[ nCont, 4 ] < mListaProd[ nCont, 3 ] )
   IF mOk
      mListaProd[ nCont, 4 ] += 1
   ENDIF

   RETURN mOk

STATIC FUNCTION P0600BarrasOutros()

   LOCAL GetList := {}, mbrCodBar, mbrCodBar2
   LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() )

   mbrCodBar := Space(22)
   mbrCodBar2:= Space(22)

   @  7, 0 SAY "Registrando OCORRENCIA"
   @  8, 0 SAY "Pedido .............: " + jppedi->pdPedido
   @  Row(), Col() + 2 SAY jppedi->pdDatEmi
   @  9, 0 SAY "Cliente/Fornecedor..: " + jppedi->pdCliFor
   Encontra( jppedi->pdCliFor, "jpcadas", "numlan" )
   @ Row(), 32 SAY jpcadas->cdNome
   DO WHILE .T.
      mbrCodBar  := Space(22)
      mbrCodBar2 := Space(22)
      @ 10, 0 SAY "Cód.Barras Próprio..:" GET mbrCodBar PICTURE "@K 9999999999"
      @ 11, 0 SAY "Cód.Barras Forneced.:" GET mbrCodBar2
      Mensagem( "Utilize o leitor, ESC Sai" )
      READ
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      WITH OBJECT cnMySql
         :cSql := "SELECT * FROM JPBARRA WHERE BRCODBAR=" + StringSql( StrZero( Val( mbrCodBar ), 10 ) )
         :Execute()
         IF :Eof()
            MsgStop( "Código de barras Próprio não cadastrado" )
            :CloseRecordset()
            LOOP
         ENDIF
         IF Empty( :StringSql( "BRPEDCOM" ) )
            IF ! MsgYesNo( "Pedido de compra não registrado! Continua?" )
               :CloseRecordset()
               LOOP
            ENDIF
         ENDIF
         IF ! Encontra( jppedi->pdPedido + :StringSql( "BRITEM", 6 ), "jpitped", "pedido" )
            Encontra( :StringSql( "BRITEM", 6 ), "jpitem", "item" )
            MsgWarning( "Não tem " + Trim( Substr( jpitem->ieDescri, 1, 50 ) ) + " no pedido!" )
            :CloseRecordset()
            LOOP
         ENDIF
         Encontra( jppedi->pdTransa, "jptransa", "numlan" )
         GravaOcorrencia( "JPBARRA", :StringSql( "BRNUMLAN" ), Trim( jptransa->trDescri ) + " Pedido " + jppedi->pdPedido + ", " + jpcadas->cdNome )
         :CloseRecordset()
      END WITH
      GravaOcorrencia( "JPPEDI", jppedi->pdPedido, "REGISTRADO COD BARRAS " + Trim( mbrCodBar ) + ", " + Trim( mbrCodBar2 ) )
   ENDDO

   RETURN NIL

STATIC FUNCTION P0600BarrasCompras()

   LOCAL mbrGarCom, nCont, GetList := {}, mOpc, mItem, mbrCodBari, mbrCodBarf, mbrNumLan, mbrCodBar
   LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() )
   MEMVAR mListaProd
   PRIVATE mListaProd

   Scroll( 8, 0, MaxRow()-2, MaxCol(), 0 )

   mbrGarCom  := 0

   @ 7, 0 SAY "Registrando COMPRA/GARANTIA"
   @ 8, 0 SAY "Pedido de Compra....: " + jppedi->pdPedido
   mListaProd := {}
   SELECT jpitped
   SEEK jppedi->pdPedido
   DO WHILE jpitped->ipPedido == jppedi->pdPedido .AND. ! Eof()
      Encontra( jpitped->ipItem, "jpitem", "item" )
      SELECT jpitped
      AAdd( mListaProd, { jpitped->ipItem, jpitem->ieDescri, jpitped->ipQtde, 0 } )
      SKIP
   ENDDO
   WITH OBJECT cnMySql
      :cSql := "SELECT * FROM JPBARRA WHERE BRPEDCOM=" + StringSql( jppedi->pdPedido )
      :Execute()
      DO WHILE ! :Eof()
         P0600BarrasComprasBaixaDigitacao( :StringSql( "BRITEM" ) )
         :MoveNext()
      ENDDO
      :CloseRecordset()
   END WITH
   P0600BarrasComprasTelaDados()
   @  Row(), Col() + 2 SAY jppedi->pdDatEmi
   @  9, 0 SAY "Fornecedor..........: " + jppedi->pdCliFor
   Encontra( jppedi->pdCliFor, "jpcadas", "numlan" )
   @ Row(), 32 SAY jpcadas->cdNome
   DO WHILE .T.
      @ 10, 0 SAY "Produto.............:"
      FOR nCont = 1 TO Len( mListaProd )
         MousePrompt( 10, 22, mListaProd[ nCont, 1 ] + "-" + Pad( mListaProd[ nCont, 2 ], 25 ) + " Ped. " + Str( mListaProd[ nCont, 3 ], 6 ) + " Dig." + Str( mListaProd[ nCont, 4 ], 6 ) )
      NEXT
      Mensagem( "Selecione produto com setas e tecle ENTER, ESC sai" )
      mOpc := 1
      mOpc := MouseMenuTo( mOpc )
      IF mOpc < 1 .OR. LastKey() == K_ESC
         EXIT
      ENDIF
      P0600BarrasComprasTelaDados()
      mItem := mListaProd[ mOpc, 1 ]
      IF mListaProd[ mOpc, 4 ] >= mListaProd[ mOpc, 3 ]
         MsgWarning( "Todos os códigos de barra desse produto já foram informados!" )
         LOOP
      ENDIF
      Encontra( mItem, "jpitem", "item" )
      @ 10, 22
      @ 10, 22 SAY mItem
      @ 10, 32 SAY jpitem->ieDescri
      @ 11, 0 SAY "Data do Cadastro....: " + Dtoc( jppedi->pdDatEmi )
      mbrGarCom := jppedi->pdDatEmi + jpitem->ieGarCom
      @ 12, 0 SAY "Garantia de Compra..:" GET mbrGarCom
      Mensagem("Digite dados, ESC Sai")
      READ
      IF LastKey() == K_ESC
         LOOP
      ENDIF
      DO WHILE .T.
         mbrCodBari := Space(22)
         mbrCodBarf := Space(22)
         @ 16, 0 SAY "Cód.Barras Próprio desde:" GET mbrCodBari PICTURE "@K 9999999999"
         @ 17, 0 SAY "Cód.Barras Próprio Ate..:" GET mbrCodBarf PICTURE "@K!"
         Mensagem("Digite o código e/ou utilize o leitor, ESC Sai")
         READ
         IF LastKey() == K_ESC
            EXIT
         ENDIF
         IF Empty( mbrCodBari )
            MsgWarning( "Não pode digitar código em branco!" )
            LOOP
         ENDIF
         IF Val( mbrCodBari ) > Val( mbrCodBarf )
            MsgWarning( "Intervalo inválido. Tem que ser do menor para o maior!" )
            LOOP
         ENDIF
         mbrCodBarf := StrZero( Val( mbrCodBarf ), 10 )
         mbrCodBari := StrZero( Val( mbrCodBari ), 10 )

         IF ( Val( mbrCodBarf ) - Val( mbrCodBari ) + 1 + mListaProd[ mOpc, 4 ] ) > mListaProd[ mOpc, 3 ]
            MsgWarning( "Quantidade digitada excede quantidade do pedido" )
            LOOP
         ENDIF

         mbrCodBar := mbrCodBari
         cnMySql:cSql := "SELECT COUNT(*) AS QTD FROM JPBARRA WHERE BRCODBAR >= " + StringSql( mbrCodBari ) + " AND BRCODBAR <= " + StringSql( mbrCodBarf )
         IF cnMySql:ReturnValueAndClose( "QTD" ) > 0
            LOOP
         ENDIF
         DO WHILE mbrCodBar <= mbrCodBarf
            mbrNumLan := NovoCodigoMySql( "JPBARRA", "BRNUMLAN", 6 )
            WITH OBJECT cnMySql
               :QueryCreate()
               :QueryAdd( "BRNUMLAN", mbrNumLan )
               :QueryAdd( "BRCODBAR", mbrCodBar )
               :QueryAdd( "BRITEM",   mListaProd[ mOpc, 1 ] )
               :QueryAdd( "BRGARCOM", mbrGarCom )
               :QueryAdd( "BRPEDCOM", jppedi->pdPedido )
               :QueryAdd( "BRINFINC", LogInfo() )
               :QueryExecuteInsert( "JPBARRA" )
            END WITH
            P0600BarrasComprasBaixaDigitacao( mItem )
            Encontra( jppedi->pdTransa, "jptransa", "numlan" )
            GravaOcorrencia( "JPBARRA", mbrNumLan, Trim( jptransa->trDescri ) + " Pedido " + jppedi->pdPedido + ", " + jpcadas->cdNome )
            GravaOcorrencia( "JPPEDI", jppedi->pdPedido, "REGISTRADO COD BARRAS " + Trim( mbrCodBar ) )
            mbrCodBar := StrZero( Val( mbrCodBar ) + 1, 10 )
         ENDDO
         P0600BarrasComprasTelaDados()
      ENDDO
   ENDDO

   RETURN NIL

STATIC FUNCTION P0600BarrasComprasBaixaDigitacao( mProduto )

   LOCAL nCont, mOk
   MEMVAR mListaProd

   FOR nCont = 1 TO Len( mListaProd )
      IF mListaProd[ nCont, 1 ] == mProduto
         EXIT
      ENDIF
   NEXT
   IF nCont > Len( mListaProd )
      AAdd( mListaProd, { "******","*INVALIDO*", 0, 0 } )
   ENDIF
   mOk := ( mListaProd[ nCont, 4 ] < mListaProd[ nCont, 3 ] )
   IF mOk
      mListaProd[ nCont, 4 ] += 1
   ENDIF

   RETURN mOk

STATIC FUNCTION P0600BarrasComprasTelaDados()

   LOCAL oElement
   MEMVAR mListaProd

   Scroll( 18, 0, MaxRow() - 3, MaxCol(), 0 )
   FOR EACH oElement IN mListaProd
      @ 15 + oElement:__EnumIndex, 0 SAY ""
      @ Row(), 0         SAY oElement[ 1 ]
      @ Row(), Col() + 2 SAY Pad( oElement[ 2 ], 30 )
      @ Row(), Col() + 2 SAY Str( oElement[ 3 ], 6 )
      @ Row(), Col() + 2 SAY Str( oElement[ 4 ], 6 )
   NEXT

   RETURN NIL
