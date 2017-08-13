/*
PAUXPPRECO - PERCENTUAIS DAS TABELAS
2013.07 José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"

PROCEDURE PAUXPPRECO

   LOCAL nCont, nPercentual := Array(10), GetList := {}

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   FOR nCont = 1 TO 7
      SEEK AUX_PPRECO + StrZero( nCont, 6 )
      nPercentual[ nCont ] := Val( jptabel->axDescri )
   NEXT
   DO WHILE .T.
      @ 2, 0 SAY ""
      @ Row() + 1, 1 SAY "Percentual A...:" GET nPercentual[ 1 ]  PICTURE PicVal( 14, 2 )
      @ Row(), Col() + 2 SAY "*** Tabela Padrão"
      @ Row() + 1, 1 SAY "Percentual B...:" GET nPercentual[ 2 ]  PICTURE PicVal( 14, 2 )
      @ Row() + 1, 1 SAY "Percentual C...:" GET nPercentual[ 3 ]  PICTURE PicVal( 14, 2 )
      @ Row() + 1, 1 SAY "Percentual D...:" GET nPercentual[ 4 ]  PICTURE PicVal( 14, 2 )
      @ Row() + 1, 1 SAY "Percentual E...:" GET nPercentual[ 5 ]  PICTURE PicVal( 14, 2 )
      @ Row() + 1, 1 SAY "Percentual F...:" GET nPercentual[ 6 ]  PICTURE PicVal( 14, 2 )
      @ Row() + 1, 1 SAY "Percentual G...:" GET nPercentual[ 7 ]  PICTURE PicVal( 14, 2 )
      READ
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      IF ! MsgYesNo( "Confirma percentuais digitados" )
         LOOP
      ENDIF
      FOR nCont = 1 TO 7
         SEEK AUX_PPRECO + StrZero( nCont, 6 )
         IF Eof()
            IF nPercentual[ nCont ] != 0
               RecAppend()
               REPLACE jptabel->axTabela WITH AUX_PPRECO, jptabel->axCodigo WITH StrZero( nCont, 6 ), jptabel->axDescri WITH Str( nPercentual[ nCont ], 14, 2 )
               RecUnlock()
            ENDIF
         ELSE
            IF nPercentual[ nCont ] == 0
               RecDelete()
            ELSE
               RecLock()
               REPLACE jptabel->axDescri WITH Str( nPercentual[ nCont ], 14, 2 )
               RecUnlock()
            ENDIF
         ENDIF
      NEXT
      EXIT
   ENDDO
   CLOSE DATABASES

   RETURN
