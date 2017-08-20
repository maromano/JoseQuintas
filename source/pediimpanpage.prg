/*
PEDIIMPANPAGE - IMPORTA T001 - AGENTES
2011.09.20 José Quintas
*/

#include "josequintas.ch"

PROCEDURE pEdiImpAnpAge

   LOCAL mAnp, mCnpj, cnExcel, mFiles, mFileExcel, cSheetName, nQtd, nQtdTotal
   LOCAL cnJoseQuintas := ADOClass():New( AppcnJoseQuintas() )
   LOCAL cTxt := "", lBegin := .F., mValDe, mValAte

mFiles := Directory( "IMPORTA\T001*.XLS" )

IF Len(mFiles) = 0
   MsgStop( "Planilha ANP T001 não encontrada na pasta IMPORTA\" )
   RETURN
ENDIF

mFileExcel := hb_cwd() + "IMPORTA\" + mFiles[ 1, 1 ]
SayScroll( mFileExcel )

IF ! MsgYesNo( "Confirma processo?" )
   RETURN
ENDIF

SayScroll( "Importando dados" )

cnJoseQuintas:Open()
cnJoseQuintas:ExecuteCmd( "TRUNCATE TABLE JPTABANPAGE" )

cnExcel := ADOClass():New( ExcelConnection( mFileExcel ) )
cnExcel:Open()

cSheetName := "[AgenteRegulado$]"

cnExcel:cSql := "SELECT COUNT(*) AS QTD FROM " + cSheetName
nQtdTotal := cnExcel:ReturnValueAndClose( "QTD" )

cnExcel:cSql := "SELECT * FROM " + cSheetName
cnExcel:Execute()

nQtd := 0
cnExcel:MoveFirst()
cnExcel:MoveNext() // pula titulo
GrafTempo( "Importando Agentes" )
DO WHILE ! cnExcel:Eof()
   GrafTempo( nQtd, nQtdTotal )
   nQtd += 1
   mAnp    := cnExcel:StringSql( 0 )
   mCnpj   := cnExcel:StringSql( 1 )
   mValDe  := cnExcel:StringSql( 9 )
   mValAte := cnExcel:StringSql( 10 )
   mCnpj   := AllTrim( mCNpj )
   mCnpj   := StrZero( Val( mCnpj ), 8 )
   mAnp    := StrZero( Val( mAnp ), 10 )
   IF Val( mCnpj ) != 0
      IF Len( cTxt ) == 0
         cTxt   := "INSERT IGNORE INTO JPTABANPAGE ( AACNPJ, AAANP, AAVALDE, AAVALATE ) VALUES "
         lBegin := .T.
      ENDIF
      IF ! lBegin
         cTxt += ", "
      ENDIF
      lBegin := .F.
      cTxt += "(" + ;
         StringSql( mCnpj ) + "," + ;
         StringSql( mAnp ) + "," + ;
         StringSql( mValDe ) + "," + ;
         StringSql( mValAte ) + ")"
      IF Len( cTxt ) > MYSQL_MAX_CMDINSERT
         cnJoseQuintas:ExecuteCmd( cTxt )
         cTxt := ""
         lBegin := .T.
      ENDIF
   ENDIF
   cnExcel:MoveNext()
ENDDO
cnExcel:CloseConnection()
IF Len( cTxt ) > 0
   cnJoseQuintas:ExecuteCmd( cTxt )
ENDIF
cnJoseQuintas:CloseConnection()
MsgExclamation( "Fim da importação! Verificados " + LTrim( Str( nQtd ) ) + " agentes" )

RETURN
