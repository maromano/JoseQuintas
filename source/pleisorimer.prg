/*
PLEISORIMER - ORIGEM DA MERCADORIA
2013.01 - José Quintas

...
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisOriMer

   LOCAL oFrm := AuxOriMerClass():New()
   MEMVAR m_Prog

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_ORIMER
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXORIMERClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_ORIMER
   METHOD TelaDados( lEdit )
   METHOD Especifico (lExiste )
   METHOD Valida( cCodigo )
   METHOD GridSelection()

   ENDCLASS

METHOD GridSelection() CLASS AUXORIMERClass

   LOCAL nSelect := Select()

   SELECT jptabel
   FazBrowse( ,, AUX_ORIMER )
   IF LastKey() != K_ESC .AND. ! Eof()
      KEYBOARD Left( jptabel->axCodigo, 1  ) + Chr( K_ENTER )
   ENDIF
   SELECT ( nSelect )

   RETURN NIL

METHOD TelaDados( lEdit ) CLASS AUXORIMERClass

   LOCAL GetList := {}
   LOCAL maxCodigo := Left( jptabel->axCodigo, 1 )
   LOCAL maxDescri := jptabel->axDescri

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      maxCodigo := ::axKeyValue[1]
   ENDIF
   ::ShowTabs()
   @ Row()+1, 1 SAY "Origem Mercadoria..:" GET maxCodigo WHEN .F.
   @ Row()+2, 1 SAY "Descrição..........:" GET maxDescri PICTURE "@!" VALID ! Empty( maxDescri )
   //SetPaintGetList( GetList )
   IF ! lEdit
      CLEAR GETS
      RETURN NIL
   ENDIF
   Mensagem( "Digite campos, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC
      GOTO ::nUltRec
      RETURN NIL
   ENDIF
   IF ::cOpc == "I"
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_ORIMER, jptabel->axCodigo WITH maxCodigo, jptabel->axInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE jptabel->axDescri With maxDescri
   IF ::cOpc == "A"
      REPLACE jptabel->axInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL

METHOD Especifico( lExiste ) CLASS AUXORIMERClass

   LOCAL GetList := {}
   LOCAL maxCodigo := Left( jptabel->axCodigo, 1 )

   IF ::cOpc == "I"
      maxCodigo := Space(1)
   ENDIF
   @ Row()+1, 22 GET maxCodigo PICTURE "9" VALID Val( maxCodigo ) > 0
   Mensagem( "Digite código para cadastro, F9 pesquisa, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Val( maxCodigo ) == 0
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK AUX_ORIMER + maxCodigo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { maxCodigo }

   RETURN .T.

METHOD Valida( cCodigo ) CLASS AUXORIMERClass

   IF ! Encontra( AUX_ORIMER + cCodigo, "jptabel", "numlan" )
      MsgStop( "Origem de mercadoria não cadastrada!" )
      RETURN .F.
   ENDIF

   RETURN .T.
