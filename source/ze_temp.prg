/*
ZE_TEMP
José Quintas
*/

#include "directry.ch"

FUNCTION AppTempPath()

   LOCAL cPath

   cPath := hb_DirTemp()
   IF " " $ cPath .OR. Empty( cPath )
      cPath := "TEMP\"
   ENDIF

   RETURN cPath

FUNCTION MyTempFile( cExt, cPath )

   LOCAL cFileName, nHandle

   hb_Default( @cExt, "TMP" )
   hb_Default( @cPath, AppTempPath() )
   nHandle := hb_FTempCreateEx( @cFileName, cPath, "TMP", "." + cExt )
   FClose( nHandle )
   IF Upper( Right( cFileName, 4 ) ) != Upper( "." + cExt )
      fRename( cFileName, cFileName + "." + cExt )
      cFileName := cFileName + "." + cExt
   ENDIF
   DelTempFiles()

   RETURN cFileName

FUNCTION TempFileArray( nQtd, cExt )

   LOCAL acFileName := {}, nCont

   FOR nCont = 1 TO nQtd
      Aadd( acFileName, MyTempFile( cExt ) )
   NEXT

   RETURN acFileName

FUNCTION DelTempFiles()

   LOCAL aFilelist, cTempPath, nPastTime, oFile

   cTempPath := AppTempPath()
   IF Len( cTempPath ) == 0
      RETURN NIL
   ENDIF
   // se tem arquivo do sistema não apaga nada
   IF File( cTempPath + "jpempre.dbf" )  .OR. File( cTempPath + "jpnota.dbf" ) .OR. File( cTempPath + "jpa.cfg" )
      RETURN NIL
   ENDIF
   aFileList := Directory( cTempPath + "*.*" )
   IF Len( aFileList ) == Len( Directory( "*.*" ) ) // mesmo tamanho da pasta atual
      RETURN NIL
   ENDIF
   IF Len( aFileList ) > 1
      FOR EACH oFile IN aFileList
         IF ( ".DBF" $ Upper( oFile[ F_NAME ] ) .OR. ".CFG" $ Upper( oFile[ F_NAME ] ) ) .AND. ! "TMP" $ Upper( oFile[ F_NAME ] )
            nPastTime := 0
         ELSEIF oFile[ F_DATE ] != Date() .AND. oFile[ F_TIME ] > "04:00:00"
            nPastTime := 24
         ELSE
            nPastTime := Val( Substr( Time(), 1, 2 ) ) - Val( Substr( oFile[ F_TIME ], 1, 2 ) )
         ENDIF
         IF nPastTime > 5
            BEGIN SEQUENCE WITH __BreakBlock()
               fErase( cTempPath + oFile[ F_NAME ] )
            END SEQUENCE
         ENDIF
      NEXT
   ENDIF

   RETURN NIL
