/*
PXLS0010 - PRODUTOS EM EXCEL
2012

...
*/


PROCEDURE PXLS0010

   LOCAL cTmpFile

   IF ! AbreArquivos( "jpitem" )
      RETURN
   ENDIF
   SELECT jpitem

   OrdSetFocus( "itemvenda" )
   cTmpFile := MyTempFile( "XLS" )
   SET ALTERNATE TO ( cTmpFile )
   SET ALTERNATE ON
   SET CONSOLE OFF

   ?? "COD" + Chr(9)
   ?? "DESCRICAO" + Chr(9)
   ?? "DEP.1" + Chr(9)
   ?? "DEP.2" + Chr(9)
   ?? "PRECO VENDA" + Chr(9)
   ?? "ULT PRECO" + Chr(9)
   ?? "CUSTO CONTABIL" + Chr(9)
   ?
   GOTO TOP
   DO WHILE ! Eof()
      ?? jpitem->ieItem + Chr(9)
      ?? jpitem->ieDescri + Chr(9)
      ?? LTrim( Str( jpitem->ieQtde, 16, 2 ) ) + Chr(9)
      ?? LTrim( Str( jpitem->ieQtd2, 16, 2 ) ) + Chr(9)
      ?? LTrim( Str( jpitem->ieValor, 16, 2 ) ) + Chr(9)
      ?? LTrim( Str( jpitem->ieUltPre, 16, 2 ) ) + Chr(9)
      ?? LTrim( Str( jpitem->ieCusCon, 16, 2 ) ) + Chr(9)
      ?
      SKIP
   ENDDO
   SET CONSOLE ON
   SET ALTERNATE OFF
   SET ALTERNATE TO
   CLOSE DATABASES
   RUN ( "START " + cTmpFile )

   RETURN
