/*
ZE_UPDATEDEFAULT
José Quintas
*/

#include "josequintas.ch"

FUNCTION JPDECRETDefault()

   LOCAL oElement, oRecList

   IF ! File( "JPDECRET.DBF" )
      RETURN NIL
   ENDIF
   IF ! AbreArquivos( "jpdecret" )
      QUIT
   ENDIF
   oRecList := { ;
      { "ST FABRICANTE",           "CST 010/070: RECOLHIMENTO DO ICMS POR SUBSTITUICAO TRIBUTARIA ARTIGO 313 DO RICMS/SP. O DESTINATARIO " + ;
                                   "DEVERA ESCRITURAR O DOCUMENTO FISCAL NOS TERMOS DO ARTIGO 278 DO RICMS.; " }, ;
      { "ST COMERCIO",             "CST 060: ICMS RECOLHIDO POR SUBSTITUICAO TRIBUTARIA PELO FABRICANTE, CONFORME ARTIGO 412 DO RICMS " + ;
                                   "DECRETO 45.490-2000 DE 30-11-2000.;" }, ;
      { "COMBUSTIVEL ONU 3082",    "ONU 3082 (SUBSTANCIA QUE APRESENTA RISCOS PARA O MEIO AMBIENTE, LIQUIDA, N.E. OLEO COMBUSTIVEL) " + ;
                                   "CLASSE DE RISCO 9 (SUBSTANCIAS E ARTIGOS PERIGOSOS DIVERSOS), EMBALAGEM III (BAIXO RISCO).;" }, ;
      { "COMBUSTIVEL ONU 1202",    "MISTURA DIESEL/BIODIESEL ONU 1202 (OLEO DIESEL) CLASSE DE RISCO 3 (LIQUIDO INFLAMAVEL) EMBALAGEM III " + ;
                                   "(BAIXO RISCO).;" }, ;
      { "COMBUSTIVEL DECLARACAO",  "DECLARAMOS QUE OS PRODUTOS DESTA NFE ESTAO DEVIDAMENTE ACONDICIONADOS PARA SUPORTAR OS RISCOS NORMAIS " + ;
                                   "DAS ETAPAS NECESSARIAS A UMA OPERACAO DE TRANSPORTE, TAIS COMO CARREGAMENTO, DESCARREGAMENTO TRANSBORDO " + ;
                                   "E TRANSPORTE E QUE ATENDEM A REGULAMENTACAO EM VIGOR, SENDO AS RESOLUCOES ANTT 420/04, ALTERADA PELAS " + ;
                                   "RESOLUCOES ANTT 701/04 E 1644/06;" }, ;
      { "COMBUSTIVEL CONFERIR",    "ANTES DE DESCARREGAR O CARRO TANQUE CONFIRA AS QUANTIDADES E EXAMINE A QUALIDADE. APOS O DESCARREGAMENTO " + ;
                                   "EXIJA O ESCORRIMENTO.; QUALQUER IRREGULARIDADE DEVERA SER RECLAMADA ANTES DO DESCARREGAMENTO." }, ;
      { "CONFERIR MERCADORIA",     "CONFIRA A MERCADORIA RECEBIDA. NAO ACEITAMOS RECLAMACOES POSTERIORES.;" }, ;
      { "ARROZ FEIJAO CONS.FINAL", "ARROZ E/OU FEIJAO ISENTO PRA CONSUMIDOR FINAL CONFORME DECRETO 61.745/2015;" }, ;
      { "TRANSP ARROZ FEIJAO",     "TRANSPORTE DE ARROZ E/OU FEIJAO ISENTO PARA CONSUMIDOR FINAL CONFORME DECRETO 61.746/2015;" } }
   IF Eof()
      FOR EACH oElement IN oRecList
         RecAppend()
         REPLACE ;
            jpdecret->DENUMLAN WITH StrZero( oElement:__EnumIndex, 6 ), ;
            jpdecret->DENOME   WITH oElement[ 1 ], ;
            jpdecret->DEDESCR1 WITH Substr( oElement[ 2 ], 1, 250 ), ;
            jpdecret->DEDESCR2 WITH Substr( oElement[ 2 ], 251, 250 ), ;
            jpdecret->DEDESCR3 WITH Substr( oElement[ 2 ], 501, 250 ), ;
            jpdecret->DEDESCR4 WITH Substr( oElement[ 2 ], 750, 250 ), ;
            jpdecret->DEDESCR5 WITH Substr( oElement[ 2 ], 1001, 250 )
         RecUnlock()
      NEXT
   ENDIF
   CLOSE DATABASES

   RETURN NIL

FUNCTION JPEMPREDefault()

   IF ! AbreArquivos( "jpempre" )
      QUIT
   ENDIF
   IF Eof()
      RecAppend()
   ENDIF
   IF Empty( jpempre->emQtdPag )
      RecLock()
      REPLACE jpempre->emQtdPag  WITH 300
   ENDIF
   IF Empty( jpempre->emDiaBal )
      RecLock()
      REPLACE jpempre->emDiaBal  WITH "S"
   ENDIF
   IF Empty( jpempre->emDiaDem )
      RecLock()
      REPLACE jpempre->emDiaDem  WITH "S"
   ENDIF
   IF Empty( jpempre->emDiaPla )
      RecLock()
      REPLACE jpempre->emDiaPla  WITH "S"
   ENDIF
   IF Empty( jpempre->emDiaMes )
      RecLock()
      REPLACE jpempre->emDiaMes  WITH 12
   ENDIF
   IF Empty( jpempre->emFecha )
      RecLock()
      REPLACE jpempre->emFecha WITH 12
   ENDIF
   IF Empty( jpempre->emAnoBase )
      RecLock()
      REPLACE jpempre->emAnoBase WITH Year( Date() ) - 1
   ENDIF
   IF Empty( jpempre->emPicture )
      RecLock()
      REPLACE jpempre->emPicture WITH "9.99.999.9999-9"
   ENDIF
   IF Empty( jpempre->emHisFec )
      RecLock()
      REPLACE jpempre->emHisFec WITH "TRANSFERENCIA PARA APURACAO DO RESULTADO"
   ENDIF
   IF Empty( jpempre->emLote )
      RecLock()
      REPLACE jpempre->emLote WITH "01010001"
   ENDIF
   RecUnlock()
   CLOSE DATABASES

   RETURN NIL

FUNCTION JPCIDADEDefault()

   LOCAL oElement

   IF ! File( "JPCIDADE.DBF" )
      RETURN NIL
   ENDIF
   IF ! AbreArquivos( "jpcidade" )
      RETURN NIL
   ENDIF

   FOR EACH oElement IN ze_TabCidade()
      IF ! Encontra( oElement[ 2 ] + Pad( oElement[ 1 ], Len( jpcidade->ciNome ) ), "jpcidade", "jpcidade3" )
         RecAppend()
      ENDIF
      RecLock()
      REPLACE ;
         jpcidade->ciNumLan WITH StrZero( oElement:__EnumIndex, 6 ), ;
         jpcidade->ciNome   WITH oElement[ 1 ], ;
         jpcidade->ciUf     WITH oElement[ 2 ], ;
         jpcidade->ciIBGE   WITH oElement[ 3 ]
      RecUnlock()
   NEXT

   RETURN NIL

FUNCTION JPUFDefault()

   LOCAL oElement

   IF ! AbreArquivos( "jpuf" )
      QUIT
   ENDIF
   FOR EACH oElement IN ze_TabUf()
      SEEK oElement[ 1 ]
      IF Eof()
         RecAppend()
      ENDIF
      RecLock()
      REPLACE ;
         jpuf->ufUF     WITH oElement[ 1 ], ;
         jpuf->ufDescri WITH oElement[ 2 ]
      RecUnlock()
   NEXT
   CLOSE DATABASES

   RETURN NIL

FUNCTION JPTABELDefault()

   LOCAL oElement

   SayScroll( "Atualizando tabelas padrão" )
   IF ! AbreArquivos( "jptabel" )
      QUIT
   ENDIF

   FOR EACH oElement IN ze_TabCfop()
      IF ! Encontra( AUX_CFOP + oElement[ 1 ], "jptabel", "numlan" )
         RecAppend()
      ENDIF
      RecLock()
      REPLACE ;
         jptabel->axTabela WITH AUX_CFOP, ;
         jptabel->axCodigo WITH oElement[ 1 ], ;
         jptabel->axDescri WITH oElement[ 2 ]
      RecUnlock()
   NEXT

   FOR EACH oElement IN ze_TabIcmCst()
      SEEK AUX_ICMCST + Pad( oElement[ 1 ], 6 )
      IF Eof()
         RecAppend()
      ENDIF
      RecLock()
      REPLACE ;
         jptabel->axTabela WITH AUX_ICMCST, ;
         jptabel->axCodigo WITH oElement[ 1 ], ;
         jptabel->axDescri WITH oELement[ 2 ]
      RecUnlock()
   NEXT

   FOR EACH oElement IN ze_TabIpiCst()
      SEEK AUX_IPICST + oElement[ 1 ]
      IF Eof()
         RecAppend()
      ENDIF
      RecLock()
      REPLACE ;
         jptabel->axTabela WITH AUX_IPICST, ;
         jptabel->axCodigo WITH StrZero( Val( oElement[ 1 ] ), 6 ), ;
         jptabel->axDescri  WITH oElement[ 2 ]
      RecUnlock()
   NEXT

   FOR EACH oElement IN ze_TabPisEnq()
      SEEK AUX_PISENQ + Pad( oElement[ 1 ], 6 )
      IF Eof()
         RecAppend()
      ENDIF
      RecLock()
      REPLACE ;
         jptabel->axTabela WITH AUX_PISENQ, ;
         jptabel->axCodigo WITH oElement[ 1 ], ;
         jptabel->axDescri WITH oElement[ 2 ]
      RecUnlock()
   NEXT

   IF .F. // Somente TRR
      FOR EACH oElement IN ze_TabCnae()
         SEEK AUX_CNAE + Pad( oElement[ 1 ], 6 )
         IF Eof()
            RecAppend()
         ENDIF
         RecLock()
         REPLACE ;
            jptabel->axTabela WITH AUX_CNAE, ;
            jptabel->axCodigo WITH oElement[ 1 ], ;
            jptabel->axDescri WITH oElement[ 2 ]
         RecUnlock()
      NEXT
   ENDIF

   FOR EACH oElement IN ze_TabModFis()
      SELECT jptabel
      SEEK Pad( oElement[ 1 ] )
      IF Eof()
         RecAppend()
      ENDIF
      RecLock()
      REPLACE ;
         jptabel->axTabela WITH AUX_MODFIS, ;
         jptabel->axCodigo WITH oElement[ 1 ], ;
         jptabel->axDescri WITH oElement[ 2 ]
      RecUnlock()
   NEXT

   FOR EACH oElement IN ze_TabPisCst()
      SEEK Pad( oElement[ 1 ], 6 )
      IF Eof()
         RecAppend()
      ENDIF
      RecLock()
      REPLACE ;
         jptabel->axTabela WITH AUX_PISCST, ;
         jptabel->axCodigo WITH oElement[ 1 ], ;
         jptabel->axDescri WITH oElement[ 2 ]
      RecUnlock()
   NEXT

   GravaCarCor()
   GravaCCusto()
   GravaCliGru()
   GravaCtaAdm()
   GravaFilial()
   GravaFinOpe()
   GravaFinPor()
   GravaIpiEnq()
   GravaOriMer()
   GravaProUni()
   GravaProDep()
   GravaProSec()
   GravaProGru()
   GravaTriCad()
   GravaTriPro()
   GravaTriUf()
   GravaQuaAss()

   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION GravaCarCor()

   LOCAL oElement, oRecList := { ;
      {  1, "RAZAO SOCIAL" }, ;
      {  2, "ENDERECO" }, ;
      {  3, "MUNICIPIO" }, ;
      {  4, "ESTADO" }, ;
      {  5, "NO. DE INSCRICAO NO CGC/MF" }, ;
      {  6, "NO. DE INSCRICAO ESTADUAL" }, ;
      {  7, "NATUREZA DA OPERACAO" }, ;
      {  8, "CODIGO FISCAL DA OPERACAO" }, ;
      {  9, "VIA DE TRANSPORTE" }, ;
      { 10, "DATA DE EMISSAO" }, ;
      { 11, "DATA DA SAIDA" }, ;
      { 12, "UNIDADE (PRODUTO)" }, ;
      { 13, "QUANTIDADE (PRODUTO)" }, ;
      { 14, "DESCRICAO DOS PRODUTOS" }, ;
      { 15, "PRECO UNITARIO" },  ;
      { 16, "VALOR DO PRODUTO" }, ;
      { 17, "CLASSIFICACAO FISCAL" }, ;
      { 18, "ALIQUOTA DE IPI" }, ;
      { 19, "ENDERECO DE ENTREGA" }, ;
      { 20, "BASE DE CALCULO DO IPI" }, ;
      { 21, "VALOR TOTAL DA NOTA" }, ;
      { 22, "ALIQUOTA DE ICMS" }, ;
      { 23, "VALOR DO ICMS" }, ;
      { 24, "BASE DE CALCULO DO ICMS" }, ;
      { 25, "NOME DO TRANSPORTADOR" }, ;
      { 26, "ENDERECO DO TRANSPORTADOR" }, ;
      { 27, "TERMO DE ISENCAO DO IPI" }, ;
      { 28, "TERMO DE ISENCAO DO ICMS" }, ;
      { 29, "PESO - BRUTO/LIQUIDO" }, ;
      { 30, "VOLUMES - MARCA/NUM/QUANT" }, ;
      { 31, "CODIGO DO PRODUTO" }, ;
      { 32, "VENCIMENTO" }, ;
      { 33, "DESCONTO" }, ;
      { 34, "PLACA DO VEICULO TRANSPORTADOR" }, ;
      { 35, "BASE DE CALCULO DO ICMS SUBST." }, ;
      { 36, "VALOR DO ICMS SUBST." }, ;
      { 37, "OUTROS" } }

   SayScroll( "Auxiliar - Codigos de Carta de Correcao" )

   FOR EACH oElement IN oRecList
      SEEK AUX_CARCOR + StrZero( oElement[ 1 ], 6 )
      IF Eof()
         RecAppend()
         REPLACE jptabel->axTabela WITH AUX_CARCOR, jptabel->axCodigo WITH StrZero( oElement[ 1 ], 6 )
      ENDIF
      RecLock()
      REPLACE jptabel->axDescri WITH oElement[ 2 ]
      RecUnlock()
   NEXT

   RETURN NIL

STATIC FUNCTION GravaCCusto()

   SayScroll( "Auxiliar - Centro de Custo" )
   IF File( "jpccusto.dbf" )
      SELECT 0
      USE jpccusto
      GOTO TOP
      DO WHILE ! Eof()
         SELECT jptabel
         SEEK AUX_CCUSTO + jpccusto->ccCCusto
         IF Eof()
            RecAppend()
            REPLACE jptabel->axTabela WITH AUX_CCUSTO, ;
                    jptabel->axCodigo WITH jpccusto->ccCCusto
         ENDIF
         RecLock()
         REPLACE jptabel->axDescri WITH jpccusto->ccDescri
         RecUnlock()
         SELECT jpccusto
         SKIP
      ENDDO
      USE
      fErase( "jpccusto.dbf" )
      SELECT jptabel
   ENDIF
   SEEK AUX_CCUSTO + StrZero( 1, 6 )
   IF Eof()
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_CCUSTO, ;
              jptabel->axCodigo WITH StrZero( 1, 6 ), ;
              jptabel->axDescri WITH "GERAL"
      RecUnlock()
   ENDIF

   RETURN NIL


STATIC FUNCTION GravaCliGru()

   SayScroll( "Auxiliar - Grupo de Cliente" )
   SEEK AUX_CLIGRU + StrZero( 1, 6 )
   IF Eof()
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_CLIGRU, ;
              jptabel->axCodigo WITH StrZero( 1, 6 ), ;
              jptabel->axDescri WITH "GERAL"
      RecUnlock()
   ENDIF

   RETURN NIL

STATIC FUNCTION GravaCtaAdm()

   SayScroll( "Auxiliar - Conta Administrativa" )
   SEEK AUX_CTAADM + StrZero( 1, 6 )
   IF Eof()
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_CTAADM, ;
              jptabel->axCodigo WITH StrZero( 1, 6 ), ;
              jptabel->axDescri WITH "GERAL"
      RecUnlock()
   ENDIF

   RETURN NIL

STATIC FUNCTION GravaFilial()

   SayScroll( "Auxiliar - Filial" )
   SEEK AUX_FILIAL + StrZero( 1, 6 )
   IF Eof()
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_FILIAL, ;
              jptabel->axCodigo WITH StrZero( 1, 6 ), ;
              jptabel->axDescri WITH "MATRIZ"
      RecUnlock()
   ENDIF

   RETURN NIL

STATIC FUNCTION GravaFinOpe()

   SayScroll( "Auxiliar - Financeiro Operacoes" )
   SEEK AUX_FINOPE + StrZero( 1, 6 )
   IF Eof()
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_FINOPE, ;
              jptabel->axCodigo WITH StrZero( 1, 6 ), ;
              jptabel->axDescri WITH "GERAL"
      RecUnlock()
   ENDIF

   RETURN NIL

STATIC FUNCTION GravaFinPor()

   SayScroll( "Auxiliar - Portador" )
   SEEK AUX_FINPOR + StrZero( 1, 6 )
   IF Eof()
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_FINPOR, ;
              jptabel->axCodigo WITH StrZero( 1, 6 ), ;
              jptabel->axDescri WITH "GERAL"
      RecUnlock()
   ENDIF

   RETURN NIL

STATIC FUNCTION GravaIpiEnq()

   SayScroll( "Auxiliar - Enquadramento de IPI" )
   SEEK AUX_IPIENQ + Pad( "999", 6 )
   IF Eof()
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_IPIENQ, jptabel->axCodigo WITH Pad( "999", 6 )
   ENDIF
   RecLock()
   REPLACE jptabel->axDescri WITH "OUTROS"
   RecUnlock()

   RETURN NIL

STATIC FUNCTION GravaOriMer()

   LOCAL oElement, oRecList := { ;
      { "0", "NACIONAL, EXCETO CODIGOS 3 A 5" }, ;
      { "1", "ESTRANGEIRA IMP DIRETA, EXCETO 6" }, ;
      { "2", "ESTRANGEIRA ADQ MERC INT, EXCETO 7" }, ;
      { "3", "MERCADORIA CONTEUDO IMP SUPERIOR 40 POR CENTO" }, ;
      { "4", "NACIONAL DECRETO 288-67 LEIS 8.248-91, 8.387-91, 10.176-01 e 11.484-07" }, ;
      { "5", "MERCADORIA CONTEUDO IMP INFERIOR 40 POR CENTO" }, ;
      { "6", "IMPORTACAO DIRETA, SEM SIMILAR NAC, RESOLUCAO CAMEX" }, ;
      { "7", "IMPORTADA, SEM SIMILAR NACIONAL, RESOLUCAO CAMEX" } }

   FOR EACH oElement IN oRecList
      SEEK AUX_ORIMER + Pad( oElement[ 1 ], 6 )
      IF Eof()
         RecAppend()
         REPLACE jptabel->axTabela WITH AUX_ORIMER, jptabel->axCodigo WITH Pad( oElement[ 1 ], 6 )
      ENDIF
      RecLock()
      REPLACE jptabel->axDescri WITH oElement[ 2 ]
      RecUnlock()
   NEXT

   RETURN NIL

STATIC FUNCTION GravaProDep()

   SayScroll( "Auxiliar - Produto Departamento" )
   SEEK AUX_PRODEP + StrZero( 1, 6 )
   IF Eof()
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_PRODEP, ;
              jptabel->axCodigo WITH StrZero( 1, 6 ), ;
              jptabel->axDescri WITH "GERAL"
      RecUnlock()
   ENDIF

   RETURN NIL

STATIC FUNCTION GravaProSec()

   SayScroll( "Auxiliar - Produto Secao" )
   SEEK AUX_PROSEC + StrZero( 1, 6 )
   IF Eof()
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_PROSEC, ;
              jptabel->axCodigo WITH StrZero( 1, 6 ), ;
              jptabel->axDescri WITH "GERAL"
      RecUnlock()
   ENDIF

   RETURN NIL

STATIC FUNCTION GravaProGru()

   SayScroll( "Auxiliar - Produto Grupo" )
   SEEK AUX_PROGRU + StrZero( 1, 6 )
   IF Eof()
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_PROGRU, ;
              jptabel->axCodigo WITH StrZero( 1, 6 ), ;
              jptabel->axDescri WITH "GERAL"
      RecUnlock()
   ENDIF

   RETURN NIL

STATIC FUNCTION GravaProUni()

   LOCAL oElement, acDefault

   SayScroll( "Auxiliar - Produto Unidade" )
   acDefault := { { "M", "METRO" }, { "KG", "QUILOGRAMA" }, { "L", "LITRO" }, { "UN", "UNIDADE" } }
   FOR EACH oElement IN acDefault
      SEEK AUX_PROUNI + Pad( oElement[ 1 ], 6 )
      IF Eof()
         RecAppend()
         REPLACE ;
            jptabel->axTabela WITH AUX_PROUNI, ;
            jptabel->axCodigo WITH oElement[ 1 ]
      ENDIF
      RecLock()
      REPLACE jptabel->axDescri WITH oElement[ 2 ]
      RecUnlock()
   NEXT

   RETURN NIL

STATIC FUNCTION GravaTriCad()

   SayScroll( "Auxiliar - Tributacao de Cadastro" )
   SEEK AUX_TRICAD + StrZero( 1, 6 )
   IF Eof()
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_TRICAD, ;
              jptabel->axCodigo WITH StrZero( 1, 6 ), ;
              jptabel->axDescri WITH "*** NAO DEFINIDA ***"
      RecUnlock()
   ENDIF

   RETURN NIL

STATIC FUNCTION GravaTriPro()

   SayScroll( "Auxiliar - Tributacao de Produto" )
   SEEK AUX_TRIPRO + StrZero( 1, 6 )
   IF Eof()
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_TRIPRO, ;
              jptabel->axCodigo WITH StrZero( 1, 6 ), ;
              jptabel->axDescri WITH "*** NAO DEFINIDA ***"
      RecUnlock()
   ENDIF

   RETURN NIL

STATIC FUNCTION GravaTriUF()

   SayScroll( "Auxiliar - Tributacao de UF" )
   SEEK AUX_TRIUF + StrZero( 1, 6 )
   IF Eof()
      RecAppend()
      REPLACE jptabel->axTabela WITH AUX_TRIUF, ;
              jptabel->axCodigo WITH StrZero( 1, 6 ), ;
              jptabel->axDescri WITH "*** NAO DEFINIDA ***"
      RecUnlock()
   ENDIF

   RETURN NIL

STATIC FUNCTION GravaQuaAss()

   LOCAL oElement, oRecList := { ;
      { 203, "DIRETOR" }, ;
      { 204, "CONSELHEIRO DE ADMINISTRACAO" }, ;
      { 205, "ADMINISTRADOR" }, ;
      { 206, "ADMINISTRADOR DE GRUPO" }, ;
      { 207, "ADMINISTRADOR DE SOCIEDADE FILIADA" }, ;
      { 220, "ADMINISTRADOR JUDICIAL - PESSOA FISICA" }, ;
      { 222, "ADMINISTRADOR JUDICIAL - PESSOA JURIDICA - PROFISSIONAL RESPONSAVEL" }, ;
      { 223, "ADMINISTRADOR JUDIDIAL/GESTOR" }, ;
      { 226, "GESTOR JUDICIAL" }, ;
      { 309, "PROCURADOR" }, ;
      { 312, "INVENTARIANTE" }, ;
      { 313, "LIQUIDANTE" }, ;
      { 315, "INTERVENTOR" }, ;
      { 801, "EMPRESARIO" }, ;
      { 900, "CONTADOR" }, ;
      { 999, "OUTROS" } }

   FOR EACH oElement IN oRecList
      SEEK AUX_QUAASS + Pad( StrZero( oElement[ 1 ], 3 ), 6 )
      IF Eof()
         RecAppend()
         REPLACE jptabel->axTabela WITH AUX_QUAASS, jptabel->axCodigo WITH Pad( StrZero( oElement[ 1 ], 3 ), 6 )
      ENDIF
      RecLock()
      REPLACE jptabel->axDescri WITH oElement[ 2 ]
      RecUnlock()
   NEXT

   RETURN NIL

FUNCTION JPSENHADefault()

   LOCAL oElement

   SayScroll( "Ajustando acessos default" )
   IF ! AbreArquivos( "jpsenha" )
      QUIT
   ENDIF
   SEEK "S"
   IF Eof()
      pw_GravaUsuarioSenha( "CT", "" )
      pw_GravaUsuarioSenha( "TESTE", "" )
      pw_GravaGrupo( "GRUPOCONTABIL" )
      pw_GravaGrupo( "GRUPOTESTE" )
      pw_GravaUsuarioGrupo( "CT", "GRUPOCONTABIL" )
      pw_GravaUsuarioGrupo( "TESTE", "GRUPOCONTABIL" )
      pw_GravaUsuarioGrupo( "TESTE", "GRUPOFINANCEIRO" )
      pw_GravaUsuarioGrupo( "TESTE", "GRUPONOTA" )
      pw_GravaUsuarioGrupo( "TESTE", "GRUPOESTOQUE" )
      pw_GravaUsuarioGrupo( "TESTE", "GRUPOBANCARIO" )
      FOR EACH oElement IN { "PCONTCTAADM", "PLEISQUAASS", "PCONTREDDISP", "PCONTIMPPLANO", "PEDI0290", ;
         "PJPDOLAR", "PCONTSPED", "PCONTFCONT", "PLEISREFCTA", "PCONTLANCINCLUI", "PCONTLANCLOTE", ;
         "PCONTLANCALTERA", "PCONTTOTAIS", "PCONTSALDO", "PCONTFECHA", "PCONTSINTETICA", "PCONTRECALCULO", ;
         "PCONTREDRENUM", "PCONTSETUP", "PCONTNUMDIA", "PCONTEMITIDOS", "PCONTREL0360", "PCONTREL0270", ;
         "PCONTREL0520", "PCONTREL0210", "PCONTREL0010", "PCONTREL0380", "PCONTREL0310", "PCONTREL0320", ;
         "PCONTREL0390", "PCONTREL0250", "PCONTREL0550", "PCONTREL0300", "PCONTREL0330", "PCONTREL0530", ;
         "PCONTREL0385", "PCONTREL0470", "PCONTREL0370", "PCONTREL0230", "PCONTREL0340", "PCONTHISTORICO", ;
         "PCONTLANCPAD", "PCONTCTPLANO", "PFISCREL0020" }
         pw_GravaUsuarioAcesso( "GRUPOCONTABIL", oElement )
      NEXT
      FOR EACH oElement IN { "PLEISIMPOSTO", "PLEISDECRETO", "PLEISTRIPRO", "PLEISTRICAD", "PFISCSAIDAS", "PFISCENTRADAS", ;
         "PLEISUF", "PLEISTRIEMP", "PLEISTRIUF", "PLEISRELCIDADE", "PLEISCFOP", "PLEISICMCST", "PLEISMODFIS", "PLEISIPIENQ", ;
         "PLEISPISENQ", "PLEISPROUNI", "PLEISORIMER", "PJPIBPT", "PJPTRANSA", "PLEISIPICST", "PLEISPISCST", "PLEISCIDADE", ;
         "PLEISUF" }
         pw_GravaUsuarioAcesso( "GRUPOCONTABIL", oElement )
      NEXT
      FOR EACH oElement IN { "LJPTABEL", "PAUXCCUSTO", "PAUXFILIAL", "PSETUPEMPRESA", "PJPEMPRE", ;
         "PSETUPNUMERO", "PJPTABEL", "PUTI0010", "PUTI0020", "PUTI0022", "PADMINLOG", "PUPDATEEXEDOWN" }
         pw_GravaUsuarioAcesso( "GRUPOCONTABIL", oElement )
      NEXT
      FOR EACH oElement IN { "PFIN0030", "PFIN0035", "PFIN0010", "PFIN0040", "PFIN0120", "PFIN0130", "PFIN0140", ;
         "PFIN0150", "LJPCADAS", "LJPFORPAG","JPCADAS1", "PJPVENDED", "PAUXFORPAG", "PAUXFINOPE", "PAUXFINPOR", ;
         "PAUXMOTIVO", "PAUXMIDIA", "PAUXMEIAUT", "PAUXCLISTA" }
          pw_GravaUsuarioAcesso( "GRUPOFINANCEIRO", oElement )
      NEXT
      FOR EACH oElement IN { "PNOT0020", "PNOT0040", "PNOT0060", "PNOT0213", "PNOT0214", "PNFEINUT", "PNOT0070", ;
         "P0600PED", "LJPPEDI", "PNOT0090", "PNOT0120", "LJPCADAS", "LJPFORPAG", "LJPITEM", "LJPCADAS3", "JPCADAS1", ;
         "PJPITEM", "PJPCADAS3", "PJPVENDED", "PJPVEICUL", "PJPMOTORI", "PAUXBANCO", "PNFE0010", "PNFE0050", "LLPRECO" }
          pw_GravaUsuarioAcesso( "GRUPONOTA", oElement )
      NEXT
      FOR EACH oElement IN { "LJPESTOQA", "LJPESTOQB", "LJPESTOQC", "PJPFISICAB", "LJPITEM", "PJPITEM", ;
         "PLEISPROUNI", "PLEISORIMER", "PESTODEPTO", "PESTOGRUPO", "PESTOSECAO", "PESTOLOCAL", "PESTLANCA1", ;
         "PESTLANCA2", "LJPESTOQA", "PBAR0010", "PBAR0040" }
          pw_GravaUsuarioAcesso( "GRUPOESTOQUE", oElement )
      NEXT
      FOR EACH oElement IN { "PBAN0010", "PBAN0020", "PBAN0030", "PBAN0040", "PBAN0060", "PBAN0070", ;
         "PBAN0080", "PBAN0090", "PBAN0100", "PBAN0110", "PBAN0120", "PBAN0130" }
         pw_GravaUsuarioAcesso( "GRUPOBANCARIO", oElement )
      NEXT
   ENDIF
   CLOSE DATABASES

   RETURN NIL
