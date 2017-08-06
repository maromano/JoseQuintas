/*
PJPDOLAR - CADASTRO DE MOEDAS
1994.04 José Quintas
*/

#include "hbclass.ch"
#include "inkey.ch"

PROCEDURE PJPDOLAR

   LOCAL oFrm := JPDOLARClass():New()

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpconfi", "jpempre", "jpdolar" )
      RETURN
   ENDIF
   SELECT jpdolar
   oFrm:Execute()

   RETURN

CREATE CLASS JPDOLARClass INHERIT FrmCadastroClass

   METHOD Especifico( lExiste )
   METHOD TelaDados( lEdit )

   ENDCLASS

METHOD Especifico( lExiste ) CLASS JPDOLARClass

   LOCAL GetList := {}
   LOCAL mdlData := jpdolar->dlData

   IF ::cOpc == "I"
      mdlData := Date()
   ENDIF
   @ Row()+1, 20 GET mdlData VALID ! Empty( mdlData )
   Mensagem( "Digite data, F9 pesquisa, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Empty( mdlData )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK Dtos( mdlData )
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { mdlData }

   RETURN .T.

METHOD TelaDados( lEdit ) CLASS JPDOLARClass

   LOCAL GetList := {}
   LOCAL mdlData   := jpdolar->dlData
   LOCAL mdlValor  := jpdolar->dlValor

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      mdlData := ::axKeyValue[1]
   ENDIF
   DO WHILE .T.
      ::ShowTabs()
      DO CASE
      CASE ::nNumTab == 1
         @ Row()+1, 1  SAY "Data.............:" GET mdlData WHEN .F.
         @ Row()+2, 1  SAY "Valor............:" GET mdlValor PICTURE PicVal(14,2) VALID mdlValor > 0
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
      IF ::nNumTab == Len( ::acTabName ) + 1
         EXIT
      ENDIF
   ENDDO
   IF lEdit
      IF ::cOpc == "I" .AND. LastKey() != K_ESC .AND. Encontra( Dtos( mdlData ), "jpdolar", "data" )
         MsgWarning( "Já cadastrado valor para data/moeda informada" )
      ELSEIF LastKey() != K_ESC
         IF ::cOpc == "I"
            RecAppend()
            REPLACE ;
               jpdolar->dlData   WITH mdlData, ;
               jpdolar->dlInfInc WITH LogInfo()
            RecUnlock()
         ENDIF
         RecLock()
         REPLACE jpdolar->dlValor WITH mdlValor
         IF ::cOpc == "A"
            REPLACE jpdolar->dlInfAlt WITH LogInfo()
         ENDIF
         RecUnlock()
      ENDIF
      ::nNumTab := 1
   ENDIF

   RETURN NIL

FUNCTION DolarDoMes( nMes )

   LOCAL nValor, nAno, dData, nSelect := Select()

   IF Select( "JPDOLAR" ) == 0
      AbreArquivos( "jpdolar" )
   ENDIF

   nAno := jpempre->emAnoBase
   IF nMes == 0
      nAno -= 1
      nMes := 12
   ELSE
      DO WHILE nMes > 12
         nAno += 1
         nMes -= 12
      ENDDO
   ENDIF
   dData := UltDia( Ctod( "01/" + StrZero( nMes, 2 ) + "/" + StrZero( nAno, 4 ) ) )
   Encontra( Dtos( dData ), "jpdolar", "data" )
   nValor := jpdolar->dlValor
   SELECT ( nSelect )

   RETURN nValor
