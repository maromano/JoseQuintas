/*
PCONTEMITIDOS - RELATORIOS EMITIDOS
1992.07 José Quintas
*/

#include "inkey.ch"

PROCEDURE pContEmitidos

   LOCAL GetList := {}, acConfiguracao := Array(9), nCont, memRelEmi

   IF ! AbreArquivos( "jpempre" )
      RETURN
   ENDIF
   SELECT jpempre

   acConfiguracao[ 1 ] := Val( Substr( jpempre->emRelEmi,  1, 2 ) )
   acConfiguracao[ 2 ] := Val( Substr( jpempre->emRelEmi,  4, 2 ) )
   acConfiguracao[ 3 ] := Val( Substr( jpempre->emRelEmi,  7, 2 ) )
   acConfiguracao[ 4 ] := Val( Substr( jpempre->emRelEmi, 10, 2 ) )
   acConfiguracao[ 5 ] := Val( Substr( jpempre->emRelEmi, 13, 2 ) )
   acConfiguracao[ 6 ] := 0 // não existe mais
   acConfiguracao[ 7 ] := Val( Substr( jpempre->emRelEmi, 19, 2 ) )
   acConfiguracao[ 8 ] := Val( Substr( jpempre->emRelEmi, 22, 2 ) )
   acConfiguracao[ 9 ] := Val( Substr( jpempre->emRelEmi, 25, 2 ) )

   DO WHILE .T.
      @  5, 10 SAY "Próximas emissões:"
      @  8, 2 SAY "Livro Diário..............:" GET acConfiguracao[ 1 ] PICTURE "99" VALID ConfigOk( @acConfiguracao[ 1 ] )
      @ 10, 2 SAY "Livro Razão...............:" GET acConfiguracao[ 2 ] PICTURE "99" VALID ConfigOk( @acConfiguracao[ 2 ] )
      @ 12, 2 SAY "Desp.p/ C.Custo Analítico.:" GET acConfiguracao[ 3 ] PICTURE "99" VALID ConfigOk( @acConfiguracao[ 3 ] )
      @ 14, 2 SAY "Desp.p/ C.Custo Resumido..:" GET acConfiguracao[ 4 ] PICTURE "99" VALID ConfigOk( @acConfiguracao[ 4 ] )
      @ 16, 2 SAY "Retrospectiva de Contas...:" GET acConfiguracao[ 5 ] PICTURE "99" VALID ConfigOk( @acConfiguracao[ 5 ] )
      @ 18, 2 SAY "Balancete.................:" GET acConfiguracao[ 7 ] PICTURE "99" VALID ConfigOk( @acConfiguracao[ 7 ] )
      @ 20, 2 SAY "Demonstração de Resultado.:" GET acConfiguracao[ 8 ] PICTURE "99" VALID ConfigOk( @acConfiguracao[ 8 ] )
      @ 22, 2 SAY "Balanço Patrimonial.......:" GET acConfiguracao[ 9 ] PICTURE "99" VALID ConfigOk( @acConfiguracao[ 9 ] )
      Mensagem( "Digite campos (meses 01 a " + StrZero( 96 + 1, 2 ) + "), ESC sai" )
      READ
      Mensagem()
      IF LastKey() == K_ESC
         CLOSE DATABASES
         EXIT
      ENDIF
      memRelEmi := ""
      FOR nCont = 1 TO 9
         memRelEmi += StrZero( acConfiguracao[ nCont ], 2 ) + ","
      NEXT
      SELECT jpempre
      RecLock()
      REPLACE jpempre->emRelEmi WITH memRelEmi
      RecUnlock()
      EXIT
   ENDDO
   CLOSE DATABASES

   RETURN

STATIC FUNCTION ConfigOk( nValue )

   IF nValue < 1 .OR. nValue > 97
      MsgWarning( "Mes inválido" )
      RETURN .F.
   ENDIF

   RETURN .T.
