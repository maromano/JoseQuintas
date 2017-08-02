/*
REXCEL2 - GERACAO EXCEL
2004 - José Quintas
*/

FUNCTION Dbf2Excel2( cSql, cPath )

   LOCAL mTmpFile

   hb_Default( @cSql, "" )
   hb_Default( @cPath, hb_cwd() )

   mTmpFile := MyTempFile( "VBS" )
   SET ALTERNATE TO ( mTmpFile )
   SET ALTERNATE ON
   SET CONSOLE OFF
   TEXT
DIM cSqlList(0)
   cSqlList(0) = "Select UfCol, UfCalc, Data, Viagem, TipoViag, TipoVeic, Ctrc, PesoReal, cnPesCal, Frete, VlMerc, Cliente From P1190 Order By UfCol, UfCalc, Data"
DIM ObjExcel   ' Workbook do Excel
DIM DbConn     ' Conexao com Banco
DIM Rs         ' RecordSet
DIM nQtdDoc    ' Qtde Documentos
DIM nRecCount  ' Qtde Registros
DIM nFldCount  ' Qtde Campos
DIM cSql       ' Auxiliar com Comando Sql
DIM cThisRange ' Auxiliar com "Range" do Excel
DIM cFormSub1, cFormSub2, cFormSub3, cFormSub4
DIM cFormTot1, cFormTot2, cFormTot3, cFormTot4
DIM nSubPesoReal, nSubPesoCalc, nSubFrete, nSubVlMerc
DIM nTotPesoReal, nTotPesoCalc, nTotFrete, nTotVlMerc   '


' Cria objeto do Excel
SET ObjExcel = WScript.CREATEObject("Excel.Application")
ObjExcel.Visible = True

' Cria conexao com Banco
SET DbConn = CREATEObject("ADODB.Connection")
DbConn.Open "Provider=Advantage.OLEDB.1;" & _
   "Mode=Share Deny None;" & _
   "Show Deleted Records in DBF Tables WITH Advantage=False;" & _
   ENDTEXT
   ? [   "Data Source=] + cPath + [;Advantage Server Type=ADS_Local_Server;" & _]
   TEXT
   "TableType=ADS_CDX;Security Mode=ADS_IGNORERIGHTS;" & _
   "Lock Mode=Compatible;" & _
   "Use NULL values in DBF Tables WITH Advantage=True;" & _
   "Exclusive=No;Deleted=No;"

' Cria Workbook no Excel, e torna-o ativo
ObjExcel.Workbooks.add
'ObjExcel.Workbooks(1).Activate
FOR EACH cSql IN cSqlList
   ' Cria nova planilha, ou seta ja' existente
   nQtdDoc = nQtdDoc + 1
'   IF nQtdDoc > ObjExcel.Workbooks(1).Worksheets.Count THEN
      ObjExcel.Workbooks(1).Worksheets.Add
'   ELSE
'      ObjExcel.Workbooks(1).Worksheets(nQtdDoc).Select
'   END IF
   ' Executa comando SQL
   SET Rs = DbConn.Execute( cSql )

   ' Coloca como titulo o nome dos campos e calcula qtd.campos
   ObjExcel.Cells(3,1).Value = "DE"
   ObjExcel.Cells(3,2).Value = "ATE"
   ObjExcel.Cells(3,3).Value = "DATA"
   ObjExcel.Cells(3,4).Value = "VIAGEM"
   ObjExcel.Cells(3,5).Value = "TIPO"
   ObjExcel.Cells(3,6).Value = "VEIC"
   ObjExcel.Cells(3,7).Value = "CTRC"
   ObjExcel.Cells(3,8).Value = "P.REAL"
   ObjExcel.Cells(3,9).Value = "P.CALC"
   ObjExcel.Cells(3,10).Value= "FRETE"
   ObjExcel.Cells(3,11).Value= "VL.MERC"
   ObjExcel.Cells(3,12).Value= "CLI"
'   nFldCount = 3
'   FOR EACH cFld IN Rs.Fields
'      ObjExcel.Cells(3,nFldCount).Value = cFld.Name
'      nFldCount = nFldCount + 1
'   NEXT

   ' Coloca conteudo dos campos nas celulas, quebrando os totais
   Rs.MoveFirst
   nLin      = 5
   cFormSub1 = "=@SUM(H5:H"
   cFormSub2 = "=@SUM(I5:I"
   cFormSub3 = "=@SUM(J5:J"
   cFormSub4 = "=@SUM(K5:K"
   cFormTot1 = "=0"
   cFormTot2 = "=0"
   cFormTot3 = "=0"
   cFormTot4 = "=0"
   DO WHILE NOT Rs.Eof
      lSubChange = "N"
      nFldCount = 1
      FOR EACH cFld IN Rs.Fields
         cCampo = "" & Rs.Fields( cFld.Name ).Value
         cCampo = REPLACE( cCampo, ",", "." )
         ObjExcel.Cells( nLin, nFldCount ).Value = cCampo
         nFldCount = nFldCount + 1
      NEXT
      nRecCount    = nRecCount + 1
      nLin         = nLin + 1
      cSubGroup    = Rs.Fields("UfCol").Value & Rs.Fields("UfCalc").Value
      Rs.MoveNEXT
      IF Rs.Eof THEN
         lSubChange = "Y"
      ELSEIF cSubGroup <> Rs.Fields("UfCol").Value & Rs.Fields("UfCalc").Value THEN
         lSubChange = "Y"
      END IF
   ENDTEXT
   TEXT
      IF lSubChange = "Y" THEN
         ObjExcel.Cells(nLin+1,3).Value  = "SUBS"
         ObjExcel.Cells(nLin+1,8).Value  = cFormSub1 & nLin-1 & ")"
         ObjExcel.Cells(nLin+1,9).Value  = cFormSub2 & nLin-1 & ")"
         ObjExcel.Cells(nLin+1,10).Value = cFormSub3 & nLin-1 & ")"
         ObjExcel.Cells(nLin+1,11).Value = cFormSub4 & nLin-1 & ")"
         cFormSub1 = "=@SUM(H" & nLin+3 & ":H"
         cFormSub2 = "=@SUM(I" & nLin+3 & ":I"
         cFormSub3 = "=@SUM(J" & nLin+3 & ":J"
         cFormSub4 = "=@SUM(K" & nLin+3 & ":K"
         cFormTot1 = cFormTot1 & "+H" & nLin+1
         cFormTot2 = cFormTot2 & "+I" & nLin+1
         cFormTot3 = cFormTot3 & "+J" & nLin+1
         cFormTot4 = cFormTot4 & "+K" & nLin+1
         nLin = nLin + 3
      END IF
   LOOP
   ObjExcel.Cells(nLin,3).Value = "TOTAIS"
   ObjExcel.Cells(nLin,8).Value = cFormTot1
   ObjExcel.Cells(nLin,9).Value = cFormTot2
   ObjExcel.Cells(nLin,10).Value = cFormTot3
   ObjExcel.Cells(nLin,11).Value = cFormTot4

   Rs.Close
   SET Rs = Nothing

   ' Formatacao
   ObjExcel.Range("A1:" & Chr(64+nFldCount) & nLin ).AutoFormat True

   ' Destaque Titulos

   cThisRange = "A3:" & Chr(64+nFldCount) & "3"
   ObjExcel.Range(cThisRange).Font.Bold = True
'   ObjExcel.Range(cThisRange).Interior.ColorIndex = 1
'   ObjExcel.Range(cThisRange).Interior.Pattern = 1
'   ObjExcel.Range(cThisRange).Font.ColorIndex = 2
   ObjExcel.Cells(1,1) = "PLANILHA"
   ObjExcel.Range("A1").Font.Bold = True
   ObjExcel.Range("A1:" & Chr(64+nFldCount) & "1").MergeCells = True

   ' Destaque Totais

   cThisRange = "A" & nLin & ":" & Chr(64+nFldCount) & nLin
   ObjExcel.Range(cThisRange).Font.Bold = True
'   ObjExcel.Range(cThisRange).Interior.ColorIndex = 1
'   ObjExcel.Range(cThisRange).Interior.Pattern = 2
'   ObjExcel.Range(cThisRange).Font.ColorIndex = 2
NEXT

   ENDTEXT
   TEXT
' Desativa Conexao
IF DbConn.State = 2 THEN
   DbConn.Close
END IF
SET DBConn = Nothing

'ObjExcel.Columns("B:B").Select
'ObjExcel.Selection.HorizontalAlignment = &hFFFFEFDD ' xlLeft
ObjExcel.Visible = True
'ObjExcel.WorkBooks(1).SaveAs "teste"
'ObjExcel.Quit
Set ObjExcel = Nothing
MsgBox("Geracao Concluida!")

   ENDTEXT
   SET CONSOLE ON
   SET ALTERNATE OFF
   SET ALTERNATE TO
   RunCmd( "WScript " + mTmpFile )

   RETURN mTmpFile
