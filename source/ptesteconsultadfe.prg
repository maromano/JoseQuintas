/*
PTESTECONSULTADFE - CONSULTAR DFE NA SEFAZ
2012.07 José Quintas
*/

#include "inkey.ch"

PROCEDURE pTesteConsultaDfe

   LOCAL cChave, oSefaz, GetList := {}

   IF ! AbreArquivos( "jpempre" )
      RETURN
   ENDIF
   oSefaz := SefazClass():New()
   oSefaz:cCertificado := NomeCertificado( "CARBOLUB" )
   oSefaz:CTeConsultaRecibo( "351000533683863" )
   MsgExclamation( oSefaz:cXmlRetorno )

   IF .T.
      RETURN
   ENDIF





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
         IF Substr( cChave, 23, 2 ) == "55"
            MsgExclamation( oSefaz:NfeConsultaProtocolo( cChave, NomeCertificado( AppEmpresaApelido() ) ) )
         ELSE
            MsgExclamation( oSefaz:MdfeConsultaProtocolo( cChave, NOmeCertificado( AppEmpresaApelido() ) ) )
            hb_MemoWrit( "d:\temp\teste.xml", oSefaz:CXmlRetorno )
            //IF MsgYesNo( "Cancela?" )
            //   oSefaz := SefazClass():New()
            //   oSefaz:MDFeEventoCancela( ;
            //      cChave, ;
            //      1, ;
            //      935170020402852, ;
            //      "Problemas com Sefaz", ;
            //      NomeCertificado( AppEmpresaApelido() ) )
            //   hb_MemoWrit( "d:\temp\teste2.xml", oSefaz:cXmlRetorno )
            //ENDIF
         ENDIF
         hb_MemoWrit( "d:\temp\ptesteconsultadfe.xml", oSefaz:cXmlRetorno )
      ENDIF
   ENDDO
   CLOSE DATABASES

   RETURN
