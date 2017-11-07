/*
TEST ONLY !!!!!!!!!!!!!!!
Testing over ALLGUI\*.*
*/
#include "directry.ch"
#include "inkey.ch"
#include "hbclass.ch"

#define FMT_COMMENT_OPEN  "/" + "*"
#define FMT_COMMENT_CLOSE "*" + "/"
#define FMT_TO_UPPER      1
#define FMT_TO_LOWER      2
#define FMT_GO_AHEAD      3
#define FMT_GO_BACK       4
#define FMT_SELF_BACK     5
#define FMT_BLANK_LINE    6
#define FMT_DECLARE_VAR   7

FUNCTION Main()

   LOCAL nKey := 0, nContYes := 0, nContNo := 0

   SetMode( 40, 100 )
   CLS

   ? "Hit Alt-D to debug, ESC to quit, or any other key to continue"
   ? "Working on d:\github\allgui\"
   IF Inkey(0)  != K_ESC
      FormatDir( "d:\github\allgui\", @nKey, @nContYes, @nContNo )
   ENDIF

   RETURN NIL

STATIC FUNCTION FormatDir( cPath, nKey, nContYes, nContNo )

   LOCAL oFiles, oElement

   oFiles := Directory( cPath + "*.*", "D" )
   FOR EACH oElement IN oFiles
      DO CASE
      CASE "D" $ oElement[ F_ATTR ] .AND. oElement[ F_NAME ] == "."
      CASE "D" $ oElement[ F_ATTR ] .AND. oElement[ F_NAME ] == ".."
      CASE "D" $ oELement[ F_ATTR ]
         FormatDir( cPath + oElement[ F_NAME ] + "\", @nKey, @nContYes, @nContNo )
      CASE Upper( Right( oElement[ F_NAME ], 4 ) ) == ".PRG"
         FormatFile( cPath + oElement[ F_NAME ], @nContYes, @nContNo )
      ENDCASE
      nKey := iif( nKey == 27, nKey, Inkey() )
      IF nKey == K_ESC
         EXIT
      ENDIF
   NEXT

   RETURN NIL

STATIC FUNCTION FormatFile( cFile, nContYes, nContNo )

   LOCAL cTxtPrg, cTxtPrgAnt, acPrgLines, oElement
   LOCAL lPrg := .T.
   LOCAL oFormat := FormatClass():New()

   cTxtPrgAnt := MemoRead( cFile )
   cTxtPrg    := cTxtPrgAnt
   cTxtPrg    := StrTran( cTxtPrg, Chr(9), Space(3) )
   cTxtPrg    := StrTran( cTxtPrg, Chr(13) + Chr(10), Chr(10) )
   cTxtPrg    := StrTran( cTxtPrg, Chr(13), Chr(10) )
   acPrgLines := hb_RegExSplit( Chr(10), cTxtPrg )

   FOR EACH oElement IN acPrgLines
      oElement := Trim( oElement )
      DO CASE
      CASE IsBeginDump( oElement ) ; lPrg := .F.
      CASE ! lPrg
         IF IsEndDump( oElement )
            lPrg := .T.
         ENDIF
      OTHERWISE
         FormatIndent( @oElement, oFormat )
      ENDCASE
   NEXT
   FormatRest( @cTxtPrg, @acPrgLines )
   // save if changed
   IF ! cTxtPrg == cTxtPrgAnt
      nContYes += 1
      ? nContYes, nContNo, "Formatted " + cFile
      hb_MemoWrit( cFile, cTxtPrg )
      wapi_ShellExecute( NIL, "open", cFile,, WIN_SW_SHOWNORMAL )
      IF Mod( nContYes, 20 ) == 0
         ? "Hit any key"
         Inkey(0)
         IF LastKey() == K_ESC
            QUIT
         ENDIF
         FmtList( 0 ) // reset
      ENDIF
   ELSE
      nContNo += 1
   ENDIF

   RETURN NIL

FUNCTION FormatIndent( cLinePrg, oFormat )

   LOCAL cThisLineUpper

   LOCAL nIdent2 := 0

   cThisLineUpper := AllTrim( Upper( cLinePrg ) )
   IF Left( cThisLineUpper, 2 ) == FMT_COMMENT_OPEN .AND. ! FMT_COMMENT_CLOSE $ cThisLineUpper
      oFormat:lComment := .T. // begin comment code
   ENDIF
   IF Left( cThisLineUpper, 2 ) == FMT_COMMENT_CLOSE
      oFormat:lComment := .F. // end comment code
   ENDIF
   IF Right( cThisLineUpper, 2 ) == FMT_COMMENT_CLOSE .AND. oFormat:lComment
      oFormat:lComment := .F.
   ENDIF
   // line continuation, make ident
   IF oFormat:lContinue .AND. ! oFormat:lComment
      nIdent2 += 1
   ENDIF
   // line continuation, without comment, will ident next
   IF ! ( Left( cThisLineUpper, 1 ) == "*" .OR. Left( cThisLineUpper, 2 ) == "//" .OR. oFormat:lComment )
      oFormat:lContinue := Right( cThisLineUpper, 1 ) == ";"
   ENDIF
   // return change ident, this prevents when return is inside endif/endcase/others
   IF ! oFormat:lReturn .AND. ! oFormat:lComment
      IF IsCmdType( FMT_GO_BACK, cThisLineUpper )
         oFormat:nIdent -= 1
      ENDIF
   ENDIF
   IF ! oFormat:lComment
      FormatCase( @cLinePrg )
   ENDIF
   IF Empty( cLinePrg )
      cLinePrg := ""
   ELSE
      cLinePrg := Space( ( Max( oFormat:nIdent + nIdent2, 0 ) ) * 3 ) + AllTrim( cLinePrg )
   ENDIF
   IF oFormat:lComment
      RETURN NIL
   ENDIF
   IF IsCmdType( FMT_GO_AHEAD, cThisLineUpper )
      oFormat:nIdent += 1
   ENDIF
   IF Left( cThisLineUpper, 6 ) == "RETURN"
      oFormat:nIdent -= 1
      oFormat:lReturn := .T.
   ELSE
      oFormat:lReturn := .F.
   ENDIF
   // min column
   IF oFormat:nIdent < 0
      oFormat:nIdent := 0
   ENDIF

   RETURN NIL

FUNCTION FormatRest( cTxtPrg, acPrgLines )

   LOCAL cThisLineUpper, nLine := 1, lPrg := .T.
   LOCAL oFormat := FormatClass():New()

   cTxtPrg  := ""
   DO WHILE nLine <= Len( acPrgLines )
      cThisLineUpper := Upper( AllTrim( acPrgLines[ nLine ] ) )
      DO CASE
      CASE IsEndDump( cThisLineUpper ) ;   lPrg := .T.
      CASE ! lPrg
      CASE IsBeginDump( cThisLineUpper ) ; lPrg := .T.
      CASE oFormat:lComment .AND. IsEndComment( cThisLineUpper ); oFormat:lComment := .F.
      CASE oFormat:lComment
      CASE IsEmptyComment( cThisLineUpper )
         nLine += 1
         LOOP
      CASE IsBeginComment( cThisLineUpper ) ; oFormat:lComment := .T.
      CASE oFormat:lEmptyLine
         IF Empty( cThisLineUpper )
            nLine += 1
            LOOP
         ENDIF
      CASE IsCmdType( FMT_BLANK_LINE, cThisLineUpper );  cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      CASE Left( cThisLineUpper, 6 )  == "RETURN";       cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      ENDCASE
      IF oFormat:lDeclareVar .AND. ;
         Right( cTxtPrg, 3 ) != ";" + hb_Eol() .AND. ;
         ! IsCmdType( FMT_DECLARE_VAR, cThisLineUpper )
         oFormat:lDeclareVar := .F.
         IF ! Empty( acPrgLines[ nLine ] ) .AND. ! oFormat:lEmptyLine
            cTxtPrg += hb_Eol()
            oFormat:lEmptyLine := .T.
         ENDIF
      ENDIF
      cTxtPrg += acPrgLines[ nLine ] + hb_Eol()
      DO CASE
      CASE ! lPrg
      CASE oFormat:lComment
      CASE Right( cThisLineUpper, 1 ) == ";"
      CASE IsCmdType( FMT_BLANK_LINE,  cThisLineUpper ) ; cTxtPrg += hb_Eol(); cThisLineUpper := ""
      CASE IsCmdType( FMT_DECLARE_VAR, cThisLineUpper ) ; oFormat:lDeclareVar := .T.
      ENDCASE
      oFormat:lEmptyLine := ( Empty( cThisLineUpper ) )
      nLine += 1
   ENDDO
   DO WHILE Replicate( hb_Eol(), 3 ) $ cTxtPrg
      cTxtPrg := StrTran( cTxtPrg, Replicate( hb_Eol(), 3 ), Replicate( hb_Eol(), 2 ) )
   ENDDO

   RETURN NIL

FUNCTION FormatCase( cLinePrg )

   LOCAL oElement

   cLinePrg := AllTrim( cLinePrg )
   FOR EACH oElement IN FmtList( FMT_TO_UPPER ) DESCEND
      IF oElement == Upper( Left( cLinePrg, Len( oElement ) ) )
         cLinePrg := oElement + Substr( cLinePrg, Len( oElement ) + 1 )
         EXIT
      ENDIF
   NEXT
   FOR EACH oElement IN FmtList( FMT_TO_LOWER ) DESCEND
      IF oElement == Upper( Left( cLinePrg, Len( oElement ) ) )
         cLinePrg := oElement + Substr( cLinePrg, Len( oElement ) + 1 )
         EXIT
      ENDIF
   NEXT

   RETURN NIL

CREATE CLASS FormatClass

   VAR nIdent      INIT 0
   VAR lFormat     INIT .T.
   VAR lContinue   INIT .F.
   VAR lReturn     INIT .F.
   VAR lComment    INIT .F.
   VAR lEmptyLine  INIT .F.
   VAR lDeclareVar INIT .F.

   ENDCLASS

STATIC FUNCTION IsBeginDump( cText )

   RETURN Lower( Left( AllTrim( cText ), 17 ) ) == "#" + "pragma begindump"

STATIC FUNCTION IsEndDump( cText )

   RETURN Lower( Left( AllTrim( cText ), 15 ) ) == "#" + "pragma enddump"

STATIC FUNCTION IsBeginComment( cText )

   RETURN Left( AllTrim( cText ), 2 ) == "*" + "/" .AND. ! "*" + "/" $ cText

STATIC FUNCTION IsEndComment( cText )

   RETURN Left( AllTrim( cText ), 2 ) == "*" + "/"

STATIC FUNCTION IsEmptyComment( cText )

   LOCAL oElement

   cText := AllTrim( cText )

   DO CASE
   CASE Left( cText, 1 ) == "* "
   CASE Left( cText, 2 ) == "//"
   CASE Left( cText, 2 ) == FMT_COMMENT_OPEN .AND. Right( cText, 2 ) == FMT_COMMENT_CLOSE
   OTHERWISE
      RETURN .F.
   ENDCASE
   FOR EACH oElement IN cText
      IF ! oElement $ "/-*"
         RETURN .F.
      ENDIF
   NEXT

   RETURN .T.

FUNCTION IsCmdType( nType, cTxt )

   RETURN AScan( FmtList( nType ), { | e | Left( cTxt, Len( e ) ) == e } ) != 0

STATIC FUNCTION FmtList( nType )

   STATIC aList := {}

   IF Len( aList ) == 0 .OR. nType == 0
      aList := Array( 7 )
      aList[ FMT_TO_UPPER ]    := ReadConfig( "to_upper" )
      aList[ FMT_TO_LOWER ]    := ReadConfig( "to_lower" )
      aList[ FMT_GO_AHEAD ]    := ReadConfig( "go_ahead" )
      aList[ FMT_GO_BACK ]     := ReadConfig( "go_back" )
      aList[ FMT_SELF_BACK ]   := ReadConfig( "self_back" )
      aList[ FMT_BLANK_LINE ]  := ReadConfig( "blank_line" )
      aList[ FMT_DECLARE_VAR ] := ReadConfig( "declare_var" )
   ENDIF
   IF nType == 0
      RETURN NIL
   ENDIF

   RETURN aList[ nType ]

STATIC FUNCTION ReadConfig( cNode )

   LOCAL cXml, aList, cFile

   cFile := hb_FNameDir( hb_ProgName() ) + "hmgformat.cfg"
   cXml  := XmlNode( MemoRead( cFile ), cNode )
   aList := MultipleNodeToArray( cXml, "." )

   RETURN aList

FUNCTION XmlNode( cXml, cNode )

   LOCAL cXmlNode := "", nPOsIni, nPosFim

   nPosIni := At( "<" + cNode + ">", cXml )
   nPosFim := At( "</" + cNode + ">", cXml )
   IF nPosIni != 0 .AND. nPosFim != 0 .AND. nPosFim > nPosIni
      cXmlNode := Substr( cXml, nPosIni + 2 + Len( cNode ), nPosFim - nPosIni - Len( cNode ) - 2 )
   ENDIF

   RETURN cXmlNode

FUNCTION MultipleNodeToArray( cXml, cNode )

   LOCAL aList := {}, cEndNode, cXmlNode

   cEndNode := "</" + cNode + ">"

   DO WHILE cEndNode $ cXml
      cXmlNode := XmlNode( cXml, cNode )
      IF ! Empty( cXmlNode )
         AAdd( aList, cXmlNode )
      ENDIF
      cXml := Substr( cXml, At( cEndNode, cXml + cEndNode ) + Len( cEndNode ) )
   ENDDO

   RETURN aList
