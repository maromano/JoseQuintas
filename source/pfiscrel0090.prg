/*
PFISCREL0090 - RELATORIO DE MOVIMENTOS IRREGULARES
1994.04 José Quintas
*/

#include "inkey.ch"

PROCEDURE pFiscRel0090

   LOCAL nOpcGeral, acTxtGeral, mDefault
   MEMVAR nOpcData, acTxtData, m_Datai, m_Dataf, nOpcEntSai, acTxtEntSai, nOpcPrinterType

   IF ! AbreArquivos( "jpempre", "jpcadas", "jplfisc" )
      RETURN
   ENDIF
   SELECT jplfisc

   mDefault := LeCnfRel()

   nOpcData = 1
   m_datai = ctod( "" )
   m_dataf = ctod( "" )
   acTxtData := { "Todas", "Intervalo" }

   nOpcEntSai = iif(mDefault[1] > 3, 3, mDefault[1] )
   acTxtEntSai := { "Entradas", "Saídas", "Entradas/Saídas" }

   nOpcPrinterType := AppPrinterType()

   nOpcGeral = 1
   acTxtGeral := Array(5)

   WOpen( 5, 4, 7+len(acTxtGeral), 45, "Opções disponíveis" )

   DO WHILE .T.

      acTxtGeral := { ;
         TxtImprime(), ;
         TxtSalva(), ;
         "Datas.....: " + iif(nOpcData==1,acTxtData[ 1 ], ;
         dtoc(m_datai) + " A " + dtoc(m_dataf) ), ;
         "Tipo......: " + acTxtEntSai[ nOpcEntSai ], ;
         "Saída.....: " + TxtSaida()[ nOpcPrinterType ] }

      FazAchoice( 7, 5, 6+len(acTxtGeral), 44, acTxtGeral, @nOpcGeral )

      DO CASE
      CASE lastkey() == K_ESC
         EXIT

      CASE nOpcGeral == 1
         IF ConfirmaImpressao()
            imprime()
         ENDIF

      CASE nOpcGeral == 2

      CASE nOpcGeral == 3
         DataIntervalo(nOpcGeral+6,25,@nOpcData,@m_Datai,@m_Dataf)

      CASE nOpcGeral == 4
         WAchoice( nOpcGeral+6, 25, acTxtEntSai, @nOpcEntSai, "Tipo" )

      CASE nOpcGeral == 5
         WAchoice( nOpcGeral+6, 25, TxtSaida(), @nOpcPrinterType, "Saída" )
         AppPrinterType( nOpcPrinterType )

      ENDCASE
   ENDDO
   WClose()

   RETURN

STATIC FUNCTION imprime()

   LOCAL oPDF, nKey, m_Irreg, m_IcmIse, m_IpiIse
   MEMVAR nOpcData, m_Datai, m_Dataf, nOpcEntSai, acTxtEntSai, nOpcPrinterType

   oPDF := PDFClass():New()
   oPDF:SetType( nOpcPrinterType )
   oPDF:Begin()
   SELECT jplfisc
   OrdSetFocus("jplfisc3")
   nKey = 0
   oPDF:acHeader := {"","","","","",""}
   oPDF:acHeader[ 1 ] = "RELATORIO DE MOVIMENTOS IRREGULARIDADES - ENTRADAS"
   IF nOpcData == 1
      oPDF:acHeader[ 2 ] = " "
      SEEK "2" SOFTSEEK
   ELSE
      oPDF:acHeader[ 2 ] = "Periodo: " + dtoc( m_datai ) + " a " + dtoc( m_dataf )
      SEEK  "2" + Dtos( m_datai ) SOFTSEEK
   ENDIF
   oPDF:acHeader[ 3 ] = jpempre->emNome + " - CNPJ: " + jpempre->emCnpj + ;
      " - INSCR.EST: " + jpempre->emInsEst
   oPDF:acHeader[ 4 ] = Replicate( "-", 132 )
   oPDF:acHeader[ 5 ] = "DATA- ESP. SER NUMERO------ DATA-DOC EMITENTE-------------------------------- --CNPJ ou CPF----- INSCR.ESTADUAL"
   oPDF:acHeader[ 6 ] = "              ---VALOR CONTABIL-- COD. UF IMP. --BASE DE CALCULO-- ALIQ- -IMPOSTO CREDITADO- ------ISENTOS------ -------OUTROS------"

   DO WHILE nKey != K_ESC .AND. nOpcEntSai != 2 .AND. ! eof()
      nKey = Inkey()
      GrafProc()
      IF (jplfisc->lfDatLan>m_dataf .AND. nOpcData==2) .OR. jplfisc->lfTipLan != "2"
         EXIT
      ENDIF
      IF jplfisc->lfIcmVal == 0 .AND. jplfisc->lfIcmBas != 0
         RecLock()
         REPLACE jplfisc->lfIcmBas WITH 0
         RecUnlock()
      ENDIF
      IF jplfisc->lfIpiVal == 0 .AND. jplfisc->lfIpiBas != 0
         RecLock()
         REPLACE jplfisc->lfIpiBas WITH 0
         RecUnlock()
      ENDIF
      m_irreg = ""
      IF Round( jplfisc->lfIcmBas, 2 ) != Round( jplfisc->lfValCon - jplfisc->lfIpiVal, 2 ) .AND. jplfisc->lfIcmBas != 0
         m_irreg += "( BASE_ICMS # CONTABIL - IPI )"
      ENDIF
      IF Round( jplfisc->lfIpiBas, 2 ) != Round( jplfisc->lfValCon - jplfisc->lfIpiVal, 2 ) .AND. jplfisc->lfIpiBas != 0
         m_irreg += "  (BASE_IPI # CONTABIL - IPI )"
      ENDIF
      // encontra aliquota
      //   m_irreg += "  (ALIQUOTA # CADASTRO)"
      IF Round( jplfisc->lfIcmBas * jplfisc->lfIcmAli / 100, 0 ) != Round( jplfisc->lfIcmVal, 0 )
         m_irreg += "  ( ICMS # BASE * ALIQUOTA )"
      ENDIF
      IF empty( m_irreg )
         SKIP
         LOOP
      ENDIF
      oPDF:MaxRowTest()
      oPDF:DrawText( oPDF:nRow,   0, left( dtoc( jplfisc->lfDatLan ), 5 ) )
      oPDF:DrawText( oPDF:nRow,   6, jplfisc->lfModFis )
      oPDF:DrawText( oPDF:nRow,  11, jplfisc->lfDocSer )
      oPDF:DrawText( oPDF:nRow,  15, jplfisc->lfDocIni )
      oPDF:DrawText( oPDF:nRow,  28, jplfisc->lfDatLan )
      encontra( "2"+jplfisc->lfCliFor, "jpcadas" )
      oPDF:DrawText( oPDF:nRow,  37, Trim( jpcadas->cdNome ) + " (" + jplfisc->lfCliFor + ")" )
      oPDF:DrawText( oPDF:nRow, 78, jpcadas->cdCnpj )
      oPDF:DrawText( oPDF:nRow,  97, jpcadas->cdInsEst )
      oPDF:nRow   += 1
      oPDF:MaxRowTest()
      m_icmise = max( jplfisc->lfValCon - jplfisc->lfIcmBas - jplfisc->lfIcmOut, 0 )
      m_ipiise = max( jplfisc->lfValCon - jplfisc->lfIpiBas - jplfisc->lfIpiOut - jplfisc->lfIpiVal, 0 )
      oPDF:DrawText( oPDF:nRow,  13, jplfisc->lfValCon, PicVal(14,2) )
      oPDF:DrawText( oPDF:nRow,  33, jplfisc->lfCfOp, "9.999" )
      oPDF:DrawText( oPDF:nRow,  38, jplfisc->lfUf )
      oPDF:DrawText( oPDF:nRow,  41, "ICMS" )
      oPDF:DrawText( oPDF:nRow,  46, jplfisc->lfIcmBas, PicVal(14,2) )
      oPDF:DrawText( oPDF:nRow,  66, jplfisc->lfIcmAli, "@E 99.99" )
      oPDF:DrawText( oPDF:nRow,  73, jplfisc->lfIcmVal, PicVal(14,2) )
      oPDF:DrawText( oPDF:nRow,  93, m_icmise, PicVal(14,2) )
      oPDF:DrawText( oPDF:nRow, 113, jplfisc->lfIcmOut, PicVal(14,2) )
      oPDF:nRow += 1
      IF jplfisc->lfIpiBas != 0 .OR. jplfisc->lfIpiVal != 0 .OR. jplfisc->lfIpiOut != 0
         oPDF:MaxRowTest()
         oPDF:DrawText( oPDF:nRow, 41, "IPI" )
         oPDF:DrawText( oPDF:nRow, 46, jplfisc->lfIpiBas, PicVal(14,2) )
         oPDF:DrawText( oPDF:nRow, 73, jplfisc->lfIpiVal, PicVal(14,2) )
         oPDF:DrawText( oPDF:nRow, 93, m_ipiise, PicVal(14,2) )
         oPDF:DrawText( oPDF:nRow, 113, jplfisc->lfIpiOut, PicVal(14,2) )
         oPDF:nRow += 1
      ENDIF
      IF ! Empty( jplfisc->lfObs )
         oPDF:MaxRowTest()
         oPDF:DrawText( oPDF:nRow, oPDF:MaxCol() - Len( Trim( jplfisc->lfObs ) ), Trim( jplfisc->lfObs ) )
         oPDF:nRow += 1
      ENDIF
      oPDF:MaxRowTest()
      oPDF:DrawText( oPDF:nRow, oPDF:MaxCol() - Len( Trim( m_irreg ) ), m_irreg )
      oPDF:nRow += 1
      oPDF:MaxRowTest()
      oPDF:DrawLine( oPDF:nRow, 0, oPDF:nRow, oPDF:MaxCol() )
      oPDF:nRow += 1
      SKIP
   ENDDO
   oPDF:nRow = oPDF:MaxRow()
   oPDF:acHeader := {"","","","","",""}
   oPDF:acHeader[ 1 ] = "RELATORIO DE MOVIMENTOS IRREGULARIDADES - SAIDAS"
   IF nOpcData == 1
      oPDF:acHeader[ 2 ] = " "
      SEEK "1" SOFTSEEK
   ELSE
      oPDF:acHeader[ 2 ] = "Periodo: " + dtoc( m_datai ) + " a " + dtoc( m_dataf )
      SEEK "1" + Dtos( m_datai ) SOFTSEEK
   ENDIF
   oPDF:acHeader[ 3 ] = jpempre->emNome + " - CNPJ: " + jpempre->emCnpj + ;
      " - INSCR.EST: " + jpempre->emInsEst
   oPDF:acHeader[ 4 ] = Replicate( "-", 132 )
   oPDF:acHeader[ 5 ] = "DATA- ESP. SER NUMERO------ DATA-DOC EMITENTE-------------------------------- --CNPJ ou CPF----- INSCR.ESTADUAL"
   oPDF:acHeader[ 6 ] = "              ---VALOR CONTABIL-- COD. UF IMP. --BASE DE CALCULO-- ALIQ- -IMPOSTO DEBITADO-- ------ISENTOS------ -------OUTROS------"
   DO WHILE nKey != K_ESC .AND. nOpcEntSai != 1 .AND. ! eof()
      nKey = Inkey()
      GrafProc()
      IF (jplfisc->lfDatLan>m_dataf .AND. nOpcData==2) .OR. jplfisc->lfTipLan != "1"
         EXIT
      ENDIF
      IF jplfisc->lfIcmVal == 0 .AND. jplfisc->lfIcmBas != 0
         RecLock()
         REPLACE jplfisc->lfIcmBas WITH 0
         RecUnlock()
      ENDIF
      IF jplfisc->lfIpiVal == 0 .AND. jplfisc->lfIpiBas != 0
         RecLock()
         REPLACE jplfisc->lfIpiBas WITH 0
         RecUnlock()
      ENDIF
      m_irreg = ""
      IF Round( jplfisc->lfIcmBas,2 ) != Round( jplfisc->lfValCon - jplfisc->lfIpiVal, 2 ) .AND. jplfisc->lfIcmBas != 0
         m_irreg += "( BASE_ICMS # CONTABIL - IPI )"
      ENDIF
      IF Round( jplfisc->lfIpiBas, 2 ) != Round( jplfisc->lfValCon - jplfisc->lfIpiVal, 2 ) .AND. jplfisc->lfIpiBas != 0
         m_irreg += "  (BASE_IPI # CONTABIL - IPI )"
      ENDIF
      // encontra aliquota
      //m_irreg += "  (ALIQUOTA # CADASTRO)"
      IF Round( jplfisc->lfIcmBas * jplfisc->lfIcmAli / 100, 0 ) != Round( jplfisc->lfIcmVal, 0 )
         m_irreg += "  ( ICMS # BASE * ALIQUOTA )"
      ENDIF
      IF empty( m_irreg )
         SKIP
         LOOP
      ENDIF
      oPDF:MaxRowTest()
      oPDF:DrawText( oPDF:nRow,   0, left(dtoc(jplfisc->lfDatLan),5) )
      oPDF:DrawText( oPDF:nRow,   6, jplfisc->lfModFis )
      oPDF:DrawText( oPDF:nRow,  11, jplfisc->lfDocSer )
      oPDF:DrawText( oPDF:nRow,  15, jplfisc->lfDocIni )
      oPDF:nRow   += 1
      m_icmise = max( jplfisc->lfValCon - jplfisc->lfIcmBas - jplfisc->lfIcmOut, 0 )
      m_ipiise = max( jplfisc->lfValCon - jplfisc->lfIpiBas - jplfisc->lfIpiOut - jplfisc->lfIpiVal, 0 )
      oPDF:MaxRowTest()
      oPDF:DrawText( oPDF:nRow,  13, jplfisc->lfValCon, PicVal(14,2) )
      oPDF:DrawText( oPDF:nRow,  33, jplfisc->lfCfOp, "9.999" )
      oPDF:DrawText( oPDF:nRow,  38, jplfisc->lfUf )
      oPDF:DrawText( oPDF:nRow,  41, "ICMS" )
      oPDF:DrawText( oPDF:nRow,  46, jplfisc->lfIcmBas, PicVal(14,2) )
      oPDF:DrawText( oPDF:nRow,  66, jplfisc->lfIcmAli, "@E 99.99" )
      oPDF:DrawText( oPDF:nRow,  73, jplfisc->lfIcmVal, PicVal(14,2) )
      oPDF:DrawText( oPDF:nRow,  93, m_icmise, PicVal(14,2) )
      oPDF:DrawText( oPDF:nRow, 113, jplfisc->lfIcmOut, PicVal(14,2) )
      oPDF:nRow += 1
      IF jplfisc->lfIpiBas != 0 .OR. jplfisc->lfIpiVal != 0 .OR. jplfisc->lfIpiOut != 0
         oPDF:MaxRowTest()
         oPDF:DrawText( oPDF:nRow, 41, "IPI" )
         oPDF:DrawText( oPDF:nRow, 46, jplfisc->lfIpiBas, PicVal(14,2) )
         oPDF:DrawText( oPDF:nRow, 73, jplfisc->lfIpiVal, PicVal(14,2) )
         oPDF:DrawText( oPDF:nRow, 93, m_ipiise, PicVal(14,2) )
         oPDF:DrawText( oPDF:nRow, 113, jplfisc->lfIpiOut, PicVal(14,2) )
         oPDF:nRow += 1
      ENDIF
      IF ! Empty( jplfisc->lfObs )
         oPDF:MaxRowTest()
         oPDF:DrawText( oPDF:nRow, oPDF:MaxCol() - Len( Trim( jplfisc->lfObs ) ), Trim( jplfisc->lfObs ) )
         oPDF:nRow += 1
      ENDIF
      oPDF:MaxRowTest()
      oPDF:DrawText( oPDF:nRow, oPDF:MaxCol() - Len( Trim( m_irreg ) ), m_irreg )
      oPDF:nRow += 1
      oPDF:MaxRowTest()
      oPDF:DrawLine( oPDF:nRow, 0, oPDF:nRow, oPDF:MaxCol() )
      oPDF:nRow += 1
      SKIP
   ENDDO
   oPDF:End()

   RETURN NIL
