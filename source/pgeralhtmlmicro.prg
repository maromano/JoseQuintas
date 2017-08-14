/*
PGERALHTMLMICRO - HTM PARA CALCULO DE MICRO MONTADO
2003 José Quintas
*/

#include "inkey.ch"

PROCEDURE pGeralHtmlMicro

   IF ! AbreArquivos( "jpitem" )
      RETURN
   ENDIF

   SELECT jpitem
   SET FILTER TO jpitem->ieTipo=="S"
   GOTO TOP

   IF ! MsgYesNo( "Confirma a geração?" )
      SET FILTER TO
      RETURN
   ENDIF
   SET ALTERNATE TO tstcalc.htm
   SET ALTERNATE ON
   SET CONSOLE OFF
   GeraHtm()
   SET ALTERNATE TO
   SET ALTERNATE OFF
   SET CONSOLE ON
   set INDEX to
   SET FILTER TO
   ShellExecuteOpen( "tstcalc.htm" )

   RETURN

STATIC FUNCTION GeraHtm()

   TEXT
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta name="GENERATOR" content="Microsoft FrontPage Express 2.0">
<title>Simulacao de Calculo de Microcomputador</title>
</head>

<body topmargin="0" leftmargin="0"
 onload="vbscript:document.frm1.processador.focus();vbscript:recalc()"
 marginwidth="0" marginheight="0">
   ENDTEXT

   //? [<FORM ACTION="/scripts/sendmail.cgi" METHOD="POST" name="frm1">]
   //? [<form action="/scripts/FormMail.pl" METHOD="POST" name="frm1"> ]
   ? [<form action="pedido.htm" METHOD="POST" name="frm1">]
   ? [<div align="center"><center>]

   //? [<INPUT TYPE="hidden" NAME="TO" VALUE="]+Trim(jpempre->emEmail)+[">]
   ? [<input type="hidden" name="recipient" value="]+Trim(jpempre->emEmail)+[">]

   ? [<INPUT TYPE="hidden" NAME="SUBJECT" VALUE="Pedido da Pagina">]
   ? [<table border="1" cellpadding="0" cellspacing="0" width="100%" height="1">]
   ? [ <tr>]
   ? [  <th width="20%" bgcolor="#E8ECF1" heigh="1"> <p align="center">]
   IF JPEGLogotipo() != NIL
      ? [  <img src=] + HtmlEncodeJPEG( JPEGLogotipo() ) + [ width="150" height="75">]
   ELSEIF File( "logotipo.gif" )
      ? [  <img src=] + HtmlEncodeFile( "logotipo.gif" ) + [ width="150" height="75">]
   ENDIF
   ? [ </p></th>]
   ? [ <th width="80%" bgcolor="#E8ECF1" heigh="1"><p align="center">]
   ? [  <small font> <font color=BLUE><i><u>]+AppEmpresaNome()+[</i></u></font>]
   ? [  <br>]
   IF ! Empty(jpempre->emTelefone)
      ?? Trim(jpempre->emTelefone) + [<br>]
   ENDIF
   ? [  ]+iif(Empty(jpempre->emHomePage),[],[Site: <a href="]+Trim(jpempre->emHomePage)+[">]+Trim(jpempre->emHomePage)+[</a>])+;
     Space(3)+iif(Empty(jpempre->emEmail),[],[Email: <a href="mailto:]+Trim(jpempre->emEmail)+;
      [">] + Trim(jpempre->emEmail)+ [</a>])
   ? [ </small></p></th></tr>]
   ? [</table>]
   TEXT
<table border="1" cellspacing="1" width="100%" bgcolor="#E8ECF1" >
 <tr>
  <td colspan="3" bgcolor="#0099CC"><p align="center"><small font><font
  color="#FFFFFF"><strong>Simulacao do Preco de um Micro Montado</strong>
  </font></small>
  <select name="MicroMontado" size="1" onchange="ModMicroMontado()"></select>
  </p></td>
 </tr>
</table>
</center></div><div align="center"><center>
<table width="100%" bgcolor="#E8ECF1">
   ENDTEXT
   ? [<tr>]
   HtmItem("Processador","0000;SEM PROCESSADOR","Escolha (Obrigatorio)",1)
   HtmItem("Video (*)","0000; ", "Padrao On Board",2)
   ? [</tr><tr>]
   HtmItem("Placa Mae (*)","0000; SEM PLACA MAE","Escolha (Obrigatorio)",3)
   HtmItem("Rede (*)","0000; Padrao On Board","Padrao On Board",4)
   ? [</tr><tr>]
   HtmItem("Cooler (*)","0000; SEM COOLER","Escolha (Obrigatorio)",5)
   HtmItem("Modem (*)","0000; ","56K Padrao On Board",6)
   ? [</tr><tr>]
   HtmItem("Gabinete","0000; SEM GABINETE","Escolha (Obrigatorio)",7)
   HtmItem("Drive","0000; SEM DRIVE","Escolha (Obrigatorio)",15)
   ? [</tr><tr>]
   HtmItem("Teclado","0000; SEM TECLADO","Escolha (Obrigatorio)",16)
   HtmItem("Mouse","0000; SEM MOUSE","Escolha (Obrigatorio)",17)
   ? [</tr><tr>]
   HtmItem("Memoria","0000; SEM MEMORIA","Escolha (Obrigatorio)",8)
   HtmItem("Disco Rigido (HD)","0000; SEM HD","Escolha (Obrigatorio)",9)
   ? [</tr><tr>]
   HtmItem("Monitor","0000; ","Escolha (Obrigatorio)",10)
   HtmItem("CD-ROM","0000; Nenhum","Escolha (Obrigatorio)",11)
   ? [</tr><tr>]
   HtmItem("Impressora","0000; ","Nenhuma",12)
   HtmItem("Outros","0000; SEM ADICIONAIS","Nenhum",14)
   ? [</tr><tr>]
   HtmItem("Outros","0000; SEM ADICIONAIS","Nenhum",14)
   HtmItem("Outros","0000; SEM ADICIONAIS","Nenhum",14)
   ? [</tr>]
   TEXT
</table>
</center></div>
<div align="center"><center>
<table border="1" cellspacing="1" width="100%" bgcolor="#E8ECF1" >
<tr>
<td width="50%"><fieldset><legend><small font>Totais</small></legend>
<small font>Unitario</small><input type="text" size="20" name="Unitario" value="0"
readonly> <br><small font>Qtde</small>
   ENDTEXT
   SelQtde("QtConfig")
   TEXT
<small font>Total</small><input type="text" size="20" name="Total" value="0" readonly>
</fieldset></td>
   ENDTEXT
   TEXT
<td width="50%"><fieldset><legend><small font>Simulacao de Financiamento
</small></legend>
<br>
<select name="FormaPagto" size="1" onchange="ReCalc()"
style="background-color: rgb(255,255,255)">
<option selected value="0000; A Vista">A Vista</option>
<option value="0000; 1 + 1">1 + 1</option>
<option value="0000; 1 + 2">1 + 2</option>
<option value="0000; 1 + 3">1 + 3</option>
<option value="0000; 1 + 4">1 + 4</option>
<option value="0000; 1 + 5">1 + 5</option>
<option value="0000; 1 + 6">1 + 6</option>
<option value="0000; 1 + 7">1 + 7</option>
<option value="0000; 1 + 8">1 + 8</option>
<option value="0000; 1 + 9">1 + 9</option>
<option value="0000; 1 + 10">1 + 10</option>
<option value="0000; 1 + 11">1 + 11</option>
<option value="0000; 1 + 12">1 + 12</option>
<option value="0000; 1 + 13">1 + 13</option>
<option value="0000; 1 + 14">1 + 14</option>
<option value="0000; 1 + 15">1 + 15</option>
<option value="0000; 1 + 16">1 + 16</option>
<option value="0000; 1 + 17">1 + 17</option>
<option value="0000; 1 + 18">1 + 18</option>
<option value="0000; 1 + 19">1 + 19</option>
<option value="0000; 1 + 20">1 + 20</option>
<option value="0000; 1 + 21">1 + 21</option>
<option value="0000; 1 + 22">1 + 22</option>
<option value="0000; 1 + 23">1 + 23</option>
<option value="0000; 1 + 24">1 + 24</option>
</select>
<input type="text" size="20" name="Parcela" value="0" readonly>
</fieldset></td>
</tr>
</table>
   ENDTEXT
   TEXT
</center></div>
<div align="center"><center>
<table border="0" width="100%" bgcolor="#C0C0C0">
 <tr>
 <td><small font>(*) Atencao: Cada modelo de placa mae e' compativel
 com um processador, e alguns modelos podem conter ou nao itens on-board<br>
 (*) Precos sujeitos a alteracao, conforme cotacao do
 dolar, confirme validade</small> </td>
 </tr>
</table>
</center></div>
<div align="center"><center>
<table border="1" cellspacing="1" width="100%" bgcolor="#E8ECF1" >
<tr>
<td><fieldset><legend><small font>Tac</small></legend>
<br>
<input type="text" size="20" name="VlTac" value="20" onchange="Recalc()">
</fieldset>
</td>
<td><fieldset><legend><small font>Margem de Lucro</small></legend>
<br>
<input type="text" size="20" name="Margem" value="0" onchange="Recalc()">
</fieldset>
</td>
</tr>
</table>
</center></div>
<input type="hidden" name="TxtPedido" value="XXX">
<fieldset><legend><small font>Seu Email</small></legend>
<input type="seu email" size="70" name="xxx" value="">
</fieldset>
<p><input type=submit value=Enviar name=B1></p>
</form>
   ENDTEXT
   TEXT
<p><script language="VBScript"><!--

sub ReCalc()
dim TxtPedido
dim total
dim Valor
dim select_index
dim select_value
dim parcela
dim i
dim nCont
dim QtItem
total = 0
TxtPedido = "" & VbCrLf & VbCrLf & VbCrLf & "PEDIDO" & VbCrLf & VbCrLf

for nCont = 0 to 17
   select_index = document.frm1.Pecas(nCont).selectedindex
   select_value = document.frm1.Pecas(nCont).options(select_index).value
   QtItem = (document.frm1.QtPecas(nCont).SelectedIndex+1)
   Valor = Mid(select_value,1,4) * QtItem
   IF Valor <> 0 Then _
      TxtPedido = TxtPedido & "Qtde." & QtItem & " " & _
         Mid(select_value,5) & " Unitario " & Mid(select_value,1,4) & _
         " Total " & Valor & VbCrLf
   Total = Total + Valor
NEXT

total = total + (total * document.frm1.Margem.Value / 100 )
total = Round(100*Total)/100
document.frm1.Unitario.Value   = total
TxtPedido = TxtPedido & VbCrLf & " Margem " & document.frm1.Margem.Value & VbCrLf
TxtPedido = TxtPedido & "Total da Maquina " & Total & VbCrLf
total = total * (document.frm1.qtconfig.SelectedIndex+1)
Total = Round(100*Total)/100
document.frm1.total.value = total
TxtPedido = TxtPedido & VbCrLf & "Qt. Maquinas " & document.frm1.qtconfig.SelectedIndex+1 & VbCrLf
TxtPedido = TxtPedido & "Valor total do pedido " & Total & VbCrLf

opcao = document.frm1.FormaPagto.selectedindex
parcela = 0
IF opcao = 0  then parcela = total
IF opcao > 0  then total   = total + document.frm1.VlTac.Value
IF opcao = 1  then parcela = total * 0.50932
IF opcao = 2  then parcela = total * 0.34584
IF opcao = 3  then parcela = total * 0.26416
IF opcao = 4  then parcela = total * 0.21519
IF opcao = 5  then parcela = total * 0.18258
IF opcao = 6  then parcela = total * 0.15933
IF opcao = 7  then parcela = total * 0.14191
IF opcao = 8  then parcela = total * 0.12839
IF opcao = 9 then parcela = total * 0.11760
IF opcao = 10 then parcela = total * 0.10879
IF opcao = 11 then parcela = total * 0.10147
IF opcao = 12 then parcela = total * 0.09529
IF opcao = 13 then parcela = total * 0.09001
IF opcao = 14 then parcela = total * 0.08544
IF opcao = 15 then parcela = total * 0.08147
IF opcao = 16 then parcela = total * 0.07797
IF opcao = 17 then parcela = total * 0.07487
IF opcao = 18 then parcela = total * 0.07211
IF opcao = 19 then parcela = total * 0.06964
   ENDTEXT
   TEXT
IF opcao = 20 then parcela = total * 0.06742
IF opcao = 21 then parcela = total * 0.06540
IF opcao = 22 then parcela = total * 0.06357
IF opcao = 23 then parcela = total * 0.06190
IF opcao = 24 then parcela = total * 0.06038
IF document.frm1.VlTac.Value < 1 then IF opcao > 0 then MsgBox "Faltou valor da TAC"
IF document.frm1.Margem.Value < 0 then MsgBox "Margem negativa"
document.frm1.parcela.value = parcela
TxtPedido = TxtPedido & VbCrLf & VbCrLf
TxtPedido = TxtPedido & "Parcelas p/ Pagto " & opcao & " " & de & Parcela & VbCrLf & VbCrLf
Document.frm1.TxtPedido.Value = TxtPedido
end sub

sub Multiplica( xSelecao, xQtde)
dim select_index
dim select_value
select_index = xSelecao.selectedindex
select_value = xSelecao.options(select_index).value
Multiplica = Mid(select_value,1,4) * ( xQtde.Value & "" )
end sub
--></script></p>

<p><script language="VBScript"><!--
sub ModMicroMontado()
MsgBox("Não implementado ainda!")
end sub
--></script></p>
</body>
</html>
   ENDTEXT

   RETURN NIL

STATIC FUNCTION ListaProDep(mNumProDep)

   LOCAL nCont, mLstItens, mProDeps, mLstProDep

// 1-Process 2-Video 3-Pl.Mae 4-Pl.Rede 5-Cooler 6-Fax 7-Gabinete
// 8-Memoria 9-Hd 10-Monitor 11-CdDvd 12-Impress 13-SO 14-Acess
// 15-Drive 16-Teclado 17-Mouse

   SELECT jpitem
   OrdSetFocus("itemvenda")
   GOTO TOP

   mLstProDep := { 30, 100, 20, 130, 0, 120, 10, 40, 50, 300, 0, 310, 0, 0, 60, 150, 160 }

   mLstItens := {}
   DO CASE
   CASE mLstProDep[mNumProDep] != 0
      DO WHILE ! Eof()
         IF Val(jpitem->ieProDep) == mLstProDep[mNumProDep]
            AAdd(mLstItens,jpitem->ieItem)
         ENDIF
         SKIP
      ENDDO
   CASE mNumProDep == 5 // Cooler
      mLstItens := {}
      DO WHILE ! Eof()
         IF "COOLER" $ jpitem->ieDescri
            AAdd(mLstItens,jpitem->ieItem)
         ENDIF
         SKIP
      ENDDO
   CASE mNumProDep == 11 // CD,DVD,GRAV
      DO WHILE ! Eof()
         IF jpitem->ieProDep $ "000060,000070,000075" // drive,cd,grav
            AAdd(mLstItens,jpitem->ieItem)
         ENDIF
         SKIP
      ENDDO
   //case mNumProDep == 13 // Sist.Operac
   //   DO WHILE ! Eof()
   //      IF Val(jpitem->ieProDep)==80
   //         IF Encontra(jpitem->ieItem,"jppromix","jppromix1")
   //            AAdd(mLstItens,jpitem->ieItem)
   //         ENDIF
   //      ENDIF
   //      SKIP
   //   ENDDO
   CASE mNumProDep == 13 .OR. mNumProDep==14 // Acessorios
      mProDeps := "000320,000140,000060,000170,000013"
      DO WHILE ! Eof()
         IF jpitem->ieProDep $ mProDeps
            AAdd(mLstItens,jpitem->ieItem)
         ENDIF
         SKIP
      ENDDO
   ENDCASE
   SELECT jpitem
   OrdSetFocus("item")
   FOR nCont = 1 TO Len( mLstItens )
      SEEK mLstItens[ nCont ]
      ? [                <option value="] + StrZero(jpitem->ieValor,4) + ;
         [; ] + Pad(jpitem->ieDescri,30) + [">] + ;
         Pad(jpitem->ieDescri,30) + [</option>]
   NEXT

   RETURN NIL

STATIC FUNCTION SelQtde(mTexto)

   LOCAL nCont

   mTexto := iif(mTexto==NIL,"QtPecas",mTexto)

   //   ? [<input type="text" fontsize="1" size="3" name="] + mNome + [" value="1" onchange="Recalc()">]

   ? [ <select name = "]+mTexto+[" size = "1" onchange="ReCalc()">]
   ? [ <option selected>1</option>]
   FOR nCont = 2 TO 10
      ? [ <option>] + LTrim(Str(nCont)) + [</option>]
   NEXT
   ? [ </select>]

   RETURN NIL

STATIC FUNCTION HtmItem( cNome, cMenu, cTexto, nProDep )

   ? [<td width="50%">]
   ? [<FieldSet><legend><small font>] + cNome + [</small></legend>]
   SelQtde()
   ? [<select name="Pecas" size="1" ]
   ? [ style="background-color: rgb(255,255,255); font-family: Arial"]
   ? [ onchange="ReCalc()">]
   ? [ <option selected value="]+cMenu+[">]+cTexto+[</option>]
   ListaProDep( nProDep )
   ? [</select>]
   ? [</fieldset>]
   ? [</td>]

   RETURN NIL
