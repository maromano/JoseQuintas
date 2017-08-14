/*
PBANCOCONSOLIDA - SALDO CONSOLIDADO DAS CONTAS
1994.04 José Quintas
*/

#include "inkey.ch"

PROCEDURE pBancoConsolida

   LOCAL mDataIni, m_Saldo, m_DtBco, m_DtEmi, oTBrowse
   MEMVAR mRecalcAuto, m_Filtro

   m_FIltro := {} // pra usar na funcao chamada
   mRecalcAuto := .T. // necessaria ref. recalculo
   mDataIni := Ctod("") // para uso da funcao pBancoLanca
   HB_SYMBOL_UNUSED( mRecalcAuto + mDataIni )
   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi", "jpbaauto", "jpbagrup", "jpbamovi" )
      RETURN
   ENDIF
   SELECT jpbagrup
   SET FILTER TO jpbagrup->bgResumo != "-"
   GOTO TOP
   SELECT jpbamovi

   Mensagem( "Aguarde... Efetuando cálculos..." )
   SELECT jpbamovi
   OrdSetFocus("jpbamovi3")
   GOTO TOP
   m_Saldo = 0
   DO WHILE ! eof()
      Grafproc()
      m_saldo += jpbamovi->bavalor
      RecLock()
      REPLACE jpbamovi->baSaldo WITH m_saldo
      RecUnlock()
      SKIP
   ENDDO
   GOTO BOTTOM
   m_dtbco = Ctod("")
   m_dtemi = Ctod("")
   DO WHILE ! Bof()
      GrafProc()
      IF jpbamovi->baDatBan != m_dtbco
         IF jpbamovi->baImpSld != "S"
            RecLock()
            REPLACE jpbamovi->baImpSld WITH "S"
            RecUnlock()
         ENDIF
      ELSEIF jpbamovi->baDatBan == Stod( "29991231" ) .AND. jpbamovi->baDatEmi != m_dtemi
         IF jpbamovi->baImpSld != "S"
            RecLock()
            REPLACE jpbamovi->baImpSld WITH "S"
            RecUnlock()
         ENDIF
      ELSEIF jpbamovi->baImpSld == "S"
         RecLock()
         REPLACE jpbamovi->baImpSld WITH "N"
         RecUnlock()
      ENDIF
      m_dtbco = jpbamovi->baDatBan
      m_dtemi = jpbamovi->baDatEmi
      SKIP -1
   ENDDO
   SEEK Dtos( Date() ) SOFTSEEK
   Mensagem( "I Inclui, A Altera, E Exclui, Ctrl-L Pesquisa, ESC Sai" )
      oTBrowse := { ;
      { "BANCO",         { || iif( jpbamovi->baValor == 0, Replicate( "-", 8 ), iif( jpbamovi->baDatBan == Stod( "29991231" ), Space(8), Dtoc( jpbamovi->baDatBan ) ) ) } }, ;
      { "EMISSÃO",       { || iif( jpbamovi->baValor == 0, Replicate( "-", 8 ), iif( jpbamovi->baDatEmi == Stod( "29991231" ), Space(8), Dtoc( jpbamovi->baDatEmi ) ) ) } }, ;
      { "RESUMO",        { || iif( jpbamovi->baValor == 0, Replicate( "-", Len( jpbamovi->baResumo ) ), jpbamovi->baResumo ) } }, ;
      { "HISTÓRICO",     { || iif( jpbamovi->baValor == 0, Pad( jpbamovi->baConta + iif( jpbamovi->baAplic == "S", "(Aplicação)", "" ), Len( jpbamovi->bahist ) ), jpbamovi->baHist ) } }, ;
      { "ENTRADA",       { || iif( jpbamovi->baValor > 0, Transform( Abs( jpbamovi->baValor ), PicVal(14,2) ), Space( Len( Transform( 0, PicVal(14,2) ) ) ) ) } }, ;
      { "SAÍDA",         { || iif( jpbamovi->baValor < 0, Transform( Abs( jpbamovi->baValor ), PicVal(14,2) ), Space( Len( Transform( 0, PicVal(14,2) ) ) ) ) } }, ;
      { "SALDO",         { || iif( jpbamovi->baImpSld == "S", Transform( jpbamovi->baSaldo, PicVal(14,2) ), Space( Len( Transform( jpbamovi->baSaldo, PicVal(14,2) ) ) ) ) } }, ;
      { " ",             { || ReturnValue( " ", vSay( 2, 0, "CONTA " + jpbamovi->baConta ) ) } } }
   DO WHILE .T.
      dbView( 4, 0, MaxRow() - 3, MaxCol(), oTBrowse, { | b, k | DigBancoLanca( b, k ) } )
      IF lastkey() == K_ESC
         EXIT
      ENDIF
   ENDDO
   OrdSetFocus( "jpbamovi1" )
   RecalculoBancario()
   CLOSE DATABASES

   RETURN
