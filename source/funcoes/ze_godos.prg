/*
ZE_GODOS
José Quintas
*/

FUNCTION GoDos()

   IF AppUserLevel() == 0
      ShellExecuteOpen( GetEnv( "COMSPEC" ) )
   ENDIF

   RETURN NIL

