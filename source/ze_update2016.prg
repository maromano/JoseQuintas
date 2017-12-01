/*
ZE_UPDATE2016 - conversões 2016
2016 José Quintas

2017.12.01 - Considera JPPREHIS somente no MySQL
*/

FUNCTION ze_Update2016()

   Update20160101() // DBFs opcionais com default
   IF AppVersaoDbfAnt() < 20160829; Update20160901();   ENDIF // MYSQL.JPREGUSO - aumento de campo
   IF AppVersaoDbfAnt() < 20160908; Update20160908();   ENDIF // MYSQL.JPEDICFG
   IF AppVersaoDbfAnt() < 20161209; Update20161209();   ENDIF // Campo CDCONTRIB em MYSQL.JPCADAS

   RETURN NIL

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

STATIC FUNCTION Update20160901()

   LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() )

   IF AppcnMySqlLocal() == NIL
      RETURN NIL
   ENDIF
   cnMySql:ExecuteCmd( "ALTER TABLE JPREGUSO MODIFY RUARQUIVO VARCHAR(15) NOT NULL DEFAULT ''" )

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
