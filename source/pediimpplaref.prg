/*
PEDIIMPPLAREF - IMPORTA SPED CONTÁBIL PLANO REFERENCIAL
2015.06 José Quintas
*/

#include "inkey.ch"

PROCEDURE pEdiImpPlaRef

   LOCAL cPastaSped  := "C:\Arquivos de Programas RFB\Programas SPED\SpedContabil\recursos\tabelas\"
   LOCAL cPatrimonio := "SPEDCONTABIL_DINAMICO_2014$SPEDECF_DINAMICA_P100*."
   LOCAL cResultado  := "SPEDCONTABIL_DINAMICO_2014$SPEDECF_DINAMICA_P150*."
   LOCAL oFiles, nCont
   LOCAL GetList := {}

   cPastaSped := Pad( cPastaSped, 100 )
   @ 10, 0 SAY "Pasta de onde serão importados os dados"
   @ 11, 0 GET cPastaSped PICTURE "@!S100"
   Mensagem( "Confirme pasta, ESC Sai" )
   READ
   IF LastKey() == K_ESC
      RETURN
   ENDIF
   cPastaSped := Trim( cPastaSped )
   IF Len( Directory( cPastaSped + cPatrimonio ) ) == 0
      MsgExclamation( "Pasta do Sped Contábil RFB não encontrada" )
      RETURN
   ENDIF
   IF Len( Directory( cPastaSped + cResultado ) ) == 0
      MsgExclamation( "Pasta do Sped Contábil RFB não encontrada" )
      RETURN
   ENDIF
   IF ! AbreArquivos( "jprefcta" )
      RETURN
   ENDIF
   IF ! MsgYesNo( "Confirma importação do plano referencial" )
      RETURN
   ENDIF

   SayScroll( "Aguarde, em processamento" )
   GOTO TOP
   DO WHILE ! Eof()
      GrafProc()
      RecLock()
      DELETE
      RecUnlock()
      SKIP
   ENDDO

   oFiles := Directory( cPastaSped + cPatrimonio )
   FOR nCont = 1 TO Len( oFiles )
      ImportaArquivo( cPastaSped + oFiles[ nCont, 1 ] )
   NEXT
   oFiles := Directory( cPastaSped + cResultado )
   FOR nCont = 1 TO Len( oFiles )
      ImportaArquivo( cPastaSped + oFiles[ nCont, 1 ] )
   NEXT
   CLOSE DATABASES
   MsgExclamation( "Ok, concluído" )

   RETURN

STATIC FUNCTION ImportaArquivo( cArquivo )

   LOCAL oFile, mrcCodigo, mrcDescri, mrcValDe, mrcValAte, mrcTipo, cTxt

   oFile := TFileRead():New( cArquivo )
   oFile:Open()
   IF oFile:Error()
      MsgExclamation( "Erro " + oFile:ErrorMsg( "FileRead:" ) )
      RETURN NIL
   ENDIF

   DO WHILE oFile:MoreToRead()
      GrafProc()
      cTxt := oFile:ReadLine()
      IF ! Substr( cTxt, 1, 1 ) $ "1234567890"
         LOOP
      ENDIF
      mrcCodigo := PegaBloco( @cTxt, "|" )
      mrcDescri := PegaBloco( @cTxt, "|" )
      mrcValDe  := PegaBloco( @cTxt, "|" )
      mrcValAte := PegaBloco( @cTxt, "|" )
      PegaBloco( @cTxt, "|" )
      mrcTipo      := PegaBloco( @cTxt, "|" ) // tipo
      RecAppend(.t.)
      REPLACE ;
         jprefcta->rcCodigo  WITH mrcCodigo, ;
         jprefcta->rcDescri  WITH mrcDescri, ;
         jprefcta->rcValDe   WITH mrcValDe, ;
         jprefcta->rcValAte  WITH mrcValAte, ;
         jprefcta->rcTipo    WITH mrcTipo
      RecUnlock()
   ENDDO
   oFile:Close()

   RETURN NIL

STATIC FUNCTION PegaBloco( cTxt, cSeparador )

   LOCAL cBloco

   cBloco := Substr( cTxt, 1, At( cSeparador, cTxt + cSeparador ) - 1 )
   cTxt   := Substr( cTxt, At( cSeparador, cTxt + cSeparador ) + 1 )

   RETURN cBloco
