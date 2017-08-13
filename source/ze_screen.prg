/*
ZE_SAYSCROLL
José Quintas
*/

FUNCTION SayScroll( mTexto, lCentraliza, lMudaCor )

   LOCAL mCorAnt    := SetColor()
   LOCAL mSetDevice := Set( _SET_DEVICE, "SCREEN" )

   hb_Default( @mTexto, "" )
   hb_Default( @lCentraliza, .F. )
   hb_Default( @lMudaCor, .F. )
   IF lMudaCor
      SetColor( SetColorAlerta() )
   ELSE
      SetColor( SetColorNormal() )
   ENDIF
   IF Len( mTexto ) > MaxCol() - 1
      DO WHILE Len( mTexto ) > 0
         Scroll( 2, 0, MaxRow() - 3, MaxCol(), 1 )
         @ MaxRow() - 3, 1 SAY Pad( mTexto, MaxCol() - 1 )
         mTexto := Substr( mTexto, MaxCol() )
      ENDDO
   ELSE
      mTexto := If( lCentraliza, Padc( mTexto, MaxCol() - 1 ), mTexto )
      Scroll( 2, 0, MaxRow() - 3, MaxCol(), 1 )
      @ MaxRow() - 3, 1 SAY mTexto
   ENDIF
   SetColor( mCorAnt )
   Set( _SET_DEVICE, mSetDevice )

   RETURN NIL

FUNCTION SayScrollList( ... )

   LOCAL aParams, cText := "", nCont

   aParams := hb_aParams()
   FOR nCont = 1 TO Len( aParams )
      cText += Transform( aParams[ nCont ], "" ) + " "
   NEXT
   SayScroll( cText )

   RETURN NIL

FUNCTION Cls()

   Scroll( 1, 0, MaxRow() - 3, MaxCol(), 0 )

   RETURN NIL
