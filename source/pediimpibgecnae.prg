/*
PEDIIMPIBGECNAE - IMPORTA IBGE CNAE EXCEL
2011.09 José Quintas
*/

#include "josequintas.ch"

PROCEDURE pEdiImpIbgeCnae

   LOCAL mCnae, mDescricao, nQtd, cnExcel, mFiles, mFileExcel, cSheetName, nQtdTotal, cnJoseQuintas := ADOClass():New( AppcnJoseQuintas() )
   LOCAL cTxt := "", lBegin := .T.

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF

   SELECT jptabel

   mFiles := Directory( "IMPORTA\cnae21_estrutura_detalhada.xls" )

   IF Len( mFiles ) == 0
      MsgStop( "Planilha cnae21_estrutura_detalhada.xls não encontrada na pasta IMPORTA\" + hb_eol() + ;
         "Baixe em http://concla.ibge.gov.br/classificacoes/download-concla" + hb_eol() + ;
      "Renomeie internamente pra plan1" )
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

   cSheetName   := "[Plan1$]"

   cnExcel:cSql := "SELECT COUNT(*) AS QTD FROM " + cSheetName
   nQtdTotal    := cnExcel:ReturnValueAndClose( "QTD" )

   cnExcel:cSql := "select * from " + cSheetName
   cnExcel:Execute()

   cnJoseQuintas:cSql := "DELETE FROM JPTABAUX WHERE AXTABELA='CNAE..'"
   cnJoseQuintas:Execute()

   nQtd := 0
   cnExcel:MoveFirst()
   cnExcel:MoveNext() // pula titulo
   GrafTempo( "Importando Atividades" )
   DO WHILE ! cnExcel:Eof()
      GrafTempo( nQtd, nQtdTotal )
      mCnae      := cnExcel:StringSql( 4 )
      mDescricao := cnExcel:StringSql( 5 )
      IF mDescricao != NIL
         mDescricao := Upper( TiraAcento( Trim( mDescricao ) ) )
      ENDIF
      IF mCnae != NIL .AND. mDescricao != NIL
         IF ! Empty( mCnae ) .AND. ! Empty( mDescricao )
            IF Len( cTxt ) == 0
               cTxt := "INSERT IGNORE INTO JPTABAUX ( AXTABELA, AXCODIGO, AXDESCRI, AXINFINC ) VALUES "
               lBegin := .T.
            ENDIF
            IF ! lBegin
               cTxt += ", "
            ENDIF
            lBegin := .F.
            mCnae := SoNumeros( mCnae )
            mDescricao := Trim( mDescricao )
            SayScroll( mCnae + " " + mDescricao )
            cTxt += "( " + StringSql( AUX_CNAE ) + ", " + StringSql( Pad( mCnae, 6 ) ) + ", " + ;
               StringSql( mDescricao ) + ", " + StringSql( LogInfo() ) + " )"
            IF Len( cTxt ) > MYSQL_MAX_CMDINSERT
               cnJoseQuintas:ExecuteCmd( cTxt )
               cTxt := ""
            ENDIF
            nQtd += 1
         ENDIF
      ENDIF
      cnExcel:MoveNext()
   ENDDO
   cnExcel:CloseConnection()
   IF Len( cTxt ) != 0
      cnJoseQuintas:ExecuteCmd( cTxt )
   ENDIF
   cnJoseQuintas:CloseConnection()
   MsgExclamation( "Fim da importação! Verificada(s) " + LTrim( Str( nQtd ) ) + " CNAEs" )

   RETURN
