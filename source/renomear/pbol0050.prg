/*
PBOL0050 - IMPRIME TXT DO ITAU
2007.03 José Quintas
*/

#include "directry.ch"

PROCEDURE PBOL0050

   LOCAL oPDF, mDatEmi, mDatVen, mValor, mJuros, mCarteira, aTxtList, mTemIni, mTemFim, mDirList, mTexto, mPosi, mLinha
   LOCAL mDocBanco, mNome, mDocto, mDirItau, mDir, oElement

   IF ! AbreArquivos( "jpconfi", "jptabel", "jpempre", "jpcadas", "jpfinan", "jpnota" )
      RETURN
   ENDIF
   mDirItau := "ITAU\"
   mDir := Directory( mDirItau + "I*.txt" )

   IF Len( mDir ) == 0
      MsgWarning( "Não tem nenhum arquivo Txt Itau" )
      RETURN
   ENDIF

   mDirList := {}
   FOR EACH oElement IN mDir
      AAdd( mDirList, oElement[ F_NAME ] )
   NEXT
   ASort( mDirList )

   IF ! ConfirmaImpressao()
      CLOSE DATABASES
      RETURN
   ENDIF

   oPDF := PDFClass():New()
   oPDF:SetType( 2 )
   oPDF:Begin()
   oPDF:acHeader := { "", "", "" }
   oPDF:acHeader[ 1 ] := "ARQUIVOS ITAU"
   oPDF:acHeader[ 2 ] := ""
   oPDF:acHeader[ 3 ] := "NOSSO_N. --DOCTO--- NOME-------------------------- EMISSAO- VENCTO-- -------VALOR -------JUROS CARTEIRA"
   oPDF:PageHeader()
   FOR EACH oElement IN mDirList
      mTexto  := MemoRead( mDirItau + oElement )
      aTxtList := {}
      DO WHILE Len( mTexto ) > 0
         mPosi  := At( Chr( 13 ), mTexto + Chr( 13 ) )
         mLinha := SubStr( mTexto, 1, mPosi - 1 )
         mTexto := SubStr( mTexto, mPosi + 2 )
         IF Len( AllTrim( mLinha ) ) <> 0
            AAdd( aTxtList, mLinha )
         ENDIF
      ENDDO
      oPDF:MaxRowTest()
      oPDF:DRAWTEXT( oPDF:nRow, 0, Replicate( " - ", Int( oPDF:MaxRow() / 3 ) ) )
      oPDF:nRow += 1
      oPDF:MaxRowTest()
      oPDF:DRAWTEXT( oPDF:nRow, 0, "ARQUIVO " + oElement )
      oPDF:nRow += 2

      mTemIni := .F.
      mTemFim := .F.
      FOR EACH mTexto IN aTxtList
         oPDF:MaxRowTest()
         IF SubStr( mTexto, 1, 1 ) == "0"
            mTemIni := .T.
         ELSEIF SubStr( mTexto, 1, 1 ) == "9"
            mTemFim := .T.
         ELSEIF SubStr( mTexto, 1, 1 ) == "1"
            // mAgencia  := Substr( mTexto, 18, 4 )
            // mConta    := Substr( mTexto, 24, 6 )
            mDocBanco := SubStr( mTexto, 63, 8 )
            mDocto    := SubStr( mTexto, 111, 10 )
            mDatVen   := CToD( Transform( SubStr( mTexto, 121, 6 ), "@R 99/99/99" ) )
            mValor    := Val( SubStr( mTexto, 127, 13 ) ) / 100
            mDatEmi   := CToD( Transform( SubStr( mTexto, 151, 6 ), "@R 99/99/99" ) )
            mJuros    := Val( SubStr( mTexto, 161, 13 ) ) / 100
            // mCnpj     := FormatCnpj( Substr( mTexto, 221, 14 ) )
            mNome     := SubStr( mTexto, 235, 30 )
            mCarteira := SubStr( mTexto, 84, 3 )
            oPDF:DRAWTEXT( oPDF:nRow, 0, mDocBanco )
            oPDF:DRAWTEXT( oPDF:nRow, oPDF:nCol + 1, mDocto )
            oPDF:DRAWTEXT( oPDF:nRow, oPDF:nCol + 1, mNome )
            oPDF:DRAWTEXT( oPDF:nRow, oPDF:nCol + 1, mDatEmi )
            oPDF:DRAWTEXT( oPDF:nRow, oPDF:nCol + 1, mDatVen )
            oPDF:DRAWTEXT( oPDF:nRow, oPDF:nCol + 1, mValor, "99999,999.99" )
            oPDF:DRAWTEXT( oPDF:nRow, oPDF:nCol + 1, mJuros, "99999,999.99" )
            oPDF:DRAWTEXT( oPDF:nRow, oPDF:nCol + 4, mCarteira )
            oPDF:nRow += 1
         ENDIF
      NEXT
      oPDF:DRAWTEXT( oPDF:nRow, 0, iif( mTemIni .AND. mTemFim, "Arquivo Ok", "*** Arquivo irregular ***" ) )
      oPDF:nRow += 1
   NEXT
   oPDF:End()
   CLOSE DATABASES

   RETURN
