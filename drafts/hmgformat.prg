/*
TEST ONLY !!!!!!!!!!!!!!!
Testing over OOHG samples.
*/
#include "directry.ch"
#include "inkey.ch"
#include "hbclass.ch"
#include "hmgformat.ch"

FUNCTION Main( cParam )

   LOCAL nKey := 0, nContYes := 0, nContNo := 0

   IF cParam == NIL .OR. cParam != "BACKUP_IS_OK"
      ? "Test only. It is dangerous to use without backup source code first"
      QUIT
   ENDIF
   SetMode( 40, 100 )
   CLS
   ? "Hit Alt-D to debug, ESC to quit, or any other key to continue"
   ? "Working on d:\github\oohgsamples\"
   IF Inkey(0)  != K_ESC
      FormatDir( "d:\github\oohgsamples\", @nKey, @nContYes, @nContNo )
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
   ELSE
      nContNo += 1
   ENDIF

   RETURN NIL

FUNCTION FormatIndent( cLinePrg, oFormat )

   LOCAL cThisLineLower

   LOCAL nIdent2 := 0, oElement

   cThisLineLower := AllTrim( Lower( cLinePrg ) )
   IF Left( cThisLineLower, 2 ) == FMT_COMMENT_OPEN .AND. ! FMT_COMMENT_CLOSE $ cThisLineLower
      oFormat:lComment := .T. // begin comment code
   ENDIF
   IF Left( cThisLineLower, 2 ) == FMT_COMMENT_CLOSE
      oFormat:lComment := .F. // end comment code
   ENDIF
   IF Right( cThisLineLower, 2 ) == FMT_COMMENT_CLOSE .AND. oFormat:lComment
      oFormat:lComment := .F.
   ENDIF
   // line continuation, make ident
   IF oFormat:lContinue .AND. ! oFormat:lComment
      nIdent2 += 1
   ENDIF
   // line continuation, without comment, will ident next
   IF ! ( Left( cThisLineLower, 1 ) == "*" .OR. Left( cThisLineLower, 2 ) == "//" .OR. oFormat:lComment )
      oFormat:lContinue := Right( cThisLineLower, 1 ) == ";"
   ENDIF
   // return change ident, this prevents when return is inside endif/endcase/others
   IF ! oFormat:lReturn .AND. ! oFormat:lComment
      FOR EACH oElement IN FMT_GO_BACK
         IF Left( cThisLineLower, Len( oElement ) ) == oElement .OR. cThisLineLower == Trim( oElement )
            oFormat:nIdent -= 1
            EXIT
         ENDIF
      NEXT
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
   // check if command will cause ident
   FOR EACH oElement IN FMT_GO_AHEAD
      IF Left( cThisLineLower, Len( oElement ) ) == oElement
         oFormat:nIdent += 1
         EXIT
      ENDIF
   NEXT
   IF Left( cThisLineLower, 6 ) == "return"
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

   LOCAL cThisLineLower, nLine := 1, lPrg := .T.
   LOCAL oFormat := FormatClass():New()

   cTxtPrg  := ""
   DO WHILE nLine <= Len( acPrgLines )
      cThisLineLower := Lower( AllTrim( acPrgLines[ nLine ] ) )
      DO CASE
      CASE IsEndDump( cThisLineLower ) ;   lPrg := .T.
      CASE ! lPrg
      CASE IsBeginDump( cThisLineLower ) ; lPrg := .T.
      CASE oFormat:lComment .AND. IsEndComment( cThisLineLower ); oFormat:lComment := .F.
      CASE oFormat:lComment
      CASE IsEmptyComment( cThisLineLower )
         nLine += 1
         LOOP
      CASE IsBeginComment( cThisLineLower ) ; oFormat:lComment := .T.
      CASE oFormat:lEmptyLine
         IF Empty( cThisLineLower )
            nLine += 1
            LOOP
         ENDIF
      CASE IsLineType( cThisLineLower, FMT_BLANK_LINE );  cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      CASE Left( cThisLineLower, 6 )  == "return";       cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      ENDCASE
      IF oFormat:lDeclareVar .AND. ;
         Right( cTxtPrg, 3 ) != ";" + hb_Eol() .AND. ;
         ! IsLineType( cThisLineLower, FMT_DECLARE_VAR )
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
      CASE Right( cThisLineLower, 1 ) == ";"
      CASE IsLineType( cThisLineLower, FMT_BLANK_LINE )  ; cTxtPrg += hb_Eol(); cThisLineLower := ""
      CASE IsLineType( cThisLineLower, FMT_DECLARE_VAR ) ; oFormat:lDeclareVar := .T.
      ENDCASE
      oFormat:lEmptyLine := ( Empty( cThisLineLower ) )
      nLine += 1
   ENDDO
   DO WHILE Replicate( hb_Eol(), 3 ) $ cTxtPrg
      cTxtPrg := StrTran( cTxtPrg, Replicate( hb_Eol(), 3 ), Replicate( hb_Eol(), 2 ) )
   ENDDO

   RETURN NIL

FUNCTION FormatCase( cLinePrg )

   LOCAL oElement

   cLinePrg := AllTrim( cLinePrg )
   FOR EACH oElement IN FMT_TO_UPPER DESCEND
      IF oElement == Upper( Left( cLinePrg, Len( oElement ) ) )
         cLinePrg := oElement + Substr( cLinePrg, Len( oElement ) + 1 )
         EXIT
      ENDIF
   NEXT
   FOR EACH oElement IN FMT_TO_LOWER DESCEND
      IF oElement == Lower( Left( cLinePrg, Len( oElement ) ) )
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

FUNCTION IsLineType( cTxt, acList )

   RETURN AScan( acList, { | e | e == Left( cTxt, Len( e ) ) } ) != 0

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
