/*
ZE_UPDATE2017 - Conversões 2017
2017 José Quintas
*/

#include "directry.ch"

FUNCTION ze_Update2017()

   IF AppVersaoDbfAnt() < 20170404; Update20170404();   ENDIF // Status de manifesto
   IF AppVersaoDbfAnt() < 20170601; Update20170601();   ENDIF // Estoque anterior
   IF AppVersaoDbfAnt() < 20170608; Update20170608();   ENDIF // Caracteres nos XMLs
   IF AppVersaoDbfAnt() < 20170614; Update20170614();   ENDIF // Corrige estoque
   IF AppVersaoDbfAnt() < 20170811; Update20170811();   ENDIF // Novo jpsenha
   IF AppVersaoDbfAnt() < 20170812; Update20170812();   ENDIF // Renomeando
   IF AppVersaoDbfAnt() < 20170816; Update20170816();   ENDIF // lixo jpconfi
   IF AppVersaoDbfAnt() < 20171231; Update20171231();   ENDIF // crispetrol
   IF AppVersaoDbfAnt() < 20170816; RemoveLixo();       ENDIF
   IF AppVersaoDbfAnt() < 20170922; Update20170922();   ENDIF
   IF AppVersaoDbfAnt() < 20170820; pw_DeleteInvalid(); ENDIF // Último, pra remover desativados

   RETURN NIL

   /*
   Status de manifesto
   */

STATIC FUNCTION Update20170404()

   LOCAL oXmlPdf, cStatus, oElement

   IF AppcnMySqlLocal() == NIL
      RETURN NIL
   ENDIF

   IF ! AbreArquivos( "jpempre", "jpmdfcab" )
      RETURN NIL
   ENDIF
   SELECT jpmdfcab
   SET ORDER TO 0
   GrafTempo( "Ajustando status de manifestos" )
   GOTO TOP
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      Inkey()
      oXmlPdf := XmlPdfClass():New()
      oXmlPdf:GetFromMySql( "", jpmdfcab->mcNumLan, "58" )
      cStatus := ""
      IF ! Empty( oXmlPdf:cXmlCancelamento )
         cStatus := "C"
      ELSE
         IF ! Empty( oXmlPdf:cXmlEmissao )
            cStatus := "E"
            FOR EACH oElement IN oXmlPdf:aXmlEvento
               IF "<tpEvento>110112</tpEvento>" $ oElement
                  cStatus := "F"
               ENDIF
            NEXT
         ENDIF
      ENDIF
      DO CASE
      CASE Empty( cStatus )
         // Não desfaz cancelamento
      CASE Trim( jpmdfcab->mcStatus ) == "C"
         // Não desfaz encerramento, mas permite cancelar
      CASE Trim( jpmdfcab->mcStatus ) == "F" .AND. cStatus != "C"
      OTHERWISE
         RecLock()
         REPLACE jpmdfcab->mcStatus WITH cStatus
         RecUnlock()
      ENDCASE
      SKIP
   ENDDO
   CLOSE DATABASES
   Mensagem()

   RETURN NIL
   /*
   Estoque anterior
   */

STATIC FUNCTION Update20170601()

   LOCAL nIdEstoque := 0

   IF ! AbreArquivos( "jpitem", "jpestoq" )
      RETURN NIL
   ENDIF
   SELECT jpestoq
   OrdSetFocus( "numlan" )
   SELECT jpitem
   IF FieldNum( "IEQTDANT" ) == 0
      CLOSE DATABASES
      RETURN NIL
   ENDIF
   SET ORDER TO 0
   GOTO TOP
   GrafTempo( "Salvando saldo anterior como movimento de estoque" )
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      Inkey()
      DO CASE
      CASE jpitem->ieQtdAnt == 0
         SKIP
         LOOP
      CASE Empty( jpitem->ieItem )
         SKIP
         LOOP
      ENDCASE
      SELECT jpestoq
      OrdSetFocus( "numlan" )
      nIdEstoque+= 1
      DO WHILE Encontra( StrZero( nIdEstoque, 6 ) )
         Inkey()
         nIdEstoque += 1
      ENDDO
      RecAppend()
      REPLACE ;
         jpestoq->esNumLan WITH StrZero( nIdEstoque, 6 ), ;
         jpestoq->esDatLan WITH Stod( "19830724" ), ;
         jpestoq->esTipLan WITH iif( jpitem->ieQtdAnt < 0, "1", "2" ), ;
         jpestoq->esCliFor WITH StrZero( 0, 6 ), ;
         jpestoq->esTipDoc WITH "INICIO", ;
         jpestoq->esNumDoc WITH "INICIO", ;
         jpestoq->esItem   WITH jpitem->ieItem, ;
         jpestoq->esQtde   WITH Abs( jpitem->ieQtdAnt ), ;
         jpestoq->esValor  WITH 0, ;
         jpestoq->esNumDep WITH "1", ;
         jpestoq->esCfOp   WITH iif( jpitem->ieQtdAnt < 0, "5.949", "1.949" ), ;
         jpestoq->esObs    WITH "SALDO ANTERIOR DO JPA", ;
         jpestoq->esinfInc WITH LogInfo()
      RecUnlock()
      SELECT jpitem
      RecLock()
      REPLACE jpitem->ieQtdAnt WITH 0
      RecUnlock()
      SayScroll( "Gravado lançamento " + jpestoq->esNumLan + " ref. produto " + jpitem->ieItem )
      SKIP
   ENDDO
   CLOSE DATABASES

   RETURN NIL
   /*
   Corrigir 10 XMLs no meio de 600.000
   */

#define SQL_CR         ['\] + Chr(13) + [']
#define SQL_LF         ['\] + Chr(10) + [']
#define SQL_CEDILHA    ['\] + Chr(195) + [\] + Chr(167) + [']
#define SQL_AO         ['\] + Chr(195) + [\] + Chr(163) + [']
#define SQL_COMERCIAL  ['&amp.']

STATIC FUNCTION Update20170608()

   LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() )
   LOCAL cSQL, nAno

   IF AppcnMySqlLocal() == NIL
      RETURN NIL
   ENDIF
   FOR nAno = 2008 TO 2017
      SayScroll( Time() + " Ajustando XML " + StrZero( nAno, 4 ) )
      cSQL := [REPLACE( XXXML, ]        + SQL_CR        + [, ''  )]
      cSQL := [REPLACE( ] + cSQL + [, ] + SQL_LF        + [, ''  )]
      cSQL := [REPLACE( ] + cSQL + [, ] + SQL_CEDILHA   + [, 'c' )]
      cSQL := [REPLACE( ] + cSQL + [, ] + SQL_AO        + [, 'a' )]
      cSQL := [REPLACE( ] + cSQL + [, ] + SQL_COMERCIAL + [, '&' )]
      cSQL := [UPDATE JPXML] + StrZero( nAno, 4 ) + [ SET XXXML=] + cSQL
      cSQL += [ WHERE ]
      cSQL += [ INSTR( XXXML, ] + SQL_CR        + [) <> 0 OR ]
      cSQL += [ INSTR( XXXML, ] + SQL_LF        + [) <> 0 OR ]
      cSQL += [ INSTR( XXXML, ] + SQL_CEDILHA   + [) <> 0 OR ]
      cSQL += [ INSTR( XXXML, ] + SQL_AO        + [) <> 0 OR ]
      cSQL += [ INSTR( XXXML, ] + SQL_COMERCIAL + [) <> 0]
      cnMySql:ExecuteCmd( cSQL )
      Inkey()
   NEXT

   RETURN NIL
   /*
   Corrige estoque
   */

STATIC FUNCTION Update20170614()

   IF ! AbreArquivos( "jpestoq" )
      RETURN NIL
   ENDIF
   SELECT jpestoq
   SET ORDER TO 0
   GOTO TOP
   GrafTempo( "Verificando lançamentos de estoque antigos" )
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      Inkey()
      IF ! jpestoq->esTipLan $ "12"
         RecLock()
         REPLACE jpestoq->esTipLan WITH "1"
         RecUnlock()
      ENDIF
      IF Val( jpestoq->esNumDep ) == 0
         RecLock()
         REPLACE jpestoq->esNumDep WITH "1"
         RecUnlock()
      ENDIF
      DO CASE
      CASE jpestoq->esQtde == 0
         RecLock()
         DELETE
         RecUnlock()
      CASE Empty( jpestoq->esItem )
         RecLock()
         DELETE
         RecUnlock()
      CASE Empty( jpestoq->esDatLan )
         RecLock()
         DELETE
         RecUnlock()
      ENDCASE
      SKIP
   ENDDO
   CLOSE DATABASES

   RETURN NIL
   /*
   Novo senhas
   */

STATIC FUNCTION Update20170811()

   IF ! AbreArquivos( "jpsenha" )
      RETURN NIL
   ENDIF
   IF FieldNum( "senha" ) == 0
      RETURN NIL
   ENDIF
   SELECT jpsenha
   SET ORDER TO 0
   GOTO TOP
   GrafTempo( "Convertendo senhas" )
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      Inkey()
      ConverteSenhas()
      SKIP
   ENDDO
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION ConverteSenhas()

   IF Empty( jpsenha->pwType ) .AND. FieldNum( "SENHA" ) != 0
      RecLock()
      REPLACE ;
         jpsenha->pwType   WITH Substr( jpsenha->Senha, 1, 1 ), ;
         jpsenha->pwFirst  WITH pw_Criptografa( pw_Descriptografa( Substr( jpsenha->Senha, 2, 30 ) ) ), ;
         jpsenha->pwLast   WITH pw_Criptografa( pw_Descriptografa( Substr( jpsenha->Senha, 32, 30 ) ) )
      RecUnlock()
   ENDIF

   RETURN NIL

   /*
   Renomeando fontes
   */

STATIC FUNCTION Update20170812()

   SayScroll( "Renomeando fontes" )
   IF ! AbreArquivos( "JPSENHA" )
      QUIT
   ENDIF
   pw_AddModule( "PTOOLDBASE",       "RDBASE" )
   pw_AddModule( "PGAMEFORCA",       "GAMEFORCA" )
   pw_AddModule( "PGAMETESTEQI",     "PGAMETESTEQI" )
   pw_AddModule( "PESTOLANCA1",      "PJPESTOQ1" )
   pw_AddModule( "PESTOLANCA2",      "PJPESTOQ2" )
   pw_AddModule( "PESTOVALEST",      "PEST0050" )
   pw_AddModule( "PESTOENTFOR",      "PEST0060" )
   pw_AddModule( "PSETUPPARAMALL",   "PJPCONFIA" )
   pw_AddModule( "PSETUPPARAMROUND", "PJPCONFIB" )
   pw_AddModule( "PSETUPNUMERO",     "PJPNUMERO" )
   pw_AddModule( "PSETUPEMPRESA",    "PCFG0030" )
   pw_AddModule( "PNOTETIQUETA",     "PNOT0230" )
   pw_AddModule( "PNOTAETIQUETA",    "PNOTETIQUETA" )
   pw_AddModule( "PFORMRECIBO",      "RRECIBO" )
   pw_AddModule( "PGERALRECIBO",     "PFORMRECIBO" )
   pw_AddModule( "PADMLOG",          "PUTI0040" )
   pw_AddModule( "PUTILDBASE",       "PTOOLDBASE" )
   pw_AddModule( "PCONTCODRED",      "PCTL0010" )
   pw_AddModule( "PCONTREL0010",     "PCTL0020" )
   pw_AddModule( "PCONTNUMDIA",      "PCTL0060" )
   pw_AddModule( "PCONTSETUP",       "PCTL0070" )
   pw_AddModule( "PCONTEMITIDOS",    "PCTL0090" )
   pw_AddModule( "PCONTSINTETICA",   "PCTL0110" )
   pw_AddModule( "PCONTRECALCULO",   "PCTL0120" )
   pw_AddModule( "PCONTREDRENUM",    "PCTL0130" )
   pw_AddModule( "PCONTREDDISP",     "PCONTCODRED" )
   pw_AddModule( "PCONTCTPLANO",     "PCTL0150" )
   pw_AddModule( "PCONTCTLANCA",     "PCTLANCA" )
   pw_AddModule( "PCONTSALDO",       "PCTL0180" )
   pw_AddModule( "PCONTFECHA",       "PCTL0190" )
   pw_AddModule( "PCONTTOTAIS",      "PCTL0260" )
   pw_AddModule( "PCONTLANCINCLUI",  "PCTL0200" )
   pw_AddModule( "PCONTLANCLOTE",    "PCTL0220" )
   pw_AddModule( "PCONTLANCAEDIT",  "PCTL0240" )
   pw_AddModule( "PCONTREL0360",     "PCTL0360" )
   pw_AddModule( "PCONTREL0270",     "PCTL0270" )
   pw_AddModule( "PCONTREL0520",     "PCTL0520" )
   pw_AddModule( "PCONTREL0210",     "PCTL0210" )
   pw_AddModule( "PCONTREL0380",     "PCTL0380" )
   pw_AddModule( "PCONTREL0310",     "PCTL0310" )
   pw_AddModule( "PCONTREL0320",     "PCTL0320" )
   pw_AddModule( "PCONTREL0390",     "PCTL0390" )
   pw_AddModule( "PCONTREL0250",     "PCTL0250" )
   pw_AddModule( "PCONTREL0550",     "PCTL0550" )
   pw_AddModule( "PCONTREL0300",     "PCTL0300" )
   pw_AddModule( "PCONTREL0530",     "PCTL0530" )
   pw_AddModule( "PCONTREL0330",     "PCTL0330" )
   pw_AddModule( "PCONTREL0385",     "PCTL0385" )
   pw_AddModule( "PCONTREL0470",     "PCTL0470" )
   pw_AddModule( "PCONTREL0370",     "PCTL0370" )
   pw_AddModule( "PCONTREL0230",     "PCTL0230" )
   pw_AddModule( "PCONTREL0340",     "PCTL0340" )
   pw_AddModule( "PFISCIMPOSTO",     "PJPIMPOS" )
   pw_AddModule( "PFISCDECRETO",     "PJPDECRET" )
   pw_AddModule( "PFISCCORRECAO",    "PFIS0010" )
   pw_AddModule( "PFISCREL0010",     "PFIS0100" )
   pw_AddModule( "PFISCREL0020",     "PFIS0170" )
   pw_AddModule( "PFISCENTRADAS",    "PJPLFISC2" )
   pw_AddModule( "PFISCSAIDAS",      "PJPLFISC1" )
   pw_AddModule( "PFISCTOTAIS",      "PJPLFISCD" )
   pw_AddModule( "PFISCREL0020",     "PCONTREL0210" )
   pw_AddModule( "PFISCREL0030",     "LJPLFISCA" )
   pw_AddModule( "PFISCREL0040",     "LJPLFISCC" )
   pw_AddModule( "PFISCREL0050",     "LJPLFISCG" )
   pw_AddModule( "PFISCREL0060",     "LJPLFISCE" )
   pw_AddModule( "PFISCREL0070",     "LJPLFISCF" )
   pw_AddModule( "PFISCREL0080",     "LJPLFISCJ" )
   pw_AddModule( "PFISCREL0090",     "LJPLFISCK" )
   pw_AddModule( "PFISCREL0100",     "LJPLFISCD" )
   pw_AddModule( "PFISCREL0110",     "LJPLFISCI" )
   pw_AddModule( "PFISCREL0120",     "LJPLFISCH" )
   pw_AddModule( "PFISCREL0130",     "PGOV0070" )
   pw_AddModule( "PFISCREL0140",     "PGOV0060" )
   pw_AddModule( "PLEISIMPOSTO",     "PFISCIMPOSTO" )
   pw_AddModule( "PLEISDECRETO",     "PFISCDECRETO" )
   pw_AddModule( "PCONTREFCTA",      "PJPREFCTA" )
   pw_AddModule( "PLEISIBPT",        "PJPIBPT" )
   pw_AddModule( "PLEISREFCTA",      "PCONTREFCTA" )
   pw_AddModule( "PFISCSINTEGRA",    "PGOV0040" )
   pw_AddModule( "PFISCSPED",        "PGOV0030" )
   pw_AddModule( "PCONTSPED",        "PGOV0010" )
   pw_AddModule( "PCONTFCONT",       "PGOV0020" )
   pw_AddModule( "PCONTCONTAS",      "PCONTCTPLANO" )
   pw_AddModule( "PCONTHISTORICO",   "PCTHISTO" )
   pw_AddModule( "PCONTLANCPAD",     "PCONTCTLANCA" )
   pw_AddModule( "PCONTIMPLANO",     "PEDI0080" )
   pw_AddModule( "PCONTEXPLOTE1",    "PEDI0090" )
   pw_AddModule( "PCONTIMPLOTE1",    "PEDI0100" )
   pw_AddModule( "PCONTAUXCTAADM",   "PAUXCTAADM" )
   pw_AddModule( "PCONTIMPEXCEL",    "PXLSKITFRA" )
   pw_AddModule( "PLEISUF",          "PJPUF" )
   pw_AddModule( "PLEISAUXQUAASS",   "PAUXQUAASS" )
   pw_AddModule( "PLEISAUXCFOP",     "PAUXCFOP" )
   pw_AddModule( "PLEISAUXCNAE",     "PAUXCNAE" )
   pw_AddModule( "PLEISAUXICMCST",   "PAUXICMCST" )
   pw_AddModule( "PCONTAUXCTAADM",   "PCONTCTAADM" )
   pw_AddModule( "PLEISCFOP",        "PLEISAUXCFOP" )
   pw_AddModule( "PLEISCNAE",        "PLEISAUXCNAE" )
   pw_AddModule( "PLEISICMCST",      "PLEISAUXICMCST" )
   pw_AddModule( "PLEISQUAASS",      "PLEISAUXQUAASS" )
   pw_AddModule( "PLEISIPICST",      "PAUXIPICST" )
   pw_AddModule( "PLEISIPIENQ",      "PAUXIPIENQ" )
   pw_AddModule( "PLEISMODFIS",      "PAUXMODFIS" )
   pw_AddModule( "PLEISORIMER",      "PAUXORIMER" )
   pw_AddModule( "PLEISPISCST",      "PAUXPISCST" )
   pw_AddModule( "PLEISPISENQ",      "PAUXPISENQ" )
   pw_AddModule( "PLEISPROUNI",      "PAUXPROUNI" )
   pw_AddModule( "PLEISTRICAD",      "PAUXTRICAD" )
   pw_AddModule( "PLEISTRIEMP",      "PAUXTRIEMP" )
   pw_AddModule( "PLEISTRIPRO",      "PAUXTRIPRO" )
   pw_AddModule( "PLEISTRIUF",       "PAUXTRIUF" )
   pw_AddModule( "PLEISRELIMPOSTO",  "LJPIMPOS" )
   pw_AddModule( "PLEISCORRECAO",    "PAUXCARCOR" )
   pw_AddModule( "PCONTCTAADM",      "PCONTAUXCTAADM" )
   pw_AddModule( "PUPDATEEXEUP",     "PVERUPL" )
   pw_AddModule( "PUPDATEEXEDOWN",   "PUTI0070" )
   pw_AddModule( "PESTODEPTO",       "PAUXPRODEP" )
   pw_AddModule( "PESTOGRUPO",       "PAUXPROGRU" )
   pw_AddModule( "PESTOLOCAL",       "PAUXPROLOC" )
   pw_AddModule( "PESTOSECAO",       "PAUXPROSEC" )
   pw_AddModule( "PADMINLOG",        "PADMLOG" )
   pw_AddModule( "PADMINACESSO",     "PCFG0050" )
   pw_AddModule( "PESTOITEMXLS",     "PXLS0010" )
   pw_AddModule( "PLEISCIDADE",      "PJPCIDADE" )
   pw_AddModule( "PLEISRELCIDADE",   "LJPCIDADE" )
   pw_AddModule( "PNOTAXLS",         "PNOT0110" )
   pw_AddModule( "PPRECANCEL",     "PTES0050" )
   pw_AddModule( "JPA_INDEX",        "PUTI0010" )
   pw_AddModule( "PDFECTECANCEL",    "PCTE0020" )
   pw_AddModule( "PBANCOGERA",       "PBAN0010" )
   pw_AddModule( "PBANCOLANCA",      "PBAN0020" )
   pw_AddModule( "PBANCOSALDO",      "PBAN0030" )
   pw_AddModule( "PBANCOCCUSTO",     "PBAN0040" )
   pw_AddModule( "PBANCOGRAFICOMES", "PBAN0060" )
   pw_AddModule( "PBANCOCONSOLIDA",  "PBAN0070" )
   pw_AddModule( "PBANCOGRAFRESUMO", "PBAN0080" )
   pw_AddModule( "PBANCORELEXTRATO", "PBAN0090" )
   pw_AddModule( "PBANCOCOMPARAMES", "PBAN0100" )
   pw_AddModule( "PBANCORELSALDO",   "PBAN0110" )
   pw_AddModule( "PBANCORELCCUSTO",  "PBAN0120" )
   pw_AddModule( "PUTILBACKUP",      "PUTI0020" )
   pw_AddModule( "PUTILBACKUPENVIA", "PUTI0022" )
   pw_AddModule( "PESTOENTFOR",      "PESTENTFOR" )
   pw_AddModule( "PESTOLANCA1",      "PESTLANCA1" )
   pw_AddModule( "PESTOLANCA2",      "PESTLANCA2" )
   pw_AddModule( "PESTOVALEST",      "PESTVALEST" )
   pw_AddModule( "PNOTARECALCULO",   "PTES0100" )
   pw_AddModule( "PNOTAVENDAS",      "PTES0120" )
   pw_AddModule( "PNOTACADASTRO",    "PNOT0020" )
   pw_AddModule( "PNOTAPEDRETIRA",   "PNOT0030" )
   pw_AddModule( "PNOTAROMANEIO",    "PNOT0050" )
   pw_AddModule( "PNOTAGERANFE",     "PNOT0060" )
   pw_AddModule( "PNOTARELRENTAB",   "PNOT0080" )
   pw_AddModule( "PNOTARELNOTAS",    "PNOT0090" )
   pw_AddModule( "PNOTACHECAGEM",    "PNOT0200" )
   pw_AddModule( "PNOTAPROXIMAS",    "PNOT0270" )
   pw_AddModule( "PESTOTOTARMAZEM",  "PNOT0260" )
   pw_AddModule( "PNOTAFICCLIVEN",   "PNOT0250" )
   pw_AddModule( "PPREHTMLTABPRE",   "PNOT0240" )
   pw_AddModule( "PPRERELTABMULTI",  "PNOT0220" )
   pw_AddModule( "PPRERELTABGERAL",  "LLPRECO" )
   pw_AddModule( "PPRERELTABCOMB",   "PPRE0030" )
   pw_AddModule( "PPREVALPERC",      "PNOT0210" )
   pw_AddModule( "PNOTARELCOMPCLI",  "PNOT0160" )
   pw_AddModule( "PNOTARELVENDCLI",  "PNOT0190" )
   pw_AddModule( "PNOTARELPEDREL",   "PNOT0130" )
   pw_AddModule( "PNOTARELCLIVEND",  "PNOT0120" )
   pw_AddModule( "PNOTAVERVENDAS",   "PNOT0070" )
   pw_AddModule( "PESTORELANALISE",  "PEST0120" )
   pw_AddModule( "PFINANBAIXAPORT",  "PFIN0010" )
   pw_AddModule( "PFINANRELFLUXO",   "PFIN0020" )
   pw_AddModule( "PFINANEDRECEBER",  "PFIN0030" )
   pw_AddModule( "PFINANEDPAGAR",    "PFIN0040" )
   pw_AddModule( "PFINANRELRECEBER", "PFIN0120" )
   pw_AddModule( "PFINANRELPAGAR",   "PFIN0140" )
   pw_AddModule( "PFINANRELMAICLI",  "PFIN0130" )
   pw_AddModule( "PFINANRELMAIFOR",  "PFIN0150" )
   pw_AddModule( "PDFESALVA",        "PNFE0010" )
   pw_AddModule( "PNOTAPLANILHAG",   "PNOT0100" )
   pw_AddModule( "PNOTAPLANILHACV",  "PNOT0101" )
   pw_AddModule( "PNOTAPLANILHAC",   "PNOT0102" )
   pw_AddModule( "PNOTARELCOMPMES",  "PNOT0150" )
   pw_AddModule( "PNOTARELMAPA",     "PNOT0145" )
   pw_AddModule( "PNOTACONSPROD",    "PNOT0170" )
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION Update20170816()

   SayScroll( "Eliminando coisa inútil" )
   IF ! AbreArquivos( "jpconfi" )
      QUIT
   ENDIF
   DelCnf( "MARGEM RELATORIOS" )
   DelCnf( "ESPACO LIVRE (KB)" )
   DelCnf( "NUM.ARQ.TEMP." )
   DelCnf( "REINDEX PERIODO" )
   DelCnf( "BACKUP PERIODO" )
   DelCnf( "REINDEX ULTIMA" )
   DelCnf( "BACKUP ULTIMO" )
   DelCnf( "BACKUP DRIVE" )
   DelCnf( "BACKUP DIARIO" )
   DelCnf( "LAYOUT DE DUPLIC" )
   DelCnf( "BACKUP DATALZH" )
   DelCnf( "P0480" )
   DelCnf( "P0500" )
   DelCnf( "P1745" )
   DelCnf( "P0850" )
   DelCnf( "BA_P130" )
   DelCnf( "PEDIDO EMAIL C/PRECO" )
   DelCnf( "PEDIDO EMAIL C/GARAN" )
   DelCnf( "PEDIDO EMAIL S/GARAN" )
   DelCnf( "P0660" )
   DelCnf( "P0610" )
   DelCnf( "P0690" )
   DelCnf( "P0540" )
   DelCnf( "VARIAS TAB.PRECO" )
   DelCnf( "DESCR.P/NF" )
   DelCnf( "P0390" )
   DelCnf( "PPRE0030" )
   DelCnf( "PFIN0140" )
   DelCnf( "PFIN0120" )
   DelCnf( "PCAD0150" )
   DelCnf( "P0790" )
   DelCnf( "PEDIDO EMAIL S/PRECO" )
   DelCnf( "EMAIL BACKUP" )
   DelCnf( "P0665" )
   DelCnf( "LAYOUT DE NF" )
   DelCnf( "PROXIMO CONTRATO" )
   DelCnf( "PROXIMO CTRC" )
   DelCnf( "PROXIMO REL.NOTAS" )
   DelCnf( "VENCIDO NAO PEDIDO" )
   DelCnf( "VENCIDO NAO NF" )
   DelCnf( "PEDIDO PARCIAL" )
   DelCnf( "PROXIMA NF" )
   DelCnf( "BAIXA P/ TRANSACAO" )
   DelCnf( "BAIXA P/TRANSACAO" )
   DelCnf( "XMLID" )
   DelCnf( "ESTOQUE FISCAL" )
   DelCnf( "DESCR.NF ESTOQUE" )
   DelCnf( "CCUSTO ESTOQUE" )
   DelCnf( "PEDIDOS DEZ EM DEZ" )
   DelCnf( "VARIAS TAB.P/CLI" )
   DelCnf( "MICRO MONTADO" )
   DelCnf( "NUM.RECDIA" )
   DelCnf( "REGRAS TRIBUTACAO" )
   DelCnf( "VERSAOWIN" )
   DelCnf( "DIGITA NUM.BOLETO" )
   GOTO TOP
   DO WHILE ! Eof()
      IF Left( jpconfi->cnf_Nome, 11 ) == "IMPRESSORA " .OR. Empty( jpconfi->cnf_Nome )
         RecLock()
         DELETE
         RecUnlock()
      ENDIF
      SKIP
   ENDDO
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION RemoveLixo( ... )

   LOCAL acMaskList, acFileList, oFile, oMask, cPath

   acMaskList := hb_AParams()

   IF Len( acMaskList ) != 0
      FOR EACH oMask IN acMaskList
         cPath := iif( "\" $ oMask, Substr( oMask, 1, Rat( "\", oMask ) ), "" )
         acFileList := Directory( oMask )
         FOR EACH oFile IN acFileList
            fErase( cPath + oFile[ F_NAME ] )
            Errorsys_WriteErrorLog( "Eliminado arquivo desativado " + cPath + oFile[ F_NAME ] )
         NEXT
      NEXT
      RETURN NIL
   ENDIF
   RemoveLixo( "*.lzh", "*.tmp", "*.pdf", "*.prn", "*.idx", "*.ndx", "*.cnf", "*.fpt", "*.ftp", "*.vbs", "*.car" )
   RemoveLixo( "temp\*.tmp", "jpawprt.exe", "getmail.exe", "*.htm", "rastrea.dbf", "jplicmov.dbf" )
   RemoveLixo( "rastrea.cdx", "jplicmov.cdx", "ts069", "ts086", "jpa.cfg.backup", "msg_os_fornecedor.txt" )
   RemoveLixo( "jpordser.dbf", "jpcotaca.dbf", "jpvvdem.dbf", "jpvvfin.dbf", "jpordbar.dbf" )
   RemoveLixo( "jpaprint.cfg", "preto.jpg", "jpnfexx.dbf", "aobaagbe", "bbchdjfe", "ajuda.hlp" )
   RemoveLixo( "jpaerror.txt", "ads.ini", "adslocal.cfg", "setupjpa.msi", "duplicados.txt" )

   RETURN NIL

STATIC FUNCTION Update20170922()

   SayScroll( "Renomeando fontes" )
   IF ! AbreArquivos( "jpsenha" )
      QUIT
   ENDIF
   pw_AddModule( "PDFEGERAPDF",       "PDA0010" )
   pw_AddModule( "PDFECTECANCEL",     "PCTECANCEL" )
   pw_AddModule( "PDFECTEINUT",       "PCTEINUT" )
   pw_AddModule( "PDFENFEINUT",       "PNFEINUT" )
   pw_AddModule( "PDFEIMPORTA",       "PNFE0060" )
   pw_AddModule( "PDFEIMPORTA",       "PNFEIMPORTA" )
   pw_AddModule( "PDFESALVA",         "PNFESALVAMYSQL" )
   pw_AddModule( "PPRETABCOMB",       "PPRE0010" )
   pw_AddModule( "PPRETABCOMBREAJ",   "PPRE0020" )
   pw_AddModule( "PPRETABELA",        "PPRE0040" )
   pw_AddModule( "PPREVALPERCA",      "PNOT0213" )
   pw_AddModule( "PPREVALPERCC",      "PNOT0214" )
   pw_AddModule( "PPRECANCEL",        "PPRECOCANCEL" )
   pw_AddModule( "PPREHTMLTABPRE",    "PPRECOHTMLTABPRE" )
   pw_AddModule( "PPRETABGERAL",      "PPRECOTABGERAL" )
   pw_AddModule( "PPREVALPERC",       "PPRECOVALPERC" )
   pw_AddModule( "PPRETABCOMB",       "PPRECOTABCOMB" )
   pw_AddModule( "PPRETABCOMBREAJ",   "PPRECOTABCOMBREAJ" )
   pw_AddModule( "PPRETABELA",        "PPRECOTABELA" )
   pw_AddModule( "PCONTLANCAEDIT",    "PCONTLANCALTERA" )
   pw_AddModule( "PEDIEXPCLARCON",    "PEDICFIN" )
   pw_AddModule( "PEDIIMPPLAREF",     "PCONTSPED" )
   pw_AddModule( "PDFEEMAIL",         "PDFESALVA" )
   pw_AddModule( "PFINANEDRECEBERBX", "PFIN0035" )
   pw_AddModule( "PFINANEDPAGARBX",   "PFIN0045" )
   pw_AddModule( "PDFEZIPXML",        "PADMINACESSO" )
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION Update20171231()

   LOCAL aList := {}, oElement

   IF ! "CRISPET" $ AppEmpresaApelido()
      RETURN NIL
   ENDIF

   SayScroll( "Número de documento no estoque" )
   AAdd( aList, { "000207", "000202049" } )
   AAdd( aList, { "000208", "000201903" } )
   AAdd( aList, { "000209", "000201902" } )
   AAdd( aList, { "000210", "000201774" } )
   AAdd( aList, { "000211", "000201481" } )
   AAdd( aList, { "000212", "000201304" } )
   AAdd( aList, { "000213", "000201308" } )
   AAdd( aList, { "000214", "000201184" } )
   AAdd( aList, { "000215", "000201182" } )
   AAdd( aList, { "000216", "000201183" } )
   AAdd( aList, { "000217", "000201013" } )
   AAdd( aList, { "000218", "000200748" } )
   AAdd( aList, { "000219", "000200606" } )
   AAdd( aList, { "000226", "000202385" } )
   AAdd( aList, { "000227", "000202386" } )
   AAdd( aList, { "000237", "000202687" } )
   AAdd( aList, { "000238", "000202673" } )
   AAdd( aList, { "000248", "000203196" } )
   AAdd( aList, { "000249", "000203197" } )
   AAdd( aList, { "000250", "000203027" } )
   AAdd( aList, { "000251", "000202851" } )
   AAdd( aList, { "000263", "000203451" } )
   AAdd( aList, { "000264", "000203411" } )
   AAdd( aList, { "000265", "000203374" } )
   AAdd( aList, { "000266", "000203645" } )
   AAdd( aList, { "000285", "000203905" } )
   AAdd( aList, { "000286", "000204054" } )
   AAdd( aList, { "000287", "000204246" } )
   AAdd( aList, { "000288", "000204467" } )
   AAdd( aList, { "000309", "000007939" } )
   AAdd( aList, { "000314", "000007939" } )
   AAdd( aList, { "000674", "020120131" } )
   AAdd( aList, { "000675", "020120228" } )
   AAdd( aList, { "000676", "020120331" } )
   AAdd( aList, { "000677", "020120430" } )
   AAdd( aList, { "000825", "000358415" } )
   AAdd( aList, { "001339", "000008994" } )
   AAdd( aList, { "001526", "000009218" } )
   AAdd( aList, { "001638", "000009359" } )
   AAdd( aList, { "001788", "000009570" } )
   AAdd( aList, { "001909", "000009740" } )
   AAdd( aList, { "001973", "000009815" } )
   AAdd( aList, { "002080", "000009940" } )
   AAdd( aList, { "002081", "000009941" } )
   AAdd( aList, { "002082", "000009942" } )
   AAdd( aList, { "002083", "000009944" } )
   AAdd( aList, { "002262", "000010148" } )
   AAdd( aList, { "002272", "000010158" } )
   AAdd( aList, { "002326", "000010219" } )
   AAdd( aList, { "002880", "000010870" } )
   AAdd( aList, { "002915", "000010909" } )
   AAdd( aList, { "003478", "000011585" } )
   AAdd( aList, { "003486", "000011590" } )
   AAdd( aList, { "004769", "000201301" } )
   AAdd( aList, { "004770", "000008813" } )
   AAdd( aList, { "004771", "000008832" } )
   AAdd( aList, { "004772", "000008756" } )
   AAdd( aList, { "004773", "000008780" } )
   AAdd( aList, { "004774", "000008788" } )
   AAdd( aList, { "004775", "000008810" } )
   AAdd( aList, { "004776", "000008791" } )
   AAdd( aList, { "004777", "000011900" } )
   AAdd( aList, { "004778", "000310313" } )
   AAdd( aList, { "004779", "000008949" } )
   AAdd( aList, { "004780", "000008921" } )
   AAdd( aList, { "004781", "000008892" } )
   AAdd( aList, { "004782", "000008935" } )
   AAdd( aList, { "004783", "000008904" } )
   AAdd( aList, { "004784", "000008941" } )
   AAdd( aList, { "004785", "000300413" } )
   AAdd( aList, { "004792", "000310513" } )
   AAdd( aList, { "004793", "000009126" } )
   AAdd( aList, { "004794", "000009137" } )
   AAdd( aList, { "004795", "000005000" } )
   AAdd( aList, { "004796", "000009238" } )
   AAdd( aList, { "004797", "000300614" } )
   AAdd( aList, { "004831", "000009351" } )
   AAdd( aList, { "004832", "000009381" } )
   AAdd( aList, { "004833", "000009564" } )
   AAdd( aList, { "004835", "000009591" } )
   AAdd( aList, { "004836", "000008575" } )
   AAdd( aList, { "004837", "000009678" } )
   AAdd( aList, { "005073", "020130930" } )
   AAdd( aList, { "005074", "030112013" } )
   AAdd( aList, { "005075", "000009047" } )
   AAdd( aList, { "005076", "000009060" } )
   AAdd( aList, { "005077", "000010142" } )
   AAdd( aList, { "005078", "000009112" } )
   AAdd( aList, { "005079", "000009114" } )
   AAdd( aList, { "005080", "000009148" } )
   AAdd( aList, { "005081", "000010291" } )
   AAdd( aList, { "005082", "000010303" } )
   AAdd( aList, { "005083", "000122748" } )
   AAdd( aList, { "005084", "000010470" } )
   AAdd( aList, { "005085", "000010689" } )
   AAdd( aList, { "005086", "000010693" } )
   AAdd( aList, { "005087", "000010702" } )
   AAdd( aList, { "005096", "000011232" } )
   AAdd( aList, { "005097", "000011236" } )
   AAdd( aList, { "005098", "000011240" } )
   AAdd( aList, { "005099", "000011252" } )
   AAdd( aList, { "005100", "000011266" } )
   AAdd( aList, { "005101", "000156976" } )
   AAdd( aList, { "005102", "000011533" } )
   AAdd( aList, { "005103", "000011558" } )
   AAdd( aList, { "005104", "000011562" } )
   AAdd( aList, { "005105", "000159697" } )
   AAdd( aList, { "005112", "000011686" } )
   AAdd( aList, { "005113", "000010854" } )
   AAdd( aList, { "005114", "000011724" } )
   AAdd( aList, { "005115", "000011747" } )
   AAdd( aList, { "005116", "000011906" } )
   AAdd( aList, { "005117", "000011767" } )
   AAdd( aList, { "005118", "000011860" } )
   AAdd( aList, { "005119", "000011887" } )
   AAdd( aList, { "005120", "000011920" } )
   AAdd( aList, { "005121", "000011941" } )
   AAdd( aList, { "005122", "000011964" } )
   AAdd( aList, { "005123", "000011973" } )
   AAdd( aList, { "005124", "000012081" } )
   AAdd( aList, { "005125", "000012171" } )
   AAdd( aList, { "005134", "000012126" } )
   AAdd( aList, { "005135", "000012423" } )
   AAdd( aList, { "005136", "000012447" } )
   AAdd( aList, { "005137", "000012277" } )
   AAdd( aList, { "005140", "000307625" } )
   AAdd( aList, { "005405", "000012400" } )
   AAdd( aList, { "005406", "000012401" } )
   AAdd( aList, { "005407", "000012369" } )
   AAdd( aList, { "005408", "000012358" } )
   AAdd( aList, { "005755", "000012722" } )
   AAdd( aList, { "005756", "000012765" } )
   AAdd( aList, { "005757", "000013137" } )
   AAdd( aList, { "005758", "000012820" } )
   AAdd( aList, { "005924", "000187449" } )
   AAdd( aList, { "006130", "000013018" } )
   AAdd( aList, { "006131", "000013057" } )
   AAdd( aList, { "006273", "000013213" } )
   AAdd( aList, { "006471", "000013352" } )
   AAdd( aList, { "006472", "000013448" } )
   AAdd( aList, { "006473", "000013447" } )
   AAdd( aList, { "006652", "000381208" } )
   AAdd( aList, { "006653", "000201430" } )
   AAdd( aList, { "006654", "000202211" } )
   AAdd( aList, { "006655", "000013535" } )
   AAdd( aList, { "006860", "000013715" } )
   AAdd( aList, { "007030", "000209622" } )
   AAdd( aList, { "007070", "000013823" } )
   AAdd( aList, { "007071", "000013863" } )
   AAdd( aList, { "007268", "000014257" } )
   AAdd( aList, { "007502", "000014305" } )
   AAdd( aList, { "007503", "000014331" } )
   AAdd( aList, { "007504", "000014358" } )
   AAdd( aList, { "007505", "000014364" } )
   AAdd( aList, { "007506", "000014853" } )
   AAdd( aList, { "007662", "000223000" } )
   AAdd( aList, { "007973", "000014542" } )
   AAdd( aList, { "008114", "000231000" } )
   AAdd( aList, { "008215", "000260446" } )
   AAdd( aList, { "008216", "000398115" } )
   AAdd( aList, { "008217", "000014950" } )
   AAdd( aList, { "008218", "000014969" } )
   AAdd( aList, { "008219", "000014972" } )
   AAdd( aList, { "008220", "000014985" } )
   AAdd( aList, { "008221", "000014986" } )
   AAdd( aList, { "008222", "000014997" } )
   AAdd( aList, { "008223", "000014791" } )
   AAdd( aList, { "008224", "000014795" } )
   AAdd( aList, { "008225", "000014796" } )
   AAdd( aList, { "008226", "000014800" } )
   AAdd( aList, { "008227", "000014891" } )
   AAdd( aList, { "008228", "000014923" } )
   AAdd( aList, { "008229", "000014875" } )
   AAdd( aList, { "008705", "001309002" } )
   AAdd( aList, { "008935", "001315146" } )
   AAdd( aList, { "008936", "001318384" } )
   AAdd( aList, { "008987", "000015477" } )
   AAdd( aList, { "008988", "000016791" } )
   AAdd( aList, { "008989", "000015559" } )
   AAdd( aList, { "008990", "000015677" } )
   AAdd( aList, { "009198", "001324771" } )
   AAdd( aList, { "009199", "001330057" } )
   AAdd( aList, { "009200", "000015751" } )
   AAdd( aList, { "009379", "001339438" } )
   AAdd( aList, { "009380", "001344663" } )
   AAdd( aList, { "009442", "000015954" } )
   AAdd( aList, { "009603", "000257537" } )
   AAdd( aList, { "009604", "000256893" } )
   AAdd( aList, { "009605", "000255401" } )
   AAdd( aList, { "009606", "001360121" } )
   AAdd( aList, { "009607", "000422957" } )
   AAdd( aList, { "009608", "000422912" } )
   AAdd( aList, { "009609", "000422911" } )
   AAdd( aList, { "009610", "000421027" } )
   AAdd( aList, { "009708", "000423205" } )
   AAdd( aList, { "009709", "000422825" } )
   AAdd( aList, { "009710", "000016224" } )
   AAdd( aList, { "009711", "000016339" } )
   AAdd( aList, { "009908", "000016644" } )
   AAdd( aList, { "009943", "000016401" } )
   AAdd( aList, { "009944", "000016452" } )
   AAdd( aList, { "009945", "000016371" } )
   AAdd( aList, { "010206", "000264404" } )
   AAdd( aList, { "010207", "000264405" } )
   AAdd( aList, { "010208", "001374130" } )
   AAdd( aList, { "010338", "001385704" } )
   AAdd( aList, { "010425", "000433565" } )
   AAdd( aList, { "010430", "000016835" } )
   AAdd( aList, { "010581", "001400899" } )
   AAdd( aList, { "010583", "000439677" } )
   AAdd( aList, { "010669", "000274246" } )
   AAdd( aList, { "010816", "000275171" } )
   AAdd( aList, { "010879", "001409890" } )
   AAdd( aList, { "010880", "001417135" } )
   AAdd( aList, { "010881", "000504428" } )
   AAdd( aList, { "010882", "000504918" } )
   AAdd( aList, { "010883", "000504918" } )
   AAdd( aList, { "010884", "000505397" } )
   AAdd( aList, { "011021", "000506340" } )
   AAdd( aList, { "011022", "000506054" } )
   AAdd( aList, { "011023", "001423900" } )
   AAdd( aList, { "011024", "000718978" } )
   AAdd( aList, { "011025", "000719381" } )
   AAdd( aList, { "011026", "000719433" } )
   AAdd( aList, { "011068", "000506982" } )
   AAdd( aList, { "011293", "000724522" } )
   AAdd( aList, { "011294", "001434748" } )
   AAdd( aList, { "011334", "000017740" } )
   AAdd( aList, { "011541", "000724948" } )
   AAdd( aList, { "011542", "000416384" } )
   AAdd( aList, { "011543", "000067877" } )
   AAdd( aList, { "011655", "SALDO    " } )
   AAdd( aList, { "011656", "SALDO    " } )
   AAdd( aList, { "011776", "000424420" } )
   AAdd( aList, { "011777", "000423643" } )
   AAdd( aList, { "011778", "000423453" } )
   AAdd( aList, { "011779", "000421468" } )
   AAdd( aList, { "011780", "000421248" } )
   AAdd( aList, { "011781", "000421109" } )
   AAdd( aList, { "011782", "000068110" } )
   AAdd( aList, { "011783", "000068096" } )
   AAdd( aList, { "011784", "000068075" } )
   AAdd( aList, { "011785", "000068020" } )
   AAdd( aList, { "011786", "000067988" } )
   AAdd( aList, { "011787", "000067971" } )
   AAdd( aList, { "011876", "000018051" } )
   AAdd( aList, { "011877", "000018069" } )
   AAdd( aList, { "011878", "000018068" } )
   AAdd( aList, { "011879", "000018074" } )
   AAdd( aList, { "011880", "000018138" } )
   AAdd( aList, { "012104", "000018323" } )
   AAdd( aList, { "012105", "000018339" } )
   AAdd( aList, { "012106", "000018383" } )
   AAdd( aList, { "012107", "000018412" } )
   AAdd( aList, { "012108", "000018416" } )
   AAdd( aList, { "012109", "000018466" } )
   AAdd( aList, { "012278", "         " } )
   AAdd( aList, { "012380", "         " } )
   AAdd( aList, { "012388", "000018561" } )
   AAdd( aList, { "012389", "000018571" } )
   AAdd( aList, { "012390", "000018592" } )
   AAdd( aList, { "012391", "000018611" } )
   AAdd( aList, { "012392", "000018628" } )
   AAdd( aList, { "012393", "000018643" } )
   AAdd( aList, { "012394", "000018661" } )
   AAdd( aList, { "012395", "000018663" } )
   AAdd( aList, { "012396", "000018685" } )
   AAdd( aList, { "012397", "000018705" } )

   IF ! AbreArquivos( "jpestoq" )
      RETURN NIL
   ENDIF
   FOR EACH oElement IN aList
      IF Encontra( oElement[ 1 ], "jpestoq", "numlan" )
         IF jpestoq->esNumDoc != oElement[ 2 ]
            RecLock()
            REPLACE jpestoq->esNumDoc WITH oElement[ 2 ]
         ENDIF
      ENDIF
   NEXT
   CLOSE DATABASES

   RETURN NIL
