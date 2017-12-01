/*
REXCEL1 - GERACAO EXCEL
2004 - José Quintas
*/

FUNCTION Dbf2Excel1( cSql, cPath )

   LOCAL mTmpFile, nCont

   hb_Default( @cPath, hb_cwd() )

   mTmpFile := MyTempFile( "VBS" )

   SET ALTERNATE TO ( mTmpFile )
   SET ALTERNATE ON
   SET CONSOLE OFF

   ? [Dim cSqlList(] + LTrim( Str( Len( cSql ) - 1 ) ) + [)]
   FOR nCont = 1 TO Len( cSql )
      ? [   cSqlList(] + LTrim( Str( nCont - 1 ) ) + [) = "] + cSql[ nCont ] + ["]
   NEXT
   TEXT
   DIM ObjExcel   ' Workbook do Excel
   DIM DbConn     ' Conexao com Banco
   DIM Rs         ' RecordSet
   DIM nQtdDoc    ' Qtde Documentos
   DIM nRecCount  ' Qtde Registros
   DIM nFldCount  ' Qtde Campos
   DIM cSql       ' Auxiliar com Comando Sql
   DIM cThisRange ' Auxiliar com "Range" do Excel
   ' Cria objeto do Excel
   SET ObjExcel = WScript.CREATEObject( "Excel.Application" )
   ObjExcel.Visible = True
   ' Cria conexao com Banco
   SET DbConn = CREATEObject( "ADODB.Connection" )
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
   '  Modifica data
   ' Cria Workbook no Excel, e torna-o ativo
   ObjExcel.Workbooks.add
   ObjExcel.Workbooks(1).Activate
   FOR EACH cSql IN cSqlList
      ' Cria nova planilha, ou seta ja' existente
      nQtdDoc = nQtdDoc + 1
      IF nQtdDoc > ObjExcel.Workbooks(1).Worksheets.Count THEN
         ObjExcel.Workbooks(1).Worksheets.Add
      ELSE
         ObjExcel.Workbooks(1).Worksheets(nQtdDoc).Select
      END IF
      ' Executa comando SQL
      SET Rs = DbConn.Execute( cSql )
      ' Coloca como titulo o nome dos campos e calcula qtd.campos
      nFldCount = 1
      FOR EACH cFld IN Rs.Fields
         ObjExcel.Cells(3,nFldCount).Value = UCase(cFld.Name)
         nFldCount = nFldCount + 1
      NEXT
      ' Coloca conteudo dos campos nas celulas
      nRecCount = 1
      Rs.MoveFirst
      DO WHILE NOT Rs.Eof
         nFldCount = 1
         FOR EACH cFld IN Rs.Fields
            cCampo = "" & Rs.Fields(cFld.Name).Value
            cCampo = Replace(cCampo,",",".")
            '          IF IsDate(cCampo) THEN
            '            cCampo = Format(cCampo,"YYYY-MM-DD")
            '         ENDIF
            ObjExcel.Cells(nRecCount+4,nFldCount).Value = "" & LTrim(cCampo)
            nFldCount = nFldCount + 1
         NEXT
         nRecCount = nRecCount + 1
         Rs.MoveNext
         LOOP
         ' Somatoria
         nFldCount = 1
         FOR EACH cFld IN Rs.Fields
            ObjExcel.Cells(nRecCount+5,nFldCount).Value = "=SUM(" & Chr(64+nFldCount) & "5:" & Chr(64+nFldCount) & nRecCount+4 & ")"
            nFldCount = nFldCount+1
         NEXT
         Rs.Close
         SET Rs = Nothing
         ' Formatacao
         ObjExcel.Range("A1:" & Chr(64+nFldCount) & nRecCount+5 ).AutoFormat True
         ' Destaque Titulos
         cThisRange = "A3:" & Chr(64+nFldCount) & "3"
         ObjExcel.Range(cThisRange).Font.Bold = True
         '   ObjExcel.Range(cThisRange).Interior.ColorIndex = 1
         '   ObjExcel.Range(cThisRange).Interior.Pattern = 1
         '   ObjExcel.Range(cThisRange).Font.ColorIndex = 2
         ' Destaque Totais
         cThisRange = "A" & nRecCount+5 & ":" & Chr(64+nFldCount) & nRecCount+5
         ObjExcel.Range(cThisRange).Font.Bold = True
         '   ObjExcel.Range(cThisRange).Interior.ColorIndex = 1
         '   ObjExcel.Range(cThisRange).Interior.Pattern = 2
         '   ObjExcel.Range(cThisRange).Font.ColorIndex = 2
         ObjExcel.Cells(1,1) = "PLANILHA"
         ObjExcel.Range("A1").Font.Bold = True
         ObjExcel.Range("A1:" & Chr(64+nFldCount) & "1").MergeCells = True
      NEXT
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
      SET ObjExcel = Nothing
      MsgBox("Geracao Concluida!")
      ENDTEXT
      SET CONSOLE ON
      SET ALTERNATE OFF
      SET ALTERNATE TO
      RunCmd( "WScript " + mTmpFile )

      RETURN mTmpFile
