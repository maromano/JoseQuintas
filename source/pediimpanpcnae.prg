/*
pEdiImpAnpCnae - IMPORTA CNAE (T002 - ATIVIDADES)
2011.09.20 José Quintas
*/

#include "josequintas.ch"
#include "directry.ch"

PROCEDURE pediImpAnpCnae

   LOCAL nQtd, nQtdTotal, mCnae, mDescricao, cnExcel, cSheetName, mFiles, mFileExcel

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel

   mFiles := Directory( "IMPORTA\T002*.XLS" )

   IF Len(mFiles) = 0
      MsgStop( "Planilha ANP T002 não encontrada na pasta IMPORTA\" )
      RETURN
   ENDIF

   mFileExcel := hb_cwd() + "IMPORTA\" + mFiles[ 1, F_NAME ]
   SayScroll( mFileExcel )

   IF ! MsgYesNo( "Confirma processo?" )
      RETURN
   ENDIF

   SayScroll( "Importando dados" )

   cnExcel := ADOClass():New( ExcelConnection( mFileExcel ) )
   cnExcel:Open()

   cSheetName := "[AtividadeEconomica$]"

   cnExcel:cSql := "SELECT COUNT(*) AS QTD FROM " + cSheetName
   cnExcel:Execute()
   nQtdTotal := cnExcel:NumberSql("QTD")
   cnExcel:CloseRecordset()

   cnExcel:cSql := "select * from " + cSheetName
   cnExcel:Execute()

   nQtd := 0
   cnExcel:MoveFirst()
   cnExcel:MoveNext() // pula titulo
   GrafTempo( "Importando Atividades" )
   DO WHILE ! cnExcel:Eof()
      GrafTempo( nQtd, nQtdTotal )
      nQtd += 1
      mCnae      := cnExcel:StringSql( 0 )
      mDescricao := cnExcel:StringSql( 1 )
   //   mDatIni    := cnExcel:StrignSql( 2 )
   //   mDatFim    := cnExcel:StringSql( 3 )
      mCnae      := StrZero( Val( mCnae ), 6 )
      mDescricao := Upper( TiraAcento( mDescricao ) )
      mDescricao := StrTran( mDescricao, ["], "" )
      IF Val( mCnae ) != 0
         IF ! Encontra( AUX_CNAE + mCnae, "jptabel", "numlan" )
            SELECT jptabel
            RecAppend()
            REPLACE jptabel->axTabela WITH AUX_CNAE, jptabel->axCodigo WITH mCnae, jptabel->axDescri WITH mDescricao, jptabel->axInfInc WITH LogInfo()
            RecUnlock()
         ENDIF
      ENDIF
      cnExcel:MoveNext()
   ENDDO
   cnExcel:CloseConnection()
   MsgExclamation( "Fim da importação! Verificada(s) " + LTrim( Str( nQtd ) ) + " Atividades(s)" )

   RETURN
