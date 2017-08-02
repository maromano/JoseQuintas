/*
ZE_UPDATE - ATUALIZACAO ENTRE VERSOES
1997.03.16 José Quintas
*/

#include "josequintas.ch"

FUNCTION ze_Update()

   LOCAL mMudaVersao := .F., mMudouExe, mVersaoExe, cTimeStart, acDbfList, nCont
   LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() )

   IF AppDatabase() != DATABASE_DBF
      RETURN NIL
   ENDIF
   fErase( "jpservi.dbf" )
   fErase( "jptaref.dbf" )
   fErase( "jpnfexx.dbf" )
   fErase( "jpnfexx.fpt" )
   IF AppcnMySqlLocal() == NIL .OR. File( "JPREGUSO.DBF" )
      JPREGUSOCreateDbf( .F. ) // Minimo obrigatorio
   ENDIF
   IF AppcnMySqlLocal() == NIL .OR. File( "JPCONFI.DBF" )
      JPCONFICreateDbf( .F. ) // Minimo obrigatorio
   ENDIF
   IF AppcnMySqlLocal() != NIL
      cnMySql:ExecuteCmd( JPREGUSOCreateMySql() )
      cnMySql:ExecuteCmd( JPCONFICreateMySql() )
   ENDIF
   CriaZip()
   IF AppcnMySqlLocal() != NIL
      cnMySql:cSql :=  "SELECT COUNT(*) AS QTD FROM JPCONFI WHERE CNF_NOME='VERSAO'"
      IF cnMySql:ReturnValueAndClose( "QTD" ) == 0
         cnMySql:ExecuteCmd( "INSERT INTO JPCONFI ( CNF_NOME, CNF_PARAM ) VALUES ( 'VERSAO', '0' )" )
      ELSE
         cnMySql:cSql := "SELECT CNF_NOME, CNF_PARAM FROM JPCONFI WHERE CNF_NOME='VERSAO'"
         AppVersaoDbfAnt( Val( cnMySql:ReturnValueAndClose( "CNF_PARAM" ) ) )
      ENDIF
      cnMySql:cSql := "SELECT COUNT(*) AS QTD FROM JPCONFI WHERE CNF_NOME='VERSAOEXE'"
      IF cnMySql:ReturnValueAndClose( "QTD" ) == 0
         cnMySql:ExecuteCmd( "INSERT INTO JPCONFI ( CNF_NOME, CNF_PARAM ) VALUES ( 'VERSAOEXE', '0' )" )
         mVersaoExe := ""
      ELSE
         cnMySql:cSql := "SELECT CNF_NOME, CNF_PARAM FROM JPCONFI WHERE CNF_NOME='VERSAOEXE'"
         mVersaoExe := cnMySql:ReturnValueAndClose( "CNF_PARAM" )
      ENDIF
   ENDIF
   IF File( "jpconfi.dbf" )
      USE JPCONFI
      LOCATE FOR Trim( jpconfi->Cnf_Nome ) == "VERSAO"
      IF AppVersaoDbfAnt() == 0 .AND. ! Eof()
         AppVersaoDbfAnt( Val( Trim( jpconfi->Cnf_Param ) ) )
         IF AppcnMySqlLocal() != NIL
            cnMySql:ExecuteCmd( "UPDATE JPCONFI SET CNF_PARAM=" + StringSql( Ltrim( Str( AppVersaoDbfAnt(), 10 ) ) ) + " WHERE CNF_NOME='VERSAO'" )
            GOTO TOP
            DO WHILE ! Eof()
               IF Trim( jpconfi->cnf_Nome ) == "VERSAO"
                  RecLock()
                  DELETE
                  RecUnlock()
               ENDIF
               SKIP
            ENDDO
         ENDIF
      ENDIF
      LOCATE FOR Trim( jpconfi->Cnf_Nome ) == "VERSAOEXE"
      IF Empty( mVersaoExe ) .AND. ! Eof()
         mVersaoExe := Trim( jpconfi->Cnf_Param )
         IF AppcnMySqlLocal() != NIL
            cnMySql:ExecuteCmd( "UPDATE JPCONFI SET CNF_PARAM=" + StringSql( mVersaoExe ) + " WHERE CNF_NOME='VERSAOEXE'" )
            GOTO TOP
            DO WHILE ! Eof()
               IF Trim( jpconfi->cnf_Nome ) == "VERSAOEXE"
                  RecLock()
                  DELETE
                  RecUnlock()
               ENDIF
               SKIP
            ENDDO
         ENDIF
      ENDIF
      CLOSE DATABASES
   ENDIF
   mMudouExe := ( ! ( AppVersaoDbfAnt() == AppVersaoDbf() .AND. mVersaoExe == AppVersaoExe() ) )

   IF AppVersaoDbfAnt() == 0
      IF ! MsgYesNo( "Não há número de versão dos arquivos" + hb_Eol() + ;
         "Será tratado como versão antiga e todas as conversões serão efetuadas" + hb_Eol() + ;
         "Prossiga se tiver certeza de que é isso mesmo que quer" + hb_Eol() + ;
         "Continua?" )
         QUIT
      ENDIF
      mMudaVersao := .T.
   ENDIF
   IF AppVersaoDbfAnt() > AppVersaoDbf()
      IF ! MsgYesNo( "Está sendo utilizado um programa ANTIGO sobre NOVOS arquivos" + hb_Eol() + ;
         "Isto poderá causar perda de dados!!!!!!" + hb_Eol() + ;
         "Versão detectada " + Str( AppVersaoDbfAnt() ) + hb_Eol() + ;
         "Versão do programa " + LTrim( Str( AppVersaoDbf() ) ) + hb_Eol() + ;
         "Continua?" )
         QUIT
      ENDIF
   ENDIF
   IF AppVersaoDbfAnt() != AppVersaoDbf()
      mMudaVersao := .T.
   ENDIF
   IF mMudaVersao
      SayScroll( "Esta versão ajustará o conteúdo dos arquivos" )
      SayScroll( "e poderá alterar a estrutura de alguns" )
      SayScroll( "Backup automático em 5 segundo(s)" )
      Inkey(5)
      CriaZip(.T.)
   ENDIF
   cTimeStart := Time()

   SayScroll( "Verificando Atualizações" )

   CLOSE DATABASES // pra garantir

   SayScroll( "Verificando atualizações" )
   ze_update00()
   // Atualizar sempre a versao no inicio do fonte
   IF AppVersaoDbfAnt() != AppVersaoDbf()
      IF AppcnMySqlLocal() == NIL
         GravaCnf( "VERSAO", LTrim( Str( AppVersaoDbf() ) ) )
      ELSE
         cnMySql:ExecuteCmd( "UPDATE JPCONFI SET CNF_PARAM=" + StringSql( LTrim( Str( AppVersaoDbf() ) ) ) + " WHERE CNF_NOME='VERSAO'" )
      ENDIF
      GravaOcorrencia( ,, "Conversão versão " + LTrim( Str( AppVersaoDbf() ) ) + " Arquivos " + LTrim( Str( AppVersaoDbfAnt() ) ) + " para " + LTrim( Str( AppVersaoDbf() ) ) )
      GravaOcorrencia( ,, "Tempo de Conversão de " + cTimeStart + " até " + Time() )
      CLOSE DATABASES
   ENDIF
   IF mMudouExe
      SayScroll( "Verificando arquivos e índices" )
      IF AppcnMySqlLocal() == NIL
         GravaCnf( "VERSAOEXE", AppVersaoExe() )
      ELSE
         cnMySql:ExecuteCmd( "UPDATE JPCONFI SET CNF_PARAM=" + StringSql( AppVersaoExe() ) + " WHERE CNF_NOME='VERSAOEXE'" )
      ENDIF
      GravaOcorrencia( ,, "Nova versao EXE " + AppVersaoExe() )
      acDbfList := DbfInd()
      FOR nCont = 1 TO Len( acDbfList )
         IF ! AbreArquivos( acDbfList[ nCont, 1 ] )
            QUIT
         ENDIF
         USE
      NEXT
   ENDIF
   CLOSE DATABASES

   RETURN NIL

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
