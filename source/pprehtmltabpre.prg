/*
PPREHTMLTABPRE - GERA PAGINA DE INTERNET
2004.07 JOsé Quintas
*/

#include "inkey.ch"

PROCEDURE pPreHtmlTabPre

   LOCAL mTmpFile

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso", "jpdecret" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpcadas", "jpcidade", "jpclista", "jpcomiss", "jpconfi", "jpempre", ;
      "jpestoq", "jpfinan", "jpforpag", "jpimpos", "jpitem", "jpitped", "jplfisc", "jpnota", "jpnumero", "jppedi", ;
      "jppreco", "jpsenha", "jptabel", "jptransa", "jpuf", "jpveicul", "jpvended" )
      RETURN
   ENDIF
   SELECT jpitem
   mTmpFile := MyTempFile( "CDX" )
   INDEX ON jpitem->ieProDep + Left(jpitem->ieDescri,50) TO (mTmpFile) FOR Val(jpitem->ieProDep) != 0 .AND. jpitem->ieTipo="S"
   SET INDEX TO (mTmpFile), jpitem
   GOTO TOP
   HtmIndex()
   HtmProDep()
   ShellExecuteOpen("TABPRECO.htm")
   SET INDEX TO ( PathAndFile( "jpitem" ) )
   fErase(mTmpFile)

   RETURN

STATIC FUNCTION HtmIndex()

   SET ALTERNATE TO ("TabPreco.Htm")
   SET ALTERNATE OFF
   SET CONSOLE   OFF
   ? [<html>]
   ? [<head>]
   ? [<title>] + Trim(AppEmpresaNome()) + [</title>]
   ? [</head>]
   ? [<frameset framespacing="0" border="false" frameborder="0" rows="40,*">]
   ?    [<frame name="titulo" scrolling="no" target="left" src="TABDETAL.HTM#CABEC" marginwidth="0" marginheight="0">]
   ?    [<frameset cols="200,*">]
   ?       [<frame name="menu" target="abertura" src="TABDETAL.HTM#MENU" scrolling="auto" noresize marginwidth="5" marginheight="5">]
   ?       [<frame name="DETALHE" src="TABDETAL.HTM#] + jpitem->ieProDep + [" scrolling="auto" noresize marginheight="5" marginwidth="5">]
   ?    [</frameset>]
   ?    [<noframes>]
   ?       [<body background="area_texto_back.jpg" bgcolor="#FFFFFF">]
   ?       [<p>Esta página não pode ser exibida pelo seu navegador Seu navegador não suporta frames.</p>]
   ?       [</body>]
   ?    [</noframes>]
   ? [</frameset>]
   ? [</html>]
   SET ALTERNATE OFF
   SET ALTERNATE TO
   SET CONSOLE   ON

   RETURN NIL

STATIC FUNCTION HtmProDep()

   LOCAL nCont, aCodItem, aCodProDep

   aCodItem  := {}
   aCodProDep := {}
   GOTO TOP
   DO WHILE ! Eof()
      AAdd( aCodItem, jpitem->ieItem )
      IF aScan( aCodProDep, jpitem->ieProDep ) == 0
         AAdd( aCodProDep, jpitem->ieProDep )
      ENDIF
      SKIP
   ENDDO
   SET ALTERNATE TO ( "TABDETAL.htm" )
   SET ALTERNATE ON
   SET CONSOLE OFF
   ? [<html>]
   ? [<Script Language="VBScript" type="text/vbscript">]
   ? [Dim ProDeps(] + LTrim(Str(Len(aCodProDep)-1)) + [)]
   FOR nCont = 1 TO Len(aCodProDep)
      ? [ProDeps(] + LTrim(Str(nCont-1)) + [) = "] + aCodProDep[nCont] + Trim( AUXPRODEPClass():Descricao( aCodProDep[ nCont ] ) ) + ["]
   NEXT
   ?
   ? [Dim Itens(] + LTrim(Str(Len(aCodItem)-1)) + [)]
   FOR nCont = 1 TO Len(aCodItem)
      Encontra(aCodItem[nCont],"jpitem","item")
      ? [Itens(] + LTrim(Str(nCont-1)) + [) = "] + jpitem->ieProDep + jpitem->ieItem + Str(jpitem->ieValor,8,2) + AjustaDescricao(jpitem->ieDescri) + "<br>" + AjustaDescricao(jpitem->ieDesTec) + ["]
   NEXT
   ?
   ? [Dim mUrl]
   ? [mUrl = document.location.href]
   ? [If Instr(mUrl,"#") = 0 Then mUrl = "#INDEX"]
   ? [mUrl = Mid(mUrl,Instr(mUrl,"#")+1)]
   ?
   ? [if mUrl = "INDEX" Then]
   ? [Document.Write("<html><head>")]
   ? [Document.Write("<title>] + Trim(AppEmpresaNome()) + [</title>")]
   ? [Document.Write("</head>")]
   ? [Document.Write("<frameset framespacing=" & Quoted2("0") & " border=" & Quoted2("false") & " frameborder=" & Quoted2("0"))]
   ? [Document.Write("rows=" & Quoted2("40,*") & ">")]
   ? [Document.Write("<frame name=" & Quoted2("titulo") & " scrolling=" & Quoted2("no") & " target=" & Quoted2("left"))]
   ? [Document.Write("    src=" & Quoted2("TABDETAL.HTM#CABEC") & " marginwidth=" & Quoted2("0") & " marginheight=" & Quoted2("0") & ">")]
   ? [Document.Write("    <frameset cols=" & Quoted2("200,*") & ">")]
   ? [Document.Write("        <frame name=" & Quoted2("menu") & " target=" & Quoted2("listapreco") & " src=" & Quoted2("TABDETAL.HTM#MENU"))]
   ? [Document.Write("        scrolling=" & Quoted2("auto") & " noresize marginwidth=" & Quoted2("5"))]
   ? [Document.Write("        marginheight=" & Quoted2("5") & ">")]
   ? [Document.Write("<frame name=" & Quoted2("DETALHE") & " src=TABDETAL.HTM#" & Mid(ProDeps(0),1,6))]
   ? [Document.Write(" scrolling=" & Quoted2("auto") & " noresize marginheight=" & Quoted2("5"))]
   ? [Document.Write("        marginwidth=" & Quoted2("5") & ">")]
   ? [Document.Write("    </frameset>")]
   ? [Document.Write("    <noframes>")]
   ? [Document.Write("    <body bgcolor=" & Quoted2("#FFFFFF") & ">")]
   ? [Document.Write("    <p>Esta página não pode ser exibida pelo seu navegador Seu")]
   ? [Document.Write("    navegador não suporta frames.</p>")]
   ? [Document.Write("    </body>    </noframes></frameset></html>")]
   ? [End If]
   ?
   ? [If mUrl = "CABEC" Then]
   ? [Document.Write("<html>")]
   ? [Document.Write("<head>")]
   ? [Document.Write("<title>] + Trim(AppEmpresaNome()) + [</title>")]
   ? [Document.Write("</head><body>")]
   ? [Document.Write("<table border=" & Quoted2("1") & " cellspacing=" & Quoted2("1") & " width=" & Quoted2("100%") & " bgcolor=" & Quoted2("#6699CC") & ">")]
   ? [Document.Write("<tr>")]
   ? [Document.Write("<td align=" & Quoted2("center") & " colspan=" & Quoted2("6") & " width=" & Quoted2("50%"))]
   ? [Document.Write("bgcolor=" & Quoted2("#000080") & "><p align=" & Quoted2("center") & "><font color=" & Quoted2("#FFFFFF"))]
   ? [Document.Write("size=" & Quoted2("5") & "><strong>] + Trim(AppEmpresaNome()) + [</strong></font></p>")]
   ? [Document.Write("</td></tr></table></body></html>")]
   ? [End If]
   ?
   ? [If mUrl = "MENU" Then]
   ? [document.write("<html>")]
   ? [document.write("<head>")]
   ? [document.write("<title>PRODUTOS</title>")]
   ? [document.write("</head>")]
   ? [document.write("<body bgcolor=" & Quoted2("#9286FB") & " topmargin=" & Quoted2("0") & " leftmargin=" & Quoted2("0") & ">")]
   ? [Dim nCont]
   ? [document.write("<table border=" & Quoted2("1") & " width=" & Quoted2("500") & ">")]
   ? [document.write("<tr>")]
   ? [document.write("<td align=" & Quoted2("left") & "><font color=" & Quoted2("#000000") & " size=" & Quoted2("3") & " face=" & Quoted2("Arial") & "><strong>PRODUTOS</strong></font></td>")]
   ? [document.write("</tr>")]
   ? [for nCont = 0 to uBound(ProDeps)]
   ? [document.write("<tr>")]
   ? [document.write("<td align=" & Quoted2("left") & "><a href=TABDETAL.HTM#" & Mid(ProDeps(nCont),1,6))]
   ? [document.write(" target=" & Quoted2("DETALHE") & "OnClick=" & Quoted2("top.window.detalhe.window.location.reload()") & "><font color=" & Quoted2("#FFFFFF") & " size=" & Quoted2("2") & " face=" & Quoted2("Arial") & "><strong> " & Mid(ProDeps(nCont),7) & "</strong></font></a></td>")]
   ? [document.write("</tr>")]
   ? [NEXT]
   ? [Document.Write("<tr>")]
   ? [Document.Write("<td align=" & Quoted2("center") & "><p align=" & Quoted2("center") & "><font size=" & Quoted2("2") & ">Referencia<br>")]
   ? [Document.Write("11/07/04</font></p>")]
   ? [Document.Write("</td></tr></table></body></html>")]
   ? [End If]
   ?
   ? [If mUrl > "000000" Then]
   ? [If mUrl < "999999" Then]
   ? [Document.Write("<html><head><title>")]
   ? [for nCont = 0 to uBound(ProDeps)]
   ? [   IF Mid(ProDeps(nCont),1,6) = mUrl Then]
   ? [      Document.Write(Mid(ProDeps(nCont),7))]
   ? [   End If]
   ? [NEXT]
   ? [Document.Write("</title></head>")]
   ? [Document.Write("<body>")]
   ? [Document.Write("<table border=" & Quoted2("1") & " cellpadding=" & Quoted2("0") & " cellspacing=" & Quoted2("0") & " width=" & Quoted2("95%") & " bgcolor=" & Quoted2("#C0C0C0") & " height=" & Quoted2("1") & ">")]
   ? [Document.Write("<tr>")]
   ? [Document.Write("<th width=" & Quoted2("10%") & " height=" & Quoted2("19") & "><font size=" & Quoted2("2") & ">CODIGO</font></th>")]
   ? [Document.Write("<th width=" & Quoted2("80%") & " height=" & Quoted2("19") & "><font size=" & Quoted2("2") & ">")]
   ? [for nCont = 0 to UBound(ProDeps)]
   ? [   IF Mid(ProDeps(nCont),1,6) = mUrl Then]
   ? [      Document.Write(Mid(ProDeps(nCont),7))]
   ? [   End If]
   ? [NEXT]
   ? [Document.Write("</font></th>")]
   ? [Document.Write("<th width=" & Quoted2("10%") & " height=" & Quoted2("19") & "><p align=" & Quoted2("right") & "><font size=" & Quoted2("2") & ">PRECO</font></p></th>")]
   ? [Document.Write("</tr>")]
   ? [Document.Write("</table>")]
   ? [Document.Write("<table border=" & Quoted2("1") & " cellpadding=" & Quoted2("0") & " cellspacing=" & Quoted2("0") & " width=" & Quoted2("95%") & " height=" & Quoted2("1") & ">")]
   ? [Dim mCor(1)]
   ? [Dim mNumCor]
   ? [mCor(0) = Quoted2("#FFFFFF")]
   ? [mCor(1) = Quoted2("#E8ECF1")]
   ? [mNumCor = 0]
   ? [FOR nCont = 0 TO UBound(Itens)]
   ? [   IF Mid(Itens(nCont),1,6) = mUrl THEN]
   ? [   Document.Write("<tr>")]
   ? [   Document.Write("<td width=" & Quoted2("10%") & " bgcolor=" & mCor(mNumCor) & " height=" & Quoted2("19") & "><font size=" & Quoted2("1") & ">" & Mid(Itens(nCont),7,6) & "</td>")]
   ? [   Document.Write("<td width=" & Quoted2("80%") & " bgcolor=" & mCor(mNumCor) & " height=" & Quoted2("19") & "><font size=" & Quoted2("1") & ">" & Mid(Itens(nCont),21) & "</font></td>")]
   ? [   Document.Write("<td width=" & Quoted2("10%") & " bgcolor=" & mCor(mNumCor) & " height=" & Quoted2("19") & "><p align=" & Quoted2("right") & "><font size=" & Quoted2("1") & ">" & Mid(Itens(nCont),13,8) & "</font></p></td>")]
   ? [   Document.Write("</tr>")]
   ? [   IF mNumCor = 0 THEN mNumCor = 1 ELSE mNumCor = 0]
   ? [END IF]
   ? [NEXT]
   ? [Document.Write("</table></body></html>")]
   ? [END IF]
   ? [END IF]
   ? [ENDTEXT]
   ?
   ? [FUNCTION Quoted2(mTexto)]
   ? [Quoted = Chr(34) & mTexto & Chr(34)]
   ? [End FUNCTION]
   ? [</script></html>]
   SET ALTERNATE OFF
   SET ALTERNATE TO
   SET CONSOLE   ON

   RETURN NIL

STATIC FUNCTION AjustaDescricao( mTexto )

   LOCAL nCont, mTexto2

   mTexto  := StrTran( mTexto, Chr(34),"" )
   mTexto2 := ""
   DO WHILE .T.
      nCont = At( "/", mTexto )
      IF nCont == 0
         EXIT
      ENDIF
      mTexto2 := mTexto2 + Substr( mTexto, 1, nCont )
      mTexto  := Substr( mTexto,nCont + 1 )
      IF Substr( mTexto, 1, 1 ) != " "
         mTexto2 := mTexto2 + " "
      ENDIF
   ENDDO
   mTexto2 += mTexto

   RETURN mTexto2
