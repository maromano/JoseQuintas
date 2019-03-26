/*
PTESVALIDAXML - Validar XML
*/

#define VALIDA_PATH_ROOT "d:\cdrom\fontes\integra\schemmas\"

#define VALIDA_PATH_NFE    VALIDA_PATH_ROOT + "PL_008i2_CFOP_EXTERNO\"
#define VALIDA_PATH_NFECAN VALIDA_PATH_ROOT + "Evento_Can_PL_v1.01\"
#define VALIDA_PATH_NFECCE VALIDA_PATH_ROOT + "Evento_CCe_PL_v1.01\"
#define VALIDA_PATH_CTE    VALIDA_PATH_ROOT + "PL_CTe_300_NT2017.002\"
//#define VALIDA_PATH_MDFE   VALIDA_PATH_ROOT + "PL_MDFe_300_NT032017\"
#define VALIDA_PATH_MDFE   VALIDA_PATH_ROOT + "PL_MDFe_300_NT022018\"
#define VALIDA_PATH_DIST   VALIDA_PATH_ROOT + "PL_NFeDistDFe_102\"
#define VALIDA_PATH_NFE4   VALIDA_PATH_ROOT + "PL_009_V4\"

PROCEDURE PTESValidaXml

   LOCAL cRetorno, cFileXsd, cXml, oDoc

   cXml := MemoRead( "d:\temp\teste.xml" )
   Mensagem( "Tecle ENTER", " 13" )
   oDoc := XmlToDoc( cXml )
   DO CASE
   CASE .F.
      SayScroll( "Envio CTE" )
      cFileXsd := VALIDA_PATH_CTE + "enviCTE_v3.00.xsd"
   CASE oDoc:cModFis == "55" .AND. oDoc:cEvento == "110100"
      SayScroll( "NFE emiss�o" )
      cFileXsd := VALIDA_PATH_NFE    + "nfe_v3.10.xsd"
   CASE oDoc:cModFis == "55" .AND. oDoc:cEvento == "110111"
      SayScroll( "NFE Evento Cancela" )
      cFileXsd := VALIDA_PATH_NFECAN + "eventoCancNFe_v1.00.xsd"
   CASE oDoc:cModFis == "55" .AND. oDoc:cEvento == "110110"
      SayScroll( "NFE Evento Carta de Corre��o" )
      cFileXsd := VALIDA_PATH_NFECCE + "CCe_v1.00.xsd"

   CASE oDoc:cModFis == "57" .AND. oDoc:cEvento == "110100"
      SayScroll( "CTE emiss�o" )
      cFileXsd := VALIDA_PATH_CTE    + "cte_v3.00.xsd"
   CASE oDoc:cModFis == "57" .AND. oDoc:cEvento == "110111"
      SayScroll( "CTE evento" )
      cFileXsd := VALIDA_PATH_CTE    + "eventoCTe_v3.00.xsd"

   CASE oDoc:cModFis == "58" .AND. oDoc:cEvento == "110100"
      SayScroll( "MDFE Emiss�o" )
      cFileXsd := VALIDA_PATH_MDFE   + "mdfe_v3.00.xsd"
   CASE oDoc:cModFis == "58" .AND. oDoc:cEvento == "110111"
      SayScroll( "MDFE Evento" )
      cFileXsd := VALIDA_PATH_MDFE   + "eventoMDFe_v3.00.xsd"
   CASE oDoc:cModFis == "58" .AND. oDoc:cEvento == "110112"
      SayScroll( "MDFE Evento Encerra" )
      cFileXsd := VALIDA_PATH_MDFE   + "eventoMDFe_v3.00.xsd"

      // N�o ser� acionado se a 3.10 estiver ativa
   CASE oDoc:cModFis == "55" .AND. oDoc:cEvento == "110100"
      SayScroll( "NFE 4.0 Emiss�o" )
      cFileXsd := VALIDA_PATH_NFE4   + "nfe_v4.00.xsd"

   OTHERWISE
      SayScroll( "XML n�o reconhecido tipo " + oDoc:cModFis + " evento " + oDoc:cEvento )
      cFileXsd := VALIDA_PATH_MDFE + "mdfe_v3.00.xsd"
   ENDCASE

   cRetorno := SefazClass():ValidaXml( cXml, cFileXsd )
   SayScroll( cRetorno )
   Inkey(0)

   RETURN
