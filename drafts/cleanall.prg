/*
CLEANALL - make a clean on temporary files, and GUI folders
*/

#include "directry.ch"
#include "inkey.ch"

PROCEDURE Main

   LOCAL nKey := 0, nBytesDeleted := 0, nFilesDeleted := 0

   SetMode( 33, 100 )
   CLS
   ? "Press ESC to NOT clean .hbmk folders and c:\temp\*.*"
   IF Inkey(0) == K_ESC
      RETURN
   ENDIF
   DeleteAll( "c:\temp\", @nBytesDeleted, @nFilesDeleted, .F. )
   DeleteHbmk( "d:\", @nBytesDeleted, @nFilesDeleted )
   ? "Deleted " + Ltrim( Str( nFilesDeleted ) ) + " file(s), Size " + Ltrim( Transform( nBytesDeleted, "@E 999,999,999,999,999" ) )
   ? "Press ESC to NOT clean ALLGUI Folders"
   IF Inkey(0) == K_ESC
      RETURN
   ENDIF
   ? "d:\github\allgui\"
   FormatFiles( "d:\github\allgui\", @nKey, @nBytesDeleted, @nFilesDeleted )
   ? "Deleted " + Ltrim( Str( nFilesDeleted ) ) + " files(s), size " + Ltrim( Transform( nBytesDeleted, "@E 999,999,999,999,999" ) )

   RETURN

FUNCTION FormatFiles( cPath, nKey, nBytesDeleted, nFilesDeleted )

   LOCAL aFiles, oFile, cFileName, cExtensao

   aFiles := Directory( cPath + "*.*", "DSH" )
   FOR EACH oFile IN aFiles
      GrafProc()
      cFileName := oFile[ F_NAME ]
      cExtensao := Upper( iif( "." $ cFileName, Substr( cFileName, Rat( ".", cFileName ) ), ""  ) )
      IF "HARBOUR" $ cPath + cFileName
         ? cPath + cFileName
      ENDIF
      DO CASE
      CASE cFileName == "."
      CASE cFileName == ".."
      CASE "D" $ oFile[ F_ATTR ]
         //IF ! oFile[ F_ATTR ] == "D"
         //   SET COLOR TO R/W
         //   ? "Folder attribute " + oFile[ F_ATTR ] + " " + cPath + cFileName
         //   SET COLOR TO W/N
         //ENDIF
         IF Upper( cFileName ) == "CVS" .OR. ;
               Upper( cFileName ) == ".SSH" .OR. ;
               Upper( cFileName ) == "BATCH" .OR. ;
               Upper( cFileName ) == ".SVN"
            DeleteAll( cPath + cFileName + "\", @nBytesDeleted, @nFilesDeleted )
         ELSE
            FormatFiles( cPath + cFileName + "\", @nKey, @nBytesDeleted, @nFilesDeleted )
         ENDIF
      CASE FileSize( cPath + cFileName ) == 0
         fErase( cPath + cFileName )
      CASE Upper( cFileName ) == "WINREG.C" .AND. "HWGUI" $ cPath
         SET COLOR TO R/W
         ? "File NOT used on HWGUI " + cPath + cFileName
         SET COLOR TO W/N
      CASE Upper( cFileName ) == ".CVSIGNORE" .OR. ;
            Upper( cFileName ) == "UNINS000.DAT" .OR. ;
            Upper( cFileName ) == "ERRORLOG.HTM" .OR. ;
            ( hb_AScan( { ".A", ".LIB", ".XBP", ".LOG", ".OBJ", ".CDX", ".PPO", ".NTX" }, cExtensao, , , .T. ) != 0 )
         nBytesDeleted += FileSize( cPath + cFileName )
         nFilesDeleted += 1
         ? "Deleting " + cPath + oFile[ F_NAME ]
         fErase( cPath + cFileName )
      CASE Upper( cFileName ) == "HBIDE.EXE" .OR. Upper( cFileName ) == "CLEANALL.EXE"
      CASE hb_AScan( { ".PRG", ".HBC", ".HBM", ".CH", ".H", ".HBP", ".INI", ".HBM", ".RC", ".HTML", ".HTM", ;
            ".CSS", ".SH", ".XML", ".C", ".TXT", ".URL", ".JS", ".RC", ".FMG", ".MANIFEST", ".RPT" }, cExtensao,,, .T. ) != 0 ;
            .OR. Upper( cFileName ) == "CHANGELOG" .OR. Upper( cFileName ) == "SUGGESTIONS"
         FormatFile( cPath + oFile[ F_NAME ], @nKey )
      CASE "\ALLGUI\ALLGUI\" $ Upper( cPath ) .OR. "\ALLGUIPAULO\ALLGUI\" $ Upper( cPath )
      CASE cExtensao == ".EXE" .AND. "FIVEWIN" $ Upper( cPath )
      CASE hb_AScan( { ".BAT" }, cExtensao,,, .T. ) != 0 .AND. ( "\MIX\" $ Upper( cPath ) .OR. "\SAMPLES\OOHG\" $ cPath )
      CASE hb_AScan( { ".HBX", ".IML", ".SCR", "*.IML", ".BC", ".GCC", ".PC", ".VC", ".WC", ".LINUX", ".BAT", ".EXE" }, cExtensao, , , .T. ) != 0 ;
            .OR. Upper( cFileName ) == "HB_OUT.LOG" .OR. Upper( cFileName ) == "MAKEFILE"
         nBytesDeleted += FileSize( cPath + cFileName )
         nFilesDeleted += 1
         ? "Deleting " + cPath + oFile[ F_NAME ]
         fErase( cPath + cFileName )
      ENDCASE
      IF nKey == K_ESC
         EXIT
      ENDIF
   NEXT

   RETURN NIL

FUNCTION FormatFile( cFile, nKey )

   LOCAL cTxt, cTxtAnt

   cTxtAnt := MemoRead( cFile )

   cTxt := cTxtAnt
   cTxt := StrTran( cTxt, Chr(9), Space(3) )
   cTxt := StrTran( cTxt, hb_Eol(), Chr(13) )
   cTxt := StrTran( cTxt, Chr(10), Chr(13) )
   cTxt := StrTran( cTxt, Chr(13), hb_Eol() )
   DO WHILE " " + hb_Eol() $ cTxt
      cTxt := StrTran( cTxt, " " + hb_Eol(), hb_Eol() )
   ENDDO
   IF ! cTxt == cTxtAnt
      ? "Formatted " + cFile
      hb_MemoWrit( cFile, cTxt )
   ENDIF
   nKey := Inkey()

   RETURN NIL

FUNCTION DeleteHbmk( cPath, nBytesDeleted, nFilesDeleted )

   LOCAL aFiles, oFile

   aFiles := Directory( cPath + "*.*", "DSH" )
   FOR EACH oFile IN aFiles
      GrafProc()
      DO CASE
      CASE Upper( oFile[ F_NAME ] ) == "."
      CASE Upper( oFile[ F_NAME ] ) == ".."
      CASE "D" $ oFile[ F_ATTR ]
         IF Upper( oFile[ F_NAME ] ) == ".HBMK" .OR. ( "\CVSFILES\VSZAKATS\" $ Upper( cPath ) .AND. "\OBJ\WIN\" $  Upper( cPath ) )
            DeleteAll( cPath + oFile[ F_NAME ] + "\", @nBytesDeleted, @nFilesDeleted )
         ELSE
            DeleteHbmk( cPath + oFile[ F_NAME ] + "\", @nBytesDeleted, @nFilesDeleted )
         ENDIF
      ENDCASE
   NEXT

   RETURN NIL

FUNCTION DeleteAll( cPath, nBytesDeleted, nFilesDeleted, lRemoveFolder )

   LOCAL aFiles, oFile

   hb_Default( @lRemoveFolder, .T. )
   ? cPath
   aFiles := Directory( cPath + "*.*", "D" )
   FOR EACH oFile IN aFiles
      DO CASE
      CASE oFile[ F_NAME ] == "."
      CASE oFile[ F_NAME ] == ".."
      CASE "D" $ oFile[ F_ATTR ]
         DeleteAll( cPath + oFile[ F_NAME ] + "\", @nBytesDeleted, @nFilesDeleted )
      OTHERWISE
         ? "Deleting " + cPath + oFile[ F_NAME ]
         nBytesDeleted += FileSize( cPath + oFile[ F_NAME ] )
         nFilesDeleted += 1
         fErase( cPath + oFile[ F_NAME ] )
      ENDCASE
   NEXT
   IF lRemoveFolder
      ? "Deleting Folder " + Left( cPath, Len( cPath ) - 1 )
      DirRemove( Left( cPath, Len( cPath ) - 1 ) )
   ENDIF

   RETURN NIL

FUNCTION FileSize( cFile )

   LOCAL aFiles, nSize := 0

   aFiles := Directory( cFile )
   IF Len( aFiles ) > 0
      nSize := aFiles[ 1, F_SIZE ]
   ENDIF

   RETURN nSize

FUNCTION GrafProc()

   STATIC StaticProc := 1
   STATIC StaticTime := "X"

   LOCAL nRow, nCol

   IF StaticTime != Time()
      nRow := Row()
      nCol := Col()
      @ MaxRow(), 0 SAY Substr( "|/-\", StaticProc, 1 )
      StaticProc += iif( StaticProc == 4, -3, 1 )
      @ nRow, nCol SAY ""
      StaticTime := Time()
   ENDIF

   RETURN NIL
