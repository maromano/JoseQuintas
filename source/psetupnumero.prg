/*
PSETUPNUMERO - NUMERACAO DO SISTEMA
2012.04.22 José Quintas
*/

#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pSetupNumero

   LOCAL oFrm := JPNUMEROClass():New()

   IF ! AbreArquivos( "jpnumero" )
      RETURN
   ENDIF
   SELECT jpnumero
   ChecaDefault( "DUPLIC" )
   ChecaDefault( "CONTRA" )
   ChecaDefault( "NF" )
   ChecaDefault( "CTRC" )
   oFrm:cOptions := "CAI"
   oFrm:Execute()

   RETURN

CREATE CLASS JPNUMEROClass INHERIT FrmCadastroClass

   METHOD Especifico( lExiste )
   METHOD TelaDados( lEdit )

   ENDCLASS

METHOD Especifico(lExiste) CLASS JPNUMEROClass

   LOCAL GetList := {}
   LOCAL mnuTabela := jpnumero->nuTabela

   IF ::cOpc == "I"
      mnuTabela := "*NOVO*"
   ENDIF
   @ Row()+1, 20 GET mnuTabela PICTURE "@K!" VALID ! Empty(mnuTabela)
   Mensagem( "Digite código, F9 pesquisa, ESC volta" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Empty( mnuTabela )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK mnuTabela
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { mnuTabela }

   RETURN .T.

METHOD TelaDados( lEdit ) CLASS JPNUMEROClass

   LOCAL GetList := {}
   LOCAL mnuTabela := jpnumero->nuTabela
   LOCAL mnuCodigo := jpnumero->nuCodigo
   LOCAL mnuInfInc := jpnumero->nuInfInc
   LOCAL mnuInfAlt := jpnumero->nuInfAlt

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      mnuTabela := ::axKeyValue[1]
   ENDIF
   DO WHILE .T.
      ::ShowTabs()
      DO CASE
      CASE ::nNumTab == 1
         @ Row()+1, 1  SAY "Referência.......:" GET mnuTabela  WHEN .F.
         @ Row()+2, 1  SAY "Código...........:" GET mnuCodigo  PICTURE "@K 999999999"       VALID Val( mnuCodigo ) > 0
         @ Row()+2, 1  SAY "Inf.Inclusão.....:" GET mnuInfInc  WHEN .F.
         @ Row()+1, 1  SAY "Inf.Alteração....:" GET mnuInfAlt  WHEN .F.
      ENDCASE
      //SetPaintGetList( GetList )
      IF ! lEdit
         CLEAR GETS
         EXIT
      ENDIF
      Mensagem( "Digite campos, F9 Pesquisa, ESC Sai" )
      READ
      Mensagem()
      ::nNumTab += 1
      IF LastKey() == 27
         EXIT
      ENDIF
      IF ::nNumTab == Len( ::acTabName ) + 1
         EXIT
      ENDIF
   ENDDO
   IF ! lEdit
      RETURN NIL
   ENDIF
   IF LastKey() != K_ESC
      IF ::cOpc == "I"
         mnuTabela := ::axKeyValue[1]
         RecAppend()
         REPLACE ;
            jpnumero->nuTabela WITH mnuTabela, ;
            jpnumero->nuInfInc WITH LogInfo()
         RecUnlock()
      ENDIF
      RecLock()
      REPLACE jpnumero->nuCodigo WITH mnuCodigo
      IF ::cOpc == "A"
         REPLACE jpnumero->nuInfAlt WITH LogInfo()
      ENDIF
      RecUnlock()
   ENDIF
   ::nNumTab := 1

   RETURN NIL

STATIC FUNCTION ChecaDefault( mChave )

   SEEK Pad( mChave, 10 )
   IF Eof()
      RecAppend()
      REPLACE ;
         jpnumero->nuTabela WITH Pad( mChave, 10 ), ;
         jpnumero->nuCodigo WITH StrZero( 1, 9 ), ;
         jpnumero->nuInfInc WITH LogInfo()
      RecUnlock()
   ENDIF

   RETURN NIL

FUNCTION LeNumeracao( mTabela )

   LOCAL nSelect

   nSelect := Select()
   SELECT jpnumero
   SEEK Pad( mTabela, 10 )
   IF Eof()
      RecAppend()
      REPLACE ;
         jpnumero->nuTabela WITH Pad( mTabela, 10 ), ;
         jpnumero->nuCodigo WITH StrZero( 1, 9 )
      RecUnlock()
   ENDIF
   SELECT ( nSelect )

   RETURN jpnumero->nuCodigo

FUNCTION GravaNumeracao( mTabela, mNumero )

   LOCAL nSelect

   nSelect := Select()
   SELECT jpnumero
   SEEK Pad( mTabela, 10 )
   IF Eof()
      RecAppend()
      REPLACE ;
         jpnumero->nuTabela WITH Pad( mTabela, 10 ), ;
         jpnumero->nuCodigo WITH StrZero( 1, 9 ), ;
         jpnumero->nuInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE ;
      jpnumero->nuCodigo WITH StrZero( Val( mNumero ), 9 ), ;
      jpnumero->nuInfAlt WITH LogInfo()
   RecUnlock()
   SELECT ( nSelect )

   RETURN NIL

FUNCTION NovoCodigo( cField, nLen )

   LOCAL cCodigo, nSelect, cAlias

   nLen    := iif( nLen == NIL, Len( &cField ), nLen )
   nSelect := Select()
   cAlias  := Pad( Alias(), 10 )
   IF Select( "jpnumero" ) == 0
      AbreArquivos( "jpnumero" )
   ENDIF
   SELECT jpnumero
   SEEK cAlias
   IF Eof()
      SELECT ( nSelect )
      GOTO BOTTOM
      cCodigo := StrZero( Val( &cField ), nLen )
      SELECT jpnumero
      RecAppend()
      REPLACE ;
         jpnumero->nuTabela WITH cAlias, ;
         jpnumero->nuCodigo WITH StrZero( Val( cCodigo ), 9 )
      RecUnlock()
   ENDIF
   RecLock()
   SKIP 0
   cCodigo := StrZero( Val( jpnumero->nuCodigo ), nLen )
   IF cCodigo > Replicate( "9", nLen - 1 ) + "8" // 2 reserva
      cCodigo := Replicate( "0", nLen )
   ENDIF
   cCodigo := StrZero( Val( cCodigo ) + 1, nLen )
   SELECT ( nSelect )
   DO WHILE .T.
      SEEK cCodigo
      IF Eof()
         EXIT
      ENDIF
      cCodigo := StrZero( Val( cCodigo ) + 1, nLen )
   ENDDO
   SELECT jpnumero
   REPLACE jpnumero->nuCodigo WITH StrZero( Val( cCodigo ), 9 )
   RecUnlock()
   SELECT ( nSelect )

   RETURN cCodigo

FUNCTION NovoCodigoMySql( cTable, cField, nLen )

   LOCAL cCodigo, nSelect
   LOCAL cnGERAL := ADOClass():New( AppcnMySqlLocal() )

   hb_Default( @nLen, 6 )
   nSelect := Select()
   IF Select( "jpnumero" ) == 0
      AbreArquivos( "jpnumero" )
   ENDIF
   SELECT jpnumero
   SEEK cTable
   IF Eof()
      cnGERAL:cSql := "SELECT " + cField + " FROM " + cTable + " ORDER BY " + cField + " DESC LIMIT 1"
      cnGERAL:Execute()
      IF cnGERAL:Eof()
         cCodigo := StrZero( 1, 9 )
      ELSE
         cCodigo := StrZero( cnGERAL:NumberSql( cField ) + 1, 9 )
      ENDIF
      cnGERAL:CloseRecordset()
      SELECT jpnumero
      RecAppend()
      REPLACE ;
         jpnumero->nuTabela WITH cTable, ;
         jpnumero->nuCodigo WITH cCodigo
      RecUnlock()
   ENDIF
   RecLock()
   SKIP 0
   cCodigo := Right( jpnumero->nuCodigo, nLen )
   IF cCodigo > Replicate( "9", nLen - 1 ) + "8" // 2 reserva
      cCodigo := Replicate( "0", nLen )
   ENDIF
   cCodigo := StrZero( Val( cCodigo ) + 1, nLen )
   DO WHILE .T.
      cnGERAL:cSql := "SELECT COUNT(*) AS QTD FROM " + cTable + " WHERE " + cField + "=" + StringSql( cCodigo )
      cnGERAL:Execute()
      IF cnGERAL:NumberSql( "QTD" ) = 0
         cnGERAL:CloseRecordset()
         EXIT
      ENDIF
      cnGERAL:CloseRecordset()
      cCodigo := StrZero( Val( cCodigo ) + 1, nLen )
   ENDDO
   SELECT jpnumero
   REPLACE jpnumero->nuCodigo WITH  StrZero( Val( cCodigo ), 9 )
   RecUnlock()
   SELECT ( nSelect )

   RETURN cCodigo
