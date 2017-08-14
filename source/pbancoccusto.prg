/*
PBANCOCCUSTO - CADASTRO DE RESUMOS / GRUPOS
1994.04 José Quintas
*/

#include "hbclass.ch"
#include "inkey.ch"

PROCEDURE pBancoCCusto

   LOCAL oFrm := BancoCCustoClass():New()

   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi", "jpbaauto", "jpbagrup", "jpbamovi" )
      RETURN
   ENDIF
   SELECT jpbagrup
   oFrm:Execute()

   RETURN

CREATE CLASS BancoCCustoClass INHERIT FrmCadastroClass

   METHOD Especifico(lExiste)
   METHOD TelaDados(lEdit)

   ENDCLASS

METHOD Especifico( lExiste ) CLASS BancoCCustoClass

   LOCAL GetList := {}, mbgResumo

   mbgResumo := jpbagrup->bgResumo
   @ Row() + 1, 20 GET mbgResumo PICTURE "@K!" VALID ! Empty( mbgResumo )
   Mensagem( "Digite código para cadastro, F9 Pesquisa, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. Empty( mbgResumo )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK mbgResumo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { mbgResumo }

   RETURN .T.

METHOD TelaDados( lEdit ) CLASS BancoCCustoClass

   LOCAL GetList := {}
   LOCAL mbgGrupo  := jpbagrup->bgGrupo
   LOCAL mbgResumo := jpbagrup->bgResumo

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      mbgResumo := ::axKeyValue[1]
   ENDIF

   DO WHILE .T.
      ::ShowTabs()
      DO CASE
      CASE ::nNumTab == 1
         @ Row() + 1, 1 SAY "Resumo...........:" GET mbgResumo PICTURE "@K!" WHEN .F.
         @ Row() + 2, 1 SAY "Grupo............:" GET mbgGrupo  PICTURE "@K!"
      ENDCASE
      //SetPaintGetList( GetList )
      IF lEdit
         Mensagem( "Digite campos, F9 Pesquisa, ESC Sai" )
         READ
         Mensagem()
      ELSE
         CLEAR GETS
         EXIT
      ENDIF
      ::nNumTab += 1
      IF LastKey() == K_ESC .OR. ::nNumTab > 1
         EXIT
      ENDIF
   ENDDO
   IF lEdit
      IF LastKey() != K_ESC
         IF ::cOpc == "I"
            mbgResumo := ::axKeyValue[1]
            IF Substr(mbgResumo,1,6) == "*NOVO*"
               //
            ENDIF
            RecAppend()
            REPLACE ;
               jpbagrup->bgResumo WITH mbgResumo, ;
               jpbagrup->bgInfInc WITH LogInfo()
            RecUnlock()
         ENDIF
         RecLock()
         REPLACE jpbagrup->bgGrupo WITH mbgGrupo
         IF ::cOpc == "A"
            REPLACE jpbaGrup->bgInfAlt WITH LogInfo()
         ENDIF
         RecUnlock()
      ENDIF
      ::nNumTab := 1
   ENDIF

   RETURN NIL

FUNCTION ValidBancarioResumo( cResumo )

   LOCAL lOk := .T.
   MEMVAR m_Prog

   DO CASE
   CASE cResumo == Pad( "APLIC", 10 )
   CASE cResumo == Pad( "NENHUM", 10 )
   CASE Empty( cResumo ) .AND. m_Prog != "PBANCOGRAFICOMES" .AND. ReadVar() != "M_RESUMO1"
   CASE ! Encontra( cResumo, "jpbagrup" )
      MsgWarning( "Resumo bancário não cadastrado!" )
      lOk := .F.
   ENDCASE

   RETURN lOk
