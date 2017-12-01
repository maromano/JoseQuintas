/*
PEDIIMPANPLOC - IMPORTA T018 - LOCALIDADES
2011.09.20 José Quintas
*/

#include "josequintas.ch"

PROCEDURE pEdiImpAnpLoc

   LOCAL mAnp, mIbge, mNome, mUf, nQtd, mFiles, mFileExcel, cSheetName, nQtdTotal, cnExcel
   LOCAL cnJoseQuintas := ADOClass():New( AppcnJoseQuintas() )
   LOCAL cTxt := "", lBegin := .T., mValDe, mValAte

   mFiles := Directory( "IMPORTA\T018*.XLS" )

   IF Len( mFiles ) = 0
      MsgStop( "Planilha ANP T018 não encontrada na pasta IMPORTA\" )
      RETURN
   ENDIF

   mFileExcel := hb_cwd() + "IMPORTA\" + mFiles[ 1, 1 ]
   SayScroll( mFileExcel )

   IF ! MsgYesNo( "Confirma processo?" )
      RETURN
   ENDIF

   SayScroll( "Importando dados" )

   cnJoseQuintas:Open()
   cnExcel := ADOClass():New( ExcelConnection( mFileExcel ) )
   cnExcel:Open()

   cSheetName := "[Localidade$]"

   cnExcel:cSql := "SELECT COUNT(*) AS QTD FROM " + cSheetName
   nQtdTotal := cnExcel:ReturnValueAndClose( "QTD" )

   cnExcel:cSql := "select * from " + cSheetName
   cnExcel:Execute()

   cnJoseQuintas:ExecuteCmd( "TRUNCATE TABLE JPTABANPLOC" )

   nQtd := 0
   cnExcel:MoveFirst()
   cnExcel:MoveNext() // pula titulo
   GrafTempo( "Importando Localidades" )
   DO WHILE ! cnExcel:Eof()
      GrafTempo( nQtd, nQtdTotal )
      nQtd    += 1
      mAnp    := cnExcel:StringSql( 0 )
      mIbge   := cnExcel:StringSql( 1 )
      mNome   := cnExcel:StringSql( 2 )
      mUf     := cnExcel:StringSql( 3 )
      mValDe  := cnExcel:StringSql( 4 )
      mValAte := cnExcel:StringSql( 5 )
      mAnp    := StrZero( Val( mAnp ), 7 )
      mIbge   := StrZero( Val( mIbge ), 7 )
      mNome   := TiraAcento( Trim( mNome ) )
      mUf     := Upper( Pad( mUf, 2 ) )
      IF Val( mIbge ) != 0
         IF Len( cTxt ) == 0
            cTxt := "INSERT IGNORE INTO JPTABANPLOC ( ALIBGE, ALANP, ALNOME, ALUF, ALVALDE, ALVALATE ) VALUES "
            lBegin := .T.
         ENDIF
         IF ! lBegin
            cTxt += ", "
         ENDIF
         lBegin := .F.
         cnJoseQuintas:cSql := "(" + StringSql( mIbge ) + "," + StringSql( mAnp ) + "," + StringSql( mNome ) + "," + StringSql( mUF ) + "," + StringSql( mValDe ) + "," + StringSql( mValAte ) + ")"
         cTxt += cnJoseQuintas:cSql
         IF Len( cTxt ) > MYSQL_MAX_CMDINSERT
            cnJoseQuintas:ExecuteCmd( cTxt )
            cTxt := ""
         ENDIF
      ENDIF
      cnExcel:MoveNext()
   ENDDO
   cnExcel:CloseConnection()
   IF Len( cTxt ) > 0
      cnJoseQuintas:ExecuteCmd( cTxt )
   ENDIF
   cnJoseQuintas:CloseConnection()
   MsgExclamation( "Fim da importação! Verificada(s) " + LTrim( Str( nQtd ) ) + " Localidade(s)" )

   RETURN
