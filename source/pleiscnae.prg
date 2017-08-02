/*
PLEISCNAE - RAMOS DE ATIVIDADE
2013.01.15 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisCnae

   LOCAL oFrm := AUXCNAEClass():New()
   MEMVAR m_Prog

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_CNAE
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXCNAEClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_CNAE
   METHOD TelaDados( lEdit )
   METHOD Especifico( lExiste )
   METHOD Valida( cCodigo, cCnpj )
   METHOD Descricao( cCodigo )

   ENDCLASS

METHOD TelaDados( lEdit ) CLASS AUXCNAEClass

   LOCAL GetList := {}
   LOCAL maxCodigo := jptabel->axCodigo
   LOCAL maxDescri := jptabel->axDescri

   lEdit := Iif( lEdit==NIL, .F., lEdit )
   IF ::cOpc == "I" .AND. lEdit
      maxCodigo := ::axKeyValue[1]
   ENDIF
   ::ShowTabs()
   @ Row()+1, 1 SAY "Codigo (CNAE)......:" GET maxCodigo WHEN .F.
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
      REPLACE jptabel->axTabela WITH ::cTabelaAuxiliar, jptabel->axCodigo WITH maxCodigo, jptabel->axInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE jptabel->axDescri With maxDescri
   IF ::cOpc == "A"
      REPLACE jptabel->axInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL

METHOD Especifico( lExiste ) CLASS AUXCNAEClass

   LOCAL GetList := {}
   LOCAL maxCodigo := jptabel->axCodigo

   IF ::cOpc == "I"
      maxCodigo := Space(2)
   ENDIF
   @ Row()+1, 22 GET maxCodigo PICTURE "@K 999999" VALID FillZeros( @maxCodigo ) .AND. Val( maxCodigo ) > 0
   Mensagem( "Digite código para cadastro, F9 pesquisa, ESC volta" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Val( maxCodigo ) == 0
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK ::cTabelaAuxiliar + maxCodigo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { maxCodigo }

   RETURN .T.

METHOD Valida( cCodigo, cCnpj ) CLASS AUXCNAEClass

   IF cCodigo = "9999999" .AND. Len( SoNumeros( cCnpj ) ) == 14
      wSave()
      SiteCnpjFazenda( StrZero( Val( SoNumeros( cCnpj ) ), 14 ) )
      wRestore()
      RETURN .F.
   ENDIF
   cCodigo := StrZero( Val( cCodigo ), Len( cCodigo ) )
   Encontra( ::cTabelaAuxiliar + Pad( "0" + cCodigo, 6 ), "jptabel", "numlan" )
   @ Row(), 32 SAY jptabel->axDescri
   RETURN .T.

METHOD Descricao( cCodigo ) CLASS AUXCNAEClass

   Encontra( ::cTabelaAuxiliar + Pad( "0" + cCodigo, 6 ), "jptabel", "numlan" )

   RETURN jptabel->axDescri
