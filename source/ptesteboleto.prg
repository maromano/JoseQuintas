/*
PTESTEBOLETO - BOLETO EM PDF
2012.09 José Quintas
*/

#include "inkey.ch"
#include "harupdf.ch"
#include "hbclass.ch"

PROCEDURE pTesteBoleto

   LOCAL oBoleto, oPdf, mCliente, GetList := {}

   IF ! AbreArquivos( "jpconfi", "jptabel", "jpempre", "jpcadas", "jpfinan", "jpnota", "jpclista" )
      RETURN
   ENDIF
   SELECT jpcadas

   oBoleto := BoletoClass():New()
   oBoleto:nBanco       := 341
   oBoleto:nAgencia     := 4
   oBoleto:nConta       := 330999
   oBoleto:nCarteira    := 109
   oBoleto:nNossoNumero := 20110712
   oBoleto:cNumDoc      := Pad( "1", 8 )
   oBoleto:dDatVen      := Date()
   oBoleto:nValor       := 5.00
   mCliente := StrZero( 6, 6 )

   @         2, 0 SAY "Banco.......:" GET oBoleto:nBanco       PICTURE "999"
   @ Row() + 1, 0 SAY "Agência.....:" GET oBoleto:nAgencia     PICTURE "9999"
   @ Row() + 1, 0 SAY "Conta.......:" GET oBoleto:nConta       PICTURE "999999"
   @ Row() + 1, 0 SAY "Carteira....:" GET oBoleto:nCarteira    PICTURE "999"
   @ Row() + 1, 0 SAY "Numero Docto:" GET oBoleto:cNumDoc      PICTURE "@!"
   @ Row() + 1, 0 SAY "Nosso número:" GET oBoleto:nNossoNumero PICTURE "99999999"
   @ Row() + 1, 0 SAY "Vencimento..:" GET oBoleto:dDatVen
   @ Row() + 1, 0 SAY "Valor.......:" GET oBoleto:nValor       PICTURE PicVal( 8, 2 )
   @ Row() + 1, 0 SAY "Cliente.....:" GET mCliente             PICTURE "999999" VALID JPCADAS1Class():Valida( @mCliente )
   @ Row() + 1, 0 SAY "Instrução...:" GET oBoleto:cInstrucao   PICTURE "@!"
   Mensagem( "Digite campos, ESC Sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC
      RETURN
   ENDIF

   Encontra( mCliente, "jpcadas", "numlan" )
   oBoleto:Calcula()
   oBoleto:cBeneficNome := Trim( jpempre->emNome )
   oBoleto:cBeneficEnd1 := Trim( jpempre->emEndereco )
   oBoleto:cBeneficEnd2 := Trim( jpempre->emCep ) + " " + Trim( jpempre->emBairro ) + " " + Trim( jpempre->emCidade ) + " " + jpempre->emUf
   oBoleto:cPagadorNome := Trim( jpcadas->cdNome ) + " " + jpcadas->cdCnpj
   oBoleto:cPagadorEnd1 := Trim( jpcadas->cdEndereco ) + " " + Trim( jpcadas->cdNumero ) + " " + Trim( Jpcadas->cdCompl )
   oBoleto:cPagadorEnd2 := jpcadas->cdCep + " " + Trim( jpcadas->cdBairro ) + " " + Trim( jpcadas->cdCidade ) + " " + jpcadas->cdUf
   oBoleto:cAvalista    := Trim( jpcadas->cdNome ) + " " + jpcadas->cdCnpj

   oPdf := MyPdfBoletoClass():New()
   oPDF:Begin()
   oPdf:AddBoleto( oBoleto )
   oPDF:End()
   CLOSE DATABASES

   RETURN

CREATE CLASS BoletoClass

   VAR    nBanco       INIT 0
   VAR    nAgencia     INIT 0
   VAR    nConta       INIT 0
   VAR    nCarteira    INIT 0
   VAR    cNumDoc      INIT Space( 10 )
   VAR    nNossoNumero INIT 0
   VAR    dDatVen      INIT Date()
   VAR    nValor       INIT 0
   VAR    cBarras      INIT ""
   VAR    cDigitavel   INIT ""
   VAR    cBarCode     INIT ""
   VAR    cBeneficNome INIT ""
   VAR    cBeneficEnd1 INIT ""
   VAR    cBeneficEnd2 INIT ""
   VAR    cPagadorNome INIT ""
   VAR    cPagadorEnd1 INIT ""
   VAR    cPagadorEnd2 INIT ""
   VAR    cAvalista    INIT ""
   VAR    cInstrucao   INIT Pad( "PROTESTO APOS 10 DIAS DO VENCIMENTO", 40 )
   METHOD Calcula()
   METHOD Modulo10( cNumero )
   METHOD Modulo11( cNumero )
   METHOD BarCodeI25()

   ENDCLASS

METHOD Calcula() CLASS BoletoClass

   LOCAL cBanco, cAgencia, cConta, cCarteira, cNossoNumero, cMoeda, cParte, cDigito, cBarras, cDigitavel

   cBanco       := StrZero( ::nBanco, 3 )
   cAgencia     := StrZero( ::nAgencia, 4 )
   cConta       := StrZero( ::nConta, 6 )
   cCarteira    := StrZero( ::nCarteira, 3 )
   cNossoNumero := StrZero( ::nNossoNumero, 8 )
   cMoeda       := Str( 9, 1 ) // Real

   cBarras      := cBanco + cMoeda + StrZero( ::dDatVen - SToD( "19971007" ), 4 ) + StrZero( ::nValor * 100, 10 ) + cCarteira + cNossoNumero
   cDigito      := ::Modulo10( cAgencia + Left( cConta, 5 ) + cCarteira + cNossoNumero )
   cBarras      += cDigito + cAgencia + cConta
   cBarras      += ::Modulo10( cAgencia + cConta ) + "000"
   cDigito      := ::Modulo11( cBarras )
   cBarras      := SubStr( cBarras, 1, 4 ) + cDigito + SubStr( cBarras, 5 )
   ::cBarras := cBarras

   cParte       := cBanco + "9" + cCarteira + SubStr( cNossoNumero, 1, 2 )
   cDigitavel   := cParte + ::Modulo10( cParte )
   cParte       := SubStr( cNossoNumero, 3 )  + ::Modulo10( cAgencia + Left( cConta, 5 ) + cCarteira + cNossoNumero ) + SubStr( cAgencia, 1, 3 )
   cDigitavel   += cParte + ::Modulo10( cParte )
   cParte       := SubStr( cAgencia, 4 ) + cConta + "000"
   cDigitavel   += cParte + ::Modulo10( cParte )
   cDigitavel   += SubStr( cBarras, 5, 1 )
   cDigitavel   += StrZero( ::dDatVen - SToD( "19971007" ), 4 ) + StrZero( ::nValor * 100, 10 )
   ::cDigitavel := cDigitavel
   ::cBarCode   := ::BarCodeI25( cBarras )

   RETURN NIL

METHOD Modulo10( cNumero ) CLASS BoletoClass

   LOCAL nFator, nSoma, cLista, cDigito

   nSoma  := 0
   nFator := 2
   FOR EACH cDigito IN cNumero DESCEND
      cLista := StrZero( Val( cDigito ) * nFator, 2 )
      nSoma  += ( Val( SubStr( cLista, 1, 1 ) ) + Val( SubStr( cLista, 2, 1 ) ) )
      nFator := iif( nFator == 2, 1, 2 )
   NEXT
   nSoma := nSoma - ( Int( nSoma / 10 ) * 10 )
   nSoma := 10 - nSoma
   nSoma := iif( nSoma == 10, 0, nSoma )

   RETURN Str( nSoma, 1 )

METHOD Modulo11( cNumero ) CLASS BoletoClass

   LOCAL nFator, nSoma := 0, cDigito

   nSoma  := 0
   nFator := 2
   FOR EACH cDigito IN cNumero DESCEND
      nSoma += ( Val( cDigito ) * nFator )
      nFator := iif( nFator == 9, 2, nFator + 1 )
   NEXT
   nSoma := nSoma - ( Int( nSoma / 11 ) * 11 )
   nSoma := 11 - nSoma
   nSoma := iif( nSoma == 0 .OR. nSoma == 10 .OR. nSoma == 11, 1, nSoma )

   RETURN Str( nSoma, 1 )

METHOD BarCodeI25() CLASS BoletoClass // Imprimir branco/preto/branco/preto F=Fino L=Largo

   LOCAL cBarCodeI25 := "", nCont, nCont2, cBarCodeNumber, cBarNumberA, cBarNumberB

   cBarCodeNumber       := Array( 10 )
   cBarCodeNumber[ 1 ]  := "11221"
   cBarCodeNumber[ 2 ]  := "21112"
   cBarCodeNumber[ 3 ]  := "12112"
   cBarCodeNumber[ 4 ]  := "22111"
   cBarCodeNumber[ 5 ]  := "11212"
   cBarCodeNumber[ 6 ]  := "21211"
   cBarCodeNumber[ 7 ]  := "12211"
   cBarCodeNumber[ 8 ]  := "11122"
   cBarCodeNumber[ 9 ]  := "21121"
   cBarCodeNumber[ 10 ] := "12121"
   FOR nCont = 1 TO Len( ::cBarras ) - 1 STEP 2
      cBarNumberA = cBarCodeNumber[ Val( SubStr( ::cBarras, nCont, 1 ) ) + 1 ]
      cBarNumberB = cBarCodeNumber[ Val( SubStr( ::cBarras, nCont + 1, 1 ) ) + 1 ]
      FOR nCont2 = 1 TO 5
         cBarCodeI25 += SubStr( cBarNumberA, nCont2, 1 ) + SubStr( cBarNumberB, nCont2, 1 )
      NEXT
   NEXT
   cBarCodeI25 := "1111" + cBarCodeI25 + "211"

   RETURN cBarCodeI25

CREATE CLASS MyPDFBoletoClass INHERIT PDFClass

   VAR    nFontSizeLarge    INIT 11
   VAR    nFontSizeSmall    INIT 6
   VAR    nFontSizeNormal   INIT 9
   VAR    cFontName         INIT "Helvetica"
   VAR    nDrawMode         INIT 2 // mm
   VAR    nPdfPage          INIT 2 // Portrait
   METHOD INIT()
   METHOD DrawI25BarCode( nRow, nCol, nHeight, cBarCode, nOneBarWidth )
   METHOD AddBoleto( oBoleto )

   ENDCLASS

METHOD INIT() CLASS MyPDFBoletoClass

   ::SetType( 2 )

   RETURN NIL

METHOD AddBoleto( oBoleto ) CLASS MyPDFBoletoClass

   ::AddPage()

   ::DrawText(  25, 162, "Recibo do Pagador", , ::nfontsizeNormal )

   ::DrawLine(  27,  20,  27, 197 )
   ::DrawLine(  27, 125,  33, 125 )
   ::DrawLine(  27, 161,  33, 161 )

   ::DrawText(  29,  20, "Beneficiário", , ::nfontsizeSmall )
   ::DrawText(  29, 126, "CNPJ/CPF", , ::nfontsizeSmall )
   ::DrawText(  29, 162, "Vencimento", , ::nfontsizeSmall )
   ::DrawText(  32,  20, oBoleto:cBeneficNome, , ::nfontsizeNormal )
   ::DrawText(  32, 126, "XXXEMPRESACNPJ", , ::nfontsizeNormal )
   ::DrawText(  32, 162, DToC( oBoleto:dDatVen ), , ::nfontsizeNormal )

   ::DrawLine(  33,  20,  33, 197 )
   ::DrawLine(  33,  46,  39,  46 )
   ::DrawLine(  33,  68,  39,  68 )
   ::DrawLine(  33,  78,  39,  78 )
   ::DrawLine(  33, 118,  39, 118 )
   ::DrawLine(  33, 156,  39, 156 )
   ::DrawText(  35,  20, "CPI", , ::nfontsizeSmall )
   ::DrawText(  35,  47, "Carteira", , ::nfontsizeSmall )
   ::DrawText(  35,  69, "Espécie", , ::nfontsizeSmall )
   ::DrawText(  35,  79, "Quantidade", , ::nfontsizeSmall )
   ::DrawText(  35, 119, "Valor", , ::nfontsizeSmall )
   ::DrawText(  35, 157, "Agência/Código do Beneficiário", , ::nfontsizeSmall )
   ::DrawText(  38,  47, StrZero( oBoleto:nCarteira, 3 ), , ::nfontsizeNormal )
   ::DrawText(  38,  69, "REAL", , ::nfontsizeNormal )
   ::DrawText(  38, 157, StrZero( oBoleto:nAgencia, 4 ) + " / " + Transform( StrZero( oBoleto:nConta, 6 ), "@R 99999-9" ), , ::nfontsizeNormal )

   ::DrawLine(  39,  20,  39, 197 )
   ::DrawLine(  39,  51,  45,  51 )
   ::DrawLine(  39,  78,  45,  78 )
   ::DrawLine(  39, 112,  45, 112 )
   ::DrawLine(  39, 125,  45, 125 )
   ::DrawLine(  39, 151,  45, 151 )
   ::DrawText(  41,  20, "Data do Documento", , ::nfontsizeSmall )
   ::DrawText(  41,  52, "Número do Documento", , ::nfontsizeSmall )
   ::DrawText(  41,  79, "Espécie do Documento", , ::nfontsizeSmall )
   ::DrawText(  41, 113, "Aceite", , ::nfontsizeSmall )
   ::DrawText(  41, 126, "Data do Processamento", , ::nfontsizeSmall )
   ::DrawText(  41, 152, "Valor do Documento", , ::nfontsizeSmall )
   ::DrawText(  44, 20,  DToC( Date() ), , ::nfontsizeNormal )
   ::DrawText(  44,  52, oBoleto:cNumDoc, , ::nfontsizeNormal )
   ::DrawText(  44,  79, "NF", , ::nfontsizeNormal )
   ::DrawText(  44, 113, "SIM", , ::nfontsizeNormal )
   ::DrawText(  44, 126, DToC( Date() ), , ::nfontsizeNormal )
   ::DrawText(  44, 171, Transform( oBoleto:nValor, "@E 999,999,999.99" ), , ::nfontsizeNormal )

   ::DrawLine(  45,  20,  45, 197 )
   ::DrawText(  47,  20, "Endereço", , ::nfontsizeSmall )
   ::DrawText(  49,  20, oBoleto:cBeneficEnd1 + " " + oBoleto:cBeneficEnd2, , ::nfontsizeNormal )

   ::DrawLine(  51,  20,  51, 197 )
   ::DrawText(  55,  20, oBoleto:cInstrucao, , ::nfontsizeNormal )

   ::DrawLine( 181,  20, 181, 197 )
   ::DrawLine( 181, 115, 185, 115 )
   ::DrawLine( 181, 197, 185, 197 )

   ::DrawText( 183,  20, "RECEBIMENTO ATRAVÉS DO CHEQUE No.", , ::nfontsizeSmall )
   ::DrawText( 183, 149, "Autenticação Mecânica", , ::nfontsizeSmall )
   ::DrawText( 185,  20, "DO BANCO", , ::nfontsizeSmall )
   ::DrawText( 187,  20, "ESTA QUITAÇÃO SÓ TERÁ VALIDADE APÓS O PAGAMENTO", , ::nfontsizeSmall )
   ::DrawText( 189,  20, "DO CHEQUE PELO BANCO PAGADOR", , ::nfontsizeSmall )

   ::DrawMemImageBox( 201, 20, 208, 46, JPEGBancoItau() )
   ::DrawLine( 203, 57, 209, 57 )
   ::DrawLine( 203, 71, 209, 71 )
   ::DrawText( 208, 75, Transform( oBoleto:cDigitavel, "@R 99999.99999 99999.999999 99999.999999 9 99999999999999" ), , ::nfontsizeLarge )

   // ::DrawText( 208, 30, "Itaú Unibanco S/A", , ::nfontsizeSmall )
   ::DrawText( 208, 58, "341-7", , ::nfontsizeLarge )

   ::DrawLine( 211, 148, 266, 148 )
   ::DrawLine( 211,  20, 211, 197 )
   ::DrawText( 214,  20, "Local de Pagamento", , ::nfontsizeSmall )
   ::DrawText( 214, 149, "Vencimento", , ::nfontsizeSmall )
   ::DrawText( 217,  20, "PAGÁVEL EM QUALQUER AGÊNCIA BANCÁRIA ATÉ O VENCIMENTO", , ::nfontsizeNormal )
   ::DrawText( 217, 149, DToC( oBoleto:dDatVen ), , ::nfontsizeNormal )

   ::DrawLine( 218,  20, 218, 197 )
   ::DrawText( 220,  20, "Beneficiário" )
   ::DrawText( 220,  35, FormatCnpj( jpempre->emCnpj ) + " " + Trim( jpempre->emEndereco ) + " " + Trim( jpempre->emCidade ) + " " + jpempre->emUF, , ::nFontSizeSmall )
   ::DrawText( 223,  20, Trim( jpempre->emNome ), , ::nFontSizeNormal )
   ::DrawText( 220, 149, "Agência/Código Beneficiário", , ::nfontsizeSmall )
   ::DrawText( 223, 149, StrZero( oBoleto:nAgencia, 4 ) + " / " + Transform( StrZero( oBoleto:nConta, 6 ), "@R 99999-9" ), , ::nfontsizeNormal )

   ::DrawLine( 224,  20, 224, 197 )
   ::DrawLine( 224,  49, 230,  49 )
   ::DrawLine( 224,  78, 230,  78 )
   ::DrawLine( 224,  99, 230,  99 )
   ::DrawLine( 224, 121, 230, 121 )
   ::DrawText( 226,  20, "Data do Documento", , ::nfontsizeSmall )
   ::DrawText( 226,  50, "No.Documento", , ::nfontsizeSmall )
   ::DrawText( 226,  79, "Espécie Doc", , ::nfontsizeSmall )
   ::DrawText( 226, 100, "Aceite", , ::nfontsizeSmall )
   ::DrawText( 226, 122, "Data Processamento", , ::nfontsizeSmall )
   ::DrawText( 226, 149, "Nosso Número", , ::nfontsizeSmall )
   ::DrawText( 229,  20, DToC( Date() ), , ::nfontsizeNormal )
   ::DrawText( 229,  50, oBoleto:cNumDoc, , ::nfontsizeNormal )
   ::DrawText( 229, 122, DToC( Date() ), , ::nfontsizeNormal )
   ::DrawText( 229, 149, StrZero( oBoleto:nNossoNumero, 8 ), , ::nfontsizeNormal )
   ::DrawText( 229,  79, "NF", , ::nfontsizeNormal )
   ::DrawText( 229, 100, "SIM", , ::nfontsizeNormal )

   ::DrawLine( 230,  20, 230, 197 )
   ::DrawLine( 230,  56, 236, 56 )
   ::DrawLine( 230,  73, 236, 73 )
   ::DrawLine( 230,  89, 236, 89 )
   ::DrawLine( 230, 106, 236, 106 )
   ::DrawText( 232,  20, "Uso do Banco", , ::nfontsizeSmall )
   ::DrawText( 232,  57, "Carteira", , ::nfontsizeSmall )
   ::DrawText( 232,  74, "Espécie", , ::nfontsizeSmall )
   ::DrawText( 232,  90, "Quantidade", , ::nfontsizeSmall )
   ::DrawText( 232, 107, "Valor", , ::nfontsizeSmall )
   ::DrawText( 232, 149, "(-) Valor do Documento", , ::nfontsizeSmall )
   ::DrawText( 235,  57, StrZero( oBoleto:nCarteira, 3 ), , ::nfontsizeNormal )
   ::DrawText( 235,  74, "REAL", , ::nfontsizeNormal )
   ::DrawText( 235, 171, Transform( oBoleto:nValor, "@E 999,999,999.99" ), , ::nfontsizeNormal )

   ::DrawLine( 236,  20, 236, 197 )
   ::DrawText( 238,  20, "Instruções de responsabilidade do BENEFICIÁRIO. Qualquer dúvida sobre este boleto, contate o BENEFICIÁRIO", , ::nfontsizeSmall )
   ::DrawText( 238, 149, "(-) Desconto/Abatimento", , ::nfontsizeSmall )
   ::DrawText( 242,  20, oBoleto:cInstrucao, , ::nfontsizeNormal )

   ::DrawLine( 242, 148, 242, 197 )

   ::DrawLine( 248, 148, 248, 197 )
   ::DrawText( 250, 149, "(+) Mora/Multa", , ::nfontsizeSmall )

   ::DrawLine( 254, 148, 254, 197 )

   ::DrawLine( 260, 148, 260, 197 )
   ::DrawText( 262, 149, "(=) Valor Cobrado", , ::nfontsizeSmall )

   ::DrawLine( 266,  20, 266, 197 )
   ::DrawText( 269,  20, oBoleto:cPagadorNome, , ::nfontsizeNormal )
   ::DrawText( 272,  20, oBoleto:cPagadorEnd1, , ::nfontsizeNormal )
   ::DrawText( 275,  20, oBoleto:cPagadorEnd2, , ::nfontsizeNormal )

   ::DrawText( 280,  20, "Pagador/Avalista", , ::nfontsizeSmall )
   ::DrawText( 280, 149, "Código de Baixa", , ::nfontsizeSmall )
   ::DrawText( 280,  42, oBoleto:cAvalista, , ::nfontsizeNormal )

   ::DrawText( 280,  18, "Banco Itaú S/A CNPJ 60.701.190", , ::nfontsizeSmall, , 90 )

   ::DrawLine( 282,  20, 282, 197 )
   ::DrawText( 284, 145, "Título processado e impresso pelo beneficiário", , ::nFontsizeSmall )
   ::DrawText( 286, 145, "Autenticação Mecânica/FICHA DE COMPENSAÇÃO", , ::nfontsizeSmall )

   ::DrawI25BarCode( 284, 20, 10, oBoleto:cBarras )

   RETURN NIL

METHOD DrawI25BarCode( nRow, nCol, nHeight, cBarCode, nOneBarWidth ) CLASS MyPDFBoletoClass

   LOCAL oZebraBarCode

   nCol         := ::ColToPdfCol( nCol )
   nRow         := ::RowToPdfRow( nRow + nHeight )
   nHeight      := ::RowToPdfRow( 0 ) - ::RowToPdfRow( nHeight )
   hb_default( @nOneBarWidth, 0.4 )

   // HPDF_Page_GSave( ::oPage )
   // HPDF_Page_Concat( ::oPage, 0.1, 0, 0, 0.1, 0, 0)

   oZebraBarCode := hb_zebra_create_itf( cBarCode, HB_ZEBRA_FLAG_WIDE2_5 )
   IF ( oZebraBarCode != NIL )
      IF hb_zebra_geterror( oZebraBarCode ) == 0
         hb_zebra_draw( oZebraBarCode, {| a, b, c, d | HPDF_Page_Rectangle( ::oPage, a, b, c, d ) }, nCol, nRow, nOneBarWidth, nHeight )
         HPDF_Page_Fill( ::oPage )
      ENDIF
   ENDIF
   hb_zebra_destroy( oZebraBarCode )
   // HPDF_Page_GRestore( ::oPage )

   RETURN NIL
