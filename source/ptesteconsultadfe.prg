/*
PTESTECONSULTADFE - CONSULTAR DFE NA SEFAZ
2012.07 José Quintas
*/

#include "inkey.ch"

PROCEDURE pTesteConsultaDfe

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
         cChave := "351611" + SoNumeros( jpempre->EmCnpj ) + "55001" + StrZero( Val( SoNumeros( cChave ) ), 9 ) + ;
            "100000000"
         cChave := cChave + CalculaDigito( cChave, "11" )
      ENDIF
      IF Len( SoNumeros( cChave ) ) == 44
         oSefaz := SefazClass():New()
         MsgExclamation( oSefaz:NfeConsultaProtocolo( cChave, NomeCertificado( AppEmpresaApelido() ) ) )
      ENDIF
   ENDDO

   RETURN
