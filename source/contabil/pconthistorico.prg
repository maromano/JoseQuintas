/*
PCONTHISTORICO - CADASTRO DE HISTORICOS PADRAO
1992.01 José Quintas
*/

#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pContHistorico

   LOCAL oFrm := CTHISTOClass():New()

   IF ! AbreArquivos( "cthisto" )
      RETURN
   ENDIF
   SELECT cthisto
   oFrm:Execute()

   RETURN

CREATE CLASS CTHISTOClass INHERIT FrmCadastroClass

   METHOD Especifico( lExiste )
   METHOD TelaDados( lEdit )
   METHOD Valida( cCodigo, cTexto1, cTexto2, cTexto3, cTexto4, cTexto5 )

   ENDCLASS

METHOD Especifico( lExiste ) CLASS CTHISTOClass

   LOCAL GetList := {}
   LOCAL mhiHisPad := cthisto->hiHisPad

   IF ::cOpc == "I"
      mhiHisPad := "*NOVO*"
   ENDIF
   @ Row() + 1, 20 GET mhiHisPad PICTURE "@K 999999" VALID NovoMaiorZero( @mhiHisPad )
   Mensagem( "Digite código, F9 pesquisa, ESC volta" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. ( Val( mhiHisPad ) == 0 .AND. mhiHisPad != "*NOVO*" )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK mhiHisPad
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { mhiHisPad }

   RETURN .T.

METHOD TelaDados( lEdit ) CLASS CTHISTOClass

   LOCAL GetList := {}
   LOCAL mhiHisPad := cthisto->hiHisPad
   LOCAL mhiDescr1 := Substr( cthisto->hiDescri, 1, 90 )
   LOCAL mhiDescr2 := Substr( cthisto->hiDescri, 91, 90 )
   LOCAL mhiDescr3 := Substr( cthisto->hiDescri, 181, 90 )
   LOCAL mhiInfInc := cthisto->hiInfInc
   LOCAL mhiInfAlt := cthisto->hiInfAlt

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      mhiHisPad := ::axKeyValue[1]
   ENDIF
   DO WHILE .T.
      ::ShowTabs()
      DO CASE
      CASE ::nNumTab == 1
         @ Row()+1, 1  SAY "Código...........:" GET mhiHisPad  WHEN .F.
         @ Row()+2, 1  SAY "Histórico........:" GET mhiDescr1  PICTURE "@K!"    VALID ! Empty(mhiDescr1)
         @ Row()+1, 1  SAY "                 :" GET mhiDescr2  PICTURE "@K!"
         @ Row()+1, 1  SAY "                 :" GET mhiDescr3  PICTURE "@K!"
         @ Row()+2, 1  SAY "Inf.Inclusão.....:" GET mhiInfInc  WHEN .F.
         @ Row()+1, 1  SAY "Inf.Alteração....:" GET mhiInfAlt  WHEN .F.
         @ Row()+3, 1  SAY "Nos trechos a serem completados no momento da digitação, voce deve preencher com @@@@@@@@@@@@@@@."
         @ Row()+1, 1  SAY "A cada símbolo de @, corresponde a uma letra."
         @ Row()+1, 1  SAY "Para solicitar uma  data, por exemplo, você pode indicar @@/@@/@@."
      ENDCASE
      //SetPaintGetList( GetList )
      IF ! lEdit
         CLEAR GETS
         EXIT
      ENDIF
      Mensagem("Digite campos, F9 Pesquisa, ESC Sai")
      READ
      Mensagem()
      ::nNumTab += 1
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      IF ::nNumTab == Len(::acTabName) + 1
         EXIT
      ENDIF
   ENDDO
   IF ! lEdit
      RETURN NIL
   ENDIF
   IF LastKey() != K_ESC
      IF ::cOpc == "I"
         mhiHisPad := ::axKeyValue[1]
         IF mhiHisPad == "*NOVO*"
            mhiHisPad := NovoCodigo( "cthisto->hiHisPad" )
         ENDIF
         RecAppend()
         REPLACE ;
            cthisto->hiHisPad WITH mhiHisPad, ;
            cthisto->hiInfInc WITH LogInfo()
         RecUnlock()
      ENDIF
      RecLock()
      REPLACE cthisto->hiDescri WITH mhiDescr1 + mhiDescr2 + mhiDescr3
      IF ::cOpc == "A"
         REPLACE cthisto->hiInfAlt WITH LogInfo()
      ENDIF
      RecUnlock()
   ENDIF
   ::nNumTab := 1

   RETURN NIL

METHOD Valida( cCodigo, cTexto1, cTexto2, cTexto3, cTexto4, cTexto5 ) CLASS CTHISTOClass

   hb_Default( @cTexto1, Space(50) )
   hb_Default( @cTexto2, Space(50) )
   hb_Default( @cTexto3, Space(50) )
   hb_Default( @cTexto4, Space(50) )
   hb_Default( @cTexto5, Space(50) )
   cCodigo := StrZero( Val( cCodigo ), 6 )
   IF ! Encontra( cCodigo, "cthisto", "numlan" )
      MsgWarning( "Código não cadastrado!" )
      RETURN .F.
   ENDIF
   cTexto1 := Pad( Substr( cthisto->hiDescri, 1 ), Len( cTexto1 ) )
   cTexto2 := Pad( Substr( cthisto->hiDescri, Len( cTexto1 ) + 1 ), Len( cTexto2 ) )
   cTexto3 := Pad( Substr( cthisto->hiDescri, Len( cTexto1 + cTexto2 ) + 1 ), Len( cTexto3 ) )
   cTexto4 := Pad( Substr( cthisto->hiDescri, Len( cTexto1 + cTexto2 + cTexto3 ) + 1 ), Len( cTexto4 ) )
   cTexto5 := Pad( Substr( cthisto->hiDescri, Len( cTexto1 + cTexto2 + cTexto3 + cTexto4 ) + 1 ), Len( cTexto5 ) )

   RETURN .T.
