/*
JPA_INDEX - REINDEXACAO GERAL
1995 José Quintas
*/

// Quando tem FOR, usar IndexFor()
// O primeiro tag sera' o nome do indice

#define IndexDbf( cDbf, cDescricao )          AAdd( aDbfInd, { cDbf, cDescricao,{} } )
#define IndexInd( cTag, cKey )                AAdd( aDbfInd[ Len( aDbfInd ), 3 ], { cTag, cKey } )
#define IndexFor( cTag, cKey, cFor )          AAdd( aDbfInd[ Len( aDbfInd ), 3 ], { cTag, cKey, cFor } )

PROCEDURE jpa_index

   MEMVAR m_Prog

   CLOSE DATABASES
   ModuloPackIndex( DbfInd(), ( m_Prog != "JPA_INDEX" ) ) // Automatico p/ outros

   RETURN

FUNCTION DbfInd( cDbf )

   LOCAL aReturn := {}, oElement
   THREAD STATIC aDbfInd := {}

   IF Len( aDbfInd ) == 0
      aDbfInd := CnfDbfInd()
   ENDIF
   IF cDbf == NIL
      aReturn := aClone( aDbfInd )
   ELSE
      FOR EACH oElement IN aDbfInd
         IF oElement[ 1 ] == cDbf
            aReturn := { aClone( oElement ) }
         ENDIF
      NEXT
   ENDIF

   RETURN aClone( aReturn )

FUNCTION CnfDbfInd()

   LOCAL aDbfInd := {}

   IF AppcnMySqlLocal() == NIL
      IndexDbf( "jpreguso", "Ocorrencias" )
         IndexInd( "numlan", "ruArquivo+ruCodigo+Str(RecNo(),10)" )

      //IndexDbf( "jpbarra", "Codigos de Barra" )
         //IndexInd( "numlan",  "brNumLan" )
         //IndexInd( "codbar1", "brCodBar+brNumLan" )
         //IndexInd( "codbar2", "brCodBar2+brNumLan" )
         //IndexInd( "pedven",  "brPedVen+brItem+brCodBar+brNumLan" )
         //IndexInd( "pedcom",  "brPedCom+brItem+brCodBar+brNumLan" )

      IF File( "jpdecret.dbf" )
         IndexDbf( "jpdecret", "Decretos/leis" )
            IndexInd( "numlan", "deNumLan" )
            IndexInd( "nome",   "deNome" )
      ENDIF

      IF File( "jpibpt.dbf" )
         IndexDbf( "jpibpt", "Tabela IBPT" )
            IndexInd( "numlan", "ibCodigo+ibNcmNbs" )
      ENDIF

      IF File( "jppromix.dbf" )
         IndexDbf( "jppromix", "Produtos (Composicao)" )
            IndexInd( "jppromix1", "ptProduto+ptItem" )
            IndexInd( "jppromix2", "ptItem+ptProduto" )
      ENDIF

   ENDIF

   IndexDbf( "jpbaauto", "(Banco) Lanc.Automaticos" )
      IndexInd( "jpbaauto1", "buResumo+buHist" )

   IndexDbf( "jpbagrup", "(Banco) Grupos/Resumos" )
      IndexInd( "jpbagrup1", "bgResumo" )
      IndexInd( "jpbagrup2", "bgGrupo+bgResumo" )

   IndexDbf( "jpbamovi", "(Banco) Movimento" )
      IndexInd( "jpbamovi1", "baConta+baAplic+Dtos(baDatBan)+Dtos(baDatEmi)+iif(baValor>0,'1','2')+Str(RecNo(),6)" )
      IndexInd( "jpbamovi2", "baResumo+Dtos(baDatEmi)+Str(RecNo(),6)" )
      IndexInd( "jpbamovi3", "Dtos(baDatBan)+Dtos(baDatEmi)+baConta+Str(RecNo(),6)" )
      IndexInd( "datemi", "Dtos(baDatEmi)+Str(RecNo(),6)" )

   IndexDbf( "ctdiari", "(Contabil) Movimentacao" )
      IndexInd( "ctdiari1", "Left(dtos(diData),6)+diLote+diLanc+diMov" )
      IndexInd( "ctdiari2", "dtos(diData)+diLote+diLanc+diMov" )
      IndexInd( "ctdiari3", "diCConta+dtos(didata)+diLote+diLanc+diMov" )
      IndexInd( "dibaixa",  "diCConta+Dtos(diBaixa)+Dtos(diData)+diLote+diLanc+diMov" )

  IndexDbf( "cthisto", "(Contabil) Historicos Padrao" )
      IndexInd( "numlan",    "hiHisPad" )
      IndexInd( "descricao", "hiDescri+hiHisPad" )

   IndexDbf( "ctlanca", "(Contabil) Lancamentos Padrao" )
      IndexInd( "ctlanca1", "ctlanca->laCodigo + ctlanca->laSeq" )

   IndexDbf( "ctlotes", "(Contabil) Capas de Lote" )
      IndexInd( "ctlotes1", "Left(Dtos(loData),6)+loLote" )

   IndexDbf( "ctplano", "(Contabil) Plano de Contas" )
      IndexInd( "ctplano1", "a_Codigo" )
      IndexInd( "ctplano2", "a_Reduz" )
      IndexInd( "ctplano3", "a_Nome" )
      IndexInd( "ctplano4", "a_CtaAdm+a_CCusto+a_Codigo" )

   IndexDbf( "jpanpmov", "Movimentacao ANP" )
      IndexInd( "numlan", "amNumLan" )
      IndexInd( "data",   "Dtos(amDatEmi)+amNumLan" )

   IndexDbf( "jpcadas", "Cadastros (Cli/Forn/Transp)" )
      IndexInd( "jpcadas1", "cdTipo + cdCodigo" )
      IndexInd( "jpcadas2", "cdTipo + cdNome + cdCodigo" )
      IndexInd( "jpcadas3", "cdTipo + cdCnpj + cdDivisao + cdCodigo" )
      IndexInd( "jpcadas4", "cdTipo + cdApelido + cdCodigo" )
      IndexInd( "telefone", "cdTipo + cdTelefone + cdCodigo" )
      IndexInd( "numlan",   "cdCodigo" )
      IndexInd( "nome",     "cdNome + cdCodigo" )
      IndexInd( "cnpj",     "cdCnpj+cdCodigo" )

   IndexDbf( "jpcidade", "Cidades e Paises" )
      IndexInd( "numlan",    "ciNumLan" )
      IndexInd( "jpcidade2", "ciNome+ciUf" )
      IndexInd( "jpcidade3", "ciUf+ciNome" )
      IndexInd( "jpcidade4", "ciIbge+ciNumLan" )

   IndexDbf( "jpclista", "Clientes - Status" )
      IndexInd( "numlan",    "csNumLan" )
      IndexInd( "descricao", "csDescri" )

   IndexDbf( "jpcomiss", "Comissoes de Vendedores" )
      IndexInd( "jpcomiss", "cmVendedor+cmProDep" )

   IndexDbf( "jpconfi", "Configuracoes do Sistema" )
      IndexInd( "jpconfi1", "Cnf_Nome" )

   IndexDbf( "jpdolar", "Cotacoes do Dolar" )
      IndexInd( "data", "Dtos(dlData)" )

   //IndexDbf( "jpedicfg", "Configuracao de EDI" )
   //   IndexInd( "numlan", "edNumLan" )
   //   IndexInd( "codedi", "edTipo+edCodEdi1+edCodEdi2+edNumLan" )
   //   IndexInd( "codjpa", "edTipo+edCodJpa+edCodEdi1+edNumLan" )

   IndexDbf( "jpempre", "Empresa" )

   IndexDbf( "jpestoq","Estoque - Movto" )
      IndexInd( "numlan",   "esNumLan" )
      IndexInd( "jpestoq2", "esTipLan+esCliFor+esNumDoc+esItem" )
      IndexInd( "jpestoq3", "esItem+Dtos(esDatLan)+Str(9-Val(esTipLan),1)+esNumLan" )
      IndexInd( "jpestoq4", "Dtos(esDatLan)+esItem+esNumLan" )
      IndexInd( "jpestoq5", "esTipLan+esCliFor+Dtos(esDatLan)+esNumDoc+esItem" )
      IndexInd( "jpestoq6", "esTipLan+esNumDoc+esItem+Dtos(esDatLan)+esNumLan" ) // Conf.Data
      IndexInd( "pedido",   "esPedido+esItem+esNumLan" )

   IndexDbf( "jpfinan", "Financeiro - Movto" )
      IndexInd( "numlan",   "fiNumLan" )
      IndexInd( "jpfinan1", "fiTipLan+fiNumLan" )
      IndexInd( "jpfinan2", "fiTipLan+fiNumDoc+fiParcela+fiTipDoc+fiCliFor+fiNumLan" )
      IndexInd( "jpfinan3", "fiTipLan+fiCliFor+fiNumDoc+fiTipDoc+fiNumLan" )
      IndexInd( "numbanco", "fiNumBan+fiNumLan" )
      IndexInd( "sacado",   "fiSacado+fiNumLan" )
      IndexInd( "cliente",  "fiCliFor+fiNumLan" )
      IndexInd( "pedido",   "fiPedido+fiNumLan" )

   IndexDbf( "jpforpag", "Formas de Pagamento" )
      IndexInd( "numlan",    "fpNumLan" )
      IndexInd( "descricao", "fpDescri+fpNumLan" )

   IndexDbf( "jpimpos", "Regras para Impostos" )
      IndexInd( "numlan", "imNumLan" )
      IndexInd( "regra",  "imTransa+imTriUf+imTriCad+imTriPro+imOriMer+imNumLan" )

   IndexDbf( "jpitem", "Produtos" )
      IndexInd( "item",      "ieItem" )
      IndexFor( "itemvenda", "Substr(ieDescri,1,99)","ieTipo$'S '" )
      IndexFor( "itemnome",  "Substr(ieDescri,1,99)","ieTipo<>'I'" )
      IndexInd( "jpitem3",   "ieGTIN+ieItem" )
      IndexInd( "jpitem4",   "ieProLoc+Substr(ieDescri,1,89)" )
      IndexInd( "tribut",    "ieTriPro+Substr(ieDescri,1,80)+ieItem" )

   IndexDbf( "jpitped", "Pedidos (Produtos)" )
      IndexInd( "pedido",   "ipPedido+ipItem" )
      IndexInd( "jpitped2", "ipItem+ipPedido" )

   IF File( "jplicmov.dbf" )
      IndexDbf( "jplicmov", "Licenças" )
         IndexInd( "numlan", "lcNumLan" )
   ENDIF

   //IndexDbf( "jpfisica", "Contagem Fisica" )
   //   IndexInd( "data",    "Dtos(fsData)+fsItem+fsDescri" )
   //   IndexInd( "item",    "fsItem+fsDescri+Dtos(fsData)" )
   //   IndexInd( "analise", "fsItem+Dtos(fsData)+fsDescri" )

   IndexDbf( "jplfisc", "Livros Fiscais - Movto" )
      IndexInd( "numlan",   "lfNumLan" )
      IndexInd( "jplfisc1", "lfTipLan+lfModFis+lfDocSer+LfDocIni+LfDocFim+LfCfOp+LfCliFor" )
      IndexInd( "jplfisc2", "LfTipLan+LfCfOp+Dtos(LfDatLan)+LfDocIni" )
      IndexInd( "jplfisc3", "LfTipLan+Dtos(LfDatLan)+LfModFis+lfDocSer+LfDocIni" )
      IndexInd( "jplfisc4", "LfTipLan+LfUf+Str(LfIcmAli,5,2)+Dtos(LfDatLan)+LfDocIni" )
      IndexInd( "jplfisc5", "LfTipLan+LfCliFor+Dtos(LfDatLan)+LfDocIni" )
      IndexInd( "jplfisc6", "LfTipLan+LfDocIni+LfModFis+lfDocSer" )
      IndexInd( "pedido",   "lfPedido+lfNumLan" )

   IndexDbf( "jpmdfcab", "MDF Cabecalho" )
      IndexInd( "numlan", "mcNumLan" )

   IndexDbf( "jpmdfdet", "MDF Detalhe" )
      IndexInd( "mdf", "mdMdfNum+mdNumDoc"  )

   IndexDbf( "jpmotori", "Motoristas" )
      IndexInd( "numlan", "moMotori" )
      IndexInd( "nome", "moNome+moMotori" )

   IndexDbf( "jpnota", "Notas Fiscais Emitidas" )
      IndexInd( "jpnota1", "nfNotFis+nfNumLan" )
      IndexInd( "jpnota2", "Dtos(nfDatEmi)+nfNotFis+nfNumLan" )
      IndexInd( "jpnota3", "nfCadDes+Dtos(nfDatEmi)+nfNotFis+nfNumLan" )
      IndexInd( "notas1",  "nfFilial+NfNotFis+nfNumLan" )
      IndexInd( "numlan",  "nfNumLan" )
      IndexInd( "pedido",  "nfPedido + nfNumLan" )

   IndexDbf( "jpnumero", "Controle de numeracoes" )
      IndexInd( "tabela", "nuTabela" )

   IndexDbf( "jppedi", "Pedidos (Cabecalho)" )
      IndexInd( "pedido",  "pdPedido" )
      IndexInd( "jppedi2", "pdCliFor+Dtos(pdDatEmi)+pdPedido" )
      IndexInd( "jppedi3", "pdNotFis+pdPedido" )
      IndexInd( "demofin", "pdDemFin+pdCliFor+pdPedido" )
      IndexInd( "clitran", "pdCliFor+pdTransa+pdPedido" )
      IndexInd( "cliped",  "pdCliFor+pdPedCli+pdPedido" )
      IndexInd( "pedrel",  "pdPedRel+pdPedido" )
      IndexInd( "status",  "pdStatus+MyDescend(pdPedido)" )

   IndexDbf( "jppreco", "Precos Diferenciados" )
      IndexInd( "item",  "pcItem+pcCadas+pcforpag" )
      IndexInd( "cadas", "pcCadas+pcItem+pcforpag" )
      IndexInd( "valor", "Str(pcValor,14,4)+pcItem" )

   //IndexDbf( "jpprehis", "Historico de Precos" )
      //IndexInd( "item",  "phItem+phCadas+phForPag+MyDescend(Dtos(phData))+MyDescend(phHora)" )
      //IndexInd( "cadas", "phCadas+phItem+phForPag+Dtos(phData)" )
      //IndexInd( "data",  "Dtos(phData)+phItem+phCadas+phForPag" )

   IndexDbf( "jppretab", "Precos de Tabela" )
      IndexInd( "item", "pcItem + Dtos( pcData )" )
      IndexInd( "data", "Dtos( pcData ) + pcItem" )

   IndexDbf( "jprefcta", "(Contabil) Plano de Contas Referencial" )
      IndexInd( "jprefcta1", "rcCodigo" )

   IndexDbf( "jpsenha", "Senhas de Acesso" )
      IndexInd( "senha", "pwType + pwFirst + pwLast" )

   IndexDbf( "jptabel", "Tabelas do Sistema" )
      IndexInd( "numlan",    "axTabela+axCodigo+axDescri" ) // descricao ref contagem fisica
      IndexInd( "descricao", "axTabela+axDescri+axCodigo" )

   IndexDbf( "jptransa", "Transacoes" )
      IndexInd( "numlan",    "trTransa" )
      IndexInd( "descricao", "trDescri" )

   IndexDbf( "jpuf", "UFs" )
      IndexInd( "numlan",    "ufUf" )
      IndexInd( "DESCRICAO", "ufDescri+ufUf" )

   IndexDbf( "jpveicul", "Veiculos" )
      IndexInd( "numlan", "veNumLan" )
      IndexInd( "placa",  "veplaca" )

   IndexDbf( "jpvended", "Vendedores/Tecnicos" )
      IndexInd( "numlan",    "vdVendedor" )
      IndexInd( "descricao", "vdDescri" )

   RETURN aClone( aDbfInd )

FUNCTION IndDbf( cDbf )

   LOCAL aFileList, aTagList := {}, aThisFile, aThisTag

   aFileList := CnfDbfInd()
   FOR EACH aThisFile IN aFileList
      IF aThisFile[ 1 ] == cDbf
         FOR EACH aThisTag IN aThisFile[ 3 ]
            AAdd( aTagList, aThisTag )
         NEXT
         EXIT
      ENDIF
   NEXT

   RETURN aClone( aTagList )
