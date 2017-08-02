/*
ZE_SQLBACKUP - Backup de MySQL
José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"

FUNCTION SQLBackup()

   LOCAL oTableList, cTable, oTableCreate, nHandle, nQtd, nLimitStart, xValue, nCont, nQtdFields, nQtdRec, cTxt
   LOCAL cFixSql, nKey := 0, nMySqlLimitRecBackup
   LOCAL cnGERAL := ADOClass():New( AppcnMySqlLocal() )

   Mensagem( "Fazendo backup da base MySql" )
   nHandle      := fCreate( "backup.sql" )
   cnGERAL:cSql := "SHOW TABLES;"
   oTableList   := cnGERAL:ExecuteCmd( cnGERAL:cSql )
   fWrite( nHandle, "SET autocommit=0;" + hb_eol() )
   fWrite( nHandle, "SET unique_checks=0;" + hb_eol() )
   fWrite( nHandle, "SET foreign_key_checks=0;" + hb_eol() )
   DO WHILE nKey != K_ESC .AND. ! oTableList:Eof()
      cTable       := oTableList:Fields( "tables_in_" + Lower( AppEmpresaApelido() ) ):Value
      cnGERAL:cSql := "SHOW CREATE TABLE `" + cTable + "`"
      oTableCreate := cnGERAL:ExecuteCmd( cnGERAL:cSql )
      fWrite( nHandle, "DROP TABLE IF EXISTS `" + cTable + "`;" + hb_eol() )
      fWrite( nHandle, StrTran( oTableCreate:Fields( "Create Table" ):Value, Chr(10), hb_eol() ) + ";" )
      fWrite( nHandle, hb_eol() + hb_eol() )
      oTableCreate:Close()
      cnGERAL:cSql := "SELECT COUNT(*) AS QTD FROM `" + cTable + "`"
      cnGERAL:Execute()
      nQtd := cnGERAL:NumberSql( "QTD" )
      cnGERAL:CloseRecordset()
      SayScroll( "Fazendo backup do MySql " + cTable + " (" + Ltrim( Transform( nQtd, PicVal(9,0) ) ) + ")" )
      fWrite( "LOCK TABLES `" + cTable + "` WRITE;" + hb_eol() )
      fWrite( nHandle, "ALTER TABLE `" + cTable + "` DISABLE KEYS;" + hb_eol() )
      nLimitStart := 0
      nMySqlLimitRecBackup := iif( "XML" $ Upper( cTable ), Int( MYSQL_MAX_RECBACKUP / 10 ), MYSQL_MAX_RECBACKUP )
      GrafTempo( "Backup " + cTable )
      DO WHILE nKey != K_ESC .AND. nLimitStart <= nQtd
         GrafTempo( nLimitStart - 1, nQtd )
         cnGERAL:cSql := "SELECT * FROM `" + cTable + "` LIMIT " + Ltrim( Str( nLimitStart ) ) + ", " + Ltrim( Str( nMySqlLimitRecBackup ) )
         cnGERAL:Execute()
         nQtdFields := cnGERAL:Rs:Fields:Count() - 1
         nQtdRec    := cnGERAL:Rs:RecordCount()
         cFixSql := "INSERT INTO `" + cTable + "` "
         IF .F. // com nomes de campos
            cFixSql += "( "
            FOR nCont = 0 TO nQtdFields
               cFixSql += "`" + cnGERAL:Rs:Fields( nCont ):Name + "`"
               IF nCont != nQtdFields
                  cFixSql += ", "
               ENDIF
            NEXT
            cFixSql += ") "
         ENDIF
         cFixSql += "VALUES "
         cFixSql += hb_eol()
         cTxt := ""
         DO WHILE nKey != K_ESC .AND. ! cnGERAL:Rs:Eof()
            Inkey()
            IF Len( cTxt ) == 0
               cTxt += cFixSql
            ENDIF
            cTxt += "( "
            FOR nCont = 0 TO nQtdFields
               xValue := cnGERAL:Rs:Fields( nCont ):Value
               DO CASE
               CASE ValType( xValue ) == "N"
                  xValue := NumberSql( xValue )
               CASE ValType( xValue ) == "D"
                  xValue := DateSql( xValue )
               CASE ValType( xValue ) == "C"
                  xValue := StringSql( xValue )
               OTHERWISE
                  xValue := "NULL"
               ENDCASE
               cTxt += xValue
               IF nCont != nQtdFields
                  cTxt += ", "
               ENDIF
            NEXT
            cTxt += " )"
            nQtdRec -= 1
            IF Len( cTxt ) > MYSQL_MAX_CMDINSERT
                fWrite( nHandle, cTxt + " ;" + hb_eol() )
                cTxt := ""
            ENDIF
            IF Len( cTxt ) != 0 .AND. nQtdRec != 0
               cTxt += ", " + hb_eol()
            ENDIF
            cnGERAL:MoveNext()
         ENDDO
         cnGERAL:CloseRecordset()
         IF Len( cTxt ) != 0
            IF Right( cTxt, 4 ) == ", " + hb_eol()
               cTxt := Substr( cTxt, 1, Len( cTxt ) - 4 )
            ENDIF
            fWrite( nHandle, cTxt + ";" + hb_eol())
         ENDIF
         nLimitStart += nMySqlLimitRecBackup
      ENDDO
      fWrite( nHandle, "ALTER TABLE `" + cTable + "` ENABLE KEYS;" + hb_eol() )
      fWrite( nHandle, "UNLOCK TABLES;" + hb_eol() )
      oTableList:MoveNext()
   ENDDO
   fWrite( nHandle, "SET autocommit=1;" + hb_eol() )
   fWrite( nHandle, "SET unique_checks=1;" + hb_eol() )
   fWrite( nHandle, "SET foreign_key_checks=1;" + hb_eol() )
   fWrite( nHandle, "COMMIT" + hb_eol() )
   oTableList:Close()
   fClose( nHandle )

   RETURN NIL
