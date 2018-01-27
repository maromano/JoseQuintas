/*
PTESCEST - TROCAR CEST AUTOMATICO
2016.03.21.1200 - Criação

2016.04.01 - CEST obrigatório
*/

PROCEDURE PTESCEST

   //LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() )
   // LOCAL nQtd := 0

   IF ! AbreArquivos( "jpimpos", "jpitem" )
      RETURN
   ENDIF
   SELECT jpitem
   GOTO TOP
   DO WHILE ! Eof()
      IF Val( jpitem->ieProDep ) == 2
         RecLock()
         REPLACE jpitem->ieCest WITH "2710193"
      ELSEIF Val( jpitem->ieProDep ) == 3
         RecLock()
         REPLACE jpitem->ieCest WITH "2710192"
      ENDIF
      /*
      IF Empty( jpitem->ieTriPro )
      SKIP
      LOOP
      ENDIF
      IF Empty( jpitem->ieNcm )
      SKIP
      LOOP
      ENDIF
      cnMySql:cSql := "SELECT * FROM TAB_CEST WHERE NCM=" + StringSql( jpitem->ieNcm )
      cnMySql:Execute()
      IF cnMySql:RecordCount() == 1
      nQtd += 1
      SayScroll( Str( nQtd, 6 ) + " " + jpitem->ieItem + " " + Pad( jpitem->ieDescri, 30 ) + " " + jpitem->ieNcm + " " + cnMySql:StringSql( "CEST" ) )
      Inkey(0.5)
      ENDIF
      cnMySql:CloseRecordset()
      */
      SKIP
   ENDDO
   CLOSE DATABASES
   Mensagem( "Fim", " 27" )

   RETURN
