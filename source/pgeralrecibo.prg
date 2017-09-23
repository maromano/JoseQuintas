/*
PGERALRECIBO - FORMULÄRIO RECIBO
1995.04 José Quintas
*/

#include "inkey.ch"

PROCEDURE PGeralRecibo

   LOCAL mPagador := Space(50), mMotivo := Space(200), mData := Date()
   LOCAL mEmitente := Space(50), mValor := 0, cText
   LOCAL GetList := {}, oPDF

   IF ! AbreArquivos( "jpempre" )
      RETURN
   ENDIF
   SELECT jpempre

   DO WHILE .T.
      @ 1, 0 SAY ""
      @ Row()+1, 0 SAY "Valor........:" GET mValor PICTURE PicVal(11,2)
      @ Row()+1, 0 SAY "Motivo Pagto.:" GET mMotivo PICTURE "@K!S50"
      @ Row()+1, 0 SAY "Data.........:" GET mData
      @ Row()+1, 0 SAY "Pagador......:" GET mPagador PICTURE "@K!"
      @ Row()+1, 0 SAY "Assinador....:" GET mEmitente PICTURE "@K!"
      Mensagem( "Digite campos, ESC Sai" )
      READ
      Mensagem()
      IF LastKey()== K_ESC
         EXIT
      ENDIF
      oPDF := PDFClass():New()
      oPDF:Begin()
      oPDF:AddPage()
      oPDF:nRow += 2
      oPDF:DrawText( oPDF:nRow, oPDF:MaxCol() / 2 + 3, "RECIBO" )
      oPDF:nRow += 3
      cText := "Recebi de " + Trim( mPagador ) + " a importância de " + "R$" + ;
         Ltrim( Transform( mValor, "@E 999,999,999.99" ) ) + " (" + Extenso( mValor ) + ;
         ") relativa ao pagamento de " + Trim( mMotivo ) + "."
      DO WHILE .T.
         oPDF:DrawText( oPDF:nRow, 10, TrechoJust( @cText, oPDF:MaxCol() - 20 ) )
         oPDF:nRow += 1
         IF Len( cText ) == 0
            EXIT
         ENDIF
      ENDDO
      oPDF:nRow += 2
      oPDF:DrawText( oPDF:nRow, 10, Padc( Trim( jpempre->emCidade ) + ", " + Extenso( mData ), oPDF:MaxCol() - 20 ) )
      oPDF:nRow += 4
      oPDF:DrawText( oPDF:nRow, 10, Padc( Trim( mEmitente ), oPDF:MaxCol() - 20 ) )
      oPDF:End()
   ENDDO
   CLOSE DATABASES

   RETURN
