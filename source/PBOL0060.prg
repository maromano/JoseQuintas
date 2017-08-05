/*
PBOL0060 - IMPRIME BOLETOS
1995.05 José Quintas
*/

#include "inkey.ch"

PROCEDURE PBOL0060

   LOCAL GetList := {}
   MEMVAR  mBolNf, mBolCRec, mBolAvu, mSemBanco, mBanco, m_Txt0, m_Txt1, m_Txt2, m_Txt3, m_Txt4, m_Txt5, m_TxtE, m_TxtJ, m_TxtM, m_TxtAc
   MEMVAR  m_Notai, m_Notaf, mDataDoc, mDocto, mValor, mCliente, mParcela, mnfFilial, mnfNotFisI, mnfNotFisF, mVencto, m_TxtBco
   MEMVAR m_Prog
   PRIVATE mBolNf, mBolCRec, mBolAvu, mSemBanco, mBanco, m_Txt0, m_Txt1, m_Txt2, m_Txt3, m_TxtE, m_TxtJ, m_TxtM, m_TxtAc
   PRIVATE m_Notai, mDataDoc, mDocto, mValor, mCliente, mParcela, mnfFilial, mnfNotFisI, mnfNotFisF, mVencto, m_TxtBco

   IF ! AbreArquivos( "jpconfi", "jptabel", "jpempre", "jpcadas", "jpfinan", "jpnota" )
      RETURN
   ENDIF
   SELECT jpnota

   mBolNf     := ( m_Prog == "PBOL0060" )
   mBolCRec   := ( m_Prog == "PBOL0061" )
   mBolAvu    := ( m_Prog == "PBOL0062" )
   mSemBanco  := "NAO INFORMADO"
   mBanco     := Space( 6 )
   m_txt0     := Pad( "QUALQUER AGENCIA, MESMO APOS VENCIMENTO", 45 )
   m_txt1     := ""
   m_txt2     := ""
   m_txt3     := m_txt4 := m_txt5 := Space( 45 )
   m_TxtE     := "NF/DUP"        // Especie
   m_TxtJ     := 0               // Juros diarios
   m_TxtM     := 0               // Multa Atraso
   m_TxtAc    := "NAO"
   m_Notai    := m_Notaf := Space( 6 )
   mDataDoc   := CToD( "" )
   mDocto     := Space( 10 )
   mValor     := 0
   mCliente   := Space( 6 )
   mVencto    := CToD( "" )
   mParcela   := Space( 1 )
   mnfFilial  := Space( 6 )
   mnfNotFisI := Space( 9 )
   mnfNotFisF := Space( 9 )

   IF File( "jpbolet.mem" )
      RESTORE FROM jpbolet ADDITIVE
   ENDIF

   DO WHILE .T.
      @ 4, 3 SAY "Banco do layout.: " GET mBanco PICTURE "@K 999999" VALID AUXBANCOClass():Valida( @mBanco )
      Mensagem( "Digite os campos, F9 Pesquisa, ESC Sai" )
      READ
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      Scroll( 6, 0, MaxRow() - 3, MaxCol(), 0 )
      @ 5, 0 SAY ""
      IF mBolNf
         @ Row() + 1, 3 SAY "Filial..........: " GET mnfFilial  PICTURE "@K 999999" VALID AuxFilialClass():Valida( @mnfFilial )
         @ Row() + 1, 3 SAY "N.Fiscal Inicial: " GET mnfNotFisI PICTURE '@K 999999999' VALID JPNOTAClass():Valida( @mnfNotFisI, mnfFilial )
         @ Row() + 1, 3 SAY "N.Fiscal Final..: " GET mnfNotFisF PICTURE '@K 999999999' VALID JPNOTAClass():Valida( @mnfNotFisF, mnfFilial ) .AND. mnfNotFisF >= mnfNotFisI
      ENDIF
      IF mBolCRec
         @ Row() + 1, 3 SAY "Documento.......: " GET mDocto   PICTURE "@K!"  VALID OkCfin( @mDocto )
         @ Row() + 1, 3 SAY "Parcela.........: " GET mParcela PICTURE "9"    VALID OkCFin( @mDocto, @mParcela )
         @ Row() + 1, 3 SAY "Cliente.........: " GET mCliente PICTURE "@K!"  VALID JPCADAS1Class():Valida( @mCliente )
      ENDIF
      IF mBolAvu
         @ Row() + 1, 3 SAY "Documento.......: " GET mDocto   PICTURE "@K!"
         @ Row() + 1, 3 SAY "Data Documento..: " GET mDataDoc
         @ Row() + 1, 3 SAY "Aceite..........: " GET m_TxtAc  PICTURE "@!A" VALID m_TxtAc $ "SIM,NAO" .OR. LastKey() == K_UP
         @ Row() + 1, 3 SAY "Vencimento......: " GET mVencto
         @ Row() + 1, 3 SAY "Valor...........: " GET mValor   PICTURE PicVal( 14, 2 )
         @ Row() + 1, 3 SAY "Cliente.........: " GET mCliente PICTURE "@K!"  VALID JPCADAS1Class():Valida( @mCliente )
      ENDIF   @ Row() + 1, 3 SAY "Espécie Docto...: " GET m_TxtE PICTURE "@!"
      @ Row() + 1, 3 SAY "Aceite..........: " GET m_TxtAc PICTURE "@!A" VALID m_TxtAc $ "SIM,NAO" .OR. LastKey() == K_UP
      @ Row() + 1, 3 SAY "% Juros Mensal..: " GET m_TxtJ PICTURE "@E 99.99"
      @ Row() + 1, 3 SAY "% Multa Mensal..: " GET m_TxtM PICTURE "@E 99.99"
      @ Row() + 1, 3 SAY "Agência Bancária: " GET m_Txt0 PICTURE "@!"
      @ Row() + 1, 3 SAY "Texto 1 (multa).: " GET m_Txt1 WHEN iif( m_TxtM == 0, .T., ReturnValue( .F., m_Txt1 := EmptyValue( m_Txt1 ) ) )
      @ Row() + 1, 3 SAY "Texto 2 (juros).: " GET m_Txt2 WHEN iif( m_TxtJ == 0, .T., ReturnValue( .F., m_Txt2 := EmptyValue( m_Txt2 ) ) )
      @ Row() + 1, 3 SAY "Texto 3.........: " GET m_Txt3 PICTURE "@!"
      @ Row() + 1, 3 SAY "Texto 4.........: " GET m_Txt4 PICTURE "@!"
      @ Row() + 1, 3 SAY "Texto 5 (descto): " GET m_Txt5 PICTURE "@!" WHEN mBanco != "00237"
      Mensagem( "Digite os campos, F9 Pesquisa, ESC Sai" )
      READ

      IF LastKey() == K_ESC
         LOOP
      ENDIF

      m_TxtBco := mBanco
      SAVE TO jpbolet ALL LIKE m_Txt *

      IF mBolNf
         IF ! Encontra( mnfNotFisI, "jpnota", "jpnota1" )
            MsgWarning( "Nota Fiscal inicial não encontrada" )
            LOOP
         ENDIF
      ENDIF
      IF ConfirmaImpressao()
         DO CASE
         CASE mBolNf
            ImpBolNf()
         CASE mBolCRec
            ImpBolCRec()
         CASE mBolAvu
            ImpBolAvu()
         ENDCASE
      ENDIF
   ENDDO
   CLOSE DATABASES

   RETURN

STATIC FUNCTION ImpBolNf()

   LOCAL nKey
   MEMVAR mTexto, mnfNotFisf, m_Txt5, mBanco

   nKey = 0
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey = Inkey()
      IF jpnota->nfNotFis > mnfNotFisF
         EXIT
      ENDIF
      SELECT jpfinan
      ordSetFocus( "jpfinan2" )
      SEEK "1" + jpnota->nfNotFis
      DO WHILE jpfinan->fiTipLan == "1" .AND. jpfinan->fiNumDoc == StrZero( Val( jpnota->nfNotFis ), 9 ) .AND. nKey != K_ESC .AND. ! Eof()
         IF jpfinan->fiCliFor != jpnota->nfCadDes
            SKIP
            LOOP
         ENDIF
         encontra( jpnota->nfCadDes, "jpcadas", "numlan" )   // localiza o cliente
         DECLARE mTexto[ 15 ]
         // Dados genericos em ImpBoleto()
         mTexto[ 2 ]  := jpfinan->fiDatVen // Vencto
         mTexto[ 3 ]  := jpfinan->fiDatEmi // Emissao
         mTexto[ 4 ]  := Trim( jpfinan->fiNumDoc ) + iif( Empty( jpfinan->fiParcela ), "", "/" + jpfinan->fiParcela ) // Docto
         mTexto[ 6 ]  := jpfinan->fiValor // Valor
         IF jpfinan->fiJurDes < 0
            mTexto[ 11 ] := "DESCTO DE R$" + LTrim( Transform( - jpfinan->fiJurDes, PicVal( 14, 2 ) ) ) + " ATE' O VENCIMENTO"
         ELSE
            mTexto[ 11 ] := m_txt5 // Mens5
         ENDIF
         ImpBoleto( mBanco )
         SKIP
      ENDDO
      SELECT jpnota
      SKIP
   ENDDO

   RETURN NIL

STATIC FUNCTION ImpBolCRec()

   MEMVAR mTexto, m_Txt5, mBanco

   Encontra( jpfinan->fiCliFor, "jpcadas", "numlan" )   // localiza o cliente
   DECLARE mTexto[ 15 ]
   // Dados genericos em ImpBoleto()
   mTexto[ 2 ]  := jpfinan->fiDatVen // Vencto
   mTexto[ 3 ]  := jpfinan->fiDatEmi // Emissao
   mTexto[ 4 ]  := Trim( jpfinan->fiNumDoc ) + iif( Empty( jpfinan->fiParcela ), "", "/" + jpfinan->fiParcela ) // Docto
   mTexto[ 6 ]  := jpfinan->fiValor // Valor
   IF jpfinan->fiJurDes < 0
      mTexto[ 11 ] := "DESCTO DE R$" + LTrim( Transform( - jpfinan->fiJurDes, PicVal( 14, 2 ) ) ) + " ATE' O VENCIMENTO"
   ELSE
      mTexto[ 11 ] := m_txt5 // Mens5
   ENDIF
   ImpBoleto( mBanco )

   RETURN NIL

STATIC FUNCTION ImpBolAvu()

   MEMVAR mTexto, mCliente, mVencto, mDataDoc, mDocto, mValor, m_Txt5, mBanco

   Encontra( mCliente, "jpcadas", "numlan" )   // localiza o cliente
   DECLARE mTexto[ 15 ]
   // Dados genericos em ImpBoleto()
   mTexto[ 2 ]  := mVencto // Vencto
   mTexto[ 3 ]  := mDataDoc // Emissao
   mTexto[ 4 ]  := mDocto // Docto
   mTexto[ 6 ]  := mValor // Valor
   mTexto[ 11 ] := m_txt5 // Mens5
   ImpBoleto( mBanco )
   GravaOcorrencia( ,, "Boleto Avulso " + mDocto + ", " + DToC( mVencto ) + ", " + LTrim( Str( mValor ) ) )

   RETURN NIL

FUNCTION ImpBoleto( mBanco )

   LOCAL lNaoExiste := .F.
   MEMVAR m_Prog, mTexto, mTmpFile, m_Txt0, m_Txt1, m_Txt2, m_Txt3, m_Txt4, m_Txte, m_Txtm, m_Txtj, m_TxtAc

   // Dados genericos
   mTexto[ 1 ]  := m_Txt0 // Pagavel em
   mTexto[ 5 ]  := m_TxtE // Especie
   // mTexto[6] contem o valor a imprimir e a usar no calculo
   IF m_TxtM == 0 .OR. mTexto[ 2 ] <= Date() // A Vista
      mTexto[ 7 ] := m_Txt1
   ELSE
      mTexto[ 7 ]  := "APOS VENCTO, MULTA DE R$" + Transform( mTexto[ 6 ] * m_TxtM / 100, PicVal( 12, 2 ) )
   ENDIF
   IF m_TxtJ == 0 .OR. mTexto[ 2 ] <= Date()// A Vista
      mTexto[ 8 ] := m_Txt2
   ELSE
      mTexto[ 8 ] := "APOS VENCTO, COBRAR R$" + Transform( mTexto[ 6 ] * m_txtJ / 100 / 30, "@E 999,999.99" ) + " POR DIA DE ATRASO"
   ENDIF
   mTexto[ 9 ]  := m_Txt3 // Mensagem 3
   mTexto[ 10 ] := m_Txt4 // Mensagem 4
   mTexto[ 12 ] := Trim( jpcadas->cdNome ) + "(" + jpcadas->cdCodigo + ")" // Nome
   mTexto[ 13 ] := Trim( jpcadas->cdEndCob ) + " " + Trim( jpcadas->cdNumCob ) + " " + Trim( jpcadas->cdComCob ) + " " + Trim( jpcadas->cdBaiCob ) // End,Bairro
   mTexto[ 14 ] := AllTrim( jpcadas->cdCidCob ) + "  " + jpcadas->cdUfCob + "  CEP: " + jpcadas->cdCepCob + "   CNPJ/CPF: " + jpcadas->cdCnpj + "  " + "INSC.ESTAD: " + jpcadas->cdInsEst // Cid,Uf,Cep,CNPJ,Inscr
   mTexto[ 15 ] := m_TxtAc
   mTmpFile := MyTempFile( "TXT" )
   SET PRINTER TO ( mTmpFile )
   SET DEVICE TO PRINT
   DO CASE
   CASE mBanco == StrZero( 1, 6 ) // Brasil
      Boleto001()
   CASE mBanco == StrZero( 38, 6 ) // Banestado
      Boleto038()
   CASE mBanco == StrZero( 237, 6 ) // Bradesco
      Boleto237()
   CASE mBanco == StrZero( 341, 6 ) // Itau
      Boleto341()
   CASE mBanco == StrZero( 353, 6 ) // Santander
      Boleto353()
   CASE mBanco == StrZero( 347, 6 ) // Sudameris (era igual Am.Sul-215)
      Boleto347()
   CASE mBanco == StrZero( 399, 6 ) // HSBC
      Boleto399()
   CASE mBanco == StrZero( 409, 6 ) // Unibanco
      Boleto409()
   CASE mBanco == StrZero( 422, 6 ) // Safra
      Boleto422()
   CASE mBanco == StrZero( 479, 6 ) // BankBoston
      Boleto479()
   OTHERWISE
      lNaoExiste := .T.
   ENDCASE
   SetPRC( 0, 0 )
   SET PRINTER TO
   SET DEVICE TO SCREEN
   win_PrintFileRaw( win_printerGetDefault(), mTmpFile, "JPA Relatorio " + m_Prog )
   IF lNaoExiste
      MsgWarning( "Layout de boleto não definido!" )
   ENDIF

   RETURN NIL

FUNCTION Boleto001() // Banco do Brasil (BHM)

   LOCAL m_Lin := 2
   MEMVAR mTexto

   @ m_Lin, 0 SAY mTexto[ 1 ] // Pagavel...
   @ m_Lin, 50 SAY mTexto[ 2 ] // Vencto
   m_Lin += 3
   @ m_Lin, 0  SAY mTexto[ 3 ] // Emissao
   @ m_Lin, 10 SAY mTexto[ 4 ] // Docto
   @ m_Lin, 29 SAY mTexto[ 5 ] // Especie
   @ m_Lin, 36 SAY mTexto[ 15 ] // Aceite
   @ m_Lin, 40 SAY Date() // Data Processamento
   m_Lin += 2
   @ m_Lin, 50 SAY mTexto[ 6 ] PICTURE "@E 999,999,999.99" // Valor
   m_Lin += 1
   @ m_Lin, 0  SAY "VENCIMENTO: " + DToC( mTexto[ 2 ] ) + "  VALOR: R$ " + LTrim( Transform( mTexto[ 6 ], "@E 999,999,999.99" ) )
   m_lin += 1
   @ m_Lin++, 0 SAY mTexto[ 7 ]
   @ m_Lin++, 0 SAY mTexto[ 8 ]
   @ m_Lin++, 0 SAY mTexto[ 9 ]
   @ m_Lin++, 0 SAY mTexto[ 10 ]
   @ m_Lin++, 0 SAY mTexto[ 11 ]
   m_Lin++
   @ m_Lin++, 10 SAY Chr( 15 ) + mTexto[ 12 ] // Nome
   @ m_Lin++, 10 SAY mTexto[ 13 ] // End,Bairro
   @ m_Lin++, 10 SAY mTexto[ 14 ] // Cid, Uf, Cep, CNPJ, Inscr
   @ m_Lin + 1, 0 SAY Chr( 18 )
   @ m_Lin + 6, 0 SAY ""

   RETURN NIL

FUNCTION Boleto038() // Banestado

   LOCAL m_Lin := 2
   MEMVAR mTexto

   @ m_Lin, 0 SAY mTexto[ 1 ] // Pagavel...
   @ m_Lin, 54 SAY mTexto[ 2 ] // Vencto
   m_Lin += 3
   @ m_Lin, 0  SAY mTexto[ 3 ] // Emissao
   @ m_Lin, 11 SAY mTexto[ 4 ] // Docto
   @ m_Lin, 26 SAY mTexto[ 5 ] // Especie
   @ m_Lin, 32 SAY mTexto[ 15 ] // Aceite
   @ m_Lin, 40 SAY Date() // Data Processamento
   m_Lin += 1
   @ m_Lin, 50 SAY mTexto[ 6 ] PICTURE "@E 999,999,999.99" // Valor
   m_Lin += 4
   @ m_Lin, 0  SAY "VENCIMENTO: " + DToC( mTexto[ 2 ] ) + "  VALOR: R$ " + LTrim( Transform( mTexto[ 6 ], "@E 999,999,999.99" ) )
   m_lin += 1
   @ m_Lin++, 0 SAY mTexto[ 7 ]
   @ m_Lin++, 0 SAY mTexto[ 8 ]
   @ m_Lin++, 0 SAY mTexto[ 9 ]
   @ m_Lin++, 0 SAY mTexto[ 10 ]
   @ m_Lin++, 0 SAY mTexto[ 11 ]
   @ m_Lin++, 15 SAY Chr( 15 ) + mTexto[ 12 ] // Nome
   @ m_Lin++, 0 SAY mTexto[ 13 ] // End,Bairro
   @ m_Lin++, 13 SAY mTexto[ 14 ] // Cid, Uf, Cep, CNPJ, Inscr
   @ m_Lin + 1, 0 SAY Chr( 18 )
   @ m_Lin + 7, 0 SAY ""

   RETURN NIL

FUNCTION Boleto347() // Sudameris (Parecido America do Sul) (Vivitek)

   LOCAL m_Lin := 2
   MEMVAR mTexto

   @ m_Lin, 1  SAY mTexto[ 1 ] // Pagavel...
   @ m_Lin, 50 SAY mTexto[ 2 ] // Vencto
   m_Lin += 3
   @ m_Lin, 0  SAY mTexto[ 3 ] // Emissao
   @ m_Lin, 11 SAY mTexto[ 4 ] // Docto
   @ m_Lin, 27 SAY mTexto[ 5 ] // Especie
   @  m_Lin, 33 SAY mTexto[ 15 ] // Aceite
   @ m_Lin, 37 SAY Date() // Data Processamento
   m_Lin += 1
   @ m_Lin, 49 SAY mTexto[ 6 ] PICTURE "@E 999,999,999.99" // Valor
   m_Lin += 3
   @ m_Lin, 1  SAY "VENCIMENTO: " + DToC( mTexto[ 2 ] ) + "  VALOR: R$ " + LTrim( Transform( mTexto[ 6 ], "@E 999,999,999.99" ) )
   m_lin += 1
   @ m_Lin++, 1 SAY mTexto[ 7 ]
   @ m_Lin++, 1 SAY mTexto[ 8 ]
   @ m_Lin++, 1 SAY mTexto[ 9 ]
   @ m_Lin++, 1 SAY mTexto[ 10 ]
   @ m_Lin++, 1 SAY mTexto[ 11 ]
   @ m_Lin++, 15 SAY Chr( 15 ) + mTexto[ 12 ] // Nome
   @ m_Lin++, 1 SAY mTexto[ 13 ] // End,Bairro
   @ m_Lin++, 1 SAY mTexto[ 14 ] // Cid, Uf, Cep, CNPJ, Inscr
   @ m_Lin + 1, 1 SAY Chr( 18 )
   @ m_Lin + 6, 1 SAY ""

   RETURN NIL

FUNCTION Boleto237() // Bradesco

   LOCAL m_Lin := 1
   MEMVAR mTexto

   @ m_Lin, 2 SAY mTexto[ 1 ] // Pagavel...
   @ m_Lin, 52 SAY mTexto[ 2 ] // Vencto
   m_Lin += 3
   @ m_Lin, 2  SAY mTexto[ 3 ] // Emissao
   @ m_Lin, 12 SAY mTexto[ 4 ] // Docto
   @ m_Lin, 26 SAY mTexto[ 5 ] // Especie
   @ m_Lin, 33 SAY mTexto[ 15 ] // Aceite
   @ m_Lin, 38 SAY Date() // Data Processamento
   m_Lin += 1
   @ m_Lin, 52 SAY mTexto[ 6 ] PICTURE "@E 999,999,999.99" // Valor
   m_Lin += 3
   @ m_Lin, 2  SAY "VENCIMENTO: " + DToC( mTexto[ 2 ] ) + "  VALOR: R$ " + LTrim( Transform( mTexto[ 6 ], "@E 999,999,999.99" ) )
   m_lin += 1
   @ m_Lin++, 2 SAY mTexto[ 7 ]
   @ m_Lin++, 2 SAY mTexto[ 8 ]
   @ m_Lin++, 2 SAY mTexto[ 9 ]
   @ m_Lin++, 2 SAY mTexto[ 10 ]
   @ m_Lin++, 2 SAY mTexto[ 11 ]
   @ m_Lin++, 10 SAY Chr( 15 ) + mTexto[ 12 ] // Nome
   @ m_Lin++, 2 SAY mTexto[ 13 ] // End,Bairro
   @ m_Lin++, 2 SAY mTexto[ 14 ] // Cid, Uf, Cep, CNPJ, Inscr
   @ m_Lin + 1, 0 SAY Chr( 18 )
   @ m_Lin + 7, 0 SAY ""

   RETURN NIL

FUNCTION Boleto341() // Itau (Cordeiro)

   LOCAL mCont, m_Lin := 2
   MEMVAR mTexto

   FOR mCont = 7 TO 11
      IF Empty( mTexto[ mCont ] )
         mTexto[ mCont ] := "NUM.DOCTO:" + mTexto[ 4 ] // num.docto. na mensagem livre
         EXIT
      ENDIF
   NEXT
   @ m_Lin, 0  SAY mTexto[ 1 ] // Pagavel...
   @ m_Lin, 50 SAY mTexto[ 2 ] // Vencto
   m_Lin += 3
   @ m_Lin, 0  SAY mTexto[ 3 ] // Emissao
   @ m_Lin, 10 SAY mTexto[ 4 ] // Docto
   @ m_Lin, 28 SAY mTexto[ 5 ] // Especie
   @ m_Lin, 35 SAY mTexto[ 15 ] // Aceite
   @ m_Lin, 39 SAY Date() // Data Processamento
   m_Lin += 2
   @ m_Lin, 49 SAY mTexto[ 6 ] PICTURE "@E 999,999,999.99" // Valor
   m_Lin += 2
   @ m_Lin, 0  SAY "VENCIMENTO: " + DToC( mTexto[ 2 ] ) + "  VALOR: R$ " + LTrim( Transform( mTexto[ 6 ], "@E 999,999,999.99" ) )
   m_lin += 1
   @ m_Lin++, 0 SAY mTexto[ 7 ]
   @ m_Lin++, 0 SAY mTexto[ 8 ]
   @ m_Lin++, 0 SAY mTexto[ 9 ]
   @ m_Lin++, 0 SAY mTexto[ 10 ]
   @ m_Lin++, 0 SAY mTexto[ 11 ]
   @ m_Lin++, 15 SAY Chr( 15 ) + mTexto[ 12 ] // Nome
   @ m_Lin++, 0 SAY mTexto[ 13 ] // End,Bairro
   @ m_Lin++, 0 SAY mTexto[ 14 ] // Cid, Uf, Cep, CNPJ, Inscr
   @ m_Lin + 1, 0 SAY Chr( 18 )
   @ m_Lin + 6, 0 SAY ""

   RETURN NIL

FUNCTION Boleto353() // Santander

   LOCAL m_Lin := 1
   MEMVAR mTexto

   @ m_Lin, 1 SAY mTexto[ 1 ] // Pagavel...
   @ m_Lin, 50 SAY mTexto[ 2 ] // Vencto
   m_Lin += 3
   @ m_Lin, 0  SAY mTexto[ 3 ] // Emissao
   @ m_Lin, 12 SAY mTexto[ 4 ] // Docto
   @ m_Lin, 28 SAY mTexto[ 5 ] // Especie
   @ m_Lin, 34 SAY mTexto[ 15 ] // Aceite
   @ m_Lin, 39 SAY Date() // Data Processamento
   m_Lin += 2
   @ m_Lin, 51 SAY mTexto[ 6 ] PICTURE "@E 999,999,999.99" // Valor
   m_Lin += 2
   @ m_Lin, 2  SAY "VENCIMENTO: " + DToC( mTexto[ 2 ] ) + "  VALOR: R$ " + LTrim( Transform( mTexto[ 6 ], "@E 999,999,999.99" ) )
   m_lin += 2
   @ m_Lin++, 2 SAY mTexto[ 7 ]
   @ m_Lin++, 2 SAY mTexto[ 8 ]
   @ m_Lin++, 2 SAY mTexto[ 9 ]
   @ m_Lin++, 2 SAY mTexto[ 10 ]
   @ m_Lin++, 2 SAY mTexto[ 11 ]
   @ m_Lin++, 10 SAY Chr( 15 ) + mTexto[ 12 ] // Nome
   @ m_Lin++, 2 SAY mTexto[ 13 ] // End,Bairro
   @ m_Lin++, 2 SAY mTexto[ 14 ] // Cid, Uf, Cep, CNPJ, Inscr
   @ m_Lin + 1, 0 SAY Chr( 18 )
   @ m_Lin + 6, 0 SAY ""

   RETURN NIL

FUNCTION Boleto399() // HSBC (Vivitek)

   LOCAL m_Lin := 2
   MEMVAR mTexto

   @ m_Lin, 1 SAY mTexto[ 1 ] // Pagavel...
   @ m_Lin, 54 SAY mTexto[ 2 ] // Vencto
   m_Lin += 3
   @ m_Lin, 1  SAY mTexto[ 3 ] // Emissao
   @ m_Lin, 12 SAY mTexto[ 4 ] // Docto
   // @ m_Lin, 24 SAY mTexto[5] // Especie
   // @ m_Lin, 31 SAY mTexto[15] // Aceite
   @ m_Lin, 40 SAY Date() // Data Processamento
   m_Lin += 2
   @ m_Lin, 55 SAY mTexto[ 6 ] PICTURE "@E 999,999,999.99" // Valor
   m_Lin += 2
   @ m_Lin, 1  SAY "VENCIMENTO: " + DToC( mTexto[ 2 ] ) + "  VALOR: R$ " + LTrim( Transform( mTexto[ 6 ], "@E 999,999,999.99" ) )
   m_lin += 1
   @ m_Lin++, 1 SAY mTexto[ 7 ]
   @ m_Lin++, 1 SAY mTexto[ 8 ]
   @ m_Lin++, 1 SAY mTexto[ 9 ]
   @ m_Lin++, 1 SAY mTexto[ 10 ]
   @ m_Lin++, 1 SAY mTexto[ 11 ]
   m_Lin += 1
   @ m_Lin++, 15 SAY Chr( 15 ) + mTexto[ 12 ] // Nome
   @ m_Lin++, 1 SAY mTexto[ 13 ] // End,Bairro
   @ m_Lin++, 1 SAY mTexto[ 14 ] // Cid, Uf, Cep, CNPJ, Inscr
   @ m_Lin + 1, 0 SAY Chr( 18 )
   @ m_Lin + 7, 0 SAY ""

   RETURN NIL

FUNCTION Boleto409() // Unibanco (Vivitek)

   LOCAL m_Lin := 2
   MEMVAR mTexto

   @ m_Lin, 0 SAY mTexto[ 1 ] // Pagavel...
   @ m_Lin, 50 SAY mTexto[ 2 ] // Vencto
   m_Lin += 3
   @ m_Lin, 0  SAY mTexto[ 3 ] // Emissao
   @ m_Lin, 10 SAY mTexto[ 4 ] // Docto
   @ m_Lin, 29 SAY mTexto[ 5 ] // Especie
   @ m_Lin, 36 SAY mTexto[ 15 ] // Aceite
   @ m_Lin, 40 SAY Date() // Data Processamento
   m_Lin += 2
   @ m_Lin, 50 SAY mTexto[ 6 ] PICTURE "@E 999,999,999.99" // Valor
   m_Lin += 2
   @ m_Lin, 0  SAY "VENCIMENTO: " + DToC( mTexto[ 2 ] ) + "  VALOR: R$ " + LTrim( Transform( mTexto[ 6 ], "@E 999,999,999.99" ) )
   m_lin += 1
   @ m_Lin++, 0 SAY mTexto[ 7 ]
   @ m_Lin++, 0 SAY mTexto[ 8 ]
   @ m_Lin++, 0 SAY mTexto[ 9 ]
   @ m_Lin++, 0 SAY mTexto[ 10 ]
   @ m_Lin++, 0 SAY mTexto[ 11 ]
   @ m_Lin++, 10 SAY Chr( 15 ) + mTexto[ 12 ] // Nome
   @ m_Lin++, 10 SAY mTexto[ 13 ] // End,Bairro
   @ m_Lin++, 10 SAY mTexto[ 14 ] // Cid, Uf, Cep, CNPJ, Inscr
   @ m_Lin + 1, 0 SAY Chr( 18 )
   @ m_Lin + 6, 0 SAY ""

   RETURN NIL

FUNCTION Boleto422() // Safra (Vivitek)

   LOCAL m_Lin := 2
   MEMVAR mTexto

   // @ m_Lin, 0  SAY mTexto[1] // Pagavel...
   @ m_Lin, 50 SAY mTexto[ 2 ] // Vencto
   m_Lin += 3
   @ m_Lin, 0  SAY mTexto[ 3 ] // Emissao
   @ m_Lin, 11 SAY mTexto[ 4 ] // Docto
   // @ m_Lin, 23 SAY mTexto[5] // Especie
   @ m_Lin, 28 SAY mTexto[ 15 ] // Aceite
   // @ m_Lin, 39 SAY Date() // Data Processamento
   m_Lin += 1
   @ m_Lin, 49 SAY mTexto[ 6 ] PICTURE "@E 999,999,999.99" // Valor
   m_Lin += 2
   @ m_Lin, 0  SAY "VENCIMENTO: " + DToC( mTexto[ 2 ] ) + "  VALOR: R$ " + LTrim( Transform( mTexto[ 6 ], "@E 999,999,999.99" ) )
   m_lin += 1
   @ m_Lin++, 0 SAY mTexto[ 7 ]
   @ m_Lin++, 0 SAY mTexto[ 8 ]
   @ m_Lin++, 0 SAY mTexto[ 9 ]
   @ m_Lin++, 0 SAY mTexto[ 10 ]
   @ m_Lin++, 0 SAY mTexto[ 11 ]
   @ m_Lin++, 15 SAY Chr( 15 ) + mTexto[ 12 ] // Nome
   @ m_Lin++, 0 SAY mTexto[ 13 ] // End,Bairro
   @ m_Lin++, 0 SAY mTexto[ 14 ] // Cid, Uf, Cep, CNPJ, Inscr
   @ m_Lin + 1, 0 SAY Chr( 18 )
   @ m_Lin + 6, 0 SAY ""

   RETURN NIL

FUNCTION Boleto479() // BankBoston (Vivitek)

   LOCAL m_Lin := 2
   MEMVAR mTexto

   @ m_Lin, 0  SAY mTexto[ 1 ] // Pagavel...
   @ m_Lin, 50 SAY mTexto[ 2 ] // Vencto
   m_Lin += 3
   @ m_Lin, 0  SAY mTexto[ 3 ] // Emissao
   @ m_Lin, 10 SAY mTexto[ 4 ] // Docto
   @ m_Lin, 28 SAY mTexto[ 5 ] // Especie
   @ m_Lin, 35 SAY mTexto[ 15 ] // Aceite
   @ m_Lin, 39 SAY Date() // Data Processamento
   m_Lin += 1
   @ m_Lin, 49 SAY mTexto[ 6 ] PICTURE "@E 999,999,999.99" // Valor
   m_Lin += 3
   @ m_Lin, 0  SAY "VENCIMENTO: " + DToC( mTexto[ 2 ] ) + "  VALOR: R$ " + LTrim( Transform( mTexto[ 6 ], "@E 999,999,999.99" ) )
   m_lin += 1
   @ m_Lin++, 0 SAY mTexto[ 7 ]
   @ m_Lin++, 0 SAY mTexto[ 8 ]
   @ m_Lin++, 0 SAY mTexto[ 9 ]
   @ m_Lin++, 0 SAY mTexto[ 10 ]
   @ m_Lin++, 0 SAY mTexto[ 11 ]
   @ m_Lin++, 15 SAY Chr( 15 ) + mTexto[ 12 ] // Nome
   @ m_Lin++, 0 SAY mTexto[ 13 ] // End,Bairro
   @ m_Lin++, 0 SAY mTexto[ 14 ] // Cid, Uf, Cep, CNPJ, Inscr
   @ m_Lin + 1, 0 SAY Chr( 18 )
   @ m_Lin + 6, 0 SAY ""

   RETURN NIL

PROCEDURE PBOL0061

   DO PBOL0060

   RETURN

PROCEDURE PBOL0062

   DO PBOL0060

   RETURN

STATIC FUNCTION OkCFin( mNumDocto, mParcela )

   mParcela := iif( mParcela == NIL, "", mParcela )
   IF LastKey() != K_UP
      IF ! Encontra( "1" + mNumDocto + mParcela, "jpfinan", "jpfinan2" )
         MsgWarning( "Docto não cadastrado!" )
         RETURN .F.
      ENDIF
   ENDIF

   RETURN .T.
