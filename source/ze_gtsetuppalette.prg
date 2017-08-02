/*
ZE_PALETTE - paleta de cores
*/

#include "hbgtinfo.ch"

FUNCTION GtSetupPalette()

   LOCAL aPalette

   // HKCU=HKEY_CURRENT_USER
   // cRootKey := "HKCU\Software\JPA Tecnologia\"

   // IF lSave
      // aPalette := hb_GtInfo( HB_GTI_PALETTE )
      // FOR nCont = 1 TO Len( aPalette )
         // Win_RegWrite( cRootKey + "Color" + Ltrim( Str( nCont ) ), aPalette[ nCont ] )
      // NEXT
   // ELSE
      aPalette := { ;
         wapi_Rgb(  30 , 30,  30 ), ; //  0 N   Black      Preto                   New Form Font Color
         wapi_Rgb(   0,  0,   80 ), ;   //  1 B   Blue     Azul
         wapi_Rgb(   0,  63, 125 ), ; //  2 G   Green      Verde
         wapi_Rgb(   0, 133, 133 ), ; //  3 BG  Cyan       Azul Celeste            Title and Selected BackGround
         wapi_Rgb( 150,   0,   0 ), ; //  4 R   Red        Vermelho
         wapi_Rgb( 133,   0, 133 ), ; //  5 RB  Magenta    Rosa
         wapi_Rgb( 133, 133,   0 ), ; //  6 GR  Brown      Marrom
         wapi_Rgb( 180, 180, 180 ), ; //  7 W   White      Branco
         wapi_Rgb(  42,  42,  42 ), ; //  8 N+  Gray       Cinza
         wapi_Rgb(   0, 114, 198 ), ; //  9 B+  +Blue      Azul Claro
         wapi_Rgb(   0,  31,  62 ), ; // 10 G+  +Green     Azul Escuro
         wapi_Rgb( 132, 150, 173 ), ; // 11 BG+ +Cyan      Azul Celeste Claro
         wapi_Rgb( 248,   0,  38 ), ; // 12 R+  +Red       Vermelho Claro          Alert
         wapi_Rgb(  64,   0,  64 ), ; // 13 RB+ +Magenta   Rosa Claro
         wapi_Rgb( 216, 152,   0 ), ; // 14 GR+ Yellow     Amarelo
         wapi_Rgb( 255, 255, 255 ) }  // 15 W+  +White     Branco Claro            New Get and Selected Font Color

      // FOR nCont = 1 TO Len( aPalette )
         // nInfRegistro := Win_RegRead( cRootKey + "Color" + Ltrim( Str( nCont ) ) )
         // IF nInfRegistro == NIL
            // Win_RegWrite( cRootKey + "Color" + Ltrim( Str( nCont ) ), aPalette[ nCont ] )
         // ELSE
            // aPalette[ nCont ] := nInfRegistro
         // ENDIF
      // NEXT
   // ENDIF
   hb_GtInfo( HB_GTI_PALETTE, aPalette )

   RETURN NIL
