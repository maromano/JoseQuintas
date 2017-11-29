/*
ZE_SQLFROMDBF - Transfere de DBF pra MySQL
José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "dbstruct.ch"

FUNCTION SqlFromDbf()

   LOCAL oFiles, nCont, acAchoice := {}, cFileDbf, nOpc := 1, cConfirma := "NAO", GetList := {}

   IF AppcnMySqlLocal() == NIL
      MsgExclamation( "Não tem conexão MySql pra esta empresa" )
      RETURN NIL
   ENDIF

   @ 2, 1 SAY "ATENÇÃO"
   @ Row() + 1, 1 SAY "Os dados dos DBFs são salvos no MySql."
   @ Row() + 1, 1 SAY "Se quiser eliminar dados anteriores do MySql, precisa fazer manualmente"
   @ Row() + 1, 1 SAY "Se quiser eliminar dados finais do DBF, precisa fazer manualmente"

   oFiles := CnfDbfInd()
   FOR nCont = 1 TO Len( oFiles )
      AAdd( acAchoice, oFiles[ nCont, 1 ] )
   NEXT
   DO WHILE .T.
      wAchoice( Row() + 1, 5, acAchoice, @nOpc, "Arquivos a transferir" )
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      cFileDbf := Upper( oFiles[ nOpc, 1 ] )
      Mensagem( "Confirme criar estrutura para " + cFileDbf )
      @ Row(), Col() + 2 GET cConfirma PICTURE "@!"
      READ
      Mensagem()
      IF LastKey() == K_ESC .OR. cConfirma != "SIM"
         LOOP
      ENDIF
      CopyDbfToMySql( cFileDbf, .F., .T., .F., cFileDbf )
   ENDDO

   RETURN NIL

FUNCTION CopyDbfToMySql( cTable, lTransfere, lCria, lZera, cNewTable )

   LOCAL oStru
   LOCAL cSql, xValue, nCont, cSqlFix
   LOCAL lBegin := .T., cTxt, cKeyName
   LOCAL cnGERAL := ADOClass():New( AppcnMySqlLocal() )
   LOCAL nSelect := Select()

   IF ! File( cTable + iif( ".DBF" $ Upper( cTable ), "", ".DBF" ) )
      RETURN NIL
   ENDIF
   hb_Default( @lCria, .F. )
   hb_Default( @lZera, .F. )
   hb_Default( @cNewTable, cTable )
   cTable      := Upper( cTable )
   SELECT 0
   USE ( cTable ) ALIAS DbfDb
   oStru    := dbStruct()
   cKeyName := Substr( oStru[ DBS_NAME, 1 ], 1, 2 ) + "ID"
   USE
   cSql := "CREATE TABLE IF NOT EXISTS " + cNewTable + " ( " + cKeyName + " INT(9) NOT NULL AUTO_INCREMENT, "
   FOR nCont = 1 TO Len( oStru )
      cSql += oStru[ nCont, DBS_NAME ] + " "
      DO CASE
      CASE oStru[ nCont, DBS_TYPE ] == "N"
         IF oStru[ nCont, DBS_DEC ] == 0
            cSql += " INT( " + Ltrim( Str( oStru[ nCont, DBS_LEN ] ) ) + " ) DEFAULT 0"
         ELSE
            cSql += " DOUBLE( " + Ltrim( Str( oStru[ nCont, DBS_LEN ] ) ) + " , " + Ltrim( Str( oStru[ nCont, DBS_DEC ] ) ) + " ) DEFAULT 0"
         ENDIF
      CASE oStru[ nCont, DBS_TYPE ] == "C"
         IF oStru[ nCont, DBS_LEN ] < 250
            cSql += " VARCHAR( " + Ltrim( Str( oStru[ nCont, DBS_LEN ] ) ) + " ) DEFAULT '' "
         ELSE
            cSql += " TEXT"
         ENDIF
      CASE oStru[ nCont, DBS_TYPE ] == "D"
         cSql += " DATE " // DEFAULT '0000-00-00'"
      CASE oStru[ nCont, DBS_TYPE ] == "M"
         cSql += " TEXT "
      ENDCASE
      cSql += " , "
   NEXT
   cSql += " PRIMARY KEY ( " + cKeyName + " )"
   cSql += " )"
   cSql += ";"
   SayScroll( "Salvando no MySql " + cTable )
   IF lCria
      cnGERAL:ExecuteCmd( cSql )
   ENDIF
   IF lZera
      cnGERAL:ExecuteCmd( "TRUNCATE TABLE " + cNewTable )
   ENDIF
   IF ! lTransfere
      SELECT ( nSelect )
      RETURN NIL
   ENDIF
   SELECT 0
   USE ( cTable ) ALIAS DbfDb
   GrafTempo( "Processando " + cTable )
   cSqlFix := "INSERT INTO " + cNewTable + " ( "
   FOR nCont = 1 TO FCount()
      cSqlFix += FieldName( nCont )
      IF nCont != FCount()
         cSqlFix += ", "
      ENDIF
   NEXT
   cSqlFix += " ) VALUES "
   cTxt := ""
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      Inkey()
      cSql := "( "
      FOR nCont = 1 TO FCount()
         xValue := FieldGet( nCont )
         DO CASE
         CASE ValType( xValue ) == "N"
            cSql += NumberSql( xValue )
         CASE ValType( xValue ) == "D"
            cSql += DateSql( xValue )
         CASE ValType( xValue ) == "C"
            xValue := LimpaErro( xValue )
            cSql += StringSql( xValue )
         OTHERWISE
            cSql += "NULL"
         ENDCASE
         IF nCont != FCount()
            cSql += ","
         ENDIF
      NEXT
      cSql += " )"
      IF Len( cTxt ) == 0
         cTxt += cSqlFix
         lBegin := .T.
      ENDIF
      IF ! lBegin
         cTxt += ", "
      ENDIF
      lBegin := .F.
      cTxt += cSql
      IF Len( cTxt ) > MYSQL_MAX_CMDINSERT
         cnGERAL:ExecuteCmd( cTxt )
         cTxt := ""
      ENDIF
      SKIP
   ENDDO
   IF Len( cTxt ) != 0
      cnGERAL:ExecuteCmd( cTxt )
   ENDIF
   USE
   SELECT ( nSelect )

   RETURN NIL

STATIC FUNCTION LimpaErro( xValue )

   xValue := StrTran( xValue, Chr(91),  " " )
   xValue := StrTran( xValue, Chr(93),  " " )
   xValue := StrTran( xValue, Chr(167), " " )
   xValue := StrTran( xValue, Chr(128), "C" )
   xValue := StrTran( xValue, Chr(135), "C" )
   xValue := StrTran( xValue, Chr(166), "A" )
   xValue := StrTran( xValue, Chr(198), "A" )
   xValue := StrTran( xValue, Chr(0),   "" )
   xValue := StrTran( xValue, Chr(95),  "-" )
   xValue := StrTran( xValue, Chr(229), "O" )
   xValue := StrTran( xValue, Chr(124), " " )
   xValue := StrTran( xValue, Chr(141), " " )
   xValue := StrTran( xValue, Chr(181), " " )
   xValue := StrTran( xValue, Chr(162), " " )
   xValue := StrTran( xValue, Chr(224), " " )
   xValue := StrTran( xValue, Chr(133), " " )
   xValue := StrTran( xValue, Chr(144), "E" )
   xValue := StrTran( xValue, Chr(160), " " )

   RETURN xValue

#define MYSQL_INSERT_COMPLETE  1
#define MYSQL_INSERT_NONAMES   2

FUNCTION cmdSQLInsert( nInsertType, cTableName )

   LOCAL cSql := "", nCont, xValue

   hb_Default( @nInsertType, MYSQL_INSERT_COMPLETE )
   hb_Default( @cTableName, Alias() )

   IF nInsertType == MYSQL_INSERT_COMPLETE
      cSql := cSql + "INSERT INTO `" + cTableName + "` "
   ENDIF
   IF nInsertType == MYSQL_INSERT_COMPLETE
      cSql += "( "
      FOR nCont = 1 TO FCount()
         cSql += "`" + FieldName( nCont ) + "`"
         IF nCont != FCount()
            cSql += ", "
         ENDIF
      NEXT
      cSql += " ) "
      cSql += "VALUES "
   ENDIF
   cSql += "( "
   FOR nCont = 1 TO FCount()
      xValue := FieldGet( nCont )
      DO CASE
      CASE ValType( xValue ) == "N"
         cSql += NumberSql( xValue )
      CASE ValType( xValue ) == "D"
         cSql += DateSql( xValue )
      CASE ValType( xValue ) == "C"
         xValue := LimpaErro( xValue )
         cSql += StringSql( xValue )
      OTHERWISE
         cSql += "NULL"
      ENDCASE
      IF nCont != FCount()
         cSql += ","
      ENDIF
   NEXT
   cSql += " ) "

   RETURN cSql

FUNCTION CopyRecordToMySql( cDatabase, cChaveAcesso )

   LOCAL nCont, xValue, lInsert := .T., oRs, cSql

   IF cChaveAcesso != NIL
      cSql := "SELECT COUNT(*) AS QTD FROM " + cDatabase + " WHERE " + cChaveAcesso
      oRs := AppcnMySqlLocal():Execute( cSql )
      IF oRs:Fields( "QTD" ):Value > 0
         lInsert := .F.
      ENDIF
      oRs:Close()
   ENDIF
   IF lInsert
      cSql := "INSERT INTO " + cDatabase + " ( "
      FOR nCont = 1 TO FCount()
         cSql += FieldName( nCont ) + iif( nCont == FCount(), "", ", " )
      NEXT
      cSql += ") VALUES ( "
   ELSE
      cSql := "UPDATE " + cDatabase + " SET "
   ENDIF
   FOR nCont = 1 TO FCount()
      xValue := FieldGet( nCont )
      IF ValType( xValue ) $ "NDC"
         IF ValType( xValue ) == "C"
            xValue := LimpaErro( xValue )
         ENDIF
         IF lInsert
            cSql += ValueSql( xValue )
         ELSE
            cSql += FieldName( nCont ) + "=" + ValueSql( xValue )
         ENDIF
      ELSE
         MsgExclamation( "Tipo desconhecido pra conversão " + ValType( xValue ) )
         QUIT
      ENDIF
      cSql += iif( nCont == FCount(), "", ", " )
   NEXT
   IF lInsert
      cSql += ")"
   ELSE
      cSql += "WHERE " + cChaveAcesso
   ENDIF
   AppcnMySqlLocal():Execute( cSql )

   RETURN NIL
