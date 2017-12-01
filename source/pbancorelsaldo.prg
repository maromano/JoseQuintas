/*
PBANCORELSALDO - SALDOS DAS CONTAS, NA IMPRESSORA
1992.11 José Quintas
*/

#include "inkey.ch"

PROCEDURE pBancoRelSaldo

   LOCAL m_tSaldon, m_tSaldoa, m_Saldon, m_Saldoa, mbaConta, m_Tiposd, m_Lin, nKey

   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi", "jpbaauto", "jpbagrup", "jpbamovi" )
      RETURN
   ENDIF
   m_tiposd = Mensagem( "Saldo do B Banco ou S Sistema, ESC sai", "B,S, 27" )
   IF m_tiposd == " 27"
      CLOSE DATABASES
      RETURN
   ENDIF

   IF ConfirmaImpressao()
      SELECT jpbagrup
      SET FILTER TO jpbagrup->bgResumo != "-"
      GOTO TOP
      SELECT jpbamovi
      SET DEVICE TO PRINT
      @ 0, 0   SAY "BANCARIO"
      @ 0, 48  SAY "DEMONSTRATIVO DE SALDOS - " + ;
         iif( m_tiposd = "B", "NO BANCO", "NO SISTEMA" )
      @ 0, 124 SAY "Pag. 001"
      @ 1, 0   SAY "PBANCORELSALDO"
      @ 1, 124 SAY Date()
      @ 2, 0   SAY Replicate( "-", 132 )
      @ 3, 0   SAY Space(20) + "             CONTA                    SALDO C/C       SALDO  APLICACAO       SALDO GERAL"
      @ 4, 0   SAY Space(20) + "-------------------------------  ------------------  ------------------  ------------------"
      m_lin     := 5
      nKey      := 0
      m_tsaldon := 0
      m_tsaldoa := 0
      GOTO TOP
      DO WHILE nKey != K_ESC .AND. ! eof()
         nKey     := Inkey()
         m_saldon := 0
         m_saldoa := 0
         mbaConta := jpbamovi->baconta
         DO WHILE mbaConta == jpbamovi->baconta .AND. ! eof()
            IF ! Empty( jpbamovi->baDatBan)
               IF jpbamovi->baDatBan!= Stod( "29991231" ) .OR. ( jpbamovi->baDatEmi <= Date() .AND. m_tiposd == "S" )
                  IF jpbamovi->aplic == "S"
                     m_saldoa := jpbamovi->basaldo
                  ELSE
                     m_saldon := jpbamovi->basaldo
                  ENDIF
               ENDIF
            ENDIF
            SKIP
         ENDDO
         @ m_lin, 20 SAY mbaConta
         @ m_lin, 53 SAY m_saldon PICTURE "@E 999,999,999,999.99"
         @ m_lin, 73 SAY m_saldoa PICTURE "@E 999,999,999,999.99"
         @ m_lin, 93 SAY m_saldon + m_saldoa PICTURE "@E 999,999,999,999.99"
         m_tsaldon += m_saldon
         m_tsaldoa += m_saldoa
         m_lin     += 1
      ENDDO
      @ m_lin, 53 SAY Replicate( "-", 18 )
      @ m_lin, 73 SAY Replicate( "-", 18 )
      @ m_lin, 93 SAY Replicate( "-", 18 )
      m_lin += 1
      @ m_lin, 20 SAY "*** TOTAL DAS CONTAS ***"
      @ m_lin, 53 SAY m_tsaldon PICTURE "@E 999,999,999,999.99"
      @ m_lin, 73 SAY m_tsaldoa PICTURE "@E 999,999,999,999.99"
      @ m_lin, 93 SAY m_tsaldon + m_tsaldoa PICTURE "@E 999,999,999,999.99"
      @ 62, 0 SAY Padl( " " + AppEmpresaNome(), 132, "-" )
      SET DEVICE TO SCREEN
   ENDIF
   CLOSE DATABASES

   RETURN
