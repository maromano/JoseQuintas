/*
RMENU - MENU DO SISTEMA
1999.10.00 José Quintas

...
2016.02.05.2100 - Formatação
2016.03.04.2200 - Teste QI
2016.03.21.1200 - Teste ref colocar CEST
2016.06.07.2350 - Organização do menu ref testes
2016.06.25.0500 - Opção somente com vendas
2016.07.17.1800 - Salva fonte do menu antes de chamar rotinas
2016.09.14.2200 - Ordenação do menu
2016.11.04.1340 - Correção de __EnumIndex faltou um underline

Atenção!!!!! Modulos só Windows nao tem fonte Clipper
*/

#include "hbgtinfo.ch"
#include "inkey.ch"

FUNCTION MenuCria()

   MEMVAR nMenuLevel, oMenuOptions
   PRIVATE nMenuLevel, oMenuOptions

nMenuLevel   := 0
oMenuOptions := {}

MenuOption( "Movto" )
   MenuDrop()
   MenuOption( "Pedidos/Notas Fiscais" )
      MenuDrop()
      MenuOption( "Consulta uma UF",  "CONSULTAUMAUF" )
      MenuOption( "Orçamentos/Pedidos",           "P0600PED", { || p0600Ped() } )
      MenuOption( "Nota Fiscal (Serviços)",       "PNOT0010", { || pnot0010() } )
      MenuOption( "Consulta a Notas Fiscais",     "PNOT0020", { || pnot0020() } )
      MenuOption( "Gera Pedido de Retirada",      "PNOT0030", { || pnot0030() } )
      MenuOption( "Rel.Romaneio de NFs",          "PNOT0050", { || pnot0050() } )
      MenuOption( "Manifesto Eletrônico",         "PJPMDF",   { || pjpmdf() } )
      MenuOption( "Altera msg_pedido.txt",        "PTXT0010", { || ptxt0010() } )
      MenuOption( "Altera msg_os_cliente.txt",    "PTXT0020", { || ptxt0020() } )
      MenuOption( "Altera msg_os_fornecedor.txt", "PTXT0030", { || ptxt0030() } )
      MenuOption( "Altera msg_cupom.txt",         "PTXT0040", { || ptxt0040() } )
      MenuOption( "Visualizar Vendas",            "PNOT0070", { || pnot0070() } )
      MenuOption( "Visualizar próximas vendas",   "PNOT0270", { || pnot0270() } )
      MenuUnDrop()
   MenuOption( "Boletos" )
      MenuDrop()
      MenuOption( "Boletos Itaú Notas (Txt)",      "PBOL0020", { || pbol0020() } )
      MenuOption( "Boletos Itaú Financeiro (Txt)", "PBOL0030", { || pbol0030() } )
      MenuOption( "Boletos Itaú Avulso (Txt)",     "PBOL0040", { || pbol0040() } )
      MenuOption( "Rel. Txt Itaú",                 "PBOL0050", { || pbol0050() } )
      MenuOption( "Boletos p/ NF Emitidas",        "PBOL0060", { || pbol0060() } )
      MenuOption( "Boletos p/ Doc.C.Receber",      "PBOL0061", { || pbol0061() } )
      MenuOption( "Boletos Avulsos",               "PBOL0062", { || pbol0062() } )
      MenuOption( "Boleto em PDF",                 "PBOL0010", { || pbol0010() } )
      MenuUnDrop()
   MenuOption( "Opções NFE/CTE/MDFE" )
      MenuDrop()
      MenuOption( "Gera Dados para NFS-E / RPS",  "PNOT0040", { || pnot0040() } )
      MenuOption( "Gera Dados para NFEletrônica", "PNOT0060", { || pnot0060() } )
      MenuOption( "Cancelar CTE",                 "PCTE0020", { || pcte0020() } )
      MenuOption( "Visualiza PDF",                "PDA0010",  { || pda0010() } )
      MenuOption( "Inutilizar número CTE",        "PCTEINUT", { || pcteinut() } )
      MenuOption( "Inutilizar número NFE",        "PNFEINUT", { || pnfeinut() } )
      MenuUnDrop()
   MenuOption( "Preços/Comissões" )
      MenuDrop()
      MenuOption( "Preços Diferenciados",             "PPRE0010",   { || ppre0010() } )
      MenuOption( "Listagem Preços Diferenciados",    "PPRE0030",   { || ppre0030() } )
      MenuOption( "Reajuste Preços Diferenciados",    "PPRE0020",   { || ppre0020() } )
      MenuOption( "Percentuais das tabelas",          "PAUXPPRECO", { || pauxppreco() } )
      MenuOption( "Alteração dos Precos",             "PPRE0040",   { || ppre0040() } )
      MenuOption( "Lista de Preços",                  "LLPRECO",    { || llpreco() } )
      MenuOption( "Consulta/Alteração de Preços",     "PNOT0213",   { || pnot0213() } )
      MenuOption( "Consulta de Preços",               "PNOT0214",   { || pnot0214() } )
      MenuOption( "Lista de Preços Img",              "PNOT0220",   { || pnot0220() } )
      MenuOption( "Preços - Percentuais das Tabelas", "PNOT0210",   { || pnot0210() } )
      MenuOption( "Html Cálculo de Micro Montado",    "PSIT0020",   { || psit0020() } )
      MenuOption( "Html Tabela de Preços",            "PNOT0240",   { || pnot0240() } )
      MenuOption( "Arredondamento dos Preços",        "PSETUPPARAMROUND",  { || pSetupParamRound() } )
      MenuOption( "Comissão de Vendedores",           "PJPCOMISS",  { || pjpcomiss() } )
      MenuUnDrop()
   MenuOption( "Etiquetas/Envelopes/Recibo" )
      MenuDrop()
      MenuOption( "Etiquetas p/ Embalagens", "PNOTAETIQUETA",  { || pNotaEtiqueta() } )
      MenuOption( "Recibo de Uso Geral",     "PGERALRECIBO",   { || pGeralRecibo() } )
      MenuUnDrop()
   MenuUnDrop()

MenuOption( "Estoq" )
   MenuDrop()
   MenuOption( "Estoque - Entradas",              "PESTLANCA2",  { || pEstLanca2() } )
   MenuOption( "Estoque - Saidas",                "PESTLANCA1",  { || pEstLanca1() } )
   MenuOption( "Consulta entradas de fornecedor", "PESTENTFOR",  { || pEstEntFor() } )
   MenuOption( "Cod.Barras Manutenção",           "PBAR0010",    { || pbar0010() } )
   MenuOption( "Cod.Barras Consulta/Ocorrência",  "PBAR0040",    { || pbar0040() } )
   MenuOption( "Digitação da Contagem Física",    "PJPFISICAA",  { || pjpfisicaa() } )
   MenuOption( "Mapa de contagem Física",         "PJPFISICAD",  { || pjpfisicad() } )
   MenuOption( "Valor do Estoque",                "PESTVALEST",  { || pEstValEst() } )
   MenuOption( "Valor armazém",                   "PNOT0260",    { || pnot0260() } )
   MenuUnDrop()

MenuOption( "Financeiro" )
   MenuDrop()
   MenuOption( "Bancário" )
      MenuDrop()
      MenuOption( "Movimentação",                 "PBAN0020", { || pban0020() } )
      MenuOption( "Resumos e Grupos",             "PBAN0040", { || pban0040() } )
      MenuOption( "Saldos das Contas no Vídeo",   "PBAN0030", { || pban0030() } )
      MenuOption( "Saldo Consolidado das Contas", "PBAN0070", { || pban0070() } )
      MenuOption( "Geração de Lancamentos",       "PBAN0010", { || pban0010() } )
      MenuOption( "Valores: Comparativo p/Mes",   "PBAN0100", { || pban0100() } )
      MenuOption( "Gráfico: Resumo por Mes",      "PBAN0060", { || pban0060() } )
      MenuOption( "Gráfico: Período por Resumo",  "PBAN0080", { || pban0080() } )
      MenuOption( "Gráfico: Período por Grupo",   "PBAN0050", { || pban0050() } )
      MenuUnDrop()
   MenuOption( "Financeiro - Rec/Pag" )
      MenuDrop()
      MenuOption( "Contas a Receber (WT)",    "PFIN0030", { || pfin0030() } )
      MenuOption( "Baixa Individual C.Rec",   "PFIN0035", { || pfin0035() } )
      MenuOption( "Baixa C.Rec.por Portador", "PFIN0010", { || pfin0010() } )
      MenuOption( "Contas a Pagar (WT)",      "PFIN0040", { || pfin0040() } )
      MenuOption( "Baixa Individual C.Pagar", "PFIN0045", { || pfin0045() } )
      MenuUnDrop()
   MenuUnDrop()

MenuOption( "Contábil" )
   MenuDrop()
   MenuOption( "Digitação de Lançamentos",  "PCONTLANCINCLUI", { || pContLancInclui() } )
   MenuOption( "Correção de Capas de Lote", "PCONTLANCLOTE",   { || pContLancLote() } )
   MenuOption( "Correção de Lançamentos",   "PCONTLANCALTERA", { || pContLancAltera() } )
   MenuOption( "Total de Lançamentos",      "PCONTTOTAIS",     { || pContTotais() } )
   MenuOption( "Consulta a Saldos",         "PCONTSALDO",      { || pContSaldo() } )
   MenuOption( "Fechamento de Exercício",   "PCONTFECHA",      { || pContFecha() } )
   MenuOption( "Utilitários" )
      MenuDrop()
      MenuOption( "Atualização de Sintéticas",     "PCONTSINTETICA", { || pContSintetica() } )
      MenuOption( "Recálculo Geral",               "PCONTRECALCULO", { || pContRecalculo() } )
      MenuOption( "Renumera Código Reduzido",      "PCONTREDRENUM",  { || pContRedRenum() } )
      MenuOption( "Códigos Reduzidos Disponíveis", "PCONTREDDISP",   { || pContRedDisp() } )
      MenuUnDrop()
   MenuOption( "Configuração" )
      MenuDrop()
      MenuOption( "Parâmetros Contábeis",       "PCONTSETUP",    { || pContSetup() } )
      MenuOption( "Livros/Páginas dos Diários", "PCONTNUMDIA",   { || pContNumDia() } )
      MenuOption( "Relatórios Emitidos",        "PCONTEMITIDOS", { || pContEmitidos() } )
      MenuUnDrop()
   MenuUnDrop()

MenuOption( "Fiscal" )
   MenuDrop()
   MenuOption( "Entradas ICMS/IPI (WT)",        "PFISCENTRADAS",  { || pFiscEntradas() } )
   MenuOption( "Saídas   ICMS/IPI (WT)",        "PFISCSAIDAS",    { || pFiscSaidas() } )
   MenuOption( "Carta de Correção de NF",       "PFISCCORRECAO",  { || pFiscCorrecao() } )
   MenuOption( "Total de Lançtos LFiscal",      "PFISCTOTAIS",    { || pFiscTotais() } )
   MenuOption( "Tributação" )
      MenuDrop()
      MenuOption( "Decretos/Leis",              "PLEISDECRETO", { || pLeisDecreto() } )
      MenuOption( "UFs (Unidades Federativas)", "PLEISUF",      { || pLeisUF() } )
      MenuOption( "Tributação de Cadastros",    "PLEISTRICAD",  { || pLeisTriCad() } )
      MenuOption( "Tributação de Empresa",      "PLEISTRIEMP",  { || pLeisTriEmp() } )
      MenuOption( "Tributação de Produtos",     "PLEISTRIPRO",  { || pLeisTriPro() } )
      MenuOption( "Tributação de UFs",          "PLEISTRIUF",   { || pLeisTriUf() } )
      MenuOption( "Regras de Tributação",       "PLEISIMPOSTO", { || pLeisImposto() } )
      MenuUnDrop()
   MenuUnDrop()

MenuOption( "Relatórios" )
   MenuDrop()
   MenuOption( "Rel.Pedidos/NF/OS" )
      MenuDrop()
      MenuOption( "Pedidos/Orçamentos",              "LJPPEDI",  { || ljppedi() } )
      MenuOption( "Rentabilidade por Produto",       "PNOT0080", { || pnot0080() } )
      MenuOption( "Clientes para Vendedor *TES*",    "PNOT0250", { || pnot0250() } )
      MenuOption( "Notas Fiscais Emitidas",          "PNOT0090", { || pnot0090() } )
      MenuOption( "Planilha Compras/Vendas Gerente", "PNOT0100", { || pnot0100() } )
      MenuOption( "Planilha Compras/Vendas",         "PNOT0101", { || pnot0101() } )
      MenuOption( "Planilha Vendas",                 "PNOT0102", { || pnot0102() } )
      MenuOption( "Notas em Excel",                  "PNOT0110", { || pnot0110() } )
      MenuOption( "Vendas a Clientes",               "PNOT0120", { || pnot0120() } )
      MenuOption( "RMA/Baixa PE",                    "PNOT0130", { || pnot0130() } )
      MenuOption( "Rel.Mapa de Vendas-Pedidos",      "PNOT0145", { || pnot0145() } )
      MenuOption( "Rel.Comparativo Compras/Vendas",  "PNOT0150", { || pnot0150() } )
      MenuOption( "Rel.Comparativo Mensal",          "PNOT0160", { || pnot0160() } )
      MenuOption( "Vendas Mensais por Cliente",      "PNOT0190", { || pnot0190() } )
      MenuUnDrop()
   MenuOption( "Rel.Bancário" )
      MenuDrop()
      MenuOption( "Rel.Extrato de Conta(s)",        "PBAN0090", { || pban0090() } )
      MenuOption( "Rel.Saldos das Contas",          "PBAN0110", { || pban0110() } )
      MenuOption( "Rel.Movimento por Grupo/Resumo", "PBAN0120", { || pban0120() } )
      MenuOption( "Rel.Geração de Lançamentos",     "PBAN0130", { || pban0130() } )
      MenuUnDrop()
   MenuOption( "Rel.Estoque" )
      MenuDrop()
      MenuOption( "Rel.Ent/Saí/Pos/Invent",         "LJPESTOQA",  { || ljpestoqa() } )
      MenuOption( "Rel.Entradas Forn/Item",         "LJPESTOQB",  { || ljpestoqb() } )
      MenuOption( "Rel.Saídas Cliente/Item",        "LJPESTOQC",  { || ljpestoqc() } )
      MenuOption( "Rel.Análise para Compra",        "PEST0120",   { || pest0120() } )
      MenuOption( "Rel.Formulário Contagem Fisica", "PJPFISICAB", { || pjpfisicab() } )
      MenuOption( "Rel.Contagem Física",            "LJPFISICA",  { || ljpfisica() } )
      MenuOption( "Produtos em Excel",              "PXLS0010",   { || pxls0010() } )
      MenuUnDrop()
   MenuOption( "Rel.Financeiro" )
      MenuDrop()
      MenuOption( "Rel.Doc.Contas a Receber", "PFIN0120", { || pfin0120() } )
      MenuOption( "Rel.Maiores Clientes",     "PFIN0130", { || pfin0130() } )
      MenuOption( "Rel.Doc.Contas a Pagar",   "PFIN0140", { || pfin0140() } )
      MenuOption( "Rel.Maiores Fornecedores", "PFIN0150", { || pfin0150() } )
      MenuOption( "Rel.Fluxo de Caixa",       "PFIN0020", { || pfin0020() } )
      MenuUnDrop()
   MenuOption( "Rel.Contábil" )
      MenuDrop()
      MenuOption( "Rel.Plano de Contas",                 "PCONTREL0360", { || pContRel0360() } )
      MenuOption( "Rel.Balancete de Verificação",        "PCONTREL0270", { || pContRel0270() } )
      MenuOption( "Rel.Balancete do período",            "PCONTREL0520", { || pContRel0520() } )
      MenuOption( "Rel.Livro Diário",                    "PCONTREL0210", { || pContRel0210() } )
      MenuOption( "Rel.Livro Caixa",                     "PCONTREL0010", { || pContRel0010() } )
      MenuOption( "Rel.Razão/Caixa",                     "PCONTREL0380", { || pContRel0380() } )
      MenuOption( "Rel.Demonstração de Resultado",       "PCONTREL0310", { || pContRel0310() } )
      MenuOption( "Rel.Balanço Patrimonial",             "PCONTREL0320", { || pContRel0320() } )
      MenuOption( "Rel.Termos de Abertura/Encerramento", "PCONTREL0390", { || pContRel0390() } )
      MenuOption( "-", "-" )
      MenuOption( "Rel.Conferência",                     "PCONTREL0250", { || pContRel0250() } )
      MenuOption( "Rel.Contas Admin/C.Custo",            "PCONTREL0550", { || pContRel0550() } )
      MenuOption( "Rel.Despesas por Centro de Custo",    "PCONTREL0300", { || pContRel0300() } )
      MenuOption( "Rel.Retrospectiva de Contas",         "PCONTREL0330", { || pContRel0330() } )
      MenuOption( "Rel.Retrospectiva de Contas-C.Custo", "PCONTREL0530", { || pContRel0530() } )
      MenuOption( "Rel.Razão de Conciliação",            "PCONTREL0385", { || pContRel0385() } )
      MenuOption( "-", "-" )
      MenuOption( "Rel.Cta.Admin x Contábeis",           "PCONTREL0470", { || pContRel0470() } )
      MenuOption( "Rel.Históricos Padrão",               "PCONTREL0370", { || pContRel0370() } )
      MenuOption( "Rel.Lançamentos Padrão",              "PCONTREL0230", { || pContRel0230() } )
      MenuOption( "Rel.Parâmetros do Sistema",           "PCONTREL0340", { || pContRel0340() } )
      MenuUnDrop()
   MenuOption( "Rel.Fiscais" )
      MenuDrop()
      MenuOption( "Rel.Conferência LFiscal",                   "PFISCREL0060",    { || pFiscRel0060() } )
      MenuOption( "Rel.DOPUF - ICMS",                          "PFISCREL0070",    { || pFiscRel0070() } )
      MenuOption( "Rel.Defesa Civil",                          "PFISCREL0140",    { || pFiscRel0140() } )
      MenuOption( "Rel.LMP Livro Mov. Produtos",               "PFISCREL0130",    { || pFiscRel0130() } )
      MenuOption( "Rel.Livro Entradas/Saidas (P1/P1A/P2/P2A)", "PFISCREL0030",    { || pFiscRel0030() } )
      MenuOption( "Rel.Livro Produção e Estoque (P3)",         "PFISCREL0010",    { || pFiscRel0010() } )
      MenuOption( "Rel.Livro Apuração de ICMS/IPI (P9)",       "PFISCREL0040",    { || pFiscRel0040() } )
      MenuOption( "Rel.Livro Oper.Interestaduais (P12)",       "PFISCREL0080",    { || pFiscRel0080() } )
      MenuOption( "Rel.Movimentos Irregulares",                "PFISCREL0090",    { || pFiscRel0090() } )
      MenuOption( "Rel.Resumo por UF - ICMS/IPI",              "PFISCREL0100",    { || pFiscRel0100() } )
      MenuOption( "Rel.Resumo por UF/Alíquota",                "PFISCREL0110",    { || pFiscRel0110() } )
      MenuOption( "Rel.Resumo por Uf/Nat/Alíquota",            "PFISCREL0120",    { || pFiscRel0120() } )
      MenuOption( "Rel.Termos de Abertura/Encerramento",       "PFISCREL0020",    { || pFiscRel0020() } )
      MenuOption( "Rel.Resumo por Data",                       "PFISCREL0050",    { || pFiscRel0050() } )
      MenuOption( "Rel.Regras de Tributação",                  "PLEISRELIMPOSTO", { || pLeisRelImposto() } )
      MenuUnDrop()
   MenuOption( "Rel.Cadastros" )
      MenuDrop()
      MenuOption( "Rel.Cidades/Países",        "LJPCIDADE", { || ljpcidade() } )
      MenuOption( "Rel.Clientes/Fornecedores", "LJPCADAS",  { || ljpcadas() } )
      MenuOption( "Rel.Formas de Pagamento",   "LJPFORPAG", { || ljpforpag() } )
      MenuOption( "Rel.Produtos",              "LJPITEM",   { || ljpitem() } )
      MenuOption( "Rel.Tabelas Auxiliares",    "LJPTABEL",  { || ljptabel() } )
      MenuOption( "Rel.Transportadoras",       "LJPCADAS3", { || ljpcadas3() } )
      MenuUnDrop()
   MenuOption( "Gerencial", "LBALGER" )
   MenuUnDrop()

MenuOption( "Governo" )
   MenuDrop()
   MenuOption( "Arquivo I-SIMP ANP",      "PJPANPMOV",      { || pjpanpmov() } )
   MenuOption( "SPED Contábil",           "PCONTSPED",      { || pContSped() } )
   MenuOption( "SPED FCONT 2011",         "PCONTFCONT",     { || pContFcont() } )
   MenuOption( "SPED Fiscal/Pis/Cofins",  "PFISCSPED",      { || pFiscSped() } )
   MenuOption( "Gera LF->Sintegra",       "PFISCSINTEGRA",  { || pFiscSintegra() } )
   MenuOption( "Consulta NFe na Sefaz",   "PNFE0040",       { || pnfe0040() } )
   MenuUnDrop()

MenuOption( "Cadastros" )
   MenuDrop()
   MenuOption( "Agenda de Telefones/Endereços",    "PJPAGENDA",      { || pjpagenda() } )
   MenuOption( "Clientes/Fornecedores",            "PJPCADAS1",      { || pjpcadas1() } )
   MenuOption( "Clientes/Fornecedores (Consulta)", "PJPCADAS1B",     { || pjpcadas1b() } )
   MenuOption( "Contas Administrativas",           "PCONTCTAADM",    { || pContCtaAdm() } )
   MenuOption( "Empresa",                          "PJPEMPRE",       { || pjpempre() } )
   MenuOption( "Históricos Padrão",                "PCONTHISTORICO", { || pContHistorico() } )
   MenuOption( "Lançamentos Padrão",               "PCONTLANCPAD",   { || pContLancPad() } )
   MenuOption( "Licenças" )
      MenuDrop()
      MenuOption( "Licenças - Lançamentos", "PJPLICMOV",  { || pjplicmov() } )
      MenuOption( "Licenças - Tipos",       "PAUXLICTIP", { || pauxlictip() } )
      MenuOption( "Licenças - Objetos",     "PAUXLICOBJ", { || pauxlicobj() } )
      MenuOption( "Licenças - Listagem",    "LJPLICMOV",  { || ljplicmov() } )
      MenuUnDrop()
   MenuOption( "Plano de Contas",              "PCONTCONTAS",  { || pContContas() } )
   MenuOption( "Produtos/Serviços",            "PJPITEM",      { || pjpitem() } )
   MenuOption( "Produtos/Serviços (Consulta)", "PJPITEMB",     { || pjpitemb() } )
   MenuOption( "Transportadoras",              "PJPCADAS3",    { || pjpcadas3() } )
   MenuOption( "Vendedores/Técnicos",          "PJPVENDED",    { || pjpvended() } )
   MenuOption( "Centros de Custo",             "PAUXCCUSTO",   { || pauxccusto() } )
   MenuOption( "Produtos (Composição)",        "PJPPROMIX",    { || pjppromix() } )
   MenuOption( "Veículos",                     "PJPVEICUL",    { || pjpveicul() } )
   MenuOption( "Motoristas",                   "PJPMOTORI",    { || pjpmotori() } )
   MenuOption( "Auxiliares Fiscais" )
      MenuDrop()
      MenuOption( "Carta de Correção (Códigos)", "PLEISCORRECAO",   { || pLeisCorrecao() } )
      MenuOption( "Cidades/Países",              "PJPCIDADE",       { || pjpcidade() } )
      MenuOption( "CFOP (Natureza de Operação)", "PLEISCFOP",       { || pLeisCfop() } )
      MenuOption( "CST/CSOSN ICMS",              "PLEISICMCST",     { || pLeisIcmCst() } )
      MenuOption( "CNAE (Ramos de Atividade)",   "PLEISCNAE",       { || pLeisCnae() } )
      MenuOption( "CST IPI",                     "PLEISIPICST",     { || pLeisIpiCst() } )
      MenuOption( "CST PIS/Cofins",              "PLEISPISCST",     { || pLeisPisCst() } )
      MenuOption( "Modelos de Doctos Fiscais",   "PLEISMODFIS",     { || pLeisModFis() } )
      MenuOption( "Enquadramento IPI",           "PLEISIPIENQ",     { || pLeisIpiEnq() } )
      MenuOption( "Enquadramento PIS/Cofins",    "PLEISPISENQ",     { || pLeisPisEnq() } )
      MenuOption( "Estoque Unidade de Medida",   "PLEISPROUNI",     { || pLeisProUni() } )
//    MenuOption( "NCM - Classificação de Produtos", "XXX" )
      MenuOption( "Origem da Mercadoria",        "PLEISORIMER",     { || pLeisOriMer() } )
      MenuOption( "Plano de Contas Referencial", "PLEISREFCTA",     { || pLeisRefCta() } )
      MenuOption( "Qualificação do Assinante",   "PLEISQUAASS",     { || pLeisQuaAss() } )
      MenuOption( "UFs (Unidades Federativas)",  "PLEISUF",         { || pLeisUF() } )
      MenuOption( "IBPT Imposto Acumulado",      "PLEISIBPT",       { || pLeisIbpt() } )
      MenuUnDrop()
   MenuOption( "Auxiliares Financeiros" )
      MenuDrop()
      MenuOption( "Bancos",                         "PAUXBANCO",  { || pauxbanco() } )
      MenuOption( "Valores do Dólar",               "PJPDOLAR",   { || pjpdolar() } )
      MenuOption( "Formas de Pagamento",            "PJPFORPAG",  { || pjpforpag() } )
      MenuOption( "Operação (Financeiro)",          "PAUXFINOPE", { || pauxfinope() } )
      MenuOption( "Portadores (Financeiro)",        "PAUXFINPOR", { || pauxfinpor() } )
      MenuUnDrop()
   MenuOption( "Auxiliares Outros" )
      MenuDrop()
      MenuOption( "Bases de Rastreamento",        "PJPNFBASE",  { || pjpnfbase() } )
      MenuOption( "Clientes - Grupo de Clientes", "PAUXCLIGRU", { || pauxcligru() } )
      MenuOption( "Clientes - Status",            "PJPCLISTA",  { || pjpclista() } )
      MenuOption( "Empresas/Filiais (Código)",    "PAUXFILIAL", { || pAuxFilial() } )
      MenuOption( "Estoque - Departamento",       "PAUXPRODEP", { || pAuxProDep() } )
      MenuOption( "Estoque - Seção",              "PAUXPROSEC", { || pAuxProSec() } )
      MenuOption( "Estoque - Grupo",              "PAUXPROGRU", { || pAuxProGru() } )
      MenuOption( "Estoque - Localização",        "PAUXPROLOC", { || pAuxProLoc() } )
      MenuOption( "Mídia (origem)",               "PAUXMIDIA",  { || pAuxMidia() } )
      MenuOption( "Motivos de Cancelamento",      "PAUXMOTIVO", { || pAuxMotivo() } )
      MenuOption( "Transação",                    "PJPTRANSA",  { || pjptransa() } )
      MenuUnDrop()
   MenuUnDrop()

MenuOption( "Integração" )
   MenuDrop()
   MenuOption( "XML de NFE" )
      MenuDrop()
      MenuOption( "Envia XML para servidor",         "PNFE0010",      { || pnfe0010() } )
      MenuOption( "Envia email de NFE",              "PNFE0050",      { || pnfe0050() } )
      MenuOption( "Envia XML para email indicado",   "PTES0130",      { || ptes0130() } )
      MenuOption( "Importa arquivos XML",            "PNFE0060",      { || pnfe0060() } )
      MenuOption( "Importa Emitente de XML",         "PNFE0070",      { || pnfe0070() } )
      MenuOption( "Tabela de Conversão",             "PEDI0150",      { || pedi0150() } )
      MenuOption( "Tipos de Conversão",              "PAUXEDICFG",    { || pAuxEdiCfg() } )
      MenuUnDrop()
   MenuOption( "Gera EDI Financeiro CLARCON",        "PEDICFIN",      { || pedicfin() } )
   MenuOption( "Arquivos de retorno ITAÚ",           "PRETITAU",      { || pretitau() } )
   MenuOption( "Importa notas TOPPETRO",             "PEDI0010",      { || pedi0010() } )
   MenuOption( "Grava NFs no L.Fiscal",              "PEDI0040",      { || pedi0040() } )
   MenuOption( "Grava LFiscal no Contábil",          "PEDI0060",      { || pedi0060() } )
   MenuOption( "Exporta Clientes Excel CSV",         "PEDI0270",      { || pedi0270() } )
   MenuOption( "CT Importa Contas (Entre Empresas)", "PCONTIMPLANO",  { || pContImpPlano() } )
   MenuOption( "CT Importar Excel KITFRAME",         "PCONTIMPEXCEL", { || pContImpExcel() } )
   MenuOption( "CT Importa SPED CONTÁBIL",           "PCONTIMPSPED",  { || pContImpSped() } )
   MenuUnDrop()

MenuOption( "Gerente" )
   MenuDrop()
   MenuOption( "Movimentação em Pedidos",         "PNOT0170", { || pnot0170() } )
   MenuOption( "PTES0060 Resumo do Período",      "PTES0060", { || ptes0060() } )
   MenuOption( "Acertos Diversos" )
      MenuDrop()
      MenuOption( "Checagem/Análise Geral",       "PNOT0200", { || pnot0200() } )
      MenuOption( "Recálculo de Qtdes",           "PBUG0020", { || pbug0020() } )
      MenuOption( "Dados Recentes Compra/Venda",  "PBUG0080", { || pbug0080() } )
      MenuUnDrop()
   MenuOption( "Estatística de Uso",              "PUTI0030", { || puti0030() } )
   MenuOption( "Log de Utilização do Sistema",    "PADMLOG",  { || pAdmLog() } )
   MenuOption( "Usuários/Senhas/Acessos",         "PCFG0050", { || pcfg0050() } )
   MenuUnDrop()

   MenuOption( "Etc" )
      MenuDrop()
      MenuOption( "NFE 13 DE MAIO", "ETCMAIO", { || etcMaio() } )
      MenuUnDrop()

MenuOption( "Sistema" )
   MenuDrop()
   MenuOption( "Sair do Sistema",    { || SairDoSistema() } )
   MenuOption( "Compactação/Reindexação", "PUTI0010" )
   MenuOption( "JPA Update - Download Versão",  "PUPDATEEXEDOWN", { || pUpdateExeDown() } )
   IF IsMySerialHD()
      MenuOption( "JPA Update - Upload Versão", "PUPDATEEXEUP",  { || pUpdateExeUp() } )
   ENDIF
   MenuOption( "Backup em arquivo ZIP",         "PUTI0020", { || puti0020() } )
   MenuOption( "Envia backup pra JPA (ZIP)",    "PUTI0022", { || puti0022() } )
   MenuOption( "Utilitários Diversos" )
      MenuDrop()
      MenuOption( "Acesso Direto a Arquivos",   "PUTILDBASE",      { || pUtilDbase() } )
      MenuOption( "Calculadora (s-F10)",        { || Calculadora() } )
      MenuOption( "Calendário (s-F9)",          { || Calendario() } )
      MenuOption( "Jogo Forca",                 "PGAMEFORCA",      { || pGameForca() } )
      MenuOption( "Jogo Teste de QI",           "PGAMETESTEQI",    { || pGameTesteQI() } )
      MenuOption( "Mudança de senha",           { || pw_AlteraSenha() } )
      MenuOption( "Teclado Virtual",            "PTOOLVKEYBOARD",  { || pToolVKeyboard() } )
      MenuOption( "Ascii Table",                "PTOOLTABASCII",   { || pToolTabAscii() } )
      MenuOption( "Color Table",                "PSETUPCOLOR",     { || pSetupColor() } )
      MenuOption( "Windows Modo Deus",          "PTOOLGODMODE",    { || pToolGodMode() } )
      MenuUnDrop()
   MenuOption( "Atualização" )
      MenuDrop()
      MenuOption( "Atualiza Países (Site BCB)", "PEDI0250", { || pedi0250() } )
      MenuOption( "Download Tabelas",           "PEDI0260", { || pedi0260() } )
      MenuOption( "Importa CNAE ANP T002",      "PEDI0240", { || pedi0240() } )
      MenuOption( "Importa plano referencial",  "PEDI0290", { || pedi0290() } )
      MenuUnDrop()
   MenuOption( "Configurações" )
      MenuDrop()
      MenuOption( "Config.Ativação/Desativação", "PSETUPPARAMALL", { || pSetupParamAll() } )
      MenuOption( "Config.Empresa Usuária",      "PSETUPEMPRESA",  { || pSetupEmpresa() } )
      MenuOption( "Config.Numeração do Sistema", "PSETUPNUMERO", { || pSetupNumero() } )
      MenuOption( "Liberação por telefone",      { || pSetupLibera() } )
      MenuOption( "Alteração no UAC Windows",    { || pSetupWindows() } )
      MenuOption( "Liberações extras" )
         MenuDrop()
         MenuOption( "VER preço de custo (I)",          "ADMPRECUS" )
         MenuOption( "Ocorrências Alterar/Excluir (I)", "ADMOCOALT" )
         MenuUnDrop()
      MenuOption( "Liberações ref. Notas" )
         MenuDrop()
         MenuOption( "Cancelamento de Nota Fiscal", "ADMNOTCAN" )
         MenuOption( "Cancelamento de NF-e",        "ADMNFECAN" )
         MenuOption( "Carta de Correção",           "ADMNFECCE" )
         MenuUnDrop()
      MenuOption( "Liberações ref. Pedidos" )
         MenuDrop()
         MenuOption( "Ped.Barras Venda/Garantia (I)",      "ADMPEDBAR" )
         MenuOption( "Ped.Barras Limpar Cód.Barras (I)",   "ADMPEDLBA" )
         MenuOption( "Ped.Cancelamento (I)",               "ADMPEDCAN" )
         MenuOption( "Ped.Duplicar Pedidos (I)",           "ADMPEDCLO" )
         MenuOption( "Ped.Cupom (I)",                      "ADMPEDCUP" )
         MenuOption( "Ped.Email Varios Pedidos (I)",       "ADMPEDMKT" )
         MenuOption( "Ped.Garantia (I)",                   "ADMPEDGAR" )
         MenuOption( "Ped.Fatura (I)",                     "ADMPEDFAT" )
         MenuOption( "Ped.Juntar Pedidos (I)",             "ADMPEDJUN" )
         MenuOption( "Ped.Libera Sem Crédito (I)",         "ADMPEDCRE" )
         MenuOption( "Ped.Libera Sem Estoque (I)",         "ADMPEDEST" )
         MenuOption( "Ped.Libera Desconto (I)",            "ADMPEDDES" )
         MenuOption( "Ped.Libera Sem Relacionado (I)",     "ADMPEDREL" )
         MenuOption( "Ped.Libera Pag Atraso (I)",          "ADMPEDPAG" )
         MenuOption( "Ped.Libera Cliente Bloqueado (I)",   "ADMPEDBLO" )
         MenuOption( "Ped.Alterar Vendedor (I)",           "ADMPEDVEN" )
         MenuOption( "Ped.Nota Fiscal/Cupom (I)",          "ADMPEDNOT" )
         MenuOption( "Ped.Gerar CTE",                      "ADMPEDCTE" )
         MenuOption( "Ped.Libera Abaixo do Custo (I)",     "ADMPEDCUS" )
         MenuOption( "Ped.Libera diferente da tabela (I)", "ADMPEDTAB" )
         MenuOption( "Ped. Confirmar ADMPEDLIBn" )
            MenuDrop()
            MenuOption( "Ped.Confirmar ADMPEDLIB1 (I)", "ADMPEDLIB1" )
            MenuOption( "Ped.Confirmar ADMPEDLIB2 (I)", "ADMPEDLIB2" )
            MenuOption( "Ped.Confirmar ADMPEDLIB3 (I)", "ADMPEDLIB3" )
            MenuOption( "Ped.Confirmar ADMPEDLIB4 (I)", "ADMPEDLIB4" )
            MenuOption( "Ped.Confirmar ADMPEDLIB5 (I)", "ADMPEDLIB5" )
            MenuOption( "Ped.Confirmar ADMPEDLIB6 (I)", "ADMPEDLIB6" )
            MenuOption( "Ped.Confirmar ADMPEDLIB7 (I)", "ADMPEDLIB7" )
            MenuOption( "Ped.Confirmar ADMPEDLIB8 (I)", "ADMPEDLIB8" )
            MenuOption( "Ped.Confirmar ADMPEDLIB9 (I)", "ADMPEDLIB9" )
            MenuUnDrop()
         MenuUnDrop()
      MenuUnDrop()
   MenuOption( "JPA - Servidor/Site" )
      MenuDrop()
      MenuOption( "Processa Emails Servidor",   "PNFE0020", { || pnfe0020() } )
      MenuOption( "Zip de XML",                 "PEDIXML",  { || pEdiXml() } )
      MenuOption( "Zip de XML de/para",         "PEDIXML2", { || pEdiXml2() } )
      IF IsMySerialHD()
         MenuOption( "Site josequintas.com.br",  "PJPSITE",    { || pjpSite() } )
      ENDIF
      IF IsMySerialHD()
         MenuOption( "Upload de Tabelas",         "PEDI0190", { || pEdi0190() } )
      ENDIF
      MenuOption( "Importa ANP Excel" )
         MenuDrop()
         MenuOption( "Importa T001.xls Agentes",      "PEDI0200", { || pedi0200() } )
         MenuOption( "Importa T008.xls Instalações",  "PEDI0210", { || pedi0210() } )
         MenuOption( "Importa T018.xls Localidades",  "PEDI0220", { || pedi0220() } )
         MenuOption( "Importa T002.xls CNAE",         "PEDI0280", { || pedi0280() } )
         MenuUnDrop()
      MenuOption( "Importa IBGE Excel CNAE 21",       "PEDI0230", { || pedi0230() } )
      MenuOption( "Importa NCM 2017",                 "PEDI0300", { || pedi0300() } )
      MenuUnDrop()
   MenuOption( "Testes" )
      MenuDrop()
      MenuOption( "Testes SPED" )
         MenuDrop()
         MenuOption( "Validar XML",             "PTESVALIDAXML",    { || ptesValidaXml() } )
         MenuUnDrop()
      MenuOption( "Testes JPA" )
         MenuDrop()
         MenuOption( "Estilo de menus",                "PTESMENU",    { || pTesMenu() } )
         MenuOption( "Clientes Excel por regiao",      "PTESTREGIAO", { || pTestRegiao() } )
         MenuOption( "Harbourdoc.com.br gerar",        "PTESHAR",     { || pTesHar() } )
         MenuOption( "Html com Pedido",                "PSIT0040",    { || pSit0040() } )
         MenuOption( "Preencher CEST",                 "PTESCEST",    { || pTesCest() } )
         MenuOption( "Telemarketing",                  "PTES0120",    { || pTes0120() } )
         MenuOption( "Teste Filtro",                   "PTESFILTRO",  { || pTesFiltro() } )
         MenuOption( "Windows Style",                  "PTESWIN",     { || pTesWin() } )
         MenuOption( "MySQL Backup",                   "SQLBACKUP",   { || SqlBackup() } )
         MenuOption( "MySQL Exportar para MySQL",      "SQLFROMDBF",  { || SqlFromDbf() } )
         MenuUnDrop()
      MenuOption( "Testes Aplicativo" )
         MenuDrop()
         MenuOption( "Manual Imprimir",              "HELPPRINT", { || HelpPrint() } )
         MenuOption( "Retorna preços diferenciados", "PTES0050",  { || pTes0050() } )
         MenuUnDrop()
      MenuUnDrop()
   MenuOption( "Sobre o JPA-Integra", { || pinfoJPA() } )
   MenuUnDrop()

   RETURN oMenuOptions

STATIC FUNCTION MenuOption( cCaption, oModule )

   LOCAL nCont, oLastMenu
   MEMVAR nMenuLevel, oMenuOptions

   oLastMenu := oMenuOptions
   FOR nCont = 1 TO nMenuLevel
      oLastMenu := oLastMenu[ Len( oLastMenu ) ]
      IF ValType( oLastMenu[ 2 ] ) # "A"
         oLastMenu[ 2 ] := {}
      ENDIF
      oLastMenu := oLastMenu[ 2 ]
   NEXT
   AAdd( oLastMenu, { cCaption, {}, oModule } )

   RETURN NIL

STATIC FUNCTION MenuDrop()

   MEMVAR nMenuLevel
   nMenuLevel++

   RETURN NIL

STATIC FUNCTION MenuUnDrop()

   MEMVAR nMenuLevel
   nMenuLevel--

   RETURN NIL

FUNCTION TelaPrinc( mTitulo )

   LOCAL cCorAnt

   cCorAnt := SetColor()
   mTitulo := AppEmpresaApelido() + " (" + AppUserName() + " ) " + mTitulo
   SetColor( SetColorTitulo() )
   Scroll( 0, 0, 0, MaxCol(), 0 )
   SayTitulo( mTitulo )
   SetColor( SetColorNormal() )
   Scroll( 1, 0, MaxRow() - 3, MaxCol(), 0 )
   //hb_Scroll( 1, 0, MaxRow() - 2, MaxCol(),,,, hb_UTF8ToStrBox( "." ) )  // screen background
   SetColor( SetColorMensagem() )
   @ MaxRow() - 2, 0 TO  MaxRow()-2, MaxCol() COLOR SetColorTraco()
//   Scroll( MaxRow() - 1, 0, MaxRow(), MaxCol(), 0 )
   SetColor( cCorAnt )

   RETURN NIL

FUNCTION MenuPrinc( mMenuOpt )

   LOCAL mOpc    := 1
   LOCAL nKey
   LOCAL mCont, mLenTot, mDife, mEspEntre, mEspFora, mColIni, aMouseMenu

   IF AppUserLevel() > 1
      RetiraOpcoesI( mMenuOpt )
   ENDIF

   IF AppMenuWindows()
      MenuDesenhoCentral()
      MenuWvg( mMenuOpt )
      RETURN NIL
   ENDIF
   // Ajusta textos para teclas de funcao
   // FOR mCont = 1 TO Len( mMenuOpt )
   //    mMenuOpt[ mCont, 1 ] := mMenuOpt[ mCont, 1 ] // Str( mCont, 2 ) + ":" + menu + " "
   // NEXT

   // Centraliza opcoes
   mLenTot := 0
   FOR mCont = 1 TO Len( mMenuOpt )
      mLenTot += Len( mMenuOpt[ mCont, 1 ] )
   NEXT
   mDife     := Max( MaxCol() + 1 - mLenTot, 0 )
   IF mDife < (Len( mMenuOpt ) + 1 )
      IF mDife >= ( Len( mMenuOpt ) - 1 )
         mEspEntre := 1
      ELSE
         mEspEntre := 0
      ENDIF
      mEspFora  := 0
   ELSE
      mEspEntre := int( mDife / ( Len( mMenuOpt ) + 1 ) )
      mEspFora  := int( ( mDife - ( mEspEntre * ( Len( mMenuOpt ) + 1 ) ) ) / 2 ) + mEspEntre
   ENDIF
   mColIni   := { mEspFora }
   FOR mCont = 2 TO Len( mMenuOpt )
      AAdd( mColIni, mColIni[ mCont - 1 ] + Len( mMenuOpt[ mCont - 1, 1 ] ) + mEspEntre )
   NEXT
   aMouseMenu := {}
   FOR mCont = 1 TO Len( mMenuOpt ) // Problema do clipper do Chr(59) no Inkey
      AAdd( aMouseMenu, { 1, mColIni[ mCont ], mColIni[ mCont ] - 1 + Len( mMenuOpt[ mCont, 1 ] ), 48 + mCont + Iif( mCont > 10, 1, 0 ), 0 } )
   NEXT
   Mensagem( "Selecione e tecle ENTER, ESC Sai" )
   DO WHILE .T.
      //wvt_DrawImage( 2, 0, MaxRow(), MaxCol(), "d:\cdrom\fontes\integra\image\jpa2017.bmp" )

      SetColor( SetColorNormal() )
      Scroll( 1, 0, 1, MaxCol(), 0 )
      FOR mCont = 1 TO Len( mMenuOpt )
         @ 1, mColIni[ mCont ] SAY mMenuOpt[ mCont, 1 ] COLOR iif( mCont == mOpc, SetColorFocus(), SetColorNormal() )
      NEXT
      //MenuDesenhoCentral()
      BoxMenu( 3, mColIni[ mOpc ] - 20 + Int( Len( mMenuOpt[ mOpc, 1 ] ) / 2 ), mMenuOpt[ mOpc, 2 ], 1,, .T., .T., aMouseMenu, 1 )
      nKey := Inkey( 60, INKEY_ALL - INKEY_MOVE + HB_INKEY_GTEVENT )
      DO CASE
      CASE nKey == K_ESC .OR. nKey == 0
          IF ! AppIsMultiThread()
              EXIT
         ENDIF
         SairDoSistema()
         LOOP
      CASE nKey == K_RIGHT
         mOpc := iif( mOpc == Len( mMenuOpt ), 1, mOpc + 1 )
      CASE nKey == K_LEFT
         mOpc := iif( mOpc == 1, Len( mMenuOpt ), mOpc - 1 )
      // Numeros, incluindo Chr(59) nao detectado no Inkey()
      CASE nKey > 48 .AND. nKey < 49 + Len( mMenuOpt ) + iif( Len( mMenuOpt ) > 10, 1, 0 )
         mOpc := Abs( nKey ) - 48
         mOpc := Iif( mOpc > 10, mOpc - 1, mOpc )
      ENDCASE
   ENDDO
   Mensagem()

   RETURN NIL

STATIC FUNCTION BoxMenu( mLini, mColi, mMenuOpt, mOpc, mTitulo, mSaiSetas, mSaiFunc, aMouseConv, nLevel )

   LOCAL mLinf, mColf, mCont, nKey, aMouseLen, lExit, xLin, xCol, cTexto, oElement
   LOCAL nMRow, nMCol, cCorAnt, m_ProgTxt
   MEMVAR m_Prog, cDummy
   PRIVATE cDummy

   hb_Default( @mSaiSetas, .F. )
   hb_Default( @mSaiFunc, .F. )
   hb_Default( @mTitulo, "" )
   hb_Default( @mOpc, 1 )
   cCorAnt := SetColor()
   mLinf     := mLini + Len( mMenuOpt ) + iif( Empty( mTitulo ), 1, 2 )
   IF mLinf > MaxRow() - 4
      mLini := mLini + MaxRow() - 4 - mLinf
      mLinf := mLini + Len( mMenuOpt ) + iif( Empty( mTitulo ), 1, 2 )
   ENDIF
   mColi := iif( mColi < 0, 0, mColi )
   mColf := mColi + 37
   IF mColf > MaxCol() - 2
      mColi := mColi - 10 // Se nao conseguiu +5, tenta -5
      mColf := mColf - 10
      IF mColf > MaxCol() - 2
         mColi := mColi + MaxCol() - 2 - mColf
         mColf := mColi + 37
      ENDIF
   ENDIF
   wOpen( mLini, mColi, mLinf, mColf, mTitulo )
   aMouseLen := Len( aMouseConv )
   ASize( aMouseConv, Len( aMouseConv ) + Len( mMenuOpt ) )
   FOR mCont = 1 TO Len( mMenuOpt )
      xLin := mLini + iif( Empty( mTitulo ), 0, 1 ) + mCont
      xCol := mColi + 1
      AIns( aMouseConv, 1 )
      aMouseConv[ 1 ] := { xLin, xCol, xCol + 33, 64 + mCont, nLevel }
   NEXT
   DO WHILE .T.
      NovaVersao() // Verifica se foi instalada nova versao
      FOR EACH oElement IN mMenuOpt
         IF oElement[ 1 ] == "-"
            @ mLini + iif( Empty( mTitulo ), 0, 1 ) + oElement:__EnumIndex, mColi + 1 TO mLini + iif( Empty( mTitulo ), 0, 1 ) + oElement:__EnumIndex, mColi + 36 COLOR iif( oElement:__EnumIndex == mOpc, SetColorFocus(), SetColorBox() )
         ELSE
            cTexto := " " + Chr( 64 + oElement:__EnumIndex ) + ":" + oElement[ 1 ]
            cTexto := Pad( cTexto, 34 ) + iif( Len( oElement[ 2 ] ) > 0, Chr(16), " " ) + " "
            @ mLini + iif( Empty( mTitulo ), 0, 1 ) + oElement:__EnumIndex, mColi + 1 SAY cTexto COLOR iif( oElement:__EnumIndex == mOpc, SetColorFocus(), SetColorBox() )
         ENDIF
      NEXT
      SetColor( SetColorNormal() )
      nKey := Inkey(1800)
      lExit := .F.
      DO CASE
      CASE nKey == K_ESC .OR. nKey == K_RBUTTONDOWN .OR. nKey == 0
         IF nKey == 0
            CLS
            QUIT
         ENDIF
         IF nLevel == 1
            KEYBOARD Chr( K_ESC )
         ENDIF
         EXIT

      CASE nKey == K_LBUTTONDOWN // Click Esquerda
         nMRow := MROW()
         nMCol := MCOL()
         FOR EACH oElement IN aMouseConv
            IF nMRow == oElement[ 1 ] .AND. nMCol >= oElement[ 2 ] .AND. nMCol <= oElement[ 3 ]
               IF oElement[ 5 ] == nLevel // Nivel Atual
                  KEYBOARD Chr( oElement[ 4 ] )
               ELSEIF oElement[ 5 ] == 0 // Principal
                  KEYBOARD Chr( oElement[ 4 ] )
                  lExit := .T.
               ELSE
                  KEYBOARD Replicate( Chr( K_ESC ), nLevel - oElement[ 5 ] - 1 ) + Chr( oElement[ 4 ] )
                  lExit := .T.
               ENDIF
               EXIT
            ENDIF
         NEXT
         IF lExit
            EXIT
         ENDIF
      CASE nKey > 64 .AND. nKey < 65 + Len( mMenuOpt ) // Letra menu atual
         mOpc := nKey - 64
         KEYBOARD Chr( K_ENTER )
      CASE mSaiSetas .AND. ( nKey == K_RIGHT .OR. nKey == K_LEFT )
         IF nLevel == 1
            KEYBOARD Chr( nKey )
         ENDIF
         EXIT
      CASE nKey == K_DOWN
         IF mOpc < Len( mMenuOpt )
            IF mMenuOpt[ mOpc + 1, 1 ] == "-"
               mOpc += 1
            ENDIF
         ENDIF
         mOpc := iif( mOpc >= Len( mMenuOpt ), 1, mOpc + 1 )
      CASE nKey == K_UP
         IF mOpc > 1
            IF mMenuOpt[ mOpc - 1, 1 ] == "-"
               mOpc -= 1
            ENDIF
         ENDIF
         mOpc := iif( mOpc <= 1, Len( mMenuOpt ), mOpc - 1 )
      CASE nKey == K_HOME
         mOpc := 1
      CASE nKey == K_END
         mOpc := Len( mMenuOpt )
      CASE nKey == K_ENTER
         IF Len( mMenuOpt[ mOpc, 2 ] ) > 0
            BoxMenu( mLini + iif( Empty( mTitulo ), 0, 1 ) + mOpc, mColi + 5, mMenuOpt[ mOpc, 2 ], 1, mMenuOpt[ mOpc, 1 ], .T., .T., aMouseConv, nLevel + 1 )
         ELSEIF ValType( mMenuOpt[ mOpc, 3 ] ) == "C"
            m_Prog := mMenuOpt[ mOpc, 3 ]
            IF m_Prog == "-"
            ELSEIF m_Prog == "NAOTEM"
               MsgStop( "Opcao em projeto/desenvolvimento" )
            ELSEIF "*W*" $ m_Prog
               MsgStop( "Modulo somente disponivel na versao Windows" )
            ELSEIF "(I)" $ m_Prog .OR. Left( m_Prog, 3 ) == "ADM"
               MsgStop( "Modulo interno, no menu apenas pra efeito de configuracao" )
            ELSEIF "(" $ m_Prog
               WSave()
               Mensagem()
               SayTitulo( AppEmpresaApelido() + " (" + AppUserName() + " ) (" + m_Prog + " ) " + Upper( mMenuOpt[ mOpc, 1 ] ) )
               Scroll( 1, 0, MaxRow() - 3, MaxCol(), 0 )
               cDummy := &( mMenuOpt[ mOpc, 3 ] )
               WRestore()
            ELSE
               wSave()
               Mensagem()
               m_ProgTxt := AppEmpresaApelido() + " (" + AppUserName() + ") (" + m_Prog + ") " + Upper( mMenuOpt[ mOpc, 1 ] )
               RunModule( m_Prog, m_ProgTxt )
               wRestore()
            ENDIF
            m_Prog := "JPA"
            SetColor( SetColorNormal() )
         ELSEIF ValType( mMenuOpt[ mOpc, 3 ] ) == "B"
            wSave()
            Mensagem()
            Scroll( 2, 0, MaxRow() - 3, MaxCol(), 0 )
            Eval( mMenuOpt[ mOpc, 3 ] )
            WRestore()
         ENDIF

      CASE SetKey( nKey ) != NIL
         Eval( SetKey( nKey ), ProcName(), ProcLine(), ReadVar() )

      OTHERWISE // Vamos ver se e' atalho
         nKey := Asc( Upper( Chr( nKey ) ) )
         FOR EACH oElement IN aMouseConv
            IF nKey == oElement[ 4 ]
               IF oElement[ 5 ] == nLevel // Nivel Atual
                  KEYBOARD Chr( oElement[ 4 ] )
               ELSEIF oElement[ 5 ] == 0 // Principal
                  KEYBOARD Chr( oElement[ 4 ] )
                  lExit := .T.
               ELSE
                  KEYBOARD Replicate( Chr(27), nLevel - oElement[ 5 ] - 1 ) + Chr( oElement[ 4 ] )
                  lExit := .T.
               ENDIF
               EXIT
            ENDIF
         NEXT
      ENDCASE
      CLOSE DATABASES
      IF lExit
         EXIT
      ENDIF
   ENDDO
   FOR EACH oElement IN mMenuOpt
      ADel( aMouseConv, 1 )
   NEXT
   ASize( aMouseConv, aMouseLen )
   wClose()
   SetColor( cCorAnt )

   RETURN NIL

FUNCTION LogDeUso( cHrInic, cModulo )

   LOCAL nElapsed, cTexto

   nElapsed := TimeDiff( cHrInic, Time() )
   IF nElapsed > 119 // a partir de 2 minutos
      cTexto := ""
      cTexto += "Modulo " + cModulo
      cTexto += ", por " + LTrim( Str( nElapsed / 60 ) ) + "m (" + Left( cHrInic, 5 ) + " a " + Left( Time(), 5 ) + ")"
      cTexto += " (ID " + DriveSerial() + ")"
      GravaOcorrencia( ,, cTexto )
   ENDIF

   RETURN NIL

FUNCTION SayTitulo( cTextoTitulo )

   @ 0, 0 SAY Padc( cTextoTitulo, MaxCol() + 1 ) COLOR SetColorTitulo()
   hb_gtInfo( HB_GTI_WINTITLE, cTextoTitulo )

   RETURN NIL

STATIC FUNCTION RetiraOpcoesI( mMenuOpt )

   LOCAL oElement

   FOR EACH oElement IN mMenuOpt
      IF Len( oElement[ 2 ] ) != 0
         RetiraOpcoesI( oElement[ 2 ] )
      ENDIF
   NEXT

   RETURN NIL

PROCEDURE PToolTabAscii

   LOCAL nCont, nRow, nCol

   nRow := 3
   nCol := 5
   FOR nCont = 1 TO 255
      @ nRow, nCol SAY StrZero( nCont, 3 ) + " " + Chr( nCont )
      nRow += 1
      IF nRow > MaxRow() - 5
         nCol += 10
         nRow := 3
      ENDIF
   NEXT
   MsgExclamation( "Ok" )

   RETURN

PROCEDURE PTESWIN

   LOCAL cisMultiThread, cPlayText, GetList := {}, cMenuWindows

   cIsMultiThread  := iif( AppIsMultiThread(), "S", "N" )
   cPlayText       := iif( AppIsPlayText(), "S", "N" )
   cMenuWindows    := iif( AppMenuWindows(), "S", "N" )
   @ 14, 10 SAY "MultiThread...............:" GET cIsMultiThread PICTURE "!A" VALID cIsMultiThread $ "SN"
   @ 18, 10 SAY "Speak Text W8.1 Enterprise:" GET cPlayText PICTURE "!A" VALID cPlayText $ "SN" WHEN AppUserLevel() == 0
   @ 20, 10 SAY "Menu Windows..............:" GET cMenuWindows PICTURE "!A" VALID cMenuWindows $ "SN"
   READ
   IF LastKey() != K_ESC
      AppIsMultiThread( cisMultiThread == "S" )
      AppIsPlayText( cPlayText == "S" )
      AppMenuWindows( cMenuWindows == "S" )
      hb_ThreadStart( { || Sistema() } )
      QUIT
   ENDIF

   RETURN

STATIC FUNCTION MenuWvg( mMenuOpt )

   LOCAL oMenu, nKey // , oImage // , oButton

   oMenu  := wvgSetAppWindow():MenuBar()
   //oButton := wvgtstPushButton():New()
   //oButton:oimage := { , WVG_IMAGE_BITMAPRESOURCE, "JPATECNOLOGIA", , 1 }
   //oButton:lImageResize := .T.
   //oButton:Create( , , { -2, 0 }, { -MaxRow(), -MaxCol() } )
   //oImage := wvgTstBitmap():New()
   //oImage:cImage := "jpatecnologia"
   //oImage:Create( ,,{ 0, 0 }, { -MaxRow() - 1, -MaxCol() - 1 } )
   BuildMenu( oMenu, mMenuOpt )
   DO WHILE .T.
      nKey := Inkey( 0 )
      DO CASE
      CASE nKey == HB_K_GOTFOCUS
      CASE nKey == HB_K_LOSTFOCUS
      CASE nKey == K_ESC
         EXIT
      ENDCASE
   ENDDO
   wvgSetAppWindow():oMenu := NIL
   wapi_SetMenu( wapi_GetActiveWindow(), NIL )
   wapi_DestroyMenu( oMenu:hWnd )

   RETURN NIL

FUNCTION BuildMenu( oMenu, acMenu )

   LOCAL oElement, oSubMenu, cbCode, m_ProgTxt
   MEMVAR m_Prog

   FOR EACH oElement IN acMenu
      IF Len( oElement[ 2 ] ) == 0
         m_Prog := oElement[ 3 ]
         IF ValType( m_Prog ) == "C"
            m_ProgTxt := AppEmpresaApelido() + " (" + AppUserName() + ") (" + m_Prog + ") " + Upper( oElement[ 1 ] )
            cbCode     := [{ || RunModule( "] + m_Prog + [", "] + m_ProgTxt + [" ) }]
            oMenu:AddItem( oElement[ 1 ] , &( cbCode ) )
         ELSE
            oMenu:AddItem( oElement[ 1 ], oElement[ 3 ] )
         ENDIF
      ELSE
         oSubMenu := WvgMenu():new( oMenu, , .T. ):Create()
         BuildMenu( oSubMenu, oElement[ 2 ] )
         oMenu:AddItem( oSubMenu, oElement[ 1 ] )

      ENDIF
   NEXT

   RETURN NIL

STATIC FUNCTION SairDoSistema()

   IF ! MsgYesNo( "Confirma saida do sistema?" )
      RETURN NIL
   ENDIF
   CLOSE DATABASES
   GtSetupFont(.T.)
   QUIT

   RETURN NIL

PROCEDURE PTESMENU

   LOCAL nStyle

   nStyle := AppStyle()
   nStyle += 1
   IF nStyle > 4
      nStyle := 1
   ENDIF
   AppStyle( nStyle )
   MsgExclamation( "Style atual " + Ltrim( Str( AppStyle() ) ) )

   RETURN

FUNCTION PToolVKeyboard()

   ShellExecuteOpen( "OSK.EXE" )

   RETURN NIL

FUNCTION PToolGodMode()

   IF ! Empty( GetEnv( "USERPROFILE" ) )
      hb_vfDirMake( GetEnv( "USERPROFILE" ) + "\desktop\God Mode.{ED7BA470-8E54-465E-825C-99712043E01C}" )
   ENDIF

   RETURN NIL

STATIC FUNCTION MenuDesenhoCentral()

   LOCAL aTexto, oElement, nRow, nCol, cSetColor := SetColor()

   aTexto := { ;
      "JPA Tecnologia (11) 2280-5776", ;
      "e-mail: suporte@jpatecnologia.com.br", ;
      "", ;
      "Licenciado: " + Trim( AppEmpresaNome() ), ;
      "", ; // "TerminalID: " + DriveSerial(), ;  // + "   ODBCMySql: " + DriverMySql
      Version() + " " + hb_GTInfo( HB_GTI_VERSION ), ;
      HB_Compiler(), ;
      "Base de dados DBF e MySQL(*)", ;
      "JPA Versao " + AppVersaoExe() }
   FOR EACH oElement IN aTexto
      IF ! Empty( oElement )
         oElement := " " + oElement + " "
      ENDIF
   NEXT
   nCol   := Max( Int( ( MaxCol() - 80 ) / 2 ), 0 )
   nRow   := Max( Int( ( MaxRow() - Len( aTexto ) ) / 2 ) - 2, 0 )
   SetColor( SetColorNormal() )
   @ nRow, 0 SAY ""
   FOR EACH oElement IN aTexto
      @ Row() + 1, nCol SAY Padc( oElement, 80 )
   NEXT
   SetColor( cSetColor )

   RETURN NIL

STATIC FUNCTION TimeDiff( mTimeIni, mTimeFim )

   mTimeIni := Val( Substr( mTimeIni, 1, 2 ) ) * 3600 + Val( Substr( mTimeIni, 4, 2 ) ) * 60 + Val( Substr( mTimeIni, 7, 2 ) )
   mTimeFim := Val( Substr( mTimeFim, 1, 2 ) ) * 3600 + Val( Substr( mTimeFim, 4, 2 ) ) * 60 + Val( Substr( mTimeFim, 7, 2 ) )

   RETURN mTimeFim - mTimeIni

REQUEST BROWSE
REQUEST ERRORSYS
REQUEST READMODAL
REQUEST HELP
