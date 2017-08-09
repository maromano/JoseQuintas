/*
XLSTOPRG - Converte Excel para fonte PRG
José Quintas
*/

REQUEST HB_CODEPAGE_PTISO

#include "inkey.ch"
#include "directry.ch"

#define AD_SCHEMA_TABLES 20

PROCEDURE Main

   LOCAL cn, rs, cName, cTxt := "", nCont, oFile, aFileList, cPath := "d:\temp\"

   aFileList := Directory( cPath + "*.xls" )

   Set( _SET_CODEPAGE, "PTISO" )
   SET DATE BRITISH
   FOR EACH oFile IN aFileList
      ? oFile[ F_NAME]
      cn := ExcelConnection( cPath + oFile[ F_NAME ] )
      cn:Open()
      cName := ExcelSheetName( cn )
      rs := cn:Execute( "SELECT * FROM [" + cName + "]" )
      cTxt += [FUNCTION jq_] + hb_FNameName( oFile[ F_NAME ] ) + [()] + hb_Eol()
      cTxt += hb_Eol()
      cTxt += [   LOCAL aList := {}] + hb_Eol() + hb_Eol()
      DO WHILE Inkey() != K_ESC .AND. ! Rs:Eof()
         cTxt += [   AAdd( aList, { ]
         FOR nCont = 0 TO rs:Fields:Count() - 1
            cTxt += ToString( rs:Fields( nCont ):Value ) + iif( nCont == rs:Fields:Count() - 1, "", ", " )
         NEXT
         cTxt += [ } )] + hb_Eol()
         rs:MoveNext()
      ENDDO
      rs:Close()
      cn:Close()
      cn := NIL
      cTxt += hb_Eol() + [   RETURN aList]
      hb_MemoWrit( cPath + [jq_] + hb_FNameName( oFile[ F_NAME ] ) + [.prg], cTxt )
      cTxt := ""
   NEXT

   RETURN

FUNCTION ExcelConnection( cFileName )

   LOCAL oConexao

   oConexao := win_OleCreateObject( "ADODB.Connection" )
   oConexao:ConnectionString := ;
      [Provider=Microsoft.Jet.OLEDB.4.0;Data Source=] + cFileName + ;
      [;Extended Properties="] + iif( ".xlsx" $ cFileName, [Excel.12.0 Xml], [Excel 8.0] ) + [";] // HDR=Yes;IMEX=1";] // alterado em 16/10 pra teste

   RETURN oConexao

FUNCTION ExcelSheetName( cn )

   LOCAL cSheetName, Rs

   rs := cn:OpenSchema( AD_SCHEMA_TABLES )
   cSheetName := rs:Fields( "TABLE_NAME" ):Value
   rs:Close()

   RETURN cSheetName

FUNCTION ToSTring( xValue )

   DO CASE
   CASE xValue == NIL
      xValue := [""]
   CASE ValType( xValue ) == "D"
      xValue := ["] + Dtos( xValue ) + ["]
   CASE ValType( xValue ) == "N"
      xValue := Ltrim( Str( xValue ) )
      IF "." $ xValue
         DO WHILE Right( xValue, 1 ) == "0"
            xValue := Substr( xValue, 1, Len( xValue ) - 1 )
         ENDDO
         IF Right( xValue, 1 ) == "."
            xValue := Substr( xValue, 1, Len( xValue ) - 1 )
         ENDIF
      ENDIF
   OTHERWISE
      xValue := ["] + StrTran( xValue, ["], [] ) + ["]
   ENDCASE

   RETURN xValue
