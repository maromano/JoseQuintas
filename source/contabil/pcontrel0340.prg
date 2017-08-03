/*
PCONTREL0340 - RELACAO DOS PARAMETROS DO SISTEMA
1990.01 José Quintas
*/

#include "inkey.ch"

PROCEDURE PCONTREL0340

   LOCAL m_Menu, m_TxtMenu, m_Conf
   MEMVAR m_Param, m_TxtParam, Rel_Param, nOpcPrinterType

IF ! abrearquivos( "jptabel", "ctplano", "jpempre" )
      RETURN
   ENDIF
SELECT jpempre

rel_param = 1
IF File( "PCONTREL0340.mem" )
   RESTORE FROM ("PCONTREL0340") ADDITIVE
ENDIF

m_conf = 2

m_param = rel_param
   m_txtparam := ;
   { "Todos ", "Parâmetros Contábeis ", "Dados da Empresa ", "Dólar para cada mes ", ;
     "Livros/Páginas dos Diários ", "Relatórios Emitidos " }

nOpcPrinterType := AppPrinterType()

m_menu = 1
   m_txtmenu := Array(4)

WOpen( 5, 4, Len(m_TxtMenu)+7, 45, "Opções Disponíveis" )

DO WHILE .T.
   m_TxtMenu := { ;
      TxtImprime(), ;
      TxtSalva(), ;
      "Parametros: " + m_txtparam[ m_param ], ;
      "Saida.....: " + TxtSaida()[ nOpcPrinterType ] }

   FazAchoice( 7, 5, Len(m_TxtMenu)+6, 44, m_txtmenu, @m_menu )

   DO CASE
   CASE lastkey() == K_ESC
      EXIT

   CASE m_menu == 1
      IF ConfirmaImpressao()
         Imprime()
      ENDIF

   CASE m_menu == 2
      m_conf = 2
      WAchoice( 8, 25, TxtConf(), @m_conf, TxtSalva())
      IF m_conf == 1 .AND. lastkey() != K_ESC
         rel_param = m_param
         save ALL LIKE rel* to ("PCONTREL0340")
      ENDIF

   CASE m_menu == 3
      WAchoice( 9, 25, m_txtparam, @m_param, "Parâmetros" )

   CASE m_menu == 4
      WAchoice( 11, 25, TxtSaida(), @nOpcPrinterType, "Saída" )
      AppPrinterType( nOpcPrinterType )

   ENDCASE

ENDDO
WClose()
CLOSE DATABASES
RETURN


STATIC FUNCTION imprime()
   LOCAL oPDF, m_Ano, nNumMes, m_Relat, m_Cont, nLivro, nPagina
   MEMVAR m_Param, m_TxtParam, nOpcPrinterType

oPDF := PDFClass():New()
oPDF:SetType( nOpcPrinterType )
oPDF:Begin()

oPDF:acHeader := {"",""}
oPDF:acHeader[ 1 ] = "RELACAO DOS PARAMETROS DO SISTEMA"

IF ( m_param == 1 .OR. m_param == 2 )
   oPDF:acHeader[ 2 ] = m_txtparam[ 2 ]
   oPDF:PageHeader()
   oPDF:DrawText( oPDF:nRow +  1, 35, "Estrutura Cod. Plano de Contas..: " + jpempre->emPicture )
   oPDF:DrawText( oPDF:nRow +  3, 35, "Ano Base para Contabilizacao....: " + StrZero( jpempre->emAnoBase, 4 ) )
   oPDF:DrawText( oPDF:nRow +  5, 35, "Maximo de Meses por Diario......: " + StrZero( jpempre->emDiaMes, 2 ) )
   oPDF:DrawText( oPDF:nRow +  7, 35, "Diario com Demonstracao.........: " + iif( jpempre->emDiaDem == "S", "Sim", "Nao" ) )
   oPDF:DrawText( oPDF:nRow +  9, 35, "Diario com Balanco Patrimonial..: " + iif( jpempre->emDiaBal == "S", "Sim", "Nao" ) )
   oPDF:DrawText( oPDF:nRow + 11, 35, "Diario com Plano de Contas......: " + iif( jpempre->emDiaPla == "S", "Sim", "Nao" ) )
   oPDF:DrawText( oPDF:nRow + 15, 35, "Limite de Paginas por Livro.....: " + StrZero( jpempre->emQtdPag, 3 ) )
   oPDF:DrawText( oPDF:nRow + 17, 35, "Fechamento (em meses)...........: " + StrZero( jpempre->emFecha, 2 ) )
   oPDF:DrawText( oPDF:nRow + 19, 35, "Historico de Fechamento.........: " + jpempre->emHisFec )
   Encontra( Left( CodContabil( jpempre->emResAcu ), 11 ), "ctplano" )
   oPDF:DrawText( oPDF:nRow + 21, 35, "Resultado Acumulado.............: " + Trim( PicConta( jpempre->emResAcu ) ) + "  " + ctplano->a_nome )

ENDIF

IF ( m_param == 1 .OR. m_param == 3 )
   oPDF:acHeader[ 2 ] = m_txtparam[ 3 ]
   oPDF:PageHeader()
   oPDF:DrawText( oPDF:nRow +  1, 30, "Nome da Empresa.......................: " + AppEmpresaNome() )
   oPDF:DrawText( oPDF:nRow +  3, 30, "Endereco..............................: " + jpempre->emEndereco )
   oPDF:DrawText( oPDF:nRow +  5, 30, "Cidade................................: " + jpempre->emCidade )
   oPDF:DrawText( oPDF:nRow +  7, 30, "Estado................................: " + jpempre->emUf )
   oPDF:DrawText( oPDF:nRow +  9, 30, "C.G.C.................................: " + jpempre->emCnpj )
   oPDF:DrawText( oPDF:nRow + 11, 30, "Inscricao Estadual....................: " + jpempre->emInsEst )
   oPDF:DrawText( oPDF:nRow + 13, 30, "Local de Registro.....................: " + jpempre->emLocReg )
   oPDF:DrawText( oPDF:nRow + 15, 30, "Numero de Registro....................: " + jpempre->emNumReg )
   oPDF:DrawText( oPDF:nRow + 17, 30, "Data de Inscricao.....................: " + Dtoc(jpempre->emDatReg) )
   oPDF:DrawText( oPDF:nRow + 19, 30, "Titular da Empresa....................: " + jpempre->emTitular )
   oPDF:DrawText( oPDF:nRow + 21, 30, "Cargo do Titular......................: " + jpempre->emCarTit )
   oPDF:DrawText( oPDF:nRow + 23, 30, "Responsavel pela Contabilidade........: " + jpempre->emContador )
   oPDF:DrawText( oPDF:nRow + 25, 30, "Cargo do Responsavel..................: " + jpempre->emCarCon )
   oPDF:DrawText( oPDF:nRow + 27, 30, "C.R.C. do Responsavel.................: " + jpempre->emCrcCon )
   oPDF:DrawText( oPDF:nRow + 29, 30, "Unidade Federativa do C.R.C...........: " + jpempre->emUfCrc )
ENDIF

IF ( m_param == 1 .OR. m_param == 5 )
   oPDF:acHeader[ 2 ] = m_txtparam[ 5 ]
   oPDF:PageHeader()
   oPDF:DrawText( oPDF:nRow, 30, "------MES------" )
   oPDF:DrawText( oPDF:nRow, 49, "DIARIO" )
   oPDF:DrawText( oPDF:nRow, 63, "PAGINA" )
   oPDF:nRow += 2
   FOR m_cont = 1 TO 96
      IF oPDF:nRow > oPDF:MaxRow() - 1
         oPDF:PageHeader()
      ENDIF
      nNumMes = m_cont
      m_ano = jpempre->emAnoBase
      DO WHILE nNumMes > 12
         nNumMes = nNumMes - 12
         m_ano = m_ano + 1
      ENDDO
      oPDF:MaxRowTest()
      nLivro := nPagina := 0
      DiarioLoad( m_Cont, @nLivro, @nPagina )
      oPDF:DrawText( oPDF:nRow++, 30, pad( nomemes( nNumMes ) + "/" + StrZero( m_ano, 4 ), 20 ) + StrZero( nLivro, 4 ) + Space(10) + StrZero( nPagina, 4 ) )
   NEXT
ENDIF

IF ( m_param == 1 .OR. m_param == 6 )
   oPDF:acHeader[ 2 ] = m_txtparam[ 6 ]
   oPDF:PageHeader()
   oPDF:nRow += 2
   oPDF:DrawText( oPDF:nRow, 30, "RELATORIOS MENSAIS" + Space(18) + "EMITIDOS" )
   oPDF:nRow += 2
   m_relat = 1
   DO WHILE m_relat <= 5
      DO CASE
      CASE m_relat = 1
         oPDF:DrawText( oPDF:nRow, 30, "Livro Diario..........................:" )
      CASE m_relat = 2
         oPDF:DrawText( oPDF:nRow, 30, "Razao Analitico.......................:" )
      CASE m_relat = 3
         oPDF:DrawText( oPDF:nRow, 30, "Despesas p/ Centro de Custo...........:" )
      CASE m_relat = 4
         oPDF:DrawText( oPDF:nRow, 30, "Despesas p/ Centro de Custo (Resumido):" )
      CASE m_relat = 5
         oPDF:DrawText( oPDF:nRow, 30, "RELATORIO DE EXERCICIO" )
         oPDF:nRow += 2
         oPDF:DrawText( oPDF:nRow, 30, "Retrospectivas de Contas..............:" )
      ENDCASE
      nNumMes = Val( Substr( jpempre->emRelEmi, m_relat * 3 - 2, 2 ) ) - 1
      m_ano = jpempre->emAnoBase
      DO WHILE nNumMes > 12
         nNumMes = nNumMes - 12
         m_ano = m_ano + 1
      ENDDO
      IF m_relat # 5
         IF nNumMes = 0
            oPDF:DrawText( oPDF:nRow, 71, "NENHUM MES" )
         ELSE
            oPDF:DrawText( oPDF:nRow, 71, nomemes( nNumMes ) + "/" + StrZero( m_ano, 4 ) )
         ENDIF
      ELSE
         oPDF:DrawText( oPDF:nRow, 71, iif( nNumMes < 12, "NAO ", "" ) + "EMITIDO" )
      ENDIF
      m_relat = m_relat + 1
      oPDF:nRow += 2
   ENDDO
ENDIF
oPDF:End()
RETURN NIL
