/*
PNFE0040 - CONSULTAR NFE NA SEFAZ
2012.07 José Quintas
*/

#include "inkey.ch"

PROCEDURE PNFE0040

   LOCAL cChave, oSefaz, GetList := {}

   DO WHILE .T.
      cChave := Space(44)
      @ 3, 0 SAY "Chave de acesso (ou numero da nota):" GET cChave PICTURE "@9"
      Mensagem( "Digite chave, ESC Sai" )
      READ
      Mensagem()
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      IF Len( SoNumeros( cChave ) ) > 0 .AND. Len( SoNumeros( cChave ) ) < 10
         cChave := "3516116833189100010055001" + StrZero( Val( SoNumeros( cChave ) ), 9 ) + ;
            "100000000"
         cChave := cChave + CalculaDigito( cChave, "11" )
      ENDIF
      IF Len( SoNumeros( cChave ) ) == 44
         oSefaz := SefazClass():New()
         MsgExclamation( oSefaz:NfeConsultaProtocolo( cChave, NomeCertificado( "CORDEIRO" ) ) )
      ENDIF
   ENDDO

   RETURN
