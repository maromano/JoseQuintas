/*
ZE_LABELCLASS - Geração de etiquetas
José Quintas
*/

#include "hbclass.ch"

CREATE CLASS LabelClass

   VAR aLabel           INIT {}
   VAR nLabelQt         INIT 3   // Label Columns
   VAR nLabelSizeRows   INIT 6   // Label Size Rows
   VAR nFirstCol        INIT 3   // First Col
   VAR nLabelSizeCols   INIT 43  // Label Size Cols

   METHOD Begin()
   METHOD Add( aConteudo )
   METHOD Imprime()
   METHOD End()

   ENDCLASS

METHOD Begin() CLASS LabelClass

   SET DEVICE TO PRINT
   SetPrc( 0, 0 )

   RETURN NIL

METHOD End() CLASS LabelClass

   IF Len( ::aLabel ) > 0
      ::Imprime()
   ENDIF
   SET DEVICE TO SCREEN
   SET PRINTER TO
   SetPrc( 0, 0 )

   RETURN NIL

METHOD Add( aConteudo ) CLASS LabelClass

   IF Len( ::aLabel ) == ::nLabelQt
      ::Imprime()
      ::aLabel := {}
   ENDIF
   AAdd( ::aLabel, aConteudo )

   RETURN NIL

METHOD Imprime() CLASS LabelClass

   LOCAL nNumLin, nNumCol, nCol

   FOR nNumLin = 1 TO Len( ::aLabel[ 1 ] ) // baseado na primeira Label
      FOR nNumCol = 1 TO Len( ::aLabel )
         nCol := ::nFirstCol + ( ( nNumCol - 1 ) * ::nLabelSizeCols )
         @ pRow(), nCol SAY Pad( ::aLabel[ nNumCol, nNumLin ], ::nLabelSizeCols - 2 )
      NEXT
      @ pRow() + 1, 0 SAY ""
   NEXT
   IF ( nNumLin - 1 ) < ::nLabelSizeRows
      @ pRow() + ( ::nLabelSizeRows - ( nNumLin - 1 ) ), 0 SAY ""
   ENDIF

   RETURN NIL
