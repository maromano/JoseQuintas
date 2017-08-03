/*
PCONTREDDISP - MOSTRA CODIGOS REDUZIDOS DISPONIVEIS
1993.05.19 José Quintas
*/

#include "inkey.ch"

PROCEDURE pContRedDisp

   LOCAL nCodigo, nKey, nRow, nCol, nCodigoConta

   IF ! AbreArquivos( "ctplano" )
      RETURN
   ENDIF
   SELECT ctplano
   OrdSetFocus("ctplano2")

   Mensagem( "Aguarde... Processando... ESC interrompe" )

   LOCATE FOR Val(ctplano->a_Reduz) != 0
   nCodigo := 1
   nKey    := 0
   nRow    := 0
   nCol    := 7
   DO WHILE nKey != K_ESC .AND. ! Eof()
      GrafProc()
      nKey := Inkey()
      nCodigoConta := Int( Val( ctplano->a_Reduz ) / 10 )
      IF nCodigo > nCodigoConta
         SKIP
         LOOP
      ENDIF
      IF nCodigo != nCodigoConta
         IF nCodigo + 1 == nCodigoConta
            @ nRow+3, nCol SAY Str( nCodigo, 5 ) + "-?"
         ELSE
            @ nRow+3, nCol SAY Str( nCodigo, 5 ) + "-? a " + Str( nCodigoConta - 1, 5 ) + "-?"
         ENDIF
         nRow += 1
         IF nRow > MaxRow()-4
            nCol += 22
            nRow := 0
            IF nCol > MaxCol()-22
               nCol := 7
               IF ! MsgYesNo( "Continua" )
                  EXIT
               ENDIF
               Cls()
            ENDIF
         ENDIF
      ENDIF
      nCodigo := nCodigoConta + 1
      SKIP
   ENDDO
   CLOSE DATABASES
   IF nKey != K_ESC
      @ nRow+3, nCol SAY Str( nCodigo,5 ) + "-? e posteriores"
   ENDIF
   MsgExclamation( "Fim" )
   RETURN

