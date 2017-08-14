/*
PBANCOSALDO - SALDOS DAS CONTAS, NO VIDEO
1992.11 José Quintas
*/

#include "inkey.ch"

PROCEDURE pBancoSaldo

   LOCAL GetList := {}
   LOCAL nKey, m_Saldon, m_Saldoa, mbaConta, m_Data, m_Tiposd, m_tSaldon, m_tSaldoa, m_Confirm

   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi", "jpbaauto", "jpbagrup", "jpbamovi" )
      RETURN
   ENDIF
   SELECT jpbagrup
   SET FILTER TO jpbagrup->bgResumo != "-"
   GOTO TOP
   SELECT jpbamovi

   SELECT jpbamovi
   m_tiposd = "B"
   m_data   = Date()
   DO WHILE .T.
      SayScroll( Replicate( Chr(196), maxcol()+1 ) )
      SayScroll()
      IF m_tiposd == "B"
         SayScroll( "SALDOS NO BANCO" )
      ELSE
         SayScroll( "SALDOS EM " + dtoc( m_data ) + " " + "NO SISTEMA" )
      ENDIF
      SayScroll()
      SayScroll( "        CONTA               SALDO C/C       SALDO  APLICAÇÃO       SALDO GERAL  " )
      SayScroll( "--------------------  ------------------  ------------------  ------------------" )
      nKey   = 0
      m_tsaldon = 0
      m_tsaldoa = 0
      SET FILTER TO
      GOTO TOP
      DO WHILE nKey != K_ESC .AND. ! eof()
         nKey  = Inkey()
         m_saldon = 0
         m_saldoa = 0
         mbaConta = jpbamovi->baconta
         DO WHILE mbaConta == jpbamovi->baConta .AND. ! eof()
            IF ! Empty( jpbamovi->baDatBan)
               IF jpbamovi->baDatBan!= Stod( "29991231" ) .OR. ( jpbamovi->baDatEmi<= m_data .AND. m_tiposd == "S" )
                  IF jpbamovi->baAplic == "S"
                     m_saldoa = jpbamovi->baSaldo
                  ELSE
                     m_saldon = jpbamovi->baSaldo
                  ENDIF
               ENDIF
            ENDIF
            SKIP
         ENDDO
         SayScroll( mbaConta + " " + transform( m_saldon, PicVal(14,2) ) + " " + ;
                    transform( m_saldoa, PicVal(14,2)) + " " + ;
                    transform( m_saldon+m_saldoa, PicVal(14,2) ) )
         m_tsaldon += m_saldon
         m_tsaldoa += m_saldoa
      ENDDO
      SayScroll( "*** TOTAIS ***  " + transform( m_tsaldon, PicVal(14,2)) + " " + ;
                 transform( m_tsaldoa, PicVal(14,2) ) + " " + ;
                 transform( m_tsaldon+m_tsaldoa, PicVal(14,2) ) )
      IF m_tiposd == "S"
         m_confirm = Mensagem( "+- altera data, B Saldo no banco, ENTER data específica, ESC Sai", "+,-,B, 13, 27" )
      ELSE
         m_confirm = Mensagem( "S saldo no sistema, ESC sai", "S, 27" )
      ENDIF
      DO CASE
      CASE m_confirm == " 27"
         EXIT
      CASE m_confirm $ "+-"
          m_data = m_data + iif( m_confirm == "+", 1, -1 )
      CASE m_confirm $ "BS"
         m_tiposd = m_confirm
      OTHERWISE
          Mensagem( "Digite data para saldo, ESC sai" )
          @ row(), col()+2 GET m_data
          read
          Mensagem()
      ENDCASE
   ENDDO
   CLOSE DATABASES

   RETURN
