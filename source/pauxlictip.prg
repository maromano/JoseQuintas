/*
PAUXLICTIP - TIPOS DE LICENCA
2013.02 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE PAUXLICTIP

   LOCAL oFrm := AUXLICTIPClass():New()

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   SET FILTER TO jptabel->axTabela == AUX_LICTIP
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXLICTIPClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_LICTIP
   METHOD TelaDados( lEdit )

   ENDCLASS

METHOD TelaDados( lEdit ) CLASS AUXLICTIPClass

   LOCAL GetList := {}
   LOCAL maxCodigo := jptabel->axCodigo
   LOCAL maxDescri := jptabel->axDescri
   LOCAL maxInfInc := jptabel->axInfInc
   LOCAL maxInfAlt := jptabel->axInfAlt
   LOCAL maxValida := Val( jptabel->axParam01 )
   LOCAL maxRenova := Val( jptabel->axParam02 )

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      maxCodigo := ::axKeyValue[1]
      ::nNumTab := 1
   ENDIF
   DO WHILE .T.
      ::ShowTabs()
      DO CASE
      CASE ::nNumTab == 1
         @ Row() + 1, 1  SAY "Código...........:" GET maxCodigo  WHEN .F.
         @ Row() + 2, 1  SAY "Descrição........:" GET maxDescri  PICTURE "@!" VALID ! Empty( maxDescri )
         @ Row() + 1, 1  SAY "Validade (meses).:" GET maxValida  PICTURE "999999"
         @ Row() + 1, 1  SAY "Renovação (dias).:" GET maxRenova  PICTURE "999999"
         @ Row() + 2, 1  SAY "Inf.Inclusão.....:" GET maxInfInc  WHEN .F.
         @ Row() + 1, 1  SAY "Inf.Alteração....:" GET maxInfAlt  WHEN .F.
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
      IF ::nNumTab > Len(::acTabName)
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
      IF maxCodigo == "*NOVO*"
         GOTO BOTTOM
         maxCodigo := StrZero( Val( jptabel->axCodigo ) + 1, 6 )
      ENDIF
      RecAppend()
      REPLACE jptabel->axTabela WITH ::cTabelaAuxiliar, jptabel->axCodigo WITH  maxCodigo, jptabel->axInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE jptabel->axDescri WITH maxDescri, jptabel->axParam01 WITH StrZero( maxValida, 6 ), jptabel->axParam02 WITH StrZero( maxRenova, 6 )
   IF ::cOpc == "A"
      REPLACE jptabel->axInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL
