/*
PCONTREL0390 - TERMOS DE ABERTURA/ENCERRAMENTO
05.08.92 - José Quintas

...
*----------------------------------------------------------------
*/

#include "inkey.ch"

PROCEDURE PCONTREL0390

   LOCAL GetList := {}, m_Menu, m_TxtMenu
   MEMVAR m_Livro, m_QtPag, m_DataAb, m_DataFe, Rel_Formu, nOpcPrinterType
   PRIVATE m_Livro, m_QtPag, m_DataAb, m_DataFe, Rel_Formu

   IF ! AbreArquivos( "jpempre" )
      RETURN
   ENDIF
   SELECT jpempre

   Rel_Formu = 1

   nOpcPrinterType := AppPrinterType()

   m_Menu = 1
      m_TxtMenu := Array(3)

   WOpen( 5, 4, 7 + Len( m_TxtMenu ), 45, "Opções disponíveis" )

   DO WHILE .T.
      m_TxtMenu := { ;
         TxtImprime(), ;
         TxtSalva(), ;
         "Saida.....: " + TxtSaida()[ nOpcPrinterType ] }

      FazAchoice( 7, 5, 10, 44, m_TxtMenu, @m_Menu )

      DO CASE
      CASE lastkey() == K_ESC
         EXIT

      CASE m_Menu == 1
         m_Livro  := 1
         m_QtPag  := jpempre->emQtdPag
         m_DataAb := Ctod( "01/01/" + StrZero( jpempre->emAnoBase, 4 ) )
         m_DataFe := Ctod( "31/12/" + StrZero( jpempre->emAnoBase, 4 ) )
         Mensagem()
         wOpen( 5, 5, 12, 40, "Livro e Página" )
         @  7, 7 SAY "Livro...:" GET m_Livro      PICTURE "9999" VALID m_Livro > 0
         @  8, 7 SAY "Qt.Pág..:" GET m_QtPag      PICTURE "9999" VALID m_QtPag > 0
         @  9, 7 SAY "Dt.Inic.:" GET m_DataAb     VALID ! Empty( m_DataAb )
         @ 10, 7 SAY "Dt.Final:" GET m_DataFe     VALID ! Empty( m_DataFe )
         READ
         wClose()
         IF lastkey() == K_ESC
            LOOP
         ENDIF
         IF ConfirmaImpressao()
            DO p390_rel
         ENDIF

      CASE m_Menu == 2

      CASE m_Menu == 3
         WAchoice( 10, 25, TxtSaida(), @nOpcPrinterType, "Saída" )
         AppPrinterType( nOpcPrinterType )

      ENDCASE

   ENDDO
   WClose()
   CLOSE DATABASES

   RETURN

STATIC PROCEDURE p390_rel

   MEMVAR oPDF, m_QtPag, nOpcPrinterType
   PRIVATE oPDF

   oPDF := PDFClass():New()
   oPDF:SetType( nOpcPrinterType )
   oPDF:Begin()

   TermoLivroDiario( "ABERTURA",     m_QtPag )
   TermoLivroDiario( "ENCERRAMENTO", m_QtPag )

   oPDF:End()

   RETURN

FUNCTION TermoLivroDiario( m_Termo, m_TPag )

   LOCAL mTemp, mTermoDatIni, mTermoDatFim, m_Texto, mData, m_Lim
   MEMVAR oPDF, m_DataAb, m_DataFe, m_Livro
   PRIVATE m_NumMes, m_NumAno

   IF Type( "m_DataAb" ) != "D"
      mTermoDatIni := Ctod( "01/01/" + StrZero( jpempre->emAnoBase, 4 ) )
      mTermoDatFim := Ctod( "31/12/" + StrZero( jpempre->emAnoBase, 4 ) )
   ELSE
      mTermoDatIni := m_DataAb
      mTermoDatFim := m_DataFe
   ENDIF
   mData = iif( m_Termo == "ABERTURA", mTermoDatIni, mTermoDatFim )
   mTemp := aClone( oPDF:acHeader )

   m_Lim   = m_Tpag
   m_Tpag  = iif( m_Termo == "ABERTURA", 1, m_Lim )

   oPDF:acHeader := { "LIVRO DIARIO" }
   oPDF:nPageNumber = iif( m_Termo == "ABERTURA", 0, m_TPag - 1 )
   oPDF:PageHeader()
   oPDF:DrawText( 9, 0 + int( ( ( oPDF:MaxCol() + 1 ) - Len( "TERMO  DE  " + m_Termo ) ) / 2 ), "TERMO  DE  " + m_Termo )
   oPDF:nRow = 12
   IF jpempre->emDiaTer $ " 1"
      p390_ImpCentralizado( "NOME DO LIVRO: LIVRO DIARIO" )
      oPDF:nRow++
      p390_ImpCentralizado( "Numero de Ordem:" + StrZero( m_Livro, 4 ) )
      oPDF:nRow++
      oPDF:nRow++
      m_Texto = "Contem este livro " + StrZero( m_Lim, 4 ) + " folhas numeradas eletronicamente de 0001 a " + ;
                StrZero( m_Lim, 4 ) + ", que " + iif( m_Termo == "ABERTURA", "servira", "serviu" ) + ;
                " de Diario Geral Numero " + StrZero( m_Livro, 4 ) + ", correspondendo ao periodo de " + Dtoc( mTermoDatIni ) + ;
                " ate " + Dtoc( mTermoDatFim ) + ", "
      m_Texto += "da sociedade " + Trim( AppEmpresaNome() ) + ", estabelecida a " + Trim( jpempre->emEndereco ) + ;
                " " + Trim( jpempre->emBairro ) + " em " + Trim( jpempre->emCidade ) + " - " + jpempre->emUf + ", registrada "
      m_Texto += Trim( jpempre->emLocReg ) + " "
      m_Texto += "sob numero " + Trim( jpempre->emNumReg ) + ", em " + Extenso( jpempre->emDatReg )
      m_Texto += ",  no CNPJ numero " + jpempre->emCnpj + " e Inscricao Estadual numero " + Trim( jpempre->emInsEst ) + "."

      p390_imp( m_Texto )

      m_Texto = "Declaramos sob pena de responsabilidade, que " + iif( m_Termo == "ABERTURA", "serao", "foram" ) + ;
                " escrituradas folhas de no. 0001 a " + StrZero( m_Lim, 4 ) + ", de acordo com a " + ;
                "instrucao normativa numero 3, de 19/08/86, do DNRC."
      oPDF:nRow += 1
      p390_imp( m_Texto )
   ELSE
      m_Texto := "O presente livro possui " + StrZero( m_Lim, 4 ) + " numeradas do numero " + StrZero( 1, 4 ) + " ao " + StrZero( m_Lim, 4 ) + ;
      " e " + iif( m_Termo == "ABERTURA", "servira", "serviu" ) + " para a escrituracao dos lancamentos proprios da sociedade empresaria abaixo identificada:"
      p390_Imp( m_Texto )
      oPDF:nRow++
      oPDF:DrawText( oPDF:nRow++, 5, "Nome empresarial: " + jpempre->emNome )
      oPDF:DrawText( oPDF:nRow++, 5, "Municipio:" + jpempre->emNome )
      oPDF:DrawText( oPDF:nRow++, 5, "Registro na JUCESP - NIRE:" + jpempre->emNumReg )
      oPDF:DrawText( oPDF:nRow++, 5, "Data do arquivamento dos atos constitutivos:" + Dtoc( jpempre->emDatReg ) )
      oPDF:DrawText( oPDF:nRow++, 5, "CNPJ:" + jpempre->emCnpj )
   ENDIF

   m_Texto = Trim( jpempre->emCidade ) + ", " + Extenso( mData )

   oPDF:DrawText( oPDF:nRow + 5, 63 + int( ( 54 - Len( m_Texto ) ) / 2 ), m_Texto )

   oPDF:DrawText( oPDF:nRow + 15, 21, "----------------------------------------" )
   oPDF:DrawText( oPDF:nRow + 15, 71, "----------------------------------------" )

   m_Texto = Trim( jpempre->emTitular )
   oPDF:DrawText( oPDF:nRow + 16, 21 + int( ( 40 - Len( m_Texto ) ) / 2 ), m_Texto )

   m_Texto = Trim( jpempre->emContador )
   oPDF:DrawText( oPDF:nRow + 16, 71 + int( ( 40 - Len( m_Texto ) ) / 2 ), m_Texto )

   m_Texto = Trim( jpempre->emCarTit)
   oPDF:DrawText( oPDF:nRow + 17, 21 + int( ( 40 - Len( m_Texto ) ) / 2 ), m_Texto )

   m_Texto = Trim( Pad( Trim( jpempre->emCarCon ) + " - CRC:" + Trim( jpempre->emCrcCon ) + ": " + Trim( jpempre->emUfCrc ), 40 ) )
   oPDF:DrawText( oPDF:nRow + 17, 71 + int( ( 40 - Len( m_Texto ) ) / 2 ), m_Texto )

   //oPDF:PageFooter()
   oPDF:acHeader := aClone( mTemp )

   RETURN .T.

STATIC FUNCTION p390_imp( cTexto )

   LOCAL m_Texto2, m_Posi
   MEMVAR oPDF

   DO WHILE Len( cTexto ) > 0
      m_Posi = Rat( " ", Left( cTexto + " ", 66 ) )
      IF m_Posi == 0
         m_Posi = 66
      ENDIF
      m_Texto2 = Left( cTexto, m_Posi - 1 )
      cTexto  = LTrim( Substr( cTexto, m_Posi ) )
      IF Len( cTexto ) != 0
         m_Texto2 := TextoAjustado( @m_Texto2, 65 )
      ENDIF
      oPDF:DrawText( oPDF:nRow, 33, m_Texto2 )
      oPDF:nRow += 2
   ENDDO

   RETURN .T.

STATIC FUNCTION TextoAjustado( cTexto, nLen )

   LOCAL nEspaco

   nEspaco = At( " ", cTexto )
   IF nEspaco != 0
      DO WHILE Len( cTexto ) < nLen
         cTexto = Stuff( cTexto, nEspaco, 0, " " )
         DO WHILE Substr( cTexto, nEspaco, 1 ) == " " .AND. nEspaco <= Len( cTexto )
            nEspaco += 1
         ENDDO
         DO WHILE Substr( cTexto, nEspaco, 1 ) != " " .AND. nEspaco <= Len( cTexto )
            nEspaco += 1
         ENDDO
         IF nEspaco >= Len( cTexto )
            nEspaco = at( " ", cTexto )
         ENDIF
      ENDDO
   ENDIF

   RETURN cTexto

STATIC FUNCTION P390_ImpCentralizado( cTexto )

   MEMVAR oPDF

   oPDF:DrawText( oPDF:nRow, 5 + Int( ( oPDF:MaxCol() - Len( cTexto ) - 10 ) / 2 ), cTexto )

   RETURN NIL
