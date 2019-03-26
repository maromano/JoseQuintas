/*
ZE_GERATABANP Gera tabelas ANP a partir dos XMLs
2017.07.05 Jos� Quintas
*/

#include "inkey.ch"
#include "directry.ch"

#define ANPAGE_CODIGO      0
#define ANPAGE_CNPJPREFIXO 1
#define ANPAGE_VALIDADE    10
#define ANPATI_CODIGO      0
#define ANPATI_NOME        1
#define ANPATI_VALIDADE    3
#define ANPINS_CODIGO      0
#define ANPINS_CNPJ        1
#define ANPINS_VALIDADE    19
#define ANPLOC_CODIGO      0
#define ANPLOC_IBGE        1
#define ANPLOC_NOME        2
#define ANPLOC_UF          3
#define ANPLOC_VALIDADE    5
#define ANPOPE_CODIGO      5
#define ANPOPE_NOME        3
#define ANPOPE_VALIDADE    7
#define ANPPRO_CODIGO      5
#define ANPPRO_DESCRICAO   4
#define ANPPRO_VALIDADE    12

PROCEDURE GeraTabAnp

   IF ! MsgYesNo( "Confirma" )
      RETURN
   ENDIF
   ExcelToPrg( "AnpAge", "T001", { "AgenteRegulado" },     { ANPAGE_CODIGO, ANPAGE_CNPJPREFIXO },                  { "C�digo", "CNPJ PRefixo" },    ANPAGE_VALIDADE )
   ExcelToPrg( "AnpAti", "T002", { "AtividadeEconomica" }, { ANPATI_CODIGO, ANPATI_NOME },                         { "C�digo", "Nome" },            ANPATI_VALIDADE )
   ExcelToPrg( "AnpIns", "T008", { "Parte_1", "Parte_2", "Parte_3" }, { ANPINS_CODIGO, ANPINS_CNPJ },                         { "C�digo", "CNPJ" },            ANPINS_VALIDADE )
   ExcelToPrg( "AnpOpe", "T011", { "Opera��o" },           { ANPOPE_CODIGO, ANPOPE_NOME },                         { "C�digo", "Nome" },            ANPOPE_VALIDADE )
   ExcelToPrg( "AnpLoc", "T018", { "Localidade" },         { ANPLOC_CODIGO, ANPLOC_IBGE, ANPLOC_UF, ANPLOC_NOME }, { "ANP", "IBGE", "UF", "NOME" }, ANPLOC_VALIDADE )
   ExcelToPrg( "AnpPro", "T012", { "Produto" },            { ANPPRO_CODIGO, ANPPRO_DESCRICAO }, ANPPRO_VALIDADE )

   RETURN

FUNCTION ExcelToPRG( cTabAnp, cFilePrefix, aPlanilhaList, aFieldList, aDescList, nFieldValidade )

   LOCAL aFiles, cFileExcel, cnExcel, cPlanilha, nField, cTxt := "", cDesc, nTotal, nAtual, nKey := 0

   cTxt += [// ]
   FOR EACH cDesc IN aDescList
      cTxt += cDesc + [, ]
   NEXT
   cTxt += hb_Eol() + hb_Eol()
   cTxt := [FUNCTION ze_Tab] + cTabAnp + [()] + hb_Eol() + hb_Eol()
   cTxt += [   LOCAL aList := {}] + hb_Eol() + hb_Eol()
   aFiles := Directory( hb_cwd() + "importa\" + cFilePrefix + "*.XLS" )
   IF Len( aFiles ) == 0
      SayScroll( "Tabela " + cTabAnp + " n�o encontrada" )
      RETURN NIL
   ENDIF
   cFileExcel := hb_cwd() + "importa\" + aFiles[ 1, F_NAME ]
   SayScroll( cFileExcel )
   cnExcel := ADOClass():New( ExcelConnection( cFileExcel ) )
   cnExcel:Open()
   FOR EACH cPlanilha IN aPlanilhaList
      GrafTempo( "Importando " + cTabAnp + " " + cPlanilha )
      cnExcel:cSql := "SELECT COUNT(*) AS QTD FROM [" + cPlanilha + "$]"
      nTotal := cnExcel:ReturnValueAndClose( "QTD" )
      nAtual := 0
      cnExcel:cSql := "SELECT * FROM [" + cPlanilha + "$]"
      cnExcel:Execute()
      cnExcel:MoveNext() // pular titulo
      SayScroll( cTabAnp + " " + Ltrim( Str( nFieldValidade ) ) )
      DO WHILE nKey != K_ESC .AND. ! cnExcel:Eof()
         nKey := Inkey()
         GrafTempo( nAtual++, nTotal )
         IF ! Empty( cnExcel:Value( nFieldValidade ) ) .AND. cnExcel:Value( nFieldValidade ) < Dtos( Date() )
            SayScroll( cTabAnp + " " + cnExcel:Value( nFieldValidade ) )
            cnExcel:MoveNext()
            LOOP
         ENDIF
         cTxt += [   AAdd( aList, { ]
         FOR EACH nField IN aFieldList
            cTxt += ["] + RetiraAcento( Transform( cnExcel:Value( nField ), "" ) ) + ["] + iif( nField:__EnumIndex == Len( aFieldList ), [], [, ] )
         NEXT
         cTxt += [ } )] + hb_Eol()
         cnExcel:MoveNext()
      ENDDO
      cnExcel:Rs:Close()
      IF nKey == K_ESC
         EXIT
      ENDIF
   NEXT
   cnExcel:Close()
   cTxt += hb_Eol() + [   RETURN NIL] + hb_Eol() + hb_Eol()
   hb_MemoWrit( "\temp\ze_tab" + Lower( cTabAnp ) + ".prg", cTxt )

   RETURN NIL

STATIC FUNCTION RetiraAcento( cTexto )

   LOCAL cLetra

   cTexto := Upper( cTexto )
   cTexto := StrTran( cTexto, Chr(0), "" )
   cTexto := StrTran( cTexto, Chr(34), " " )
   FOR EACH cLetra IN @cTexto
      DO CASE
      CASE cLetra $ "abcdefghijklmnopqrstuvwxyz"
      CASE cLetra $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      CASE cLetra $ "0123456789"
      CASE cLetra $ " /,.()-;.:"
      CASE cLetra $ "�����" ; cLetra := "A"
      CASE cLetra $ "��"  ; cLetra := "E"
      CASE cLetra $ "�"  ; cLetra := "I"
      CASE cLetra $ "�����" ; cLetra := "O"
      CASE cLetra $ "�"  ; cLetra := "C"
      CASE cLetra $ "��"  ; cLetra := "U"
      CASE cLetra == Chr(0) ; cLetra := ""
      OTHERWISE
         ? cLetra, Asc( cLetra ), cLetra:__EnumIndex, Substr( cTexto, cLetra:__EnumIndex - 25, 50 )
      ENDCASE
   NEXT

   RETURN cTexto
