/*
PNOTAXLS - GERA NOTAS EM EXCEL
2012.06 José Quintas
*/

#include "inkey.ch"

PROCEDURE pNotaXls

   LOCAL GetList := {}
   MEMVAR mDatai, mDataf, mFilial, mTransa, mVendedor

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso", "jpdecret" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpcadas", "jpcidade", "jpclista", "jpcomiss", "jpconfi", "jpempre", ;
         "jpestoq", "jpfinan", "jpforpag", "jpimpos", "jpitem", "jpitped", "jplfisc", "jpnota", "jpnumero", "jppedi", ;
         "jppreco", "jpsenha", "jptabel", "jptransa", "jpuf", "jpveicul", "jpvended" )
      RETURN
   ENDIF
   SELECT jpnota

   mDataf    := Date() - Day( Date() ) - 1
   mDatai    := mDataf - Day( mDataf ) + 1
   mFilial   := Space(6)
   mTransa   := Space(6)
   mVendedor := Space(6)

   DO WHILE .T.
      @ 2, 0 SAY "Data Inicial..:" GET mDatai
      @ 3, 0 SAY "Data Final....:" GET mDataf
      @ 4, 0 SAY "Filial........:" GET mFilial VALID Val( mFilial ) == 0 .OR. AUXFILIALClass():Valida( @mFilial )
      @ Row(), 32 SAY AUXFilialClass():Descricao( mFilial )
      @ 5, 0 SAY "Tipo Transação:" GET mTransa VALID Val(mTransa)==0 .OR. JPTRANSAClass():Valida( @mTransa )
      @ 6, 0 SAY "Vendedor......:" GET mVendedor VALID Val(mVendedor)==0 .OR. JPVENDEDClass():Valida( @mVendedor )
      Mensagem("Digite dados, zerado=todos, ESC Sai")
      READ
      Mensagem()
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      IF MsgYesNo( "Confirme geração?" )
         GeraExcel()
      ENDIF
   ENDDO
   CLOSE DATABASES

   RETURN

STATIC FUNCTION GeraExcel()

   LOCAL mTmpFile, mTab, nKey, mPicValExcel
   MEMVAR mDatai, mDataf, mFilial, mTransa, mVendedor

   mTmpFile := MyTempFile( "XLS" )

   SET ALTERNATE TO ( mTmpFile )
   SET ALTERNATE ON
   SET CONSOLE OFF
   mTab := Chr(9)
   ?? [NOTA] + mTab
   ?? [EMISSAO] + mTab
   ?? [VALOR.NF] + mTab
   ?? [ICMS.ST] + mTab
   ?? [NOME DO CLIENTE] + mTab
   ?? [VENDEDOR] + mTab
   ?
   SELECT jpnota
   OrdSetFocus( "jpnota2" )
   SEEK Dtos( mDatai ) SOFTSEEK
   nKey := 0
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey := Inkey()
      IF Empty( jpnota->nfNotFis ) // Seguranca
         SKIP
         LOOP
      ENDIF
      IF Empty( jpnota->nfDatEmi ) // Seguranca
         SKIP
         LOOP
      ENDIF
      IF Dtos( jpnota->nfDatEmi ) < Dtos( mDatai )
         SKIP
         LOOP
      ENDIF
      IF Dtos( jpnota->nfDatEmi ) > Dtos( mDataf )
         EXIT
      ENDIF
      IF jpnota->nfFilial != mFilial .AND. Val( mFilial ) != 0
         SKIP
         LOOP
      ENDIF
      Encontra( jpnota->nfPedido, "jppedi", "pedido" )
      IF jppedi->pdTransa != mTransa .AND. Val( mTransa ) != 0
         SKIP
         LOOP
      ENDIF
      IF jppedi->pdVendedor != mVendedor .AND. Val( mVendedor ) != 0
         SKIP
         LOOP
      ENDIF
      Encontra( jpnota->nfCadDes, "jpcadas", "numlan" )
      mPicValExcel := "@E 9999999999999.99"
      ?? jpnota->nfNotFis + mTab
      ?? Dtoc( jpnota->nfDatEmi ) + mTab
      ?? Transform( jpnota->nfValNot, mPicValExcel ) + mTab
      ?? Transform( jpnota->nfSubVal, mPicValExcel ) + mTab
      ?? jpnota->nfCadDes + mTab
      ?? iif( jpnota->nfStatus == "C", "CANCELADA", jpcadas->cdNome ) + mTab
      Encontra( jppedi->pdVendedor, "jpvended", "numlan" )
      ?? jppedi->pdVendedor + "-" + jpvended->vdDescri + mTab
      ?
      SKIP
   ENDDO
   SET ALTERNATE OFF
   SET ALTERNATE TO
   SET CONSOLE ON
   ShellExecuteOpen( mTmpFile )

   RETURN NIL
