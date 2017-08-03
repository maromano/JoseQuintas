/*
ZE_SHELLEXECUTE
José Quintas
*/

FUNCTION ShellExecuteOpen( cFileName, cParameters, nShow )

   hb_Default( @nShow, WIN_SW_SHOWNORMAL )
   WAPI_ShellExecute( NIL, "open", cFileName, cParameters,, nShow )

   RETURN NIL

FUNCTION ShellExecutePrint( cFileName, cParameters, nShow )

   hb_Default( @nShow, WIN_SW_SHOWMINNOACTIVE )
   WAPI_ShellExecute( NIL, "print", cFileName, cParameters,, nShow )

   RETURN NIL

