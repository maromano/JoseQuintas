/*
PFISCSPED - SPED PIS/COFINS
2011.09 - José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#define SPED_SEPARADOR "|"

PROCEDURE pFiscSped

   LOCAL mFileSped, GetList := {}
   MEMVAR mDatIni, mDatFim, mTipoSped, mPerfil, mLayOut, mBlocoLst, mBlocoTot, mPisLst, mCofLst, mPisBas, mCofBas
   PRIVATE mDatIni, mDatFim, mTipoSped, mPerfil, mLayOut, mBlocoLst, mBlocoTot, mPisLst, mCofLst, mPisBas, mCofBas

   IF AppcnMySqlLocal() == NIL
      MsgExclamation( "Opção disponível apenas com base MySQL" )
      RETURN
   ENDIF
   IF ! AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpdecret" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpitped", "jppedi", "jpestoq", "jpcadas", "jpitem", "jpcidade", "jpempre", "jptabel", "jpnota" )
      RETURN
   ENDIF
   SELECT jpnota

   mDatIni   := Date() - Day( Date() )
   mDatIni   := mDatIni - Day( mDatIni ) + 1
   mDatFim   := Date() - Day( Date() )
   mTipoSped := "P"
   mPerfil   := "A"

   @ 5, 5 SAY "Data Inicial......:" GET mDatIni
   @ 6, 5 SAY "Data Final........:" GET mDatFim
   @ 7, 5 SAY "Sped Fiscal ou Pis:" GET mTipoSped PICTURE "!A" VALID mTipoSped $ "FP"
   @ 8, 5 SAY "Perfil............:" GET mPerfil PICTURE "!A" VALID mPerfil $ "ABC"
   @ 10, 5 SAY "Temporariamente retirado bloco C110 (Pis/Cof) ref informações complementares"
   Mensagem( "Digite campos, ESC Sai" )
   READ
   Mensagem()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   IF ! MsgYesNo( "Confirma geração" )
      RETURN
   ENDIF

   SayScroll( "Gerando SPED" )

   IF mTipoSped == "P"
      mLayout := "003" // 2.01A
      mFileSped := "EXPORTA\SPPC" + SubStr( DToS( mDatFim ), 3, 4 ) + ".TXT"
   ELSE
      mLayOut := "006"
      mFileSped := "EXPORTA\SPFI" + SubStr( DToS( mDatFim ), 3, 4 ) + ".TXT"
   ENDIF

   SET ALTERNATE TO ( mFileSped )
   SET ALTERNATE ON
   SET CONSOLE OFF

   mBlocoLst := {}
   mBlocoTot := {} // usado nos totalizadores
   mPisLst := {}
   mPisBas := {}
   mCofLst := {}
   mCofBas := {} // totaliza C170 para M400 e M800

   // --------------------- Bloco0 - Abertura, Identificacao e Referencias

   Bloco0000()   // Abertura Bloco 0
   Bloco0001()   // Abertura Bloco 0
   IF mTipoSped == "F"
      Bloco0005()
      Bloco0015()
   ENDIF
   Bloco0100()   // Contabilista
   IF mTipoSped == "P"
      Bloco0110()   // Regime de Apuracao
      Bloco0111()   // Tabela de Receita Bruta Mensal
      Bloco0120()   // Identif. Periodos dispensados da escrituracao digital
      Bloco0140()   // Tabela de Cadastro Estabelecimento
   ENDIF
   Bloco0150()   // Tabela de Cadastro de Participantes
   IF mTipoSped == "F"
      Bloco0175()
   ENDIF
   Bloco0190()   // Tabela de Unidades de Medida
   Bloco0200()   // Tabela de Produtos e Servicos
   // Bloco0200-Bloco0205() // Alteração do produto/serviço
   // Bloco0200-Bloco0206() // Tabela ANP
   IF mTipoSped == "P"
      Bloco0208()   // Codigo de Grupos por Marca (Bebidas Frias)
   ENDIF
   IF mTipoSped == "F"
      Bloco0220() // Fatores de Conversao
      Bloco0300() // Bens ou Componentes do Ativo
   ENDIF
   Bloco0400()   // Tabela de Natureza de Operacao
   Bloco0450()   // Tabela de Informacao Complementar
   IF mTipoSped == "F"
      Bloco0460()
   ENDIF
   Bloco0500()   // Plano de Contas Contabil
   Bloco0600()   // Centros de Custo
   Bloco0990()   // Encerramento

   IF mTipoSped == "P"

      // --------------------- BlocoA - Documentos Fiscais Servicos ISS

      BlocoA001()  // Abertura Bloco A
      // BlocoA010() // Identificacao do Estabelecimento
      // BlocoA100() // Documento NF Servico
      // BlocoA100-BlocoA110() // Complemento - Informacao Complementar
      // BlocoA100-BlocoA111() // Processo Referenciado
      // BlocoA100-BlocoA120() // Complemento - Importacao
      // BlocoA100-BlocoA170() // Complemento - Itens do Documento
      BlocoA990() // Encerramento Bloco A
   ENDIF

   // -------------------- BlocoC - Documentos Fiscais I Mercadorias ICMS/IPI

   BlocoC001() // Abertura
   IF mTipoSped == "P"
      BlocoC010() // Identificacao do Estabelecimento
   ENDIF
   BlocoC100() // Nota Fiscal
   // BlocoC100-BlocoC110() // Complemento
   IF mTipoSped == "F"
      // BlocoC100-BlocoC105()
      // BlocoC100-BlocoC110()
   ENDIF
   // BlocoC100-BlocoC111() // Processo Referenciado
   // BlocoC100-BlocoC120() // Complemento Importacao
   // BlocoC100-BlocoC170() // Itens do Documento
   // BlocoC180() // Consolidacao das Notas Emitidas
   // BlocoC181() // Detalhamento da Consolidacao Pis
   // BlocoC185() // Detalhamento da Consolidacao Cofins
   // BlocoC188() // Processo Referenciado
   // BlocoC190() // Consolidacao de NFE Aquisicao e Devolucao Compras/Vendas
   // BlocoC191() // Detalhamento 190 Pis
   // BlocoC195() // Detalhamento 190 Cofins
   // BlocoC198() // Processo Referenciado
   // BlocoC199() // Complemento Importacao
   // BlocoC380() // Consolidacao NF Consumidor Emitidos
   // BlocoC381() // Detalhamento 380 Pis
   // BlocoC385() // Detalhamento 380 Cofins
   // BlocoC395() // NF Consumidor Aquisicoes
   // BlocoC396() // Produtos da NF Consumidor 395
   // BlocoC400() // Equipamento ECF
   // BlocoC405() // Reducao Z
   // BlocoC481() // Resumo Diario ECF Pis
   // BlocoC485() // Resumo Diario ECF Cofins
   // BlocoC489() // Processo Referenciado
   // BlocoC490() // Consolidacao ECF
   // BlocoC491() // Detalhamento 0490 Pis
   // BlocoC495() // Detalhamento 0490 Cofins
   // BlocoC499() // Processo Referenciado ECF
   // BlocoC500() // Luz, Agua e Gas
   // BlocoC501() // Complemento 500 Pis
   // BlocoC505() // Complemento 500 Cofins
   // BlocoC600() // Consolidacao Luz,Agua,Gas
   // BlocoC601() // Complemento 0600 Pis
   // BlocoC605() // Complemento 0600 Cofins
   // BlocoC609() // Processo Referenciado 0600
   // BlocoC800() // Cupom Fiscal Eletronico
   // BlocoC810() // Detalhamento C800 Pis
   // BlocoC820() // Detalhamento C800 Cofins
   // BlocoC830() // Processo Referenciado C800
   // BlocoC860() // Identificacao Equipamento SAT-CFe
   // BlocoC870() // Detalhamento Cupom Pis
   // BlocoC880() // Detalhamento Cupom Cofins
   BlocoC990() // Encerramento Bloco C

   // --------------------- BlocoD - Documentos Fiscais II Servicos ICMS

   BlocoD001() // Abertura
   // BlocoD010() // Identificacao do Estabelecimento
   // BlocoD100() // Aquisicao Serv Transp
   // BlocoD101() // Complemento Pis
   // BlocoD105() // Complemento Cofins
   // BlocoD111() // Processo Referenciado
   // BlocoD200() // Resumo Diario Serv Transp
   // BlocoD201() // Total Diario Pis
   // BlocoD205() // Total Diario Cofins
   // BlocoD209() // Processo Referenciado
   // BlocoD300() // Resumo Diario
   // BlocoD309() // Processo Referenciado
   // BlocoD350() // Resumo Diario Cupom ECF
   // BlocoD359() // Processo Referenciado
   // BlocoD500() // NF Comunicacao/Telecomunicacao
   // BlocoD501() // Complemento Pis
   // BlocoD509() // Complemento Cofins
   // BlocoD600() // Processo Referenciado
   // BlocoD601() // Consolidacao
   // BlocoD605() // Complemento Consolidacao
   // BlocoD609() // Processo Referenciado
   BlocoD990() // Encerramento

   IF mTipoSped == "F"
      // --------------------- BLOCOE -
      BlocoE001() // Abertura
      BlocoE100() // Movimento
      BlocoE110() // Apuracao ICMS
      BlocoE990() // Encerramento
   ENDIF

   // --------------------- BlocoF - Demais Documentos e Operacoes

   IF mTipoSped == "P"
      BlocoF001() // Abertura
      // BlocoF010() // Identificacao do Estabelecimento
      // BlocoF100() // Demais Doc
      // BlocoF111() // Processo Referenciado
      // BlocoF120() // Bens Ativo Depreciacao
      // BlocoF129() // Processo Referenciado
      // BLocoF130() // Bens Ativo Aquisicao
      // BlocoF139() // Processo Referenciado
      // BlocoF150() // Credito Presumido sobre estoque
      // BlocoF200() // Ativ.Imobiliaria Venda
      // BlocoF205() // Ativ.Imobiliaria Custo
      // BlocoF210() // Ativ.Imobiliaria Custo
      // BlocoF211() // Processo Referenciado
      // BlocoF500() // Consolidacao Regime de Caixa
      // BlocoF509() // Processo Referenciado
      // BlocoF510() // Consolidacao Regime de Caixa por unidade
      // BlocoF519() // Processo Referenciado
      // BlocoF525() // Composicao Receita Regime de Caixa
      // BlocoF550() // Consolidacao Regime de Competencia
      // BlocoF559() // Processo Referenciado
      // BlocoF560() // Consolidacao Regime Competencia por Unidade
      // BlocoF569() // Processo Referenciado
      // BlocoF600() // Contribuicao Retida na fonte
      // BlocoF700() // Deducoes Diversas
      // BlocoF800() // Creditos Incorporacao,Fusao e Cisao
      BlocoF990() // Encerramento
   ENDIF

   IF mTipoSped == "F"

      // --------------------BlocoG - Controle de Credito de ICMS do Ativo Permanente - CIAP
      BlocoG001()
      BlocoG990()

      // --------------------BlocoH - Inventario Fisico
      BlocoH001()
      BlocoH990()

   ENDIF

   // -------------------- BlocoI

   IF mTipoSped == "P"

      // -------------------- BlocoM - Apuracao da Contribuicao e Credito PIS e COFINS

      BlocoM001() // Abertura
      // BlocoM100() // Credito Pis Periodo
      // BlocoM105() // Detalhamento Pis
      // BlocoM110() // Ajustes de Credito
      BlocoM200() // Consolidacao Pis
      // BlocoM210()// Detalhamento Pis
      // BlocoM211() // Cooperativas Pis
      // BlocoM220() // Ajustes Pis
      // BlocoM230() // Inf. Adicionais Pis
      // BlocoM300() // Pis Anteriores
      // BlocoM350() // Pis Folha de Salarios
      BlocoM400() // Receitas Isentas
      BlocoM410() // Detalhamento Isentas
      // BlocoM500() // Credito Cofins
      // BlocoM505() // Consolidacao Cofins
      // BlocoM510() // Ajustes Cofins
      BlocoM600() // Consolidacao Cofins
      // BlocoM610() // Detalhamento Cofins
      // BlocoM611() // Cooperativas Cofins
      // BlocoM620() // Ajustes Cofins
      // BlocoM630() // Inf.Adicionais Cofins
      // BlocoM700() // Cofins Anteriores
      BlocoM800() // Isentas Cofins
      BlocoM810() // Detalhamento Isentas
      BlocoM990() // Encerramento

   ENDIF

   // -------------------- BlocoP

   // ------------------- Bloco1 - Complemento da Escrituracao
   Bloco1001()
   // Bloco1010()
   // Bloco1020()
   // Bloco1100()
   // Bloco1101()
   // Bloco1102()
   // Bloco1200()
   // Bloco1210()
   // Bloco1220()
   // Bloco1300()
   // Bloco1500()
   // Bloco1501()
   // Bloco1502()
   // Bloco1600()
   // Bloco1610()
   // Bloco1620()
   // Bloco1700()
   // Bloco1800()
   // Bloco1809()
   // Bloco1900()
   Bloco1990()

   // --------------------- Bloco9 - Encerramento

   Bloco9001() // Abertura
   Bloco9900() // Totalizacao dos blocos
   Bloco9990() // Encerramento bloco
   Bloco9999() // Encerramento Geral

   SET CONSOLE ON
   SET ALTERNATE OFF
   SET ALTERNATE TO
   fDelEof( mFileSped )

   MsgExclamation( "Fim da Geracao" )

   RETURN

STATIC FUNCTION Bloco0000()

   MEMVAR mDatIni, mDatFim, mLayout, mTipoSped, mPerfil

   IF mTipoSped == "P"
      SomaBloco( "0000" )
      ?? SPED_SEPARADOR
      ?? "0000" + SPED_SEPARADOR                                          // 01 REG fixo
      ?? mLayOut + SPED_SEPARADOR                                         // 02 COD_VER versao do arquivo
      ?? "0" + SPED_SEPARADOR                                             // 03 TIPO_ESCRIT 0 = original 1=retificadora
      ?? "" + SPED_SEPARADOR                                              // 04 IND_SIT_ESP Situacao Especial 0=abertura 1=cisao 2=fusao 3=incorporacao 4=encerramento
      ?? "" + SPED_SEPARADOR                                              // 05 NUM_REC_ANTERIOR Numero anterior
      ?? FormatoData( mDatIni ) + SPED_SEPARADOR                          // 06 DT_INI
      ?? FormatoData( mDatFim ) + SPED_SEPARADOR                          // 07 DT_FIN
      ?? Trim( jpempre->emNome ) + SPED_SEPARADOR                         // 08 NOME
      ?? SoNumeros( jpempre->emCnpj ) + SPED_SEPARADOR                    // 09 CNPJ
      ?? jpempre->emUf + SPED_SEPARADOR                                   // 10 UF
      ?? CidadeIbge( jpempre->emCidade, jpempre->emUf ) + SPED_SEPARADOR  // 11 COD_MUN Cidade no IBGE
      ?? "" + SPED_SEPARADOR                                              // 12 SUFRAMA
      ?? "00" + SPED_SEPARADOR                                            // 13 IND_NAT_PJ Natureza Juridica 00 - Soc.Empresaria em Geral
      ?? "2" + SPED_SEPARADOR                                             // 14 IND_ATIV 0-Industrial 1-Servicos 2-Comercio 3-Financeira 4-Imobiliaria 9-Outros
      ?
   ELSE
      SomaBloco( "0000" )
      ?? SPED_SEPARADOR
      ?? "0000" + SPED_SEPARADOR                                    // 01 REG fixo
      ?? mLayOut + SPED_SEPARADOR                                   // 02 COD_VER Versao
      ?? "0" + SPED_SEPARADOR                                       // 03 COD_FIN 0 = original 1=retificadora
      ?? FormatoData( mDatIni ) + SPED_SEPARADOR                    // 04 DT_INI
      ?? FormatoData( mDatFim ) + SPED_SEPARADOR                    // 05 DT_FIN
      ?? Trim( jpempre->emNome ) + SPED_SEPARADOR                   // 06 NOME
      ?? SoNumeros( jpempre->emCnpj ) + SPED_SEPARADOR              // 07 CNPJ
      ?? "" + SPED_SEPARADOR                                        // 08 CPF
      ?? jpempre->emUf + SPED_SEPARADOR                             // 09 UF
      ?? SoNumeros( jpempre->emInsEst ) + SPED_SEPARADOR              // 10 IE Inscricao Estadual
      ?? CidadeIbge( jpempre->emCidade, jpempre->emUf ) + SPED_SEPARADOR // 11 COD_MUN Cidade no IBGE
      ?? SoNumeros( jpempre->emInsMun ) + SPED_SEPARADOR              // 12 IM Inscricao Municipal
      ?? "" + SPED_SEPARADOR                                        // 13 SUFRAMA
      ?? mPerfil + SPED_SEPARADOR                                   // 14 IND_PERFIL A, B, C
      ?? "1" + SPED_SEPARADOR                                       // 15 IND_ATIV 0-Industrial 1-Outros
      ?
   ENDIF

   RETURN NIL

STATIC FUNCTION Bloco0001()

   SomaBloco( "0001" )
   ?? SPED_SEPARADOR
   ?? "0001" + SPED_SEPARADOR        // 01 REG
   ?? "0" + SPED_SEPARADOR           // 02 IND_MOV 0=informado 1=nao informado
   ?

   RETURN NIL

STATIC FUNCTION Bloco0005() // Fiscal

   SomaBloco( "0005" )
   ?? SPED_SEPARADOR
   ?? "0005" + SPED_SEPARADOR                            // 01 REG
   ?? "" + SPED_SEPARADOR                                // 02 FANTASIA Nome fantasia
   ?? SoNumeros( jpempre->emCep ) + SPED_SEPARADOR       // 03 CEP
   ?? Trim( jpempre->emEndereco ) + SPED_SEPARADOR       // 04 END
   ?? "." + SPED_SEPARADOR                               // 05 NUM
   ?? "" + SPED_SEPARADOR                                // 06 COMPL
   ?? Trim( jpempre->emBairro ) + SPED_SEPARADOR         // 07 BAIRRO
   ?? SoNumeros( jpempre->emTelefone ) + SPED_SEPARADOR  // 08 FONE
   ?? "" + SPED_SEPARADOR                                // 09 FAX
   ?? "" + SPED_SEPARADOR                                // 10 EMAIL
   ?

   RETURN NIL

STATIC FUNCTION Bloco0015() // Fiscal

   // Dados do Contribuinte Substituto

   RETURN NIL

STATIC FUNCTION Bloco0100() // Contabilista

   SomaBloco( "0100" )
   ?? SPED_SEPARADOR
   ?? "0100" + SPED_SEPARADOR                         // 01 REG
   ?? Trim( jpempre->emContador ) + SPED_SEPARADOR      // 02 NOME
   ?? SoNumeros( jpempre->emCpfCon ) + SPED_SEPARADOR   // 03 CPF
   ?? Trim( jpempre->emCrcCon ) + SPED_SEPARADOR        // 04 CRC
   ?? "" + SPED_SEPARADOR                             // 05 CNPJ se houver
   ?? "01000000" + SPED_SEPARADOR                     // 06 CEP
   ?? "END.CONTADOR" + SPED_SEPARADOR                 // 07 END
   ?? "0" + SPED_SEPARADOR                            // 08 NUM
   ?? "COMPL" + SPED_SEPARADOR                        // 09 COMPL
   ?? "BAIRRO"  + SPED_SEPARADOR                      // 10 BAIRRO
   ?? "FONE" + SPED_SEPARADOR                         // 11 FONE
   ?? "FAX" + SPED_SEPARADOR                          // 12 FAX
   ?? "EMAIL" + SPED_SEPARADOR                        // 13 EMAIL
   ?? CidadeIbge( "SAO PAULO", "SP" ) + SPED_SEPARADOR   // 14 COD_MUN Ibge
   ?

   RETURN NIL

STATIC FUNCTION Bloco0110()

   MEMVAR mLayout

   SomaBloco( "0110" )
   ?? SPED_SEPARADOR
   ?? "0110" + SPED_SEPARADOR                        // 01 REG
   ?? "1" + SPED_SEPARADOR                           // 02 COD_INC_TRIB 1-Reg.Nao Cumulativo 2=Cumulativo 3=Ambas
   ?? "1" + SPED_SEPARADOR                           // 03 IND_APRO_CRE 1=Direta 2-Rateio
   ?? "1" + SPED_SEPARADOR                           // 04 COD_TIPO_CONT 1=aliquota 2-Diferenciado
   IF mLayOut > "002"                                // Layout atual Pis/Cofins nao tem
      ?? "1" + SPED_SEPARADOR                        // 05 IND_REG_CUM 1-Caixa 2-Competencia totais 3-Competencia detalhada
   ENDIF
   ?

   RETURN NIL

STATIC FUNCTION Bloco0111() // Calculo pela receita bruta

   IF .F.
      SomaBloco( "0111" )
      ?? SPED_SEPARADOR
      ?? "0111" + SPED_SEPARADOR                     // 01 REG
      ?? FormatoValor( 0 ) + SPED_SEPARADOR            // 02 REC_BRU_NCUM_TRIB_MI Receita Bruta Nao Cum Merc Interno
      ?? FormatoValor( 0 ) + SPED_SEPARADOR            // 03 REC_BRU_NCUM_NT_MI Receita Bruta Nao Trib.Merc.Interno
      ?? FormatoValor( 0 ) + SPED_SEPARADOR            // 04 REC_BRU_NCUM_EXP Receita Bruta Nao Com Exportacao
      ?? FormatoValor( 0 ) + SPED_SEPARADOR            // 05 REC_BRU_CUM Receita Bruta Nao Cumulativa
      ?? FormatoValor( 0 ) + SPED_SEPARADOR            // 06 REC_BRU_TOTAL Receita Bruta Total
      ?
   ENDIF

   RETURN NIL

STATIC FUNCTION Bloco0120() // Periodos dispensados

   RETURN NIL

STATIC FUNCTION Bloco0140() // Estabelecimento

   SomaBloco( "0140" )
   ?? SPED_SEPARADOR
   ?? "0140" + SPED_SEPARADOR                                         // 01 REG
   ?? jpempre->emCnpj + SPED_SEPARADOR                                // 02 COD_EST Cod Identificacao Estabelecimento Livre
   ?? Trim( jpempre->emNome ) + SPED_SEPARADOR                          // 03 NOME
   ?? SoNumeros( jpempre->emCnpj ) + SPED_SEPARADOR                     // 04 CNPJ
   ?? jpempre->emUf + SPED_SEPARADOR                                  // 05 UF
   ?? SoNumeros( jpempre->emInsEst ) + SPED_SEPARADOR                   // 06 IE
   ?? CidadeIbge( jpempre->emCidade, jpempre->emUf ) + SPED_SEPARADOR    // 07 COD_MUN Ibge
   ?? "" + SPED_SEPARADOR                                             // 08 IM Inscricao Municipal
   ?? "" + SPED_SEPARADOR                                             // 09 SUFRAMA
   ?

   RETURN NIL

STATIC FUNCTION Bloco0150() // Cadastro do Participantes

   SELECT jpcadas
   GOTO TOP
   DO WHILE ! Eof()
      IF Empty( CidadeIbge( jpcadas->cdCidade, jpcadas->cdUf ) )
         SKIP
         LOOP
      ENDIF
      IF ! ValidIE( jpcadas->cdInsEst, jpcadas->cdUf )
         SKIP
         LOOP
      ENDIF
      IF Len( SoNumeros( jpcadas->cdCnpj ) ) != 14 .AND. Len( SoNumeros( jpcadas->cdCnpj ) ) != 11
         SKIP
         LOOP
      ENDIF
      SomaBloco( "0150" )
      ?? SPED_SEPARADOR
      ?? "0150" + SPED_SEPARADOR                                         // 01 REG
      ?? jpcadas->cdCodigo + SPED_SEPARADOR                              // 02 COD_PART Cod Participante Livre
      ?? Trim( jpcadas->cdNome ) + SPED_SEPARADOR                          // 03 NOME
      ?? "01058" + SPED_SEPARADOR                                        // 04 COD_PAIS
      IF Len( SoNumeros( jpcadas->cdCnpj ) ) == 14
         ?? SoNumeros( jpcadas->cdCnpj ) + SPED_SEPARADOR                  // 05 CNPJ
         ?? "" + SPED_SEPARADOR
      ELSE
         ?? "" + SPED_SEPARADOR
         ?? SoNumeros( jpcadas->cdCnpj ) + SPED_SEPARADOR                  // 06 CPF
      ENDIF
      ?? SoNumeros( jpcadas->cdInsEst ) + SPED_SEPARADOR                   // 07 IE
      ?? CidadeIbge( jpcadas->cdCidade, jpcadas->cdUf ) + SPED_SEPARADOR    // 08 COD_MUN
      ?? "" + SPED_SEPARADOR                                             // 09 SUFRAMA
      ?? Trim( jpcadas->cdEndereco ) + SPED_SEPARADOR                      // 10 END
      ?? "0" + SPED_SEPARADOR                                            // 11 NUM
      ?? "" + SPED_SEPARADOR                                             // 12 COMPL
      ?? Trim( jpcadas->cdBairro ) + SPED_SEPARADOR                        // 13 BAIRRO
      ?
      SKIP
   ENDDO

   RETURN NIL

STATIC FUNCTION Bloco0175()

   // Alteração do cadastro de participantes

   RETURN NIL

STATIC FUNCTION Bloco0190() // Unidades de medida

   SELECT jptabel
   GOTO TOP
   DO WHILE ! Eof()
      IF jptabel->axTabela == AUX_PROUNI
         SomaBloco( "0190" )
         ?? SPED_SEPARADOR
         ?? "0190" + SPED_SEPARADOR                  // 01 REG
         ?? Trim( jptabel->axCodigo ) + SPED_SEPARADOR    // 02 UNID // Unidade de Medida
         ?? Trim( jptabel->axDescri ) + SPED_SEPARADOR    // 03 DESCR Descricao
         ?
      ENDIF
      SKIP
   ENDDO

   RETURN NIL

STATIC FUNCTION Bloco0200() // Produtos e/ou servicos

   SELECT jpitem
   GOTO TOP
   Bloco0205()
   DO WHILE ! Eof()
      SomaBloco( "0200" )
      ?? SPED_SEPARADOR
      ?? "0200" + SPED_SEPARADOR                  // 01 REG
      ?? jpitem->ieItem + SPED_SEPARADOR          // 02 COD_ITEM
      ?? Trim( jpitem->ieDescri ) + SPED_SEPARADOR  // 03 DESCR_ITEM
      ?? Trim( jpitem->ieGTIN ) + SPED_SEPARADOR    // 04 COD_BARRA
      ?? "" + SPED_SEPARADOR                      // 05 COD_ANT_ITEM Codigo anterior do item
      ?? Trim( jpitem->ieUnid ) + SPED_SEPARADOR    // 06 UNID_INV Unidade de medida
      ?? "99" + SPED_SEPARADOR                    // 07 TIPO_ITEM Tipo de Item 00-Revenda 01-Mat.Prima 02-Embalagem 03-em Processo
      // 04-Acabado 05-Subproduto 06-Prod.Intermediario 07-Mat.Uso/Consumo
      // 08-Ativo 09-Servicos 10-Outros insumos 99-Outros
      ?? Trim( jpitem->ieCodNcm ) + SPED_SEPARADOR  // 08 COD_NCM
      ?? "" + SPED_SEPARADOR                      // 09 EX_IPI Codigo EX conforme a TIPI
      ?? "" + SPED_SEPARADOR                      // 10 COD_GEN Codigo do Genero 2 digitos
      ?? "" + SPED_SEPARADOR                      // 11 COD_LST Cod Servico conf lei
      ?? FormatoValor( 18, 2 ) + SPED_SEPARADOR      // 12 ALIQ_ICMS Aliquota interna
      ?
      Bloco0206()
      SKIP
   ENDDO

   RETURN NIL

STATIC FUNCTION BLoco0205() // Alteração de item

   IF .F.
      SomaBloco( "0205" )
      ?? SPED_SEPARADOR
      ?? "0205" + SPED_SEPARADOR                             // 01 REG
      ?? "" + SPED_SEPARADOR                                 // 02 DESCR_ANT_ITEM Descricao anterior
      ?? FormatoData( CToD( "01/01/2011" ) ) + SPED_SEPARADOR    // 03 DT_INI Data de inicio de utilizacao
      ?? "" + SPED_SEPARADOR                                 // 04 DT_FIM Data de final
      ?? "" + SPED_SEPARADOR                                 // 05 COD_ANT_ITEM Codigo anterior
      ?
   ENDIF

   RETURN NIL

STATIC FUNCTION Bloco0206() // ANP

   IF ! Empty( jpitem->ieAnp ) .AND. jpitem->ieAnp != "999999999"
      SomaBloco( "0206" )
      ?? SPED_SEPARADOR
      ?? "0206" + SPED_SEPARADOR                       // 01 REG
      ?? jpitem->ieAnp + SPED_SEPARADOR                // 02 COD_COMB Codigo ANP
      ?
   ENDIF

   RETURN NIL

STATIC FUNCTION Bloco0208() // Bebidas frias

   IF .F.
      SomaBloco( "0208" )
      ?? SPED_SEPARADOR
      ?? "0208" + SPED_SEPARADOR      // 01 REG
      ?? "01" + SPED_SEPARADOR        // 02 COD_TAB
      ?? "" + SPED_SEPARADOR          // 03 COD_GRU Codigo do Grupo conf Anexo
      ?? "" + SPED_SEPARADOR          // 04 MARCA_COM Marca comercial
      ?
   ENDIF

   RETURN NIL

STATIC FUNCTION Bloco0220() // Fatores de Conversao

   IF .F.
      SomaBloco( "0220" )
      ?? SPED_SEPARADOR
      ?? "0220" + SPED_SEPARADOR           // 01 REG
      ?? "XXXXXX" + SPED_SEPARADOR         // 02 UNID_CONV Unidade comercial no registro 0200
      ?? "0" + SPED_SEPARADOR              // 03 FAT_CONV Fator de Conversao (Numerico)
      ?
   ENDIF

   RETURN NIL

STATIC FUNCTION Bloco0300() // Bens ou Componentes do Ativo

   Bloco0305()

   RETURN NIL

STATIC FUNCTION Bloco0305() // Informacoes sobre a utilizacao do Bem

   RETURN NIL

STATIC FUNCTION Bloco0400() // CFOP

   SELECT jptabel
   SEEK AUX_CFOP
   DO WHILE jptabel->axTabela == AUX_CFOP .AND. ! Eof()
      SomaBloco( "0400" )
      ?? SPED_SEPARADOR
      ?? "0400" + SPED_SEPARADOR                       // 01 REG
      ?? Trim( jptabel->axCodigo ) + SPED_SEPARADOR        // 02 COD_NAT
      ?? Trim( jptabel->axDescri ) + SPED_SEPARADOR      // 03 DESCR_NAT
      ?
      SKIP
   ENDDO

   RETURN NIL

STATIC FUNCTION Bloco0450() // Inf. Adicionais

   LOCAL cnJPDECRET := ADOClass():New( AppcnMySqlLocal() )

   IF AppcnMySqlLocal() == NIL
      SELECT jpdecret
      GOTO TOP
      DO WHILE ! Eof()
         SomaBloco( "0450" )
         ?? SPED_SEPARADOR
         ?? "0450" + SPED_SEPARADOR                                    // 01 REG
         ?? jpdecret->deNumLan + SPED_SEPARADOR                        // 02 COD_INF
         ?? Trim( jpdecret->deDescr1 + jpdecret->deDescr2 + jpdecret->deDescr3 + jpdecret->deDescr4 + jpdecret->deDescr5 ) + SPED_SEPARADOR // 03 TXT Descricao
         ?
         SKIP
      ENDDO
   ELSE
      WITH OBJECT cnJPDECRET
         :cSql := "SELECT * FROM JPDECRET"
         :Execute()
         DO WHILE ! :Eof()
            SomaBloco( "0450" )
            ?? SPED_SEPARADOR
            ?? "0450" + SPED_SEPARADOR                                    // 01 REG
            ?? :StringSql( "DENUMLAN" ) + SPED_SEPARADOR                        // 02 COD_INF
            ?? Trim( :StringSql( "DEDESCR1" ) + " " + :StringSql( "DEDESCR2" ) + " " + :StringSql( "DEDESCR3" ) + " " + ;
               :StringSql( "DEDESCR4" ) + " " + :StringSql( "DEDESCR5" ) ) + SPED_SEPARADOR // 03 TXT Descricao
            ?
            :MoveNext()
         ENDDO
         :CloseRecordset()
      ENDWITH
   ENDIF
   SomaBloco( "0450" )
   ?? SPED_SEPARADOR
   ?? "0450" + SPED_SEPARADOR                 // 01 REG
   ?? "999999" + SPED_SEPARADOR               // 02 COD_INF Digitacao Livre
   ?? "." + SPED_SEPARADOR                    // 03 TXT Descricao
   ?

   RETURN NIL

STATIC FUNCTION Bloco0460() // Tabela de Obs do Lancamento Fiscal

   RETURN NIL

STATIC FUNCTION Bloco0500() // Plano de Contas

   IF .F.
      SomaBloco( "0500" )
      ?? SPED_SEPARADOR
      ?? "0500" + SPED_SEPARADOR                             // 01 REG
      ?? FormatoData( CToD( "01/01/80" ) ) + SPED_SEPARADOR      // 02 DT_ALT Data inclusão/alteração
      ?? "09" + SPED_SEPARADOR                               // 03 COD_NAT_CC 01-Ativo 02-Passivo 03-Patrimônio 04-Resultado 05-Compensação 09-Outras
      ?? "S"                                                 // 04 IND_CTA S-Sintética A-Analítica
      ?? "00000" + SPED_SEPARADOR                            // NIVEL Nivel da conta
      ?? "1" + SPED_SEPARADOR                                // COD_CTA Codigo
      ?? "CONTA" + SPED_SEPARADOR                            // NOME_CTA
      ?? "REF" + SPED_SEPARADOR                              // COD_CTA_REF Conta no plano referencial
      ?? "" + SPED_SEPARADOR                                 // CNPJ_EST CNPJ no caso da conta especifica a estabelecimento
      ?
   ENDIF

   RETURN NIL

STATIC FUNCTION Bloco0600() // Centros de Custo

   IF .F.
      SomaBloco( "0600" )
      ?? SPED_SEPARADOR
      ?? "0600" + SPED_SEPARADOR                              // 01 REG
      ?? FormatoData( CToD( "01/01/80" ) ) + SPED_SEPARADOR       // 02 DT_ALT Inclusão/Alteração
      ?? "" + SPED_SEPARADOR                                  // 03 COD_CCUS Codigo do CCusto
      ?? "" + SPED_SEPARADOR                                  // 04 CCUST Nome do CCusto
      ?
   ENDIF

   RETURN NIL

STATIC FUNCTION Bloco0990() // Totalizacao bloco 0

   SomaBloco( "0990" )
   ?? SPED_SEPARADOR
   ?? "0990" + SPED_SEPARADOR                              // 01 REG
   ?? FormatoValor( TotalBloco( "0" ), 0 ) + SPED_SEPARADOR     // 02 QTD_LIN_0 Totais do Bloco 0
   ?

   RETURN NIL

STATIC FUNCTION Bloco9001() // Encerramento

   SomaBloco( "9001" )
   ?? SPED_SEPARADOR
   ?? "9001" + SPED_SEPARADOR       // 01 REG
   ?? "0" + SPED_SEPARADOR          // 02 IND_MOV 0=com dados 1=sem dados
   ?

   RETURN NIL

STATIC FUNCTION Bloco9900()

   LOCAL nCont
   MEMVAR mBlocoLst, mBlocoTot

   // Acumula Proximos e atuais
   AAdd( mBlocoLst, "9900" ) // Bloco atual, sem somar
   AAdd( mBlocoTot, 0 )      // Bloco atual, sem somar
   SomaBloco( "9990" )
   SomaBloco( "9999" )
   FOR nCont = 1 TO Len( mBlocoLst )
      SomaBloco( "9900" )
   NEXT
   // Fim pra acumular proximos
   FOR nCont = 1 TO Len( mBlocoLst )
      ?? SPED_SEPARADOR
      ?? "9900" + SPED_SEPARADOR                                // 01 REG
      ?? mBlocoLst[ nCont ] + SPED_SEPARADOR                      // 02 REG_BLC
      ?? FormatoValor( mBlocoTot[ nCont ], 0 ) + SPED_SEPARADOR      // 03 QTD_REG_BLC Qtd Registros
      ?
   NEXT

   RETURN NIL

STATIC FUNCTION Bloco9990()

   ?? SPED_SEPARADOR
   ?? "9990" + SPED_SEPARADOR                              // 01 REG
   ?? FormatoValor( TotalBloco( "9" ), 0 ) + SPED_SEPARADOR     // 02 QTD_LIN_9
   ?

   RETURN NIL

STATIC FUNCTION Bloco9999()

   ?? SPED_SEPARADOR
   ?? "9999" + SPED_SEPARADOR                              // 01 REG
   ?? FormatoValor( TotalBloco( "" ), 0 ) + SPED_SEPARADOR      // 02 QTD_LIN
   ?

   RETURN NIL

STATIC FUNCTION BlocoA001()

   SomaBloco( "A001" )
   ?? SPED_SEPARADOR
   ?? "A001" + SPED_SEPARADOR           // 01 REG
   ?? "1" + SPED_SEPARADOR              // 02 IND_MOV 0=com inf 1=sem inf
   ?

   RETURN NIL

STATIC FUNCTION BlocoA990()

   SomaBloco( "A990" )
   ?? SPED_SEPARADOR
   ?? "A990" + SPED_SEPARADOR                                 // 01 REG
   ?? FormatoValor( TotalBloco( "A" ), 0 ) + SPED_SEPARADOR        // 02 QT_LIN_A
   ?

   RETURN NIL

STATIC FUNCTION BlocoC001()

   SomaBloco( "C001" )
   ?? SPED_SEPARADOR
   ?? "C001" + SPED_SEPARADOR           // 01 REG
   ?? "0" + SPED_SEPARADOR              // 02 IND_MOV 0=com inf 1=sem inf
   ?

   RETURN NIL

STATIC FUNCTION BlocoC010()

   SomaBloco( "C010" )
   ?? SPED_SEPARADOR
   ?? "C010" + SPED_SEPARADOR                         // 01 REG
   ?? SoNumeros( jpempre->emCnpj ) + SPED_SEPARADOR     // 02 CNPJ
   ?? "2" + SPED_SEPARADOR                            // 03 IND_ESCRI 1=por totais C180, C190 e C490, 2=detalhado C100, C170 e C400
   ?

   RETURN NIL

STATIC FUNCTION BlocoC100()

   LOCAL mNota, cnMySql := ADOClass():New( AppcnMySqlLocal() )
   MEMVAR mDatIni, mDatFim, mTipoSPed

   IF AppcnMySqlLocal() == NIL
      RETURN NIL
   ENDIF
   // parte 1 - notas emitidas
   SELECT jpnota
   GOTO TOP
   DO WHILE ! Eof()
      IF jpnota->nfDatEmi < mDatIni .OR. jpnota->nfDatEmi > mDatFim
         SKIP
         LOOP
      ENDIF
      IF jpnota->nfStatus == "C"
         SKIP
         LOOP
      ENDIF
      SomaBloco( "C100" )
      ?? SPED_SEPARADOR
      ?? "C100" + SPED_SEPARADOR                                   // 01 REG
      IF SubStr( jpnota->nfCfOp, 1, 1 ) < "5"
         ?? "0" + SPED_SEPARADOR                                   // 02 IND_OPER 0=Entrada
      ELSE
         ?? "1" + SPED_SEPARADOR                                   // 02 IND_OPER 1=Saida
      ENDIF
      ?? "0" + SPED_SEPARADOR                                      // 03 IND_EMIT 0=Propria 1=Terceiros
      ?? jpnota->nfCadDes + SPED_SEPARADOR                         // 04 COD_PART Codigo de cadastro
      ?? "55" + SPED_SEPARADOR                                     // 05 COD_MOD Cod Modelo de Doc Fiscal 55=Eletronica
      ?? "00" + SPED_SEPARADOR                                     // 06 COD_SIT Sit.Doc.Fiscal
      ?? "001" + SPED_SEPARADOR                                    // 07 SER Serie
      ?? jpnota->nfNotFis + SPED_SEPARADOR                         // 08 NUM_DOC
      cnMySql:cSql := "SELECT KKCHAVE FROM JPNFEKEY WHERE KKNOTFIS=" + StringSql( jpnota->nfNotFis ) + " AND KKEMINFE=" + StringSql( jpempre->emCnpj ) + " AND KKMODFIS='55'"
      cnMySql:Execute()
      IF cnMySql:Eof()
         ?? "" + SPED_SEPARADOR                                    // 09 CHV_NFE Chave NF eletronica
      ELSE
         ?? cnMySql:StringSql( "KKCHAVE" ) + SPED_SEPARADOR       // 09 CHV_NFE Chave NF eletronica
      ENDIF
      cnMySql:CloseRecordset()
      ?? FormatoData( jpnota->nfDatEmi ) + SPED_SEPARADOR            // 10 DT_DOC Emissao
      ?? FormatoData( jpnota->nfDatSai ) + SPED_SEPARADOR            // 11 DT_E_S Data Entrada/Saida
      ?? FormatoValor( jpnota->nfValNot, 2 ) + SPED_SEPARADOR         // 12 VL_DOC
      ?? "1" + SPED_SEPARADOR                                      // 13 IND_PGTO 0=vista 1=prazo 9-sem pagto
      ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR                        // 14 VL_DESC Vlr Desconto
      ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR                        // 15 VL_ABAT_NT Abatimento nao tribut
      ?? FormatoValor( jpnota->nfValPro, 2 ) + SPED_SEPARADOR         // 16 VL_MERC
      ?? "1" + SPED_SEPARADOR                                      // 17 IND_FRT 0=terceiros 1=emitente 2=destinatario 9=sem frete
      ?? FormatoValor( jpnota->nfValFre, 2 ) + SPED_SEPARADOR         // 18 VL_FRT Frete
      ?? FormatoValor( jpnota->nfValSeg, 2 ) + SPED_SEPARADOR         // 19 VL_SEG Seguro
      ?? FormatoValor( jpnota->nfValOut, 2 ) + SPED_SEPARADOR         // 20 VL_OUT_DA Outras
      ?? FormatoValor( jpnota->nfIcmBas, 2 ) + SPED_SEPARADOR         // 21 VL_BC_ICMS
      ?? FormatoValor( jpnota->nfIcmVal, 2 ) + SPED_SEPARADOR         // 22 VL_ICMS
      ?? FormatoValor( jpnota->nfSubBas, 2 ) + SPED_SEPARADOR         // 23 VL_BC_ICMS_ST
      ?? FormatoValor( jpnota->nfSubVal, 2 ) + SPED_SEPARADOR         // 24 VL_ICMS_ST
      ?? FormatoValor( jpnota->nfIpiVal, 2 ) + SPED_SEPARADOR         // 25 VL_IPI
      ?? FormatoValor( jpnota->nfPisVal, 2 ) + SPED_SEPARADOR         // 26 VL_PIS
      ?? FormatoValor( jpnota->nfCofVal, 2 ) + SPED_SEPARADOR         // 27 VL_COFINS
      ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR                        // 28 VL_PIS_ST
      ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR                        // 29 VL_COFINS_ST
      ?
      IF mTipoSPed == "F"
         BlocoC105()
      ENDIF
      BlocoC110()
      IF mTipoSPed == "F"
         BlocoC111()
         BlocoC112()
         BlocoC113()
         BlocoC114()
         BlocoC115()
         BlocoC140()
      ENDIF
      Encontra( jpnota->nfPedido, "jppedi", "pedido" )
      BlocoC170() // Itens dos pedidos
      SELECT jpnota // os anteriores desposicionam
      SKIP
   ENDDO

   // parte 2 - notas de terceiros

   SELECT jppedi
   // nao tem indice pra agilizar
   GOTO TOP
   DO WHILE ! Eof()
      IF jppedi->pdDatEmi < mDatIni .OR. jppedi->pdDatEmi > mDatFim
         SKIP
         LOOP
      ENDIF
      IF Encontra( jppedi->pdPedido, "jpnota", "pedido" )
         SKIP
         LOOP
      ENDIF
      IF jppedi->pdConf != "S"
         SKIP
         LOOP
      ENDIF
      mNota := SoNumeros( jppedi->pdPedCli )
      IF Len( mNota ) < 6
         mNota := PadL( mNota, 6, "0" )
      ELSE
         mNota := Right( mNota, 6 )
      ENDIF
      IF Val( mNota ) == 0
         SKIP
         LOOP
      ENDIF
      Encontra( jppedi->pdPedido, "jpitped", "pedido" )
      SomaBloco( "C100" )
      ?? SPED_SEPARADOR
      ?? "C100" + SPED_SEPARADOR                           // 01 REG
      IF SubStr( jpitped->ipCfOp, 1, 1 ) < "5"
         ?? "0" + SPED_SEPARADOR                           // 02 IND_OPER 0=Entrada
      ELSE
         ?? "1" + SPED_SEPARADOR                           // 02 IND_OPER 1=Saida
      ENDIF
      ?? "1" + SPED_SEPARADOR                              // 03 IND_EMIT 0=Propria 1=Terceiros
      ?? jppedi->pdCliFor + SPED_SEPARADOR                 // 04 COD_PART Codigo de cadastro
      Encontra( jppedi->pdCliFor, "jpcadas", "numlan" )
      IF Eof()
         ?? "01" + SPED_SEPARADOR                           // 05 COD_MOD Cod Modelo de Doc Fiscal 01=Nota Fiscal
      ELSE
         ?? "55" + SPED_SEPARADOR                          // 05 COD_MOD Cod Modelo de Doc Fiscal 55=Eletronica
      ENDIF
      ?? "00" + SPED_SEPARADOR                             // 06 COD_SIT Sit.Doc.Fiscal
      ?? "001" + SPED_SEPARADOR                            // 07 SER Serie
      ?? mNota + SPED_SEPARADOR                            // 08 NUM_DOC
      ?? "" + SPED_SEPARADOR                               // 09 CHV_NFE Chave NF eletronica (Nao informar para terceiros)
      ?? FormatoData( jppedi->pdDatEmi ) + SPED_SEPARADOR    // 10 DT_DOC Emissao
      ?? FormatoData( jppedi->pdDatEmi ) + SPED_SEPARADOR    // 11 DT_E_S Data Entrada/Saida
      ?? FormatoValor( jppedi->pdValNot, 2 ) + SPED_SEPARADOR // 12 VL_DOC
      ?? "1" + SPED_SEPARADOR                              // 13 IND_PGTO 0=vista 1=prazo 9-sem pagto
      ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR                // 14 VL_DESC Vlr Desconto
      ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR                // 15 VL_ABAT_NT Abatimento nao tribut
      ?? FormatoValor( jppedi->pdValPro, 2 ) + SPED_SEPARADOR // 16 VL_MERC
      ?? "1" + SPED_SEPARADOR                              // 17 IND_FRT 0=terceiros 1=emitente 2=destinatario 9=sem frete
      ?? FormatoValor( jppedi->pdValFre, 2 ) + SPED_SEPARADOR // 18 VL_FRT Frete
      ?? FormatoValor( jppedi->pdValSeg, 2 ) + SPED_SEPARADOR // 19 VL_SEG Seguro
      ?? FormatoValor( jppedi->pdValOut, 2 ) + SPED_SEPARADOR // 20 VL_OUT_DA Outras
      ?? FormatoValor( jppedi->pdIcmBas, 2 ) + SPED_SEPARADOR // 21 VL_BC_ICMS
      ?? FormatoValor( jppedi->pdIcmVal, 2 ) + SPED_SEPARADOR // 22 VL_ICMS
      ?? FormatoValor( jppedi->pdSubBas, 2 ) + SPED_SEPARADOR // 23 VL_BC_ICMS_ST
      ?? FormatoValor( jppedi->pdSubVal, 2 ) + SPED_SEPARADOR // 24 VL_ICMS_ST
      ?? FormatoValor( jppedi->pdIpiVal, 2 ) + SPED_SEPARADOR // 25 VL_IPI
      ?? FormatoValor( jppedi->pdPisVal, 2 ) + SPED_SEPARADOR // 26 VL_PIS
      ?? FormatoValor( jppedi->pdCofVal, 2 ) + SPED_SEPARADOR // 27 VL_COFINS
      ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR                // 28 VL_PIS_ST
      ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR                // 29 VL_COFINS_ST
      ?
      // IF mTipoSPed == "F"
      // BlocoC105()
      // ENDIF
      // BlocoC110()
      // IF mTipoSPed == "F"
      // BlocoC111()
      // BlocoC112()
      // BlocoC113()
      // BlocoC114()
      // BlocoC115()
      // BlocoC140()
      // ENDIF
      // Encontra(jpnota->nfPedido,"jppedi","pedido") // para pedidos, ja posicionado
      BlocoC170() // Itens dos pedidos
      SELECT jppedi // os anteriores desposicionam
      SKIP
   ENDDO

   RETURN NIL

STATIC FUNCTION BlocoC105() // Operacoes com ST recolhido pra outra UF

   RETURN NIL

STATIC FUNCTION BlocoC110()

   LOCAL mLstLei, mLei, mLeiLst
   LOCAL cnJPDECRET := ADOClass():New( AppcnMySqlLocal() )

   mLstLei := Trim( jpnota->nfLeis )
   DO WHILE Len( mLstLei ) > 0
      mLei := SubStr( mLeiLst, 1, 6 )
      mLeiLst := SubStr( mLeiLst, 8 )
      IF Val( mLei ) != 0
         IF AppcnMySqlLocal() == NIL
            IF Encontra( mLei, "jpdecret", "numlan" )
               SomaBloco( "C110" )
               ?? SPED_SEPARADOR
               ?? "C110" + SPED_SEPARADOR                // 01 REG
               ?? mLei + SPED_SEPARADOR                  // 02 COD_INF
               ?? "" + SPED_SEPARADOR
               ?
            ENDIF
         ELSE
            cnJPDECRET:cSql := "SELECT COUNT(*) AS QTD FROM JPDECRET WHERE DENUMLAN=" + StringSql( mLei )
            IF cnJPDECRET:ReturnValueAndClose( "QTD" ) > 0
               SomaBloco( "C110" )
               ?? SPED_SEPARADOR
               ?? "C110" + SPED_SEPARADOR                // 01 REG
               ?? mLei + SPED_SEPARADOR                  // 02 COD_INF
               ?? "" + SPED_SEPARADOR
               ?
            ENDIF
         ENDIF
      ENDIF
   ENDDO
   // mObs := Trim(jpnota->nfObs1 + jpnota->nfObs2 + jpnota->nfObs3 + jpnota->nfObs4)
   // IF ! Empty(mObs)
   // ?? SPED_SEPARADOR
   // ?? "C110" + SPED_SEPARADOR              // 01 REG
   // ?? "999999" + SPED_SEPARADOR            // 02 COD_INF
   // ?? mObs + SPED_SEPARADOR
   // ?
   // SomaBloco("C110")
   // ENDIF

   RETURN NIL

STATIC FUNCTION BlocoC111() // Processo Referenciado

   RETURN NIL

STATIC FUNCTION BlocoC112() // Documento de Arrecadacao Referenciado

   RETURN NIL

STATIC FUNCTION BlocoC113() // Documento Fiscal Referenciado

   RETURN NIL

STATIC FUNCTION BlocoC114() // Cupom Fiscal Referencaido

   RETURN NIL

STATIC FUNCTION BlocoC115() // Local de Coleta/Entrega

   IF .F. // falta detalhar
      SomaBloco( "C115" )
      ?? "C115" + SPED_SEPARADOR    // 01 REG
      ?? "0" + SPED_SEPARADOR       // 02 IND_CARGA 0=Rodoviario 1=Ferroviario 2=RodoFerrov 3=Aquaviario 4=Dutoviario 5=Aereo 9=Outros
      ?? "" + SPED_SEPARADOR        // 03 CNPJ_COL CNPJ do local de coleta
      ?? "" + SPED_SEPARADOR        // 04 IE_COL Inscricao do local de coleta
      ?? "" + SPED_SEPARADOR        // 05 CPF_COL CPF do local de coleta
      ?? "" + SPED_SEPARADOR        // 06 COD_MUN_COL Municipio de coleta IBGE
      ?? "" + SPED_SEPARADOR        // 07 CNPJ_ENTG CNPJ local de entrega
      ?? "" + SPED_SEPARADOR        // 08 IE_ENTG Inscr do local de entrega
      ?? "" + SPED_SEPARADOR        // 09 CPF_ENTG CPF local entrega
      ?? "" + SPED_SEPARADOR        // 10 COD_MUN_ENTG Municipio IBGE Entrega
      ?
   ENDIF

   RETURN NIL

STATIC FUNCTION BlocoC140() // Faturas

   RETURN NIL

STATIC FUNCTION BlocoC170()

   LOCAL mSequencia, mIndice
   MEMVAR mPisLst, mPisVal, mCofLst, mCofVal, mCofBas, mPisBas

   SELECT jpitped
   SEEK jppedi->PdPedido
   mSequencia := 1
   DO WHILE jpitped->ipPedido == jppedi->pdPedido .AND. ! Eof()
      Encontra( jpitped->ipItem, "jpitem", "item" )
      SomaBloco( "C170" )
      ?? SPED_SEPARADOR
      ?? "C170" + SPED_SEPARADOR                              // 01 REG
      ?? StrZero( mSequencia, 3 ) + SPED_SEPARADOR               // 02 NUM_ITEM
      ?? jpitped->ipItem + SPED_SEPARADOR                     // 03 COD_ITEM
      ?? "" + SPED_SEPARADOR                                  // 04 DESCR_COMPL Complemento de Descricao
      ?? FormatoValor( jpitped->ipQtde, 5 ) + SPED_SEPARADOR     // 05 QTD
      ?? Trim( jpitem->ieUnid ) + SPED_SEPARADOR                // 06 UNID
      ?? FormatoValor( jpitped->ipValPro, 2 ) + SPED_SEPARADOR   // 07 VL_ITEM
      ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR                   // 08 VL_DESC Descto Comercial
      ?? "0" + SPED_SEPARADOR                                 // 09 IND_MOV Movimentacao Fisica 0=Sim 1=Nao
      ?? Trim( jpitped->ipIcmCst ) + SPED_SEPARADOR             // 10 CST_ICMS (no sistema tem 4 digitos pra aceitar CSOSN)
      ?? SoNumeros( jpitped->ipCfOp ) + SPED_SEPARADOR          // 11 CFOP
      ?? Trim( jpitped->ipCfOp ) + SPED_SEPARADOR               // 12 COD_NAT natureza conf cadastro
      ?? FormatoValor( jpitped->ipIcmBas, 2 ) + SPED_SEPARADOR   // 13 VL_BC_ICMS
      ?? FormatoValor( jpitped->ipIcmAli, 2 ) + SPED_SEPARADOR   // 14 ALIQ_ICMS
      ?? FormatoValor( jpitped->ipIcmVal, 2 ) + SPED_SEPARADOR   // 15 VL_ICMS
      ?? FormatoValor( jpitped->ipSubBas, 2 ) + SPED_SEPARADOR   // 16 VL_BC_ICMS_ST
      ?? FormatoValor( jpitped->ipSubAli, 2 ) + SPED_SEPARADOR   // 17 ALIQ_ST
      ?? FormatoValor( jpitped->ipSubVal, 2 ) + SPED_SEPARADOR   // 18 VL_ICMS_ST
      ?? "0" + SPED_SEPARADOR                                 // 19 IND_APUR IPI 0=Mensal 1=Decendial
      ?? jpitped->ipIpiCst + SPED_SEPARADOR                   // 20 CST_IPI
      ?? iif( Empty( Trim( jpitped->ipIpiEnq ) ), "999", Trim( jpitped->ipIpiEnq ) ) + SPED_SEPARADOR             // 21 COD_ENQ Cod Enquadramento IPI
      ?? FormatoValor( jpitped->ipIpiBas, 2 ) + SPED_SEPARADOR   // 22 VL_BC_IPI
      ?? FormatoValor( jpitped->ipIpiAli, 2 ) + SPED_SEPARADOR   // 23 ALIQ_IPI
      ?? FormatoValor( jpitped->ipIpiVal, 2 ) + SPED_SEPARADOR   // 24 VL_IPI
      ?? jpitped->ipPisCst + SPED_SEPARADOR                   // 25 CST_PIS
      ?? FormatoValor( jpitped->ipPisBas, 2 ) + SPED_SEPARADOR   // 26 VL_BC_PIS
      IF jpitped->ipPisAli == 0
         ?? SPED_SEPARADOR
      ELSE
         ?? PadL( FormatoValor( jpitped->ipPisAli, 4 ), 8, "0" ) + SPED_SEPARADOR // 27 ALIQ_PIS No Fiscal 8 digitos
      ENDIF
      IF 0 = 0
         ?? "" + SPED_SEPARADOR
         ?? "" + SPED_SEPARADOR
      ELSE
         ?? FormatoValor( 0, 3 ) + SPED_SEPARADOR                   // 28 QUANT_BC_PIS
         ?? FormatoValor( 0, 4 ) + SPED_SEPARADOR                   // 29 ALIQ_PIS_QUANT
      ENDIF
      ?? FormatoValor( jpitped->ipPisVal, 2 ) + SPED_SEPARADOR   // 30 VL_PIS
      ?? jpitped->ipCofCst + SPED_SEPARADOR                   // 31 CST_COFINS
      ?? FormatoValor( jpitped->ipCofBas, 2 ) + SPED_SEPARADOR   // 32 VL_BC_COFINS
      IF jpitped->ipCofAli == 0
         ?? SPED_SEPARADOR
      ELSE
         ?? PadL( FormatoValor( jpitped->ipCofAli, 4 ), 8, "0" ) + SPED_SEPARADOR // 33 ALIQ_COFINS No Fiscal 8 digitos
      ENDIF
      IF 0 = 0
         ?? "" + SPED_SEPARADOR
         ?? "" + SPED_SEPARADOR
      ELSE
         ?? FormatoValor( 0, 3 ) + SPED_SEPARADOR                   // 34 QUANT_BC_COFINS
         ?? FormatoValor( 0, 4 ) + SPED_SEPARADOR                   // 35 ALIQ_COFINS_QUANT
      ENDIF
      ?? FormatoValor( jpitped->ipCofVal, 2 ) + SPED_SEPARADOR   // 36 VL_COFINS
      ?? "" + SPED_SEPARADOR                                  // 37 COD_CTA Conta contabil debitada/creditada
      ?
      // Acumula Pis
      IF AScan( mPisLst, jpitped->ipPisCst ) == 0
         AAdd( mPisLst, jpitped->ipPisCst )
         AAdd( mPisBas, 0 )
      ENDIF
      mIndice := AScan( mPisLst, jpitped->ipPisCst )
      mPisBas[ mIndice ] += jpitped->ipValNot
      // Acumula Cofins
      IF AScan( mCofLst, jpitped->ipCofCst ) == 0
         AAdd( mCofLst, jpitped->ipCofCst )
         AAdd( mCofBas, 0 )
      ENDIF
      mIndice := AScan( mCofLst, jpitped->ipCofCst )
      mCofBas[ mIndice ] += jpitped->ipValNot
      mSequencia := mSequencia + 1
      SKIP
   ENDDO

   RETURN NIL

STATIC FUNCTION BlocoC990()

   SomaBloco( "C990" )
   ?? SPED_SEPARADOR
   ?? "C990" + SPED_SEPARADOR                                // 01 REG
   ?? FormatoValor( TotalBloco( "C" ), 0 ) + SPED_SEPARADOR       // 02 QT_LIN_C
   ?

   RETURN NIL

STATIC FUNCTION BlocoD001()

   SomaBloco( "D001" )
   ?? SPED_SEPARADOR
   ?? "D001" + SPED_SEPARADOR            // 01 REG
   ?? "1" + SPED_SEPARADOR               // 02 IND_MOV 0=com inf 1=sem inf
   ?

   RETURN NIL

STATIC FUNCTION BlocoD990()

   SomaBloco( "D990" )
   ?? SPED_SEPARADOR
   ?? "D990" + SPED_SEPARADOR                                // 01 REG
   ?? FormatoValor( TotalBloco( "D" ), 0 ) + SPED_SEPARADOR       // 02 QT_LIN_D
   ?

   RETURN NIL

STATIC FUNCTION BlocoE001()

   SomaBloco( "E001" )
   ?? SPED_SEPARADOR
   ?? "E001" + SPED_SEPARADOR            // 01 REG
   ?? "0" + SPED_SEPARADOR               // 02 IND_MOV 0=com inf 1=sem inf
   ?

   RETURN NIL

STATIC FUNCTION BlocoE100()

   MEMVAR mDatIni, mDatFim

   SomaBloco( "E100" )
   ?? SPED_SEPARADOR
   ?? "E100" + SPED_SEPARADOR                    // 01 REG
   ?? FormatoData( mDatIni ) + SPED_SEPARADOR      // 02 DT_INI
   ?? FormatoData( mDatFim ) + SPED_SEPARADOR      // 03 DT_FIM
   ?

   RETURN NIL

STATIC FUNCTION BlocoE110()

   SomaBloco( "E110" )
   ?? SPED_SEPARADOR
   ?? "E110" + SPED_SEPARADOR           // 01 REG
   ?? FormatoValor( 0 ) + SPED_SEPARADOR  // 02 VL_TOT_DEBITOS
   ?? FormatoValor( 0 ) + SPED_SEPARADOR  // 03 VL_AJ_DEBITOS
   ?? FormatoValor( 0 ) + SPED_SEPARADOR  // 04 VL_TOT_AJ_DEBITOS
   ?? FormatoValor( 0 ) + SPED_SEPARADOR  // 05 VL_ESTORNOS_CRED
   ?? FormatoValor( 0 ) + SPED_SEPARADOR  // 06 VL_TOT_CREDITOS
   ?? FormatoValor( 0 ) + SPED_SEPARADOR  // 07 VL_AJ_CREDITOS
   ?? FormatoValor( 0 ) + SPED_SEPARADOR  // 08 VL_TOT_AJ_CREDITOS
   ?? FormatoValor( 0 ) + SPED_SEPARADOR  // 09 VL_ESTORNOS_DEB
   ?? FormatoValor( 0 ) + SPED_SEPARADOR  // 10 VL_SLD_CREDOR_ANT
   ?? FormatoValor( 0 ) + SPED_SEPARADOR  // 11 VL_SLD_APURADO
   ?? FormatoValor( 0 ) + SPED_SEPARADOR  // 12 VL_TOT_DED
   ?? FormatoValor( 0 ) + SPED_SEPARADOR  // 13 VL_ICMS_RECOLHER
   ?? FormatoValor( 0 ) + SPED_SEPARADOR  // 14 VL_SLD_CREDOR_TRANSPORTAR
   ?? FormatoValor( 0 ) + SPED_SEPARADOR  // 15 DEB_ESP
   ?

   RETURN NIL

STATIC FUNCTION BlocoE990()

   SomaBloco( "E990" )
   ?? SPED_SEPARADOR
   ?? "E990" + SPED_SEPARADOR                                // 01 REG
   ?? FormatoValor( TotalBloco( "E" ), 0 ) + SPED_SEPARADOR       // 02 QT_LIN_D
   ?

   RETURN NIL

STATIC FUNCTION BlocoF001()

   SomaBloco( "F001" )
   ?? SPED_SEPARADOR
   ?? "F001" + SPED_SEPARADOR        // 01 REG
   ?? "1" + SPED_SEPARADOR           // 02 IND_MOV 0=com inf 1=sem inf
   ?

   RETURN NIL

STATIC FUNCTION BlocoF990()

   SomaBloco( "F990" )
   ?? SPED_SEPARADOR
   ?? "F990" + SPED_SEPARADOR                             // 01 REG
   ?? FormatoValor( TotalBloco( "F" ), 0 ) + SPED_SEPARADOR    // 02 QT_LIN_F
   ?

   RETURN NIL

STATIC FUNCTION BlocoG001()

   SomaBloco( "G001" )
   ?? SPED_SEPARADOR
   ?? "G001" + SPED_SEPARADOR        // 01 REG
   ?? "1" + SPED_SEPARADOR           // 02 IND_MOV 0=com inf 1=sem inf
   ?

   RETURN NIL

STATIC FUNCTION BlocoG990()

   SomaBloco( "G990" )
   ?? SPED_SEPARADOR
   ?? "G990" + SPED_SEPARADOR                             // 01 REG
   ?? FormatoValor( TotalBloco( "G" ), 0 ) + SPED_SEPARADOR    // 02 QT_LIN_F
   ?

   RETURN NIL

STATIC FUNCTION BlocoH001()

   SomaBloco( "H001" )
   ?? SPED_SEPARADOR
   ?? "H001" + SPED_SEPARADOR        // 01 REG
   ?? "1" + SPED_SEPARADOR           // 02 IND_MOV 0=com inf 1=sem inf
   ?

   RETURN NIL

STATIC FUNCTION BlocoH990()

   SomaBloco( "H990" )
   ?? SPED_SEPARADOR
   ?? "H990" + SPED_SEPARADOR                             // 01 REG
   ?? FormatoValor( TotalBloco( "H" ), 0 ) + SPED_SEPARADOR    // 02 QT_LIN_F
   ?

   RETURN NIL

STATIC FUNCTION BlocoM001()

   SomaBloco( "M001" )
   ?? SPED_SEPARADOR
   ?? "M001" + SPED_SEPARADOR     // 01 REG
   ?? "0" + SPED_SEPARADOR        // 02 IND_MOV 0=com inf 1=sem inf
   ?

   RETURN NIL

STATIC FUNCTION BlocoM200()

   SomaBloco( "M200" )
   ?? SPED_SEPARADOR
   ?? "M200" + SPED_SEPARADOR // 01 REG
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 02 VL_TOT_CONT_NC_PER Vl Tot Cont Nao Cum Periodo
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 03 VL_TOT_CRED_DESC Vl Tot Credito Desc
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 04 VL_TOT_CRED_DESC_ANT Vl Tot Cred Anterior
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 05 VL_TOT_CONT_NC_DEV Vl Tot Nao Cum Devedor
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 06 VL_RET_NC Vl Retido na Fonte Deduzido
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 07 VL_OUT_DEC_NC Outras Deducoes
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 08 VL_CONT_NC_REC Vl Contr Recolher/Pagar
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 09 VL_TOT_CONT_CUM_PER Vl Recuperado
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 10 VL_RET_CUM Vl Retido na Fonte
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 11 VL_OUT_DED_CUM Outras Deducoes
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 12 VL_CONT_CUM_REC Vl a Recolher
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 13 VL_TOT_CONT_REC Vl Recolher/Pagar no Periodo
   ?

   RETURN NIL

STATIC FUNCTION BlocoM400()

   LOCAL nCont
   MEMVAR mPisLst, mPisBas

   FOR nCont = 1 TO Len( mPisLst )
      SomaBloco( "M400" )
      ?? SPED_SEPARADOR
      ?? "M400" + SPED_SEPARADOR                             // 01 REG
      ?? mPisLst[ nCont ] + SPED_SEPARADOR                     // 02 CST_PIS
      ?? FormatoValor( mPisBas[ nCont ], 2 ) + SPED_SEPARADOR     // 03 VL_TOT_REC
      ?? "" + SPED_SEPARADOR                                 // 04 COD_CTA Conta Contabil
      ?? "" + SPED_SEPARADOR                                 // 05 DESC_COMPL Descricao Complementar
      ?
   NEXT

   RETURN NIL

STATIC FUNCTION BlocoM410()

   MEMVAR mPisLst, mPisBas

   IF Len( mPisLst ) > 0
      SomaBloco( "M410" )
      ?? SPED_SEPARADOR
      ?? "M410" + SPED_SEPARADOR                         // 01 REG
      ?? "201" + SPED_SEPARADOR                          // 02 NAT_REC 201=Biodiesel
      ?? FormatoValor( mPisBas[ 1 ], 2 ) + SPED_SEPARADOR     // 03 VL_REC
      ?? "" + SPED_SEPARADOR                             // 04 COD_CTA Conta Contabil
      ?? "" + SPED_SEPARADOR                             // 05 DESC_COMPL Descricao complementar
      ?
   ENDIF

   RETURN NIL

STATIC FUNCTION BlocoM600()

   SomaBloco( "M600" )
   ?? SPED_SEPARADOR
   ?? "M600" + SPED_SEPARADOR // 01 REG
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 02 VL_TOT_CONT_NC_PER Vl Tot Cont Nao Cum Periodo
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 03 VL_TOT_CRED_DESC Vl Tot Credito Desc
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 04 VL_TOT_CRED_DESC_ANT Vl Tot Cred Anterior
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 05 VL_TOT_CONT_NC_DEV Vl Tot Nao Cum Devedor
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 06 VL_RET_NC Vl Retido na Fonte Deduzido
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 07 VL_OUT_DEC_NC Outras Deducoes
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 08 VL_CONT_NC_REC Vl Contr Recolher/Pagar
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 09 VL_TOT_CONT_CUM_PER Vl Recuperado
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 10 VL_RET_CUM Vl Retido na Fonte
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 11 VL_OUT_DED_CUM Outras Deducoes
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 12 VL_CONT_CUM_REC Vl a Recolher
   ?? FormatoValor( 0, 2 ) + SPED_SEPARADOR // 13 VL_TOT_CONT_REC Vl Recolher/Pagar no Periodo
   ?

   RETURN NIL

STATIC FUNCTION BlocoM800()

   LOCAL nCont
   MEMVAR mCofLst, mCofBas

   FOR nCont = 1 TO Len( mCofLst )
      SomaBloco( "M800" )
      ?? SPED_SEPARADOR
      ?? "M800" + SPED_SEPARADOR                               // 01 REG
      ?? mCofLst[ nCont ] + SPED_SEPARADOR                       // 02 CST_COFINS
      ?? FormatoValor( mCofBas[ nCont ], 2 ) + SPED_SEPARADOR       // 03 VL_TOT_REC
      ?? "" + SPED_SEPARADOR                                   // 04 COD_CTA Conta Contabil
      ?? "" + SPED_SEPARADOR                                   // 05 DESC_COMPL Descricao Complementar
      ?
   NEXT

   RETURN NIL

STATIC FUNCTION BlocoM810()

   MEMVAR mCofLst, mCofBas

   IF Len( mCofLst ) > 0
      SomaBloco( "M810" )
      ?? SPED_SEPARADOR
      ?? "M810" + SPED_SEPARADOR                        // 01 REG
      ?? "201" + SPED_SEPARADOR                         // 02 NAT_REC 201=Biodiesel
      ?? FormatoValor( mCofBas[ 1 ], 2 ) + SPED_SEPARADOR    // 03 VL_REC
      ?? "" + SPED_SEPARADOR                            // 04 COD_CTA Conta Contabil
      ?? "" + SPED_SEPARADOR                            // 05 DESC_COMPL Descricao complementar
      ?
   ENDIF

   RETURN NIL

STATIC FUNCTION BlocoM990()

   SomaBloco( "M990" )
   ?? SPED_SEPARADOR
   ?? "M990" + SPED_SEPARADOR                                // 01 REG
   ?? FormatoValor( TotalBloco( "M" ), 0 ) + SPED_SEPARADOR       // 02 QT_LIN_M
   ?

   RETURN NIL

STATIC FUNCTION Bloco1001()

   SomaBloco( "1001" )
   ?? SPED_SEPARADOR
   ?? "1001" + SPED_SEPARADOR         // 01 REG
   ?? "1" + SPED_SEPARADOR            // 02 IND_MOV 0=com inf 1=sem inf
   ?

   RETURN NIL

STATIC FUNCTION Bloco1990()

   SomaBloco( "1990" )
   ?? SPED_SEPARADOR
   ?? "1990" + SPED_SEPARADOR                                // 01 REG
   ?? FormatoValor( TotalBloco( "1" ), 0 ) + SPED_SEPARADOR       // 02 QT_LIN_1
   ?

   RETURN NIL

STATIC FUNCTION FormatoData( mData )

   LOCAL mReturn

   mReturn := ;
      StrZero( Day( mData ), 2 ) + ;
      StrZero( Month( mData ), 2 ) + ;
      StrZero( Year( mData ), 4 )

   RETURN mReturn

STATIC FUNCTION FormatoValor( mValor, mDecimais )

   LOCAL mReturn, mPicture

   hb_Default( @mDecimais, 2 )
   mPicture := "@E 999999999999" + iif( mDecimais > 0, "." + Replicate( "9", mDecimais ), "" )
   mReturn := LTrim( Transform( mValor, mPicture ) )

   RETURN mReturn

STATIC FUNCTION SomaBloco( cBloco )

   LOCAL mIndice
   MEMVAR mBlocoLst, mBlocoTot

   IF AScan( mBlocoLst, cBloco ) == 0
      AAdd( mBlocoLst, cBloco )
      AAdd( mBlocoTot, 0 )
   ENDIF
   mIndice := AScan( mBlocoLst, cBloco )
   mBlocoTot[ mIndice ] += 1

   RETURN NIL

STATIC FUNCTION TotalBloco( cBloco )

   LOCAL mTotal := 0, nCont
   MEMVAR mBlocoLst, mBlocoTot

   FOR nCont = 1 TO Len( mBlocoLst )
      IF Pad( mBlocoLst[ nCont ], Len( cBloco ) ) == cBloco
         mTotal := mTotal + mBlocoTot[ nCont ]
      ENDIF
   NEXT

   RETURN mTotal
