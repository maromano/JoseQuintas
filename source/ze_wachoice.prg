/*
ZE_WMENU - FUNCOES PARA MENUS
1991.04 José Quintas
*/

#include "inkey.ch"

FUNCTION FazAchoice( nTop, nLeft, nBottom, nRight, aTexto2, nOpcao )

   LOCAL cCorAnt, aSeleciona, nOpcaoAqui, oElement
   MEMVAR aTexto
   PRIVATE aTexto

   Scroll( nTop, nLeft, nBottom, nRight, 0 )
   Mensagem( "Selecione e tecle ENTER, ou código, ESC Sai" )
   nOpcaoAqui := nOpcao
   aSeleciona := {}
   aTexto     := {}
   cCorAnt    := SetColor()

   IF Left( aTexto2[ 1 ], 5 ) != " A - "
      FOR EACH oElement IN aTexto2
         IF oElement == "-"
            AAdd( aTexto, Replicate( "-", 40 ) )
            AAdd( aSeleciona, .F. )
         ELSE
            AAdd( aTexto, " " + Chr( 64 + oElement:__EnumIndex ) + " - " + oElement )
            AAdd( aSeleciona, .T. )
         ENDIF
      NEXT
   ELSE
      FOR EACH oElement IN aTexto2
         AAdd( aTexto, oElement )
         AAdd( aSeleciona, .T. )
      NEXT
   ENDIF
   IF Len( aTexto ) > ( nBottom - nTop + 1 )
      nOpcaoAqui := Achoice( nTop, nLeft, nBottom, nRight, aTexto, aSeleciona, { | m, e, p | FuncWAchoice( m, e, p ) }, nOpcaoAqui )
   ELSE
      FOR EACH oElement IN aTexto
         MousePrompt( nTop + oElement:__EnumIndex - 1, nLeft, Pad( oElement, nRight - nLeft + 1 ) )
      NEXT
      nOpcaoAqui := MouseMenuTo( nOpcaoAqui )
   ENDIF
   IF nOpcaoAqui == 0
      KEYBOARD Chr( K_ESC )
      Inkey(0)
   ELSE
      nOpcao := nOpcaoAqui
   ENDIF
   SetColor( cCorAnt )

   RETURN NIL

FUNCTION FuncWAchoice( m_modo, m_elem, m_posi )

   LOCAL nLastKey, oElement
   MEMVAR aTexto

   hb_Default( @m_Posi, 0 )
   hb_Default( @m_Modo, 0 )
   nLastKey := lastkey()

   DO CASE
   CASE nLastKey == K_ESC
      RETURN 0

   CASE nLastKey == K_ENTER
      RETURN 1

   CASE Str( nLastKey, 3 ) $ "  1, 29, 55"
      KEYBOARD Chr( K_CTRL_PGUP )

   CASE Str( nLastKey, 3 ) $ "  6, 23, 49"
      KEYBOARD Chr( K_CTRL_PGDN )

   CASE nLastKey == 50
      KEYBOARD Chr( K_DOWN )

   CASE nLastKey == 56
      KEYBOARD Chr( K_UP )

   CASE nLastKey > 64 .AND. nLastKey < 126
      FOR EACH oElement IN aTexto
         IF Upper( Chr( nLastKey ) ) == Substr( oElement, 2, 1 )
            IF oElement:__EnumIndex > m_elem
               KEYBOARD Replicate( Chr( K_DOWN ), oElement:__EnumIndex - m_elem ) + Chr(13)
            ELSEIF oElement:__EnumIndex < m_elem
               KEYBOARD Replicate( Chr( K_UP ), m_elem - oElement:__EnumIndex ) + Chr(13)
            ELSE
               KEYBOARD Chr( K_ENTER )
            ENDIF
            EXIT
         ENDIF
      NEXT

   ENDCASE

   RETURN 2

FUNCTION WAchoice( nTop, nLeft, aTexto, nOpcao, cTitulo, nTamanho )

   LOCAL nBottom, cSetColor

   cSetColor := SetColor()
   hb_Default( @nTamanho, Int( ( MaxCol() + 1 ) / 2 ) )
   hb_Default( @cTitulo, "" )
   nBottom := nTop + Len( aTexto ) + iif( Empty( cTitulo ), 1, 2 )
   IF nBottom > MaxRow() - 2
      nBottom := MaxRow() - 2
      nTop := Max( 1, nBottom - Len( aTexto ) - iif( Empty( cTitulo ), 1, 2 ) )
   ENDIF
   IF empty( cTitulo )
      WOpen( nTop, nLeft, nBottom, nLeft + nTamanho )
   ELSE
      WOpen( nTop, nLeft, nBottom, nLeft + nTamanho, cTitulo )
   ENDIF
   FazAchoice( nTop + iif( empty( cTitulo ), 1, 2 ), nLeft + 1, nBottom - 1, nLeft + nTamanho - 1, aTexto, @nOpcao )
   WClose()
   SetColor( cSetColor )

   RETURN NIL

FUNCTION WAchoiceNoClose( nTop, nLeft, aTexto, nOpcao, cTitulo, nTamanho )

   LOCAL nBottom, cSetColor

   cSetColor := SetColor()
   hb_Default( @nTamanho, int( ( MaxCol() + 1 ) / 2 ) )
   hb_Default( @cTitulo, "" )
   nBottom := nTop + Len( aTexto ) + iif( Empty( cTitulo ), 1, 2 )
   IF nBottom > MaxRow() - 2
      nBottom := MaxRow() - 2
      nTop := Max( 1, nBottom - Len( aTexto ) - iif( Empty( cTitulo ), 1, 2 ) )
   ENDIF
   IF empty( cTitulo )
      WOpen( nTop, nLeft, nBottom, nLeft + nTamanho )
   ELSE
      WOpen( nTop, nLeft, nBottom, nLeft + nTamanho, cTitulo )
   ENDIF
   Mensagem( "Selecione e tecle ENTER, ou código, ESC volta" )
   FazAchoice( nTop + iif( empty( cTitulo ), 1, 2 ), nLeft + 1, nBottom - 1, nLeft + nTamanho - 1, aTexto, @nOpcao )
   SetColor( cSetColor )

   RETURN NIL
