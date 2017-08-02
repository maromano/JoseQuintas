
#include "inkey.ch"

PROCEDURE ConsultaUmaUF

   LOCAL mcdUF := Space(2), GetList := {}

   IF ! AbreArquivos( "JPUF" )
      RETURN
   ENDIF
   DO WHILE .T.
      Mensagem( "Digite UF, F9 pesquisa, ESC sai" )
      @ 5, 0 SAY "UF:" GET mcdUF PICTURE "@!" VALID JPUFClass():Valida( mcdUF )
      READ
      Mensagem()
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      MsgExclamation( jpuf->ufDescri )
   ENDDO
   CLOSE DATABASES

   RETURN
