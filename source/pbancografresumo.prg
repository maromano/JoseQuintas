/*
PBANCOGRAFRESUMO - MOSTRA TOTAIS/GRAFICO POR RESUMO
1992.10 José Quintas
*/

#include "inkey.ch"

MEMVAR aTotais, m_EntTot, m_SaiTot

PROCEDURE pBancoGrafResumo

   LOCAL nCont, GetList := {}, mEntVal, mValor, m_Datai, m_Dataf, oGrafico
   LOCAL m_SomaE, m_SomaS, mEntNom, oElement, mGrupoResumo := "R"

   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi", "jpbaauto", "jpbagrup", "jpbamovi" )
      RETURN
   ENDIF
   SELECT jpbagrup
   SET FILTER TO jpbaGrup->bgresumo != "-"
   GOTO TOP
   SELECT jpbamovi

   m_datai := Date() - Day( Date() ) + 1
   m_dataf := m_datai + 32
   m_dataf := m_dataf - Day( m_dataf )
   @ 3, 0 SAY "Período:" GET m_datai
   @ row(), col() + 2 SAY "ate':"  GET m_dataf
   @ 4, 0 SAY "(G)Grupo ou (R)Resumo:" GET mGrupoResumo PICTURE "!A" VALID mGrupoResumo $ "GR"
   mensagem( "Digite período a ser apresentado, ESC sai" )
   READ

   IF LastKey() == K_ESC
      CLOSE DATABASES
      RETURN
   ENDIF

   mensagem( "Efetuando cálculos..." )

   @ 3, 0 SAY "___RESUMO___        _____ENTRADAS_____  " + "______SAIDAS______  _____DIFERENCA____"

   aTotais := {}

   m_enttot = 0
   m_saitot = 0
   SomaValores( m_Datai, m_Dataf, mGrupoResumo == "G" )
   ASort( aTotais,,, { | a, b | Abs( a[ 2 ] - a[ 3 ] ) > Abs( b[ 2 ] - b[ 3 ] ) } )
   FOR nCont = 1 to Min( MaxRow() - 8, Len( aTotais ) )
      mostra( nCont + 3, aTotais[ nCont, 1 ], aTotais[ nCont, 2 ], aTotais[ nCont, 3 ] )
   NEXT
   IF Len( aTotais ) > 16
      store 0 to m_somae, m_somas
      FOR nCont = 17 TO Len( aTotais )
         grafproc()
         m_somae += aTotais[ nCont, 2 ]
         m_somas += aTotais[ nCont, 3 ]
      NEXT
      mostra( maxrow() - 4, "***OUTROS***", m_somae, m_somas )
   ENDIF
   IF MsgYesNo( "Mostrar gráfico?" )
      mEntVal := { {}, {} }
      mEntNom := {}
      FOR EACH oElement IN aTotais
         grafproc()
         mValor := oElement[ 2 ] - oElement[ 3 ]
         IF mValor > 0
            AAdd( mEntNom, Trim( oElement[ 1 ] ) )
            AAdd( mEntVal[ 1 ], mValor )
            AAdd( mEntVal[ 2 ], 0 )
         ELSEIF mValor < 0
            AAdd( mEntNom, Trim( oElement[ 1 ] ) )
            AAdd( mEntVal[ 1 ], 0 )
            AAdd( mEntVal[ 2 ], -mValor )
         ENDIF
      NEXT
      IF Len( mEntNom ) == 0
         RETURN
      ENDIF

      wSave()
      oGrafico             := BarChartClass():New()
      oGrafico:nTop        := 2
      oGrafico:nLeft       := 0
      oGrafico:nBottom     := MaxRow() - 3
      oGrafico:nRight      := MaxCol()
      oGrafico:nGradeCount := 5
      oGrafico:cTxtTitle   := "ENTRADA/SAÍDAS POR RESUMO"
      oGrafico:aTxtSubList := { "ENTRADA", "SAIDA" }
      oGrafico:aTxtBarList := mEntNom
      oGrafico:aValues     := mEntVal
      oGrafico:Show()
      MsgExclamation( "Clique OK para prosseguir" )
      WRestore()
   ENDIF
   CLOSE DATABASES

   RETURN

STATIC FUNCTION SomaValores( m_Datai, m_Dataf, lAgrupado )

   LOCAL m_Resumo, m_Num, nKey := 0, mContaGrafico

   OrdSetFocus( "jpbamovi2" )
   GOTO TOP
   DO WHILE nKey != K_ESC .AND. ! eof()
      grafproc()
      nKey := Inkey()
      IF "SALDO ANTERIOR" $ jpbamovi->baHist
         SKIP
         LOOP
      ENDIF
      m_resumo := jpbamovi->baresumo
      SEEK m_resumo + dtos( m_datai ) SOFTSEEK
      DO WHILE nKey != K_ESC .AND. jpbamovi->baResumo = m_resumo .AND. dtos( jpbamovi->baDatEmi) <= dtos( m_dataf ) .AND. ! eof()
         grafproc()
         nKey := Inkey()
         IF jpbamovi->baValor == 0 .OR. "SALDO ANTERIOR" $ jpbamovi->baHist
            SKIP
            LOOP
         ENDIF
         IF m_resumo = "NENHUM" .OR. m_resumo = "APLIC"
            EXIT
         ENDIF
         mContaGrafico := jpbamovi->baResumo
         IF lAgrupado
            Encontra( jpbamovi->baResumo, "jpbagrup", "jpbagrup1" )
            mContaGrafico := jpbagrup->bgGrupo
         ENDIF
         m_num := AScan( aTotais, { | e | e[ 1 ] == mContaGrafico } )
         IF m_num = 0
            m_num := Len( aTotais ) + 1
            AAdd( aTotais, { mContaGrafico, 0, 0 } )
         ENDIF
         IF jpbamovi->baValor > 0
            aTotais[ m_Num, 2 ] += jpbamovi->baValor
            m_enttot += jpbamovi->baValor
         ELSE
            aTotais[ m_Num, 3 ] -= jpbamovi->baValor
            m_saitot += jpbamovi->baValor
         ENDIF
         IF m_num < maxrow() - 7
            mostra( 3 + m_num, aTotais[ m_Num, 1 ], aTotais[ m_Num, 2 ], aTotais[ m_Num, 3 ] )
         ELSE
            @ maxrow() - 4, 0 SAY "??????????"
         ENDIF
         mostra( maxrow() - 3, "*** TOTAIS ***", m_enttot, m_saitot )
         SKIP
      ENDDO
      SEEK m_resumo + "99999999" SOFTSEEK
   ENDDO
   OrdSetFocus( "jpbamovi1" )

   RETURN .T.

STATIC FUNCTION mostra( m_lin, m_texto, m_entra, m_sai )

   @ m_lin, 0 SAY pad( m_texto, 20 ) + Transform( m_entra, PicVal(14,2) ) + "  " + ;
      Transform( m_sai, PicVal(14,2) ) + "  " + Transform( m_entra - m_sai, PicVal(14,2) )

   RETURN .T.
