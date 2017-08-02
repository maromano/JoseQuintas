/*
REQUEST HB_CODEPAGE_PTISO

#include "inkey.ch"

FUNCTION Main()

   LOCAL cNcm := Space(8), GetList := {}, oElement, aList

   Set( _SET_CODEPAGE, "PTISO" )
   CLS
   SetMode( 30, 100 )
   DO WHILE .T.
      @ 2, 1 SAY "Código NCM a pesquisar:" GET cNcm PICTURE "@R 99.99.99.99"
      READ

      IF LastKey() == K_ESC
         EXIT
      ENDIF
      aList := CestFromNcm( cNcm )

      Scroll( 3, 0, MaxRow(), MaxCol(), 0 )
      @ 3, 0 SAY ""
      FOR EACH oElement IN aList
         @ Row() + 1, 1 SAY oElement[ 1 ] PICTURE "@R 99.99.99.99"
         @ Row(), Col() + 2 SAY oElement[ 2 ] PICTURE "@R 99.99.99.99"
         @ Row(), Col() + 2 SAY Pad( oElement[ 3 ], 60 )
      NEXT
   ENDDO

   RETURN NIL
*/

FUNCTION CestFromNcm( cNcm )

   LOCAL oCest, nCont, aList := {}

   cNcm := SoNumeros( cNcm )
   IF Len( cNcm ) == 8
      FOR nCont = 8 TO 2 STEP -1
         FOR EACH oCest IN ze_TabCest()
            IF Pad( Left( cNcm, nCont ), 8, "X" ) == oCest[ 2 ]
               AAdd( aList, oCest )
            ENDIF
         NEXT
         IF Len( aList ) > 0
            EXIT
         ENDIF
      NEXT
   ENDIF

   RETURN aList
