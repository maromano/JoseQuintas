/*
PAUXLICOBJ - TIPOS DE LICENCA
2013.02 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE PAUXLICOBJ

   LOCAL oFrm := AUXLICOBJClass():New(), cFiltro

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   cFiltro := "jptabel->axTabela == [" + AUX_LICOBJ + "]"
   SET FILTER TO &cFiltro
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

CREATE CLASS AUXLICOBJClass INHERIT AUXILIARClass

   VAR  cTabelaAuxiliar INIT AUX_LICOBJ
   METHOD TelaDados( lEdit )

   ENDCLASS

METHOD TelaDados( lEdit ) CLASS AUXLICOBJClass

   LOCAL GetList := {}
   LOCAL maxCodigo := jptabel->axCodigo
   LOCAL maxDescri := jptabel->axDescri
   LOCAL maxInfInc := jptabel->axInfInc
   LOCAL maxInfAlt := jptabel->axInfAlt
   LOCAL maxLic01  := Substr( jptabel->axParam03, 1, 6 )
   LOCAL maxLic02  := Substr( jptabel->axParam03, 7, 6 )
   LOCAL maxLic03  := Substr( jptabel->axParam03, 13, 6 )
   LOCAL maxLic04  := Substr( jptabel->axParam03, 19, 6 )
   LOCAL maxLic05  := Substr( jptabel->axParam03, 25, 6 )
   LOCAL maxLic06  := Substr( jptabel->axParam03, 31, 6 )
   LOCAL maxLic07  := Substr( jptabel->axParam03, 37, 6 )
   LOCAL maxLic08  := Substr( jptabel->axParam03, 43, 6 )
   LOCAL maxLic09  := Substr( jptabel->axParam03, 49, 6 )
   LOCAL maxLic10  := Substr( jptabel->axParam03, 55, 6 )
   LOCAL maxLic11  := Substr( jptabel->axParam03, 61, 6 )
   LOCAL maxLic12  := Substr( jptabel->axParam04, 67, 6 )

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      maxCodigo := ::axKeyValue[1]
      ::nNumTab := 1
   ENDIF
   SET FILTER TO // por causa de subtabela
   DO WHILE .T.
      ::ShowTabs()
      DO CASE
      CASE ::nNumTab == 1
         @ Row()+1, 1  SAY "Código...........:" GET maxCodigo  WHEN .F.
         @ Row()+2, 1  SAY "Descrição........:" GET maxDescri  PICTURE "@!" VALID ! Empty( maxDescri )
         @ Row()+1, 1  SAY "Licença 01.......:" GET maxLic01   PICTURE "@K 999999" VALID Val( maxLic01 ) == 0 .OR. AUXLICTIPClass():Valida( @maxLic01 )
         @ Row(), 32 SAY AUXLICTIPClass():Descricao( maxLic01 )
         @ Row()+1, 1  SAY "Licença 02.......:" GET maxLic02   PICTURE "@K 999999" VALID Val( maxLic02 ) == 0 .OR. AUXLICTIPClass():Valida( @maxLic02 )
         @ Row(), 32 SAY AUXLICTIPClass():Descricao( maxLic02 )
         @ Row()+1, 1  SAY "Licença 03.......:" GET maxLic03   PICTURE "@K 999999" VALID Val( maxLic03 ) == 0 .OR. AUXLICTIPClass():Valida( @maxLic03 )
         @ Row(), 32 SAY AUXLICTIPClass():Descricao( maxLic03 )
         @ Row()+1, 1  SAY "Licença 04.......:" GET maxLic04   PICTURE "@K 999999" VALID Val( maxLic04 ) == 0 .OR. AUXLICTIPClass():Valida( @maxLic04 )
         @ Row(), 32 SAY AUXLICTIPClass():Descricao( maxLic04 )
         @ Row()+1, 1  SAY "Licença 05.......:" GET maxLic05   PICTURE "@K 999999" VALID Val( maxLic05 ) == 0 .OR. AUXLICTIPClass():Valida( @maxLic05 )
         @ Row(), 32 SAY AUXLICTIPClass():Descricao( maxLic05 )
         @ Row()+1, 1  SAY "Licença 06.......:" GET maxLic06   PICTURE "@K 999999" VALID Val( maxLic06 ) == 0 .OR. AUXLICTIPClass():Valida( @maxLic06 )
         @ Row(), 32 SAY AUXLICTIPClass():Descricao( maxLic06 )
         @ Row()+1, 1  SAY "Licença 07.......:" GET maxLic07   PICTURE "@K 999999" VALID Val( maxLic07 ) == 0 .OR. AUXLICTIPClass():Valida( @maxLic07 )
         @ Row(), 32 SAY AUXLICTIPClass():Descricao( maxLic07 )
         @ Row()+1, 1  SAY "Licença 08.......:" GET maxLic08   PICTURE "@K 999999" VALID Val( maxLic08 ) == 0 .OR. AUXLICTIPClass():Valida( @maxLic08 )
         @ Row(), 32 SAY AUXLICTIPClass():Descricao( maxLic08 )
         @ Row()+1, 1  SAY "Licença 09.......:" GET maxLic09   PICTURE "@K 999999" VALID Val( maxLic09 ) == 0 .OR. AUXLICTIPClass():Valida( @maxLic09 )
         @ Row(), 32 SAY AUXLICTIPClass():Descricao( maxLic09 )
         @ Row()+1, 1  SAY "Licença 10.......:" GET maxLic10   PICTURE "@K 999999" VALID Val( maxLic10 ) == 0 .OR. AUXLICTIPClass():Valida( @maxLic10 )
         @ Row(), 32 SAY AUXLICTIPClass():Descricao( maxLic10 )
         @ Row()+1, 1  SAY "Licença 11.......:" GET maxLic11   PICTURE "@K 999999" VALID Val( maxLic11 ) == 0 .OR. AUXLICTIPClass():Valida( @maxLic11 )
         @ Row(), 32 SAY AUXLICTIPClass():Descricao( maxLic11 )
         @ Row()+1, 1  SAY "Licença 12.......:" GET maxLic12   PICTURE "@K 999999" VALID Val( maxLic12 ) == 0 .OR. AUXLICTIPClass():Valida( @maxLic12 )
         @ Row(), 32 SAY AUXLICTIPClass():Descricao( maxLic12 )
         @ Row()+2, 1  SAY "Inf.Inclusão.....:" GET maxInfInc  WHEN .F.
         @ Row()+1, 1  SAY "Inf.Alteração....:" GET maxInfAlt  WHEN .F.
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
   SET FILTER TO &( "jptabel->axTabela == [" + ::cTabelaAuxiliar + "]" ) // por causa de subtabela
   SEEK ::cTabelaAuxiliar + maxCodigo                   // por causa de subtabela
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
   SEEK AUX_LICOBJ + maxCodigo
   RecLock()
   REPLACE jptabel->axDescri WITH maxDescri, jptabel->axParam03 WITH maxLic01 + maxLic02 + maxLic03 + maxLic04 + maxLic05 + ;
      maxLic06 + maxLic07 + maxLic08 + maxLic09 + maxLic10 + maxLic11 + maxLic12
   IF ::cOpc == "A"
      REPLACE jptabel->axInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL
