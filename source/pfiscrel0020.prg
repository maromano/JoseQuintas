/*
PFISCREL0020 - TERMOS DE ABERTURA/ENCERRAMENTO
1993.09 José Quintas
*/

#include "inkey.ch"

PROCEDURE pFiscRel0020

   LOCAL nOpcTemp, nOpcMenu, acTxtMenu, acOpcDefault, GetList := {}, nOpcSalva
   MEMVAR nOpcLivro, acTxtLivro, nNumLivro, nQtdFolhas, dDataInicial, dDataFinal, nOpcPrinterType
   PRIVATE nOpcLivro, acTxtLivro, nNumLivro, nQtdFolhas, dDataInicial, dDataFinal

   IF ! AbreArquivos( "jptabel", "jpempre", "jpuf" )
      RETURN
   ENDIF
   SELECT jpempre

   acOpcDefault := LeCnfRel()

   nNumLivro    := 0
   nQtdFolhas   := 0
   dDataInicial := Ctod( "" )
   dDataFinal   := Ctod( "" )

   nOpcSalva = 2

   nOpcLivro := iif( acOpcDefault[ 1 ] > 6, 1, acOpcDefault[ 1 ] )
      acTxtLivro := { "Livro Diario", "Livro Registro de Entradas", "Livro Registro de Saidas", "Livro de Apuracao de ICMS", ;
         "Livro de Apuracao de IPI", "Livro de Producao e Controle de Estoque" }

   nOpcPrinterType := AppPrinterType()

   nOpcMenu = 1
      acTxtMenu := Array( 4 )

   WOpen( 5, 4, 7 + Len( acTxtMenu ), 45, "Opções disponíveis" )

   DO WHILE .T.

      acTxtMenu := { ;
         TxtImprime(), ;
         TxtSalva(), ;
         "Livro.....: " + acTxtLivro[ nOpcLivro ], ;
         "Saída.....: " + TxtSaida()[ nOpcPrinterType ] }

      FazAchoice( 7, 5, 6 + Len( acTxtMenu ), 44, acTxtMenu, @nOpcMenu )

      nOpcTemp = 1
      DO CASE
      CASE lastkey() == K_ESC
         EXIT

      CASE nOpcMenu == nOpcTemp++
         wOpen( 5, 5, 12, 40, "Livro, Páginas e Datas" )
         @  7, 7 SAY "Livro......:" GET nNumLivro    PICTURE "9999" VALID nNumLivro > 0
         @  8, 7 SAY "Qt.Folhas..:" GET nQtdFolhas   PICTURE "9999" VALID nQtdFolhas > 2
         @  9, 7 SAY "Dt.Inicial.:" GET dDataInicial VALID ! Empty( dDataInicial )
         @ 10, 7 SAY "Dt.Final...:" GET dDataFinal   VALID ! Empty( dDataFinal )
         READ
         wClose()
//         Mensagem( "Número do livro: " )
//         @ Row(), Col() GET  nNumLivro PICTURE "99999" VALID nNumLivro > 0
//         READ
//         Mensagem( "Quantidade de folhas: " )
//         @ Row(), Col() GET  nQtdFolhas PICTURE "999" VALID nQtdFolhas > 2
//         READ
//           Mensagem( "Datas dos termos: " )
//         @ Row(), Col() GET dDataInicial VALID ! Empty( dDataInicial )
//         @ Row(), Col() + 2 GET dDataFinal VALID ! Empty( dDataFinal )
//         READ
//         Mensagem()
         IF LastKey() == K_ESC
            LOOP
         ENDIF
         IF ConfirmaImpressao()
            Imprime()
         ENDIF

      CASE nOpcMenu == nOpcTemp++
         wAchoice( nOpcMenu + 6, 25, TxtConf(), @nOpcSalva, TxtSalva() )

      CASE nOpcMenu == nOpcTemp++
         WAchoice( nOpcMenu+6, 25, acTxtLivro, @nOpcLivro, "Modelo de Livro" )

      CASE nOpcMenu == nOpcTemp
         WAchoice( nOpcMenu+6, 25, TxtSaida(), @nOpcPrinterType, "Saída" )
         AppPrinterType( nOpcPrinterType )

      ENDCASE
   ENDDO
   WClose()

   RETURN

STATIC FUNCTION Imprime()

   MEMVAR cNomeLivro, acTxtLivro, nOpcLivro, dDataInicial, dDataFinal
   MEMVAR oPDF, nOpcPrinterType
   PRIVATE oPDF

   oPDF := PDFClass():New()
   oPDF:SetType( nOpcPrinterType )
   oPDF:Begin()

   cNomeLivro := acTxtLivro[ nOpcLivro ]

   TermoFiscalEntradasSaidas( "ABERTURA", dDataInicial, cNomeLivro )
   TermoFiscalEntradasSaidas( "ENCERRAMENTO", dDataFinal, cNomeLivro )

   oPDF:End()

   RETURN NIL

STATIC FUNCTION TermoFiscalEntradasSaidas( mAberturaEncerramento, dDataAssinatura, cNomeLivro )

   LOCAL cTexto, nMargem, nPos
   MEMVAR nNumLivro, oPDF, nQtdFolhas

   Encontra( jpempre->emUf, "jpuf", "numlan" )
   cTexto = "O presente livro contem " + StrZero( nQtdFolhas, 3 ) + " folhas numeradas eletronicamente de 001 a " + StrZero( nQtdFolhas, 3 ) + " que " + ;
             iif( mAberturaEncerramento == "ABERTURA", "servira", "serviu" ) + " de " + cNomeLivro + " numero " + StrZero( nNumLivro, 6 ) + " da sociedade " + ;
             Trim( jpempre->emNome ) + ", estabelecida a " + Trim( jpempre->emEndereco ) + ", em " + Trim( jpempre->emCidade ) + ", " + jpempre->emUf + ;
             ", registrada "
   cTexto = cTexto + Trim( jpempre->emLocReg ) + " do estado de " + Trim( jpuf->ufDescri )
   cTexto = cTexto + ", sob numero " + Trim( jpempre->emNumReg ) + ", em " + dtoc( jpempre->emDatReg ) + ", no CNPJ numero " + Trim( jpempre->emCnpj ) + ;
             " e inscricao estadual numero " + Trim( jpempre->emInsEst ) + "."

   oPDF:acHeader := {Upper( cNomeLivro ),""}
   IF mAberturaEncerramento == "ABERTURA"
      oPDF:nPageNumber := 0
   ELSE
      oPDF:nPageNumber := nQtdFolhas - 1
   ENDIF
   oPDF:PageHeader()
   oPDF:DrawText( oPDF:nRow + 4, 0, PadC( "TERMO DE " + mAberturaEncerramento, oPDF:MaxCol() + 1 ) )

   oPDF:nRow += 15
   DO WHILE .T.
      IF Len( cTexto ) < 60
         oPDF:DrawText( oPDF:nRow, 0, Padc( cTexto, oPDF:MaxCol() + 1 ) )
         oPDF:nRow += 2
         EXIT
      ELSE
         nPos = Rat( " ", Left( cTexto, oPDF:MaxCol() - 20 ) )
         oPDF:DrawText( oPDF:nRow, 0, padc( Trim( Substr( cTexto, 1, nPos ) ), oPDF:MaxCol() + 1 ) )
         cTexto  = lTrim( Substr( cTexto, nPos ) )
         oPDF:nRow += 2
      ENDIF
   ENDDO

   oPDF:DrawText( oPDF:nRow + 4, 0, padc( Trim( jpempre->emCidade ) + ", " + Extenso( dDataAssinatura ), oPDF:MaxCol() + 1 ) )

   nMargem := Int( ( oPDF:MaxCol() + 1 - 80 ) / 2 )
   oPDF:DrawText( oPDF:nRow + 14, nMargem + 5, Replicate( "-", 30 ) )
   oPDF:DrawText( oPDF:nRow + 14, nMargem + 5 + 40, Replicate( "-", 30 ) )
   oPDF:DrawText( oPDF:nRow + 15, nMargem, padc( Trim( jpempre->emTitular ), 40 ) )
   oPDF:DrawText( oPDF:nRow + 15, nMargem + 40, padc( Trim( jpempre->emContador ), 40 ) )
   oPDF:DrawText( oPDF:nRow + 16, nMargem, padc( Trim( jpempre->emCarTit), 40 ) )
   oPDF:DrawText( oPDF:nRow + 16, nMargem + 40, padc( Trim( jpempre->emCarCon ), 40 ) )
   oPDF:DrawText( oPDF:nRow + 17, nMargem, Padc( "CPF:" + jpempre->emCpfTit, 40 ) )
   oPDF:DrawText( oPDF:nRow + 17, nMargem + 40, Padc( "CRC:" + Trim( jpempre->emCrcCon ) + "/" + jpempre->emUfCrc + " - " + "CPF:" + jpempre->emCpfCon, 40) )

   //IF mAberturaEncerramento != "ABERTURA"
      //oPDF:PageFooter()
   //ENDIF

   RETURN NIL
