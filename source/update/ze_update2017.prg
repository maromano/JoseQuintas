/*
ZE_UPDATE2017 - Conversões 2017
2017 José Quintas
*/

FUNCTION ze_Update2017()

   IF AppVersaoDbfAnt() < 20170404; Update20170404();   ENDIF // Status de manifesto
   IF AppVersaoDbfAnt() < 20170601; Update20170601();   ENDIF // Estoque anterior
   IF AppVersaoDbfAnt() < 20170608; Update20170608();   ENDIF // Caracteres nos XMLs
   IF AppVersaoDbfAnt() < 20170614; Update20170614();   ENDIF // Corrige estoque
   IF AppVersaoDbfAnt() < 20170620; Update20170620();   ENDIF // Novo jpsenha
   IF AppVersaoDbfAnt() < 20170723; Update20170730();   ENDIF // Renomeando
   IF AppVersaoDbfAnt() != AppVersaoDbf() // até terminar de renomear
      Update20170730()
   ENDIF

   RETURN NIL

/*
RC20170404 - Status de manifesto
2017.04.04.1300 - José Quintas
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
RC20170601 - Estoque anterior
2017.06.02.1000 - José Quintas
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
RC20170608 - Corrigir 10 XMLs no meio de 600.000
2017.06.08.1900 - José Quintas
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
RC20170614 - Corrige estoque
2017.06.14.1430 - José Quintas
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
RC20170620 - Novo senhas
2017.06.14.1500 - José Quintas

2017.06.20.1400 - Renomeado
*/

STATIC FUNCTION Update20170620()

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

   LOCAL lDelete := .F.

   DO CASE
   CASE ! Empty( jpsenha->pwType )
   CASE ! IsValid( Descriptografa( Substr( jpsenha->Senha, 2, 30 ) ) )
   CASE ! IsValid( Descriptografa( Substr( jpsenha->Senha, 32, 30 ) ) )
   OTHERWISE
      lDelete := .F.
      RecLock()
      REPLACE ;
         jpsenha->pwType   WITH Substr( jpsenha->Senha, 1, 1 ), ;
         jpsenha->pwFirst  WITH Criptografa( Descriptografa( Substr( jpsenha->Senha, 2, 30 ) ) ), ;
         jpsenha->pwLast   WITH Criptografa( Descriptografa( Substr( jpsenha->Senha, 32, 30 ) ) )
      RecUnlock()
   ENDCASE
   IF lDelete
      RecLock()
      DELETE
      RecUnlock()
   ENDIF

   RETURN NIL

STATIC FUNCTION IsValid( cTexto )

   LOCAL oElement, lIsValid := .T.

   FOR EACH oElement IN cTexto
      DO CASE
      CASE oElement $ "abcdefghijklmnopqrstuvwxuz"
      CASE oElement $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      CASE oElement $ "0123456789"
      CASE oElement $ "_ "
      OTHERWISE
         lIsValid := .F.
      ENDCASE
   NEXT
   IF ! lIsValid
      SayScroll( "Nome inválido " + cTexto )
      Inkey(1)
   ENDIF

   RETURN lIsValid

/*
Update20170717 - Renomeando fontes
*/

STATIC FUNCTION Update20170730()

   IF ! AbreArquivos( "JPSENHA" )
      QUIT
   ENDIF
   pw_NovoAcessoModulo( "PTOOLDBASE",       "RDBASE" )
   pw_NovoAcessoModulo( "PGAMEFORCA",       "GAMEFORCA" )
   pw_NovoAcessoModulo( "PGAMETESTEQI",     "PGAMETESTEQI" )
   pw_NovoAcessoModulo( "PESTLANCA1",       "PJPESTOQ1" )
   pw_NovoAcessoModulo( "PESTLANCA2",       "PJPESTOQ2" )
   pw_NovoAcessoModulo( "PESTVALEST",       "PEST0050" )
   pw_NovoAcessoModulo( "PESTENTFOR",       "PEST0060" )
   pw_NovoAcessoModulo( "PSETUPPARAMALL",   "PJPCONFIA" )
   pw_NovoAcessoModulo( "PSETUPPARAMROUND", "PJPCONFIB" )
   pw_NovoAcessoModulo( "PSETUPNUMERO",     "PJPNUMERO" )
   pw_NovoAcessoModulo( "PSETUPEMPRESA",    "PCFG0030" )
   pw_NovoAcessoModulo( "PNOTETIQUETA",     "PNOT0230" )
   pw_NovoAcessoModulo( "PNOTAETIQUETA",    "PNOTETIQUETA" )
   pw_NovoAcessoModulo( "PFORMRECIBO",      "RRECIBO" )
   pw_NovoAcessoModulo( "PGERALRECIBO",     "PFORMRECIBO" )
   pw_NovoAcessoModulo( "PADMLOG",          "PUTI0040" )
   pw_NovoAcessoModulo( "PUTILDBASE",       "PTOOLDBASE" )
   pw_NovoAcessoModulo( "PCONTCODRED",      "PCTL0010" )
   pw_NovoAcessoModulo( "PCONTREL0010",     "PCTL0020" )
   pw_NovoAcessoModulo( "PCONTNUMDIA",      "PCTL0060" )
   pw_NovoAcessoModulo( "PCONTSETUP",       "PCTL0070" )
   pw_NovoAcessoModulo( "PCONTEMITIDOS",    "PCTL0090" )
   pw_NovoAcessoModulo( "PCONTSINTETICA",   "PCTL0110" )
   pw_NovoAcessoModulo( "PCONTRECALCULO",   "PCTL0120" )
   pw_NovoAcessoModulo( "PCONTREDRENUM",    "PCTL0130" )
   pw_NovoAcessoModulo( "PCONTREDDISP",     "PCONTCODRED" )
   pw_NovoAcessoModulo( "PCONTCTPLANO",     "PCTL0150" )
   pw_NovoAcessoModulo( "PCONTCTLANCA",     "PCTLANCA" )
   pw_NovoAcessoModulo( "PCONTSALDO",       "PCTL0180" )
   pw_NovoAcessoModulo( "PCONTFECHA",       "PCTL0190" )
   pw_NovoAcessoModulo( "PCONTTOTAIS",      "PCTL0260" )
   pw_NovoAcessoModulo( "PCONTLANCINCLUI",  "PCTL0200" )
   pw_NovoAcessoModulo( "PCONTLANCLOTE",    "PCTL0220" )
   pw_NovoAcessoModulo( "PCONTLANCALTERA",  "PCTL0240" )
   pw_NovoAcessoModulo( "PCONTREL0360",     "PCTL0360" )
   pw_NovoAcessoModulo( "PCONTREL0270",     "PCTL0270" )
   pw_NovoAcessoModulo( "PCONTREL0520",     "PCTL0520" )
   pw_NovoAcessoModulo( "PCONTREL0210",     "PCTL0210" )
   pw_NovoAcessoModulo( "PCONTREL0380",     "PCTL0380" )
   pw_NovoAcessoModulo( "PCONTREL0310",     "PCTL0310" )
   pw_NovoAcessoModulo( "PCONTREL0320",     "PCTL0320" )
   pw_NovoAcessoModulo( "PCONTREL0390",     "PCTL0390" )
   pw_NovoAcessoModulo( "PCONTREL0250",     "PCTL0250" )
   pw_NovoAcessoModulo( "PCONTREL0550",     "PCTL0550" )
   pw_NovoAcessoModulo( "PCONTREL0300",     "PCTL0300" )
   pw_NovoAcessoModulo( "PCONTREL0530",     "PCTL0530" )
   pw_NovoAcessoModulo( "PCONTREL0330",     "PCTL0330" )
   pw_NovoAcessoModulo( "PCONTREL0385",     "PCTL0385" )
   pw_NovoAcessoModulo( "PCONTREL0470",     "PCTL0470" )
   pw_NovoAcessoModulo( "PCONTREL0370",     "PCTL0370" )
   pw_NovoAcessoModulo( "PCONTREL0230",     "PCTL0230" )
   pw_NovoAcessoModulo( "PCONTREL0340",     "PCTL0340" )
   pw_NovoAcessoModulo( "PFISCIMPOSTO",     "PJPIMPOS" )
   pw_NovoAcessoModulo( "PFISCDECRETO",     "PJPDECRET" )
   pw_NovoAcessoModulo( "PFISCCORRECAO",    "PFIS0010" )
   pw_NovoAcessoModulo( "PFISCREL0010",     "PFIS0100" )
   pw_NovoAcessoModulo( "PFISCREL0020",     "PFIS0170" )
   pw_NovoAcessoModulo( "PFISCENTRADAS",    "PJPLFISC2" )
   pw_NovoAcessoModulo( "PFISCSAIDAS",      "PJPLFISC1" )
   pw_NovoAcessoModulo( "PFISCTOTAIS",      "PJPLFISCD" )
   pw_NovoAcessoModulo( "PFISCREL0020",     "PCONTREL0210" )
   pw_NovoAcessoModulo( "PFISCREL0030",     "LJPLFISCA" )
   pw_NovoAcessoModulo( "PFISCREL0040",     "LJPLFISCC" )
   pw_NovoAcessoModulo( "PFISCREL0050",     "LJPLFISCG" )
   pw_NovoAcessoModulo( "PFISCREL0060",     "LJPLFISCE" )
   pw_NovoAcessoModulo( "PFISCREL0070",     "LJPLFISCF" )
   pw_NovoAcessoModulo( "PFISCREL0080",     "LJPLFISCJ" )
   pw_NovoAcessoModulo( "PFISCREL0090",     "LJPLFISCK" )
   pw_NovoAcessoModulo( "PFISCREL0100",     "LJPLFISCD" )
   pw_NovoAcessoModulo( "PFISCREL0110",     "LJPLFISCI" )
   pw_NovoAcessoModulo( "PFISCREL0120",     "LJPLFISCH" )
   pw_NovoAcessoModulo( "PFISCREL0130",     "PGOV0070" )
   pw_NovoAcessoModulo( "PFISCREL0140",     "PGOV0060" )
   pw_NovoAcessoModulo( "PLEISIMPOSTO",     "PFISCIMPOSTO" )
   pw_NovoAcessoModulo( "PLEISDECRETO",     "PFISCDECRETO" )
   pw_NovoAcessoModulo( "PCONTREFCTA",      "PJPREFCTA" )
   pw_NovoAcessoModulo( "PLEISIBPT",        "PJPIBPT" )
   pw_NovoAcessoModulo( "PLEISREFCTA",      "PCONTREFCTA" )
   pw_NovoAcessoModulo( "PFISCSINTEGRA",    "PGOV0040" )
   pw_NovoAcessoModulo( "PFISCSPED",        "PGOV0030" )
   pw_NovoAcessoModulo( "PCONTSPED",        "PGOV0010" )
   pw_NovoAcessoModulo( "PCONTFCONT",       "PGOV0020" )
   pw_NovoAcessoModulo( "PCONTCONTAS",      "PCONTCTPLANO" )
   pw_NovoAcessoModulo( "PCONTHISTORICO",   "PCTHISTO" )
   pw_NovoAcessoModulo( "PCONTLANCPAD",     "PCONTCTLANCA" )
   pw_NovoAcessoModulo( "PCONTIMPLANO",     "PEDI0080" )
   pw_NovoAcessoModulo( "PCONTEXPLOTE1",    "PEDI0090" )
   pw_NovoAcessoModulo( "PCONTIMPLOTE1",    "PEDI0100" )
   pw_NovoAcessoModulo( "PCONTAUXCTAADM",   "PAUXCTAADM" )
   pw_NovoAcessoModulo( "PCONTIMPEXCEL",    "PXLSKITFRA" )
   pw_NovoAcessoModulo( "PLEISUF",          "PJPUF" )
   pw_NovoAcessoModulo( "PLEISAUXQUAASS",   "PAUXQUAASS" )
   pw_NovoAcessoModulo( "PLEISAUXCFOP",     "PAUXCFOP" )
   pw_NovoAcessoModulo( "PLEISAUXCNAE",     "PAUXCNAE" )
   pw_NovoAcessoModulo( "PLEISAUXICMCST",   "PAUXICMCST" )
   pw_NovoAcessoModulo( "PCONTAUXCTAADM",   "PCONTCTAADM" )
   pw_NovoAcessoModulo( "PLEISCFOP",        "PLEISAUXCFOP" )
   pw_NovoAcessoModulo( "PLEISCNAE",        "PLEISAUXCNAE" )
   pw_NovoAcessoModulo( "PLEISICMCST",      "PLEISAUXICMCST" )
   pw_NovoAcessoModulo( "PLEISQUAASS",      "PLEISAUXQUAASS" )
   pw_NovoAcessoModulo( "PLEISIPICST",      "PAUXIPICST" )
   pw_NovoAcessoModulo( "PLEISIPIENQ",      "PAUXIPIENQ" )
   pw_NovoAcessoModulo( "PLEISMODFIS",      "PAUXMODFIS" )
   pw_NovoAcessoModulo( "PLEISORIMER",      "PAUXORIMER" )
   pw_NovoAcessoModulo( "PLEISPISCST",      "PAUXPISCST" )
   pw_NovoAcessoModulo( "PLEISPISENQ",      "PAUXPISENQ" )
   pw_NovoAcessoModulo( "PLEISPROUNI",      "PAUXPROUNI" )
   pw_NovoAcessoModulo( "PLEISTRICAD",      "PAUXTRICAD" )
   pw_NovoAcessoModulo( "PLEISTRIEMP",      "PAUXTRIEMP" )
   pw_NovoAcessoModulo( "PLEISTRIPRO",      "PAUXTRIPRO" )
   pw_NovoAcessoModulo( "PLEISTRIUF",       "PAUXTRIUF" )
   pw_NovoAcessoModulo( "PLEISRELIMPOSTO",  "LJPIMPOS" )
   pw_NovoAcessoModulo( "PLEISCORRECAO",    "PAUXCARCOR" )
   pw_NovoAcessoModulo( "PCONTCTAADM",      "PCONTAUXCTAADM" )
   pw_NovoAcessoModulo( "PUPDATEEXEUP",     "PVERUPL" )
   pw_NovoAcessoModulo( "PUPDATEEXEDOWN",   "PUTI0070" )
   pw_NovoAcessoModulo( "PESTODEPTO",       "PAUXPRODEP" )
   pw_NovoAcessoModulo( "PESTOGRUPO",       "PAUXPROGRU" )
   pw_NovoAcessoModulo( "PESTOLOCAL",       "PAUXPROLOC" )
   pw_NovoAcessoModulo( "PESTOSECAO",       "PAUXPROSEC" )
   pw_NovoAcessoModulo( "PADMINLOG",        "PADMLOG" )
   pw_NovoAcessoModulo( "PADMINACESSO",     "PCFG0050" )
   pw_NovoAcessoModulo( "PESTOITEMXLS",     "PXLS0010" )
   pw_NovoAcessoModulo( "PLEISCIDADE",      "PJPCIDADE" )
   pw_NovoAcessoModulo( "PLEISRELCIDADE",   "LJPCIDADE" )
   pw_NovoAcessoModulo( "PNOTAXLS",         "PNOT0110" )
   pw_NovoAcessoModulo( "PESTORECALCULT",   "PBUG0080" )
   pw_NovoAcessoModulo( "PPRECOCANCEL",     "PTES0050" )
   CLOSE DATABASES

   RETURN NIL
