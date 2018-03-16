#define MYSQL_MAX_CMDINSERT   500000
#define MYSQL_MAX_RECBACKUP   25000

#ifndef AD_STATE_CLOSED
   #define AD_STATE_CLOSED  0
#endif
#define DATABASE_DBF      1
#define DATABASE_HBNETIO  2

#define AUX_BANCO   "BANCO." // bancos
#define AUX_CADCTL  "CADCTL" // Contábil para Cadastro
#define AUX_CARCOR  "CARCOR" // códigos de carta de correção
#define AUX_CCUSTO  "CCUSTO" // centros de custo
#define AUX_CFOP    "CFOP.." // CFOP
#define AUX_CLIGRU  "CLIGRU" // Cliente - Grupos
#define AUX_CNAE    "CNAE.." // CNAE
#define AUX_CTAADM  "CTAADM" // contas administrativas
#define AUX_EDICFG  "EDICFG" // configuracao de edi
#define AUX_FILIAL  "FILIAL" // filiais
#define AUX_FINOPE  "FINOPE" // financeiro - operações
#define AUX_FINPOR  "FINPOR" // financeiro - portadores
#define AUX_ICMCST  "ICMCST" // ICMS CST
#define AUX_IPICST  "IPICST" // IPI CST
#define AUX_IPIENQ  "IPIENQ" // IPI Enquadramento
#define AUX_LICTIP  "LICTIP" // Tipo de licença
#define AUX_LICOBJ  "LICOBJ" // Tipo de objeto
#define AUX_MIDIA   "MIDIA." // Midia, forma por onde chegou o cliente
#define AUX_MODFIS  "MODFIS" // Modelo de documento fiscal
#define AUX_MOTIVO  "MOTIVO" // Motivo de cancelamento
#define AUX_ORIMER  "ORIMER" // origem da mercadoria
#define AUX_PISCST  "PISCST" // PIS CST
#define AUX_PISENQ  "PISENQ" // PIS Enquadramento
#define AUX_PPRECO  "PPRECO" // percentuais de tabelas de preço
#define AUX_PROGRU  "PROGRU" // Produto Grupo
#define AUX_PRODEP  "PRODEP" // Produto Departamento
#define AUX_PROSEC  "PROSEC" // Produto Seção
#define AUX_PROLOC  "PROLOC" // Produto Localização
#define AUX_PROUNI  "PROUNI" // Produto unidade
#define AUX_QUAASS  "QUAASS" // Qualificação do Assinante
#define AUX_TABAUX  "TABAUX" // Tabelas Auxiliares
#define AUX_TRICAD  "TRICAD" // Tributação de Cadastros
#define AUX_TRIEMP  "TRIEMP" // Tributação de empresa
#define AUX_TRIPRO  "TRIPRO" // Tributação de produtos
#define AUX_TRIUF   "TRIUF." // Tributação de UFs

#define AUX_CXATIP   "CXATIP"   // Tipo de lançamento no caixa

#define AUX_ECIVIL   "ECIVIL"   // Estado Civil
#define AUX_REAJUS   "REAJUS"   // Tipo de Reajuste
#define AUX_TIPIMO   "TIPIMO"   // Tipo de Imóvel
#define AUX_TIPCTR   "TIPCTR"   // Tipo de Contrato

#define DOW_DOMINGO   1
#define DOW_SEGUNDA   2
#define DOW_TERCA     3
#define DOW_QUARTA    4
#define DOW_QUINTA    5
#define DOW_SEXTA     6
#define DOW_SABADO    7

#define HLCAIXA_MONE_CHEQUE      1
#define HLCAIXA_MONE_DINHEIRO    2
#define HLCAIXA_MONE_CARTAO      3
#define HLCAIXA_MONE_DOLAR       4
#define HLCAIXA_MONE_VALE        5

#define HLCAIXA_DB_ENTRADA       1
#define HLCAIXA_DB_SAIDA         2
#define HLCAIXA_DB_EXTRACAIXA    3

#define HLCAIXA_TIPO_RECIBO               1
#define HLCAIXA_TIPO_RECIBO_ALUGUEL       2
#define HLCAIXA_TIPO_RECIBO_LUZ           3
#define HLCAIXA_TIPO_RECIBO_AGUA          4
#define HLCAIXA_TIPO_RECIBO_PREDIAL       5
#define HLCAIXA_TIPO_RECIBO_CONDOMINIO    6
#define HLCAIXA_TIPO_RECIBO_TELEFONE      7
#define HLCAIXA_TIPO_RECIBO_CONTRATOS     8
#define HLCAIXA_TIPO_DIVERSOS_ENTRADA     9
#define HLCAIXA_TIPO_RECIBO_FIANCA       10
#define HLCAIXA_TIPO_RECIBO_TAXALIXO     11
#define HLCAIXA_TIPO_RECIBO_ADICDIVS     11
#define HLCAIXA_TIPO_RECIBO_IRRF         12
#define HLCAIXA_TIPO_BOLETO_AVULSO       13
#define HLCAIXA_TIPO_HAVER               15
#define HLCAIXA_TIPO_RECIBO_DESCDIVS     17
#define HLCAIXA_TIPO_EXTRATOS            20
#define HLCAIXA_TIPO_ADIANTAMENTO        21
#define HLCAIXA_TIPO_DIVERSOS_SAIDA      22
#define HLCAIXA_TIPO_CHEQUE_DEPOSITO     23
#define HLCAIXA_TIPO_DEVE                26
#define HLCAIXA_TIPO_RETIRADACC          27
#define HLCAIXA_TIPO_BOLETO              28

#define RECIBO10_ENTRADA 1
#define RECIBO10_SAIDA   2

#define REAJUSTE_COMB_LIST { "Normal", "Mensal" }

   #command @ <row>, <col> GET <v> [PICTURE <pic>] ;
                           [VALID <valid>] [WHEN <when>] [SEND <snd>] ;
                           [CAPTION <cap>] [MESSAGE <msg>] => ;
         SetPos( <row>, <col> ) ;;
         AAdd( GetList, _GET_( <v>, <"v">, <pic>, <{valid}>, <{when}> ) ) ;;
       [ ATail( GetList ):Cargo := <cap> ;;
         ATail( GetList ):CapRow := ATail( Getlist ):row ;;
         ATail( GetList ):CapCol := ATail( Getlist ):col - __CapLength( <cap> ) - 1 ;] ;
       [ ATail( GetList ):message := <msg> ;] [ ATail( GetList ):<snd> ;] ;
         ATail( GetList ):Display()
