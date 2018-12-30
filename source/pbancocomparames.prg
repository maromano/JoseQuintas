/*
PBANCOCOMPARAMES - COMPARATIVO MES A MES
1994.01 José Quintas
*/

#include "inkey.ch"

PROCEDURE pBancoComparaMes

   LOCAL m_Texto, m_TmpMes, m_TmpAno, oBrowse, nKey, mTop, mLeft, mBottom, mRight, ColPos
   LOCAL m_TmpMov, nMCol, nMRow, oTBrowse
   MEMVAR m_MostraDol, m_MostraTot, m_Ano, m_Mes, m_CodResumo, m_Tabela, nQtdCols

   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi", "jpbaauto", "jpbagrup", "jpbamovi" )
      RETURN
   ENDIF
   SELECT jpbamovi
   OrdSetFocus( "jpbamovi2" )
   SELECT jpbagrup
   OrdSetFocus( "jpbagrup2" )
   GOTO TOP
   m_Tabela := PegaContas( .T. )
   IF Len( m_Tabela ) == 2 // So contas de totais
      MsgWarning( "Não há dados p/ comparativo!" )
      RETURN
   ENDIF

   m_CodResumo           := 1
   m_Ano                 := Year( Date() )
   m_Mes                 := Month( Date() )
   m_mostratot           := .F.
   m_mostradol           := .F.
   mTop                  := 4
   mLeft                 := 0
   mBottom               := MaxRow() - 5
   mRight                := MaxCol() - 2

   oBrowse               := TBrowseDb( mTop, mLeft, mBottom, mRight )
   oBrowse:SkipBlock     := { | m_Regs | SkipBrow2( m_Regs ) }
   oBrowse:GoTopBlock    := { || TopBrow2() }
   oBrowse:GoBottomBlock := { || botbrow2() }
   oBrowse:HeadSep       := Chr(196)
   oBrowse:ColSep        := Chr(179)
   oBrowse:FootSep       := Chr(196)
   oBrowse:FrameColor    := SetColorTbrowseFrame()
   ColPos                := 2
   nQtdCols              := 5

   oTBrowse := { ;
      { "", { || FldBrow2( -1 ) } }, ;
      { "", { || FldBrow2( 0  ) } }, ;
      { "", { || FldBrow2( 1  ) } }, ;
      { "", { || FldBrow2( 2  ) } }, ;
      { "", { || FldBrow2( 3  ) } }, ;
      { "", { || FldBrow2( 4  ) } } }
   ToBrowse( oTBrowse, oBrowse )

   TitBrow2()

   oBrowse:right()

   DO WHILE ! oBrowse:Stable
      oBrowse:Stabilize()
   ENDDO
   DO WHILE .T.
      Mensagem( "SETAS, T Totais, ENTER Lançamentos, R Resumos, ESC Sai" )
      nKey := 0
      DO WHILE nKey == 0 .AND. ! oBrowse:Stable
         oBrowse:Stabilize()
         nKey := Inkey()
      ENDDO

      IF oBrowse:stable()
         oBrowse:RefreshCurrent()
         DO WHILE ! oBrowse:Stabilize()
         ENDDO
         nKey = Inkey(600, INKEY_ALL - INKEY_MOVE + HB_INKEY_GTEVENT)
         IF nKey == 0
            KEYBOARD Chr( K_ESC )
            LOOP
         ENDIF
      ENDIF
      nMRow := MROW()
      NMCol := MCOL()

      DO CASE
      CASE SetKey( nKey ) != NIL
         eval( SetKey( nKey ), procname(), procline(), readvar() )
      CASE nKey > 999
         DO CASE
         CASE mBrzMove( oBrowse, nMRow, nMCol, mTop + 1, mLeft + 1, mBottom - 1, mRight - 1 ) // Move cursor
         CASE mBrzClick( oBrowse, nMRow, nMCol ) // click no TBrowse atual
            //KEYBOARD Chr( K_ENTER )
         ENDCASE

      CASE nKey == K_ESC       ; EXIT

      CASE nKey == K_DOWN      ; oBrowse:Down()

      CASE nKey == K_UP        ; oBrowse:Up()

      CASE nKey == K_CTRL_DOWN ; oBrowse:PageDown()

      CASE nKey == K_CTRL_UP   ; oBrowse:PageUp()

      CASE nKey == K_LEFT
         IF ColPos == 2
            m_Ano := iif( m_Mes == 12, m_Ano + 1, m_Ano )
            m_Mes := iif( m_Mes == 12, 1, m_Mes + 1 )
            TitBrow2()
            oBrowse:Invalidate()
            oBrowse:RefreshAll()
         ELSEIF ColPos > 1
            oBrowse:left()
            ColPos--
         ENDIF

      CASE nKey == K_RIGHT
         IF ColPos == ( nQtdCols + 1 )
            m_Ano = iif( m_Mes == 1, m_Ano - 1, m_Ano )
            m_Mes = iif( m_Mes == 1, 12, m_Mes - 1 )
            TitBrow2()
            oBrowse:Invalidate()
            oBrowse:RefreshAll()
         ELSE
            oBrowse:right()
            ColPos++
         ENDIF

      CASE nKey == asc( "R" ) .OR. nKey == asc( "r" )
         IF Len( m_Tabela[ m_CodResumo ] ) == 10
            SELECT jpbagrup
            SEEK m_Tabela[ m_CodResumo ]
            DO WHILE jpbagrup->bgGrupo == m_Tabela[ m_CodResumo ] .AND. ! eof()
               RecLock()
               REPLACE jpbagrup->bgMostra WITH iif( jpbagrup->bgMostra == "S", "N", "S" )
               RecUnlock()
               SKIP
            ENDDO
            m_Tabela := PegaContas()
            oBrowse:Invalidate()
            oBrowse:RefreshAll()
         ENDIF

      CASE nKey == K_ENTER
         DO WHILE ! oBrowse:stabilize()
            GrafProc()
         ENDDO
         m_TmpMes := m_Mes - iif( ColPos > 1, ColPos - 2, 0 )
         m_TmpAno := m_Ano - iif( m_TmpMes < 1, 1, 0 )
         m_TmpMes := m_TmpMes + iif( m_TmpMes < 1, 12, 0 )
         WSave()
         Mensagem( "Aguarde, pesquisando movimentação..." )
         Cls()
         @ 2, 0 SAY "Grupo:" + Trim( left( m_Tabela[ m_CodResumo ], 10 ) ) + iif( Len( m_Tabela[ m_CodResumo ] ) == 10, "", ;
            ", Resumo:" + Trim( right( m_Tabela[ m_CodResumo ], 10 ) ) ) + ", mes:" + StrZero( m_TmpMes, 2 ) + "/" + StrZero( m_TmpAno, 4 )
         @ 3, 0 SAY "BANCO EMISS __________HISTORICO__________ ___VALOR (NA DATA)__"
         m_tmpmov := {}
         SELECT jpbagrup
         SEEK left( m_Tabela[ m_CodResumo ], 10 )
         DO WHILE jpbagrup->bgGrupo == left( m_Tabela[ m_CodResumo ], 10 ) .AND. ! eof()
            GrafProc()
            IF jpbagrup->bgResumo != right( m_Tabela[ m_CodResumo ], 10 ) .AND. Len( m_Tabela[ m_CodResumo ] ) > 10
               SKIP
               LOOP
            ENDIF
            SELECT jpbamovi
            SEEK jpbagrup->bgResumo + StrZero( m_TmpAno, 4 ) + StrZero( m_TmpMes, 2 )
            DO WHILE jpbamovi->baResumo = jpbagrup->bgResumo .AND. year( jpbamovi->baDatEmi ) == m_TmpAno .AND. month( jpbamovi->baDatEmi ) == m_TmpMes .AND. ! eof()
               GrafProc()
               m_Texto  = iif( jpbamovi->baDatBan = Stod( "29991231" ), Space(5), Left( Dtoc( jpbamovi->baDatBan ), 5 ) )
               m_Texto += Chr(179) + left( dtoc( jpbamovi->baDatEmi ), 5 )
               m_Texto += Chr(179) + left( jpbamovi->baHist, 26 )
               m_Texto += Chr(179)
               m_Texto += transform( jpbamovi->bavalor, PicVal(14,2) )
               m_Texto += "<" + Chr(179)
               m_Texto += Space(14)
               m_Texto += " "
               AAdd( m_tmpmov, m_Texto )
               SKIP
            ENDDO
            SELECT jpbagrup
            SKIP
         ENDDO
         IF Len( m_tmpmov ) > 0
            Mensagem( "Movimente com as setas, ENTER ou ESC sai" )
            achoice( 4, 0, 21, 79, m_tmpmov )
         ENDIF
         WRestore()

      CASE nKey == K_HOME
         oBrowse:GoTop()

      CASE nKey == K_END
         oBrowse:GoBottom()

      CASE Chr( nKey ) $ "Tt"
         m_mostratot = ( ! m_mostratot )
         TitBrow2()
         oBrowse:Invalidate()
         oBrowse:RefreshAll()

      CASE Chr( nKey ) $ "Dd"
         m_mostradol = ( ! m_mostradol )
         TitBrow2()
         oBrowse:Invalidate()
         oBrowse:RefreshAll()

      ENDCASE
   ENDDO

   RETURN

STATIC FUNCTION TopBrow2()

   MEMVAR m_CodResumo

   m_CodResumo := 1

   RETURN .T.

STATIC FUNCTION botbrow2()

   MEMVAR m_CodResumo, m_Tabela

   m_CodResumo := Len( m_Tabela )

   RETURN .T.

STATIC FUNCTION SkipBrow2( nSkip )

   LOCAL nSkipped := 0
   MEMVAR m_CodResumo, m_Tabela

   IF nSkip == 0
   ELSEIF nSkip > 0 .AND. m_CodResumo < Len( m_Tabela )
      DO WHILE nSkipped < nSkip .AND. m_CodResumo < Len( m_Tabela )
         GrafProc()
         m_CodResumo++
         nSkipped++
      ENDDO
   ELSEIF nSkip < 0
      DO WHILE nSkipped > nSkip .AND. m_CodResumo > 1
         GrafProc()
         m_CodResumo--
         nSkipped--
      ENDDO
   ENDIF

   RETURN nSkipped

STATIC FUNCTION FldBrow2( nCont )

   LOCAL m_Retorno, m_TmpMes, m_TmpAno, m_Select
   MEMVAR m_Ano, m_Mes, m_CodResumo, m_Tabela, m_MostraTot, m_MostraDol

   m_TmpAno := iif( m_Mes-nCont <= 0, m_Ano - 1, m_Ano )
   m_TmpMes := iif( m_Mes-nCont <= 0, m_Mes - nCont + 12, m_Mes -nCont )
   m_Select := select()
   DO CASE
   CASE nCont == -1
      IF Len( m_Tabela[ m_CodResumo ] ) == 10
         m_Retorno := "->" + left( m_Tabela[ m_CodResumo ], 10 )
      ELSE
         m_Retorno := "  " + right( m_Tabela[ m_CodResumo ], 10 )
      ENDIF
   CASE ( m_Tabela[ m_CodResumo ] == ">ENTRADAS" .OR. m_Tabela[ m_CodResumo] == ">SAIDAS" ) .AND. ! m_MostraTot
      m_Retorno := ""
   CASE m_Tabela[ m_CodResumo ] = ">ENTRADAS"
      m_Retorno := transform( SomaEntradas( m_TmpAno, m_TmpMes ), PicVal(14,2) )
   CASE m_Tabela[ m_CodResumo ] = ">SAIDAS"
      m_Retorno := transform( SomaSaidas( m_TmpAno, m_TmpMes ), PicVal(14,2) )
   CASE Len(m_Tabela[ m_CodResumo ]) == 10
      m_Retorno := Transform( SomaGrupo( m_Tabela[ m_CodResumo ], m_TmpAno, m_TmpMes ), PicVal(14,2) )
   OTHERWISE
      m_Retorno := Transform( SomaResumo( right( m_Tabela[ m_CodResumo ], 10 ), m_TmpAno, m_TmpMes ), PicVal(14,2) )
   ENDCASE
   SELECT ( m_Select )

   RETURN m_Retorno

STATIC FUNCTION TitBrow2()

   LOCAL nCont
   MEMVAR m_Ano, m_Mes, nQtdCols, m_MostraDol

   @ 2, 0 SAY Padc( "VALORES EM MOEDA VIGENTE", MaxCol() )
   @ 3, 1 SAY "Item"
   FOR nCont = 0 TO ( nQtdCols - 1 )
      @ 3, 16 + nCont * 20 SAY Padc( Space(3) + iif( m_Mes - nCont <= 0, ;
         StrZero( m_Mes - nCont + 12, 2 ) + "/" + StrZero( m_Ano - 1, 4 ),;
         StrZero( m_Mes - nCont, 2 ) + "/" + StrZero( m_Ano, 4 ) ), 20 )
   NEXT

   RETURN .T.

STATIC FUNCTION SomaEntradas( m_Ano, m_Mes )

   LOCAL nTotal := 0, cResumo, nTotalTmp, nSelect := Select(), nRecNo

   SELECT jpbamovi
   nRecNo := RecNo()
   GOTO TOP
   DO WHILE ! Eof()
      GrafProc()
      cResumo   := jpbamovi->baResumo
      nTotalTmp := 0
      SEEK cResumo + StrZero( m_Ano, 4 ) + StrZero( m_Mes, 2 )
      DO WHILE jpbamovi->baResumo = cResumo .AND. year( jpbamovi->baDatEmi ) == m_Ano .AND. month( jpbamovi->baDatEmi ) == m_Mes .AND. ! eof()
         GrafProc()
         IF jpbamovi->baResumo == Pad( "APLIC", 10 ) .OR. jpbamovi->baResumo == Pad( "NENHUM", 10 )
            EXIT
         ENDIF
         nTotalTmp += ValorLancto()
         SKIP
      ENDDO
      IF nTotalTmp > 0
         nTotal += nTotalTmp
      ENDIF
      SEEK cResumo + "XXXX" SOFTSEEK
   ENDDO
   GOTO nRecNo
   SELECT ( nSelect )

   RETURN nTotal

STATIC FUNCTION SomaSaidas( nAno, nMes )

   LOCAL nTotal := 0, cResumo, nTotalTmp, nSelect := Select(), nRecNo

   SELECT jpbamovi
   nRecNo := RecNo()
   GOTO TOP
   DO WHILE ! Eof()
      GrafProc()
      cResumo := jpbamovi->baResumo
      nTotalTmp := 0
      SEEK cResumo + StrZero( nAno, 4 ) + StrZero( nMes, 2 )
      DO WHILE jpbamovi->baResumo = cResumo .AND. year( jpbamovi->baDatEmi ) == nAno .AND. month( jpbamovi->baDatEmi ) == nMes .AND. ! eof()
         GrafProc()
         IF jpbamovi->baResumo == Pad( "APLIC", 10 ) .OR. jpbamovi->baResumo == Pad( "NENHUM", 10 )
            EXIT
         ENDIF
         nTotalTmp += ValorLancto()
         SKIP
      ENDDO
      IF nTotalTmp < 0
         nTotal += nTotalTmp
      ENDIF
      SEEK cResumo + "XXXX" SOFTSEEK
   ENDDO
   GOTO nRecNo
   SELECT ( nSelect )

   RETURN nTotal

STATIC FUNCTION SomaGrupo( cGrupo, nAno, nMes )

   LOCAL nTotal := 0, nSelect := Select()

   SELECT jpbagrup
   SEEK cGrupo
   DO WHILE jpbagrup->bgGrupo == cGrupo .AND. ! Eof()
      GrafProc()
      nTotal += SomaResumo( jpbagrup->bgResumo, nAno, nMes )
      SKIP
   ENDDO
   SELECT ( nSelect )

   RETURN nTotal

STATIC FUNCTION SomaResumo( cResumo, nAno, nMes )

   LOCAL nTotal := 0, nSelect := Select()

   SELECT jpbamovi
   SEEK cResumo + StrZero( nAno, 4 ) + StrZero( nMes, 2 )
   DO WHILE jpbamovi->baResumo = cResumo .AND. Year( jpbamovi->baDatEmi ) == nAno .AND. Month( jpbamovi->baDatEmi ) == nMes .AND. ! Eof()
      GrafProc()
      nTotal += ValorLancto()
      SKIP
   ENDDO
   SELECT ( nSelect )

   RETURN nTotal

STATIC FUNCTION ValorLancto()

   RETURN jpbamovi->baValor

STATIC FUNCTION PegaContas( lPrimeiraVez )

   LOCAL mLista := {}, m_Grupo

   hb_Default( @lPrimeiraVez, .F. )
   GOTO TOP
   DO WHILE ! Eof()
      GrafProc()
      AAdd( mLista, jpbagrup->bgGrupo )
      m_Grupo = jpbagrup->bgGrupo
      DO WHILE jpbagrup->bgGrupo == m_Grupo .AND. ! Eof()
         GrafProc()
         IF lPrimeiraVez .AND. jpbagrup->bgMostra == "S"
            RecLock()
            REPLACE jpbagrup->bgMostra WITH  "N"
            RecUnlock()
         ENDIF
         IF jpbagrup->bgMostra=="S"
            AAdd( mLista, jpbagrup->bgGrupo + jpbagrup->bgResumo )
         ENDIF
         SKIP
      ENDDO
   ENDDO
   AAdd( mLista, ">ENTRADAS" )
   AAdd( mLista, ">SAIDAS" )

   RETURN mLista
