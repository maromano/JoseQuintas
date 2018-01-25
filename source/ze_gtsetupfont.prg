/*
ZE_SETUPFONT
José Quintas
*/

#include "hbgtinfo.ch"

FUNCTION GtSetupFont( lSave )

   STATIC sFontSize := 0, sFontWidth := 0, sFontWeight := 0
   LOCAL  nFontSize, nFontWidth, nFontWeight, cRootKey

   hb_Default( @lSave, .F. )

   cRootKey := "HKCU\Software\JPA Tecnologia\"

   IF lSave
      nFontSize   := hb_gtInfo( HB_GTI_FONTSIZE )
      nFontWidth  := hb_gtInfo( HB_GTI_FONTWIDTH )
      nFontWeight := hb_gtInfo( HB_GTI_FONTWEIGHT )
      IF nFontSize != sFontSize .OR. nFontWidth != sFontWidth .OR. nFontWeight != sFontWeight
         sFontSize   := nFontSize
         sFontWidth  := nFontWidth
         sFontWeight := nFontweight
         Win_RegWrite( cRootKey + "FontSize",   LTrim( Str( sFontSize ) ) )
         Win_RegWrite( cRootKey + "FontWidth",  LTrim( Str( sFontWidth ) ) )
         Win_RegWrite( cRootKey + "FontWeight", LTrim( Str( sFontWeight ) ) )
      ENDIF
   ELSE
      AddExtraFonts()
      hb_GtInfo( HB_GTI_FONTNAME, "Office Code Pro" )
      IF Win_RegRead( cRootKey + "FontSize" ) != NIL
         sFontSize   := Val( Win_RegRead( cRootKey + "FontSize" ) )
         sFontWidth  := Val( Win_RegRead( cRootKey + "FontWidth" ) )
         sFontWeight := Val( Win_RegRead( cRootKey + "FontWeight" ) )
         IF sFontSize > 0 .AND. sFontWidth > 0 .AND. sFontWeight > 0
            hb_gtInfo( HB_GTI_FONTSIZE,   sFontSize )
            hb_gtInfo( HB_GTI_FONTWIDTH,  sFontWidth )
            hb_gtInfo( HB_GTI_FONTWEIGHT, sFontWeight )
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION AddExtraFonts()

   STATIC lAvailable := .F.

   IF ! lAvailable
      AddFontFromMem( ResourceTTFOfficeCode() )
      AddFontFromMem( ResourceTTFStop() )
      lAvailable := .T.
   ENDIF

   RETURN NIL

STATIC FUNCTION AddFontFromMem( cFontTxt )

   RETURN wapi_AddFontMemResourceEx( @cFontTxt, Len( cFontTxt ), 0, 1 )

STATIC FUNCTION ResourceTTFOfficeCode()

   #pragma __binarystreaminclude "..\resource\officecodepro-regular.ttf"   | RETURN %s

STATIC FUNCTION ResourceTTFStop()

   #pragma __binarystreaminclude "..\resource\stopn.ttf"   | RETURN %s
