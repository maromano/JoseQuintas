/*
PFISCREL0060 - REL.CONFERENCIA LFISCAL
2005.06 José Quintas
*/

#include "inkey.ch"

PROCEDURE pFiscRel0060

   LOCAL nOpcGeral, acTxtGeral
   MEMVAR nOpcData, acTxtData, nOpcOrdem, acTxtOrdem, m_Datai, m_Dataf, nOpcEntSai, acTxtEntSai
   MEMVAR nOpcPrinterType

   IF ! AbreArquivos( "jptabel", "jpempre", "jpcadas", "jplfisc" )
      RETURN
   ENDIF
   SELECT jplfisc

   nOpcData = 1
   m_Datai = CToD( "" )
   m_Dataf = CToD( "" )
   acTxtData := { "Todas", "Intervalo" }

   nOpcOrdem := 1
   acTxtOrdem := { "Data Lçto", "CFOP", "UF", "Cli/Forn", "Docto", "Lançamento" }

   nOpcEntSai := 1
   acTxtEntSai := { "Entrada/Saída", "Entrada", "Saída" }

   nOpcPrinterType := AppPrinterType()

   nOpcGeral = 1
   acTxtGeral := Array( 6 )

   WOpen( 5, 4, 7 + Len( acTxtGeral ), 45, "Opções disponíveis" )

   DO WHILE .T.

      acTxtGeral := { ;
         TxtImprime(), ;
         TxtSalva(), ;
         "Datas.....: " + iif( nOpcData == 1, acTxtData[ 1 ], ;
         DToC( m_Datai ) + " A " + DToC( m_Dataf ) ), ;
         "Ordem.....: " + acTxtOrdem[ nOpcOrdem ], ;
         "Movimento.: " + acTxtEntSai[ nOpcEntSai ], ;
         "Saída.....: " + txtSaida()[ nOpcPrinterType ] }

      FazAchoice( 7, 5, 6 + Len( acTxtGeral ), 44, acTxtGeral, @nOpcGeral )

      DO CASE
      CASE LastKey() == K_ESC
         EXIT

      CASE nOpcGeral == 1
         IF ConfirmaImpressao()
            imprime()
         ENDIF

      CASE nOpcGeral == 2

      CASE nOpcGeral == 3
         DataIntervalo( nOpcGeral + 6, 25, @nOpcData, @m_Datai, @m_Dataf )

      CASE nOpcGeral == 4
         WAchoice( nOpcGeral + 6, 25, acTxtOrdem, @nOpcOrdem, "Ordem" )

      CASE nOpcGeral == 5
         WAchoice( nOpcGeral + 6, 25, acTxtEntSai, @nOpcEntSai, "Tipo Movto" )

      CASE nOpcGeral == 6
         WAchoice( nOpcGeral + 6, 25, txtSaida(), @nOpcPrinterType, "Saída" )
         AppPrinterType( nOpcPrinterType )

      ENDCASE
   ENDDO
   WClose()

   RETURN

STATIC FUNCTION imprime()

   LOCAL oPDF, nKey
   LOCAL nTotValCon, nTotIcmBas, nTotIcmVal, nTotIcmIse, nTotIcmOut, nTotIpiBas, nTotIpiVal, nTotIpiIse, nTotIpiOut
   LOCAL m_IcmIse, m_IpiIse
   MEMVAR nOpcData, acTxtData, nOpcOrdem, acTxtOrdem, m_Datai, m_Dataf, nOpcEntSai, acTxtEntSai, nOpcPrinterType

   oPDF := PDFClass():New()
   oPDF:SetType( nOpcPrinterType )
   oPDF:Begin()
   oPDF:acHeader := { "", "", "", "", "", "" }
   oPDF:acHeader[ 1 ] := "LISTAGEM DE CONFERENCIA - LIVROS FISCAIS"
   oPDF:acHeader[ 2 ] := "Periodo: " + DToC( m_Datai ) + " a " + DToC( m_Dataf )
   oPDF:acHeader[ 3 ] := "         ------------- DOCUMENTOS FISCAIS-------------               --CODIFICACAO-- --------ICMS/IPI VALORES FISCAIS--------"
   oPDF:acHeader[ 4 ] := "DATA DO       SERIE               DATA    CLI/     UF       VALOR                     ICMS COD BASE DE CALC.      IMPOSTO"
   oPDF:acHeader[ 5 ] := "LANCTO.  ESP. SUB-S    NUMERO     NF ENT  FORN. LANCTO    CONTABIL   NUM.LCTO FISCAL IPI  (A)  VL.OPERACAO  ALIQ  LANCADO     OBS."
   oPDF:acHeader[ 6 ] := "-------- ---- ----- ------------ -------- ----- ------ ------------- -------- ------ ---- --- ------------- ---- ------------ -----"

   nKey := 0

   STORE 0 TO nTotValCon, nTotIcmBas, nTotIcmVal, nTotIcmIse, nTotIcmOut, nTotIpiBas, nTotIpiVal, nTotIpiIse, nTotIpiOut

   DO CASE
   CASE nOpcOrdem == 1
      ordSetFocus( "jplfisc3" )
   CASE nOpcOrdem == 2
      ordSetFocus( "jplfisc2" )
   CASE nOpcOrdem == 3
      ordSetFocus( "jplfisc4" )
   CASE nOpcOrdem == 4
      ordSetFocus( "jplfisc5" )
   CASE nOpcOrdem == 5
      ordSetFocus( "jplfisc6" )
   CASE nOpcOrdem == 6
      ordSetFocus( "numlan" )
   ENDCASE

   GOTO TOP
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey = Inkey()
      GrafProc()
      DO CASE
      CASE jplfisc->lfTipLan == "1" .AND. nOpcEntSai == 2
         SKIP
         LOOP
      CASE jplfisc->lfTipLan == "2" .AND. nOpcEntSai == 3
         SKIP
         LOOP
      CASE nOpcData == 2 .AND. ( jplfisc->lfDatLan < m_Datai .OR. jplfisc->lfDatLan > m_Dataf )
         SKIP
         LOOP
      ENDCASE
      oPDF:MaxRowTest( 1 )
      oPDF:DRAWTEXT( oPDF:nRow,   0, jplfisc->lfDatLan )
      oPDF:DRAWTEXT( oPDF:nRow,   9, jplfisc->lfModFis )
      oPDF:DRAWTEXT( oPDF:nRow,  14, jplfisc->lfDocSer )
      oPDF:DRAWTEXT( oPDF:nRow,  20, jplfisc->lfDocIni )
      IF ! Empty( jplfisc->lfDocFim )
         oPDF:DRAWTEXT( oPDF:nRow, oPDF:nCol, " a" )
         oPDF:nRow += 1
         oPDF:DRAWTEXT( oPDF:nRow, 20, jplfisc->lfDocFim )
      ENDIF
      oPDF:DRAWTEXT( oPDF:nRow,  33, jplfisc->lfDatDoc )
      oPDF:DRAWTEXT( oPDF:nRow,  42, jplfisc->lfCliFor )
      oPDF:DRAWTEXT( oPDF:nRow,  50, jplfisc->lfUf )
      oPDF:DRAWTEXT( oPDF:nRow,  55, jplfisc->lfValCon, PicVal( 11, 2 ) )
      oPDF:DRAWTEXT( oPDF:nRow,  71, jplfisc->lfNumLan )
      oPDF:DRAWTEXT( oPDF:nRow,  79, jplfisc->lfCfOp )
      m_IcmIse = Max( jplfisc->lfValCon - jplfisc->lfIcmBas - jplfisc->lfIcmOut, 0 )
      m_IpiIse = Max( jplfisc->lfValCon - jplfisc->lfIpiBas - jplfisc->lfIpiOut - jplfisc->lfIpiVal, 0 )
      oPDF:DRAWTEXT( oPDF:nRow,  85, "ICMS" )
      IF jplfisc->lfIcmBas != 0
         oPDF:DRAWTEXT( oPDF:nRow,  91, "1" )
         oPDF:DRAWTEXT( oPDF:nRow,  94, jplfisc->lfIcmBas, PicVal( 11, 2 ) )
         oPDF:DRAWTEXT( oPDF:nRow, 108, jplfisc->lfIcmAli, iif( Int( jplfisc->lfIcmAli * 100 ) / 100 == jplfisc->lfIcmAli, "@E 99.99", "@E 99.9999" ) )
         oPDF:DRAWTEXT( oPDF:nRow, 113, jplfisc->lfIcmVal, PicVal( 11, 2 ) )
         oPDF:nRow += 1
         oPDF:MaxRowTest()
      ENDIF
      IF m_IcmIse != 0
         oPDF:DRAWTEXT( oPDF:nRow,  91, "2" )
         oPDF:DRAWTEXT( oPDF:nRow,  94, m_IcmIse, PicVal( 11, 2 ) )
         oPDF:nRow += 1
         oPDF:MaxRowTest()
      ENDIF
      IF jplfisc->lfIcmOut != 0
         oPDF:DRAWTEXT( oPDF:nRow,  91, "3" )
         oPDF:DRAWTEXT( oPDF:nRow,  94, jplfisc->lfIcmOut, PicVal( 11, 2 ) )
         oPDF:nRow += 1
         oPDF:MaxRowTest()
      ENDIF
      IF jplfisc->lfIcmVal == 0 .AND. m_IcmIse == 0 .AND. jplfisc->lfIcmOut == 0
         oPDF:nRow += 1
         oPDF:MaxRowTest()
      ENDIF
      IF jplfisc->lfIpiBas != 0 .OR. jplfisc->lfIpiVal != 0 .OR. m_IpiIse != 0 .OR. jplfisc->lfIpiOut != 0
         oPDF:DRAWTEXT( oPDF:nRow, 85, "IPI" )
         IF jplfisc->lfIpiVal != 0
            oPDF:DRAWTEXT( oPDF:nRow, 91, "1" )
            oPDF:DRAWTEXT( oPDF:nRow, 94, jplfisc->lfIpiBas, PicVal( 11, 2 ) )
            oPDF:DRAWTEXT( oPDF:nRow, 113, jplfisc->lfIpiVal, PicVal( 11, 2 ) )
            oPDF:nRow += 1
            oPDF:MaxRowTest()
         ENDIF
         IF m_IpiIse != 0
            oPDF:DRAWTEXT( oPDF:nRow, 91, "2" )
            oPDF:DRAWTEXT( oPDF:nRow, 94, m_IpiIse, PicVal( 11, 2 ) )
            oPDF:nRow += 1
            oPDF:MaxRowTest()
         ENDIF
         IF jplfisc->lfIpiOut != 0
            oPDF:DRAWTEXT( oPDF:nRow, 91, "3" )
            oPDF:DRAWTEXT( oPDF:nRow, 113, jplfisc->lfIpiOut, PicVal( 11, 2 ) )
            oPDF:nRow += 1
            oPDF:MaxRowTest()
         ENDIF
         IF jplfisc->lfIpiVal == 0 .AND. m_IpiIse == 0 .AND. jplfisc->lfIpiOut == 0
            oPDF:nRow += 1
            oPDF:MaxRowTest()
         ENDIF
      ENDIF
      IF ! Empty( jplfisc->lfObs )
         oPDF:DRAWTEXT( oPDF:nRow, oPDF:MaxCol() - Len( Trim( jplfisc->lfObs ) ), Trim( jplfisc->lfObs ) )
         oPDF:nRow += 1
         oPDF:MaxRowTest()
      ENDIF
      nTotIcmBas := Round( nTotIcmBas + jplfisc->lfIcmBas, 2 )
      nTotIcmVal := Round( nTotIcmVal + jplfisc->lfIcmVal, 2 )
      nTotValCon := Round( nTotValCon + jplfisc->lfValCon, 2 )
      nTotIcmIse := Round( nTotIcmIse + m_IcmIse, 2 )
      nTotIcmOut := Round( nTotIcmOut + jplfisc->lfIcmOut, 2 )
      nTotIpiBas := Round( nTotIpiBas + jplfisc->lfIpiBas, 2 )
      nTotIpiVal := Round( nTotIpiVal + jplfisc->lfIpiVal, 2 )
      nTotIpiIse := Round( nTotIpiIse + m_IpiIse, 2 )
      nTotIpiOut := Round( nTotIpiOut + jplfisc->lfIpiOut, 2 )
      oPDF:nRow     += 1
      SKIP
   ENDDO
   oPDF:MaxRowTest()
   oPDF:DRAWLINE( oPDF:nRow, oPDF:nRow, oPDF:MaxCol() )
   oPDF:DRAWTEXT( oPDF:nRow, 33, "TOTAIS" )
   oPDF:DRAWTEXT( oPDF:nRow, 55, nTotValCon, PicVal( 11, 2 ) )
   oPDF:DRAWTEXT( oPDF:nRow, 85, "ICMS" )
   IF nTotIcmBas != 0
      oPDF:DRAWTEXT( oPDF:nRow, 91, "1" )
      oPDF:DRAWTEXT( oPDF:nRow, 94, nTotIcmBas, PicVal( 11, 2 ) )
      oPDF:DRAWTEXT( oPDF:nRow, 113, nTotIcmVal, PicVal( 11, 2 ) )
      oPDF:nRow += 1
      oPDF:MaxRowTest()
   ENDIF
   IF nTotIcmIse != 0
      oPDF:DRAWTEXT( oPDF:nRow, 91, "2" )
      oPDF:DRAWTEXT( oPDF:nRow, 94, nTotIcmIse, PicVal( 11, 2 ) )
      oPDF:nRow += 1
      oPDF:MaxRowTest()
   ENDIF
   IF nTotIcmOut != 0
      oPDF:DRAWTEXT( oPDF:nRow, 91, "3" )
      oPDF:DRAWTEXT( oPDF:nRow, 94, nTotIcmOut, PicVal( 11, 2 ) )
      oPDF:nRow += 1
      oPDF:MaxRowTest()
   ENDIF
   IF nTotIcmBas == 0 .AND. nTotIcmIse == 0 .AND. nTotIcmOut == 0
      oPDF:nRow += 1
      oPDF:MaxRowTest()
   ENDIF
   IF nTotIpiBas != 0 .OR. nTotIpiVal != 0 .OR. nTotIpiIse != 0 .OR. nTotIpiOut != 0
      oPDF:DRAWTEXT( oPDF:nRow, 85, "IPI" )
      IF nTotIpiBas != 0
         oPDF:DRAWTEXT( oPDF:nRow, 91, "1" )
         oPDF:DRAWTEXT( oPDF:nRow, 94, nTotIpiBas, PicVal( 11, 2 ) )
         oPDF:DRAWTEXT( oPDF:nRow, 113, nTotIpiVal, PicVal( 11, 2 ) )
         oPDF:nRow += 1
         oPDF:MaxRowTest()
      ENDIF
      IF nTotIpiIse != 0
         oPDF:DRAWTEXT( oPDF:nRow, 91, "2" )
         oPDF:DRAWTEXT( oPDF:nRow, 94, nTotIpiIse, PicVal( 11, 2 ) )
         oPDF:nRow += 1
         oPDF:MaxRowTest()
      ENDIF
      IF nTotIpiOut != 0
         oPDF:DRAWTEXT( oPDF:nRow, 91, "3" )
         oPDF:DRAWTEXT( oPDF:nRow, 94, nTotIpiOut, PicVal( 11, 2 ) )
         oPDF:nRow += 1
         oPDF:MaxRowTest()
      ENDIF
      IF nTotIpiBas == 0 .AND. nTotIpiIse == 0 .AND. nTotIpiOut == 0
         oPDF:nRow += 1
      ENDIF
   ENDIF
   oPDF:End()

   RETURN .T.
