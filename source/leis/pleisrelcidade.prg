/*
PLEISRELCIDADE - LISTAGEM DE CIDADES/PAISES
1987.02.07 José Quintas
*/

#include "inkey.ch"

PROCEDURE pLeisRelCidade

   LOCAL GetList := {}, nOpcTemp, nOpcGeral, acTxtGeral
   MEMVAR acTxtDeAte, nOpcDeAte, mcinumlani, mcinumlanf, nOpcPrinterType
   PRIVATE acTxtDeAte, nOpcDeAte, mcinumlani, mcinumlanf, nOpcPrinterType

   IF ! AbreArquivos( "jpcidade" )
      RETURN
   ENDIF
   SELECT jpcidade

   nOpcDeAte  := 1
   mcinumlani := Space(6)
   mcinumlanf := Space(6)
      DECLARE acTxtDeAte := { "Todos", "Intervalo" }

   nOpcPrinterType := AppPrinterType()

   nOpcGeral  := 1
   acTxtGeral := Array(4)

   WOpen( 5, 4, 7 + Len( acTxtGeral ), 45, "Opções disponíveis" )

   DO WHILE .T.
      acTxtGeral := { ;
         TxtImprime(), ;
         TxtSalva(), ;
         "Intervalo : " + iif( nOpcDeAte == 1, acTxtDeAte[ 1 ], ;
            mcinumlani + " a " + mcinumlanf ), ;
         "Saída.....: " + TxtSaida()[ nOpcPrinterType ] }

      FazAchoice( 7, 5, 6 + Len( acTxtGeral ), 44, acTxtGeral, @nOpcGeral )

      nOpcTemp := 1

      DO CASE
      CASE lastkey() == K_ESC
         EXIT

      CASE nOpcGeral == nOpcTemp++
         IF ConfirmaImpressao()
            imprime()
         ENDIF

      CASE nOpcGeral == nOpcTemp++

      CASE nOpcGeral == nOpcTemp++
         WOpen( nOpcGeral + 6, 25, nOpcGeral + 10, 65, "Intervalo" )
         DO WHILE .T.
            FazAchoice( nOpcGeral + 8, 26, nOpcGeral + 9, 64, acTxtDeAte, @nOpcDeAte )
            IF lastkey() != K_ESC .AND. nOpcDeAte == 2
               WOpen( nOpcGeral + 9, 45, nOpcGeral + 13, 65, "Código" )
               @ nOpcGeral + 11, 47 GET mcinumlani PICTURE "@K 999999"
               @ nOpcGeral + 12, 47 GET mcinumlanf PICTURE "@K 999999"
               Mensagem( "Digite código da cidade, F9 pesquisa, ESC sai" )
               READ
               WClose()
               IF lastkey() == K_ESC
                  LOOP
               ENDIF
            ENDIF
            EXIT
         ENDDO
         WClose()

      CASE nOpcGeral == nOpcTemp
         WAchoice( nOpcGeral + 6, 25, TxtSaida(), @nOpcPrinterType, "Saída" )
         AppPrinterType( nOpcPrinterType )

      ENDCASE
   ENDDO
   WClose()
   CLOSE DATABASES

   RETURN

STATIC FUNCTION imprime()

   LOCAL oPDF, nKey
   MEMVAR acTxtDeAte, nOpcDeAte, mcinumlani, mcinumlanf, nOpcPrinterType

   oPDF := PDFClass():New()
   oPDF:SetType( nOpcPrinterType )
   oPDF:Begin()

   nKey = 0

   oPDF:acHeader := { "","",""}
   oPDF:acHeader[ 1 ] = "LISTAGEM DO CADASTRO DE CIDADES/PAISES"
   oPDF:acHeader[ 3 ] = Space(43) + "CODIGO  NOME-------------------------------------  UF"
   IF nOpcDeAte == 1
      GOTO TOP
   ELSE
      oPDF:acHeader[ 2 ] = "de: " + mcinumlani + " ate: " + mcinumlanf
      SEEK mcinumlani
   ENDIF

   DO WHILE nKey != K_ESC .AND. ! eof()
      GrafProc()
      nKey = Inkey()
      DO CASE
      CASE jpcidade->ciNumLan > mcinumlanf .AND. nOpcDeAte == 2
          EXIT
      ENDCASE
      oPDF:MaxRowTest()
      oPDF:DrawText( oPDF:nRow, 44, jpcidade->ciNumLan )
      oPDF:DrawText( oPDF:nRow, 52, jpcidade->cinome )
      oPDF:DrawText( oPDF:nRow, 96, jpcidade->ciuf )
      oPDF:nRow += 1
      SKIP
   ENDDO
   oPDF:End()

   RETURN .T.
