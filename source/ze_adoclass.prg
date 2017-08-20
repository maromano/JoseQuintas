/*
ZE_ADOCLASS - ROTINAS ADO
2011.09 José Quintas
*/

// anotacao
// Table Schemma é case sensitive
// User ID=root;Password=myPassword;Host=localhost;Port=3306;Database=myDataBase;
// Direct=true;Protocol=TCP;Compress=false;
// Pooling=true;Min Pool Size=0;Max Pool Size=100;Connection Lifetime=0;

#require "hbwin.hbc"
#include "hbclass.ch"

/* ADO Field Types */

#define AD_EMPTY                        0
#define AD_TINYINT                      16
#define AD_SMALLINT                     2
#define AD_INTEGER                      3
#define AD_BIGINT                       20
#define AD_UNSIGNEDTINYINT              17
#define AD_UNSIGNEDSMALLINT             18
#define AD_UNSIGNEDINT                  19
#define AD_UNSIGNEDBIGINT               21
#define AD_SINGLE                       4
#define AD_DOUBLE                       5
#define AD_CURRENCY                     6
#define AD_DECIMAL                      14
#define AD_NUMERIC                      131
#define AD_BOOLEAN                      11
#define AD_ERROR                        10
#define AD_USERDEFINED                  132
#define AD_VARIANT                      12
#define AD_IDISPATCH                    9
#define AD_IUNKNOWN                     13
#define AD_GUID                         72
#define AD_DATE                         7
#define AD_DBDATE                       133
#define AD_DBTIME                       134
#define AD_DBTIMESTAMP                  135
#define AD_BSTR                         8
#define AD_CHAR                         129
#define AD_VARCHAR                      200
#define AD_LONGVARCHAR                  201
#define AD_WCHAR                        130
#define AD_VARWCHAR                     202
#define AD_LONGVARWCHAR                 203
#define AD_BINARY                       128
#define AD_VARBINARY                    204
#define AD_LONGVARBINARY                205
#define AD_CHAPTER                      136
#define AD_FILETIME                     64
#define AD_PROPVARIANT                  138
#define AD_VARNUMERIC                   139
#define AD_ARRAY                        /* &H2000 */

/* ADO Cursor Type */
#define AD_OPEN_FORWARDONLY             0
#define AD_OPEN_KEYSET                  1
#define AD_OPEN_DYNAMIC                 2
#define AD_OPEN_STATIC                  3

/* ADO Lock Types */
#define AD_LOCK_READONLY                1
#define AD_LOCK_PESSIMISTIC             2
#define AD_LOCK_OPTIMISTIC              3
#define AD_LOCK_TACHOPTIMISTIC          4

/* ADO Cursor Location */
#define AD_USE_NONE                      1
#define AD_USE_SERVER                    2
#define AD_USE_CLIENT                    3
#define AD_USE_CLIENTBATCH               3

/* Constant Group: ObjectStateEnum */
#ifndef AD_STATE_CLOSED
   #define AD_STATE_CLOSED                 0
#endif
#define AD_STATE_OPEN                   1
#define AD_STATE_CONNECTING             2
#define AD_STATE_EXECUTING              4
#define AD_STATE_FETCHING               8

FUNCTION ExcelConnection( cFileName )

   LOCAL oConexao

   oConexao := win_OleCreateObject( "ADODB.Connection" )
   oConexao:ConnectionString := ;
      [Provider=Microsoft.Jet.OLEDB.4.0;Data Source=] + cFileName + ;
      [;Extended Properties="Excel 8.0;"] // HDR=Yes;IMEX=1";] // alterado em 16/10 pra teste
   RETURN oConexao

CREATE CLASS ADOClass

   VAR    Cn
   VAR    Rs
   VAR    cSql
   VAR    aQueryList

   METHOD New( oConnection )           INLINE ::CN := oConnection, SELF
   METHOD Open( lError )
   METHOD Close()                    // desativar
   METHOD CloseConnection()
   METHOD CloseRecordset()
   METHOD Execute( cSql, lError )    // Atualiza Rs com retorno
   METHOD ExecuteCmd( cSql, lError ) // Despreza retorno
   METHOD StringSql( xField, nLen )
   METHOD NumberSql( xField )
   METHOD DateSql( xField )
   METHOD Value( xField )
   METHOD Replace( cFrom, cTo )
   METHOD Eof()                        INLINE iif( ::Rs == NIL .OR. ::RecordCount() == 0, .T., ::Rs:Eof() )
   METHOD MoveFirst()                  INLINE ::Rs:MoveFirst()
   METHOD MoveNext()                   INLINE ::Rs:MoveNext()
   METHOD SqlToDbf( oStructure )
   METHOD ReturnValueAndClose( cField, cSql )
   METHOD TableList()
   METHOD TableExists( cTable )
   METHOD FieldList( cTable )
   METHOD FieldExists( cField, cTable )
   METHOD AddField( cField, cTable, cSql )
   METHOD DeleteField( cField, cTable, cDbf )
   METHOD IndexList( cTable )
   METHOD RecordCount()                INLINE ::Rs:RecordCount()
   METHOD FieldsCount()                INLINE ::Rs:Fields:Count()
   METHOD QueryCreate()                INLINE ::aQueryList := {}, NIL
   METHOD QueryAdd( cField, xValue )   INLINE AAdd( ::aQueryList, { cField, xValue } ), NIL
   METHOD QueryIsEmpty()               INLINE Len( ::aQueryList ) == 0
   METHOD QueryExecuteInsert( cTable )
   METHOD QueryExecuteUpdate( cTable, cWhere )
   METHOD TableRecCount( cTable, cFilter )

   ENDCLASS

METHOD Close() CLASS ADOClass // desativar

   ::CloseRecordset()
   ::CloseConnection()

   RETURN NIL

METHOD CloseConnection() CLASS ADOClass

   ::CloseRecordset()
   BEGIN SEQUENCE WITH __BreakBlock()
      ::Cn:Close()
   ENDSEQUENCE

   RETURN NIL

METHOD CloseRecordset() CLASS ADOClass

   BEGIN SEQUENCE WITH __BreakBlock()
      ::Rs:Close()
   ENDSEQUENCE
   ::Rs := NIL

   RETURN NIL

METHOD Open( lError ) CLASS ADOClass

   LOCAL lOk := .F., nCont, cMessage

   hb_Default( @lError, .T. )
   WSave( MaxRow() - 1, 0, MaxRow(), MaxCol() )
   FOR nCont = 1 TO 5
      BEGIN SEQUENCE WITH __BreakBlock()
         IF ::cn:State() != AD_STATE_OPEN
            ::Cn:Open()
         ENDIF
         DO WHILE ::cn:State() != AD_STATE_OPEN
            Inkey(1)
         ENDDO
         lOk := .T.
      ENDSEQUENCE
      IF lOk
         EXIT
      ENDIF
      Mensagem( "Falhou pra conectar com servidor, tentativa " + LTrim( Str( nCont ) ) + "/5" )
      BEGIN SEQUENCE WITH __BreakBlock()
         cMessage := LTrim( Str( ::Cn:Errors(0):Number() ) ) + " " + ::Cn:Errors(0):Description()
         Mensagem( cMessage )
         Errorsys_WriteErrorLog( cMessage, 2 )
      ENDSEQUENCE
      Inkey(10)
   NEXT
   IF lError .AND. ! lOk
      Eval( ErrorBlock() )
      QUIT
   ENDIF
   WRestore()

   RETURN lOk

METHOD Execute( cSql, lError ) CLASS ADOClass

   ::Rs := NIL
   ::Rs := ::ExecuteCmd( cSql, lError )

   RETURN NIL

METHOD ExecuteCmd( cSql, lError ) CLASS ADOClass

   LOCAL lOk := .F., cMensagem := "", Rs

   IF ::Cn == NIL
      RETURN NIL
   ENDIF
   hb_Default( @lError, .T. )
   cSql := iif( cSql == NIL, ::cSql, cSql ) // não pode usar hb_Default
   IF ::Cn:State() != AD_STATE_OPEN
      ::Open()
   ENDIF
   cSql := Trim( cSql )
   IF Right( AllTrim( cSql ), 1 ) != ";"
      cSql += ";"
   ENDIF
   IF Len( Trim( cSql ) ) != 0
      BEGIN SEQUENCE WITH __BreakBlock()
         Rs := ::Cn:Execute( cSql )
         lOk := .T.
      ENDSEQUENCE
      IF ! lOk
         cMensagem += iif( "SELECT" $ cSql, "Tentativa 1: ", "" ) + " Erro executando comando:" + LTrim( Str( ::Cn:Errors( 0 ):Number( ) ) ) + " " + ::Cn:Errors( 0 ):Description()
         Errorsys_WriteErrorLog( cMensagem )
         Errorsys_WriteErrorLog( cSql, 2 )
         IF "SELECT " $ upper( cSql )
            BEGIN SEQUENCE WITH __BreakBlock()
               Rs := ::cn:Execute( cSql )
               lOk := .T.
            ENDSEQUENCE
            IF ! lOk
               Errorsys_WriteErrorLog( "Tentativa 2: Erro executando comando:" + LTrim( Str( ::Cn:Errors( 0 ):Number( ) ) ) + " " + ::Cn:Errors( 0 ):Description() )
               Errorsys_WriteErrorLog( cSql, 2 )
            ENDIF
         ENDIF
      ENDIF
      IF ! lOk
         IF lError
            Eval( ErrorBlock() )
            QUIT
         ENDIF
      ENDIF
   ENDIF

   RETURN Rs

METHOD Replace( cFrom, cTo ) CLASS ADOClass

   ::cSql := StrTran( ::cSql, cFrom, cTo )

   RETURN NIL

METHOD StringSql( xField, nLen ) CLASS ADOClass

   LOCAL xValue

   IF ::rs:RecordCount() == 0
      xValue := ""
   ELSE
      xValue := ::Rs:Fields( xField ):Value
   ENDIF
   DO CASE
   CASE ValType( xValue ) == "N"
      xValue := Ltrim( Str( xValue ) )
   CASE ValType( xValue ) == "D"
      xValue := Dtoc( xValue )
   CASE ValType( xValue ) == "C"
      xValue := Trim( xValue )
   OTHERWISE
      xValue := ""
   ENDCASE
   IF nLen != NIL
      xValue := Pad( xValue, nLen )
   ENDIF

   RETURN xValue

METHOD NumberSql( xField ) CLASS ADOClass

   LOCAL xValue

   IF ::rs:RecordCount() == 0
      xValue := 0
   ELSE
      xValue := ::Rs:Fields( xField ):Value
   ENDIF
   DO CASE
   CASE ValType( xValue ) == "N"
   CASE ValType( xValue ) == "C"
      xValue := Val( xValue )
   OTHERWISE
      xValue := 0
   ENDCASE
   xValue := xValue + 0.000000

   RETURN xValue

METHOD DateSql( xField ) CLASS ADOClass

   LOCAL xValue

   IF ::rs:RecordCount() == 0
      xValue := Ctod( "" )
   ELSE
      xValue := ::Rs:Fields( xField ):Value
   ENDIF
   DO CASE
   CASE ValType( xValue ) == "D"
   OTHERWISE
      xValue := Ctod("")
   ENDCASE

   RETURN xValue

METHOD ReturnValueAndClose( cField, cSql ) CLASS ADOClass

   LOCAL xValue

   IF cSql != NIL
      ::cSql := cSql
   ENDIF
   ::Execute()
   xValue := ::Value( cField )
   ::CloseRecordset()

   RETURN xValue

METHOD Value( xField ) CLASS ADOClass

   LOCAL nType, xValue, cType

   nType := ::Rs:Fields( xField ):Type
   DO CASE
   CASE nType == AD_BOOLEAN
      cType := "N"
   CASE AScan( { AD_DATE, AD_DBDATE, AD_DBTIME, AD_DBTIMESTAMP }, nType ) != 0
      cType := "D"
   CASE AScan( { AD_BIGINT, AD_SMALLINT, AD_TINYINT, AD_INTEGER, AD_UNSIGNEDTINYINT, AD_UNSIGNEDSMALLINT, AD_UNSIGNEDINT, AD_UNSIGNEDBIGINT }, nType ) != 0
      cType := "N"
   CASE AScan( { AD_DOUBLE, AD_SINGLE }, nType ) != 0
      cType := "N"
   CASE nType == AD_CURRENCY
      cType := "N"
   CASE AScan( { AD_DECIMAL, AD_NUMERIC, AD_VARNUMERIC }, nType ) != 0
      cType := "N"
   CASE AScan( { AD_BSTR, AD_CHAR, AD_VARCHAR, AD_LONGVARCHAR, AD_WCHAR, AD_VARWCHAR, AD_LONGVARWCHAR }, nType ) > 0
      cType := "C"
   CASE AScan( { AD_BINARY, AD_VARBINARY, AD_LONGVARBINARY }, nType ) != 0
      cType := "C"
   OTHERWISE
      cType := "C"
   ENDCASE
   DO CASE
   CASE cType == "N"
      xValue := ::NumberSql( xField )
   CASE cType == "D"
      xValue := ::DateSql( xField )
   CASE cType == "C"
      xValue := ::StringSql( xField )
   OTHERWISE
      xValue := ::StringSql( xField )
   ENDCASE

   RETURN xValue

// Somente string vém tamanho correto em DefinedSize, Int vém como 10, e depende da versão do ODBC

METHOD SqlToDbf( oStructure ) CLASS ADOClass

   LOCAL nSelect, cDbfFile, nCont, cType, nLen, nDec, cName, nType, oElement

   ::Execute()

   IF oStructure == NIL
      oStructure := {}
      FOR nCont = 0 TO ::Rs:Fields:Count() - 1
         cName := Upper( Trim( ::Rs:Fields( nCont ):Name ) )
         nType := ::Rs:Fields( nCont ):Type
         DO CASE
         CASE nType == AD_BOOLEAN
            cType := "L"
            nLen  := 1
            nDec  := 0
         CASE AScan( { AD_DATE, AD_DBDATE, AD_DBTIME, AD_DBTIMESTAMP }, nType ) != 0
            cType := "D"
            nLen  := 8
            nDec  := 0
         CASE AScan( { AD_BIGINT, AD_SMALLINT, AD_TINYINT, AD_INTEGER, AD_UNSIGNEDTINYINT, AD_UNSIGNEDSMALLINT, AD_UNSIGNEDINT, AD_UNSIGNEDBIGINT }, nType ) != 0
            cType := "N"
            nLen  := ::rs:Fields( nCont ):Precision
            nDec  := 0
         CASE AScan( { AD_DOUBLE, AD_SINGLE }, nType ) != 0
            cType := "N"
            nLen  := ::Rs:Fields( nCont ):Precision
            nDec  := ::Rs:Fields( nCont ):NumericScale
         CASE nType == AD_CURRENCY
            cType := "N"
            nLen  := ::Rs:Fields( nCont ):Precision
            nDec  := ::Rs:Fields( nCont ):NumericScale
         CASE AScan( { AD_DECIMAL, AD_NUMERIC, AD_VARNUMERIC }, nType ) != 0
            cType := "N"
            nLen  := ::Rs:Fields( nCont ):Precision
            nDec  := ::Rs:Fields( nCont ):NumericScale
         CASE AScan( { AD_BSTR, AD_CHAR, AD_VARCHAR, AD_LONGVARCHAR, AD_WCHAR, AD_VARWCHAR, AD_LONGVARWCHAR }, nType ) > 0
            cType := "C"
            nLen := ::Rs:Fields( nCont ):DefinedSize
            IF nLen > 255
               cType := "M"
               nLen := 10
            ENDIF
            nDec := 0
         CASE AScan( { AD_BINARY, AD_VARBINARY, AD_LONGVARBINARY }, nType ) != 0
            cType := "M"
            nLen  := 10
            nDec  := 0
         OTHERWISE
            MsgExclamation( "Novo tipo ADO " + Ltrim( Str( ::Rs:Fields( nCont ):Type ) ) )
            cType := "M"
            nLen  := 10
            nDec  := 0
         ENDCASE
         IF cType == "N"
            nLen := iif( nLen < 0, 13, nLen )
            nLen := iif( nLen > 15, 15, nLen )
            nDec := iif( nDec < 0, 6, nDec )
            nDec := iif( nDec > 6, 6, nDec )
            IF nDec != 0
               nLen := nLen + nDec + 1
            ENDIF
         ENDIF
         AAdd( oStructure, { cName, cType, nLen, nDec } )
      NEXT
   ELSE
      FOR EACH oElement IN oStructure
         IF Len( oElement ) < 4
            AAdd( oElement, 0 )
         ENDIF
      NEXT
   ENDIF
   nSelect  := Select()
   cDbfFile := MyTempFile( "DBF" )
   SELECT 0
   dbCreate( cDbfFile, oStructure )
   USE ( cDbfFile ) ALIAS SqlToDbf
   DO WHILE ! ::Rs:Eof()
      RecAppend()
      FOR nCont = 1 TO Len( oStructure )
         DO CASE
         CASE oStructure[ nCont, 2 ] == "N" ; FieldPut( nCont, ::NumberSql( oStructure[ nCont, 1 ] ) )
         CASE oStructure[ nCont, 2 ] == "D" ; FieldPut( nCont, ::DateSql( oStructure[ nCont, 1 ] ) )
         OTHERWISE                          ; FieldPut( nCont, ::StringSql( oStructure[ nCont, 1 ] ) )
         ENDCASE
      NEXT
      ::Rs:MoveNext()
   ENDDO
   USE
   SELECT ( nSelect )
   ::CloseRecordset()

   RETURN cDbfFile

METHOD TableList() CLASS ADOClass

   LOCAL acTableList := {}

   ::cSql := "SELECT table_name AS TABELA FROM information_schema.TABLES WHERE table_schema=" + StringSql( Lower( AppEmpresaApelido() ) )
   ::Execute()
   DO WHILE ! ::Eof()
      AAdd( acTableList, ::Value( "TABELA" ) )
      ::MoveNext()
   ENDDO
   ::CloseRecordset()

   RETURN acTableList

METHOD TableExists( cTable ) CLASS ADOClass

   LOCAL nQtd

   ::cSql := "SELECT COUNT(*) AS QTD FROM information_schema.TABLES WHERE table_schema=" + StringSql( Lower( AppEmpresaApelido() ) ) + ;
                   " AND table_name=" + StringSql( cTable )
   ::Execute()
   nQtd := ::Value( "QTD" )
   ::CloseRecordset()

   RETURN nQtd > 0

METHOD FieldList( cTable ) CLASS ADOClass

   LOCAL acFieldList := {}

   ::cSql := "SELECT COLUMN_NAME AS CAMPO FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=" + StringSql( Lower( AppEmpresaApelido() ) ) + " AND TABLE_NAME=" + StringSql( cTable )
   ::Execute()

   DO WHILE ! ::Eof()
      AAdd( acFieldList, ::Value( "CAMPO" ) )
      ::MoveNext()
   ENDDO
   ::CloseRecordset()

   RETURN acFieldList

METHOD FieldExists( cField, cTable ) CLASS ADOClass

   LOCAL nQtd

   ::cSql := "SELECT COUNT(*) AS QTD FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=" + StringSql( Lower( AppEmpresaApelido() ) ) + " AND TABLE_NAME=" + StringSql( cTable ) + ;
                   " AND COLUMN_NAME=" + StringSql( cField )
   ::Execute()
   nQtd := ::Value( "QTD" )
   ::CloseRecordset()

   RETURN nQtd > 0

METHOD IndexList( cTable ) CLASS ADOClass

   LOCAL acIndexList := {}

   ::cSql := "SELECT CONSTRAINT_NAME AS INDICE FROM information_schema.TABLE_CONSTRAINTS WHERE " + ;
      "TABLE_SCHEMA=" + StringSql( Lower( AppEmpresaApelido() ) ) + " AND TABLE_NAME=" + StringSql( cTable )
   ::Execute()
   DO WHILE ! ::Eof()
      AAdd( acIndexList, ::Value( "INDICE" ) )
      ::MoveNext()
   ENDDO
   ::CloseRecordset()

   RETURN acIndexList

METHOD AddField( cField, cTable, cSql ) CLASS ADOClass

     IF ::FieldExists( cField, cTable )
        // Errorsys_WriteErrorLog( "Já pode tirar adição do campo do MySql " + cTable + "." + cField )
     ELSE
        SayScroll( "Adicionando campo " + cTable + "." + cField )
        ::cSql := "ALTER TABLE " + cTable + " ADD " + cField + " " + cSql
        ::ExecuteCmd()
     ENDIF

     RETURN NIL

METHOD DeleteField( cField, cTable, cDbf ) CLASS ADOClass

   IF cDbf != NIL
      IF ! AbreArquivos( cDbf )
         RETURN NIL
      ENDIF
      IF FieldNum( cField ) != 0
         Errorsys_WriteErrorLog( "Existe o campo " + cField + " em " + cDbf + ".dbf por isso não eliminado do MySQL" )
         CLOSE DATABASES
         RETURN NIL
      ENDIF
      CLOSE DATABASES
   ENDIF
   IF ::FieldExists( cField, cTable )
      SayScroll( "Removendo campo " + cField + " da tabela " + cTable )
      ::ExecuteCmd( "ALTER TABLE " + cTable + " DROP COLUMN " + cField )
   ELSE
      Errorsys_WriteErrorLog( "Já pode tirar remoção do campo do MySql " + cTable + "." + cField )
   ENDIF

   RETURN NIL

METHOD QueryExecuteInsert( cTable ) CLASS ADOClass

   LOCAL oField, cSql := "INSERT INTO " + cTable + " ( "

   FOR EACH oField IN ::aQueryList
      cSql += oField[ 1 ]
      IF ! oField:__EnumIsLast
         cSql += ", "
      ENDIF
   NEXT
   cSql += " ) VALUES ( "
   FOR EACH oField in ::aQueryList
      cSql += ValueSql( oField[ 2 ] )
      IF ! oField:__EnumIsLast
         cSql += ", "
      ENDIF
   NEXT
   cSql += " )"
   ::ExecuteCmd( cSql )

   RETURN NIL

METHOD QueryExecuteUpdate( cTable, cWhere ) CLASS ADOClass

   LOCAL oField, cSql := "UPDATE " + cTable + " SET "

   FOR EACH oField IN ::aQueryList
      cSql += oField[ 1 ] + "=" + ValueSql( oField[ 2 ] )
      IF ! oField:__EnumIsLast
         cSql += ", "
      ENDIF
   NEXT
   cSql += " WHERE " + cWhere
   ::ExecuteCmd( cSql )

   RETURN NIL

METHOD TableRecCount( cTable, cFilter ) CLASS ADOClass

   ::cSql := "SELECT COUNT(*) AS QTD FROM " + cTable
   IF cFilter != NIL
      ::cSql += " WHERE " + cFilter
   ENDIF

   RETURN ::ReturnValueAndClose( "QTD" )

//FUNCTION ExcelConnection( cPlanilha )

//   LOCAL cnExcel

//   cnExcel := win_OleCreateObject( "ADODB.Connection" )
//   cnExcel:ConnectionString := ;
//      [Provider=Microsoft.Jet.OLEDB.4.0;Data Source=] + cPlanilha + ;
//      [;Extended Properties="Excel 8.0;"] // HDR=Yes;IMEX=1";] // alterado em 16/10 pra teste
//   RETURN cnExcel

FUNCTION MySqlConnection( cServer, cDatabase, cUser, cPassword, nPort, nVersion )

   LOCAL cnConnection

   hb_Default( @nPort, 3306 )
   hb_Default( @nVersion, AppODBCMySql() )

   cnConnection:= win_OleCreateObject( "ADODB.Connection" )
   cnConnection:ConnectionString := "Driver={MySQL ODBC " + iif( nVersion == 3, "3.51", "5.3 ANSI" ) + " Driver};Server=" + cServer + ";" + "Port=" + Ltrim( Str( nPort ) ) + ;
      ";Stmt=;Database=" + cDatabase + ";User=" + cUser + ";Password=" + cPassword + ";Collation=latin1;" + ;
      "AUTO_RECONNECT=1;COMPRESSED_PROTO=0;PAD_SPACE=1" // usando compactação impede certas checagens // Option=131072;
   cnConnection:CursorLocation    := AD_USE_CLIENT
   cnConnection:CommandTimeOut    := 600 // seconds
   cnConnection:ConnectionTimeOut := 600 // seconds
   // cnConnection:ConnectionString := "Driver={MySQL ODBC 5.3 ANSI Driver};Server=" + cServer + ";" + "Port=" + Ltrim( Str( nPort ) ) + ;

   RETURN cnConnection

// innodb_buffer_pool_size=2G
// skip_name_resolve
// innodb_file_per_table=1
// GRANT ALL ON *.* TO 'usuario'@'%' IDENTIFIED BY 'senha'
// DROP USER 'usuario'
// SHOW GRANTS [ FOR CURRENT_USER ]
//
// defaults:
// SET GLOBAL max_allowed_packed=4M
// SET GLOBAL connect_timeout=28800
// SET GLOBAL wait_timeout=28800
// SET GLOBAL interactive_timeout=28800


   //acMySql := { "{MySQL ODBC 3.51 Driver}" }
   // , "{MySQL ODBC 5.1 Driver}", "{MySQL ODBC 5.3w}" } // o segundo ficou esquisito pra rede local
   // 32 em 64 bits: pode ser necessário adicionar MSDASQL;Driver={...}

// =SO bits: "HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers\" + versao + "\Driver"
// 32 em 64: "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432\Node\MySQL AB\" + versao + "\Version"

   //cMySqlDriver := acMySql[ 1 ]
   //FOR nCont = 1 TO Len( acMySql )
   //   cRegistroText := Win_RegRead( "HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers\" + acMySql[ nCont ] )
   //   IF cRegistroText != NIL
   //      IF cRegistroText == "Installed"
   //         cMySqlDriver := acMySql[ nCont ]
   //      ENDIF
   //   ENDIF
   //NEXT

/*
FUNCTION DatabaseList()

information_schema - banco com definicoes
USER_PRIVILEGES   - usuarios e acessos
TABLE_CONSTRAINTS - indices
TABLES            - tabelas
SCHEMATA          - databases
PROCESSLIST       - processos
COLUMNS           - campos

*/

//IF ! File("adslocal.cfg")
   //   mTexto := "[SETTINGS]" + hb_Eol() + ;
   //      "LICENSES=20" + hb_Eol() + ;
   //      "CONNECTIONS=20" + hb_Eol() + ;
   //      "TABLES=100" + hb_Eol() + ;
   //      "INDEXES=100" + hb_Eol() + ;
   //      "LOCKS=500" + hb_Eol() + ;
   //      "ERROR_LOG_MAX=1000" + hb_Eol() + ;
   //      "ERROR_ASSERT_LOGS=" + hb_Eol() + ;
   //      "ANSI_CHAR_SET=Portuguese" + hb_Eol() + ; // Engl(UK)
   //      "OEM_CHAR_SET=PORTUGUE" + hb_Eol() + ; // USA
   //      "FLUSH_FREQUENCY=1000" + hb_Eol() + ;
   //      "LOWERCASE_ALL_PATHS=" + hb_Eol() + ;
   //      hb_Eol()
   //   HB_MemoWrit("adslocal.cfg",mTexto)
   //ENDIF

/*
[SETTINGS]
;              Advantage Local Server configuration file
;
; The Advantage Local Server DLL (for Windows) and SO (for Linux) reads
; this configuration file when the DLL/SO is loaded. Values input
; after the keyword and equal sign are used to configure the DLL/SO.
; If no value is inserted after a keyword and equal sign, the default
; is used. This file should be located in the same directory as your
; Advantage Local Server DLL (adsloc32.dll) or SO (libadsloc.so).
;
; Number of Connections
; Default = 20; Range = 1 - No upper limit
CONNECTIONS=20
;
; Number of Tables
; Default = 50; Range = 1 - No upper limit
TABLES=100
;
; Number of Index Files
; Default = 75; Range = 1 - No upper limit
INDEXES=100
;
; Number of Data Locks
; Default = 500; Range = 1 - No upper limit
LOCKS=500
;
; Maximum Size of Error Log (in KBytes)
; Default = 1000 KBytes; Range = 1 KByte - No upper limit
ERROR_LOG_MAX=1000
;
; Error Log and Assert Log Path
; Default = C:\
ERROR_ASSERT_LOGS=
;
; ANSI Character Set
; Default = Use the currently configured ANSI character set that is active
;           on the workstation.
; If you do not wish to use the ANSI character set that is active on the
;   current workstation, the available ANSI character sets to be used are:
;     Danish, Dutch, Engl(Amer), Engl(UK), Engl(Can), Finnish, French,
;     French Can, German, Icelandic, Italian, Norwegian, Portuguese, Spanish,
;     Span(Mod), Swedish, Russian, ASCII, Turkish, Polish, or Baltic
ANSI_CHAR_SET=
;
; OEM/Localized Character Set
; Default = USA
; Options are:
;   USA, DANISH, DUTCH, FINNISH, FRENCH, GERMAN, GREEK437, GREEK851, ICELD850,
;   ICELD861, ITALIAN, NORWEGN, PORTUGUE, SPANISH, SWEDISH, MAZOVIA, PC_LATIN,
;   ISOLATIN, RUSSIAN, NTXCZ852, NTXCZ895, NTXSL852, NTXSL895, NTXHU852,
;   NTXPL852, or TURKISH
OEM_CHAR_SET=USA
;
; Local File Flush Frequency (in milliseconds)
; Default = 20000 ms (20 seconds); Range = 0 ms - 100000 ms
FLUSH_FREQUENCY=20000
;
; Lowercase All Paths
; Default = 0 (false)
; Options are: 0 (for false) and 1 (for true)
; Option to force the Linux Advantage Local Server SO to lowercase all
;    paths and filenames before attempting to access them on disk. This
;    option is ignored by the Advantage Local Server DLL for Windows.
LOWERCASE_ALL_PATHS=

;
; Number of Work Areas
; Default = 100
; 32-bit range = 1 - 250 x maximum number of connections
; 16-bit range = 1 - 125
WORKAREAS=5000

*/
