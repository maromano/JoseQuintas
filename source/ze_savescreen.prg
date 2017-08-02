/*
ZE_WINDW - TRATAMENTO DE JANELAS
1990.05.09 - José Quintas
*/

#include "hbCLASS.ch"
#include "hbgtinfo.ch"

THREAD STATIC oWindowList := {}

CREATE CLASS WindowClass STATIC

   VAR  nTop     INIT 0
   VAR  nLeft    INIT 0
   VAR  nBottom  INIT MaxRow()
   VAR  nRight   INIT MaxCol()
   VAR  cColor   INIT SetColor()
   VAR  cSave
   METHOD Open( nTop, nLeft, nBottom, nRight, cCaption, cBoxColor )
   METHOD Close()
   METHOD Save( nTop, nLeft, nBottom, nRight )
   METHOD Restore()

   ENDCLASS

METHOD Open( nTop, nLeft, nBottom, nRight, cCaption, cBoxColor ) CLASS WindowClass

   LOCAL nTamanho

   hb_Default( @nTop, 0 )
   hb_Default( @nLeft, 0 )
   hb_Default( @nBottom, MaxRow() )
   hb_Default( @nRight, MaxCol() )
   hb_Default( @cCaption, "" )
   hb_Default( @cBoxColor, SetColorBox() )
   ::Save( nTop, nLeft, nBottom + 1, nRight + 1 )
   ::cColor := SetColor()
   SetColor( SetColorBorda() )
   @ nTop, nLeft TO nBottom, nRight
   SetColor( cBoxColor )
   Scroll( nTop + 1, nLeft + 1, nBottom - 1, nRight - 1, 0 )
   IF ! Empty( cCaption )
      nTamanho := nRight - nLeft - 1
      cCaption := AllTrim( cCaption )
      IF Len( cCaption ) > nTamanho
         cCaption := Left( cCaption, nTamanho )
      ELSEIF nTamanho - Len( cCaption ) > 4
         cCaption := Space(2) + cCaption + Space(2)
      ELSEIF nTamanho - Len( cCaption ) > 2
         cCaption := " " + cCaption + " "
      ENDIF
      @ nTop, nLeft + ( ( nTamanho - Len( cCaption ) ) / 2 ) SAY cCaption COLOR SetColorTituloBox()
   ENDIF

   RETURN NIL

METHOD Close() CLASS WindowClass

   ::Restore()
   SetColor( ::cColor )

   RETURN NIL

METHOD Save( nTop, nLeft, nBottom, nRight ) CLASS WindowClass

   hb_Default( @nTop, 0 )
   hb_Default( @nLeft, 0 )
   hb_Default( @nBottom, MaxRow() )
   hb_Default( @nRight, MaxCol() )
   ::nTop     := nTop
   ::nLeft    := nLeft
   ::nBottom  := nBottom
   ::nRight   := nRight
   ::cSave    := SaveScreen( nTop, nLeft, nBottom, nRight )

   RETURN NIL

METHOD Restore() CLASS WindowClass

   RestScreen( ::nTop, ::nLeft, ::nBottom, ::nRight, ::cSave )

   RETURN NIL

FUNCTION WOpen( nTop, nLeft, nBottom, nRight, cCaption, cBoxColor )

   LOCAL oWindow := WindowClass():New()

   oWindow:Open( nTop, nLeft, nBottom, nRight, cCaption, cBoxColor )
   AAdd( oWindowList, oWindow )

   RETURN NIL

FUNCTION WClose()

   LOCAL oWindow

   IF Len( oWindowList ) != 0
      oWindow := Atail( oWindowList )
      SetColor( oWindow:cColor )
      oWindow:Restore()
      ASize( oWindowList, Len( oWindowList ) - 1 )
   ENDIF

   RETURN NIL

FUNCTION WSave( nTop, nLeft, nBottom, nRight )

   LOCAL oWindow := WindowClass():New()

   oWindow:Save( nTop, nLeft, nBottom, nRight )
   AAdd( oWindowList, oWindow )

   RETURN NIL

FUNCTION WRestore()

   LOCAL oWindow

   oWindow := Atail( oWindowList )
   oWindow:Restore()
   ASize( oWindowList, Len( oWindowList ) - 1 )

   RETURN NIL
