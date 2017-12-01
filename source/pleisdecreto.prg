/*
PLEISDECRETO - DECRETOS/LEIS
2011.02 - José Quintas
*/

#include "hbclass.ch"
#include "inkey.ch"

PROCEDURE pLeisDecreto

   LOCAL oFrm := JPDECRETClass():New()

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpdecret" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpnota", "jpimpos" )
      RETURN
   ENDIF
   IF AppcnMySqlLocal() == NIL
      SELECT jpdecret
   ENDIF
   oFrm:axKeyValue[ 1 ] := Space(6)
   oFrm:Execute()

   RETURN

CREATE CLASS JPDECRETClass INHERIT FrmCadastroClass

   METHOD Especifico( lExiste )
   METHOD TelaDados( lEdit )
   METHOD Valida( cDecreto )
   METHOD Delete()
   METHOD GridSelection()
   METHOD MoveFirst()
   METHOD MoveLast()
   METHOD MovePrevious()
   METHOD MoveNext()

   ENDCLASS

METHOD Especifico( lExiste ) CLASS JPDECRETClass

   LOCAL GetList := {}
   LOCAL mdeNumLan
   LOCAL cnJPDECRET := ADOClass():New( AppcnMySqlLocal() )

   IF ::cOpc == "I"
      mdeNumLan := "*NOVO*"
   ELSE
      IF AppcnMySqlLocal() == NIL
         mdeNumLan := jpdecret->DENUMLAN
      ELSE
         mdeNumLan := ::axKeyValue[ 1 ]
      ENDIF
   ENDIF
   @ Row() + 1, 20 GET mdeNumLan PICTURE "@K 999999" VALID NovoMaiorZero( @mdeNumLan )
   Mensagem( "Digite código para cadastro, F9 pesquisa, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. ( Val(mdeNumLan) == 0 .AND. mdeNumLan != "*NOVO*" )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   IF AppcnMySqlLocal() == NIL
      SEEK mdeNumLan
      IF ! ::EspecificoExiste( lExiste, Eof() )
         RETURN .F.
      ENDIF
   ELSE
      cnJPDECRET:cSql := "SELECT * FROM JPDECRET WHERE DENUMLAN=" + StringSql( mdeNumLan )
      cnJPDECRET:Execute()
      IF ! ::EspecificoExiste( lExiste, cnJPDECRET:Eof() )
         cnJPDECRET:CloseRecordset()
         RETURN .F.
      ENDIF
      cnJPDECRET:CloseRecordset()
   ENDIF
   ::axKeyValue := { mdeNumLan }

   RETURN .T.

METHOD Delete() CLASS JPDECRETClass

   LOCAL lExclui := .T.
   LOCAL cnJPDECRET := ADOClass():New( AppcnMySqlLocal() )

   IF Empty( ::axKeyValue[ 1 ] )
      RETURN NIL
   ENDIF
   SELECT jpimpos
   LOCATE FOR ::axKeyValue[ 1 ] $ jpimpos->imLeis
   IF ! Eof()
      MsgStop( "INVÁLIDO! Decreto usado na regra " + jpimpos->imNumLan )
      lExclui := .F.
   ENDIF
   SELECT jpnota
   LOCATE FOR ::axKeyValue[ 1 ] $ jpnota->nfLeis
   IF ! Eof()
      MsgStop( "INVÁLIDO! Decreto usado na nota fiscal " + jpnota->nfNotFis + " de " + Dtoc( jpnota->nfDatEmi ) )
      lExclui := .F.
   ENDIF
   IF AppcnMySqlLocal() == NIL
      SELECT jpdecret
      IF lExclui
         ::Super:Delete()
      ENDIF
   ELSE
      cnJPDECRET:cSql := "DELETE FROM JPDECRET WHERE DENUMLAN=" + StringSql( ::axKeyValue[ 1 ] )
      cnJPDECRET:Execute()
   ENDIF

   RETURN NIL

METHOD TelaDados( lEdit ) CLASS JPDECRETClass

   LOCAL GetList := {}
   LOCAL mdeNumLan, mdeNome, mdeDescr1, mdeDescr2, mdeDescr3, mdeDescr4, mdeDescr5, mdeInfInc, mdeInfAlt
   LOCAL cnJPDECRET := ADOClass():New( AppcnMySqlLocal() )

   IF AppcnMySqlLocal() == NIL
      mdeNumLan := jpdecret->deNumLan
      mdeNome   := jpdecret->deNome
      mdeDescr1 := jpdecret->deDescr1
      mdeDescr2 := jpdecret->deDescr2
      mdeDescr3 := jpdecret->deDescr3
      mdeDescr4 := jpdecret->deDescr4
      mdeDescr5 := jpdecret->deDescr5
      mdeInfInc := jpdecret->deInfInc
      mdeInfAlt := jpdecret->deInfAlt
   ELSE
      mdeNumLan := ::axKeyValue[ 1 ]
      cnJPDECRET:cSql := "SELECT * FROM JPDECRET WHERE DENUMLAN=" + StringSql( mdeNumLan )
      cnJPDECRET:Execute()
      IF cnJPDECRET:Eof()
         mdeNome   := Space(30)
         mdeDescr1 := Space(250)
         mdeDescr2 := Space(250)
         mdeDescr3 := Space(250)
         mdeDescr4 := Space(250)
         mdeDescr5 := Space(250)
         mdeInfInc := Space(60)
         mdeInfAlt := Space(60)
      ELSE
         WITH OBJECT cnJPDECRET
            mdeNome   := :StringSql( "DENOME", 30 )
            mdeDescr1 := :StringSql( "DEDESCR1", 250 )
            mdeDescr2 := :StringSql( "DEDESCR2", 250 )
            mdeDescr3 := :StringSql( "DEDESCR3", 250 )
            mdeDescr4 := :StringSql( "DEDESCR4", 250 )
            mdeDescr5 := :StringSql( "DEDESCR5", 250 )
            mdeInfInc := :StringSql( "DEINFINC", 60 )
            mdeInfAlt := :StringSql( "DEINFALT", 60 )
         ENDWITH
      ENDIF
      cnJPDECRET:CloseRecordset()
   ENDIF
   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      mdeNumLan := ::axKeyValue[ 1 ]
   ENDIF
   DO WHILE .T.
      ::ShowTabs()
      DO CASE
      CASE ::nNumTab == 1
         @ Row()+1, 1  SAY "Decreto..........:" GET mdeNumLan  WHEN .F.
         @ Row()+2, 1  SAY "Nome.............:" GET mdeNome    PICTURE "@!"
         @ Row()+1, 1  SAY "Descrição........:" GET mdeDescr1  PICTURE "@!S90"
         @ Row()+1, 1  SAY "      Cont.1.....:" GET mdeDescr2  PICTURE "@!S90"
         @ Row()+1, 1  SAY "      Cont.2.....:" GET mdeDescr3  PICTURE "@!S90"
         @ Row()+1, 1  SAY "      Cont.3.....:" GET mdeDescr4  PICTURE "@!S90"
         @ Row()+1, 1  SAY "      Cont.4.....:" GET mdeDescr5  PICTURE "@!S90"
         @ Row()+2, 1  SAY "Inf. Inclusão....:" GET mdeInfInc  WHEN .F.
         @ Row()+1, 1  SAY "Inf. Alteração...:" GET mdeInfAlt  WHEN .F.
      ENDCASE
      //SetPaintGetList( GetList )
      IF lEdit
         Mensagem("Digite campos, F9 Pesquisa, ESC Sai")
         READ
         Mensagem()
         ::nNumTab += 1
      ELSE
         CLEAR GETS
         EXIT
      ENDIF
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      IF ::nNumTab == Len(::acTabName) + 1
         EXIT
      ENDIF
   ENDDO
   IF lEdit
      IF LastKey() != K_ESC
         IF ::cOpc == "I"
            mdeNumLan := ::axKeyValue[1]
            IF mdeNumLan == "*NOVO*"
               IF AppcnMySqlLocal() == NIL
                  mdeNumLan := NovoCodigo( "jpdecret->deNumLan" )
               ELSE
                  mdeNumLan := NovoCodigoMySql( "JPDECRET", "DENUMLAN", 6 )
               ENDIF
            ENDIF
            IF AppcnMySqlLocal() == NIL
               RecAppend()
               REPLACE ;
                  jpdecret->deNumLan WITH mdeNumLan, ;
                  jpdecret->deInfInc WITH LogInfo()
               RecUnlock()
            ELSE
               WITH OBJECT cnJPDECRET
                  :QueryCreate()
                  :QueryAdd( "DENUMLAN", mdeNumLan )
                  :QueryAdd( "DEINFINC", LogInfo() )
                  :QueryExecuteInsert( "JPDECRET" )
               END WITH
            ENDIF
         ENDIF
         IF AppcnMySqlLocal() == NIL
            RecLock()
            REPLACE ;
               jpdecret->deNome WITH mdeNome, ;
               jpdecret->deDescr1 WITH mdeDescr1, ;
               jpdecret->deDescr2 WITH mdeDescr2, ;
               jpdecret->deDescr3 WITH mdeDescr3, ;
               jpdecret->deDescr4 WITH mdeDescr4, ;
               jpdecret->deDescr5 WITH mdeDescr5
            IF ::cOpc == "A"
               REPLACE jpdecret->deInfAlt WITH LogInfo()
            ENDIF
            RecUnlock()
         ELSE
            cnJPDECRET:cSql := "UPDATE JPDECRET SET DENOME=" + StringSql( mdeNome ) + ", " + ;
               "DEDESCR1=" + StringSql( mdeDescr1 ) + ", DEDESCR2=" + StringSql( mdeDescr2 ) + ", " + ;
               "DEDESCR3=" + StringSql( mdeDescr3 ) + ", DEDESCR4=" + StringSql( mdeDescr4 ) + ", " + ;
               "DEDESCR5=" + StringSql( mdeDescr5 )
            IF ::cOpc == "A"
               cnJPDECRET:cSql += ", DEINFALT=" + StringSql( LogInfo() )
            ENDIF
            cnJPDECRET:cSql += " WHERE DENUMLAN=" + StringSql( mdeNumLan )
            cnJPDECRET:ExecuteCmd()
         ENDIF
         ::axKeyValue[ 1 ] := mdeNumLan
      ENDIF
      ::nNumTab := 1
   ENDIF

   RETURN NIL

METHOD GridSelection() CLASS JPDECRETClass

   LOCAL nSelect := Select(), cTmpFile
   LOCAL cnJPDECRET := ADOClass():New( AppcnMySqlLocal() )

   IF AppcnMySqlLocal() == NIL
      SELECT JPDECRET
      FazBrowse()
      IF LastKey() != K_ESC .AND. ! Eof()
         KEYBOARD JPDECRET->DENUMLAN + Chr( K_ENTER )
      ENDIF
   ELSE
      cnJPDECRET:cSql := "SELECT * FROM JPDECRET"
      cTmpFile := cnJPDECRET:SqlToDbf()
      SELECT 0
      USE ( cTmpFile ) ALIAS JPDECRET
      FazBrowse()
      IF LastKey() != K_ESC .AND. ! Eof()
         KEYBOARD jpdecret->DENUMLAN + Chr( K_ENTER )
      ENDIF
      USE
      fErase( cTmpFile )
   ENDIF
   SELECT ( nSelect )

   RETURN NIL

METHOD Valida( cDecreto ) CLASS JPDECRETClass

   LOCAL lOk := .T.
   LOCAL cnJPDECRET := ADOClass():New( AppcnMySqlLocal() )

   @ Row(), 32 SAY Space(30)
   IF Val( cDecreto ) == 0
      cDecreto := Space(6)
   ELSE
      cDecreto := StrZero(Val(cDecreto),6)
      IF AppcnMySqlLocal() == NIL
         IF ! Encontra( cDecreto, "jpdecret", "numlan" )
            MsgWarning( "Código de lei/decreto inexistente!" )
            lOk := .F.
         ENDIF
         @ Row(), 32 SAY jpdecret->deNome
      ELSE
         cnJPDECRET:cSql := "SELECT * FROM JPDECRET WHERE DENUMLAN=" + StringSql( cDecreto )
         cnJPDECRET:Execute()
         IF cnJPDECRET:Eof()
            MsgWarning( "Código de lei/decreto inexistente!" )
            lOk := .F.
         ELSE
            @ Row(), 32 SAY cnJPDECRET:StringSql( "DENOME", 30 )
         ENDIF
         cnJPDECRET:CloseRecordset()
      ENDIF
   ENDIF

   RETURN lOk

METHOD MoveFirst() CLASS JPDECRETClass

   LOCAL cnJPDECRET := ADOClass():New( AppcnMySqlLocal() )

   IF AppcnMySqlLocal() == NIL
      ::Super:MoveFirst()
      ::axKeyValue[ 1 ] := jpdecret->DENUMLAN
   ELSE
      cnJPDECRET:cSql := "SELECT DENUMLAN FROM JPDECRET ORDER BY DENUMLAN LIMIT 1"
      cnJPDECRET:Execute()
      IF ! cnJPDECRET:Eof()
         ::axKeyValue[ 1 ] := cnJPDECRET:StringSql( "DENUMLAN" )
      ENDIF
      cnJPDECRET:CloseRecordset()
   ENDIF

   RETURN NIL

METHOD MoveLast() CLASS JPDECRETClass

   LOCAL cnJPDECRET := ADOClass():New( AppcnMySqlLocal() )

   IF AppcnMySqlLocal() == NIL
      ::Super:MoveLast()
      ::axKeyValue[ 1 ] := jpdecret->DENUMLAN
   ELSE
      cnJPDECRET:cSql := "SELECT DENUMLAN FROM JPDECRET ORDER BY DENUMLAN DESC LIMIT 1"
      cnJPDECRET:Execute()
      IF ! cnJPDECRET:Eof()
         ::axKeyValue[ 1 ] := cnJPDECRET:StringSql( "DENUMLAN" )
      ENDIF
      cnJPDECRET:CloseRecordset()
   ENDIF

   RETURN NIL

METHOD MovePrevious() CLASS JPDECRETClass

   LOCAL cnJPDECRET := ADOClass():New( AppcnMySqlLocal() )

   IF AppcnMySqlLocal() == NIL
      ::Super:MovePrevious()
      ::axKeyValue[ 1 ] := jpdecret->DENUMLAN
   ELSE
      cnJPDECRET:cSql := "SELECT DENUMLAN FROM JPDECRET WHERE DENUMLAN < " + StringSql( ::axKeyValue[ 1] ) + " ORDER BY DENUMLAN DESC LIMIT 1"
      cnJPDECRET:Execute()
      IF ! cnJPDECRET:Eof()
         ::axKeyValue[ 1 ] := cnJPDECRET:StringSql( "DENUMLAN" )
      ENDIF
      cnJPDECRET:CloseRecordset()
   ENDIF

   RETURN NIL

METHOD MoveNext() CLASS JPDECRETClass

   LOCAL cnJPDECRET := ADOClass():New( AppcnMySqlLocal() )

   IF AppcnMySqlLocal() == NIL
      ::Super:MoveNext()
      ::axKeyValue[ 1 ] := jpdecret->DENUMLAN
   ELSE
      cnJPDECRET:cSql := "SELECT DENUMLAN FROM JPDECRET WHERE DENUMLAN > " + StringSql( ::axKeyValue[ 1] ) + " ORDER BY DENUMLAN LIMIT 1"
      cnJPDECRET:Execute()
      IF ! cnJPDECRET:Eof()
         ::axKeyValue[ 1 ] := cnJPDECRET:StringSql( "DENUMLAN" )
      ENDIF
      cnJPDECRET:CloseRecordset()
   ENDIF

   RETURN NIL
