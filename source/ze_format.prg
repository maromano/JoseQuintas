/*
ZE_FORMAT
José Quintas
*/

FUNCTION PicVal( nTamanho, nDecimais )

   LOCAL cPicture

   hb_Default( @nDecimais, 0 )
   cPicture  := Replicate( "9", nTamanho - nDecimais )
   cPicture  := LTrim( Transform( Val( cPicture ), "999,999,999,999,999,999" ) )
   IF nDecimais != 0
      cPicture := cPicture + "." + Replicate( "9", nDecimais )
   ENDIF
   cPicture := "@E " + cPicture

   RETURN cPicture

FUNCTION MToH( nMinutes )

   RETURN StrZero( Int( nMinutes / 60 ), 3 ) + ":" + StrZero( Mod( nMinutes, 60 ), 2 )

