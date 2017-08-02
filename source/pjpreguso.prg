/*
PJPREGUSO - Ocorrências
2007.05.22 - José Quintas
*/

#include "inkey.ch"

FUNCTION PJPREGUSO( cArquivo, cCodigo )

   LOCAL mSelect, mCampos, mTmpFile, lAltera, lIsOpen, cnMySql := ADOClass():New( AppcnMySqlLocal() )
   MEMVAR mruArquivo, mruCodigo
   PRIVATE mruArquivo, mruCodigo

   mruArquivo := cArquivo
   mruCodigo  := cCodigo
   lAltera    := ( AppUserLevel() < 2 .OR. TemAcesso( "ADMOCOALT" ) )
   mSelect    := Select()
   lIsOpen    := ( Select( "jpreguso" ) != 0 )
   IF Empty( mruArquivo ) .OR. Val( mruCodigo ) == 0
      RETURN NIL
   ENDIF
   AppGuiHide()
   WSave()
   IF AppcnMySqlLocal() == NIL
      IF ! lIsOpen
         SELECT 0
         AbreArquivos( "jpreguso" )
      ENDIF
      SELECT jpreguso
      Cls()
      mCampos := { ;
         { "HORÁRIO", { || Substr( jpreguso->ruInfInc, 1, 26 ) } }, ;
         { "TEXTO",   { || jpreguso->ruTexto } }, ;
         { "INF.INC", { || jpreguso->ruInfInc } } }
      SELECT jpreguso
      SEEK Pad( mruArquivo, 9 ) + mruCodigo
      mTmpFile := MyTempFile( "CDX" )
      INDEX ON jpreguso->ruArquivo + jpreguso->ruCodigo + Str( RecNo(), 10 ) TAG ("temp") TO ( mTmpFile ) ADDITIVE ;
            FOR Pad( mruArquivo, 9 ) = jpreguso->ruArquivo .AND. mruCodigo == jpreguso->ruCodigo ;
            WHILE Pad( mruArquivo, 9 ) == jpreguso->ruArquivo .AND. mruCodigo == jpreguso->ruCodigo
      SET INDEX TO ( PathAndFile( "jpreguso" ) ), ( mTmpFile )
      OrdSetFocus( "temp" )
      GOTO TOP
      DO WHILE .T.
         GOTO TOP
         Mensagem( "Selecione, " + iif( lAltera, "ENTER altera, INS Insere, ", "" ) + "ESC sai" )
         dbView( 2, 0, MaxRow() - 4, MaxCol(), mCampos, { | b, k | DigOcorr( b, k ) } )
         IF LastKey() == K_ESC
            EXIT
         ENDIF
      ENDDO
      SELECT jpreguso
      SET INDEX TO ( PathAndFile( "jpreguso" ) )
      fErase( mTmpFile )
      IF ! lIsOpen
         USE
      ENDIF
   ELSE
      cnMySql:cSql := "SELECT RUID, RUARQUIVO, RUCODIGO, RUTEXTO, RUINFINC FROM JPREGUSO WHERE RUARQUIVO=" + StringSql( mruArquivo ) + " AND RUCODIGO=" + mruCodigo
      mTmpFile := cnMySql:SqlToDbf()
      Cls()
      SELECT 0
      USE ( mTmpFile ) ALIAS temp
      mCampos := { ;
         { "HORÁRIO", { || Substr( temp->ruInfInc, 1, 26 ) } }, ;
         { "TEXTO",   { || temp->ruTexto } }, ;
         { "INF.INC", { || temp->ruInfInc } } }
      DO WHILE .T.
         GOTO TOP
         Mensagem( "Selecione, " + iif( lAltera, "ENTER altera, INS Insere, ", "" ) + "ESC sai" )
         dbView( 2, 0, MaxRow() - 4, MaxCol(), mCampos, { | b, k | DigOcorr( b, k ) } )
         IF LastKey() == K_ESC
            EXIT
         ENDIF
      ENDDO
      USE
      fErase( mTmpFile )
   ENDIF
   WRestore()
   AppGuiShow()
   SELECT ( mSelect )

   RETURN NIL

STATIC FUNCTION DigOcorr( ... )

   LOCAL mLinha1, GetList := {}, mruInfInc, cnMySql := ADOClass():New( AppcnMySqlLocal() )
   MEMVAR mruArquivo, mruCodigo

   DO CASE
   CASE LastKey() == K_ESC
      RETURN 0
   CASE LastKey() == K_INS
      WOpen( 7, 3, 13, 108, "Nova Ocorrência" )
      mLinha1 := Space(100)
      @  9, 5 SAY Date()
      @ 10, 5 GET mLinha1
      Mensagem( "Digite ocorrência, ESC sai" )
      READ
      IF LastKey() != K_ESC
         IF AppcnMySqlLocal() == NIL
            RecAppend()
            REPLACE jpreguso->ruArquivo WITH mruArquivo, jpreguso->ruCodigo WITH mruCodigo, ;
               jpreguso->ruTexto WITH mLinha1, jpreguso->ruInfInc WITH LogInfo()
            RecUnlock()
         ELSE
            RecAppend()
            REPLACE temp->ruArquivo WITH mruArquivo, temp->ruCodigo WITH mruCodigo, ;
               temp->ruTexto WITH mLinha1, temp->ruInfInc WITH LogInfo()
            RecUnlock()
            WITH OBJECT cnMySql
               :QueryCreate()
               :QueryAdd( "RUARQUIVO", mruArquivo )
               :QueryAdd( "RUCODIGO",  mruCodigo )
               :QueryAdd( "RUTEXTO",   mLinha1 )
               :QueryAdd( "RUINFINC",  LogInfo() )
               :QueryExecuteInsert( "JPREGUSO" )
            END WITH
         ENDIF
         KEYBOARD Chr( K_CTRL_PGUP )
      ENDIF
      WClose()
      RETURN 0
   CASE AppUserLevel() > 1 .AND. ! TemAcesso( "ADMOCOALT" )
   CASE LastKey() == K_DEL .AND. ! Eof() .AND. ! Deleted()
      IF MsgYesNo( "Confirma a exclusão?" )
         IF AppcnMySqlLocal() == NIL
            RecDelete()
         ELSE
            cnMySql:cSql := "DELETE FROM JPREGUSO WHERE RUARQUIVO=" + StringSql( temp->ruArquivo ) + " AND " + ;
               "RUCODIGO=" + StringSql( mruCodigo ) + " AND RUID=" + NumberSql( temp->RUID )
            cnMySql:ExecuteCmd()
            RecDelete()
         ENDIF
         KEYBOARD Chr( K_CTRL_PGUP )
      ENDIF
      RETURN 0
   CASE LastKey() == K_ENTER .AND. ! Eof() .AND. ! Deleted()
      WOpen( 7, 3, 16, 108, "Ocorrência" )
      IF AppcnMySqlLocal() == NIL
         mLinha1   := jpreguso->ruTexto
         mruInfInc := jpreguso->ruInfInc
      ELSE
         mlinha1   := temp->ruTexto
         mruInfInc := temp->ruInfInc
      ENDIF
      @ 10, 5 GET mLinha1
      @ 14, 5 SAY "Inf.Inclusão.:" GET mruInfInc WHEN .F.
      Mensagem( "Digite ocorrência, ESC sai" )
      READ
      IF LastKey() != K_ESC
         IF AppcnMySqlLocal() == NIL
            RecLock()
            REPLACE jpreguso->ruTexto WITH mLinha1
            RecUnlock()
         ELSE
            RecLock()
            REPLACE temp->ruTexto WITH mLinha1
            RecUnlock()
            WITH OBJECT cnMySql
               :QueryCreate()
               :QueryAdd( "RUTEXTO", mLinha1 )
               :QueryExecuteUpdate( "JPREGUSO", "RUARQUIVO=" + StringSql( mruArquivo ) + " AND RUCODIGO=" + StringSql( mruCodigo ) + " AND RUID=" + NumberSql( temp->RUID ) )
            END WITH
         ENDIF
      ENDIF
      WClose()
      RETURN 0
   ENDCASE

   RETURN 1

FUNCTION GravaOcorrencia( cArquivo, cCodigo, cTexto )

   LOCAL nSelect, lIsOpen, cnMySql := ADOClass():New( AppcnMySqlLocal() )

   hb_Default( @cArquivo, "" )
   hb_Default( @cCodigo, "" )
   cArquivo   := Pad( cArquivo, 8 )
   lIsOpen    := ( Select( "jpreguso" ) != 0 )
   nSelect    := Select()
   cTexto     := StrTran( Trim( cTexto ), "  ", " " )
   IF AppcnMySqlLocal() == NIL
      IF ! lIsOpen
         AbreArquivos( "jpreguso" )
      ENDIF
   ENDIF
   DO WHILE Len( cTexto ) > 0
      IF AppcnMySqlLocal() == NIL
         SELECT jpreguso
         RecAppend()
         REPLACE jpreguso->ruArquivo WITH cArquivo, jpreguso->ruCodigo WITH  cCodigo, jpreguso->ruTexto WITH cTexto, jpreguso->ruInfInc WITH LogInfo()
         RecUnlock()
      ELSE
         WITH OBJECT cnMySql
            :QueryCreate()
            :QueryAdd( "RUARQUIVO", cArquivo )
            :QueryAdd( "RUCODIGO",  cCodigo )
            :QueryAdd( "RUTEXTO",   Trim( Pad( cTexto, 100 ) ) )
            :QueryAdd( "RUINFINC",  LogInfo() )
            :QueryExecuteInsert( "JPREGUSO" )
         END WITH
      ENDIF
      cTexto := Substr( cTexto, 101 )
   ENDDO
   IF AppcnMySqlLocal() == NIL
      IF ! lIsOpen
         IF Select( "jpreguso" ) != 0
            SELECT jpreguso
            USE
         ENDIF
      ENDIF
   ENDIF
   SELECT ( nSelect )

   RETURN NIL

FUNCTION QtdOcorrencias( cArquivo, cCodigo, cUltima )

   LOCAL nQtd := 0, nSelect, cnMySql := ADOClass():New( AppcnMySqlLocal() )

   cArquivo   := Pad( cArquivo, 9 )
   HB_SYMBOL_UNUSED( cUltima )
   cUltima := ""
   IF AppcnMySqlLocal() == NIL
      nSelect := Select()
      SELECT jpreguso
      SEEK cArquivo + StrZero( Val( cCodigo ), 9 )
      DO WHILE cArquivo == jpreguso->ruArquivo .AND. StrZero( Val( cCodigo ), 9 ) == jpreguso->ruCodigo .AND. ! Eof()
         cUltima := jpreguso->ruInfInc
         nQtd += 1
         SKIP
      ENDDO
      SELECT ( nSelect )
   ELSE
      cnMySql:cSql := "SELECT COUNT(*) AS QTD FROM JPREGUSO WHERE RUARQUIVO=" + StringSql( cArquivo ) + " AND RUCODIGO=" + StringSql( StrZero( Val( cCodigo ), 9 ) )
      cnMySql:Execute()
      nQtd := cnMySql:NumberSql( "QTD" )
      cnMySql:CloseRecordset()
      IF nQtd > 0
         cnMySql:cSql := "SELECT RUINFINC FROM JPREGUSO WHERE RUARQUIVO=" + StringSql( cArquivo ) + " AND RUCODIGO=" + StringSql( StrZero( Val( cCodigo ), 9 ) ) + " ORDER BY RUID DESC LIMIT 1"
         cnMySql:Execute()
         cUltima := cnMySql:StringSql( "RUINFINC" )
         cnMySql:CloseRecordset()
      ENDIF
   ENDIF

   RETURN nQtd
