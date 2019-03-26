/*
PLEISRELIMPOSTO - LISTAGEM DAS REGRAS DE TRIBUTACAO
2011.01 José Quintas
*/

#include "inkey.ch"

PROCEDURE pLeisRelImposto

   LOCAL nOpcGeral, acTxtGeral, nOpcTemp
   MEMVAR nOpcPrinterType

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso", "jpdecret" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpcadas", "jpcidade", "jpconfi", "jpempre", "jpimpos", "jpsenha", "jptabel", "jptransa", "jpuf" )
      RETURN
   ENDIF
   SELECT jpimpos

   nOpcPrinterType := AppPrinterType()

   nOpcGeral := 1
   acTxtGeral := Array(2)

   WOpen( 5, 4, 7+len(acTxtGeral), 45, "Opções disponíveis" )

   DO WHILE .T.

      acTxtGeral := { ;
         TxtImprime(), ;
         "Saida.....: " + TxtSaida()[ nOpcPrinterType ] }

      FazAchoice( 7, 5, 6+len(acTxtGeral), 44, acTxtGeral, @nOpcGeral )

      nOpcTemp := 1
      DO CASE
      CASE LastKey() == K_ESC
         EXIT

      CASE nOpcGeral == nOpcTemp++
         IF ConfirmaImpressao()
            Imprime()
         ENDIF

      CASE nOpcGeral == nOpcTemp
         WAchoice( nOpcGeral+6, 25, TxtSaida(), @nOpcPrinterType, "Saida" )
         AppPrinterType( nOpcPrinterType )

      ENDCASE
   ENDDO
   WClose()

   RETURN

STATIC FUNCTION Imprime()

   LOCAL oPDF, mimTransa, mimTriUf, mimTriCad, nKey, mimleis, nCont, mTexto, mDecret
   LOCAL cnJPDECRET := ADOClass():New( AppcnMySqlLocal() )
   MEMVAR nOpcPrinterType

   oPDF := PDFClass():New()
   oPDF:SetType( nOpcPrinterType )
   oPDF:Begin()
   oPDF:acHeader := { "", "", "", "" }
   oPDF:acHeader[ 1 ] = "LISTAGEM DAS REGRAS DE TRIBUTACAO"
   oPDF:acHeader[ 2 ] = ""
   oPDF:acHeader[ 3 ] = "              -ISS-- --II-- ---------IPI-------- ------ICMS------- -----ICMS SUBST----- ----PIS------- --COFINS------ ---DIFAL---"
   oPDF:acHeader[ 4 ] = "CODTRI -CFOP- %ALIQ. %ALIQ. CST %ALIQ. CST I ENQ CST %ALIQ. %REDUC %ALIQ. %REDUC %I.V.A CST %ALIQ. ENQ CST %ALIQ. ENQ UFS INT FCP"

   OrdSetFocus( "regra" )
   mimTransa := "X"
   mimTriUf  := "X"
   mimTriCad := "X"
   nKey := 0
   GOTO TOP
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey = Inkey()
      IF mimTransa != jpimpos->imTransa
         oPDF:MaxRowTest()
         oPDF:DrawLine( oPDF:nRow-0.5, 0, oPDF:nRow - 0.5, oPDF:MaxCol() )
         oPDF:nRow += 2
         oPDF:MaxRowTest()
         Encontra( jpimpos->imTransa, "jptransa", "numlan" )
         oPDF:DrawText( oPDF:nRow, 0, jpimpos->imTransa + " " + Trim( jptransa->trDescri ) )
         oPDF:nRow += 2
         mimTransa := jpimpos->imTransa
         mimTriUf  := "X"
         mimTriCad := "X"
      ENDIF
      IF mimTriUf != jpimpos->imTriUf .OR. mimTriCad != jpimpos->imTriCad
         oPDF:nRow += 1
         oPDF:MaxRowTest()
         oPDF:DrawText( oPDF:nRow, 0, "UF: " + jpimpos->imTriUf + " " + AUXTRIUFClass():Descricao( jpimpos->imTriUf ) )
         oPDF:nRow += 1
         oPDF:DrawText( oPDF:nRow, 3, "CAD: " + jpimpos->imTriCad  + " " + AUXTRICADClass():Descricao( jpimpos->imTriCad ) )
         oPDF:nRow += 2
         mimTriUf  := jpimpos->imTriUf
         mimTriCad := jpimpos->imTriCad
      ENDIF
      oPDF:MaxRowTest( 4 )
      oPDF:DrawText( oPDF:nRow, 6, jpimpos->imTriPro + " " + AUXTRIPROClass():Descricao( jpimpos->imTripro ) )
      oPDF:nRow += 1
      oPDF:DrawText( oPDF:nRow, 0, jpimpos->imNumLan )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, jpimpos->imCfOp )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, jpimpos->imIssAli, "999.99" )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, jpimpos->imIIAli,  "999.99" )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, Pad( jpimpos->imIpiCst, 3 ) )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, jpimpos->imIpiAli, "999.99" )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, Pad( jpimpos->imIpiCst, 3 ) )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, Pad( jpimpos->imIpiIcm, 1 ) )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, jpimpos->imIpiEnq )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, Substr( jpimpos->imIcmCst, 2, 3 ) )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, jpimpos->imIcmAli, "999.99" )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, jpimpos->imIcmRed, "999.99" )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, jpimpos->imSubAli, "999.99" )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, jpimpos->imSubRed, "999.99" )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, jpimpos->imSubIva, "999.99" )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, Pad( jpimpos->imPisCst, 3 ) )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, jpimpos->imPisAli, "999.99" )
      oPDF:DrawText( oPDF:nRow, oPDF:nCOl + 1, Pad( jpimpos->imPisEnq, 3 ) )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, Pad( jpimpos->imCofCst, 3 ) )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, jpimpos->imCofAli, "999.99" )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, Pad( jpimpos->imCofEnq, 3 ) )
      oPDF:DrawText( oPDF:nROw, oPDF:nCol + 1, jpimpos->imDifAlii, "999" )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, jpimpos->imDifAliu, "999" )
      oPDF:DrawText( oPDF:nRow, oPDF:nCol + 1, jpimpos->imDifAlif, "999" )
      oPDF:nRow += 1
      IF jpimpos->imIcsAli != 0
         oPDF:DrawText( oPDF:nRow, oPDF:MaxCol() - 100, "CRED.SIMPLES:" + Str( jpimpos->imIcsAli, 6, 2 ) )
         oPDF:nRow += 1
      ENDIF
      mimLeis := Trim( jpimpos->imLeis )
      IF Len( mimLeis ) # 0
         FOR nCont = 1 TO Len( mimLeis ) Step 7
            mDecret := Substr( mimLeis, nCont, 6 )
            IF Val( mDecret ) != 0
               IF AppcnMySqlLocal() == NIL
                  IF Encontra( mDecret, "jpdecret", "numlan" )
                     mTexto := "(" + mDecret + ") " + Trim( jpdecret->deDescr1 ) + " " + Trim( jpdecret->deDescr2 ) + Trim( jpdecret->deDescr3 ) + " " + ;
                        Trim( jpdecret->deDescr4 ) + " " + Trim( jpdecret->deDescr5 )
                  ELSE
                     mTexto := ""
                  ENDIF
               ELSE
                  cnJPDECRET:cSql := "SELECT * FROM JPDECRET WHERE DENUMLAN=" + StringSql( mDecret )
                  cnJPDECRET:Execute()
                  IF cnJPDECRET:Eof()
                     mTexto := ""
                  ELSE
                     mTexto := "(" + mDecret + ") " + cnJPDECRET:StringSql( "DEDESCR1" ) + " " + cnJPDECRET:StringSql( "DEDESCR2" ) + " " + ;
                        cnJPDECRET:StringSql( "DEDESCR3" ) + " " + cnJPDECRET:StringSql( "DEDESCR4" ) + " " + cnJPDECRET:StringSql( "DEDESCR5" )
                  ENDIF
                  cnJPDECRET:CloseRecordset()
               ENDIF
               mTexto := Trim( mTexto )
               DO WHILE Len( mTexto ) > 0
                  oPDF:MaxRowTest()
                  oPDF:DrawText( oPDF:nRow, oPDF:MaxCol() - 100, Substr( mTexto, 1, 100 ) )
                  oPDF:nRow += 1
                  mTexto := Substr( mTexto, 101 )
               ENDDO
            ENDIF
         NEXT
      ENDIF
      oPDF:nRow += 1
      SKIP
   ENDDO
   OrdSetFocus( "jpimpos1" )
   oPDF:End()

   RETURN NIL
