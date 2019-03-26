/*
ZE_SPEDXMLLIST - LISTA DE XMLS
2016.08 - Jos� Quintas

2018.03.14 Ajuste no XML devido a uso diferente pela Petrobras
2018.05.10 Corre��o ref XML de cancelamento
*/

#include "hbclass.ch"
#include "josequintas.ch"
#include "sefazclass.ch"
MEMVAR m_Prog

CREATE CLASS XmlPdfClass

   VAR cXmlEmissao      INIT ""
   VAR cXmlCancelamento INIT ""
   VAR cChave            INIT ""
   VAR nOrdem           INIT 0
   VAR aXmlEvento       INIT {}
   VAR aFileList        INIT {}
   METHOD GeraPdf( lShow, lWriteXml )
   METHOD GetFromMySql( cChave, cNotFis, cModFis, cEmitente )

   ENDCLASS

METHOD GeraPdf( lShow, lWriteXml ) CLASS XmlPdfClass

   LOCAL cLogoFile, cDesenvolvedor, oDanfe, cFilePDF, cXml, lShowAny := .F.

   hb_Default( @lShow, .T. )
   hb_Default( @lWriteXml, .F. )
   cLogoFile      := ze_RawImage( DfeEmitente( ::cChave ), .T. )
   cDesenvolvedor := "www.josequintas.com.br"

   IF Empty( ::cXmlEmissao )
      IF ! Empty( ::cXmlCancelamento )
         AAdd( ::aXmlEvento, ::cXmlCancelamento )
      ENDIF
   ENDIF
   IF Empty( ::cChave )
      MsgExclamation( "N�o localizada chave pra gera��o" )
      RETURN NIL
   ENDIF
   IF ! Empty( ::cXmlEmissao )
      oDanfe := hbNFeDaGeral():New()
      oDanfe:cLogoFile      := cLogoFile
      oDanfe:cDesenvolvedor := cDesenvolvedor
      oDanfe:ToPDF( ::cXmlEmissao, cFilePDF := AppTempPath() + ::cChave + ".PDF", ::cXmlCancelamento )
      IF File( cFilePdf )
         AAdd( ::aFileList, cFilePdf )
      ENDIF
      IF lWriteXml
         AAdd( ::aFileList, AppTempPath() + ::cChave + ".XML" )
         hb_MemoWrit( Atail( ::aFileList ), ::cXmlEmissao )
         IF ! Empty( ::cXmlCancelamento )
            AAdd( ::aFileList, AppTempPath() + ::cChave + "-110111.XML" )
            hb_MemoWrit( Atail( ::aFileList ), ::cXmlCancelamento )
         ENDIF
      ENDIF
      IF lShow
         ShellExecuteOpen( cFilePDF )
         lShowAny := .T.
      ENDIF
   ENDIF
   FOR EACH cXml IN ::aXmlEvento
      oDanfe := hbNFeDaEvento():New()
      oDanfe:cLogoFile      := cLogoFile
      oDanfe:cDesenvolvedor := cDesenvolvedor
      oDanfe:ToPDF( cXml, cFilePDF := AppTempPath() + ::cChave + "-" + StrZero( cXml:__EnumIndex, 2 ) + "-" + XmlToDoc( cXml ):cEvento +  ".PDF", ::cXmlEmissao )
      IF File( cFilePdf )
         AAdd( ::aFileList, cFilePDF )
      ENDIF
      IF lWriteXml
         AAdd( ::aFileList, AppTempPath() + ::cChave + "-" + StrZero( cXml:__EnumIndex, 2 ) + "-" + XmlToDoc( cXml ):cEvento  + ".XML" )
         hb_MemoWrit( Atail( ::aFileList ), cXml )
      ENDIF
      IF lShow
         ShellExecuteOpen( cFilePDF )
         lShowAny := .T.
      ENDIF
   NEXT
   IF lShow .AND. ! lShowAny
      MsgExclamation( "Nada encontrado para ser mostrado" )
   ENDIF

   RETURN NIL

METHOD GetFromMySql( cChave, cNotFis, cModFis, cEmitente ) CLASS XmlPdfClass

   LOCAL cnMySql

   IF AppcnMySqlLocal() == NIL .OR. m_Prog == "PDFESERVER" .OR. IsMaquinaJPA() // servidor JPA
      cnMySql := ADOClass():New( AppcnServerJPA() )
   ELSE
      cnMySql := ADOClass():New( AppcnMySqlLocal() )
   ENDIF

   ::cChave := cChave
   IF Empty( ::cChave )
      cnMySql:cSql := "SELECT * FROM JPNFEKEY WHERE KKNOTFIS=" + StringSql( StrZero( Val( cNotFis ), 9 ) ) + " AND KKMODFIS=" + StringSql( StrZero( Val( cModFis ), 2 ) )
      IF cEmitente == NIL
         cnMySql:cSql += " AND KKEMINFE=" + StringSql( jpempre->emCnpj )
      ELSE
         cnMySql:cSql += " AND KKEMINFE=" + StringSql( cEmitente ) + " AND KKDESNFE=" + StringSql( jpempre->emCnpj )
      ENDIF
      cnMySql:Execute()
      IF ! cnMySql:Eof()
         ::cChave := cnMySql:StringSql( "KKCHAVE" )
      ENDIF
      cnMySql:CloseRecordset()
   ENDIF
   IF ! Empty( ::cChave )
      cnMySql:cSql := "SELECT * FROM JPXML20" + Substr( ::cChave, 3, 2 ) + " WHERE XXCHAVE=" + StringSql( ::cChave )
      cnMySql:Execute()
      DO WHILE ! cnMySql:Eof()
         DO CASE
         CASE cnMySql:StringSql( "XXEVENTO" ) == "110100"
            ::cXmlEmissao := XML_UTF8 + XmlTransform( cnMySql:StringSql( "XXXML" ) )
         CASE cnMySql:StringSql( "XXEVENTO" ) == "110111"
            ::cXmlCancelamento := XML_UTF8 + XmlTransform( cnMySql:StringSql( "XXXML" ) )
         CASE Pad( cnMySql:StringSql( "XXEVENTO" ), 6 ) $ "110110,110112"
            AAdd( ::aXmlEvento, XML_UTF8 + XmlTransform( cnMySql:StringSql( "XXXML" ) ) )
            ::nOrdem := Max( ::nOrdem, cnMySql:NumberSql( "XXORDEM" ) )
         ENDCASE
         cnMySql:MoveNext()
      ENDDO
      cnMySql:CloseRecordset()
   ENDIF

   RETURN NIL
