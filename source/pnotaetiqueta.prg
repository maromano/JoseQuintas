/*
PNOTAETIQUETA - ETIQUETAS PARA EMBALAGENS
2001.01.08 José Quintas
*/

#include "inkey.ch"

PROCEDURE pNotaEtiqueta

   LOCAL mTmpFile, mNome, mEndereco, mBairro, mCidade, mUf, mCep, mNf, mPeso, mAvanco, mPedido, mCliente, mQtde, GetList := {}, mQtdOk
   MEMVAR m_Prog

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso", "jpdecret" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpcadas", "jpcidade", "jpclista", "jpcomiss", "jpconfi", "jpempre", ;
      "jpestoq", "jpfinan", "jpforpag", "jpimpos", "jpitem", "jpitped", "jplfisc", "jpnota", "jpnumero", "jppedi", ;
      "jppreco", "jpsenha", "jptabel", "jptransa", "jpuf", "jpveicul", "jpvended" )
      RETURN
   ENDIF
   SELECT jppedi

   mNome    := Space(50)
   mEndereco:= Space(50)
   mBairro  := Space(20)
   mCidade  := Space(20)
   mUf      := Space(2)
   mCep     := Space(9)
   mNf      := Space(6)
   mPeso    := 0
   mAvanco  := Val( LeCnf( "PNOTAETIQUETA-AVANCO", "8" ) )
   DO WHILE .T.
      mPedido  := Space(6)
      mCliente := Space(6)
      mQtde    := 1
      @  2, 3 SAY "Pedido/Orçam..:" GET mPedido   PICTURE "@K 999999" VALID ChecaPedi( @mPedido, @mCliente, @mNf )
      @  3, 3 SAY "Cliente.......:" GET mCliente  PICTURE "@K 999999" VALID ChecaCli( @mCliente, @mNome, @mEndereco, @mBairro, @mCep, @mCidade, @mUf )
      @  4, 3 SAY "Nome..........:" GET mNome     PICTURE "@K!"
      @  5, 3 SAY "Endereço......:" GET mEndereco PICTURE "@K!"
      @  6, 3 SAY "Bairro........:" GET mBairro   PICTURE "@K!"
      @  7, 3 SAY "Cep...........:" GET mCep      PICTURE "@K 99999-999"
      @  8, 3 SAY "Cidade........:" GET mCidade   PICTURE "@K!"
      @  9, 3 SAY "Uf............:" GET mUf       PICTURE "@K!A"
      @ 10, 3 SAY "Nf............:" GET mNf       PICTURE "@K 999999"
      @ 11, 3 SAY "Peso..........:" GET mPeso     PICTURE "@E 999999.9"
      @ 13, 3 SAY "Avanço P/ Etiq:" GET mAvanco   PICTURE "999"
      @ 14, 3 SAY "Qtde.Cópias...:" GET mQtde     PICTURE "999" VALID mQtde > 0
      Mensagem( "Digite dados, F9 pesquisa, ESC sai" )
      READ
      Mensagem()
      IF lastkey() == K_ESC
         EXIT
      ENDIF
      IF ! ConfirmaImpressao()
         LOOP
      ENDIF
      GravaCnf( "PNOTAETIQUETA-AVANCO", NumberSql( mAvanco ) )
      SELECT jppedi
      SEEK mPedido
      Encontra( jppedi->pdCliFor, "jpcadas", "numlan" )
      mQtdOk := 0
      mTmpFile := MyTempFile( "TXT" )
      SET PRINTER TO ( mTmpFile )
      SET DEVICE TO PRINT
      DO WHILE mQtdOk < mQtde
         @ pRow() + 13, 0 SAY ""
         @ pRow() + 0, 32 SAY mNome
         @ pRow() + 2, 32 SAY mEndereco
         @ pRow() + 2, 32 SAY mBairro
         @ pRow() + 0, 55 SAY mCep
         @ pRow() + 2, 32 SAY mCidade
         @ pRow() + 0, 65 SAY mUf
         @ pRow() + 2, 32 SAY mPeso PICTURE "@E 999,999.9"
         @ pRow() + 0, 55 SAY mNf
         @ pRow() + mAvanco, 0  SAY ""
         SetPrc(0,0)
         mQtdOk += 1
      ENDDO
      SET DEVICE TO SCREEN
      SET PRINTER TO
      Win_PrintFileRaw( Win_PrinterGetDefault(), mTmpFile, "JPA Relatorio " + m_Prog )
      fErase( mTmpFile )
   ENDDO

   RETURN

STATIC FUNCTION ChecaPedi( mPedido, mCliente, mNf )

   FillZeros( @mPedido )
   IF Encontra( mPedido, "jppedi", "pedido" )
      mCliente := jppedi->pdCliFor
      IF Encontra( mPedido, "jpnota", "pedido" )
         mNf := jpnota->nfNotFis
      ENDIF
   ENDIF

   RETURN .T.

STATIC FUNCTION ChecaCli( mCliente, mNome, mEndereco, mBairro, mCep, mCidade, mUf )

   FillZeros( @mCliente )
   IF Encontra( mCliente, "jpcadas", "numlan" )
      mNome     := jpcadas->cdNome
      mEndereco := jpcadas->cdEndereco
      mBairro   := jpcadas->cdBairro
      mCep      := jpcadas->cdCep
      mCidade   := jpcadas->cdCidade
      mUf       := jpcadas->cdUf
   ENDIF

   RETURN .T.
