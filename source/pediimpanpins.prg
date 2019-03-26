/*
PEDIIMPANPINS - IMPORTA T003 - INSTALACOES
2011.09.20 José Quintas
*/

#include "josequintas.ch"

PROCEDURE pEdiImpAnpIns

   LOCAL mCnpj, mAnp, nQtd, cnExcel, mFileExcel, cSheetName, nQtdTotal, mFiles
   LOCAL cnJoseQuintas := ADOClass():New( AppcnJoseQuintas() )
   LOCAL cTxt    := "", lBegin := .T., mValDe, mValAte, cSheet

   mFiles := Directory( "IMPORTA\T008*.XLS" )

   IF Len( mFiles ) = 0
      MsgStop( "Planilha ANP T008 não encontrada na pasta IMPORTA\" )
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

   cnJoseQuintas:ExecuteCmd( "TRUNCATE TABLE JPTABANPINS;" )

   cSheetName := { "[Parte_1$]", "[Parte_2$]", "[Parte_3$]" }

   nQtdTotal := 0
   FOR EACH cSheet IN cSheetName
      cnExcel:cSql := "SELECT COUNT(*) AS QTD FROM " + cSheet
      nQtdTotal += cnExcel:ReturnValueAndClose( "QTD" )
   NEXT

   nQtd := 0

   GrafTempo( "Importando Instalações" )

   FOR EACH cSheet IN cSheetName

      cnExcel:cSql := "SELECT * FROM " + cSheet
      cnExcel:Execute()

      cnExcel:MoveFirst()
      cnExcel:MoveNext() // pula titulo
      DO WHILE ! cnExcel:Eof()
         GrafTempo( nQtd, nQtdTotal )
         nQtd += 1
         mAnp    := cnExcel:StringSql( 0 )
         mCnpj   := cnExcel:StringSql( 1 )
         mValDe  := cnExcel:StringSql( 18 )
         mValAte := cnExcel:StringSql( 19 )
         mCnpj   := AllTrim( mCnpj )
         mCnpj   := StrZero( Val( mCnpj ), 14 )
         mAnp    := StrZero( Val( mAnp ), 7 )
         IF Val( mCnpj ) != 0
            IF lBegin
               cTxt += "INSERT IGNORE INTO JPTABANPINS ( AICNPJ, AIANP, AIVALDE, AIVALATE ) VALUES " + hb_eol()
            ENDIF
            IF ! lBegin
               cTxt += ", "
            ENDIF
            cTxt += " (" + ;
               StringSql( mCnpj ) + "," + ;
               StringSql( mAnp ) + "," + ;
               StringSql( mValDe ) + "," + ;
               StringSql( mValAte ) + ")"
            lBegin := .F.
            IF Len( cTxt ) > MYSQL_MAX_CMDINSERT
               cnJoseQuintas:ExecuteCmd( cTxt )
               cTxt := ""
               lBegin := .T.
            ENDIF
            //cnJoseQuintas:Execute()
         ENDIF
         cnExcel:MoveNext()
      ENDDO
      cnExcel:CloseRecordset()
      IF Len( cTxt ) > 0
         cnJoseQuintas:ExecuteCmd( cTxt )
      ENDIF
   NEXT
   cnExcel:CloseConnection()
   cnJoseQuintas:CloseConnection()
   MsgExclamation( "Fim da importação! Verificadas " + LTrim( Str( nQtd ) ) + " instalações" )

   RETURN
