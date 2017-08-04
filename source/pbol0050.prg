
* PROGRAMA...: PBOL0050 - IMPRIME TXT DO ITAU                   *
* CRIACAO....: 06.03.07 - JOSE                                  *


* ...


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
   aSort( mDirList )

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
         mPosi  := At( Chr(13), mTexto + Chr(13) )
         mLinha := Substr( mTexto, 1, mPosi - 1 )
         mTexto := Substr( mTexto, mPosi + 2 )
         IF Len( AllTrim( mLinha ) ) <> 0
            AAdd( aTxtList, mLinha )
         ENDIF
      ENDDO
      oPDF:MaxRowTest()
      oPDF:DrawText( oPDF:nRow, 0, Replicate( " - ", Int( oPDF:MaxRow() / 3 ) ) )
      oPDF:nRow += 1
      oPDF:MaxRowTest()
      oPDF:DrawText( oPDF:nRow, 0, "ARQUIVO " + oElement )
      oPDF:nRow += 2

      mTemIni := .F.
      mTemFim := .F.
      FOR EACH mTexto IN aTxtList
         oPDF:MaxRowTest()
         IF Substr( mTexto, 1, 1 ) == "0"
            mTemIni := .T.
         ELSEIF Substr( mTexto, 1, 1 ) == "9"
            mTemFim := .T.
         ELSEIF Substr( mTexto, 1, 1 ) == "1"
            //mAgencia  := Substr( mTexto, 18, 4 )
            // mConta    := Substr( mTexto, 24, 6 )
            mDocBanco := Substr( mTexto, 63, 8 )
            mDocto    := Substr( mTexto, 111, 10 )
            mDatVen   := Ctod( Transform( Substr( mTexto, 121, 6 ), "@R 99/99/99" ) )
            mValor    := Val( Substr( mTexto, 127, 13 ) ) / 100
            mDatEmi   := Ctod( Transform( Substr( mTexto, 151, 6 ), "@R 99/99/99" ) )
            mJuros    := Val( Substr( mTexto, 161, 13 ) ) / 100
            // mCnpj     := FormatCnpj( Substr( mTexto, 221, 14 ) )
            mNome     := Substr( mTexto, 235, 30 )
            mCarteira := Substr( mTexto, 84, 3 )
            oPDF:DrawText( oPDF:nRow, 0, mDocBanco )
            oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, mDocto )
            oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, mNome )
            oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, mDatEmi )
            oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, mDatVen )
            oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, mValor, "99999,999.99" )
            oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, mJuros, "99999,999.99" )
            oPDF:DrawText( oPDF:nRow, oPDF:nCol + 4, mCarteira )
            oPDF:nRow += 1
         ENDIF
      NEXT
      oPDF:DrawText( oPDF:nRow, 0, Iif(mTemIni .AND. mTemFim, "Arquivo Ok", "*** Arquivo irregular ***" ) )
      oPDF:nRow += 1
   NEXT
   oPDF:End()
   CLOSE DATABASES

   RETURN
