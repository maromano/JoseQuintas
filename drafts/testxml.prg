/*
TESTXML - Teste simples de caracteres inválidos no XML
José Quintas
*/

#include "inkey.ch"
#include "directry.ch"

MEMVAR cFileName

PROCEDURE Main

   LOCAL cPath, aFiles, oFile, cText, cLetra, aCharList := {}, nKey := 0

   PARAMETERS cFileName

   SetMode( 40, 100 )
   CLS
   cText := MemoRead( cFileName )
   FOR EACH cLetra IN cText
      DO CASE
      CASE cLetra $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      CASE cLetra $ "abcdefghijklmnopqrstuvwxyz"
      CASE cLetra $ "0123456789"
      CASE cLetra $ ".,<># -/()=;:+$&?_%*@'"
      CASE cLetra == Chr(34)
      CASE cLetra == Chr(10)
      CASE cLetra == Chr(13)
      OTHERWISE
         ? cLetra, Asc( cLetra ), Substr( cText, Max( 0, cLetra:__EnumIndex - 30 ), 60 )
      ENDCASE
      IF nKey != K_ESC
         nKey := Inkey()
      ENDIF
      IF nKey == K_ESC
         EXIT
      ENDIF
   NEXT

   RETURN
