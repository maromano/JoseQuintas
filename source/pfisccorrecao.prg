/*
PFISCCORRECAO - EMISSAO DE CARTA DE CORRECAO
1997,03 José Quintas
*/

#include "inkey.ch"

PROCEDURE pFiscCorrecao

   LOCAL m_Cont, GetList := {}
   MEMVAR m_cCont, m_CliFor, mCliente, mFornec, mnfAqui, mSerieAqui, mDataDoc, mDataCarta, m_cContAnt

   IF ! AbreArquivos( "jptabel", "jpempre", "jpcadas", "jpclista" )
      RETURN
   ENDIF
   SELECT jpcadas

   MsgExclamation( "ATENÇÃO!!! Para nota eletrônica utilize a carta de correção eletrônica!" )

   m_CliFor   := "C"
   mFornec    := EmptyValue( jpcadas->cdCodigo )
   mCliente   := EmptyValue( jpcadas->cdCodigo )
   mNfAqui    := 000000
   mSerieAqui := "  "
   mDataDoc   := Date()
   mDataCarta := Date()

   FOR m_Cont = 1 TO 9
      m_CCont := str( m_Cont, 1 )
      m_Irreg&m_CCont := Space(6)
      m_Descr&m_CCont := Space(27)
   NEXT

   @ 3, 1 SAY "NF (C)li (F)ornec:"
   @ 4, 1 SAY "Cliente/Fornec...:"
   @ 5, 1 SAY "NF/CTRC     Num..:"
   @ 6, 1 SAY "            Série:"
   @ 7, 1 SAY "            Data.:"
   @ 8, 1 SAY "Data da Carta....:"
   FOR m_Cont = 1 TO 9
      @ 8 + m_Cont, 1 SAY "Irreg. " + StrZero( m_Cont, 2 ) + "........:"
   NEXT
   DO WHILE .T.
     Scroll( 4, 20, MaxRow() - 3, MaxCol(), 0 )
     mFornec  := EmptyValue( jpcadas->cdCodigo )
     mCliente := EmptyValue( jpcadas->cdCodigo )
     @ 3, 20 GET m_CliFor  PICTURE "!A" VALID m_CliFor $ "CF"
     @ 3, 20 GET mFornec  PICTURE "@K 999999" WHEN m_CliFor == "F" VALID JPCADAS1Class():Valida( @mFornec )
     @ 4, 20 GET mCliente PICTURE "@K 999999" WHEN m_CliFor == "C" VALID JPCADAS1Class():Valida( @mCliente )
     @ 5, 20 GET mNfAqui      PICTURE "@K 999999"
     @ 6, 20 GET mSerieAqui   PICTURE "@K!"
     @ 7, 20 GET mDataDoc
     @ 8, 20 GET mDataCarta
     FOR m_Cont = 1 TO 9
        m_CCont    := Str( m_Cont, 1 )
        m_CContAnt := Str( m_Cont - 1, 1 )
        IF m_Cont = 1
           @ 8 + m_Cont, 20 GET m_Irreg&m_CCont PICTURE "@K 999999" VALID Val( m_Irreg&m_cCont ) == 0 .OR. AUXCARCORClass():Valida( @m_Irreg&m_CCont, .F. )
        ELSE
           @ 8 + m_Cont, 20 GET m_Irreg&m_CCont WHEN Val( m_Irreg&m_CContAnt ) != 0 PICTURE "@K 999999" VALID Val( m_Irreg&m_cCont ) == 0 .OR. AUXCARCORClass():Valida( @m_Irreg&m_CCont, .F. )
        ENDIF
     NEXT
     Mensagem( "Digite dados, F9 Pesquisa, ESC Sai" )
     READ
     Mensagem()
     IF lastkey() == K_ESC
        EXIT
     ENDIF

     FOR m_Cont = 1 TO 9
       m_CCont := Str( m_Cont, 1 )
       IF Val( m_Irreg&m_CCont ) != 0
          m_Descr&m_CCont := Pad( AUXCARCORClass():Descricao( m_Irreg&m_cCont ), 77 )
          @ 8+m_Cont, 20 GET m_Descr&m_CCont PICTURE "@KS55"
       ELSE
          m_Descr&m_CCont := Space(77)
          @ 8+m_Cont, 20 SAY left(m_Descr&m_CCont,55)
       ENDIF
     NEXT
     Mensagem( "Digite as descrições, F9 Pesquisa, ESC Sai" )
     READ
     Mensagem()
     IF lastkey() == K_ESC
        EXIT
     ENDIF

     IF ConfirmaImpressao()
        Imprime()
     ENDIF

   ENDDO

   RETURN

STATIC FUNCTION imprime()

   LOCAL oPDF, m_Cont, m_Cont2, m_Codigo
   MEMVAR m_CCont, m_CliFor, mCliente, mFornec, mnfAqui, mSerieAqui, mDataDoc, mDataCarta, m_x

   m_x := Array( 36 )
   Afill( m_x, Space(3) )

   FOR m_Cont = 1 TO 9
      m_CCont  := Str(m_Cont,1)
      m_Codigo := Val( m_Irreg&m_CCont )
      IF m_Codigo > 0 .AND. m_Codigo < 37
         m_x[ m_Codigo ] := " X "
      ENDIF
   NEXT

   oPDF := PDFClass():New()
   oPDF:SetType( 2 )
   oPDF:Begin()
   oPDF:PageHeader()
   oPDF:DrawText( oPDF:nRow++, 0, " " + Trim( jpempre->emCidade ) + ", " + Extenso( mDataCarta ) )
   oPDF:DrawText( oPDF:nRow++, 0, Space(85) + ".----------" + Space(21) + "----------." )
   oPDF:DrawText( oPDF:nRow++, 0, " A" + Space(83) + "!" + Space(41) + "!" )
   oPDF:DrawText( oPDF:nRow++, 0, " " + jpcadas->cdNome )
   oPDF:DrawText( oPDF:nRow++, 0, " " + jpcadas->cdEndereco )
   oPDF:DrawText( oPDF:nRow++, 0, " " + Trim( jpcadas->cdCidade ) + " - " + jpcadas->cdUf )
   oPDF:nRow += 1
   oPDF:DrawText( oPDF:nRow++, 0, " Prezado(s) Senhor(es)" )
   oPDF:nRow += 1
   oPDF:DrawText( oPDF:nRow++, 0, "         Ref.: CONFERENCIA DE DOCUMENTO FISCAL E COMUNICACAO DE INCORRECOES" )
   oPDF:DrawText( oPDF:nRow++, 0, Space(85) + "!" + Space(41) + "!" )
   oPDF:DrawText( oPDF:nRow++, 0, "            (X) " + iif( m_CliFor == "F", "S", "N" ) + "/ NOTA FISCAL No. " + str( mNfAqui ) + " SERIE " + mSerieAqui + " DE " + dtoc( mDataDoc ) + ;
     Space(23) + "`----------" + Space(21) + "----------'" )
   oPDF:nRow += 1
   oPDF:DrawText( oPDF:nRow++, 0, "      Em face do que determina a legislacao fiscal vigente, vimos pela presente comunicar-lhe(s) que o  documento  em referencia" )
   oPDF:DrawText( oPDF:nRow++, 0, " contem a(s) irregularidade(s) que abaixo apontamos, cuja correcao solicitamos seja providenciada imediatamente." )
   oPDF:nRow += 1
   oPDF:DrawText( oPDF:nRow, 0, "" )
   FOR m_Cont=1 TO 3
      oPDF:DrawText( oPDF:nRow, oPDF:nCol, " .---------------------------------------. " )
   NEXT
   oPDF:nRow += 1
   oPDF:DrawText( oPDF:nRow, 0, "" )
   FOR m_Cont = 1 TO 3
      oPDF:DrawText( oPDF:nRow, oPDF:nCol, " !  Codigo   !      Especificacao        ! " )
   NEXT
   oPDF:nRow += 1
   oPDF:DrawText( oPDF:nRow, 0, "" )
   FOR m_Cont = 1 TO 3
      oPDF:DrawText( oPDF:nRow, oPDF:nCol, " !-----------!---------------------------! " )
   NEXT
   oPDF:nRow += 1
   FOR m_Cont = 1 TO 12
      oPDF:DrawText( oPDF:nRow, 0, "" )
      FOR m_Cont2 = 0 TO 24 STEP 12
         oPDF:DrawText( oPDF:nRow, oPDF:nCol, " !" + m_x[ m_Cont + m_Cont2 ] + "!  " + StrZero( m_Cont + m_Cont2, 2 ) + "   !" + Pad( AUXCARCORClass():Descricao( StrZero( m_Cont + m_Cont2, 6 ) ), 27 ) + "! " )
      NEXT
      oPDF:nRow += 1
   NEXT
   oPDF:DrawText( oPDF:nRow++, 0, " `---------------------------------------'  `---------------------------------------'  `---------------------------------------'" )
   oPDF:DrawText( oPDF:nRow++, 0, " ." + Replicate( "-", 125 ) + "." )
   oPDF:DrawText( oPDF:nRow++, 0, " ! Codigos com Irregularidades !                   Retificacoes a Serem Consideradas                                           !" )
   oPDF:DrawText( oPDF:nRow++, 0, " !-----------------------------!-----------------------------------------------------------------------------------------------!" )
   FOR m_Cont = 1 TO 9
     m_CCont = str(m_Cont,1)
     oPDF:DrawText( oPDF:nRow++, 0, " !              "+iif( Val( m_irreg&m_CCont ) == 0, "  ", StrZero( Val( m_irreg&m_CCont ), 2 ) ) + "             ! " + Pad( m_descr&m_CCont, 94 ) + "!" )
   NEXT
   oPDF:DrawText( oPDF:nRow++, 0, " `"+ Replicate( "-", 125 ) + "'" )
   oPDF:DrawText( oPDF:nRow++, 0, "      Para evitar-se de qualquer sancao fiscal, solicitamos acusarem o recebimento desta, na copia que a  acompanha,  devendo  a" )
   oPDF:DrawText( oPDF:nRow++, 0, " via de V. S(as) ficar arquivada juntamente com a Nota Fiscal em questao." )
   oPDF:nRow += 1
   oPDF:DrawText( oPDF:nRow++, 0, "      Sem outro motivo para o momento, subscrevemos-nos" )
   oPDF:nRow += 1
   oPDF:DrawText( oPDF:nRow++, 0, " .---------- Acusamos recebimento da 1a via ----------." )
   oPDF:DrawText( oPDF:nRow++, 0, " !" + Space(52) + "!" )
   oPDF:DrawText( oPDF:nRow++, 0, " !" + Space(52) + "!" + Space(37) + "Atenciosamente" )
   oPDF:DrawText( oPDF:nRow++, 0, " !" + Space(52) + "!" )
   oPDF:DrawText( oPDF:nRow++, 0, " !----------------------------------------------------!" )
   oPDF:DrawText( oPDF:nRow++, 0, " !                   (Local e Data)                   !" )
   oPDF:DrawText( oPDF:nRow++, 0, " !" + Space(52) + "!" )
   oPDF:DrawText( oPDF:nRow++, 0, " !" + Space(52) + "!" )
   oPDF:DrawText( oPDF:nRow++, 0, " !" + Space(52) + "!" )
   oPDF:DrawText( oPDF:nRow++, 0, " !----------------------------------------------------!                  " + Replicate("-",51) )
   oPDF:DrawText( oPDF:nRow++, 0, " !               (Carimbo e Assinatura)               !                                (Carimbo e Assinatura)" )
   oPDF:DrawText( oPDF:nRow++, 0, " `----------------------------------------------------'" )
   oPDF:End()

   RETURN .T.
