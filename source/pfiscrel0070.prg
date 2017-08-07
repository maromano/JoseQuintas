/*
PFISCREL0070 - RELATORIO PARA PRENCH DO DOPUF
1994.03 José Quintas
*/

#include "inkey.ch"

PROCEDURE pFiscRel0070

   LOCAL nOpcGeral, acTxtGeral, nOpcTemp
   MEMVAR nOpcData, acTxtData, m_Datai, m_Dataf
   MEMVAR nOpcPrinterType

   IF ! AbreArquivos( "jpempre", "jptabel", "jplfisc", "jpuf" )
      RETURN
   ENDIF
   SELECT jplfisc

   ordSetFocus( "jplfisc4" )

   nOpcData = 1
   m_datai = CToD( "" )
   m_dataf = CToD( "" )
   acTxtData := { "Todas", "Intervalo" }

   nOpcPrinterType := AppPrinterType()

   nOpcGeral = 1
   acTxtGeral := Array( 3 )

   WOpen( 5, 4, 7 + Len( acTxtGeral ), 45, "Opções disponíveis" )

   DO WHILE .T.

      acTxtGeral := { ;
         TxtImprime(), ;
         "Datas.....: " + iif( nOpcData == 1, acTxtData[ 1 ], ;
         DToC( m_datai ) + " A " + DToC( m_dataf ) ), ;
         "Saída.....: " + TxtSaida()[ nOpcPrinterType ] }

      FazAchoice( 7, 5, 6 + Len( acTxtGeral ), 44, acTxtGeral, @nOpcGeral )

      nOpcTemp := 1
      DO CASE
      CASE LastKey() == K_ESC
         EXIT

      CASE nOpcGeral == nOpcTemp++
         IF ConfirmaImpressao()
            imprime()
         ENDIF

      CASE nOpcGeral == nOpcTemp++
         DataIntervalo( nOpcGeral + 6, 25, @nOpcData, @m_Datai, @m_Dataf )

      CASE nOpcGeral == nOpcTemp
         WAchoice( nOpcGeral + 6, 25, TxtSaida(), @nOpcPrinterType, "Saída" )
         AppPrinterType( nOpcPrinterType )

      ENDCASE
   ENDDO
   WClose()

   RETURN

STATIC FUNCTION imprime()

   LOCAL oPDF, nKey
   LOCAL m_TEntTri, m_TEntIse, m_TSaiTri, m_TSaiIse, m_SEntTri, m_SEntIse, m_SSaiTri, m_SSaiIse, mUF, m_VlTri, m_VlIse
   MEMVAR nOpcPrinterType
   MEMVAR nOpcData, acTxtData, m_Datai, m_Dataf

   oPDF := PDFClass():New()
   oPDF:SetType( nOpcPrinterType )
   oPDF:Begin()

   nKey = 0
   oPDF:acHeader := { "", "", "", "", "", "" }
   oPDF:acHeader[ 1 ] = "RELATORIO PARA PREENCHIMENTO DO DOPUF"
   IF nOpcData == 1
      oPDF:acHeader[ 2 ] = ""
   ELSE
      oPDF:acHeader[ 2 ] = "Periodo: " + DToC( m_datai ) + " a " + DToC( m_dataf )
   ENDIF
   oPDF:acHeader[ 2 ] += " - VALORES SEM CENTAVOS"
   oPDF:acHeader[ 3 ] = jpempre->emNome + " - CNPJ: " + jpempre->emCnpj + ;
      " - INSCR.EST: " + jpempre->emInsEst
   oPDF:acHeader[ 4 ] = Replicate( "-", 132 )
   oPDF:acHeader[ 5 ] = "                                                     ----------VALOR DAS ENTRADAS----------- -----------VALOR DAS SAIDAS------------"
   oPDF:acHeader[ 6 ] = "--------------SIGLA DA UF E DESCRICAO--------------- -----TRIBUTADAS---- N.TRIB/ISENT/OUTRAS -----TRIBUTADAS---- N.TRIB/ISENT/OUTRAS"

   SELECT jpuf
   GOTO TOP

   STORE 0 TO m_tenttri, m_tentise, m_tsaitri, m_tsaiise
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey = Inkey()
      GrafProc()
      STORE 0 TO m_senttri, m_sentise, m_ssaitri, m_ssaiise
      mUf := jpuf->ufUf
      SELECT jplfisc
      SEEK "2" + mUf SOFTSEEK
      DO WHILE nKey != K_ESC .AND. jplfisc->lfTipLan == "2" .AND. jplfisc->lfUf == mUf .AND. ! Eof()
         nKey = Inkey()
         GrafProc()
         IF jplfisc->lfDatLan > m_dataf .AND. nOpcData == 2
            EXIT
         ENDIF
         IF jplfisc->lfDatLan < m_datai .AND. nOpcData == 2
            SKIP
            LOOP
         ENDIF
         m_vltri = jplfisc->lfIcmBas
         m_vlise = ( jplfisc->lfValCon - jplfisc->lfIcmBas )
         m_senttri = Round( m_senttri + m_vltri, 2 )
         m_sentise = Round( m_sentise + m_vlise, 2 )
         SKIP
      ENDDO
      SEEK "1" + mUf SOFTSEEK
      DO WHILE nKey != K_ESC .AND. jplfisc->lfTipLan == "1" .AND. jplfisc->lfUf == mUf .AND. ! Eof()
         nKey = Inkey()
         GrafProc()
         IF jplfisc->lfDatLan > m_dataf .AND. nOpcData == 2
            EXIT
         ENDIF
         IF jplfisc->lfDatLan < m_datai .AND. nOpcData == 2
            SKIP
            LOOP
         ENDIF
         m_vltri = jplfisc->lfIcmBas
         m_vlise = ( jplfisc->lfValCon - jplfisc->lfIcmBas )
         m_ssaitri = Round( m_ssaitri + m_vltri, 2 )
         m_ssaiise = Round( m_ssaiise + m_vlise, 2 )
         SKIP
      ENDDO
      m_senttri = Int( m_senttri )
      m_sentise = Int( m_sentise )
      m_ssaitri = Int( m_ssaitri )
      m_ssaiise = Int( m_ssaiise )
      IF m_senttri != 0 .OR. m_sentise != 0 .OR. m_ssaitri != 0 .OR. m_ssaiise != 0
         oPDF:MaxRowTest()
         Encontra( mUf, "jpuf", "numlan" )
         oPDF:DRAWTEXT( oPDF:nRow,   0, Pad( jpuf->ufDescri, 40 ) + " (" + mUf + ")" )
         oPDF:DRAWTEXT( oPDF:nRow,  53, m_senttri, PicVal( 14, 2 ) )
         oPDF:DRAWTEXT( oPDF:nRow,  73, m_sentise, PicVal( 14, 2 ) )
         oPDF:DRAWTEXT( oPDF:nRow,  93, m_ssaitri, PicVal( 14, 2 ) )
         oPDF:DRAWTEXT( oPDF:nRow, 113, m_ssaiise, PicVal( 14, 2 ) )
         m_tenttri = Round( m_tenttri + m_senttri, 2 )
         m_tentise = Round( m_tentise + m_sentise, 2 )
         m_tsaitri = Round( m_tsaitri + m_ssaitri, 2 )
         m_tsaiise = Round( m_tsaiise + m_ssaiise, 2 )
         oPDF:nRow    += 1
      ENDIF
      SELECT jpuf
      SKIP
   ENDDO
   IF oPDF:nPageNumber != 0
      oPDF:MaxRowTest()
      oPDF:DRAWLINE( oPDF:nRow,  0, oPDF:nRow, oPDF:MaxCol() )
      oPDF:nRow += 1
      oPDF:MaxRowTest()
      oPDF:DRAWTEXT( oPDF:nRow,   0, "*** TOTAIS ***" )
      oPDF:DRAWTEXT( oPDF:nRow,  53, m_tenttri, PicVal( 14, 2 ) )
      oPDF:DRAWTEXT( oPDF:nRow,  73, m_tentise, PicVal( 14, 2 ) )
      oPDF:DRAWTEXT( oPDF:nRow,  93, m_tsaitri, PicVal( 14, 2 ) )
      oPDF:DRAWTEXT( oPDF:nRow, 113, m_tsaiise, PicVal( 14, 2 ) )
      oPDF:nRow += 1
      oPDF:MaxRowTest()
      oPDF:DRAWLINE( oPDF:nRow, 0, oPDF:nRow, oPDF:MaxCol() )
      oPDF:nRow += 1
      oPDF:MaxRowTest()
   ENDIF
   oPDF:End()

   RETURN .T.
