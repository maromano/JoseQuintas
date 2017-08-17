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
   IF AppVersaoDbfAnt() < 20170812; Update20170812A();  ENDIF // Renomeando
   IF AppVersaoDbfAnt() < 20170812; Update20170812B();  ENDIF // Renomeando
   IF AppVersaoDbfAnt() < 20170812; Update20170812C();  ENDIF // Renomeando
   IF AppVersaoDbfAnt() < 20170812; Update20170812D();  ENDIF // Renomeando
   IF AppVersaoDbfAnt() < 20170812; pw_DeleteInvalid(); ENDIF
   IF AppVersaoDbfAnt() < 20170816; Update20170816();   ENDIF // lixo jpconfi
   IF AppVersaoDbfAnt() < 20170816; RemoveLixo();       ENDIF
   IF AppVersaoDbfAnt() < 20170817; Update20170817();   ENDIF

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
      SayScroll( "Gravado lancamento " + jpestoq->esNumLan + " ref. produto " + jpitem->ieItem )
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

STATIC FUNCTION Update20170812A()

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
   pw_AddModule( "PCONTLANCALTERA",  "PCTL0240" )
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
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION Update20170812B()

   IF ! AbreArquivos( "JPSENHA" )
      QUIT
   ENDIF
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
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION Update20170812C()

   IF ! AbreArquivos( "JPSENHA" )
      QUIT
   ENDIF
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
   pw_AddModule( "PPRECOCANCEL",     "PTES0050" )
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
   pw_AddModule( "PNOTARESUMO",      "PTES0060" )
   pw_AddModule( "PNFEIIMPORTA",     "PNFE0060" )
   pw_AddModule( "PNOTACADASTRO",    "PNOT0020" )
   pw_AddModule( "PNOTAPEDRETIRA",   "PNOT0030" )
   pw_AddModule( "PNOTAROMANEIO",    "PNOT0050" )
   pw_AddModule( "PNOTAGERANFE",     "PNOT0060" )
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION Update20170812D()

   IF ! AbreArquivos( "JPSENHA" )
      QUIT
   ENDIF
   pw_AddModule( "PNOTARELRENTAB",   "PNOT0080" )
   pw_AddModule( "PNOTARELNOTAS",    "PNOT0090" )
   pw_AddModule( "PNOTACHECAGEM",    "PNOT0200" )
   pw_AddModule( "PNOTAPROXIMAS",    "PNOT0270" )
   pw_AddModule( "PESTOTOTARMAZEM",  "PNOT0260" )
   pw_AddModule( "PNOTAFICCLIVEN",   "PNOT0250" )
   pw_AddModule( "PPRECOHTMLTABPRE", "PNOT0240" )
   pw_AddModule( "PPRECORELTABMULTI","PNOT0220" )
   pw_AddModule( "PPRECORELTABGERAL","LLPRECO" )
   pw_AddModule( "PPRECORELTABCOMB", "PPRE0030" )
   pw_AddModule( "PPRECOVALPERC",    "PNOT0210" )
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
   pw_AddModule( "PNFESALVAMYSQL",   "PNFE0010" )
   pw_AddModule( "PESTORECALCULO",   "PBUG0090" )
   pw_AddModule( "PNOTAPLANILHAG",   "PNOT0100" )
   pw_AddModule( "PNOTAPLANILHACV",  "PNOT0101" )
   pw_AddModule( "PNOTAPLANILHAC",   "PNOT0102" )
   pw_AddModule( "PNOTARELCOMPMES",  "PNOT0150" )
   pw_AddModule( "PNOTARELMAPA",     "PNOT0145" )
   pw_AddModule( "PNOTACONSPROD",    "PNOT0170" )
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION Update20170816()

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

STATIC FUNCTION Update20170817()

   IF ! AbreArquivos( "jpsenha" )
      QUIT
   ENDIF
   pw_AddModule( "PDFEGERAPDF",   "PDA0010" )
   pw_AddModule( "PDFECTECANCEL", "PCTECANCEL" )
   pw_AddModule( "PDFECTEINUT",   "PCTEINUT" )
   pw_AddModule( "PDFENFEINUT",   "PNFEINUT" )
   CLOSE DATABASES

   RETURN NIL
