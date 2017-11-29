/*
PBANCORELCCUSTO - LISTAGEM POR GRUPO/RESUMO
1993.04 José Quintas
*/

#include "inkey.ch"

PROCEDURE pBancoRelCCusto

   LOCAL nOpcGeral, acTxtGeral, nOpcTemp, nOpcConf, anDefault
   MEMVAR nOpcData, acTxtData, m_Datai, m_Dataf, nOpcEmiBan, nOpcDetalhe, acTxtDetalhe, nOpcOrdem, acTxtOrdem, acTxtEmiBan, nOpcPrinterType

   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi", "jpbaauto", "jpbagrup", "jpbamovi" )
      RETURN
   ENDIF
   SELECT jpbagrup
   SET FILTER TO jpbagrup->bgResumo != "-"
   GOTO TOP
   SELECT jpbamovi

   anDefault := LeCnfRel()
   nOpcConf  := 2
   nOpcData  := 1
   m_Datai  := m_Dataf := Ctod( "" )
   acTxtData := { "Todas", "Intervalo" }
   nOpcEmiBan := iif( anDefault[ 1 ] > 2, 1, anDefault[ 1 ] )
   acTxtEmiBan:= { "Data de emissão", "Data do Banco" }
   nOpcOrdem  := iif( anDefault[ 2 ] > 2, 1, anDefault[ 2 ] )
   acTxtOrdem := { "Resumo", "Grupo+Resumo" }
   nOpcDetalhe   := iif( anDefault[ 3 ] > 2, 1,anDefault[ 3 ] )
   acTxtDetalhe := { "Analítico", "Sintético" }
   nOpcPrinterType := AppPrinterType()
   nOpcGeral   := 1
   acTxtGeral := Array( 7 )
   WOpen( 5, 4, 7 + Len( acTxtGeral ), 45, "Opções Disponíveis" )
   DO WHILE .T.
      acTxtGeral := { ;
         TxtImprime(), ;
         TxtSalva(), ;
         "Referência: " + acTxtEmiBan[ nOpcEmiBan ], ;
         "Ordem.....: " + acTxtOrdem[ nOpcOrdem ], ;
         "Tipo......: " + acTxtDetalhe[ nOpcDetalhe ], ;
         "Datas.....: " + iif( nOpcData == 1, acTxtData[ 1 ], ;
         dtoc( m_Datai ) + " A " + dtoc( m_Dataf ) ), ;
         "Saída.....: " + TxtSaida()[ nOpcPrinterType ] }
      FazAchoice( 7, 5, 6 + Len( acTxtGeral ), 44, acTxtGeral, @nOpcGeral )
      nOpcTemp := 1
      DO CASE
      CASE LastKey() == K_ESC
         EXIT
      CASE nOpcGeral == nOpcTemp++
         IF ConfirmaImpressao()
            Imprime()
         ENDIF

      CASE nOpcGeral == nOpcTemp++
         nOpcConf = 2
         WAchoice( nOpcGeral + 6, 25, TxtConf(), @nOpcConf, TxtSalva() )
         IF nOpcConf == 1 .AND. lastkey() != K_ESC
            GravaCnfRel( { nOpcEmiBan, nOpcOrdem, nOpcDetalhe } )
         ENDIF

      CASE nOpcGeral == nOpcTemp++
         WAchoice( nOpcGeral + 6, 25, acTxtEmiBan, @nOpcEmiBan, "Referência" )

      CASE nOpcGeral == nOpcTemp++
         WAchoice( nOpcGeral + 6, 25, acTxtOrdem, @nOpcOrdem, "Ordem" )

      CASE nOpcGeral == nOpcTemp++
         WAchoice( nOpcGeral + 6, 25, acTxtDetalhe, @nOpcDetalhe, "Tipo" )

      CASE nOpcGeral == nOpcTemp++
         DataIntervalo( nOpcGeral + 8, 26, @nOpcData, @m_Datai, @m_Dataf )

      CASE nOpcGeral == nOpcTemp
         WAchoice( nOpcGeral + 6, 25, TxtSaida( "VIE" ), @nOpcPrinterType, "Saída" )
         AppPrinterType( nOpcPrinterType )
      ENDCASE
   ENDDO
   WClose()
   CLOSE DATABASES

   RETURN

STATIC FUNCTION Imprime()

   LOCAL oPDF, nKey, mTotEnt, mTotSai, m_Picture1, m_Picture2, mResEnt, mResSai, mResumo, mGruEnt, mGruSai
   LOCAL mTmpFile, mGrupo, mImpTit, cTexto
   MEMVAR nOpcData, acTxtData, m_Datai, m_Dataf, nOpcDetalhe, acTxtDetalhe, nOpcOrdem, acTxtOrdem, nOpcEmiBan, nOpcPrinterType

   oPDF := PDFClass():New()
   oPDF:SetType( nOpcPrinterType )
   oPDF:Begin()
   nKey := 0
   oPDF:acHeader := { "", "" }
   oPDF:acHeader[ 1 ] := "MOVIMENTO POR " + Upper( acTxtOrdem[ nOpcOrdem ] )
   oPDF:acHeader[ 2 ] := "DT_BANCO   DT_EMISS   ___________H_I_S_T_O_R_"+;
      "I_C_O____________   ____ENTRADAS____   _____SAIDAS_____  "+;
      " _____SALDOS_____"
   IF nOpcData == 2
      AAdd( oPDF:acHeader, dtoc( m_Datai ) + " A " + dtoc( m_Dataf ) )
   ENDIF
   mTmpFile := MyTempFile( "CDX" )
   SELECT jpbamovi
   IF nOpcOrdem == 2
      SET RELATION TO jpbamovi->baResumo INTO jpbagrup
   ELSE
      SET RELATION TO
   ENDIF
   INDEX ON iif( nOpcOrdem == 1, "", jpbagrup->bgGrupo ) + jpbamovi->baResumo + dtos( jpbamovi->baDatBan ) + ;
      dtos( iif(nOpcEmiBan == 1, jpbamovi->baDatEmi, jpbamovi->baDatBan ) ) + jpbamovi->baHist to ( mTmpFile )
   GOTO TOP
   mTotEnt := mTotSai := 0
   DO WHILE nKey != K_ESC .AND. ! Eof()
      GrafProc()
      nKey := Inkey()
      IF ! Filtro()
         SKIP
         LOOP
      ENDIF
      oPDF:MaxRowTest()
      mGruEnt := mGruSai := 0
      mGrupo  := jpbagrup->bgGrupo
      DO WHILE nKey!=K_ESC .AND. mGrupo==jpbagrup->bgGrupo .AND. ! Eof()
         GrafProc()
         nKey := Inkey()
         IF ! Filtro()
            SKIP
            LOOP
         ENDIF
         mResEnt := mResSai := 0
         mResumo := jpbamovi->baResumo
         mImpTit := .T.
         DO WHILE nKey != K_ESC .AND. mGrupo == jpbagrup->bgGrupo .AND. mResumo == jpbamovi->baResumo .AND. ! Eof()
            GrafProc()
            nKey := Inkey()
            IF ! Filtro()
               SKIP
               LOOP
            ENDIF
            IF mImpTit .AND. nOpcDetalhe == 1
               cTexto := iif( nOpcOrdem == 1, "", jpbagrup->bgGrupo + " - " ) + jpbamovi->baResumo
               oPDF:MaxRowTest()
               oPDF:DrawText( oPDF:nRow, 0, cTexto )
               oPDF:nRow += 1
               mImpTit := .F.
            ENDIF
            mResEnt += iif(jpbamovi->baValor > 0, jpbamovi->baValor, 0 )
            mResSai += iif( jpbamovi->baValor > 0, 0, -jpbamovi->baValor )
            IF nOpcDetalhe == 1
               oPDF:MaxRowTest()
               oPDF:DrawText( oPDF:nRow, 0, iif( jpbamovi->baDatBan == Stod( "29991231" ),Space(8), Dtoc( jpbamovi->baDatBan ) ) )
               oPDF:DrawText( oPDF:nRow, oPDF:nCol + 3, jpbamovi->baDatEmi )
               oPDF:DrawText( oPDF:nRow, oPDF:nCol + 3, jpbamovi->baHist )
               m_Picture1 = iif( jpbamovi->baValor > 0, "@E 9,999,999,999.99", Space(16) )
               m_Picture2 = iif( jpbamovi->baValor < 0, "@E 9,999,999,999.99", Space(16) )
               oPDF:DrawText( oPDF:nRow, oPDF:nCol + 3, jpbamovi->baValor, m_Picture1 )
               oPDF:DrawText( oPDF:nRow, oPDF:nCol + 3, -jpbamovi->baValor, m_Picture2 )
               oPDF:DrawText( oPDF:nRow, oPDF:nCol + 3, (mResEnt-mResSai), "@E 99,999,999,999.99" )
               oPDF:nRow   += 1
            ENDIF
            SKIP
         ENDDO
         IF mResEnt != 0 .OR. mResSai != 0
            oPDF:MaxRowTest()
            oPDF:DrawText( oPDF:nRow, 33, "Resumo "+mResumo )
            oPDF:DrawText( oPDF:nRow, 63, mResEnt, PicVal( 14, 2 ) )
            oPDF:DrawText( oPDF:nRow, 82, mResSai, PicVal( 14, 2 ) )
            IF nOpcDetalhe == 1
               oPDF:nRow += 1
               oPDF:MaxRowTest()
               oPDF:DrawTExt( oPDF:nRow, 0, Replicate( " - ", Int( oPDF:MaxCol() / 3 ) ) )
            ENDIF
            oPDF:nRow += 1
            mGruEnt += mResEnt
            mGruSai += mResSai
         ENDIF
      ENDDO
      IF mGruEnt != 0 .OR. mGruSai != 0
         IF nOpcOrdem == 2
            oPDF:MaxRowTest()
            oPDF:DrawText( oPDF:nRow, 33, "Grupo " + mGrupo )
            oPDF:DrawText( oPDF:nRow, 63, mGruEnt, PicVal( 14, 2 ) )
            oPDF:DrawTExt( oPDF:nRow, 82, mGruSai, PicVal( 14, 2 ) )
            oPDF:nRow += 1
            oPDF:MaxRowTest()
            oPDF:DrawLine( oPDF:nRow, 0, oPDF:nRow, oPDF:MaxCol() )
            oPDF:nRow += 1
         ENDIF
         mTotEnt += mGruEnt
         mTotSai += mGruSai
      ENDIF
   ENDDO
   IF mTotEnt != 0 .OR. mTotSai != 0
      oPDF:MaxRowTest()
      oPDF:DrawText( oPDF:nRow, 33, "Total Geral" )
      oPDF:DrawText( oPDF:nRow, 63, mTotEnt, PicVal(14,2) )
      oPDF:DrawText( oPDF:nRow, 82, mTotSai, PicVal(14,2) )
      oPDF:nRow += 1
   ENDIF
   oPDF:End()
   SET INDEX TO ( PathAndFile( "jpbamovi" ) )
   SET RELATION TO
   fErase( mTmpFile )

   RETURN NIL

STATIC FUNCTION Filtro()

   LOCAL mReturn := .F.
   MEMVAR nOPcData, m_Datai, m_Dataf, nOpcEmiBan

   DO CASE
   CASE jpbamovi->baValor == 0
   CASE jpbamovi->baResumo==Pad("NENHUM",10)
   CASE nOpcEmiBan == 2 .AND. jpbamovi->baDatBan == Stod( "29991231" ) // Não baixados no banco
   CASE nOpcData == 1
      mReturn := .T.
   CASE nOpcEmiBan == 1 .AND. jpbamovi->baDatEmi < m_Datai
   CASE nOpcEmiBan == 1 .AND. jpbamovi->baDatEmi > m_Dataf
   CASE nOpcEmiBan == 2 .AND. jpbamovi->baDatBan < m_Datai
   CASE nOpcEmiBan == 2 .AND. jpbamovi->baDatBan > m_Dataf
   OTHERWISE
      mReturn := .T.
   ENDCASE

   RETURN mReturn
