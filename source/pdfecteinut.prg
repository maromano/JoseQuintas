/*
PDFECTEINUT - INUTILIZAR CTE
2017.01 Jos� Quintas
*/

#include "inkey.ch"

PROCEDURE pDfeCteInut

   LOCAL nNumDoc := 0, oXmlPdf, oSefaz := SefazClass():New(), cMotivo, cConfirma, GetList := {}

   IF AppEmpresaApelido() != "CARBOLUB"
      MsgExclamation( "Empresa n�o emite CTE" )
      RETURN
   ENDIF
   IF ! AbreArquivos( "jpempre" )
      RETURN
   ENDIF
   DO WHILE .T.
      @ 12, 10 SAY "N�mero do CTE:" GET nNumDoc PICTURE "@K 999999999" VALID nNumDoc > 0
      Mensagem( "Digite n�mero do CTE, ESC Sai" )
      READ
      Mensagem()
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      oXmlPdf := XmlPdfClass():New()
      oXmlPdf:GetFromMySql( "", StrZero( nNumDoc, 9 ), "57" )
      IF ! Empty( oXmlPdf:cXmlCancelamento )
         MsgExclamation( "CTE cancelado" )
         LOOP
      ENDIF
      IF ! Empty( oXmlPdf:cXmlEmissao )
         MsgExclamation( "CTE emitido" )
         LOOP
      ENDIF
      WOpen( 5, 5, 15, 90, "Inutiliza��o de CTE na Fazenda" )
      cMotivo   := Space(90)
      cConfirma := "NAO"
      @ 7, 7 SAY "Motivo (m�nimo de 15 letras):"
      @ 8, 7 GET cMotivo PICTURE "@!" VALID Len( Trim( cMotivo ) ) > 15
      @ 9, 7 SAY "Confirme fazer inutiliza��o:" GET cConfirma PICTURE "@!"
      Mensagem( "Digite dados para inutiliza��o" )
      READ
      Mensagem()
      WClose()
      IF LastKey() == K_ESC .OR. cConfirma != "SIM"
         LOOP
      ENDIF
      IF Len( Trim( cMotivo ) ) < 15
         MsgWarning( "Texto precisa no m�nimo 15 letras" )
         LOOP
      ENDIF
      oSefaz:CteInutiliza( "2017", SoNumeros( jpempre->emCnpj ), "57", "1", Ltrim( Str( nNumDoc ) ), Ltrim( Str( nNumDoc ) ), Trim( cMotivo ), "SP", AppEmpresaApelido(), "1" )
      IF oSefaz:cStatus == "102"
         hb_MemoWrit( hb_cwd() + "IMPORTA\CTE" + StrZero( nNumDoc, 9 ) + "-inutiliza.xml", oSefaz:cXmlAutorizado )
         MsgExclamation( "Inutiliza��o autorizada" )
      ELSE
         hb_MemoWrit( hb_cwd() + "NFE\CTE" + StrZero( nNumDoc, 9 ) + "-inutiliza-documento.xml", oSefaz:cXmlDocumento )
         hb_MemoWrit( hb_cwd() + "NFE\CTE" + StrZero( nNumDoc, 9 ) + "-inutiliza-retorno.xml", oSefaz:cXmlRetorno )
         Errorsys_WriteErrorLog( oSefaz:cXmlSoap, 3 )
         Errorsys_WriteErrorLog( oSefaz:cXmlRetorno )
         MsgExclamation( oSefaz:cXmlRetorno )
         MsgExclamation( "Erro na autoriza��o da inutiliza��o " + oSefaz:cStatus + " " + oSefaz:cMotivo )
      ENDIF
      EXIT
   ENDDO
   CLOSE DATABASES

   RETURN
