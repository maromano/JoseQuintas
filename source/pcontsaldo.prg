/*
PCONTSALDO - CONSULTA AOS VALORES DO PLANO DE CONTAS
1991.04 - José Quintas
*/

#include "inkey.ch"

PROCEDURE pContSaldo

   LOCAL mctConta, mctReduz, lCodigoNormal, nCont, nContMes, nCalcSaldo, nAnoAtual, nNumMes, GetList := {}
   LOCAL nRecNo, nAnoCalculo, nCalcDebito, nCalcCredito, lRecalculaSinteticas

   IF ! abrearquivos( "jpempre", "jptabel", "ctplano" )
      RETURN
   ENDIF
   SELECT ctplano

   mctConta      := Space( 12 )
   mctReduz      := Space(6)
   lCodigoNormal := .T.

   @  4, 2 SAY "Conta. . .:"

   @  6, 2  SAY "--mes--"
   @  6, 10 SAY " " + Padc( "Débitos", 21, "-" )
   @  6, 32 SAY " " + Padc( "Créditos", 21, "-" )
   @  6, 54 SAY " " + Padc( "Saldo Exercício", 21, "-" )
   @  6, 76 SAY " " + Padc( "Saldo Período", 21, "-" )

   @  7, 2  SAY "DEZ/"
   @  9, 2  SAY "JAN/"
   @ 11, 2  SAY "FEV/"
   @ 13, 2  SAY "MAR/"
   @ 15, 2  SAY "ABR/"
   @ 17, 2  SAY "MAI/"
   @ 19, 2  SAY "JUN/"
   @ 21, 2  SAY "JUL/"
   @ 23, 2  SAY "AGO/"
   @ 25, 2  SAY "SET/"
   @ 27, 2  SAY "OUT/"
   @ 29, 2  SAY "NOV/"
   @ 31, 2  SAY "DEZ/"

   nAnoAtual := 0
   lRecalculaSinteticas := .T.

   DO WHILE .T.
      Mensagem( "Código da conta, F9 pesquisa, F6 normal/reduz, F7 +ano, F8 -ano, ESC sai" )
      SET KEY K_F6 TO ClearGets
      SET KEY K_F7 TO ClearGets
      SET KEY K_F8 TO ClearGets
      IF lCodigoNormal
         @ 4, 13 GET mctConta PICTURE ( "@KR " + jpempre->emPicture ) VALID CTPLANOClass():Valida( @mctConta, "N", .F. )
         read
      ELSE
         @ 4, 13 SAY Space(20)
         @ 4, 13 GET mctreduz PICTURE "@K 999999" VALID CTPLANOClass():Valida( @mctreduz, "R", .F. )
         read
      ENDIF
      SET KEY K_F6 TO
      SET KEY K_F7 TO
      SET KEY K_F8 TO
      Mensagem()
      DO CASE
      CASE lastkey() == K_ESC
         EXIT
      CASE LastKey() == K_F6
         lCodigoNormal = ! lCodigoNormal
         LOOP
      CASE LastKey() == K_F7
         IF nAnoAtual < int( ( 96 - 1 ) / 12 )
            nAnoAtual += 1
         ENDIF
      CASE LastKey() == K_F8
         IF nAnoAtual > 0
            nAnoAtual -= 1
         ENDIF
      ENDCASE
      @ 4, 40 SAY ctplano->a_nome
      mctConta := Pad( Trim( Substr( ctplano->a_Codigo, 1, 11 ) ) + Right( ctplano->a_Codigo, 1 ), 12 )
      mctreduz := StrZero( Val( ctplano->a_Reduz ), 6 )

      IF ( ctplano->a_tipo == "S" .OR. Substr( ctplano->a_codigo, 1, 11 ) $ jpempre->emCodAcu ) .AND. lRecalculaSinteticas
         nRecNo = RecNo()
         RecalculaSinteticas()
         goto nRecNo
         lRecalculaSinteticas := .F.
      ENDIF

      nCalcSaldo  := ctplano->a_sdant
      nAnoCalculo := 0

      IF nAnoAtual > nAnoCalculo
         nContMes := 1
         DO WHILE nAnoAtual > nAnoCalculo
            nNumMes      := nAnoCalculo * 12 + nContMes
            nCalcDebito  := fieldget( fieldpos( "A_DEB" + StrZero( nNumMes, 2 ) ) )
            nCalcCredito := fieldget( fieldpos( "A_CRE" + StrZero( nNumMes, 2 ) ) )
            nCalcSaldo   := Round( nCalcSaldo + nCalcDebito - nCalcCredito, 2 )
            nContMes     := nContMes + 1
            IF nContmes > 12
               nContmes    := 1
               nAnoCalculo += 1
            ENDIF
         ENDDO
         IF ctplano->a_grupo == "R"
            nCalcSaldo := 0
         ELSEIF Substr( ctplano->a_codigo, 1, 11 ) $ jpempre->emCodAcu
            IF nAnoAtual > 0
               FOR nCont = 1 TO nAnoAtual * 12
                  nCalcSaldo := Round( nCalcSaldo + AppLucroDebito()[ nCont ] - AppLucroCredito()[ nCont ], 2 )
               NEXT
            ENDIF
         ENDIF
      ENDIF
      @ 7,  6 SAY StrZero( jpempre->emAnoBase + nAnoAtual - 1, 4 )
      @ 7, 52 SAY nCalcSaldo PICTURE PicVal(14,2)
      @ 7, 74 SAY nCalcSaldo PICTURE PicVal(14,2)
      FOR nCont = 1 TO 12
         nNumMes := nAnoAtual * 12 + nCont
         IF nNumMes > 96
            nCalcDebito  := 0
            nCalcCredito := 0
         ELSE
            nCalcDebito  := FieldGet( fieldpos( "A_DEB" + StrZero( nNumMes, 2 ) ) )
            nCalcCredito := FieldGet( fieldpos( "A_CRE" + StrZero( nNumMes, 2 ) ) )
         ENDIF
         nCalcSaldo = Round( nCalcSaldo + nCalcDebito - nCalcCredito, 2 )
         @ nCont * 2 + 7, 0 SAY ""
         @ Row(), 6  SAY StrZero( jpempre->emAnoBase + nAnoAtual, 4 )
         @ Row(), 10 SAY nCalcDebito  PICTURE PicVal(14,2)
         @ Row(), 32 SAY nCalcCredito PICTURE PicVal(14,2)
         @ Row(), 52 SAY nCalcSaldo   PICTURE PicVal(14,2)
         @ Row(), 74 SAY CTPLANOClass():SaldoContabil( nNumMes )  PICTURE PicVal(14,2)
      NEXT
   ENDDO
   CLOSE DATABASES

   RETURN
