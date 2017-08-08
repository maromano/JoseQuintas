/*
ZE_MOUSEMENU - Substitui o PROMPT
José Quintas
*/

#include "inkey.ch"

THREAD STATIC acOpcList := {}

FUNCTION MousePrompt( nRow, nCol, cText )

   AAdd( acOpcList, { nRow, nCol, cText, nCol + Len( cText ) - 1 } )
   @ nRow, nCol SAY cText

   RETURN NIL

FUNCTION MouseMenuTo( nOpc )

   hb_Default( @nOpc, 1 )
   nOpc      := MouseMenu( aClone( acOpcList ), nOpc )
   acOpcList := {}

   RETURN nOpc

FUNCTION MouseMenu( acOpcList, nOpc, aHotKeys )

   LOCAL cFirstLet  := ""
   LOCAL cColorFocus, oThis, nKey, nPos, oElement

   hb_Default( @aHotKeys, {} )
   hb_Default( @nOpc, 1 )
   nOpc         := Max( Min( nOpc, Len( acOpcList ) ), 1 )
   cColorFocus  := Substr( SetColor(), At( ",", SetColor()) + 1 )
   cColorFocus  := Substr( cColorFocus, 1, At( ",", cColorFocus + "," ) - 1 )
   FOR EACH oElement IN acOpcList
      nPos := 1
      DO WHILE Substr( oElement[ 3 ], nPos, 1 ) $ " <" .AND. nPos < Len( oElement[ 3 ] )
         nPos += 1
      ENDDO
      cFirstLet += Upper( Substr( oElement[ 3 ], nPos, 1 ) )
   NEXT

   DO WHILE .T.
      FOR EACH oElement IN acOpcList
         @ oElement[ 1 ], oElement[ 2 ] SAY oElement[ 3 ] COLOR iif( oElement:__EnumIndex == nOpc, cColorFocus, SetColor() )
      NEXT
      nKey := Inkey(600)
      IF nKey == 0
         KEYBOARD Chr( K_ESC )
         LOOP
      ENDIF
      IF SetKey( nKey ) <> NIL
         Eval( SetKey( nKey ) )
      ENDIF
      IF ( oThis := AScan( aHotkeys, { | o | o[  1 ] == nKey } ) ) > 0
         nKey := oThis
      ENDIF
      DO CASE
      CASE nKey = K_ESC .OR. nKey == K_ENTER
         EXIT
      CASE nKey == K_LBUTTONDOWN
         IF ( oThis := AScan( acOpcList, { | o | MRow() == o[ 1 ] .AND. MCol() >= o[ 2 ] .AND. MCol() <= o[ 2 ] + Len( o[ 3 ] ) - 1 } ) ) > 0
            nOpc := oThis
            KEYBOARD Chr( K_ENTER )
         ENDIF
      CASE nKey = K_END                        ; nOpc := Len( acOpcList )
      CASE nKey = K_HOME                       ; nOpc := 1
      CASE nKey = K_LEFT .OR. nkey == K_UP     ; nOpc := IIF( nOpc == 1, Len( acOpcList ), nOpc - 1 )
      CASE nKey = K_RIGHT .OR. nKey == K_DOWN  ; nOpc := IIF( nOpc == Len( acOpcList ), 1, nOpc + 1 )
      CASE Upper( Chr( nKey ) ) $ cFirstLet
         nOpc := At( Upper( Chr( nKey ) ), cFirstLet )
         KEYBOARD Chr( K_ENTER )
      ENDCASE
   ENDDO

   RETURN nOpc
