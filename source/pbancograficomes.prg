/*
PBANCOGRAFICOMES - GRAFICO: RESUMO MES A MES
1994.02 José Quintas
*/

#include "inkey.ch"

PROCEDURE pBancoGraficoMes

   LOCAL mDatai, mDataf, mSoma, GetList := {}, nMaxContas := 5
   LOCAL acResumo, anValor, acMeses, nContMes, nContResumo , oGrafico, nCont, oElement

   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi", "jpbaauto", "jpbagrup", "jpbamovi" )
      RETURN
   ENDIF
   acResumo := Array( nMaxContas )
   Afill( acResumo, EmptyValue( jpbamovi->baResumo ) )
   SELECT jpbagrup
   SET FILTER TO jpbagrup->bgResumo != "-"
   GOTO TOP
   SELECT jpbamovi
   OrdSetFocus( "jpbamovi2" )

   mDatai  := Date() - 360
   mDatai  -= ( Day( mDatai ) - 1 )
   mDataf  := Ultdia( Ultdia( Date() ) + 1 )
   DO WHILE .T.
      ASize( acResumo, nMaxContas )
      FOR nCont = 1 TO Len( acResumo )
         IF ValType( acResumo[ nCont ] ) != "C"
            acResumo[ nCont ] := EmptyValue( jpbamovi->baResumo )
         ENDIF
      NEXT
      @ 4, 3 SAY "Período desde...:" GET mDatai
      @ Row(), Col() + 2 SAY "ate:"  GET mDataf
      FOR EACH oElement IN acResumo
         @ Row() + 1, 3 SAY "Resumo .........:" GET oElement PICTURE "@K!" VALID Empty( oElement ) .OR. ValidBancarioResumo( @oElement )
      NEXT
      Mensagem( "Digite dados a serem apresentados, F9 Pesquisa, ESC Sai" )
      READ
      Mensagem()
      IF lastkey() == K_ESC
         CLOSE DATABASES
         EXIT
      ENDIF
      Mensagem( "Aguarde, efetuando cálculos..." )

      FOR nCont = Len( acResumo ) TO 1 STEP -1
         IF Empty( acResumo[ nCont ] )
            hb_ADel( acResumo, nCont, .T. )
         ENDIF
      NEXT
      IF Len( acResumo ) == 0
         MsgStop( "Nenhum resumo selecionado" )
         LOOP
      ENDIF

      acMeses := {}
      // pega lista dos meses disponiveis
      OrdSetFocus( "datemi" )
      SEEK Dtos( mDatai ) SOFTSEEK
      DO WHILE Dtos( jpbamovi->baDatEmi ) <= Dtos( mDataf ) .AND. ! eof()
         GrafProc()
         IF ascan( acMeses, Left( Dtos( jpbamovi->baDatEmi ), 6 ) ) == 0
            AAdd( acMeses, Left( Dtos( jpbamovi->baDatEmi ), 6 ) )
         ENDIF
         SKIP
      ENDDO
      aSort( acMeses, , , { | x, y | x > y } )

      DO WHILE Len( acMeses ) > MaxCol() / ( Len( acResumo ) + 1 )
         hb_ADel( acMeses, 1, .T. )
      ENDDO

      anValor := {}
      FOR nCont = 1 TO Len( acResumo )
         Aadd( anValor, {} )
      NEXT
      OrdSetFocus( "jpbamovi2" )
      // pega totais de cada mes
      WSave()
      FOR nContMes = 1 TO Len( acMeses )
         FOR nContResumo = 1 TO Len( acResumo )
            mSoma = 0
            GrafProc()
            SEEK acResumo[ nContResumo ] + acMeses[ nContMes ]
            DO WHILE acResumo[ nContResumo ] == jpbamovi->baResumo .AND. Left( Dtos( jpbamovi->baDatEmi), 6 ) = acMeses[ nContMes ] .AND. ! Eof()
               GrafProc()
               mSoma += jpbamovi->baValor
               SKIP
            ENDDO
            AAdd( anValor[ nContResumo ], Abs( mSoma ) )
         NEXT
         acMeses[ nContMes ] := Substr( acMeses[ nContMes ], 5, 2 ) + "/" + Substr( acMeses[ nContMes ], 3, 2 )
      NEXT
      IF Len( acMeses ) == 0
         MsgWarning( "Sem movimento!" )
         LOOP
      ENDIF

      wSave()
      oGrafico             := BarChartClass():New()
      oGrafico:nTop        := 2
      oGrafico:nLeft       := 0
      oGrafico:nBottom     := MaxRow() - 3
      oGrafico:nRight      := MaxCol()
      oGrafico:nGradeCount := 5
      oGrafico:cTxtTitle   := "COMPARATIVO MES A MES"
      oGrafico:aTxtSubList := acResumo
      oGrafico:aTxtBarList := acMeses
      oGrafico:aValues     := anValor
      oGrafico:Show()
      MsgExclamation( "Clique OK para prosseguir" )
      WRestore()
   ENDDO
   CLOSE DATABASES

   RETURN
