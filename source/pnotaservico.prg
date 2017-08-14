/*
PNOTASERVICO - EMISSAO DE NOTA FISCAL DE SERVICOS
1993.07 José Quintas
*/

#include "inkey.ch"

PROCEDURE pNotaServico

   LOCAL GetList := {}, mFilial, m_Datai, m_Dataf, mTmpFile, mNumLan, mfiNumLan, mlfNumLan
   MEMVAR m_DocDat, m_DocVen, m_DocTot, mDescri, mCliente, mnfNotFis
   PRIVATE m_DocDat, m_DocVen, m_DocTot, mCliente, mDescri, mnfNotFis

   IF ! AbreArquivos( "jpnumero", "jptabel", "jpnota", "jpfinan", "jplfisc", "jpcadas", "jpclista" )
      RETURN
   ENDIF
   SELECT jpcadas

   SELECT jpcadas
   m_dataf  := Date()
   m_Dataf  := Iif( Day( m_Dataf ) < 10, m_Dataf, m_Dataf + 25 )
   m_dataf  := m_dataf - day( m_dataf )
   m_datai  := m_dataf - day( m_dataf ) + 1
   m_DocDat := Date()
   m_DocVen := Date() - Day( Date() ) + 15
   m_DocTot := 0
   mDescri  := Space(200)
   @  4, 5 SAY "Período.....: " GET m_datai
   @ Row(), Col() + 2 SAY "a"
   @ Row(), Col() + 2 GET m_dataf
   mensagem( "Digite período, ESC Sai" )
   READ
   mensagem()
   IF LastKey() == K_ESC
      RETURN
   ENDIF
   mcliente  := Space(6)
   mDescri   := Pad( "PRESTACAO DE SERVICOS", 36 )
   mFilial   := StrZero(2,6)
   mnfNotFis := Space(9)
   DO WHILE .T.
      @ 4, 0 SAY ""
      @ Row() + 1, 5 SAY "Filial......:" GET mFilial   PICTURE "@K 999999" VALID AUXFILIALClass():Valida( @mFilial )
      @ Row(), 32  SAY AUXFILIALClass():Descricao( mFilial )
      @ Row() + 1, 5 SAY "Cliente.....:" GET mCliente  PICTURE "@K 999999" VALID OkAqui( @mcliente )
      @ Row() + 1, 5 SAY "Nota Fiscal.:" GET mnfNotFis PICTURE "@K 999999999" WHEN ProximaNota( @mnfNotFis, mFilial ) VALID OkNotaLivre( @mFilial, @mnfNotFis )
      @ Row() + 1, 5 SAY "Data Docto..:" GET m_DocDat
      @ Row() + 1, 5 SAY "Vencimento..:" GET m_DocVen
      @ Row() + 1, 5 SAY "Valor.......:" GET m_DocTot  PICTURE PicVal(14,2) VALID m_DocTot > 0
      @ Row() + 1, 5 SAY "Texto Nota..:" GET mDescri   PICTURE "@!S60"
      Mensagem( "Digite campos, F9 Pesquisa, ESC Sai" )
      READ
      Mensagem()
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      IF m_DocTot < 1
         MsgWarning( "Não pode emitir NF com esse valor" )
         LOOP
      ENDIF
      IF Encontra( mFilial + Right( mnfNotFis, Len( jpnota->nfNotFis ) ), "jpnota", "notas1" )
         IF jpnota->nfStatus == "C"
            IF ! MsgYesNo( "Número de nota cancelada. Continua?" )
               LOOP
            ENDIF
         ELSE
            MsgWarning( "Nota fiscal já emitida" )
            LOOP
         ENDIF
      ENDIF
      mTmpFile := MyTempFile( "TXT" )
      SET PRINTER TO ( mTmpFile )
      ImpModA()
      SET PRINTER TO
      //   mComando := hb_DirBase() + "jpawprt.exe " + mTmpFile
      //   RunCmd( mComando )

      // Notas Fiscais

      SELECT jpnota
      IF Encontra( mFilial + mnfNotFis, "jpnota", "notas1" )
         RecDelete()
      ENDIF
      OrdSetFocus("numlan")
      mNumLan := NovoCodigo( "jpnota->nfNumLan" )
      RecAppend()
      REPLACE ;
         jpnota->nfNumLan WITH mNumLan, ;
         jpnota->nfFilial WITH mFilial, ;
         jpnota->nfNotFis WITH mnfNotFis
      REPLACE ;
         jpnota->nfDatEmi WITH m_DocDat, ;
         jpnota->nfCadDes WITH mCliente, ;
         jpnota->nfValNot WITH m_DocTot, ;
         jpnota->nfInfInc WITH LogInfo()
      RecUnlock()

      // Financeiro
      SELECT jpfinan
      OrdSetFocus( "numlan" )
      mfiNumLan := NovoCodigo( "jpfinan->fiNumLan" )
      OrdSetFocus( "jpfinan1" )
      RecAppend()
      REPLACE ;
         jpfinan->fiNumLan WITH mfiNumLan, ;
         jpfinan->fiTipLan WITH "1", ;
         jpfinan->fiFilial WITH mFilial, ;
         jpfinan->fiPedido WITH "", ;
         jpfinan->fiCliFor WITH mCliente, ;
         jpfinan->fiSacado WITH mCliente, ;
         jpfinan->fiNumDoc WITH mnfNotFis, ;
         jpfinan->fiParcela WITH StrZero( 1, Len( jpfinan->fiParcela ) ), ;
         jpfinan->fiDatEmi WITH m_DocDat, ;
         jpfinan->fiDatVen WITH m_DocVen, ;
         jpfinan->fiValor  WITH m_DocTot, ;
         jpfinan->fiCCusto WITH StrZero(1,6), ;
         jpfinan->fiOperacao WITH StrZero(1,6), ;
         jpfinan->fiPortador WITH StrZero(1,6), ;
         jpfinan->fiVendedor WITH StrZero(1,6), ;
         jpfinan->fiInfInc WITH LogInfo()

      // Livros Fiscais

      SELECT jplfisc
      OrdSetFocus("numlan")
      mlfNumLan := NovoCodigo( "jplfisc->lfNumLan" )
      OrdSetFocus( "jplfisc1" )
      RecAppend()
      REPLACE jplfisc->lfTipLan WITH "1", ;
         jplfisc->lfNumLan WITH mlfNumLan, ;
         jplfisc->lfModFis WITH "000001", ;
         jplfisc->lfDocPro WITH "P", ;
         jplfisc->lfDocSer WITH "A", ;
         jplfisc->lfDocIni WITH mnfNotFis, ;
         jplfisc->lfFilial WITH mFilial, ;
         jplfisc->lfCfOp    WITH iif( jpcadas->cdUf == "SP", "5.949", "6.949" ), ;
         jplfisc->lfCliFor  WITH mCliente, ;
         jplfisc->lfUf      WITH jpcadas->cdUf, ;
         jplfisc->lfDatLan  WITH m_DocDat, ;
         jplfisc->lfDatDoc  WITH m_DocDat, ;
         jplfisc->lfValCon  WITH m_DocTot, ;
         jplfisc->lfPedido  WITH "", ;
         jplfisc->lfInfInc  WITH LogInfo()
      RecUnlock()
      SELECT jpcadas
      GravaNumeracao( "NF-" + mFilial, StrZero( Val( mnfNotFis ) + 1, 6 ) )
   ENDDO

   RETURN

STATIC FUNCTION OkAqui( mcliente )

   LOCAL m_Ok
   MEMVAR m_TotVal, m_DocTot

   m_ok := JPCADAS1Class():Valida( @mcliente )
   m_totval = jpcadas->cdValMes
   m_DocTot = m_totval
   RETURN m_ok

STATIC FUNCTION ImpModA()

   LOCAL nCont, mImpTot
   MEMVAR m_DocDat, m_DocVen, m_DocTot, mDescri

   IF .T.
      RETURN NIL
   ENDIF
   SET DEVICE TO PRINT
   ImpCentimetros( 0, 0, "." )
   ImpCentimetros( 4, 15, "PREST.SERVICOS" )
   ImpCentimetros( 4.5, 15.5, "SUPORTE" )
   ImpCentimetros( 5, 16, Extenso( m_DocDat ) )
   ImpCentimetros( 6, 1, "Tel.JPA: (11) 2280-5776" )
   ImpCentimetros( 6.5, 2.5, jpcadas->cdNome )
   ImpCentimetros( 7, 3, Trim( jpcadas->cdEndereco ) )
   ImpCentimetros( 7, 16.5, jpcadas->cdCep )
   ImpCentimetros( 8, 3, Substr( jpcadas->cdBairro, 1, 30 ) )
   ImpCentimetros( 8, 11, jpcadas->cdCidade )
   ImpCentimetros( 8, 19, jpcadas->cdUf )
   ImpCentimetros( 8.5, 3, jpcadas->cdCnpj )
   ImpCentimetros( 8.5, 10.5, jpcadas->cdInsEst )
   ImpCentimetros( 8.5, 16, jpcadas->cdOutDoc )

   mImpTot := .T.
   FOR nCont = 1 TO 6
      ImpCentimetros ( 10.5 + ( nCont * 0.5 ), 2.5, Substr( mDescri, ( 36 * nCont - 35 ), 36) )
      IF mImpTot .AND. Len( Trim( mDescri ) ) < ( nCont ) * 36
         ImpCentimetros( 10.5 + ( nCont * 0.5 ), 16, Transform( m_DocTot, PicVal(10,2) ) )
         mImpTot := .F.
      ENDIF
   NEXT
   ImpCentimetros( 16, 16, Transform( m_DocTot, PicVal(10,2) ) )
   SET DEVICE TO SCREEN

   RETURN NIL

STATIC FUNCTION ImpCentimetros( nLin, nCol, cTexto )

   @ Round( nLin * 3.5, 0 ), Round( nCol * 6.5, 0 ) SAY cTexto

   RETURN NIL

STATIC FUNCTION OkNotaLivre( mnfFilial, mnfNotFis )

   LOCAL lRetorno := .T.

   mnfNotFis := StrZero( Val( mnfNotFis ), Len( mnfNotFis ) )
   IF Encontra( mnfFilial + mnfNotFis, "jpnota", "notas1" )
      IF jpnota->nfStatus == "C"
         IF ! MsgYesNo( "Número de nota cancelada! Continua?" )
            lRetorno := .F.
         ENDIF
      ELSE
         MsgWarning( "Nota já emitida" )
         lRetorno := .F.
      ENDIF
   ENDIF

   RETURN lRetorno
