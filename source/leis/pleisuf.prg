/*
PLEISUF - UFS
2013.01.14 José Quintas
*/

#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisUF

   LOCAL oFrm := JPUFClass():New()
   MEMVAR m_Prog

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso", "jpdecret" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpcadas", "jpcidade", "jpclista", "jpcomiss", "jpconfi", "jpempre", ;
      "jpestoq", "jpfinan", "jpforpag", "jpimpos", "jpitem", "jpitped", "jplfisc", "jpnota", "jpnumero", "jppedi", ;
      "jppreco", "jpsenha", "jptabel", "jptransa", "jpuf", "jpveicul", "jpvended" )
      RETURN
   ENDIF
   SELECT jpuf
   oFrm:Execute()

   RETURN

CREATE CLASS JPUFClass INHERIT frmCadastroClass

   METHOD TelaDados( lEdit )
   METHOD Especifico (lExiste )
   METHOD Valida( cUf )

   ENDCLASS

METHOD TelaDados( lEdit ) CLASS JPUFClass

   LOCAL GetList := {}
   LOCAL mufUf     := jpuf->ufUf
   LOCAL mufDescri := jpuf->ufDescri
   LOCAL mufTriUf  := jpuf->ufTriUf

   lEdit := Iif( lEdit==NIL, .F., lEdit )
   IF ::cOpc == "I" .AND. lEdit
      mufUf := ::axKeyValue[1]
   ENDIF
   ::ShowTabs()
   @ Row()+1, 1 SAY "Sigla da UF........:" GET mufUf WHEN .F.
   @ Row()+2, 1 SAY "Descrição..........:" GET mufDescri PICTURE "@!" VALID ! Empty( mufDescri )
   @ Row()+1, 1 SAY "Tributação UF......:" GET mufTriUf  PICTURE "@K 999999" VALID AuxTriUfClass():Valida( @mufTriUf )
   @ Row(), 32  SAY AUXTRIUFClass():Descricao( mufTriUf )
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
      REPLACE ;
         jpuf->ufUf     WITH mufUf, ;
         jpuf->ufInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE ;
      jpuf->ufDescri WITH mufDescri, ;
      jpuf->ufTriUf  WITH mufTriUf
   IF ::cOpc == "A"
      REPLACE jpuf->ufInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL

METHOD Especifico(lExiste) CLASS JPUFClass

   LOCAL GetList := {}
   LOCAL mufUf := jpuf->ufUf

   IF ::cOpc == "I"
      mufUf := Space(2)
   ENDIF
   @ Row()+1, 22 GET mufUf PICTURE "@!A" VALID ! Empty( mufUf )
   Mensagem( "Digite código para cadastro, F9 pesquisa, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Empty( mufUf )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK mufUf
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { mufUf }

   RETURN .T.

METHOD Valida( cUf ) CLASS JPUFClass

   IF ! Encontra( cUf, "jpuf", "numlan" )
      MsgWarning( "UF não cadastrada!" )
      RETURN .F.
   ENDIF

   RETURN .T.
