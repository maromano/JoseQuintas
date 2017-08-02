/*
ZE_UPDATE2016 - conversões 2016
2016 José Quintas
*/

FUNCTION ze_Update2016()

   Update20160101() // DBFs opcionais com default
   IF AppVersaoDbfAnt() < 20160829; Update20160830();   ENDIF // nome cidades mogi mirim e embu das artes
   IF AppVersaoDbfAnt() < 20160829; Update20160901();   ENDIF // MYSQL.JPREGUSO - aumento de campo
   IF AppVersaoDbfAnt() < 20160907; Update20160907();   ENDIF // MYSQL.JPNFBASE
   IF AppVersaoDbfAnt() < 20160908; Update20160908();   ENDIF // MYSQL.JPEDICFG
   IF AppVersaoDbfAnt() < 20160911; Update20160911();   ENDIF // MYSQL.JPPREHIS
   IF AppVersaoDbfAnt() < 20160923; Update20160923();   ENDIF // MYSQL.JPAGENDA
   IF AppVersaoDbfAnt() < 20161209; Update20161209();   ENDIF // Campo CDCONTRIB em MYSQL.JPCADAS

   RETURN NIL

//-----------
STATIC FUNCTION Update20160101()

   IF AppcnMySqlLocal() == NIL
      JPREGUSOCreateDbf()
      JPDECRETCreateDbf()
      JPIBPTCreateDbf()
      RETURN NIL
   ENDIF
   IF File( "jpreguso.cdx" )
      fErase( "jpreguso.cdx" )
   ENDIF
   IF File( "jpdecret.cdx" )
      fErase( "jpdecret.cdx" )
   ENDIF
   IF File( "jpibpt.cdx" )
      fErase( "jpibpt.cdx" )
   ENDIF
   IF File( "JPREGUSO.DBF" )
      CopyDbfToMySql( "JPREGUSO", .T. )
      fErase( "JPREGUSO.DBF" )
   ENDIF
   IF File( "JPDECRET.DBF" )
      JPDECRETCreateDbf()
      CopyDbfToMySql( "JPDECRET", .T. )
      fErase( "JPDECRET.DBF" )
   ENDIF
   IF File( "JPIBPT.DBF" )
      JPIBPTCreateDbf()
      CopyDbfToMySql( "JPIBPT", .T. )
      fErase( "JPIBPT.DBF" )
   ENDIF
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION JPDECRETCreateDbf()

   LOCAL mStruOk

   IF ! ( File( "JPDECRET.DBF" ) .OR. AppVersaoDbfAnt() < 20160101 )
      RETURN NIL
   ENDIF
   SayScroll( "JPDECRET, verificando atualizações" )
   mStruOk := { ;
      { "DENUMLAN",  "C", 6 }, ;
      { "DENOME",    "C", 30 }, ;
      { "DEDESCR1",  "C", 250 }, ;
      { "DEDESCR2",  "C", 250 }, ;
      { "DEDESCR3",  "C", 250 }, ;
      { "DEDESCR4",  "C", 250 }, ;
      { "DEDESCR5",  "C", 250 }, ;
      { "DEINFINC",  "C", 80 }, ;
      { "DEINFALT",  "C", 80 } }
   IF ! ValidaStru( "JPDECRET", mStruOk )
      MsgStop( "JPDECRET não disponível!" )
      QUIT
   ENDIF
   IF AppVersaoDbfAnt() < 20150101
      JPDECRETDefault()
   ENDIF

   RETURN NIL

STATIC FUNCTION JPIBPTCreateDbf()

   LOCAL mStruOk

   IF AppcnMySqlLocal() != NIL .AND. ! File( "JPIBPT.DBF" )
      RETURN NIL
   ENDIF
   SayScroll( "JPIBPT, verificando atualizações" )
   mStruOk := { ;
      { "IBCODIGO",  "C", 8 }, ;
      { "IBEXCECAO", "C", 2 }, ;
      { "IBNCMNBS",  "C", 1 }, ; // 0 NCM
      { "IBUF",      "C", 2 }, ;
      { "IBNACALI",  "N", 7, 2 }, ;
      { "IBIMPALI",  "N", 7, 2 }, ;
      { "IBALIFEDN", "N", 7, 2 }, ;
      { "IBALIFEDI", "N", 7, 2 }, ;
      { "IBALIEST",  "N", 7, 2 }, ;
      { "IBALIMUN",  "N", 7, 2 }, ;
      { "IBINFINC",  "C", 80 }, ;
      { "IBINFALT",  "C", 80 } }
   IF ! ValidaStru( "JPIBPT", mStruOk )
      MsgStop( "JPIBPT nao disponível!" )
      QUIT
   ENDIF

   RETURN NIL
//-----------

/*
RC20160830 - ATUALIZACAO DO NOME DAS CIDADES MOGI MIRIM E EMBU DAS ARTES
20160826 - José Quintas

*/

STATIC FUNCTION Update20160830()

   SayScroll( "Atualizando nome das cidades MOGI MIRIM e EMBU DAS ARTES" )
   IF ! AbreArquivos( "jpempre", "jpcadas", "jpcidade" )
      QUIT
   ENDIF
   SELECT jpempre
   IF Trim( jpempre->emCidade ) == "MOJI MIRIM"
      RecLock()
      REPLACE jpempre->emCidade WITH "MOGI MIRIM"
   ELSEIF Trim( jpempre->emCidade ) == "EMBU"
      RecLock()
      REPLACE jpempre->emCidade WITH "EMBU DAS ARTES"
   ENDIF
   RecUnlock()
   SELECT jpcidade
   SET ORDER TO 0
   GOTO TOP
   GrafTempo( "JPCIDADE" )
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      Inkey()
      IF Trim( jpcidade->ciNome ) == "MOJI MIRIM"
         RecLock()
         REPLACE jpcidade->ciNome WITH "MOGI MIRIM"
      ENDIF
      IF Trim( jpcidade->ciNome ) == "EMBU"
         RecLock()
         REPLACE jpcidade->ciNome WITH "EMBU DAS ARTES"
      ENDIF
      SKIP
   ENDDO
   SELECT jpcadas
   SET ORDER TO 0
   GOTO TOP
   GrafTempo( "JPCADAS" )
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      Inkey()
      IF Trim( jpcadas->cdCidade ) == "MOJI MIRIM"
         RecLock()
         REPLACE jpcadas->cdCidade WITH "MOGI MIRIM"
      ELSEIF Trim( jpcadas->cdCidade ) == "EMBU"
         RecLock()
         REPLACE jpcadas->cdCidade WITH "EMBU DAS ARTES"
      ENDIF
      IF Trim( Jpcadas->cdCidCob ) == "MOJI MIRIM"
         RecLock()
         REPLACE jpcadas->cdCidCob WITH "MOGI MIRIM"
      ELSEIF Trim( jpcadas->cdCidCob ) == "EMBU"
         RecLock()
         REPLACE jpcadas->cdCidCob WITH "EMBU DAS ARTES"
      ENDIF
      IF Trim( jpcadas->cdCidEnt ) == "MOJI MIRIM"
         RecLock()
         REPLACE jpcadas->cdCidEnt WITH "MOGI MIRIM"
      ELSEIF Trim( Jpcadas->cdCidEnt ) == "EMBU"
         RecLock()
         REPLACE jpcadas->cdCidEnt WITH "EMBU DAS ARTES"
      ENDIF
      SKIP
   ENDDO
   CLOSE DATABASES

   RETURN NIL
/*
RC20160901 - AJUSTA ESTRUTURA JPREGUSO
2016.08.29.1015 - José Quintas
*/

STATIC FUNCTION Update20160901()

   LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() )

   IF AppcnMySqlLocal() == NIL
      RETURN NIL
   ENDIF
   cnMySql:ExecuteCmd( "ALTER TABLE JPREGUSO MODIFY RUARQUIVO VARCHAR(15) NOT NULL DEFAULT ''" )

   RETURN NIL
/*
RC20160907 - Conversão jpnfbase
2016.09.07 - José Quintas
*/

STATIC FUNCTION Update20160907()

   LOCAL lEof

   IF AppcnMySqlLocal() == NIL
      JPNFBASECreateDbf()
      RETURN NIL
   ENDIF
   IF File( "jpnfbase.dbf" )
      USE JPNFBASE
      lEof := ( LastRec() < 5 )
      USE
      JPNFBASECreateDbf()
      IF ! lEof
         CopyDbfToMySql( "JPNFBASE", .T. )
      ENDIF
      fErase( "jpnfbase.dbf" )
   ENDIF

   RETURN NIL

STATIC FUNCTION JPNFBASECreateDbf()

   LOCAL mStruOk

   SayScroll( "JPNFBASE, verificando atualizações" )
   mStruOk := { ;
      { "NBNUMLAN",   "C", 6 }, ;
      { "NBNOME",     "C", 40 }, ;
      { "NBENDERECO", "C", 50 }, ;
      { "NBBAIRRO",   "C", 20 }, ;
      { "NBCIDADE",   "C", 20 }, ;
      { "NBUF",       "C", 2 }, ;
      { "NBCEP",      "C", 9 }, ;
      { "NBINFINC",   "C", 80 }, ;
      { "NBINFALT",   "C", 80 } }
   IF ! ValidaStru( "jpnfbase", mStruOk )
      MsgStop( "JPNFBASE não disponível!" )
      QUIT
   ENDIF

   RETURN NIL
/*
RDBEDICFG - TESTA ESTRUTURA JPEDICFG
2016.08.29.1900 - José Quintas

2016.09.08.1330 - Oficial

*/

// bloqueado até ajuste geral

STATIC FUNCTION Update20160908()

   LOCAL lEof, cnMySql := AdoClass():New( AppcnMySqlLocal() )

   IF File( "jpedicfg.cdx" )
      fErase( "jpedicfg.cdx" )
   ENDIF
   IF AppcnMySqlLocal() != NIL
      cnMySql:ExecuteCmd( "ALTER TABLE JPEDICFG MODIFY EDDESEDI VARCHAR(50) NOT NULL DEFAULT ''" )
   ENDIF
   IF File( "jpedicfg.dbf" )
      SayScroll( "Somente em MySQL - JPEDICFG" )
      JPEDICFGCreateDbf()
      USE jpedicfg
      lEof := ( LastRec() < 5 )
      USE
      IF ! lEof
         CopyDbfToMySql( "JPEDICFG", .T. )
      ENDIF
      fErase( "jpedicfg.dbf" )
   ENDIF

   RETURN NIL

STATIC FUNCTION JPEDICFGCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPEDICFG, verificando atualizações" )
   mStruOk := { ;
      { "EDNUMLAN",  "C", 6 }, ;
      { "EDTIPO",    "C", 6 }, ;
      { "EDCODJPA",  "C", 6 }, ;
      { "EDCODEDI1", "C", 20 }, ;
      { "EDCODEDI2", "C", 20 }, ;
      { "EDDESEDI",  "C", 30 }, ;
      { "EDINFINC",  "C", 80 }, ;
      { "EDINFALT",  "C", 80 } }
   IF ! ValidaStru( "JPEDICFG", mStruOk )
      MsgStop( "JPEDICFG não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

/*
RC20160911 - JPPREHIS PARA MYSQL
2016.09.11.1940 - José Quintas
*/

STATIC FUNCTION Update20160911()

   LOCAL lEof

   IF AppcnMySqlLocal() == NIL
      JPPREHISCreateDbf()
      RETURN NIL
   ENDIF
   IF File( "jpprehis.dbf" )
      JPPREHISCreateDbf()
      USE JPPREHIS
      lEof := ( LastRec() < 5 )
      USE
      IF ! lEof
         CopyDbfToMySql( "JPPREHIS", .T. )
      ENDIF
      fErase( "jpprehis.dbf" )
   ENDIF

   RETURN NIL

STATIC FUNCTION JPPREHISCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPPREHIS, verificando atualizações" )
   mStruOk := { ;
      { "PHITEM",   "C", 6 }, ;
      { "PHCADAS",  "C", 6 }, ;
      { "PHFORPAG", "C", 6 }, ;
      { "PHDATA",   "D", 8 }, ;
      { "PHHORA",   "C", 8 }, ;
      { "PHVALOR",  "N", 15, 4 }, ;
      { "PHOBS",    "C", 60 }, ;
      { "PHINFINC", "C", 80 }, ;
      { "PHINFALT", "C", 80 } }
   IF ! ValidaStru( "jpprehis", mStruOk )
      MsgStop( "JPPREHIS não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

/*
RC20160923 - AGENDA PARA MYSQL
2016.09.23.0930 - José Quintas
*/

STATIC FUNCTION Update20160923()

   LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() )

   IF AppcnMySqlLocal() == NIL
      RETURN NIL
   ENDIF
   IF ! AbreArquivos( "jpcadas" )
      RETURN NIL
   ENDIF
   LOCATE FOR jpcadas->cdTipo = "4"
   IF Eof()
      CLOSE DATABASES
      RETURN NIL
   ENDIF
   GOTO TOP
   DO WHILE ! Eof()
      Inkey()
      IF jpcadas->cdTipo != "4"
         SKIP
         LOOP
      ENDIF
      WITH OBJECT cnMySql
         :QueryCreate()
         :QueryAdd( "CDCODIGO",   jpcadas->cdCodigo )
         :QueryAdd( "CDNOME",     jpcadas->cdNome )
         :QueryAdd( "CDENDERECO", jpcadas->cdEndereco )
         :QueryAdd( "CDBAIRRO",   jpcadas->cdBairro )
         :QueryAdd( "CDCIDADE",   jpcadas->cdCidade )
         :QueryAdd( "CDUF",       jpcadas->cdUF )
         :QueryAdd( "CDCEP",      jpcadas->cdCep )
         :QueryAdd( "CDTELEFONE", jpcadas->cdTelefone )
         :QueryAdd( "CDTELEF2",   jpcadas->cdTelef2 )
         :QueryAdd( "CDTELEF3",   jpcadas->cdTelef3 )
         :QueryAdd( "CDFAX",      jpcadas->cdFax )
         :QueryAdd( "CDEMAIL",    jpcadas->cdEmail )
         :QueryAdd( "CDOBS",      jpcadas->cdObs )
         :QueryAdd( "CDINFINC",   jpcadas->cdInfInc )
         :QueryAdd( "CDINFALT",   jpcadas->cdInfAlt )
         :QueryExecuteInsert( "JPAGENDA" )
      END WITH
      RecLock()
      DELETE
      SKIP
   ENDDO
   CLOSE DATABASES

   RETURN NIL

/*
RC20161209 - Campo CDCONTRIB em JPCADAS
2016.12.09.1936 - José Quintas
*/

STATIC FUNCTION Update20161209()

   LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() )

   IF AppcnMySqlLocal() == NIL
      RETURN NIL
   ENDIF
   WITH OBJECT cnMySql
      IF ! :FieldExists( "CDCONTRIB", "JPCADAS" )
         :AddField( "CDCONTRIB", "JPCADAS", "VARCHAR(1) NOT NULL DEFAULT ''" )
      ENDIF
      :ExecuteCmd( "ALTER TABLE JPCADAS MODIFY CDCONTRIB VARCHAR(1) NOT NULL DEFAULT ''" )
   END WITH

   RETURN NIL
