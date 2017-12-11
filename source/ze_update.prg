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
   fErase( "jpservi.dbf" ) // porque pode conter DBT/FPT
   fErase( "jptaref.dbf" ) // porque pode conter DBT/FPT
   fErase( "jpnfexx.dbf" ) // porque pode conter DBT/FPT
   fErase( "jpnfexx.fpt" ) // porque pode conter DBT/FPT
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
      USE jpconfi
      LOCATE FOR Trim( jpconfi->Cnf_Nome ) == "VERSAO"
      IF AppVersaoDbfAnt() == 0 .AND. ! Eof()
         AppVersaoDbfAnt( Val( Trim( jpconfi->Cnf_Param ) ) )
         IF AppcnMySqlLocal() != NIL
            cnMySql:ExecuteCmd( "UPDATE JPCONFI SET CNF_PARAM=" + StringSql( Alltrim( NumberSql( AppVersaoDbfAnt() ) ) ) + " WHERE CNF_NOME='VERSAO'" )
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
   ze_update0000()
   // Atualizar sempre a versao no inicio do fonte
   IF AppVersaoDbfAnt() != AppVersaoDbf()
      IF AppcnMySqlLocal() == NIL
         GravaCnf( "VERSAO", AllTrim( NumberSql( AppVersaoDbf() ) ) )
      ELSE
         cnMySql:ExecuteCmd( "UPDATE JPCONFI SET CNF_PARAM=" + StringSql( AllTrim( NumberSql( AppVersaoDbf() ) ) ) + " WHERE CNF_NOME='VERSAO'" )
      ENDIF
      GravaOcorrencia( ,, "Conversão versão " + LTrim( Str( AppVersaoDbf() ) ) + " Arquivos " + AllTrim( NumberSql( AppVersaoDbfAnt() ) ) + " para " + AllTrim( NumberSql( AppVersaoDbf() ) ) )
      GravaOcorrencia( ,, "Tempo de Conversão de " + cTimeStart + " até " + Time() )
      CLOSE DATABASES
      AppVersaoDbfAnt( AppVersaoDbf() )
      ze_update0000() // De novo, pra completar atualização, ref campos removidos
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
