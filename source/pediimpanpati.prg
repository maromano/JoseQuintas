/*
PEDIIMPANPCNAE - IMPORTA T002 - ATIVIDADE ANP (CNAE)
2015.01 José Quintas
*/

#include "josequintas.ch"

PROCEDURE pEdiImpAnpAti

   LOCAL matCnae, matDescri
   LOCAL cnJoseQuintas := ADOClass():New( AppcnJoseQuintas() )
   LOCAL cnExcel, nQtd, cSheetName, mFiles, mFileExcel, nQtdTotal, cTxt := "", lBegin := .T., mValDe, mValAte

   mFiles := Directory( "IMPORTA\T002*.XLS" )

   IF Len( mFiles ) = 0
      MsgStop( "Planilha ANP T002 não encontrada na pasta IMPORTA\" )
      RETURN
   ENDIF

   mFileExcel := hb_cwd() + "IMPORTA\" + mFiles[ 1, 1 ]
   SayScroll( mFileExcel )

   IF ! MsgYesNo( "Confirma processo?" )
      RETURN
   ENDIF

   cnJoseQuintas:Open()
   SayScroll( "Importando dados" )

   cnExcel := ADOClass():New( ExcelConnection( mFileExcel ) )
   cnExcel:Open()

   cnJoseQuintas:ExecuteCmd( "TRUNCATE TABLE JPTABANPATI" )

   cSheetName := "[AtividadeEconomica$]"

   cnExcel:cSql := "SELECT COUNT(*) AS QTD FROM " + cSheetName
   cnExcel:Execute()
   nQtdTotal := cnExcel:NumberSql( "QTD" )
   cnExcel:CloseRecordset()

   cnExcel:cSql := "SELECT COUNT(*) AS QTD FROM " + cSheetName
   cnExcel:Execute()
   nQtdTotal := nQtdTotal + cnExcel:NumberSql( "QTD" )
   cnExcel:CloseRecordset()

   nQtd := 0

   GrafTempo( "Importando CNAE" )

   cnExcel:cSql := "select * from " + cSheetName
   cnExcel:Execute()

   cnExcel:MoveFirst()
   cnExcel:MoveNext() // pula titulo
   DO WHILE ! cnExcel:Eof()
      GrafTempo( nQtd, nQtdTotal )
      nQtd += 1
      matCnae   := StrZero( Val( cnExcel:StringSql( 0 ) ), 5 )
      matDescri := Trim( cnExcel:StringSql( 1 ) )
      mValDe    := cnExcel:StringSql( 2 )
      mValAte   := cnExcel:StringSql( 3 )
      IF Val( matCnae ) != 0
         IF Len( cTxt ) == 0
            cTxt += "INSERT IGNORE INTO JPTABANPATI ( ATCNAE, ATDESCRI, ATVALDE, ATVALATE ) VALUES "
            lBegin := .T.
         ENDIF
         IF ! lBegin
            cTxt += ", "
         ENDIF
         LBegin := .F.
         cnJoseQuintas:cSql := "(" + StringSql( matCnae ) + "," + StringSql( TiraAcento( Pad( matDescri ), 100 ) ) + "," + StringSql( mValDe ) + "," + StringSql( mValAte ) + ")"
         cTxt += cnJoseQuintas:cSql
         IF Len( cTxt ) > MYSQL_MAX_CMDINSERT
            cnJoseQuintas:ExecuteCmd( cTxt )
            cTxt := ""
         ENDIF
      ENDIF
      cnExcel:MoveNext()
   ENDDO
   cnExcel:CloseRecordset()
   cnExcel:CloseConnection()
   IF Len( cTxt ) != 0
      cnJoseQuintas:ExecuteCmd( cTxt )
   ENDIF
   cnJoseQuintas:CloseConnection()
   MsgExclamation( "Fim da importação! Verificados " + LTrim( Str( nQtd ) ) + " CNAEs" )

   RETURN
