*
PTESMDB - GRAVA DBFS EM MDB
José Quintas
*/

#include "inkey.ch"
#include "directry.ch"

PROCEDURE PTESMDB

   LOCAL oCatalog, oCn, cSql, cString, oFiles, oStru, cTable, nCont2, cSqlInsert, oFileDbf

   IF ! MsgYesNo( "Confirma?" )
      RETURN
   ENDIF

   fErase( "jpa.mdb" )
   RddSetDefault( "DBFCDX" )
   Set( _SET_CODEPAGE, "PTISO" )
   cString := "Provider=Microsoft.Jet.OLEDB.4.0;Jet OLEDB:Engine Type=5;Data Source=jpa.mdb"
   oCatalog := win_OleCreateObject( "ADOX.Catalog" )
   oCatalog:Create( cString )

   oCn := win_OleCreateObject( "ADODB.Connection" )
   oCn:ConnectionString := cString
   oCn:CursorLocation    := 3  // cliente
   oCn:CommandTimeOut    := 30 // seconds
   oCn:ConnectionTimeOut := 30 // seconds

   oCn:Open()

   oFiles := Directory( "*.dbf" )

   FOR EACH oFileDbf IN oFiles
      cTable := oFileDbf[ F_NAME ]
      cTable := hb_FNameName( cTable )
      SayScroll( cTable )
      USE ( cTable )
      cSql := "CREATE TABLE " + cTable + " ( "
      cSqlInsert := "INSERT INTO " + cTable + " ( "
      oStru := dbStruct()
      FOR nCont2 = 1 TO Len( oStru )
         cSql += FieldName( nCont2 ) + " "
         cSqlInsert += FieldName( nCont2 ) + " "
         DO CASE
         CASE oStru[ nCont2, 2 ] $ "CM"
            cSql += "TEXT"
         CASE oStru[ nCont2, 2 ] == "N"
            cSql += "DOUBLE"
         CASE oStru[ nCont2, 2 ] == "D"
            cSql += "DATE "
         ENDCASE
         IF nCont2 < Len( oStru )
            cSql += ", "
            cSqlInsert += ", "
         ENDIF
      NEXT
      cSql += " );"
      oCn:Execute( cSql )
      cSqlInsert += " ) VALUES ( "
      GOTO TOP
      DO WHILE ! Eof()
         cSql := cSqlInsert
         FOR nCont2 = 1 TO Len( oStru )
            DO CASE
            CASE oStru[ nCont2, 2 ] $ "CM"
               cSql += StringSql( Trim( FieldGet( nCont2 ) ) )
            CASE oStru[ nCont2, 2 ] == "N"
               cSql += Ltrim( Str( FieldGet( nCont2 ) ) )
            CASE oStru[ nCont2, 2 ] == "D"
               IF Empty( FieldGet( nCont2 ) )
                  cSql += "NULL"
               ELSE
                  cSql += StringSql( Transform( Dtos( FieldGet( nCont2 ) ), "@R 9999-99-99" ) )
               ENDIF
            ENDCASE
            IF nCont2 < Len( oStru )
               cSql += ", "
            ENDIF
         NEXT
         cSql += " )"
         oCn:Execute( cSql )
         SKIP
      ENDDO
      USE
   NEXT
   oCn:Close()

   RETURN
