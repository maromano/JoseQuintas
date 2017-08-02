/*
HTMLTOPRG - Converte do site da Fazenda pra fonte PRG
José Quintas
*/

REQUEST HB_CODEPAGE_PTISO

PROCEDURE Main

   LOCAL cXml, cXmlTabela, cXmlRow, cXmlColList, cCest, aNcm, cDesc, oElement, cTxt := ""

   Set( _SET_CODEPAGE, "PTISO" )
   CLS
   cXml := DownloadFazenda()
   // Retira anexo
   //cXml := Substr( cXml, 1, At( [VENDA DE MERCADORIAS PELO SISTEMA PORTA A PORTA], cXml ) )
   //
   cTxt := [FUNCTION CestList()] + hb_Eol() + hb_Eol()
   cTxt += [   LOCAL aList := {}] + hb_Eol() + hb_Eol()
   FOR EACH cXmlTabela IN MultipleNodeToArray( cXml, "table" )
      FOR EACH cXmlRow IN MultipleNodeToArray( cXmlTabela, "tr" )
         cXmlColList := MultipleNodeToArray( cXmlRow, "td" )
         IF Len( cXmlColList ) != 4 // Titulos
            ? cXmlColList
         ELSE
            cCest := XmlNode( cXmlColList[ 2 ], "p" )
            IF Len( SoNumeros( cCest ) ) != 0
               aNcm  := PegaNcm( cXmlColList[ 3 ] )
               cDesc := XmlNode( cXmlColList[ 4 ], "p" )
               FOR EACH oElement IN aNcm
                  cTxt += [   Aadd( aList, { ]
                  cTxt += ["] + SoNumeros( cCest ) + [", ]
                  cTxt += ["] + Pad( SoNumeros( oElement ), 8, "X" ) + [", ]
                  cTxt += ["] + AllTrim( StrTran( cDesc, ["], "" ) ) + [" } )]
                  cTxt += hb_Eol()
               NEXT
            ENDIF
         ENDIF
      NEXT
   NEXT
   cTxt += hb_Eol() + [   RETURN aList] + hb_Eol()
   Ajusta( @cTxt )
   hb_MemoWrit( "teste.prg", cTxt )

   RETURN

FUNCTION PegaNcm( cXmlNcm )

   LOCAL cXmlBloco, cTxt := "", aNcmList, cNcm

   FOR EACH cXmlBloco IN MultipleNodeToArray( cXmlNcm, "p" )
      cTxt += " " + StrTran( cXmlBloco, "<br>", " " )
   NEXT
   aNcmList := hb_RegExSplit( " ", cTxt )
   FOR EACH cNcm IN aNcmList DESCEND
      cNcm := AllTrim( cNcm )
      IF Empty( cNcm ) .AND. Len( aNcmList ) > 1
         hb_Adel( aNcmList, cNcm:__EnumIndex, .T. )
      ENDIF
   NEXT

   RETURN aNcmList

FUNCTION DownloadFazenda()

   LOCAL oSoap, cRetorno
   LOCAL cUrl := [https://www.confaz.fazenda.gov.br/legislacao/convenios/2017/CV052_17]

   oSoap := win_OleCreateObject( "MSXML2.ServerXMLHTTP" )
   oSOap:Open( "GET", cUrl, .F. )
   oSoap:Send()
   cRetorno := oSoap:ResponseBody()

   RETURN cRetorno

FUNCTION Ajusta( cTxt )

   LOCAL cLetra

   cTxt := StrTran( cTxt, Chr(195) + Chr(162), "a" )
   cTxt := StrTran( cTxt, Chr(195) + Chr(161), "a" )
   cTxt := StrTran( cTxt, Chr(195) + Chr(163), "a" )
   cTxt := StrTran( cTxt, Chr(195) + Chr(173), "i" )
   cTxt := StrTran( cTxt, Chr(195) + Chr(179), "o" )
   cTxt := StrTran( cTxt, Chr(195) + Chr(167), "c" )
   cTxt := StrTran( cTxt, Chr(195) + Chr(169), "e" )
   cTxt := StrTran( cTxt, Chr(195) + Chr(170), "e" )
   cTxt := StrTran( cTxt, Chr(195) + Chr(181), "o" )
   cTxt := StrTran( cTxt, Chr(195) + Chr(160), "o" )
   cTxt := StrTran( cTxt, Chr(195) + Chr(181), "o" )
   cTxt := StrTran( cTxt, Chr(195) + Chr(129), "A" )
   cTxt := StrTran( cTxt, Chr(226) + Chr(128) + Chr(156), [*] ) // aspas de destaque "cames"
   cTxt := StrTran( cTxt, Chr(226) + Chr(128) + Chr(157), [*] ) // aspas de destaque "cames"
   cTxt := StrTran( cTxt, Chr(195) + Chr(180), "o" )
   cTxt := StrTran( cTxt, Chr(195) + Chr(186), "u" )
   cTxt := StrTran( cTxt, Chr(195) + Chr(147), "O" )
   cTxt := StrTran( cTxt, Chr(226) + Chr(128) + Chr(153), [ ] ) // caixa d'agua
   cTxt := StrTran( cTxt, Chr(226) + Chr(128) + Chr(147), [-] ) // - mesmo
   cTxt := StrTran( cTxt, Chr(194) + Chr(179), [3] ) // m3
   FOR EACH cLetra IN @cTxt
      DO CASE
      CASE cLetra $ "abcdefghijklmnopqrstuvwxyz"
      CASE cLetra $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      CASE cLetra $ "0123456789.,-+(){}$%/:;=*<> "
      CASE cLetra == Chr(13)
      CASE cLetra == Chr(10)
      CASE cLetra == ["]
      OTHERWISE
         ? cLetra, Asc( cLetra ), cLetra:__EnumIndex, Substr( cTxt, cLetra:__EnumIndex - 25, 50 )
         Inkey(5)
      ENDCASE
   NEXT

   RETURN cTxt
