/*
PCONTREL0370 - RELACAO DE HISTORICOS PADRAO
1990 José Quintas
*/

#include "inkey.ch"

PROCEDURE PCONTREL0370

   LOCAL GetList := {}, m_Menu, m_TxtMenu
   MEMVAR m_DeAte, mhiHisPadi, mhiHisPadf, m_TxtDeAte, m_Ordem, m_TxtOrdem, nOpcPrinterType

IF ! abrearquivos( "jpempre", "cthisto" )
      RETURN
   ENDIF
SELECT cthisto

m_deate  := 1
mhiHisPadi := mhiHisPadf := Space(6)
   m_txtdeate := { "Todos", "Intervalo" }

m_ordem := 1
   m_txtordem := { "Código", "Descrição" }

nOpcPrinterType := AppPrinterType()

m_menu := 1
   m_txtmenu := Array(5)

WOpen( 5, 4, Len(m_TxtMenu)+7, 45, "Opções disponíveis" )

DO WHILE .T.
   m_TxtMenu := { ;
      TxtImprime(), ;
      TxtSalva(), ;
      "Intervalo.: " + iif( m_DeAte==1, m_txtdeate[ 1 ], ;
         mhiHisPadi + " A " + mhiHisPadf ), ;
      "Ordem.....: " + m_txtordem[m_ordem], ;
      "Saída.....: " + TxtSaida()[ nOpcPrinterType ] }

   FazAchoice( 7, 5, Len(m_TxtMenu)+6, 44, m_txtmenu, @m_menu )

   DO CASE
   CASE lastkey() == K_ESC
      EXIT

   CASE m_menu == 1
      IF ConfirmaImpressao()
         Imprime()
      ENDIF

   CASE m_menu == 2

   CASE m_menu == 3
      WOpen( 9, 25, 13, 65, "Intervalo" )
      DO WHILE .T.
         FazAchoice( 11, 26, 12, 64, m_txtdeate, @m_deate )
         IF LastKey() != K_ESC .AND. m_deate == 2
            WOpen( 12, 45, 16, 65, "C.Hist." )
            @ 14, 47 GET mhiHisPadi PICTURE "@k 999999"   VALID CTHISTOClass():Valida( @mhiHisPadi )
            @ 15, 47 GET mhiHisPadf PICTURE "@k 999999"   VALID CTHISTOClass():Valida( @mhiHisPadf )
            Mensagem( "Digite Código do Histórico, F9 pesquisa, ESC sai" )
            READ
            WClose()
            IF LastKey() == K_ESC
               LOOP
            ENDIF
         ENDIF
         EXIT
      ENDDO
      WClose()

   CASE m_menu == 4
      WAchoice( 10, 25, m_txtordem, @m_ordem, "Ordem" )

   CASE m_menu == 5
      WAchoice( 12, 25, TxtSaida(), @nOpcPrinterType, "Saída" )
      AppPrinterType( nOpcPrinterType )

   ENDCASE

ENDDO
WClose()
CLOSE DATABASES
RETURN


STATIC FUNCTION imprime()
   LOCAL oPDF, nKey
   MEMVAR m_DeAte, mhiHisPadi, mhiHisPadf, m_Ordem, m_TxtOrdem, nOpcPrinterType

oPDF := PDFClass():New()
oPDF:SetType( nOpcPrinterType )
oPDF:Begin()

oPDF:acHeader := {"","",""}
oPDF:acHeader[ 1 ] := "RELACAO DE HISTORICOS PADRAO"
oPDF:acHeader[ 2 ] := "Ordem: " + Trim( m_txtordem[m_ordem] )
IF m_deate == 2
   oPDF:acHeader[ 2 ] += ", de: " + mhiHisPadi + "ate': " + mhiHisPadf
ENDIF
oPDF:acHeader[ 2 ] := Trim( oPDF:acHeader[ 2 ] )
oPDF:acHeader[ 3 ] := SPACE(8) + "CODIGO        -----------------" + ;
                "-----------------------  H I S T O R I C O" + ;
                "  -----------------------------------------"
nKey := 0

OrdSetFocus(iif(m_Ordem==1,"numlan","descricao"))
IF m_deate == 2 .AND. m_ordem == 1
   SEEK mhiHisPadi
ELSE
   GOTO TOP
ENDIF

DO WHILE nKey != K_ESC .AND. ! eof()
   nKey := Inkey()
   DO CASE
   CASE cthisto->hiHisPad > mhiHisPadf .AND. m_deate == 2 .AND. m_ordem == 1
      EXIT
   CASE ( cthisto->hiHisPad < mhiHisPadi .OR. cthisto->hiHisPad > mhiHisPadf ) .AND. m_deate == 2
      SKIP
      LOOP
   CASE oPDF:nRow > oPDF:MaxRow() - 9
      oPDF:PageHeader()
   ENDCASE
   oPDF:DrawText( oPDF:nRow, 8, cthisto->hiHisPad )
   oPDF:DrawText( oPDF:nRow, 22, Substr(cthisto->hiDescri,1,100) )
   IF Len(Trim(Substr(cthisto->hiDescri,101,100))) <> 0
      oPDF:nRow++
      oPDF:DrawText( oPDF:nRow, 22, Substr(cthisto->hiDescri,101,100) )
   ENDIF
   IF Len(Trim(Substr(cthisto->hiDescri,201,50))) <> 0
      oPDF:nRow++
      oPDF:DrawText( oPDF:nRow, 22, Substr(cthisto->hiDescri,201) )
   ENDIF
   oPDF:nRow += 2
   SKIP
ENDDO
OrdSetFocus("numlan")
oPDF:End()
RETURN NIL
