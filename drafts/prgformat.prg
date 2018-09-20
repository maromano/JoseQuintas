/*
MGFORMAT - Format source code (indent, line space, first words to upper)
Test over HMG3 + HMG EXTENDED + HWGUI + OOHG

2017.12.01 - Try to solve continuation with comments, anything like this: IF .T. ; ENDIF
2018.04.12  K_ESC
*/

#include "directry.ch"
#include "inkey.ch"
#include "hbclass.ch"

#define FMT_COMMENT_OPEN  "/" + "*"
#define FMT_COMMENT_CLOSE "*" + "/"
#define FMT_TO_CASE       1
#define FMT_GO_AHEAD      2
#define FMT_GO_BACK       3
#define FMT_SELF_BACK     4
#define FMT_BLANK_LINE    5
#define FMT_DECLARE_VAR   6
#define FMT_AT_BEGIN      7
#define FMT_CASE_ANY      8
#define FMT_FROM_TO       9

FUNCTION Main( cFileName )

   LOCAL nKey := 0, nContYes := 0, nContNo := 0, cPath := ".\"

   SetMode( 40, 100 )
   CLS

   ? "Hit Alt-D to debug, ESC to quit, or any other key to continue"
   ? "Working on " + cPath
   IF cFileName == NIL
      nKey := Inkey(0)
   ENDIF
   IF nKey != K_ESC
      CLS
      FormatDir( cPath, @nKey, @nContYes, @nContNo, cFileName )
   ENDIF

   RETURN NIL

STATIC FUNCTION FormatDir( cPath, nKey, nContYes, nContNo, cFileName )

   LOCAL oFiles, oElement

   IF cFileName == NIL
      oFiles := Directory( cPath + "*.*", "D" )
   ELSE
      cPath := ""
      oFiles := { { cFileName, 0, Date(), Time(), "A" } }
   ENDIF
   ASort( oFiles, , , { | a, b | a[ 1 ] < b[ 1 ] } )
   FOR EACH oElement IN oFiles
      DO CASE
      CASE "D" $ oElement[ F_ATTR ] .AND. oElement[ F_NAME ] == "."
      CASE "D" $ oElement[ F_ATTR ] .AND. oElement[ F_NAME ] == ".."
      CASE "D" $ oELement[ F_ATTR ]
         FormatDir( cPath + oElement[ F_NAME ] + "\", @nKey, @nContYes, @nContNo )
      CASE Upper( Right( oElement[ F_NAME ], 4 ) ) == ".PRG" .OR. ;
           Upper( Right( oElement[ F_NAME ], 4 ) ) == ".FMG" .OR. ;
           Upper( RIght( oElement[ F_NAME ], 3 ) ) == ".CH" .OR. ;
           Upper( Right( oElement[ F_NAME ], 2 ) ) == ".H" .OR. ;
           Upper( Right( oElement[ F_NAME ], 4 ) ) == ".BAT" .OR. ;
           Upper( Right( oElement[ F_NAME ], 2 ) ) == ".C" .OR. ;
           Upper( Right( oElement[ F_NAME ], 4 ) ) == ".CPP" .OR. ;
           Upper( Right( oElement[ F_NAME ], 4 ) ) == ".TXT" .OR. ;
           Upper( Right( oElement[ F_NAME ], 4 ) ) == ".HBP"
         FormatFile( cPath + oElement[ F_NAME ], @nContYes, @nContNo )
      ENDCASE
      nKey := iif( nKey == K_ESC, nKey, Inkey() )
      IF nKey == K_ESC
         EXIT
      ENDIF
   NEXT

   RETURN NIL

STATIC FUNCTION FormatFile( cFile, nContYes, nContNo )

   LOCAL cTxtPrg, cTxtPrgAnt, acPrgLines, oElement, lPrgSource := .T.
   LOCAL oFormat := FormatClass():New()

   cTxtPrgAnt := MemoRead( cFile )
   IF "HB_INLINE" $ cTxtPrgAnt // C source inside PRG source, but not #pragma begindump
      ? cFile
      ? Space(3) + " ignored because have HB_INLINE"
      RETURN NIL
   ENDIF
   cTxtPrg    := cTxtPrgAnt
   cTxtPrg    := StrTran( cTxtPrg, Chr(9), Space(3) )
   cTxtPrg    := StrTran( cTxtPrg, Chr(13) + Chr(10), Chr(10) )
   cTxtPrg    := StrTran( cTxtPrg, Chr(13), Chr(10) )
   cTxtPrg    := StrTran( cTxtPrg, Chr(10) + Chr(10) + Chr(10), Chr(10) + Chr(10) )
   acPrgLines := hb_RegExSplit( Chr(10), cTxtPrg )
   DO WHILE .T.
      IF Len( acPrgLines ) < 1 .OR. ! Empty( acPrgLines[ Len( acPrgLines ) ] )
         EXIT
      ENDIF
      aSize( acPrgLines, Len( acPrgLines ) - 1 )
   ENDDO

   IF ".prg" $ Lower( cFile ) ;
      .AND. ! "menudrop()" $ Lower( cTxtPrg ) ;
      .AND. ! "indexind" $ Lower( cTxtPrg )
      FOR EACH oElement IN acPrgLines
         oElement := Trim( oElement )
         DO CASE
         CASE IsBeginDump( oElement ) ; lPrgSource := .F.
         CASE ! lPrgSource
            IF IsEndDump( oElement )
               lPrgSource := .T.
            ENDIF
         OTHERWISE
            // pessoal begin
            IF oElement:__EnumIndex > 1 ;
               .AND. "RECUNLOCK()" $ Upper( oElement ) ;
               .AND. Upper( AllTrim( oElement ) ) == Upper( AllTrim( acPrgLines[ oElement:__EnumIndex - 1 ] ) )
               oElement := ""
            ENDIF
            /// pessoal end
            FormatIndent( @oElement, oFormat )
         ENDCASE
      NEXT
      FormatEmptyLine( @cTxtPrg, @acPrgLines )
   ELSE
      cTxtPrg := ""
      FOR EACH oElement IN acPrgLines
         cTxtPrg += Trim( oElement ) + hb_Eol()
      NEXT
   ENDIF
   // save if changed
   IF ! cTxtPrg == cTxtPrgAnt
      MakeBackup( cFile )
      nContYes += 1
      ? nContYes, nContNo, "Formatted " + cFile
      fErase( cFile )
      hb_MemoWrit( Lower( cFile ), cTxtPrg )
      //wapi_ShellExecute( NIL, "open", cFile,, WIN_SW_SHOWNORMAL )
      //IF Mod( nContYes, 10 ) == 0
      //   ? "Hit any key"
      //   IF Inkey(0) == K_ESC
      //      QUIT
      //   ENDIF
      //ENDIF
   ELSE
      nContNo += 1
   ENDIF

   RETURN NIL

FUNCTION FormatIndent( cLinePrg, oFormat )

   LOCAL cThisLineUpper, nIdent2 := 0, nItem

   cLinePrg := AllTrim( cLinePrg )
/* porque tem muito fonte assim */
   IF Left( cLinePrg, 8 ) == "DO WHIL "
      cLinePrg := StrTran( cLinePrg, "DO WHIL ", "DO WHILE " )
   ENDIF
   IF Upper( Left( cLinePrg, 12 ) ) == "SET ORDE TO "
      cLinePrg := "SET ORDER TO " + Substr( cLinePrg, 13 )
   ENDIF
   cLinePrg := StrTran( cLinePrg, "INKEY.CH", "inkey.ch" )
   IF Upper( Left( cLinePrg, 12 ) ) == "STATIC FUNC "
      cLinePrg := "STATIC FUNCTION " + Substr( cLinePrg, 13 )
   ENDIF
   IF Upper( Left( cLinePrg, 12 ) ) == "STATIC PROC "
      cLinePrg := "STATIC PROCEDURE " + Substr( cLinePrg, 13 )
   ENDIF
   IF Upper( Left( cLinePrg, 5 ) ) == "FUNC "
      cLinePrg := "FUNCTION " + Substr( cLinePrg, 6 )
   ENDIF
   IF Upper( Left( cLinePrg, 5 ) ) == "PROC "
      cLinePrg := "PROCEDURE " + Substr( cLinePrg, 6 )
   ENDIF
   IF " TRANS(" $ Upper( cLinePrg ) .OR. "(TRANS(" $ Upper( cLinePrg )
      cLinePrg := StrTran( cLinePrg, " TRANS(", " Transform(" )
      cLinePrg := StrTran( cLinePrg, "(TRANS(", "( Transform(" )
   ENDIF
   IF " REPL(" $ Upper( cLinePrg ) .OR. "(REPL(" $ Upper( cLinePrg )
      cLinePrg := StrTran( cLinePrg, " REPL(", " Replicate(" )
      cLinePrg := StrTran( cLinePrg, "(REPL(", "( Replicate(" )
   ENDIF
   // pessoal
   IF "#include" $ Lower( cLinePrg ) .AND. ".fh" $ cLinePrg .AND. ! "fspreset" $ cLinePrg
      cLinePrg := StrTran( Lower( cLinePrg ), ".fh", ".ch" )
   ENDIF
   nItem := ASCan( FmtList( FMT_FROM_TO ), { | e | e[ 1 ] == Upper( cLinePrg ) } )
   IF nItem != 0
      cLinePrg := FmtList( FMT_FROM_TO )[ nItem, 2 ]
   ENDIF
   //cLinePrg := StrTran( cLinePrg, [abri(01,], [IF ! AbreArquivos( "CLIE" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(02,], [IF ! AbreArquivos( "FORN" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(03,], [IF ! AbreArquivos( "VEND" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(05,], [IF ! AbreArquivos( "DOBR" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(06,], [IF ! AbreArquivos( "COBR" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(07,], [IF ! AbreArquivos( "TBCP" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(08,], [IF ! AbreArquivos( "DES1" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(09,], [IF ! AbreArquivos( "PREV" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(10,], [IF ! AbreArquivos( "COMI" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(11,], [IF ! AbreArquivos( "CLMK" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(12,], [IF ! AbreArquivos( "RAM1" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(13,], [IF ! AbreArquivos( "DES2" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(14,], [IF ! AbreArquivos( "DES3" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(15,], [IF ! AbreArquivos( "PLAN" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(16,], [IF ! AbreArquivos( "REC1" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(17,], [IF ! AbreArquivos( "REC2" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(18,], [IF ! AbreArquivos( "PRO1", "PRDEPT" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(19,], [IF ! AbreArquivos( "PRO2" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(20,], [IF ! AbreArquivos( "PRO3" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(21,], [IF ! AbreArquivos( "TBPR" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(22,], [IF ! AbreArquivos( "TBIC" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(23,], [IF ! AbreArquivos( "NATO" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(24,], [IF ! AbreArquivos( "MATE" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(35,], [IF ! AbreArquivos( "CALE" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(36,], [IF ! AbreArquivos( "FNCA" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(37,], [IF ! AbreArquivos( "FNCI" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(38,], [IF ! AbreArquivos( "PRCE" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(39,], [IF ! AbreArquivos( "EQUI" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(40,], [IF ! AbreArquivos( "EQPA" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(41,], [IF ! AbreArquivos( "CTPR" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(42,], [IF ! AbreArquivos( "CTPO" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(43,], [IF ! AbreArquivos( "CTPE" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(44,], [IF ! AbreArquivos( "EQPP" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(45,], [IF ! AbreArquivos( "INDI" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(46,], [IF ! AbreArquivos( "INDM" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(47,], [IF ! AbreArquivos( "PLVI" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(48,], [IF ! AbreArquivos( "PRVI" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(49,], [IF ! AbreArquivos( "ORSE" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(50,], [IF ! AbreArquivos( "OSFU" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(51,], [IF ! AbreArquivos( "OSMA" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(52,], [IF ! AbreArquivos( "CLIO" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(53,], [IF ! AbreArquivos( "OSKM" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(54,], [IF ! AbreArquivos( "OSRE" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(55,], [IF ! AbreArquivos( "ORCM" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(56,], [IF ! AbreArquivos( "ORAM" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(57,], [IF ! AbreArquivos( "ORAF" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(58,], [IF ! AbreArquivos( "MOV1" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(59,], [IF ! AbreArquivos( "FEOS" ); QUIT; ENDIF // ] )
   //cLinePrg := StrTran( cLinePrg, [abri(60,], [IF ! AbreArquivos( "FOSM" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(61,], [IF ! AbreArquivos( "FOSS" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(62,], [IF ! AbreArquivos( "PEVM" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(63,], [IF ! AbreArquivos( "PEVC" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(64,], [IF ! AbreArquivos( "MOV2" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(65,], [IF ! AbreArquivos( "PRER" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(66,], [IF ! AbreArquivos( "PRED" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(67,], [IF ! AbreArquivos( "CADC" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(72,], [IF ! AbreArquivos( "REM4" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(73,], [IF ! AbreArquivos( "REM5" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(74,], [IF ! AbreArquivos( "REM6" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(75,], [IF ! AbreArquivos( "OSNF" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(76,], [IF ! AbreArquivos( "PLHI" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(77,], [IF ! AbreArquivos( "POBS" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(78,], [IF ! AbreArquivos( "PROR" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(79,], [IF ! AbreArquivos( "PROB" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(82,], [IF ! AbreArquivos( "OSFP" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(83,], [IF ! AbreArquivos( "PRVD" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(86,], [IF ! AbreArquivos( "DES4" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(87,], [IF ! AbreArquivos( "NFGE" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(88,], [IF ! AbreArquivos( "NFMA" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(89,], [IF ! AbreArquivos( "NFMO" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(90,], [IF ! AbreArquivos( "PEPG" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri(93,], [IF ! AbreArquivos( "PVD2" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 1,], [IF ! AbreArquivos( "CLIE" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 2,], [IF ! AbreArquivos( "FORN" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 3,], [IF ! AbreArquivos( "VEND" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 5,], [IF ! AbreArquivos( "DOBR" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 6,], [IF ! AbreArquivos( "COBR" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 7,], [IF ! AbreArquivos( "TBCP" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 8,], [IF ! AbreArquivos( "DES1" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 9,], [IF ! AbreArquivos( "PREV" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 10,], [IF ! AbreArquivos( "COMI" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 11,], [IF ! AbreArquivos( "CLMK" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 12,], [IF ! AbreArquivos( "RAM1" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 13,], [IF ! AbreArquivos( "DES2" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 14,], [IF ! AbreArquivos( "DES3" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 15,], [IF ! AbreArquivos( "PLAN" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 16,], [IF ! AbreArquivos( "REC1" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 17,], [IF ! AbreArquivos( "REC2" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 18,], [IF ! AbreArquivos( "PRO1", "PRDEPT" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 19,], [IF ! AbreArquivos( "PRO2" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 20,], [IF ! AbreArquivos( "PRO3" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 21,], [IF ! AbreArquivos( "TBPR" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 22,], [IF ! AbreArquivos( "TBIC" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 23,], [IF ! AbreArquivos( "NATO" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 24,], [IF ! AbreArquivos( "MATE" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 35,], [IF ! AbreArquivos( "CALE" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 36,], [IF ! AbreArquivos( "FNCA" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 37,], [IF ! AbreArquivos( "FNCI" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 38,], [IF ! AbreArquivos( "PRCE" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 39,], [IF ! AbreArquivos( "EQUI" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 40,], [IF ! AbreArquivos( "EQPA" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 41,], [IF ! AbreArquivos( "CTPR" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 42,], [IF ! AbreArquivos( "CTPO" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 43,], [IF ! AbreArquivos( "CTPE" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 44,], [IF ! AbreArquivos( "EQPP" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 45,], [IF ! AbreArquivos( "INDI" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 46,], [IF ! AbreArquivos( "INDM" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 47,], [IF ! AbreArquivos( "PLVI" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 48,], [IF ! AbreArquivos( "PRVI" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 49,], [IF ! AbreArquivos( "ORSE" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 50,], [IF ! AbreArquivos( "OSFU" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 51,], [IF ! AbreArquivos( "OSMA" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 52,], [IF ! AbreArquivos( "CLIO" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 53,], [IF ! AbreArquivos( "OSKM" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 54,], [IF ! AbreArquivos( "OSRE" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 55,], [IF ! AbreArquivos( "ORCM" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 56,], [IF ! AbreArquivos( "ORAM" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 57,], [IF ! AbreArquivos( "ORAF" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 58,], [IF ! AbreArquivos( "MOV1" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 59,], [IF ! AbreArquivos( "FEOS" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 60,], [IF ! AbreArquivos( "FOSM" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 61,], [IF ! AbreArquivos( "FOSS" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 62,], [IF ! AbreArquivos( "PEVM" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 63,], [IF ! AbreArquivos( "PEVC" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 64,], [IF ! AbreArquivos( "MOV2" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 65,], [IF ! AbreArquivos( "PRER" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 66,], [IF ! AbreArquivos( "PRED" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 67,], [IF ! AbreArquivos( "CADC" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 72,], [IF ! AbreArquivos( "REM4" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 73,], [IF ! AbreArquivos( "REM5" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 74,], [IF ! AbreArquivos( "REM6" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 75,], [IF ! AbreArquivos( "OSNF" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 76,], [IF ! AbreArquivos( "PLHI" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 77,], [IF ! AbreArquivos( "POBS" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 78,], [IF ! AbreArquivos( "PROR" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 79,], [IF ! AbreArquivos( "PROB" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 82,], [IF ! AbreArquivos( "OSFP" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 83,], [IF ! AbreArquivos( "PRVD" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 86,], [IF ! AbreArquivos( "DES4" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 87,], [IF ! AbreArquivos( "NFGE" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 88,], [IF ! AbreArquivos( "NFMA" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 89,], [IF ! AbreArquivos( "NFMO" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 90,], [IF ! AbreArquivos( "PEPG" ); QUIT; ENDIF // ] )
   // cLinePrg := StrTran( cLinePrg, [abri( 93,], [IF ! AbreArquivos( "PVD2" ); QUIT; ENDIF // ] )
   //IF Upper( Left( cLinePrg, 9 ) ) == "MENSAGEM("
   //   cLinePrg := "Mensagem(" + Substr( cLinePrg, 10 )
   //ENDIF
   //cLinePrg := StrTran( cLinePrg, " !EMPTY(", " ! Empty(" )
   //cLinePrg := StrTran( cLinePrg, "(SUBS(", "( Substr(" )
   //cLinePrg := StrTran( cLinePrg, " TRANS(", " Transform(" )
   //cLinePrg := StrTran( cLinePrg, "(INT(", "( Int(" )
   //cLinePrg := StrTran( cLinePrg, " PROM ", " PROMPT " )
   //cLinePrg := StrTran( cLinePrg, " prom ", " PROMPT " )
   //cLinePrg := StrTran( cLinePrg, "(DBSEEK(", "( dbSeek( " )
   //cLinePrg := StrTran( cLinePrg, " SUBST(", " Substr(" )
   //cLinePrg := StrTran( cLinePrg, " subst(", " Substr(" )
   //cLinePrg := StrTran( cLinePrg, "DBUNLOCK()", "RecUnlock()" )
   //cLinePrg := StrTran( cLinePrg, "WHEN Mensagem(", "WHEN MsgWhen(" )
   //cLinePrg := StrTran( cLinePrg, "Mensagem('',24,.T.)", "Mensagem()" )
   //cLinePrg := StrTran( cLinePrg, "MsgWhen('',24,.T.)", "MsgWhen()" )
   //cLinePrg := StrTran( cLinePrg, "DbAppend()", "RecAppend()" )
   //cLinePrg := StrTran( cLinePrg, "DBAPPEND()", "RecAppend()" )
   //cLinePrg := StrTran( cLinePrg, "dbAppend()", "RecAppend()" )
   //cLinePrg := StrTran( cLinePrg, "DBCOMMIT()", "RecUnlock()" )
   //cLinePrg := StrTran( cLinePrg, "DBCREATE(", "CreateDbf(" )
   //cLinePrg := StrTran( cLinePrg, "DbCreate(", "CreateDbf(" )
   //cLinePrg := StrTran( cLinePrg, "DbCREATE(", "CreateDbf(" )

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
      oFormat:lContinue := IsLineContinue( cThisLineUpper )
   ENDIF
   IF ! oFormat:lComment
      FormatCase( @cLinePrg )
      IF IsCmdType( FMT_SELF_BACK, cThisLineUpper ) .OR. IsCmdType( FMT_GO_BACK, cThisLineUpper )
         IF ! Left( cThisLineUpper, 6 ) == "METHOD" .OR. ! oFormat:lIsClass
            oFormat:nIdent -= 1
         ENDIF
      ENDIF
      IF IsCmdType( FMT_AT_BEGIN, cThisLineUpper )
         IF ! Left( cThisLineUpper, 6 ) == "METHOD" .OR. ! oFormat:lIsClass
            oFormat:nIdent := 0
            nIdent2        := 0
         ENDIF
      ENDIF
   ENDIF
   IF Empty( cLinePrg )
      cLinePrg := ""
   ELSE
      IF ! oFormat:lComment
         IF Left( AllTrim( cLinePrg ), 1 ) == "#" .AND. ! oFormat:lComment
            nIdent2 := -oFormat:nIdent // 0 col
         ELSEIF AScan( { "ENDCLASS", " END CLASS" },,, { | e | Upper( AllTrim( cLinePrg ) ) == e } ) != 0
            nIdent2 := 1 - oFormat:nIdent // 1 col
         ENDIF
      ENDIF
      cLinePrg := Space( ( Max( oFormat:nIdent + nIdent2, 0 ) ) * 3 ) + AllTrim( cLinePrg )
      IF Right( cLinePrg, 1 ) == ";"
         IF Substr( cLinePrg, Len( cLinePrg ) - 1, 1 ) != " "
            cLinePrg := Substr( cLinePrg, 1, Len( cLinePrg ) - 1 ) + " " + ";"
         ENDIF
      ENDIF
   ENDIF
   FmtCaseFromAny( @cLinePrg )
   IF oFormat:lComment
      RETURN NIL
   ENDIF
   DO CASE
   CASE ";" $ cThisLineUpper .AND. hb_LeftEq( cThisLineUpper, "IF " ) .AND. "ENDIF" $ cThisLineUpper
   CASE ";" $ cThisLineUpper .AND. hb_LeftEq( cThisLineUpper, "DO WHILE " ) .AND. "ENDDO"$ cThisLineUpper
   CASE ";" $ cThisLineUpper .AND. hb_LeftEq( cThisLineUpper, "WHILE " ) .AND. "ENDDO" $ cThisLineUpper
   OTHERWISE
      IF IsCmdType( FMT_SELF_BACK, cThisLineUpper ) .OR. IsCmdType( FMT_GO_AHEAD, cThisLineUpper )
         IF ! Left( cThisLineUpper, 6 ) == "METHOD" .OR. ! oFormat:lIsClass
            oFormat:nIdent += 1
         ENDIF
      ENDIF
   ENDCASE
   IF Left( cThisLineUpper, 3 ) == "END" .AND. oFormat:lIsClass
      oFormat:lIsClass := .F.
   ELSEIF Left( cThisLineUpper, 5 ) == "CLASS" .OR. Left( cThisLineUpper, 12 ) == "CREATE CLASS"
      oFormat:lIsClass := .T.
   ENDIF
   // min column
   oFormat:nIdent := Max( oFormat:nIdent, 0 )

   RETURN NIL

FUNCTION FormatEmptyLine( cTxtPrg, acPrgLines )

   LOCAL cThisLineUpper, nLine := 1, lPrgSource := .T.
   LOCAL oFormat := FormatClass():New()

   cTxtPrg  := ""
   DO WHILE nLine <= Len( acPrgLines )
      cThisLineUpper := Upper( AllTrim( acPrgLines[ nLine ] ) )
      DO CASE
      CASE IsEndDump( cThisLineUpper ) ;   lPrgSource := .T.
      CASE ! lPrgSource
      CASE IsBeginDump( cThisLineUpper ) ; lPrgSource := .F.
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
      CASE Left( acPrgLines[ nLine ], 1 ) != " " .AND. IsCmdType( FMT_BLANK_LINE, cThisLineUpper ) ;  cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      CASE Left( cThisLineUpper, 7 )  == "RETURN " .AND. At( "RETURN", acPrgLines[ nLine ] ) < 5   ;  cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      CASE cThisLineUpper == "RETURN" .AND. At( "RETURN", acPrgLines[ nLine ] ) < 5   ;  cTxtPrg += hb_Eol(); oFormat:lEmptyLine := .T.
      ENDCASE
      IF oFormat:lDeclareVar .AND. ;
         Right( cTxtPrg, 3 ) != ";" + hb_Eol() .AND. ;
         ! IsCmdType( FMT_DECLARE_VAR, cThisLineUpper )
         oFormat:lDeclareVar := .F.
         IF ! Empty( acPrgLines[ nLine ] ) .AND. ! oFormat:lEmptyLine .AND. ! IsLineContinue( cThisLineUpper )
            cTxtPrg += hb_Eol()
            oFormat:lEmptyLine := .T.
         ENDIF
      ENDIF
      cTxtPrg += acPrgLines[ nLine ] + hb_Eol()
      DO CASE
      CASE ! lPrgSource
      CASE oFormat:lComment
      CASE IsLineContinue( cThisLineUpper )
      CASE Left( acPrgLines[ nLine ], 1 ) != " " .AND. IsCmdType( FMT_BLANK_LINE,  cThisLineUpper ); cTxtPrg += hb_Eol(); cThisLineUpper := ""
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

   LOCAL nPos

   cLinePrg := AllTrim( cLinePrg )
   IF IsCmdType( FMT_TO_CASE, cLinePrg, @nPos )
      cLinePrg := FmtList( FMT_TO_CASE )[ nPos ] + Substr( cLinePrg, Len( FmtList( FMT_TO_CASE )[ nPos ] ) + 1 )
   ENDIF

   RETURN NIL

CREATE CLASS FormatClass

   VAR nIdent      INIT 0
   VAR lFormat     INIT .T.
   VAR lContinue   INIT .F.
   VAR lComment    INIT .F.
   VAR lEmptyLine  INIT .F.
   VAR lDeclareVar INIT .F.
   VAR lIsClass    INIT .F.

   ENDCLASS

STATIC FUNCTION IsBeginDump( cText )

   RETURN Lower( Left( AllTrim( cText ), 17 ) ) == "#" + "pragma begindump"

STATIC FUNCTION IsEndDump( cText )

   RETURN Lower( Left( AllTrim( cText ), 15 ) ) == "#" + "pragma enddump"

STATIC FUNCTION IsLineContinue( cText )

   LOCAL nPos

   // May be IF .T.; ENDIF, or xxx ; // comment

   IF .NOT. ";" $ cText
      RETURN .F.
   ENDIF
   IF "//" $ cText
      cText := Trim( Substr( cText, 1, At( "//", cText ) - 1 ) )
   ENDIF
   IF Right( cText, 1 ) == ";"
      RETURN .T.
   ENDIF
   nPos  := hb_At( ";", cText )
   IF "/*" $ cText
      IF At( "/*", cText ) < nPos
         RETURN .F.
      ENDIF
      cText := Trim( Substr( cText, 1, At( "/*", cText ) - 1 ) )
   ENDIF
   IF nPos < Len( cText ) // tem algo além do ;, talvez IF x; ENDIF
      RETURN .F.
   ENDIF

   RETURN .T.

STATIC FUNCTION IsBeginComment( cText )

   RETURN Left( AllTrim( cText ), 2 ) == "*" + "/" .AND. ! "*" + "/" $ cText

STATIC FUNCTION IsEndComment( cText )

   RETURN Left( AllTrim( cText ), 2 ) == "*" + "/"

STATIC FUNCTION IsEmptyComment( cText )

   LOCAL oElement

   cText := AllTrim( cText )
   // caution with above line, to not consider */
   IF "*/" $ cText .OR. ! ( hb_LeftEq( cText, "*" ) .OR. hb_LeftEq( cText, "//" ) )
      RETURN .F.
   ENDIF
   FOR EACH oElement IN cText
      IF ! oElement $ "/-*~"
         RETURN .F.
      ENDIF
   NEXT

   RETURN .T.

FUNCTION IsCmdType( nType, cTxt, nPos )

   LOCAL oElement

   nPos := 0
   FOR EACH oElement IN FmtList( nType ) DESCEND
      IF Upper( cTxt ) == Upper( oElement ) .OR. hb_LeftEq( Upper( cTxt ) + " ", Upper( oELement ) + " " )
         nPos := oElement:__EnumIndex
         EXIT
      ENDIF
   NEXT
   //nPos := AScan( FmtList( nType ), { | e | Upper( cTxt ) == Upper( e ) .OR. hb_LeftEq( Upper( cTxt ), Upper( e ) + " " )  } )

   RETURN nPos != 0

STATIC FUNCTION FmtList( nType )

   LOCAL aList

   // only first world of line
   DO CASE
   CASE nType == FMT_TO_CASE // begin word(s) will be on this case, upper or lower

      aList := { ;
         "#command", ;
         "#define", ;
         "#else", ;
         "#endif", ;
         "#ifdef", ;
         "#ifndef", ;
         "#include", ;
         "#pragma", ;
         "#pragma begindump", ;
         "#pragma enddump", ;
         "#translate", ;
         "ACCEPT", ;
         "ACTION", ; // DEFINE
         "ACTIVATE WINDOW", ;
         "ADDITIVE", ; // DEFINE
         "ALIGNMENT", ; // DEFINE
         "ALLOWAPPEND", ; // DEFINE
         "ALLOWDELETE", ; // DEFINE
         "ALLOWEDIT", ; // DEFINE
         "ANNOUNCE", ;
         "ANYWHERESEARCH", ; // DEFINE
         "APPEND", ;
         "APPEND BLANK", ;
         "AUTOSIZE", ; // DEFINE
         "AVERAGE", ;
         "BACKCOLOR", ; // DEFINE
         "BEGIN", ;
         "BEGIN INI FILE", ;
         "CASE", ;
         "CAPTION", ; // DEFINE
         "CATCH", ;
         "CELLED", ; // DEFINE
         "CELLNAVIGATION", ; // DEFINE
         "CENTER WINDOW", ;
         "CHILD", ; // DEFINE
         "CLASS", ;
         "CLASSVAR", ;
         "CLEAR", ;
         "CLOSE", ;
         "COL", ; // DEFINE
         "COLOFFSET", ; // DEFINE
         "COLUMNWHEN", ; // DEFINE
         "COLUMNCONTROLS", ; // DEFINE
         "COLUMNVALID", ; // DEFINE
         "COMMIT", ;
         "CONTINUE", ;
         "COPY", ;
         "COUNT", ;
         "CREATE", ;
         "CREATE CLASS", ;
         "CUEBANNER", ; // DEFINE
         "DATA", ;
         "DECLARE", ;
         "DEFAULT", ;
         "DEFINE ACTIVEX", ;
         "DEFINE BROWSE", ;
         "DEFINE BUTTON", ;
         "DEFINE BUTTONEX", ;
         "DEFINE CHECKBOX", ;
         "DEFINE CHECKLIST", ;
         "DEFINE COMBOBOX", ;
         "DEFINE COMBOSEARCH", ;
         "DEFINE COMBOSEARCHBOX", ;
         "DEFINE COMBOSEARCHGRID", ;
         "DEFINE CONTEXT", ;
         "DEFINE CONTROL CONTEXTMENU", ;
         "DEFINE DATEPICKER", ;
         "DEFINE EDITBOX", ;
         "DEFINE FONT", ;
         "DEFINE FRAME", ;
         "DEFINE GRID", ;
         "DEFINE IMAGE", ;
         "DEFINE INTERNAL", ;
         "DEFINE LABEL", ;
         "DEFINE LISTBOX", ;
         "DEFINE MAIN MENU", ;
         "DEFINE MENU", ;
         "DEFINE PAGE", ;
         "DEFINE POPUP", ;
         "DEFINE RADIOGROUP", ;
         "DEFINE SLIDER", ;
         "DEFINE SPINNER", ;
         "DEFINE SPLITBOX", ;
         "DEFINE STATUSBAR", ;
         "DEFINE TAB", ;
         "DEFINE TBROWSE", ;
         "DEFINE TEXTBOX", ;
         "DEFINE TIMEPICKER", ;
         "DEFINE TREE", ;
         "DEFINE TOOLBAR", ;
         "DEFINE WINDOW", ;
         "DELETE", ;
         "DISPLAY", ;
         "DO CASE", ;
         "DO WHILE", ;
         "DRAW LINE", ;
         "DYNAMIC", ;
         "DYNAMICBACKCOLOR", ; // DEFINE
         "EJECT", ;
         "ELSE", ;
         "ELSEIF", ;
         "END", ;
         "END BROWSE", ;
         "END BUTTON", ;
         "END BUTTONEX", ;
         "END CLASS", ;
         "END CASE", ;
         "END CHECKBOX", ;
         "END COMBOBOX", ;
         "END COMBOSEARCH", ;
         "END COMBOSEARCHBOX", ;
         "END COMBOSEARCHGRID", ;
         "END FRAME", ;
         "END GRID", ;
         "END IF", ;
         "END IMAGE", ;
         "END INI", ;
         "END LABEL", ;
         "END MENU", ;
         "END PAGE", ;
         "END POPUP", ;
         "END PRINTDOC", ;
         "END PRINTPAGE", ;
         "END SEQUENCE", ;
         "END SPLITBOX", ;
         "END STATUSBAR", ;
         "END SWITCH", ;
         "END TAB", ;
         "END TEXTBOX", ;
         "END TIMEPICKER", ;
         "END WINDOW", ;
         "END WITH", ;
         "ENDCASE", ;
         "ENDCLASS", ;
         "ENDDO", ;
         "ENDFOR", ;
         "ENDIF", ;
         "ENDSEQUENCE", ;
         "ENDSWITCH", ;
         "ENDTEXT", ;
         "ENDWITH", ;
         "ERASE", ;
         "EXECUTE FILE", ;
         "EXIT", ;
         "EXIT PROCEDURE", ;
         "EXTERNAL", ;
         "FIELDS", ; // DEFINE
         "FONT", ; // DEFINE
         "FONTBOLD", ; // DEFINE
         "FONTCOLOR", ; // DEFINE
         "FONTITALIC", ; // DEFINE
         "FONTNAME", ; // DEFINE
         "FONTSIZE", ; // DEFINE
         "FONTUNDERLINE", ; // DEFINE
         "FOR", ;
         "FOR EACH", ;
         "FUNCTION", ;
         "HEADERS", ; // DEFINE
         "HEIGHT", ; // DEFINE
         "IF", ;
         "GET", ;
         "GOTO", ;
         "GO TOP", ;
         "ICON", ; // DEFINE
         "INCREMENT", ; // DEFINE
         "INDEX", ;
         "INDEX ON", ;
         "INIT", ;
         "INIT PROCEDURE", ;
         "INPLACEEDIT", ; // DEFINE
         "INPUT", ;
         "INPUTMASK", ; // DEFINE
         "ITEMCOUNT", ; // DEFINE
         "ITEMS", ; // DEFINE
         "JOIN", ;
         "JUSTIFY", ; // DEFINE
         "KEYBOARD", ;
         "LABEL", ;
         "LIST", ;
         "LOAD WINDOW", ;
         "LOCAL", ;
         "LOCATE", ;
         "LOCK", ; // DEFINE
         "LOOP", ;
         "MAIN", ; // DEFINE
         "MAXLENGTH", ; // DEFINE
         "MEMVAR", ;
         "MENU", ;
         "MENUITEM", ;
         "METHOD", ;
         "NEXT", ;
         "NOHSCROLL", ; // DEFINE
         "NOLINES", ; // DEFINE
         "NOMAXIMIZE", ; //DEFINE
         "NOSIZE", ; // DEFINE
         "NOSNOW", ; // DEFINE
         "NOSYSMENU", ; // DEFINE
         "NOTABSTOP", ; // DEFINE
         "NUMERIC", ; // DEFINE
         "ON CHANGE", ; // DEFINE
         "ON DBLCLICK", ; // DEFINE
         "ON ENTER", ; // DEFINE
         "ON GOTFOCUS", ; // DEFINE
         "ON INIT", ; // DEFINE
         "ON LOSTFOCUS", ; // DEFINE
         "ON KEY F5 ACTION", ;
         "ON KEY F6 ACTION", ;
         "ON KEY F7 ACTION", ;
         "ON KEY F8 ACTION", ;
         "ON KEY ESCAPE ACTION", ;
         "ON QUERYDATA", ; // DEFINE
         "ON RELEASE", ; // DEFINE
         "ONCHANGE", ; // DEFINE
         "ONCLICK", ; // DEFINE
         "ONDBLCLICK", ; // DEFINE
         "OTHER", ;
         "OTHERWISE", ;
         "PACK", ;
         "PARAMETERS", ;
         "PARENT", ; // DEFINE
         "PICTURE", ; // DEFINE
         "POPUP", ;
         "PRINT", ;
         "PRIVATE", ;
         "PROCEDURE", ;
         "PUBLIC", ;
         "QUIT", ;
         "RANGEMIN", ; // DEFINE
         "RANGEMAX", ; // DEFINE
         "READ", ;
         "READONLY", ; // DEFINE
         "RECALL", ;
         "RECOVER", ;
         "REINDEX", ;
         "RELEASE", ;
         "RELEASE WINDOW", ;
         "RENAME", ;
         "REPLACE", ;
         "REQUEST", ;
         "RESTORE", ;
         "RETURN", ;
         "RETURN NIL", ;
         "RETURN SELF", ;
         "RIGHTALIGN", ; // DEFINE
         "ROW", ; // DEFINE
         "ROWOFFSET", ; // DEFINE
         "RUN", ;
         "SAVE", ;
         "SEEK", ;
         "SELE", ;
         "SELECT", ;
         "SEPARATOR", ;
         "SET", ;
         "SET ALTERNATE ON", ;
         "SET ALTERNATE OFF", ;
         "SET ALTERNATE TO", ;
         "SET AUTOADJUST ON", ;
         "SET AUTOADJUST OFF", ;
         "SET BROWSESYNC ON", ;
         "SET BROWSESYNC OFF", ;
         "SET CENTURY ON", ;
         "SET CENTURY OFF", ;
         "SET CODEPAGE TO", ;
         "SET CONFIRM ON", ;
         "SET CONFIRM OFF", ;
         "SET CONSOLE ON", ;
         "SET CONSOLE OFF", ;
         "SET DEFAULT TO", ;
         "SET DATE", ;
         "SET DATE ANSI", ;
         "SET DATE BRITISH", ;
         "SET DELETED", ;
         "SET DELETED ON", ;
         "SET DELETED OFF", ;
         "SET EPOCH TO", ;
         "SET INTERACTIVECLOSE ON", ;
         "SET INTERACTIVECLOSE OFF", ;
         "SET LANGUAGE TO", ;
         "SET MULTIPLE ON WARNING", ;
         "SET MULTIPLE OFF WARNING", ;
         "SET NAVIGATION EXTENDED", ;
         "SET PATH TO", ;
         "SET PRINTER OFF", ;
         "SET PRINTER ON", ;
         "SET PRINTER TO", ;
         "SET RELATION TO", ;
         "SET SECTION", ;
         "SET TOOLTIPBALLOON ON", ;
         "SET TOOLTIPBALLOON OFF", ;
         "SHOWNONE", ; // DEFINE
         "SHOWHEADERS", ; // DEFINE
         "SKIP", ;
         "SORT", ;
         "START PRINTDOC", ;
         "START PRINTPAGE", ;
         "STATIC", ;
         "STATIC FUNCTION", ;
         "STATIC PROCEDURE", ;
         "STORE", ;
         "STRETCH", ; // DEFINE
         "SUM", ;
         "SWITCH", ;
         "SWITCH CASE", ;
         "TABSTOP", ; // DEFINE
         "TEXT", ;
         "THEAD STATIC", ;
         "TITLE", ; // DEFINE
         "TOOLTIP", ; // DEFINE
         "TOTAL", ;
         "TRANSPARENT", ; // DEFINE
         "UNLOCK", ;
         "UPDATE", ;
         "UPPERCASE", ; // DEFINE
         "USE", ;
         "VAR", ;
         "VALUE", ; // DEFINE
         "VCENTERALIGN", ; // DEFINE
         "VIRTUAL", ; // DEFINE
         "WAIT", ;
         "WHILE", ;
         "WIDTH", ; // DEFINE
         "WIDTHS", ; // DEFINE
         "WINDOW TYPE MAIN", ; // DEFINE
         "WITH OBJECT", ;
         "WORKAREA", ; // DEFINE
         "ZAP" }

   CASE nType == FMT_GO_AHEAD // after this, lines will be indented ahead
      aList := { ;
         "BEGIN", ;
         "CLASS", ;
         "CREATE CLASS", ;
         "DEFINE ACTIVEX", ;
         "DEFINE BUTTON", ;
         "DEFINE BUTTONEX", ;
         "DEFINE BROWSE", ;
         "DEFINE CHECKBOX", ;
         "DEFINE CHECKBUTTON", ;
         "DEFINE CHECKLIST", ;
         "DEFINE COMBOBOX", ;
         "DEFINE COMBOSEARCHBOX", ;
         "DEFINE COMBOSEARCHGRID", ;
         "DEFINE CONTEXT", ;
         "DEFINE CONTROL CONTEXTMENU", ;
         "DEFINE DATEPICKER", ;
         "DEFINE DROPDOWN", ;
         "DEFINE EDITBOX", ;
         "DEFINE FRAME", ;
         "DEFINE GRID", ;
         "DEFINE HYPERLINK", ;
         "DEFINE IMAGE", ;
         "DEFINE INTERNAL", ;
         "DEFINE IPADDRESS", ;
         "DEFINE LABEL", ;
         "DEFINE LISTBOX", ;
         "DEFINE MAIN MENU", ;
         "DEFINE MAINMENU", ;
         "DEFINE MENU", ;
         "DEFINE NODE", ;
         "DEFINE NOTIFY MENU", ;
         "DEFINE PAGE", ;
         "DEFINE PLAYER", ;
         "DEFINE POPUP", ;
         "DEFINE PROGRESSBAR", ;
         "DEFINE RADIOGROUP", ;
         "DEFINE REPORT", ;
         "DEFINE RICHEDITBOX", ;
         "DEFINE SLIDER", ;
         "DEFINE SPINNER", ;
         "DEFINE SPLITBOX", ;
         "DEFINE STATUSBAR", ;
         "DEFINE TAB", ;
         "DEFINE TEXTBOX", ;
         "DEFINE TIMEPICKER", ;
         "DEFINE TOOLBAR", ;
         "DEFINE TREE", ;
         "DEFINE WINDOW", ;
         "DO CASE", ;
         "DO WHILE", ;
         "FOR", ;
         "FUNC", ;
         "FUNCTION", ;
         "IF", ;
         "INIT PROC", ;
         "INIT PROCEDURE", ;
         "METHOD", ;
         "NODE", ;
         "PAGE", ;
         "POPUP", ;
         "PROC", ;
         "PROCEDURE", ;
         "RECOVER", ;
         "START HPDFDOC", ;
         "START HPDFPAGE", ;
         "START PRINTDOC", ;
         "START PRINTPAGE", ;
         "STATIC FUNC", ;
         "STATIC FUNCTION", ;
         "STATIC PROC", ;
         "STATIC PROCEDURE", ;
         "SWITCH", ;
         "TRY", ;
         "WHILE", ;
         "WITH OBJECT" }

   CASE nType == FMT_GO_BACK // including this, lines will be indented back

      aList := { ;
         "END", ;
         "ENDCASE", ;
         ; // "ENDCLASS", ;
         "ENDIF", ;
         "ENDDO", ;
         "ENDFOR", ;
         "ENDSWITCH", ;
         "ENDWITH", ;
         "NEXT" }

   CASE nType == FMT_SELF_BACK // this line will be indented back
      aList := { ;
         "CASE", ;
         "CATCH", ;
         "ELSE", ;
         "ELSEIF", ;
         "OTHER", ;
         "OTHERWISE", ;
         "RECOVER" }

   CASE nType == FMT_BLANK_LINE // a blank line before this line
      aList := { ;
         "CLASS", ;
         "CREATE CLASS", ;
         "END CLASS", ;
         "ENDCLASS", ;
         "FUNCTION", ;
         "METHOD", ;
         "PROC", ;
         "PROCEDURE", ;
         "STATIC FUNC", ;
         "STATIC FUNCTION", ;
         "STATIC PROC", ;
         "STATIC PROCEDURE" }

   CASE nType == FMT_DECLARE_VAR // only to group declarations
      aList := { ;
         "FIELD", ;
         "LOCAL", ;
         "MEMVAR", ;
         "PRIVATE", ;
         "PUBLIC" }

   CASE nType == FMT_AT_BEGIN // this will be at ZERO Column
      aList := { ;
         "CREATE CLASS", ;
         "CLASS", ;
         "EXIT PROCEDURE", ;
         "INIT PROCEDURE", ;
         "METHOD", ;
         "FUNCTION", ;
         "PROCEDURE", ;
         "STATIC FUNCTION", ;
         "STATIC PROCEDURE" }

   CASE nType == FMT_FROM_TO
      aList := { ;
         { "SET DATE BRIT", "SET DATE BRITISH" }, ;
         { "SET CONF ON", "SET CONFIRM ON" }, ;
         { "SET DELE ON", "SET DELETED ON" }, ;
         { "SET DELE OFF", "SET DELETED OFF" }, ;
         { "SET INTE ON", "SET INTENSITY ON" }, ;
         { "SET STAT OFF", "SET STATUS OFF" }, ;
         { "SET SCOR ON", "SET SCOREBOARD ON" }, ;
         { "SET SCOR OFF", "SET SCOREBOARD OFF" }, ;
         { "ENDC", "ENDCASE" }, ;
         { "ENDI", "ENDIF" }, ;
         { "ENDD", "ENDDO" }, ;
         { "RETU", "RETURN" }, ;
         { "RETU .T.", "RETURN .T." }, ;
         { "RETU .F.", "RETURN .F." }, ;
         { "RETU(.T.)", "RETURN .T." }, ;
         { "RETU(.F.)", "RETURN .F." }, ;
         { "RETURN(.T.)", "RETURN .T." }, ;
         { "RETURN(.F.)", "RETURN .F." }, ;
         { "RETU NIL", "RETURN NIL" }, ;
         { "RETURN(NIL)", "RETURN NIL" }, ;
         { "CLOSE DATA", "CLOSE DATABASES" } }

   CASE nType == FMT_CASE_ANY // on any line posicion
      aList := { ;
         " .AND. ", ;
         " .NOT. ", ;
         " .OR. ", ;
         " Aadd(", ;
         "(Aadd(", ;
         " Asc(", ;
         " Alert(", ;
         " ALIAS ", ;
         " AllTrim(", ;
         "(AllTrim(", ;
         " APPEND FROM", ;
         " Bof(", ;
         " Chr(", ;
         "(Chr({", ;
         " Col(", ;
         " dbGoBottom(", ;
         "(dbGoBottom(", ;
         " dbGoTop(", ;
         "(dbGoTop(", ;
         " File(", ;
         "(File(", ;
         "!File(", ;
         " Date(", ;
         "(Date(", ;
         " Day(", ;
         "(Day(", ;
         " dbDelete(", ;
         "(dbDelete(", ;
         " dbGoto(", ;
         "(dbGoTo(", ;
         " dbSeek(", ;
         "(dbSeek(", ;
         "!dbSeek(", ;
         " dbSetOrder(", ;
         "(dbSetOrder(", ;
         " dbSkip(", ;
         "(dbSkip(", ;
         " dbStruct(", ;
         "(dbStruct(", ;
         " DO WHILE ", ;
         " Dtoc(", ;
         "(Dtoc(", ;
         " Dtos(", ;
         "(Dtos(", ;
         " Empty(", ;
         "(Empty(", ;
         "!Empty(", ;
         " Eof(", ;
         "!Eof(", ;
         "(Eof(", ;
         "(!Eof(", ;
         " File(", ;
         " FUNCTION ", ;
         " GET ", ;
         " GetList ", ;
         " IF ", ;
         " INDEX ", ;
         " INDEX ON ", ;
         " Inkey(", ;
         " Int(", ;
         " LastKey(", ;
         " Left(", ;
         " Len(", ;
         "(Len(", ;
         "+Len(", ;
         "-Len(", ;
         ",Len(", ;
         " Lower(", ;
         "(Lower(", ;
         " MemoEdit(", ;
         " MemoLine(", ;
         "(MemoLine(", ;
         " MemoRead(", ;
         " MemoWrit(", ;
         " MEMVAR ", ;
         " Mensagem(", ;
         " Month(", ;
         "(Month(", ;
         " NetErr(", ;
         " Pad(", ;
         " Padc", ;
         " Padr(", ;
         " PICTURE ", ;
         " PROCEDURE ", ;
         " pCol()", ;
         " RecNo(", ;
         "(RecNo(", ;
         " Replicate(", ;
         "(Replicate(", ;
         " Right(", ;
         " RLock(", ;
         "(RLock(", ;
         " pRow()", ;
         " Round(", ;
         "(Round(", ;
         " Row(", ;
         " SAY ", ;
         " Scroll(", ;
         "(Scroll(", ;
         " SET DEVICE TO PRINT", ;
         " SET DEVICE TO SCREEN", ;
         " SET INDEX TO", ;
         " SET PRINTER TO", ;
         " SetCursor(", ;
         " SetColor(", ;
         " Space(", ;
         "(Space(", ;
         ",Space(", ;
         " Str(", ;
         "(Str(", ;
         " StrZero(", ;
         "(StrZero(", ;
         "+StrZero(", ;
         " Substr(", ;
         "(Substr(", ;
         "+Substr(", ;
         " RestScreen(", ;
         " SaveScreen(", ;
         " Time(", ;
         "(Time(", ;
         "+Time(", ;
         " Tone(", ;
         " Transform(", ;
         "(Transform(", ;
         " Type(", ;
         " Upper(", ;
         "(Upper(", ;
         " Val(", ;
         "(Val(", ;
         " Year(", ;
          "(Year(" }

   ENDCASE

   RETURN aList

FUNCTION MakeBackup( cFile )

   LOCAL cFileBak

   IF "." $ cFile
      cFileBak := Substr( cFile, 1, Rat( ".", cFile ) ) + "bak"
   ELSE
      cFileBak := cFile + ".bak"
   ENDIF
   IF .F.
      hb_MemoWrit( cFileBak, MemoRead( cFile ) )
   ENDIF

   RETURN NIL

FUNCTION FmtCaseFromAny( cLinePrg )

   LOCAL aList := FmtList( FMT_CASE_ANY )
   LOCAL nPos, oElement

      FOR EACH oElement IN aList
         nPos := 1
         DO WHILE hb_At( Upper( oElement ), Upper( cLinePrg ), nPos ) != 0
            nPos := hb_At( Upper( oElement ), Upper( cLinePrg ), nPos )
            cLinePrg := Substr( cLinePrg, 1, nPos - 1 ) + oElement + Substr( cLinePrg, nPos + Len( oElement ) )
            nPos += Len( oElement )
         ENDDO
      NEXT

   RETURN cLinePrg
