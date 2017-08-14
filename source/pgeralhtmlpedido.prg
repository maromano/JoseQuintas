/*
PGERALHTMLPEDIDO - GERA PAGINA DE PEDIDOS
2006 JOsé Quintas
*/

PROCEDURE pGeralHtmlPedido

   LOCAL GetList := {}, nCont, nCont2, nCont3, nColor, mNumItem, cCorTitulo, mTmpFile, mTmpHtm, mLista, mlPreco, mProDep, mNumGru

   IF ! AbreArquivos( "jptabel", "jpitem" )
      RETURN
   ENDIF
   SELECT jptabel

   mLPreco  := "*"
   @ 12, 5 SAY "Lista......:" GET mLPreco PICTURE "!A"
   Mensagem( "Digite campos, ESC Sai" )
   READ
   Mensagem()

   IF ! MsgYesNo( "Gerando lista " + mLPreco )
      RETURN
   ENDIF

   mTmpFile := TempFileArray(2)

   SELECT jpitem
   INDEX ON IndexGeralHtmlPedido( jpitem->ieItem ) TO ( mTmpFile[ 2 ] ) FOR jpitem->ieTipo == "S"

   GOTO TOP

   cCorTitulo := "#FFFF80"

   nColor   := 1
   mLista   := {}
   mNumItem := 0

   DO WHILE ! Eof()
      IF ! jpitem->ieTipo == "S"
         SKIP
         LOOP
      ENDIF
      AAdd( mLista, { jpitem->ieProDep, {} } )
      mProDep  := jpitem->ieProDep
      mNumGru  := Len( mLista )
      DO WHILE jpitem->ieProDep == mProDep .AND. ! Eof()
         IF ! jpitem->ieTipo == "S"
            SKIP
            LOOP
         ENDIF
         AAdd( mLista[ mNumGru, 2 ], { jpitem->ieItem, jpitem->ieDescri, mNumItem, jpitem->ieValor, Trim( jpitem->ieDesTec ) } )
         mNumItem += 1
         SKIP
     ENDDO
   ENDDO

   mTmpHtm := MyTempFile( "HTM" )
   SET ALTERNATE TO ( mTmpHtm )
   SET ALTERNATE ON
   SET CONSOLE   OFF
   ? [<Html>]
   ? [<Head>]
   ? [<Script Language="VBScript">]
   ? [<----]
   ?
   FOR nCont = 1 TO Len( mLista )
      FOR nCont2 = 1 TO Len( mLista[ nCont, 2 ] )
         mNumItem := mLista[ nCont, 2, nCont2, 3 ]
         ? [Sub Recalculo] + LTrim( Str( mNumItem ) ) + [()]
         ? [Dim nTotal]
         ? [nTotal = Document.Form1.Qtd(] + LTrim( Str( mNumItem ) ) + [).Value * ] + ;
           [Document.Form1.Valor(] + LTrim( Str( mNumItem ) ) + [).Value]
         ? [Document.Form1.Valor2(] + LTrim( Str( mNumItem ) ) + [).Value = nTotal]
         ? [RecalculoProDep] + lTrim( Str( nCont - 1 ) )
         ? [End Sub]
         ?
      NEXT
      ? [Sub RecalculoProDep] + LTrim( Str( nCont - 1 ) ) + [()]
      ? [Dim nTotal]
      ? [nTotal = 0]
      For nCont2 = 1 To Len( mLista[ nCont, 2 ] )
         ? [nTotal = nTotal + Document.Form1.Valor2(] + lTrim( Str( mLista[ nCont, 2, nCont2, 3 ] ) ) + [).Value]
      NEXT
      ? [Document.Form1.SubTotal(] + LTrim( Str( nCont - 1 ) ) + [).Value = nTotal]
      ? [RecalculoGeral]
      ? [End Sub]
      ?
   NEXT
   ? [Sub RecalculoGeral()]
   ? [Dim nTotal]
   ? [nTotal = 0]
   FOR nCont = 0 TO Len( mLista ) - 1
      ? [nTotal = nTotal + Document.Form1.SubTotal(] + LTrim( Str( nCont ) ) + [).Value]
   NEXT
   ? [Document.Form1.TotalGeral.Value = nTotal]
   ? [End Sub]
   ?
   ? [--->]
   ? [</Script>]
   ?
   ? [</Head>]
   ? [<Body Width="95%" align="CENTER">]
   ? [<Form action="/scripts/sendmail.cgi" METHOD="POST" name="Form1">]
   ? [<Table Border="1" Width="100%" Align="CENTER" bgColor="] + cCorTitulo + [">]
   ? [<tr><td>VALIDADE DESTA TABELA: APENAS TESTE</td></tr>]
   ? [</Table>]

   mNumItem := 1
   For nCont = 1 To Len( mLista )
      ? [<FieldSet>]
      ? [<Legend>]
      ? [<Small Font>]
      ? AUXPRODEPClass():Descricao( mLista[ nCont, 1 ] )
      ? [</Small Font>]
      ? [</Legend>]
      ? [<Table Width="100%" Align="CENTER">]
      ? [<tr><td Width="5%"></td>]
      ? [<td Width="75%"></td>]
      ? [<td Width="10%"></td>]
      ? [<td Width="10%"></td>]
      ? [</tr>]
      For nCont2 = 1 To Len(mLista[nCont,2])
         ? [<tr>]
         ? [<td>]
         ? [<Select Name="Qtd" onchange="Recalculo]+LTrim(Str(mNumItem-1))+[()">]
         ? [<Option Selected Value="0">0</Option>]
         For nCont3 = 1 To 10
            ? [<Option Value="] + LTrim(Str(nCont3)) + [">] + LTrim(Str(nCont3)) + [</Option>]
         NEXT
         ? [</Select></td>]
         ? [<td bgcolor=] + CorFundo(nColor) + [>]
         ? [<Small Font>] + "("+mLista[nCont,2,nCont2,1]+") "+Trim(mLista[nCont,2,nCont2,2]) + [<br>]
         IF Len(mLista[nCont,2,nCont2,5]) <> 0
            ? [Detalhe: ] + mLista[nCont,2,nCont2,5]
         ENDIF
         ? [</Small>]
         ? [</td>]
         ? [<td>]
         ? [<Input Type="text" Name="Valor" size="15" readonly Value="] + LTrim(Transform(mLista[nCont,2,nCont2,4],"@E 999999999.99")) +[">]
         ? [</td>]
         ? [<td>]
         ? [<Input Type="text" Name="Valor2" size="15" readonly Value="0">]
         ? [</td>]
         ? [</tr>]
         nColor := IIf(nColor==1,0,1)
         mNumItem += 1
      NEXT
      ? [<tr><td Width="5%" bgcolor="] + cCorTitulo + ["></td>]
      ? [<td Width="75%" bgcolor="] + cCorTitulo + [">]
      ? [<Small Font><b>TOTAL ] + Trim( AUXPRODEPClass():Descricao( mLista[ nCont, 1 ] ) ) + [</b></Small>]
      ? [</td>]
      ? [<td Width="10%" bgcolor="] + cCorTitulo + ["></td>]
      ? [<td Width="10%" bgcolor="] + cCorTitulo + [">]
      ? [<Input Type="text" Name="SubTotal" size="15" readonly Value="0">]
      ? [</td>]
      ? [</tr>]
      ? [</table>]
      ? [</FieldSet>]
      ? [<br>]
   NEXT
   ? [<FieldSet><Legend><Small Font><B>TOTAL GERAL</B></Small></Legend>]
   ? [<table width="100%">]
   ? [<tr><td width="5%" bgcolor="] + cCorTitulo + ["></td>]
   ? [<td width="75%" bgcolor="] + cCorTitulo + [">]
   ? [TOTAL GERAL]
   ? [</td>]
   ? [<td width="10%" bgcolor="] + cCorTitulo + ["></td>]
   ? [<td width="10%" bgcolor="] + cCorTitulo + [">]
   ? [<Input Type="text" size="15" Name="TotalGeral" readonly Value="0">]
   ? [</td>]
   ? [</tr>]
   ? [</table>]
   ? [</FieldSet>]
   ? [<FieldSet><Legend>Dados para Faturamento</Legend>]
   ? [<Table Width="100%">]
   ? [<tr><td width="10%">Nome</td><td width="90%"><Input Type="text" size="50" Name="Nome"></td></tr>]
   ? [<tr><td>Contato</td><td><Input Type="text" size="50" Name="Contato"></td></tr>]
   ? [<tr><td><input type=submit value=Enviar name="cmdSend"></td></tr>]
   ? [</table></FieldSet>]
   ? [</Form>]
   ? [</Body>]
   ? [</Html>]
   SET ALTERNATE OFF
   SET ALTERNATE TO
   SET CONSOLE ON
   SELECT (Select("temp"))
   USE
   SELECT jptabel
   SET FILTER TO
   fErase(mTmpFile[1])
   fErase(mTmpFile[2])
   ShellExecuteOpen(mTmpHtm)

   RETURN

STATIC FUNCTION CorFundo( NumColor )

   LOCAL cValue

   IF NumColor == 1
      cValue = "#FFFFFF"
   ELSE
      cValue = "#C0C0C0"
   ENDIF
   cValue = Chr(34) + cValue + Chr(34)

   RETURN cValue

FUNCTION IndexGeralHtmlPedido()

   LOCAL cValue

   cValue := Pad( AUXPRODEPClass():Descricao( jpitem->ieProDep ), 30 ) + jpitem->ieProDep
   cValue += Pad( jpitem->ieDescri, 30 )

   RETURN cValue
