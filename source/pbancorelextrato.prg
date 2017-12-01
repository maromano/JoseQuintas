/*
PBANCORELEXTRATO - EXTRATO BANCARIO
1989 José Quintas
*/

#include "inkey.ch"

PROCEDURE pBancoRelExtrato

   LOCAL nOpcGeral, acTxtGeral, nOpcTemp
   MEMVAR nOpcData, acTxtData, m_Datai, m_Dataf, nOpcConta, acTxtConta, nOpcTotais, acTxtTotais
   MEMVAR nOpcPrinterType

   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi", "jpbaauto", "jpbagrup", "jpbamovi" )
      RETURN
   ENDIF
   SELECT jpbagrup
   SET FILTER TO jpbagrup->bgResumo != "-"
   GOTO TOP
   SELECT jpbamovi

   nOpcData = 1
   m_DataI = Date() - 15
   m_DataF = Date() + 15
   acTxtData := { "Todas", "Intervalo" }

   nOpcConta := 1
   acTxtConta := { "Todas" }

   GOTO TOP
   DO WHILE ! Eof()
      AAdd(acTxtConta,jpbamovi->baConta)
      SEEK jpbamovi->baConta + "Z" SOFTSEEK
      // Abaixo e' pra evitar problemas com arquivo corrompido
      DO WHILE jpbamovi->baConta == acTxtConta[ Len( acTxtConta ) ] .AND. ! Eof()
         SKIP
      ENDDO
   ENDDO

   nOpcTotais = 1
   acTxtTotais := { "Normal", "Totais por data" }

   nOpcPrinterType := AppPrinterType()

   nOpcGeral = 1
   acTxtGeral := Array(5)

   WOpen( 5, 4, 7+len(acTxtGeral), 45, "Opções disponíveis" )

   DO WHILE .T.

      acTxtGeral := { ;
         TxtImprime(), ;
         "Datas.....: " + iif( nOpcData == 1, acTxtData[1], ;
         dtoc(m_DataI)+" A " + dtoc(m_DataF) ), ;
         "Conta.....: " + acTxtConta[nOpcConta], ;
         "Totais....: " + acTxtTotais[ nOpcTotais ], ;
         "Saída.....: " + TxtSaida()[ nOpcPrinterType ] }

      FazAchoice( 7, 5, 6+len(acTxtGeral), 44, acTxtGeral, @nOpcGeral )

      nOpcTemp := 1
      DO CASE
      CASE lastkey() == K_ESC
         EXIT

      CASE nOpcGeral == nOpcTemp++
         IF ConfirmaImpressao()
            Imprime()
         ENDIF

      CASE nOpcGeral == nOpcTemp++
         DataIntervalo(nOpcGeral+6,25,@nOpcData,@m_Datai,@m_Dataf)

      CASE nOpcGeral == nOpcTemp++
         WAchoice(nOpcGeral+6,25,acTxtConta,@nOpcConta,"Conta")

      CASE nOpcGeral == nOpcTemp++
         WAchoice( nOpcGeral+6, 25, acTxtTotais, @nOpcTotais, "Imprime Totais" )

      CASE nOpcGeral == nOpcTemp
         WAchoice( nOpcGeral+6, 25, TxtSaida(), @nOpcPrinterType, "Saída" )
         AppPrinterType( nOpcPrinterType )

      ENDCASE
   ENDDO
   WClose()
   CLOSE DATABASES

   RETURN

STATIC FUNCTION Imprime()

   LOCAL oPDF, cTxt, m_SaiDia, m_SdMem, m_Saldo, m_VlMov, m_EntDia, nKey, mbaConta, m_DtBco, m_DtEmi, m_Aplic
   MEMVAR nOpcData, acTxtData, m_Datai, m_Dataf, nOpcTotais, acTxtTotais, nOpcPrinterType

   oPDF := PDFClass():New()
   oPDF:SetType( nOpcPrinterType )
   oPDF:Begin()
   nKey = 0

   AAdd( oPDF:acHeader, "" )
   oPDF:acHeader[1] := "EXTRATO DAS CONTAS" + iif( nOpcTotais == 1, "", " - COM TOTAIS POR DATA" )
   AAdd( oPDF:acHeader, "" )
   IF nOpcData == 2
      oPDF:acHeader[ 2 ] = ( "Datas: " + Dtoc( m_DataI ) + " a " + Dtoc( m_DataF ) )
   ENDIF
   AAdd( oPDF:acHeader, "DT.BANCO DT.EMISS --RESUMO-- ---------------HISTORICO" + "----------------- -----ENTRADAS---- ------SAIDAS----- " + "------SALDO------ US$" )

   GOTO TOP
   DO WHILE nKey != K_ESC .AND. ! eof()
      grafproc()
      nKey = Inkey()
      DO CASE
      CASE ! Filtro()
         SKIP
         LOOP
      ENDCASE
      oPDF:MaxRowTest()
      oPDF:DrawText( oPDF:nRow, 0, "CONTA:" + jpbamovi->baConta + iif( jpbamovi->baAplic != "S", "", " - APLICACAO" ) )
      oPDF:nRow += 2
      oPDF:MaxRowTest()
      mbaConta := jpbamovi->baConta
      m_Aplic := jpbamovi->baAplic
      m_Saldo := 0
      m_SdMem := .F.
      m_DtBco := jpbamovi->baDatBan
      m_DtEmi := jpbamovi->baDatEmi
      m_EntDia := m_SaiDia := 0
      DO WHILE nKey != K_ESC .AND. jpbamovi->baConta == mbaConta .AND. jpbamovi->baAplic == m_Aplic .AND. ! Eof()
         grafproc()
         nKey := Inkey()
         IF ! m_SdMem
            m_Saldo := jpbamovi->basaldo
         ENDIF
         DO CASE
         CASE ! Filtro()
            SKIP
            LOOP
         ENDCASE
         oPDF:MaxRowTest()
         m_VlMov  := jpbamovi->baValor
         IF ! m_SdMem
            m_SdMem := .T.
            m_Saldo := m_Saldo - m_VlMov // Deduz para saldo anterior
            oPDF:DrawText( oPDF:nRow, 50, "SALDO INICIAL:" )
            oPDF:DrawText( oPDF:nRow, 107, Transform( m_Saldo, PicVal(13,2) ) )
            oPDF:nRow += 1
         ENDIF
         cTxt := iif( jpbamovi->baDatBan == Stod( "29991231" ), Space(8), Dtoc( jpbamovi->baDatBan ) )
         cTxt += " " + Dtoc( jpbamovi->baDatEmi )
         cTxt += " " + jpbamovi->baResumo
         cTxt += " " + Pad( Trim( jpbamovi->baHist ), Len( jpbamovi->baHist ), "." )
         cTxt += " " + Transform( iif( jpbamovi->baValor > 0, jpbamovi->baValor, 0 ), PicVal(13,2) )
         cTxt += " " + Transform( iif( jpbamovi->baValor < 0, -jpbamovi->baValor, 0 ), PicVal(13,2) )
         m_VlMov  := jpbamovi->baValor
         m_Saldo  += m_VlMov
         m_EntDia += iif( m_VlMov > 0, m_VlMov, 0 )
         m_SaiDia += iif( m_VlMov < 0, -m_VlMov, 0 )
         cTxt += " " + Transform( m_Saldo, PicVal(13,2) )
         oPDF:DrawText( oPDF:nRow, 0, cTxt )
         oPDF:nRow++
         SKIP
         IF nOpcTotais == 2 .AND. ( jpbamovi->baDatBan != m_DtBco .OR. ( jpbamovi->baDatBan == Stod( "29991231" ) .AND. jpbamovi->baDatEmi!= m_DtEmi ) )
            oPDF:DrawText( oPDF:nRow, 50, "Totais do dia -----> " +  Transform( m_EntDia, PicVal(13,2) ) + " " + Transform( m_SaiDia, PicVal(13,2) ) )
            m_EntDia := 0
            m_SaiDia := 0
            m_DtBco  := jpbamovi->baDatBan
            m_DtEmi  := jpbamovi->baDatEmi
            oPDF:nRow    += 2
         ENDIF
      ENDDO
      oPDF:DrawLine( oPDF:nRow - 0.5, 0, oPDF:nRow - 0.5, oPDF:MaxCol() )
      oPDF:nRow += 2
   ENDDO
   oPDF:End()

   RETURN .T.

STATIC FUNCTION Filtro()

   MEMVAR nOpcData, m_Datai, m_Dataf, nOpcConta, acTxtConta

   DO CASE
   CASE jpbamovi->baValor == 0
      RETURN .F.
   CASE jpbamovi->baDatEmi == Stod( "29991231" )
      RETURN .F.
   CASE jpbamovi->baConta != acTxtConta[ nOpcConta ] .AND. nOpcConta != 1
      RETURN .F.
   CASE nOpcData == 1
      RETURN .T.
   CASE Dtos( jpbamovi->baDatBan ) < Dtos( m_DataI ) .AND. jpbamovi->baDatBan != Stod( "29991231" )
      RETURN .F.
   CASE Dtos( jpbamovi->baDatBan ) > Dtos( m_DataF ) .AND. jpbamovi->baDatBan != Stod( "29991231" )
      RETURN .F.
   CASE dtos( jpbamovi->baDatEmi ) > Dtos( m_DataF )
      RETURN .F.
   ENDCASE

   RETURN .T.
