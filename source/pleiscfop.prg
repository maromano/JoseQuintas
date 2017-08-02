/*
PLEISCFOP - CADASTRO CFOP - NATUREZA DE OPERACAO
1993.08.21 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisCfop

   LOCAL oFrm := AUXCFOPClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_CFOP
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXCFOPClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_CFOP
   METHOD Especifico( lExiste )
   METHOD TelaDados( lEdit )
   METHOD Valida( cCodigo, lMostra, lZerado )

   ENDCLASS

METHOD Especifico( lExiste ) CLASS AUXCFOPClass

   LOCAL GetList := {}, maxCodigo

   maxCodigo := jptabel->axCodigo
   @ Row()+1, 20 GET maxCodigo PICTURE "@K 9.999" VALID ! Empty( maxCodigo )
   Mensagem( "Digite CFOP, F9 Pesqusisa, ESC Sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Empty( maxCodigo )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK AUX_CFOP + maxCodigo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { maxCodigo }

   RETURN .T.

METHOD TelaDados( lEdit ) CLASS AUXCFOPClass

   LOCAL GetList := {}
   LOCAL maxDescri := jptabel->axDescri
   LOCAL maxInfInc := jptabel->axInfInc
   LOCAL maxInfAlt := jptabel->axInfAlt
   LOCAL maxCodigo := jptabel->axCodigo

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      maxCodigo := ::axKeyValue[ 1 ]
   ENDIF
   DO WHILE .T.
      ::ShowTabs()
      DO CASE
      CASE ::nNumTab == 1
         @ Row()+1, 1 SAY "CFOP.............:" GET maxCodigo WHEN .F.
         @ Row()+2, 1 SAY "Descrição........:" GET maxDescri PICTURE "@K!"
         @ Row()+2, 1 SAY "Inf.Inclusão.....:" GET maxInfInc WHEN .F.
         @ Row()+1, 1 SAY "Inf.Alteração....:" GET maxInfAlt WHEN .F.
      ENDCASE
      //SetPaintGetList( GetList )
      IF lEdit
         Mensagem( "Digite campos, F9 Pesquisa, ESC Sai" )
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
      IF ::nNumTab == Len( ::acTabName ) + 1
         EXIT
      ENDIF
   ENDDO
   IF LastKey() == K_ESC
      GOTO ::nUltRec
      RETURN NIL
   ENDIF
   IF lEdit
      IF ::cOpc == "I"
         maxCodigo := ::axKeyValue[ 1 ]
         RecAppend()
         REPLACE jptabel->axCodigo WITH maxCodigo, jptabel->axInfInc WITH LogInfo()
         RecUnlock()
      ENDIF
      RecLock()
      REPLACE jptabel->axDescri WITH maxDescri
      IF ::cOpc == "A"
         REPLACE jptabel->axInfAlt WITH LogInfo()
      ENDIF
      RecUnlock()
      ::nNumTab := 1
   ENDIF

   RETURN NIL

METHOD Valida( cCodigo, lMostra, lZerado ) CLASS AUXCFOPClass

   LOCAL lReturn := .T.
   MEMVAR m_Prog

   hb_Default( @lMostra, .T. )
   hb_Default( @lZerado, .F. )

   IF lMostra
      @ Row(), 32 SAY EmptyValue( jptabel->axDescri )
   ENDIF
   IF ! Encontra( AUX_CFOP + cCodigo, "jptabel", "numlan" ) .AND. LastKey() != K_UP
      IF Val( cCodigo ) != 0 .OR. ! lZerado
         MsgWarning( "CFOP não cadastrado!" )
         lReturn := .F.
      ENDIF
   ENDIF
   IF ! m_Prog $ "PLEISCFOP"
      IF "00" $ cCodigo
         MsgStop( "Para lançamentos não pode ser usado CFOP indicador de grupo!" )
         lReturn := .F.
      ENDIF
   ENDIF
   IF lMostra
      @ Row(), 32 SAY jptabel->axDescri
   ENDIF

   RETURN lReturn
