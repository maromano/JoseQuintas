/*
PTESFILTRO - Teste do filtro automatico
José Quintas
*/

#include "hbclass.ch"
#include "inkey.ch"
#define FIELD_NAME       1
#define FIELD_COMPARE    2
#define FIELD_SELECTED   3
#define FIELD_RANGEFROM  4
#define FIELD_RANGETO    5
// Until 8, to define list

#define COMPARE_NO_FILTER          1 //
#define COMPARE_EQUAL              2 // =
#define COMPARE_GREATHER_OR_EQUAL  3 // >=
#define COMPARE_LESS_OR_EQUAL      4 // <=
#define COMPARE_GREATHER           5 // >
#define COMPARE_LESS               6 // <
#define COMPARE_NOT_EQUAL          7 // !=
#define COMPARE_RANGE              8 // >= rangefrom .AND. <= rangeto
#define COMPARE_HAS_TEXT           9 // text $ field
#define COMPARE_NOT_HAS_TEXT      10 // ! text $ field
#define COMPARE_BEGIN_WITH_TEXT   11 // field = text*
#define COMPARE_IN_TEXT           12 // field $ text
#define COMPARE_NOT_IN_TEXT       13 // ! field $ text

PROCEDURE PTESFILTRO

   LOCAL oFilter

   IF ! AbreArquivos( "jpcadas" )
      RETURN
   ENDIF

   oFilter := FilterClass():New()
   oFilter:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS FilterClass

   VAR    acFilterConfig   INIT {}
   METHOD Init()
   METHOD Filter()                                 // filter result
   METHOD FilterAsString()                         // an string with filter to be displayed
   METHOD FilterOptionsAsArray( lIncludeAll )      // an array to use as options to select
   METHOD FilterOptions()                          // an array with filter types
   METHOD Show( nRowi, nColi, nRowf, nColf )       // diplay filter string
   METHOD ChooseFilter()                           // user select filter options
   METHOD SelectFields()
   METHOD GetFieldFilter( nOpcCompare, nFieldCompare, xFieldIni, xFieldEnd )
   METHOD Execute()
   METHOD Browse( nTop, nLeft, nBottom, nRight )

   ENDCLASS

METHOD Init() CLASS FilterClass

   LOCAL acStru, nCont, xValue

   acStru := dbStruct()
   FOR nCont = 1 TO Len( acStru )
      xValue := EmptyValue( FieldGet( nCont ) )
      Aadd( ::acFilterConfig, { FieldName( nCont ), COMPARE_NO_FILTER, .F., xValue, xValue, xValue, xValue, xValue } )
   NEXT

   RETURN NIL

METHOD Filter() Class FilterClass

   LOCAL oElement, lReturn := .T., xValue

   FOR EACH oElement IN ::acFilterConfig
      xValue := FieldGet( FieldNum( oElement[ FIELD_NAME ] ) )
      DO CASE
      CASE oElement[ FIELD_COMPARE ] == COMPARE_NO_FILTER
      CASE oElement[ FIELD_COMPARE ] == COMPARE_EQUAL ;             lReturn := ( xValue == oElement[ FIELD_RANGEFROM ] )
      CASE oElement[ FIELD_COMPARE ] == COMPARE_GREATHER_OR_EQUAL ; lReturn := ( xValue >= oElement[ FIELD_RANGEFROM ] )
      CASE oElement[ FIELD_COMPARE ] == COMPARE_LESS_OR_EQUAL ;     lReturn := ( xValue <= oElement[ FIELD_RANGEFROM ] )
      CASE oElement[ FIELD_COMPARE ] == COMPARE_GREATHER ;          lReturn := ( xValue >  oElement[ FIELD_RANGEFROM ] )
      CASE oElement[ FIELD_COMPARE ] == COMPARE_LESS ;              lReturn := ( xValue <  oElement[ FIELD_RANGEFROM ] )
      CASE oElement[ FIELD_COMPARE ] == COMPARE_NOT_EQUAL ;         lReturn := ( xValue != oElement[ FIELD_RANGEFROM ] )
      CASE oElement[ FIELD_COMPARE ] == COMPARE_RANGE ;             lReturn := ( xValue >= oElement[ FIELD_RANGEFROM ] .AND. xValue <= oElement[ FIELD_RANGETO ] )
      CASE oElement[ FIELD_COMPARE ] == COMPARE_HAS_TEXT ;          lReturn := ( Trim( oElement[ FIELD_RANGEFROM ] ) $ xValue )
      CASE oElement[ FIELD_COMPARE ] == COMPARE_NOT_HAS_TEXT ;      lReturn := ( ! Trim( oElement[ FIELD_RANGEFROM ] ) $ xValue )
      CASE oElement[ FIELD_COMPARE ] == COMPARE_BEGIN_WITH_TEXT ;   lReturn := ( Substr( xValue, 1, Len( Trim( oElement[ FIELD_RANGEFROM ] ) ) ) == Trim( oElement[ FIELD_RANGEFROM ] ) )
      CASE oElement[ FIELD_COMPARE ] == COMPARE_IN_TEXT;            lReturn := ( xValue $ oElement[ FIELD_RANGEFROM ] )
      CASE oElement[ FIELD_COMPARE ] == COMPARE_NOT_IN_TEXT;        lReturn := ( ! xValue $ oElement[ FIELD_RANGEFROM ] )
      ENDCASE
      IF ! lReturn
         EXIT
      ENDIF
   NEXT

   RETURN lReturn

METHOD FilterAsString() CLASS FilterClass

   LOCAL xValue, oElement

   xValue := ""
   FOR EACH oElement IN ::acFilterConfig
      IF oElement[ FIELD_COMPARE ] != COMPARE_NO_FILTER
         xValue += oElement[ FIELD_NAME ] + " "
         xValue += ::FilterOptions()[ oElement[ FIELD_COMPARE ] ] + " "
         IF oElement[ FIELD_COMPARE ] == COMPARE_RANGE
            xValue += Trim( Transform( oElement[ FIELD_RANGEFROM ], "" ) ) + " to "
            xValue += Trim( Transform( oElement[ FIELD_RANGETO ], "" ) )
         ELSE
            xValue += Trim( Transform( oElement[ FIELD_RANGEFROM ], "" ) )
         ENDIF
         xValue += ", "
      ENDIF
   NEXT

   RETURN xValue

METHOD FilterOptionsAsArray( lIncludeAll ) CLASS FilterClass

   LOCAL xValue, acTxtFiltros := {}, oElement

   hb_Default( @lIncludeAll, .T. )
   FOR EACH oElement IN ::acFilterConfig
      xValue := oElement[ FIELD_NAME ] + " "
      IF oElement[ FIELD_COMPARE ] == COMPARE_NO_FILTER
         xValue += " No Filter "
      ELSE
         xValue += ::FilterOptions()[ oElement[ FIELD_COMPARE ] ] + " "
         IF oElement[ FIELD_COMPARE ] == COMPARE_RANGE
            xValue += Trim( Transform( oElement[ FIELD_RANGEFROM ], "" ) ) + " to " + xValue + Trim( Transform( oElement[ FIELD_RANGETO ], "" ) )
         ELSE
            xValue += Trim( Transform( oElement[ FIELD_RANGEFROM ], "" ) )
         ENDIF
      ENDIF
      IF oElement[ FIELD_COMPARE ] != COMPARE_NO_FILTER .OR. lIncludeAll
         Aadd( acTxtFiltros, xValue )
      ENDIF
   NEXT

   RETURN acTxtFiltros

METHOD FilterOptions() CLASS FilterClass

   LOCAL xValue := { "No Filter", "equal", "Greather or Equal", "Less or Equal", "Greather", "Less", "Not Equal", "Range", "Have Text", "Haven't Text", "Begin With", "In Text", "Not In Text" }

   RETURN xValue

METHOD Show( nRowi, nColi, nRowf, nColf ) CLASS FilterClass

   LOCAL cText, nLen, nCont

   nLen := nColf - nColi + 1
   cText := ::FilterAsString()
   FOR nCont = nRowi TO nRowf
      @ nCont, nColi SAY Substr( cText, ( nCont - nRowi ) * nLen + 1, nLen )
   NEXT

   RETURN NIL

METHOD ChooseFilter() CLASS FilterClass

   LOCAL nOpcField := 1, nOpcCompare, nCont, acTxtActive, nOpcActive := 1, lOk, oElement

   wOpen( 5, 0, 20, 80, "Filter" )
   DO WHILE .t.
      acTxtActive := ::FilterOptionsAsArray( .f. )
      aSize( acTxtActive, Len( acTxtActive ) + 4 )
      FOR nCont = 1 TO 4
         AIns( acTxtActive, 1 )
      NEXT
      acTxtActive[ 1 ] := "Select Fields"
      acTxtActive[ 2 ] := "Finish Filter"
      acTxtActive[ 3 ] := "Change Filter"
      acTxtActive[ 4 ] := "Reset"
      nOpcActive := Min( nOpcActive, Len( acTxtActive ) )
      Scroll( 7, 1, 19, 79, 0 )
      Achoice( 7, 1, 19, 79, acTxtActive, .t. ,,@nOpcActive )
      DO CASE
      CASE LastKey() == K_ESC
         EXIT
      CASE nOpcActive == 1
         ::SelectFields()
         LOOP
      CASE nOpcActive == 2
         lOk := .F.
         FOR EACH oElement IN ::acFilterConfig
            IF oElement[ FIELD_SELECTED ]
               lOk := .T.
               EXIT
            ENDIF
         NEXT
         IF ! lOk
            Alert( "If you do not select fields, no filter to show" )
            LOOP
         ENDIF
         EXIT
      CASE nOpcActive == 4
         FOR EACH oElement IN ::acFilterConfig
            oElement[ FIELD_COMPARE ] := COMPARE_NO_FILTER
         NEXT
         LOOP
      ENDCASE
      wOpen( 5, 0, 20, 80, "Field To Filter" )
      DO WHILE .t.
         Achoice( 7, 1, 19, 79, ::FilterOptionsAsArray(), .t.,, @nOpcField )
         IF LastKey() == K_ESC
            EXIT
         ENDIF
         wOpen( 6, 10, 20, 60, "Filter Type" )
         DO WHILE .t.
            Achoice( 8, 11, 19, 59, ::FilterOptions, .t.,, @nOpcCompare )
            IF LastKey() == K_ESC
               EXIT
            ENDIF
            ::GetFieldFilter( nOpcCompare, ;
               @::acFilterConfig[ nOpcField, FIELD_COMPARE ], ;
               @::acFilterConfig[ nOpcField, FIELD_RANGEFROM ], ;
               @::acFilterConfig[ nOpcField, FIELD_RANGETO ] )
            EXIT
         ENDDO
         wClose()
      ENDDO
      wClose()
   ENDDO
   wClose()

   RETURN LastKey() != K_ESC

METHOD SelectFields() CLASS FilterClass

   LOCAL oElement
   MEMVAR  acFields
   PRIVATE acFields := {}

   FOR EACH oElement IN ::acFilterConfig
      AAdd( acFields, iif( oElement[ FIELD_SELECTED ], "*", " " ) + " " + oElement[ FIELD_NAME ] )
   NEXT
   wOpen( 7, 10, 20, 80, "Select Fields" )
   AChoice( 8, 11, 19, 79, acFields, "", { | ... | UDFSelectField( ... ) } )
   wClose()
   FOR EACH oElement IN acFields
      ::acFilterConfig[ oElement:__EnumIndex, FIELD_SELECTED ] := ( Left( oElement, 1 ) == "*" )
   NEXT

   RETURN NIL

METHOD GetFieldFilter( nOpcCompare, nFieldCompare, xFieldIni, xFieldEnd ) CLASS FilterClass

   LOCAL GetList := {}

   DO CASE
   CASE nOpcCompare == COMPARE_NO_FILTER
      nFieldCompare := nOpcCompare
   CASE nOpcCompare == COMPARE_RANGE
      nFieldCompare := nOpcCompare
      wOpen( 10, 20, 16, 80, "From/To" )
      SetColor( "W/B,N/W,,,W/B" )
      IF ValType( xFieldIni ) == "C"
         IF Len( xFieldIni ) > 48
            @ 12, 22 GET xFieldIni PICTURE "@!S 48"
            @ 14, 22 GET xFieldEnd PICTURE "@!S 48"
         ELSE
            @ 12, 22 GET xFieldIni PICTURE "@!"
            @ 14, 22 GET xFieldEnd PICTURE "@!"
         ENDIF
      ELSE
         @ 12, 22 GET xFieldIni
         @ 14, 22 GET xFieldEnd
      ENDIF
      READ
      wClose()
   CASE nOpcCompare == COMPARE_HAS_TEXT .OR. nOpcCompare == COMPARE_NOT_HAS_TEXT .OR. nOpcCompare == COMPARE_BEGIN_WITH_TEXT
      IF ValType( xFieldIni ) != "C"
         Alert( "Valid only for String" )
      ELSE
         wOpen( 10, 20, 15, 80, "Value To Compare" )
         nFieldCompare := nOpcCompare
         SetColor( "W/B,N/W,,,W/B" )
         @ 12, 22 GET xFieldIni PICTURE "@!"
         READ
         wClose()
      ENDIF
   OTHERWISE
      nFieldCompare := nOpcCompare
      wOpen( 10, 20, 15, 80, "Value To Compare" )
      SetColor( "W/B,N/W,,,W/B" )
      IF ValType( xFieldIni ) == "C"
         @ 12, 22 GET xFieldIni PICTURE "@!"
      ELSE
         @ 12, 22 GET xFieldIni
      ENDIF
      READ
      wClose()
   ENDCASE

   RETURN NIL

METHOD Execute() CLASS FilterClass

   LOCAL nQtdRec

   DO WHILE .T.
      IF ! ::ChooseFilter()
         EXIT
      ENDIF
      SET FILTER TO ::Filter()
      COUNT TO nQtdRec
      SetColor( SetColorNormal() )
      @ 1, 0 SAY "Records in Filter:" + Str( nQtdRec )
      ::Show( MaxRow() - 2, 0, MaxRow(), MaxCol() )
      ::Browse( 2, 0, MaxRow() - 4, MaxCol() )
      SET FILTER TO
   ENDDO

   RETURN NIL

METHOD Browse( nTop, nLeft, nBottom, nRight ) CLASS FilterClass

   LOCAL oBrowse, oElement, nKey

   oBrowse := tBrowseDb( nTop, nLeft, nBottom, nRight )
   FOR EACH oElement IN ::acFilterConfig
      IF oElement[ FIELD_SELECTED ]
         oBrowse:AddColumn( TBColumnNew( oElement[ FIELD_NAME ], FieldBlock( oElement[ FIELD_NAME ] ) ) )
      ENDIF
   NEXT
   GOTO TOP
   DO WHILE .T.
      DO WHILE ! oBrowse:Stable
         oBrowse:Stabilize()
      ENDDO
      nKey := Inkey(0)
      IF nKey == K_ESC
         EXIT
      ENDIF
      oBrowse:ApplyKey( nKey )
   ENDDO
   Scroll( nTop, nLeft, nBottom, nRight, 0 )

   RETURN NIL

STATIC FUNCTION UDFSelectField( nModo, nElemento, nSelecao )   // Used in METHOD SelectFields()

   MEMVAR acFields

   IF LastKey() == K_SPACE
      acFields[ nElemento ] := iif( Left( acFields[ nElemento ], 1 ) == "*", " ", "*" ) + Substr( acFields[ nElemento ], 2 )
   ELSEIF LastKey() == K_ESC .OR. Lastkey() == K_ENTER
      RETURN 0
   ENDIF
   HB_SYMBOL_UNUSED( nModo + nSelecao )

   RETURN 2
