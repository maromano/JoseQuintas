/*
ZE_WEBSER - FUNCOES DE WEBSERVICE
2012.05.31 - JosÈ Quintas

...
*/


/*
Estrutura do CEP

1 - Regi„o
2 - Sub-regi„o
3 - Setor
4 - Subsetor
5 - Divis„o de sub-setor
6,7,8 - identificadores de distribuiÁ„o ( sufixo )

- CEPs especiais sufixo 900 a 959
- CEPs promocionais sufixo 960 a 969
- CEPs de unidades do correio sufixos 970 a 989 e 999
- CEPs de caixas postais comunitarias 990 a 998


*/

FUNCTION CepOk( mCep, mEndereco, mBairro, mCidade, mUf, mPesquisa )

   LOCAL mTexto

   hb_Default( @mPesquisa, .T. )
   IF Val( SoNumeros( mCep ) ) == 0 .OR. ! mPesquisa
      RETURN .T.
   ENDIF
   mTexto := WebCep( mCep )
   mUf       := Pad( XmlNode( mTexto, "UF" ), 2 )
   mCidade   := Pad( XmlNode( mTexto, "CIDADE" ), Len( mCidade ) )
   mBairro   := Pad( XmlNode( mTexto, "BAIRRO" ), Len( mBairro ) )
   mEndereco := Pad( XmlNode( mTexto, "LOGRADOURO" ), Len( mEndereco ) )

   RETURN .T.

FUNCTION WebCep( cCep )

   LOCAL cTexto

   WSave()
   Mensagem( "Consultando CEP nos correios, ESC abandona" )
   cTexto := DownloadTexto( ;
      "http://www.josequintas.com.br/cep.asp" + ;
      "?cep=" + cCep + ;
      "&usuario=" + Trim( AppUserName() ) + ;
      "&maquina=" + DriveSerial() + ;
      "&empresa=" + Trim( AppEmpresaApelido() ) )
   WRestore()
   cTexto := iif( ValType( cTexto ) == "C", cTexto, "" )
   cTexto := Upper( TiraAcento( cTexto ) )

   RETURN cTexto

FUNCTION TiraAcento( cTexto )

   LOCAL acLetras := {}, nCont, nPosicao

   AAdd( acLetras, { "Ä", "C" } )
   AAdd( acLetras, { "á", "C" } )
   AAdd( acLetras, { "†", "A" } )
   AAdd( acLetras, { "µ", "A" } )
   AAdd( acLetras, { "∆", "A" } )
   AAdd( acLetras, { "«", "A" } )
   AAdd( acLetras, { "°", "I" } )
   AAdd( acLetras, { "÷", "I" } )
   AAdd( acLetras, { "¢", "O" } )
   AAdd( acLetras, { "‡", "O" } )
   AAdd( acLetras, { "£", "U" } )
   AAdd( acLetras, { "È", "E" } )
   AAdd( acLetras, { "Ç", "E" } )
   AAdd( acLetras, { "ê", "E" } )
   AAdd( acLetras, { "∫", "." } )
   AAdd( acLetras, { "'", " " })
   AAdd( acLetras, { "„", "A" } )
   AAdd( acLetras, { "·", "A" } )
   AAdd( acLetras, { "Á", "C" } )
   AAdd( acLetras, { "È", "E" } )
   AAdd( acLetras, { "Í", "E" } )
   AAdd( acLetras, { "Ì", "I" } )
   AAdd( acLetras, { "Û", "O" } )
   AAdd( acLetras, { "Ù", "O" } )
   AAdd( acLetras, { "˙", "U" } )
   AAdd( acLetras, { "‚", "A" } )
   AAdd( acLetras, { "¡", "A" } )
   AAdd( acLetras, { "ı", "O" } )
   AAdd( acLetras, { "…", "E" } )
   AAdd( acLetras, { "Õ", "I" } )
   AAdd( acLetras, { "«", "C" } )
   AAdd( acLetras, { " ", "E" } )
   AAdd( acLetras, { "”", "O" } )
   AAdd( acLetras, { "‘", "O" } )
   AAdd( acLetras, { "’", "O" } )
   AAdd( acLetras, { "⁄", "U" } )
   AAdd( acLetras, { "•", "N" } )
   AAdd( acLetras, { "√", "A" } )
   AAdd( acLetras, { "¡", "A" } )
   AAdd( acLetras, { "¬", "A" } )
   AAdd( acLetras, { "¿", "A" } )
   AAdd( acLetras, { "‚", "A" } )
   AAdd( acLetras, { "‹", "U" } )
   AAdd( acLetras, { "¸", "U" } )
   AAdd( acLetras, { "+", " " } )
   AAdd( acLetras, { "`", " " } )
   AAdd( acLetras, { "—", "N" } )
   AAdd( acLetras, { "»", "E" } )
   AAdd( acLetras, { "™", "A" } )
   AAdd( acLetras, { "∫", "O" } )
   AAdd( acLetras, { "™", "." } )
   AAdd( acLetras, { "ß", "" } )
   FOR nCont = 1 TO Len( acLetras )
      DO WHILE acLetras[ nCont, 1 ] $ cTexto
         nPosicao := At( acLetras[ nCont, 1 ], cTexto )
         cTexto := Substr( cTexto, 1, nPosicao - 1 ) + acLetras[ nCont, 2 ] + Substr( cTexto, nPosicao + 1 )
      ENDDO
   NEXT
   cTexto := Upper( cTexto ) // Acrescentado

   RETURN cTexto

FUNCTION DownloadFile( cUrl, cFile )

   LOCAL oSoap, aRetorno, nHandle, nAscii, lOk

   lOk := .F.
   BEGIN SEQUENCE WITH __BreakBlock()
      oSoap := Win_OleCreateObject( "MSXML2.ServerXMLHTTP" )
      oSoap:Open( "GET", cUrl, .F. )
      oSoap:Send()
      aRetorno := oSoap:ResponseBody()
      nHandle := fCreate( cFile )
      IF ValType( aRetorno ) == "C"
         fWrite( nHandle, aRetorno )
      ELSE
         FOR EACH nAscii IN aRetorno
            fWrite( nHandle, Chr( nAscii ) )
         NEXT
      ENDIF
      fClose( nHandle )
      lOk := .T.
   ENDSEQUENCE

   RETURN lOk

FUNCTION DownloadTexto( cUrl )

   LOCAL oSoap, cRetorno, aRetorno, nAscii

   cRetorno := ""
   BEGIN SEQUENCE WITH __BreakBlock()
      oSoap := Win_OleCreateObject( "MSXML2.ServerXMLHTTP" )
      oSoap:Open( "GET", cUrl, .F.)
      oSoap:Send()
      aRetorno := oSoap:ResponseBody()
      IF ValType( aRetorno ) == "C"
         cRetorno := aRetorno
      ELSE
         cRetorno := ""
         FOR EACH nAscii IN aRetorno
            cRetorno += Chr( nAscii )
         NEXT
      ENDIF
   ENDSEQUENCE

   RETURN cRetorno

FUNCTION SiteCnpjFazenda( cCnpj )

   LOCAL cUrl

   //cUrl := ["c:\Arquivos de Programas\Internet Explorer\iExplore.exe" ] + ;
   cUrl := [http://www.receita.fazenda.gov.br/PessoaJuridica/CNPJ/cnpjreva/Cnpjreva_Solicitacao2.asp?cnpj=] + ;
      StrZero( Val( cCnpj ), 14 )
//   RUN ( "cmd /c START " + cUrl )
   ShellExecuteOpen( cUrl )

   RETURN NIL

FUNCTION WebCotacao( dData )

   LOCAL cUrl, nVlDolar := 0

   cUrl := "http://cotacao.republicavirtual.com.br/web_cotacao.php?formato=xml"
   cUrl +=  "?vldolar=" + Dtoc( dData )
   //
   // <?xml version="1.0" encoding="iso-8859-1"?>
   // <webservicecotacao>
   // <dolar_comercial_compra>2,1260</dolar_comercial_compra>
   // <dolar_comercial_venda>2,1280</dolar_comercial_venda>
   // <dolar_paralelo_compra>2,2200</dolar_paralelo_compra>
   // <dolar_paralelo_venda>2,3000</dolar_paralelo_venda>
   // <euro_dolar_compra>1,2410</euro_dolar_compra>
   // <euro_dolar_venda>1,2410</euro_dolar_venda>
   // <euro_real_compra>2,6384</euro_real_compra>
   // <euro_real_venda>2,6408</euro_real_venda>
   // </webservicecotacao>

   RETURN nVlDolar

/*
FUNCTION DownloadTexto( cUrl )

   LOCAL oFileContent := "", oHttp

   BEGIN SEQUENCE WITH __BreakBlock()
      oHttp := TIPClientHttp():New( cUrl )
      oHttp:Open()
//      oHttp:ExGauge := { | done, size | GrafTempo( Done, Size ) } // nao funciona se nao souber o tamanho
      oFileContent := oHttp:ReadAll()
      oHttp:Close()
   ENDSEQUENCE
   RETURN oFileContent
*/
