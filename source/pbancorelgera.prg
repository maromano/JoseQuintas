/*
PBANCORELGERA - LISTAGEM DA GERACAO DE LANCAMENTOS
1995.03 José Quintas
*/

#include "inkey.ch"

PROCEDURE pBancoRelGera

   LOCAL oPDF, nKey

   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi", "jpbaauto", "jpbagrup", "jpbamovi" )
      RETURN
   ENDIF
   SELECT jpbaauto
   IF ! ConfirmaImpressao()
      RETURN
   ENDIF

   oPDF := PDFClass():New()
   oPDF:SetType( 1 )
   oPDF:Begin()
   oPDF:acHeader:= { "BANCARIO", "" }
   AAdd( oPDF:acHeader, Padc( "CONTA", 17 ) + Padc( "RESUMO", 12 ) + Padc( "HISTORICO", 42 ) + Padc( "VALOR", Len( Transform( 0, PicVal(14,2) ) ) + 2 ) + Padc( "DATA", 10 ) )
   nKey = 0
   GOTO TOP
   DO WHILE nKey != K_ESC .AND. ! eof()
      nKey  = Inkey()
      oPDF:MaxRowTest()
      oPDF:DrawText( oPDF:nRow, 0, jpbaauto->buConta )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 2, jpbaauto->buresumo )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 2, jpbaauto->buHist )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 2, jpbaauto->buValor, PicVal(14,2) )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 2, jpbaauto->buData )
      oPDF:nRow += 1
      SKIP
   ENDDO
   oPDF:End()
   CLOSE DATABASES

   RETURN
