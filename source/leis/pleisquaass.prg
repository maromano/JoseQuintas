/*
PLEISQUAASS - QUALIFICACAO DE ASSINANTES
2013.02 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisQuaAss

   LOCAL oFrm := AUXQUAASSClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_QUAASS
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXQUAASSClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_QUAASS
   METHOD GridSelection()
   METHOD Especifico( lExiste )
   METHOD TelaDados( lEdit )
   METHOD Valida( cCodigo )

   ENDCLASS

METHOD GridSelection() CLASS AUXQUAASSClass

   LOCAL nSelect := Select(), cOrdSetFocus

   SELECT jptabel
   cOrdSetFocus := OrdSetFocus( "descricao" )
   FazBrowse( ,, AUX_QUAASS )
   IF LastKey() != K_ESC .AND. ! Eof()
      KEYBOARD Pad( jptabel->axCodigo, 3 ) + Chr( K_ENTER )
   ENDIF
   OrdSetFocus( cOrdSetFocus )
   SELECT ( nSelect )

   RETURN NIL

METHOD Especifico( lExiste ) CLASS AUXQUAASSClass

   LOCAL GetList := {}
   LOCAL maxCodigo := Left( jptabel->axCodigo, 3 )

   IF ::cOpc == "I"
      maxCodigo := Space(3)
   ENDIF
   @ Row()+1, 20 GET maxCodigo PICTURE "@K 999" VALID FillZeros( @maxCodigo ) .AND. Val( maxCodigo ) > 0
   Mensagem( "Digite código, F9 pesquisa, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Val( maxCodigo ) == 0
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK AUX_QUAASS + maxCodigo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { maxCodigo }

   RETURN .T.

METHOD TelaDados( lEdit ) CLASS AUXQUAASSClass

   LOCAL GetList := {}
   LOCAL maxCodigo := Left( jptabel->axCodigo, 3 )
   LOCAL maxDescri := jptabel->axDescri
   LOCAL maxInfInc := jptabel->axInfInc
   LOCAL maxInfAlt := jptabel->axInfAlt

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      maxCodigo := ::axKeyValue[1]
      ::nNumTab := 1
   ENDIF
   DO WHILE .T.
      ::ShowTabs()
      DO CASE
      CASE ::nNumTab == 1
         @ Row()+1, 1 SAY "Código...........:" GET maxCodigo WHEN .F.
         @ Row()+2, 1 SAY "Descrição........:" GET maxDescri PICTURE "@!" VALID ! Empty( maxDescri )
         @ Row()+2, 1 SAY "Inf.Inclusão.....:" GET maxInfInc WHEN .F.
         @ Row()+1, 1 SAY "Inf.Alteração....:" GET maxInfAlt WHEN .F.
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
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      IF ::nNumTab > Len( ::acTabName )
         EXIT
      ENDIF
   ENDDO
   IF ! lEdit
      RETURN NIL
   ENDIF
   ::nNumTab := 1
   IF LastKey() == K_ESC
      GOTO ::nUltRec
      RETURN NIL
   ENDIF
   IF ::cOpc == "I"
      maxCodigo := ::axKeyValue[1]
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_QUAASS, jptabel->axCodigo WITH maxCodigo, jptabel->axInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE jptabel->axDescri WITH maxDescri
   IF ::cOpc == "A"
      REPLACE jptabel->axInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL

METHOD Valida( cCodigo ) CLASS AUXQUAASSClass

   LOCAL lOk := .T.
   MEMVAR m_Prog

   cCodigo := StrZero( Val( cCodigo ), 3 )
   IF ! Encontra( AUX_QUAASS + cCodigo, "jptabel", "numlan" )
      MsgWarning( "Código não cadastrado!" )
      lOk := .F.
   ENDIF

   RETURN lOk
