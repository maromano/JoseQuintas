/*
ZE_APPDATABASE
José Quintas
*/

#include "josequintas.ch"

FUNCTION AppDatabase()

   STATIC AppDatabase := 999

   IF AppDatabase == 999
      AppDatabase := DATABASE_DBF
      IF File( "jpa.cfg" )
         IF "netio" $ Lower( XmlNode( MemoRead( "jpa.cfg" ), "dbf" ) )
            AppDatabase := DATABASE_HBNETIO
         ENDIF
      ENDIF
   ENDIF

   RETURN AppDatabase
