/*
PCONTREL0250 - RELATORIO DE CONFERENCIA
1991.05 José Quintas
*/

#include "inkey.ch"

PROCEDURE PCONTREL0250

   LOCAL GetList := {}, m_Menu, m_TxtMenu, m_Conf, nCont
   MEMVAR m_DeAte, m_TxtDeAte, m_Lotei, m_Lotef, m_TRel, m_TxtTRel, nOpcMes, acTxtMes
   MEMVAR REL_TRel, nOpcPrinterType

   IF ! AbreArquivos( "jpempre", "jptabel", "ctplano", "ctdiari", "ctlotes" )
      RETURN
   ENDIF
   SELECT ctlotes

   rel_trel  = 1

   IF File( "PCONTREL0250.mem" )
      RESTORE FROM ( "PCONTREL0250" ) ADDITIVE
   ENDIF

   m_conf = 2

   nOpcMes = 1
   acTxtMes := Array( 96 )
   FOR nCont = 1 TO 96
      acTxtMes[ nCont ] = Pad( nomemes( nCont ), 9 ) + " / " + StrZero( jpempre->emAnoBase + Int( ( nCont - 1 ) / 12 ), 4 )
   NEXT

   m_deate = 1
   m_lotei = Space( 6 )
   m_lotef = Space( 6 )
   m_txtdeate := { "Todos", "Intervalo" }

   m_trel = rel_trel
   m_txttrel := { "Todos os lotes", "So' lotes com diferença ", "Só lotes batidos" }

   nOpcPrinterType := AppPrinterType()

   m_menu = 1
   m_txtmenu := Array( 6 )

   WOpen( 5, 4, Len( m_TxtMenu ) + 7, 45, "Opções disponíveis" )

   DO WHILE .T.

      m_TxtMenu := { ;
         TxtImprime(), ;
         TxtSalva(), ;
         "Mes.......: " + acTxtMes[ nOpcMes ], ;
         "Lotes.....: " + iif( m_DeAte == 1, m_txtdeate[ 1 ], m_lotei + " a " + m_lotef ), ;
         "Tipo Relat: " + m_txttrel[ m_trel ], ;
         "Saída.....: " + TxtSaida()[ nOpcPrinterType ] }

      FazAchoice( 7, 5, Len( m_TxtMenu ) + 6, 44, m_txtmenu, @m_menu )

      DO CASE
      CASE LastKey() == K_ESC
         EXIT

      CASE m_menu == 1
         IF ConfirmaImpressao()
            Imprime()
         ENDIF

      CASE m_menu == 2
         m_conf = 2
         WAchoice( 8, 25, TxtConf(), @m_conf, TxtSalva() )
         IF m_conf == 1 .AND. LastKey() != K_ESC
            rel_trel  = m_trel
            SAVE ALL LIKE rel * TO ( "PCONTREL0250" )
         ENDIF

      CASE m_menu == 3
         SelecionaMesContabil( 9, 25, @nOpcMes )

      CASE m_menu == 4
         WOpen( 10, 25, 14, 65, "Intervalo" )
         DO WHILE .T.
            FazAchoice( 12, 26, 13, 64, m_txtdeate, @m_deate )
            IF LastKey() != K_ESC .AND. m_deate = 2
               WOpen( 13, 45, 17, 70, "Lotes" )
               Mensagem( "Digite Número do Lote, F9 pesquisa, ESC sai" )
               @ 15, 47 GET m_lotei PICTURE "@K 999999" VALID FillZeros( @m_Lotei )
               @ 16, 47 GET m_lotef PICTURE "@K 999999" VALID FillZeros( @m_Lotef )
               READ
               WClose()
               IF LastKey() == K_ESC
                  LOOP
               ENDIF
            ENDIF
            EXIT
         ENDDO
         WClose()

      CASE m_menu == 5
         WAchoice( 11, 25, m_txttrel, @m_trel, "Tipo de Relatório" )

      CASE m_menu == 6
         WAchoice( 13, 25, TxtSaida(), @nOpcPrinterType, "Saída" )
         AppPrinterType( nOpcPrinterType )

      ENDCASE

   ENDDO
   WClose()
   CLOSE DATABASES

   RETURN

STATIC FUNCTION imprime()

   LOCAL oPDF, m_qtdtot, m_debtot, m_cretot, m_qtdlan, m_deblan, m_crelan, m_Batido, nKey, m_AnoMes, nCont, m_Lanc
   MEMVAR m_DeAte, m_TxtDeAte, m_Lotei, m_Lotef, m_TRel, m_TxtTRel, acTxtMes, nOpcMes, nOpcPrinterType

   oPDF := PDFClass():New()
   oPDF:SetType( nOpcPrinterType )
   oPDF:Begin()

   oPDF:acHeader := { "", "", "", "", "", "" }
   oPDF:acHeader[ 1 ] = "RELATORIO DE CONFERENCIA DO MOVIMENTO"

   oPDF:acHeader[ 2 ] = acTxtMes[ nOpcMes ]

   IF m_deate == 2
      oPDF:acHeader[ 2 ] = oPDF:acHeader[ 2 ] + "   " + ;
         m_lotei + " ATE' " + m_lotef
   ENDIF

   oPDF:acHeader[ 3 ] = "LOT.LAN.MOV  DATA MOV  ---- DIGITACAO -----"
   oPDF:acHeader[ 4 ] = Space( 13 ) +  "------------ CONTA ( NOME, " + "CODIGO NORMAL E REDUZIDO ) ------------"
   oPDF:acHeader[ 5 ] = Space( 13 ) +  "---- CENTRO DE CUSTO ( NOME" + " E CODIGO ) -----"
   oPDF:acHeader[ 6 ] = Space( 37 ) +  "-------------------- HISTOR" + "ICO --------------------  ------ DEBITO " + "------  ----- CREDITO ------"

   nKey = 0

   m_AnoMes := ContabilAnoMes( nOpcMes )
   SEEK m_AnoMes SOFTSEEK
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey = Inkey()
      IF Left( DToS( ctlotes->loData ), 6 ) > m_AnoMes
         EXIT
      ENDIF
      IF ctlotes->loLote < m_Lotei .AND. m_DeAte == 2
         SKIP
         LOOP
      ENDIF
      IF ctlotes->loLote > m_lotef .AND. m_deate == 2
         EXIT
      ENDIF
      m_batido = ( ctlotes->loQtdInf == ctlotes->loQtdCal .AND. ctlotes->loValInf == ctlotes->loDebCal .AND. ctlotes->loValInf == ctlotes->loCreCal )
      IF ( m_batido .AND. m_trel == 2 ) .OR. ( ! m_batido .AND. m_trel == 3 )
         SKIP
         LOOP
      ENDIF
      SELECT ctdiari
      SEEK m_AnoMes + ctlotes->loLote
      STORE 0 TO m_qtdtot, m_debtot, m_cretot
      STORE 0 TO m_qtdlan, m_deblan, m_crelan
      oPDF:nRow = oPDF:MaxRow()
      DO WHILE Left( DToS( ctdiari->diData ), 6 ) == m_AnoMes .AND. nKey != K_ESC .AND. ctdiari->diLote = ctlotes->loLote .AND. ! Eof()
         nKey = Inkey()
         IF oPDF:nRow > oPDF:MaxRow() - 9
            oPDF:PageHeader()
         ENDIF
         oPDF:DRAWTEXT( oPDF:nRow, 0, ctdiari->diLote + "." + ctdiari->diLanc + "." + ctdiari->diMov )
         oPDF:DRAWTEXT( oPDF:nRow, oPDF:nCol + 2, ctdiari->diData )
// oPDF:DrawText( oPDF:nRow, oPDF:nCol + 2, "(" + d_digitador + " - " + Dtoc( d_digitado ) + ")" )
         oPDF:nRow = oPDF:nRow + 1
         Encontra( ctdiari->diCConta, "ctplano" )
         oPDF:DRAWTEXT( oPDF:nRow, 13, Trim( ctplano->a_nome ) + " (" + PicConta( ctdiari->diCConta ) + ")" + " (" + Transform( ctplano->a_reduz, "999999" ) + ")" )
         oPDF:nRow = oPDF:nRow + 1
         IF Val( ctdiari->diCCusto ) != 0
            oPDF:DRAWTEXT( oPDF:nRow, 13, Trim( AUXCCUSTOClass():Descricao( ctdiari->diCCusto ) ) + " (" + ctdiari->diCCusto + ")" )
            oPDF:nRow = oPDF:nRow + 1
         ENDIF
         oPDF:DRAWTEXT( oPDF:nRow, 37, SubStr( ctdiari->diHist, 1, 50 ) )
         FOR nCont = 2 TO 5
            IF ! Empty( SubStr( ctdiari->diHist, nCont * 50 - 49, 50 ) )
               oPDF:nRow = oPDF:nRow + 1
               oPDF:DRAWTEXT( oPDF:nRow, 37, SubStr( ctdiari->diHist, nCont * 50 - 59, 50 ) )
            ENDIF
         NEXT
         IF ctdiari->diDebCre = "D"
            oPDF:DRAWTEXT( oPDF:nRow, 90, ctdiari->diValor, PicVal( 14, 2 ) )
            m_debtot := Round( m_debtot + ctdiari->diValor, 2 )
            m_deblan := Round( m_deblan + ctdiari->diValor, 2 )
         ELSE
            oPDF:DRAWTEXT( oPDF:nRow, 112, ctdiari->diValor, PicVal( 14, 2 ) )
            m_cretot = Round( m_cretot + ctdiari->diValor, 2 )
            m_crelan = Round( m_crelan + ctdiari->diValor, 2 )
         ENDIF
         m_qtdtot = m_qtdtot + 1
         m_qtdlan = m_qtdlan + 1
         oPDF:nRow    = oPDF:nRow + 1
         m_lanc   = ctdiari->diLanc
         SKIP
         IF m_lanc != ctdiari->diLanc .OR. ctdiari->diLote != ctlotes->loLote
            IF m_deblan != m_crelan .AND. m_qtdlan != 1
               oPDF:DRAWTEXT( oPDF:nRow, 96, "***** LANCAMENTO COM DIFERENCA *****" )
               oPDF:nRow = oPDF:nRow + 1
            ENDIF
            oPDF:DRAWLINE( oPDF:nRow, 0, oPDF:nRow, oPDF:MaxCol() )
            oPDF:nRow  = oPDF:nRow + 1
            m_deblan = 0
            m_crelan = 0
            m_qtdlan = 0
         ENDIF
      ENDDO
      SELECT ctlotes
      IF LastKey() != K_ESC
         IF oPDF:nRow > oPDF:MaxRow() - 14
            oPDF:PageHeader()
         ENDIF
         oPDF:DRAWTEXT( oPDF:nRow, 0, "Valores calculados durante a impress" + "ao: Lote " + ctlotes->loLote )
         oPDF:DRAWTEXT( oPDF:nRow, 77, "Qtde:" )
         oPDF:DRAWTEXT( oPDF:nRow, 84, m_qtdtot, "99999" )
         oPDF:DRAWTEXT( oPDF:nRow, 90, m_debtot, PicVal( 14, 2 ) )
         oPDF:DRAWTEXT( oPDF:nRow, 112, m_cretot, PicVal( 14, 2 ) )
         oPDF:nRow = oPDF:nRow + 1

         oPDF:DRAWTEXT( oPDF:nRow, 0, "Valores informados na capa de lote:" )
         oPDF:DRAWTEXT( oPDF:nRow, 77, "Qtde:" )
         oPDF:DRAWTEXT( oPDF:nRow, 84, ctlotes->loQtdInf, "99999" )
         oPDF:DRAWTEXT( oPDF:nRow, 90, ctlotes->loValInf, PicVal( 14, 2 ) )
         oPDF:DRAWTEXT( oPDF:nRow, 112, ctlotes->loValInf, PicVal( 14, 2 ) )
         oPDF:nRow = oPDF:nRow + 1

         m_batido = .F.
         DO CASE
         CASE Round( m_qtdtot, 0 ) != Round( ctlotes->loQtdInf, 0 )
         CASE Round( m_debtot, 2 ) != Round( ctlotes->loValInf, 2 )
         CASE Round( m_cretot, 2 ) != Round( ctlotes->loValInf, 2 )
         OTHERWISE
            m_batido = .T.
         ENDCASE
         IF m_batido
            oPDF:DRAWTEXT( oPDF:nRow, 84, "LOTE BATIDO" )
         ELSE
            oPDF:DRAWTEXT( oPDF:nRow, 84, "----" )
            oPDF:DRAWTEXT( oPDF:nRow, 90, Replicate( "-", 20 ) )
            oPDF:DRAWTEXT( oPDF:nRow, 112, Replicate( "-", 20 ) )
            oPDF:nRow = oPDF:nRow + 1
            oPDF:DRAWTEXT( oPDF:nRow, 0, "Diferenca entre valores calculados e informados:" )
            oPDF:DRAWTEXT( oPDF:nRow, 84, Abs( m_qtdtot - ctlotes->loQtdInf ), "9999" )
            oPDF:DRAWTEXT( oPDF:nRow, 90, Abs( m_debtot - ctlotes->loValInf ), PicVal( 14, 2 ) )
            oPDF:DRAWTEXT( oPDF:nRow, 112, Abs( m_cretot - ctlotes->loValInf ), PicVal( 14, 2 ) )
         ENDIF
         oPDF:DRAWLINE( oPDF:nRow + 1, 0, oPDF:nRow + 1, oPDF:MaxCol() )
         oPDF:nRow = oPDF:nRow + 2
         IF ctlotes->loQtdCal != m_qtdtot
            RecLock()
            REPLACE ctlotes->loQtdCal WITH m_qtdtot
         ENDIF
         IF ctlotes->loDebCal != m_debtot
            RecLock()
            REPLACE ctlotes->loDebCal WITH m_debtot
         ENDIF
         IF ctlotes->loCreCal != m_cretot
            RecLock()
            REPLACE ctlotes->loCreCal WITH m_cretot
         ENDIF
         RecUnlock()
      ENDIF
      SKIP
   ENDDO
   oPDF:End()

   RETURN NIL
