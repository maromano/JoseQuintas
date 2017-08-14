/*
PBANCOGERA - GERACAO DE LANCAMENTOS
1993.08 - José Quintas
*/

#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pBancoGera

   LOCAL mData
   LOCAL oFrm := BancoGeraClass():New()
   MEMVAR mRecalcAuto
   PRIVATE mRecalcAuto := .T.

   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi", "jpbaauto", "jpbagrup", "jpbamovi" )
      RETURN
   ENDIF
   SELECT jpbagrup
   SET FILTER TO jpbagrup->bgResumo != "-"
   SELECT jpbaauto
   oFrm:Execute()
   IF MsgYesNo( "Gerar lançamentos agora?" )
      Mensagem( "Aguarde... gerando lançamentos..." )
      GOTO TOP
      DO WHILE ! Eof()
         GrafProc()
         SELECT jpbamovi
         RecAppend()
         REPLACE ;
            jpbamovi->baConta  WITH jpbaauto->buConta, ;
            jpbamovi->baAplic  WITH "N", ;
            jpbamovi->baDatEmi WITH jpbaauto->buData, ;
            jpbamovi->baDatBan WITH Stod( "29991231" ), ;
            jpbamovi->baResumo WITH jpbaauto->buResumo, ;
            jpbamovi->baHist   WITH Trim( jpbaauto->buHist ) + " " + Dtoc( jpbaauto->buData ), ;
            jpbamovi->bavalor  WITH jpbaauto->buValor
         RecUnlock()
         SELECT jpbaauto
         SKIP
      ENDDO
      SELECT jpbamovi
      GOTO TOP
      RecalculoBancario()
      IF MsgYesNo( "Soma um mes nas datas?" )
         SELECT jpbaauto
         GOTO TOP
         DO WHILE ! Eof()
            mData = jpbaauto->buData + 28
            IF ( Day( mData ) > 28 .AND. Month( mData ) == 2 ) .OR. Day( mData ) == 31
               mData = UltDia(mData)
            ELSE
               DO WHILE Day( mData ) != Day( jpbaauto->buData )
                  mData += 1
               ENDDO
            ENDIF
            RecLock()
            REPLACE jpbaauto->buData WITH mData
            RecUnlock()
            SKIP
         ENDDO
      ENDIF
   ENDIF
   CLOSE DATABASES

   RETURN

CREATE CLASS BancoGeraClass INHERIT FrmCadastroClass

   METHOD Especifico( lExiste )
   METHOD TelaDados( lEdit )
   METHOD UserFunction( lProcessou )

   ENDCLASS

METHOD UserFunction( lProcessou ) CLASS BancoGeraClass

   IF ::cOpc == "C"
      FazBrowse()
      lProcessou := .T.
   ELSE
      lProcessou := .F.
   ENDIF

   RETURN lProcessou

METHOD Especifico( lExiste ) CLASS BancoGeraClass

   lExiste := .T.

   RETURN .T.

METHOD TelaDados( lEdit ) CLASS BancoGeraClass

   LOCAL GetList := {}
   LOCAL mbuConta  := jpbaauto->buConta
   LOCAL mbuResumo := jpbaauto->buResumo
   LOCAL mbuHist   := jpbaauto->buHist
   LOCAL mbuValor  := jpbaauto->buValor
   LOCAL mbuData   := jpbaauto->buData
   LOCAL mbuInfInc := jpbaauto->buInfInc
   LOCAL mbuInfAlt := jpbaauto->buInfAlt

   hb_Default( @lEdit, .F. )
   ::ShowTabs()
   @ Row()+1, 1  SAY "Conta Bancária...:" GET mbuConta   PICTURE "@K!"        VALID ValidBancarioConta( @mbuConta )
   @ Row()+1, 1  SAY "Resumo...........:" GET mbuResumo  PICTURE "@!"         VALID ValidBancarioResumo( @mbuResumo )
   @ Row()+1, 1  SAY "Histórico........:" GET mbuHist    PICTURE "@K!A"       VALID ! Empty( mbuHist )
   @ Row()+1, 1  SAY "Valor............:" GET mbuValor   PICTURE PicVal(14,2) VALID mbuValor != 0
   @ Row()+1, 1  SAY "Data.............:" GET mbuData
   @ Row()+1, 1  SAY "Inf.Inclusão.....:" GET mbuInfInc  WHEN .F.
   @ Row()+1, 1  SAY "Inf.Alteração....:" GET mbuInfAlt  WHEN .F.
   //SetPaintGetList( GetList )
   IF ! lEdit
      CLEAR GETS
      RETURN NIL
   ENDIF
   Mensagem("Digite campos, F9 Pesquisa, ESC Sai")
   READ
   Mensagem()
   IF LastKey() == K_ESC
      RETURN NIL
   ENDIF
   IF ::cOpc == "I"
      RecAppend()
      REPLACE jpbaauto->buInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE ;
      jpbaauto->buConta  WITH mbuConta, ;
      jpbaauto->buResumo WITH mbuResumo, ;
      jpbaauto->buHist   WITH mbuHist, ;
      jpbaauto->buValor  WITH mbuValor, ;
      jpbaauto->buData   WITH mbuData
   IF ::cOpc == "A"
      REPLACE jpbaauto->buInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL
