/*
sjpa - intermediário pra carga do EXE final
*/

REQUEST HB_Codepage_PTISO

#include "directry.ch"
#include "hbwin.ch"

PROCEDURE Main( cmdParam1, CmdParam2, cmdParam3, cmdParam4, cmdParam5 )

   LOCAL oExeList, cPath

   Set( _SET_CODEPAGE, "PTISO" )
   SET DATE BRITISH
   SET EPOCH TO Year( Date() ) - 90

   cPath := hb_FNameDir( hb_ProgName() )
   cmdParam1 := iif( cmdParam1 == NIL, "", cmdParam1 )
   cmdParam2 := iif( cmdParam2 == NIL, "", cmdParam2 )
   cmdParam3 := iif( cmdParam3 == NIL, "", cmdParam3 )
   cmdParam4 := iif( cmdParam4 == NIL, "", cmdParam4 )
   cmdParam5 := iif( cmdParam5 == NIL, "", cmdParam5 )

   oExeList := Directory( cPath + "JPA*.EXE" )

   IF Len( oExeList ) == 0
      MsgExclamation( "Não encontrado EXE na pasta " + cPath )
      RETURN
   ENDIF

   ASort( oExeList, , , { | a, b | Dtos( a[ F_DATE ] ) + a[ F_TIME ] > Dtos( b[ F_DATE ] ) + b[ F_TIME ] } )
   WAPI_ShellExecute( NIL, "open", cPath + oExeList[ 1, F_NAME ], cmdParam1 + " " + cmdParam2 + " " + cmdParam3 + " " + cmdParam4 + " " + cmdParam5, hb_cwd(), SW_SHOWNORMAL )

   RETURN

FUNCTION MsgExclamation( cText )

   wapi_MessageBox( wapi_GetActiveWindow(), cText, "Atenção", WIN_MB_ICONASTERISK )

   RETURN NIL
