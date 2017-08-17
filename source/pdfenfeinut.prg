/*
PDFENFEINUT - INUTILIZAR NFE
2017.01.10 José Quintas
2017.05.31.0930 - Ano com 2 dígitos
*/

#include "inkey.ch"

PROCEDURE pDfeNfeInut

   LOCAL nNumDoc := 0, oXmlPdf, oSefaz := SefazClass():New(), cMotivo, cConfirma, GetList := {}

   IF ! AbreArquivos( "jpempre" )
      RETURN
   ENDIF
   DO WHILE .T.
      @ 12, 10 SAY "Número da NFE:" GET nNumDoc PICTURE "@K 999999999" VALID nNumDoc > 0
      Mensagem( "Digite número do NFE, ESC Sai" )
      READ
      Mensagem()
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      oXmlPdf := XmlPdfClass():New()
      oXmlPdf:GetFromMySql( "", StrZero( nNumDoc, 9 ), "5" )
      IF ! Empty( oXmlPdf:cXmlCancelamento )
         MsgExclamation( "NFE já cancelada" )
         LOOP
      ENDIF
      IF ! Empty( oXmlPdf:cXmlEmissao )
         MsgExclamation( "NFE emitida" )
         LOOP
      ENDIF
      WOpen( 5, 5, 15, 90, "Inutilização de NFE na Fazenda" )
      cMotivo   := Space(90)
      cConfirma := "NAO"
      @ 7, 7 SAY "Motivo (mínimo de 15 letras):"
      @ 8, 7 GET cMotivo PICTURE "@!" VALID Len( Trim( cMotivo ) ) > 15
      @ 9, 7 SAY "Confirme fazer inutilização:" GET cConfirma PICTURE "@!"
      Mensagem( "Digite dados para inutilização" )
      READ
      Mensagem()
      WClose()
      IF LastKey() == K_ESC .OR. cConfirma != "SIM"
         LOOP
      ENDIF
      IF Len( Trim( cMotivo ) ) < 15
         MsgWarning( "Texto precisa no mínimo 15 letras" )
         LOOP
      ENDIF
      oSefaz:NFeInutiliza( Right( StrZero( Year( Date() ), 4 ), 2 ), SoNumeros( jpempre->emCnpj ), "55", "1", Ltrim( Str( nNumDoc ) ), Ltrim( Str( nNumDoc ) ), Trim( cMotivo ), "SP", AppEmpresaApelido(), "1" )
      IF oSefaz:cStatus == "102"
         hb_MemoWrit( hb_cwd() + "IMPORTA\NFE" + StrZero( nNumDoc, 9 ) + "-inutiliza.xml", oSefaz:cXmlAutorizado )
         MsgExclamation( "Inutilização autorizada" )
      ELSE
         hb_MemoWrit( hb_cwd() + "NFE\NFE" + StrZero( nNumDoc, 9 ) + "-inutiliza-documento.xml", oSefaz:cXmlDocumento )
         hb_MemoWrit( hb_cwd() + "NFE\NFE" + StrZero( nNumDoc, 9 ) + "-inutiliza-retorno.xml", oSefaz:cXmlRetorno )
         hb_MemoWrit( hb_cwd() + "NFE\NFE" + StrZero( nNumDoc, 9 ) + "-inutiliza-autorizado.xml", oSefaz:cXmlAutorizado )
         MsgExclamation( oSefaz:cXmlRetorno )
         MsgExclamation( "Erro na autorização da inutilização " + oSefaz:cStatus + " " + oSefaz:cMotivo )
      ENDIF
      EXIT
   ENDDO
   CLOSE DATABASES

   RETURN
