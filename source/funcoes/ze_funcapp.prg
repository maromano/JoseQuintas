/*
ZE_FUNCAPP - FUNCOES DO SISTEMA
1995.04.07

...
*/

#include "inkey.ch"

FUNCTION TxtConf()

   RETURN { "Sim", "Não" }

FUNCTION TxtImprime()

   RETURN "Impressão do relatório"

FUNCTION TxtSalva()

   RETURN "Salva Configuração Default"

FUNCTION DataIntervalo( nLini, nColi, nOpc, dDatai, dDataf, lAuto, cTitulo )

   LOCAL nLinf := nLini + 4
   LOCAL nColf := nColi + 40
   LOCAL acTxtOpc := { "Todas", "Intervalo" }
   LOCAL GetList := {}

   hb_Default( @cTitulo, "Data(s)" )
   hb_Default( @lAuto, .F. )
   IF dDataf == NIL
      acTxtOpc := { "Todas", "Específica" }
   ENDIF
   WOpen( nLini, nColi, nLinf, nColf, cTitulo )
   DO WHILE .T.
      IF ! lAuto
         FazAchoice( nLini + 2, nColi + 1, nLinf - 1, nColf - 1, @acTxtOpc, @nOpc )
      ENDIF
      IF LastKey() != K_ESC .AND. nOpc == 2
         WOpen( nLini + 3, nColi + 5, nLini + 7, nColi + 45, cTitulo )
         @ nLini + 5, nColi + 7 GET dDatai
         IF dDataf != NIL
            @ nLini + 6, nColi + 7 GET dDataf
         ENDIF
         Mensagem( "Digite data(s), ESC sai" )
         READ
         WClose()
         IF LastKey() == K_ESC
            IF lAuto
               EXIT
            ENDIF
            LOOP
         ENDIF
      ENDIF
      EXIT
   ENDDO
   WClose()

   RETURN NIL

FUNCTION UfIbge( mUf )

   Encontra( mUf, "jpcidade", "jpcidade3" )

   RETURN Substr( jpcidade->ciIbge, 1, 2 )

FUNCTION CidadeIbge( mCidade, mUf )

   Encontra( mUf + Trim( mCidade ), "jpcidade", "jpcidade3" )

   RETURN jpcidade->ciIbge

