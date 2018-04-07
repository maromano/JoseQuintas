/*
ZE_CALCULADORA - CALCULADORA ON-LINE
1992.04
*/

#require "gtwvg.hbc"

#include "hbgtinfo.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE Calculadora

   LOCAL oCalculator := CalculatorClass():New()
   MEMVAR  m_Prog
   PRIVATE m_Prog := "CALCULA"

   AppGuiHide()
   SET KEY K_SH_F10 TO
   oCalculator:Execute()
   AppGuiShow()
   SET KEY K_SH_F10 TO Calculadora

   RETURN

CREATE CLASS CalculatorClass STATIC

   DATA   nWidth              INIT 26
   DATA   nHeight             INIT 15
   DATA   nTop                INIT 0
   DATA   nLeft               INIT 0
   DATA   nValueTotal         INIT 0
   DATA   nValueMemory        INIT 0
   DATA   cValueDisplay       INIT ""
   DATA   cPendingOperation   INIT " "
   DATA   lBeginNumber        INIT .T.
   DATA   cSaveScreen
   DATA   acTape              INIT { " " }
   DATA   aGUIButtons         INIT {}
   DATA   acKeyboard          INIT { ;
      { "MC", "MR", "MS", "M+", "M-" }, ;
      { "T",  "C",  "CC", Chr(177),  "R" }, ;
      { "7",  "8",  "9",  "/",  "%" }, ;
      { "4",  "5",  "6",  "*",  "I" }, ;
      { "1",  "2",  "3",  "-",  "<" }, ;
      { "",   "0",  ".",   "+",  "=" } }

   METHOD Init()
   METHOD Execute()
   METHOD Number( cNumber )
   METHOD Comma()
   METHOD Back()
   METHOD Clear()
   METHOD OneDivide()
   METHOD Square()
   METHOD InvertSignal()
   METHOD Operation( cOperation )
   METHOD Percent()
   METHOD Memory()
   METHOD LoadSaveValue( lSave )
   METHOD Show()
   METHOD WriteTape( cFlag, nValue )
   METHOD ShowTape()
   METHOD Move( nKey )
   METHOD GuiShow()
   METHOD GuiDestroy()

   ENDCLASS

METHOD Init() CLASS CalculatorClass

   ::nTop  := Int( ( MaxRow() - ::nHeight ) / 2 )
   ::nLeft := Int( ( MaxCol() - ::nWidth ) / 2 )

   RETURN SELF

METHOD Execute() CLASS CalculatorClass

   LOCAL cOldColor := SetColor(), nKey, cStrKey

   ::LoadSaveValue()
   SAVE SCREEN TO ::cSaveScreen
   ::GuiShow()
   DO WHILE .T.
      ::Show()
      nKey    := Inkey(0)
      cStrKey := iif( nKey == K_ENTER, "=", Upper( Chr( nKey ) ) )
      DO CASE
      CASE nKey == K_ESC
         KEYBOARD Chr( 205 )
         Inkey(0)
         EXIT
      CASE cStrKey == "D"
         ::LoadSaveValue( .T. )
         KEYBOARD Chr( K_ESC )
      CASE nKey == K_BS .OR. cStrKey == "<"
         ::Back()
      CASE nKey == K_LEFT .OR. nKey == K_RIGHT .OR. nKey == K_UP .OR. nKey == K_DOWN .OR. nKey == K_CTRL_RIGHT ;
            .OR. nKey == K_CTRL_LEFT .OR. nKey == K_CTRL_UP .OR. nKey == K_CTRL_DOWN
         ::Move( nKey )
      CASE cStrKey $ "0123456789"
         ::Number( cStrKey )
      CASE cStrKey $ ".,"
         ::Comma()
      CASE cStrKey $ "+-*/="
         ::Operation( cStrKey )
      CASE cStrKey == "%"
         ::Percent()
      CASE cStrKey == "C"
         ::Clear()
      CASE cStrKey == Chr(177)
         ::InvertSignal()
      CASE cStrKey == "M"
         ::Memory()
      CASE cStrKey == "I"
         ::OneDivide()
      CASE cStrKey == "R"
         ::Square()
      CASE cStrKey == "T"
         ::ShowTape()
      ENDCASE
   ENDDO
   ::GuiDestroy()
   RESTORE SCREEN FROM ::cSaveScreen
   SetColor( cOldColor )

   RETURN NIL

METHOD Percent() CLASS CalculatorClass

   ::WriteTape( "%" )
   IF ::cPendingOperation $ "+-"
      ::cValueDisplay := ValToString( ::nValueTotal * Val( ::cValueDisplay ) / 100 )
   ELSEIF ::cPendingOperation == "/"
      ::cValueDisplay := ValToString( ::nValueTotal / Val( ::cValueDisplay ) * 100 )
   ELSE
      ::cValueDisplay := ValToString( Val( ::cValueDisplay ) / 100 )
   ENDIF

   RETURN NIL

METHOD Operation( cOperation ) CLASS CalculatorClass

   DO CASE
   CASE ::cPendingOperation == "+"
      ::nValueTotal := ::nValueTotal + Val( ::cValueDisplay )
   CASE ::cPendingOperation == "-"
      ::nValueTotal := ::nValueTotal - Val( ::cValueDisplay )
   CASE ::cPendingOperation == "*"
      ::nValueTotal := ::nValueTotal * Val( ::cValueDisplay )
   CASE ::cPendingOperation == "/"
      ::nValueTotal := ::nValueTotal / Val( ::cValueDisplay )
   OTHERWISE
      ::nValueTotal := Val( ::cValueDisplay )
   ENDCASE
   ::WriteTape( iif( ::cPendingOperation $ "+-*/", ::cPendingOperation, " " ) )
   ::cValueDisplay     := ValToString( ::nValueTotal )
   ::cPendingOperation := cOperation
   ::lBeginNumber      := .T.
   IF cOperation == "="
      ::WriteTape( cOperation )
      ::WriteTape()
   ENDIF

   RETURN NIL

METHOD InvertSignal() CLASS CalculatorClass

   ::WriteTape( Chr(177) )
   ::cValueDisplay := ValToString( -Val( ::cValueDisplay ) )
   ::WriteTape( "=" )

   RETURN NIL

METHOD OneDivide() CLASS CalculatorClass

   ::WriteTape( "I" )
   ::cValueDisplay := ValToString( 1 / Val( ::cValueDisplay ) )
   ::WriteTape( "=" )

   RETURN NIL

METHOD Square() CLASS CalculatorClass

   ::WriteTape( "R" )
   ::cValueDisplay := ValToString( Sqrt( Val( ::cValueDisplay ) ) )
   ::WriteTape( "=" )

   RETURN NIL

METHOD Comma() CLASS CalculatorClass

   IF ::lBeginNumber
      ::cValueDisplay := ""
   ENDIF
   ::lBeginNumber := .F.
   IF ! "." $ ::cValueDisplay
      IF Len( ::cValueDisplay ) == 0
         ::cValueDisplay += "0"
      ENDIF
      ::cValueDisplay += "."
   ENDIF

   RETURN NIL

METHOD Number( cNumber ) CLASS CalculatorClass

   IF ::lBeginNumber
      ::cValueDisplay := ""
   ENDIF
   ::lBeginNumber := .F.
   IF cNumber == "0" .AND. Len( ::cValueDisplay ) == 0
      RETURN NIL
   ENDIF
   ::cValueDisplay += cNumber

   RETURN NIL

METHOD Back() CLASS CalculatorClass

   IF Len( ::cValueDisplay ) > 0
      ::cValueDisplay := Left( ::cValueDisplay, Len( ::cValueDisplay ) - 1 )
   ENDIF

   RETURN NIL

METHOD Clear() CLASS CalculatorClass

   ::cValueDisplay = ""
   IF ::cPendingOperation == "C"
      ::nValueTotal := 0
   ENDIF
   ::cPendingOperation := "C"

   RETURN NIL

METHOD Memory() CLASS CalculatorClass

   LOCAL cStrKey := " ", nKey := 0

   DO WHILE ! cStrKey $ "CSR+-" .AND. nKey != K_BS
      nKey := Inkey(0)
      cStrKey := Upper( Chr( nKey ) )
   ENDDO
   DO CASE
   CASE cStrKey == "C"
      ::nValueMemory := 0
      ::WriteTape( "MC", 0 )
   CASE cStrKey == "R"
      ::nValueMemory := Val( ::cValueDisplay )
      ::WriteTape( "MS", Val( ::cValueDisplay ) )
   CASE cStrKey == "R"
      ::cValueDisplay := ValToString( ::nValueMemory )
   CASE cStrKey == "+"
      ::nValueMemory := ::nValueMemory + Val( ::cValueDisplay )
      ::WriteTape( "M+", Val( ::cValueDisplay ) )
   CASE cStrKey == "-"
      ::nValueMemory := ::nValueMemory - Val( ::cValueDisplay )
      ::WriteTape( "M-", Val( ::cValueDisplay ) )
   ENDCASE

   RETURN NIL

METHOD Show() CLASS CalculatorClass

   LOCAL nCont, nCont2

   DispBegin()
   SetColor( SetColorFocus() )
   @ ::nTop, ::nLeft CLEAR TO ::nTop + ::nHeight - 1, ::nLeft + ::nWidth - 1
   @ ::nTop, ::nLeft TO ::nTop + ::nHeight - 1 , ::nLeft + ::nWidth - 1
   @ ::nTop + 1, ::nLeft + 1  SAY iif( ::nValueMemory == 0, " ", "M" ) COLOR SetColorFocus()
   IF Val( ::cValueDisplay ) > 999999999999999999999999
      @ Row(), Col() SAY Padc( "OVERFLOW", ::nWidth - 4 ) COLOR SetColorAlerta()
   ELSE
      @ Row(), Col() SAY Padl( ValToString( Val( ::cValueDisplay ) ), ::nWidth - 5 ) COLOR SetColorFocus()
   ENDIF
   @ Row(), Col() SAY " " COLOR SetColorFocus()
   @ Row(), Col() SAY ::cPendingOperation COLOR SetColorFocus()
   @ ::nTop + 2, ::nLeft + 1 TO ::nTop + 2, ::nLeft + ::nWidth - 2
   FOR nCont = 1 TO Len( ::acKeyboard )
      FOR nCont2 = 1 TO Len( ::acKeyboard[ nCont ] )
         @ ::nTop + 1 + nCont * 2, ::nLeft + 1 + ( nCont2 - 1 ) * 5 SAY ::acKeyboard[ nCont, nCont2 ]
      NEXT
   NEXT
   DispEnd()

   RETURN NIL

METHOD WriteTape( cFlag, nValue ) CLASS CalculatorClass

   IF cFlag == NIL
      Aadd( ::acTape, Pad( "", ::nWidth - 2 ) )
   ELSEIF Substr( cFlag, 1, 1 ) == "M"
      AAdd( ::acTape, Padl( ValToSTring( nValue ), ::nWidth - 5 ) + " " + cFlag )
   ELSE
      Aadd( ::acTape, Padl( ValToString( Val( ::cValueDisplay ) ), ::nWidth - 4 ) + " " + cFlag )
   ENDIF

   RETURN NIL

METHOD Move( nKey ) CLASS CalculatorClass

   ::GUIDestroy()
   RESTORE SCREEN FROM ::cSaveScreen
   DO CASE
   CASE nKey == K_LEFT
      ::nLeft := Max( 0, ::nLeft - 1 )
   CASE nKey == K_RIGHT
      ::nLeft := Min( MaxCol() - ::nWidth + 1, ::nLeft + 1 )
   CASE nKey == K_UP
      ::nTop := Max( 0, ::nTop - 1 )
   CASE nKey == K_DOWN
      ::nTop := Min( MaxRow() - ::nHeight + 1, ::nTop + 1 )
   CASE nKey == K_CTRL_UP
      ::nTop := 0
   CASE nKey == K_CTRL_DOWN
      ::nTop := MaxRow() - ::nHeight + 1
   CASE nKey == K_CTRL_LEFT
      ::nLeft := 0
   CASE nKey == K_CTRL_RIGHT
      ::nLeft := MaxCol() - ::nWidth + 1
   ENDCASE
   ::GuiShow()

   RETURN NIL

METHOD ShowTape() CLASS CalculatorClass

   LOCAL cScreen

   ::GuiDestroy()
   SAVE SCREEN TO cScreen
   @ ::nTop + 1, ::nLeft + 1 CLEAR TO ::nTop + ::nHeight - 2, ::nLeft + ::nWidth - 2
   aChoice( ::nTop + 1, ::nLeft + 1, ::nTop + ::nHeight - 2, ::nLeft + ::nWidth - 2, ::acTape, .t., , Len( ::acTape ) )
   RESTORE SCREEN FROM cScreen
   ::GUIShow()

   RETURN NIL

METHOD LoadSaveValue( lSave ) CLASS CalculatorClass

   LOCAL oGet

   hb_Default( @lSave, .F. )
   oGet := GetActive()
   IF oGet != NIL
      IF oGet:Type == "N"
         IF lSave
            oGet:varPut( Val( ::cValueDisplay ) )
         ELSE
            ::cValueDisplay := ValToString( oGet:varGet() )
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION ValToString( nValue )

   LOCAL cValue := Ltrim( Str( nValue, 50, 14 ) )

   IF "." $ cValue
      DO WHILE Right( cValue, 1 ) $ "0"
         cValue := Left( cValue, Len( cValue ) - 1 )
      ENDDO
      IF Right( cValue, 1 ) == "."
         cValue := Left( cValue, Len( cValue ) - 1 )
      ENDIF
   ENDIF

   RETURN cValue

METHOD GUIShow() CLASS CalculatorClass

   LOCAL nCont, nCont2, oControl

   FOR nCont = 1 TO Len( ::acKeyboard )
      FOR nCont2 = 1 TO Len( ::acKeyboard[ nCont ] )
         oControl := wvgtstPushButton():New()
         oControl:Caption := ::acKeyboard[ nCont, nCont2 ]
         oControl:PointerFocus := .F.
         oControl:Create( , , { -( ::nTop + 1 + nCont * 2 ), -( ::nLeft + 1 + ( nCont2 - 1 ) * 5 ) }, { -1.5, -4 } )
         //         oControl:Activate := &( [{ || __Keyboard( "] + ::acKeyboard[ nCont, nCont2 ] + [" ) }] )
         oControl:Activate := BuildBlockHB_KeyPut( Asc( ::acKeyboard[ nCont, nCont2 ] ) )
         oControl:ToolTipText( KeyToolTip( oControl:Caption ) )
         Aadd( ::aGUIButtons, oControl )
      NEXT
   NEXT

   RETURN NIL

METHOD GUIDestroy() CLASS CalculatorClass

   LOCAL nCont

   FOR nCont = 1 TO Len( ::aGUIButtons )
      ::aGUIButtons[ nCont ]:Destroy()
   NEXT
   ::aGUIButtons := {}

   RETURN NIL

STATIC FUNCTION KeyToolTip( cKey )

   LOCAL cText := "", nPos
   LOCAL aList := { ;
      { "MC", "Limpa Memória" }, ;
      { "MR", "Resultado na Memória" }, ;
      { "MS", "" }, ;
      { "M+", "Soma na Memória" }, ;
      { "M-", "Tira da Memória" }, ;
      { "T", "Mostra Fita" }, ;
      { "C", "Limpa tudo" }, ;
      { "CC", "Limpa último valor" }, ;
      { Chr(177), "Inverte Sinal" }, ;
      { "R", "Raiz Quadrada" }, ;
      { "/", "Divide" }, ;
      { "%", "Percentual (/100)" }, ;
      { "*", "Multiplica" }, ;
      { "I", "" }, ;
      { "-", "Subtrai" }, ;
      { "<", "apaga último dígito" }, ;
      { "+", "Soma" }, ;
      { "=", "Encerra cálculo e/ou repete última operação" } }

   IF ( nPos := AScan( aList, { | e | e[ 1 ] == cKey } ) ) != 0
      cText := aList[ nPos, 2 ]
   ENDIF

   RETURN cText
