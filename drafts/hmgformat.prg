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
   Inkey(0)
   FormatDir( "d:\github\oohgsamples\", @nKey, @nContYes, @nContNo )

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

   LOCAL cTxtPrg, cTxtPrgAnt

   cTxtPrgAnt := MemoRead( cFile )
   cTxtPrg    := cTxtPrgAnt
   FormatBasic( @cTxtPrg )
   FormatSource( @cTxtPrg )
   FormatBlankLine( @cTxtPrg )
   // save if changed
   IF ! cTxtPrg == cTxtPrgAnt
      nContYes += 1
      ? nContYes, nContNo, "Formatted " + cFile
      //MemoEdit( cTxtPrg, 1, 1, 39, 99, .T. )
      //IF LastKey() != K_ESC
      hb_MemoWrit( cFile, cTxtPrg )
      //ENDIF
   ELSE
      nContNo += 1
   ENDIF

   RETURN NIL

FUNCTION FormatBasic( cTxtPrg )

   // TAB
   cTxtPrg := StrTran( cTxtPrg, Chr(9), Space(3) )
   // Windows CRLF
   cTxtPrg := StrTran( cTxtPrg, hb_Eol(), Chr(13) )
   cTxtPrg := StrTran( cTxtPrg, Chr(10), Chr(13) )
   cTxtPrg := StrTran( cTxtPrg, Chr(13), hb_Eol() )
   // Blank spaces at end of line
   DO WHILE " " + hb_Eol() $ cTxtPrg
      cTxtPrg := StrTran( cTxtPrg, " " + hb_Eol(), hb_Eol() )
   ENDDO

   RETURN NIL

FUNCTION FormatSource( cTxtPrg )

   LOCAL acPrgLines, oElement, oFormat := FormatClass():New()

   acPrgLines := hb_regExSplit( hb_Eol(), cTxtPrg )
   // one blank line at end of file
   DO WHILE Len( acPrgLines ) > 1 .AND. Empty( acPrgLines[ Len( acPrgLines ) ] )
      aSize( acPrgLines, Len( acPrgLines ) - 1 )
   ENDDO
   // more
   FOR EACH oElement IN acPrgLines
      FormatIndent( @oElement, @oFormat )
   NEXT
   cTxtPrg := ""
   FOR EACH oElement IN acPrgLines
      cTxtPrg += oElement + hb_Eol()
   NEXT

   RETURN NIL

FUNCTION FormatIndent( cLinePrg, oFormat )

   LOCAL cThisLineLower

   LOCAL nIdent2 := 0, oElement

   cThisLineLower := AllTrim( Lower( cLinePrg ) )
   IF "#" + "pragma" $ cThisLineLower // to do not consider this source code
      IF "begindump" $ cThisLineLower
         oFormat:lFormat := .F. // begin c code, turn format OFF
      ENDIF
      IF "enddump" $ cThisLineLower
         oFormat:lFormat := .T. // end c code, turn format ON
      ENDIF

      RETURN NIL
   ENDIF
   IF ! oFormat:lFormat

      RETURN NIL
   ENDIF
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
      FormatUpperLower( @cLinePrg )
   ENDIF
   IF oFormat:nIdent + nIdent2 > 0
      IF Empty( cLinePrg )
         cLinePrg := ""
      ELSE
         cLinePrg := Space( ( oFormat:nIdent + nIdent2 ) * 3 ) + AllTrim( cLinePrg )
      ENDIF
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
   // prevent negative number
   IF oFormat:nIdent < 0
      oFormat:nIdent := 0
   ENDIF

   RETURN NIL

FUNCTION FormatBlankLine( cTxtPrg )

   LOCAL cThisLineLower, nLine := 1, oFormat := FormatClass():New(), acPrgLines, oElement

   acPrgLines := hb_RegExSplit( hb_Eol(), cTxtPrg )
   cTxtPrg  := ""
   DO WHILE nLine <= Len( acPrgLines )
      cThisLineLower := Lower( AllTrim( acPrgLines[ nLine ] ) )
      DO CASE
      CASE "%pragma" $ cThisLineLower .AND. "enddump" $ cThisLineLower    .AND. oFormat:lCCode ; oFormat:lCCode   := .F.
      CASE oFormat:lCCode
      CASE "#pragma" $ cThisLineLower .AND. "begindump" $ cThisLineLower  ; oFormat:lCCode   := .T.
      CASE FMT_COMMENT_CLOSE $ cThisLineLower .AND. oFormat:lComment; oFormat:lComment := .F.
      CASE oFormat:lComment
      CASE ( Left( cThisLineLower, 2 ) == FMT_COMMENT_OPEN .AND. FMT_COMMENT_CLOSE $ cThisLineLower ) .OR. Left( cThisLineLower, 1 ) == "*" .OR. Left( cThisLineLower, 2 ) == "//"
         lAnything := .F.
         FOR EACH oElement IN cThisLineLower
            IF ! oElement $ "/-*"
               lAnything := .T.
               EXIT
            ENDIF
         NEXT
         IF ! lAnything
            nLine += 1
            LOOP
         ENDIF
      CASE Left( cThisLineLower, 2 ) == FMT_COMMENT_OPEN ; oFormat:lComment := .T.
      CASE Left( cThisLineLower, 2 ) == "//" .OR. Left( cThisLineLower, 1 ) == "*"
      CASE oFormat:lEmptyLine
         IF Empty( cThisLineLower )
            nLine += 1
            LOOP
         ENDIF
      CASE Left( cThisLineLower, 11 ) == "static proc";  cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      CASE Left( cThisLineLower, 11 ) == "static func";  cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      CASE Left( cThisLineLower, 4 )  == "proc";         cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      CASE Left( cThisLineLower, 4 )  == "func";         cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      CASE Left( cThisLineLower, 5 )  == "class";        cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      CASE Left( cThisLineLower, 12 ) == "create class"; cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      CASE Left( cThisLineLower, 8 )  == "endclass";     cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      CASE Left( cThisLineLower, 6 )  == "method";       cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      CASE Left( cThisLineLower, 6 )  == "return";       cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      ENDCASE
      cTxtPrg += acPrgLines[ nLine ] + hb_Eol()
      DO CASE
      CASE oFormat:lCCode
      CASE oFormat:lComment
      CASE Right( cThisLineLower, 1 ) == ";"
      CASE Left( cThisLineLower, 11 ) == "static proc";  cTxtPrg += hb_Eol(); cThisLineLower := ""
      CASE Left( cThisLineLower, 11 ) == "static func";  cTxtPrg += hb_Eol(); cThisLineLower := ""
      CASE Left( cThisLineLower, 4 )  == "proc";         cTxtPrg += hb_Eol(); cThisLineLower := ""
      CASE Left( cThisLineLower, 4 )  == "func";         cTxtPrg += hb_Eol(); cThisLineLower := ""
      CASE Left( cThisLineLower, 5 )  == "class";        cTxtPrg += hb_Eol(); cThisLineLower := ""
      CASE Left( cThisLineLower, 12 ) == "create class"; cTxtPrg += hb_Eol(); cThisLineLower := ""
      CASE Left( cThisLineLower, 5 )  == "local" ;       cTxtPrg += hb_Eol(); cThisLineLower := ""
      ENDCASE
      oFormat:lEmptyLine := ( Empty( cThisLineLower ) )
      nLine += 1
   ENDDO
   DO WHILE Len( acPrgLines ) > 2 .AND. Empty( acPrgLines[ Len( acPrgLines ) ] ) .AND. Empty( acPrgLines[ Len( acPrgLines ) - 1 ] )
      aSize( acPrgLines, Len( acPrgLines ) - 1 )
   ENDDO

   RETURN NIL

FUNCTION FormatUpperLower( cLinePrg )

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
   VAR lCCode      INIT .F.
   VAR lEmptyLine  INIT .F.

ENDCLASS

