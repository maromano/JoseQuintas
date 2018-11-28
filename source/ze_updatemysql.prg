/*
ZE_UPDATEMYSQL - Todas as estruturas MySql possíveis
2016 José Quintas

2018.02.08 Campos estoque e reserva do produto
2018.02.17 Eliminados restos do demonstrativo
*/

FUNCTION ze_UpdateMysql()

   LOCAL nCont, cnMySql := ADOClass():New( AppcnMySqlLocal() )

   IF AppcnMySqlLocal() == NIL
      RETURN NIL
   ENDIF
   SayScroll( "Verificando tabelas MySql" )

   // Antes de todos os outros
   WITH OBJECT cnMySql
      :ExecuteCmd( JPREGUSOCreateMySql() )
      :ExecuteCmd( JPCONFICreateMySql() )
      //:ExecuteCmd( "DROP TABLE IF EXISTS JPANPAGE" )
      //:ExecuteCmd( "DROP TABLE IF EXISTS JPANPATI" )
      //:ExecuteCmd( "DROP TABLE IF EXISTS JPANPINS" )
      //:ExecuteCmd( "DROP TABLE IF EXISTS JPANPLOC" )
      //:ExecuteCmd( "DROP TABLE IF EXISTS JPANPOPE" )
      //:ExecuteCmd( "DROP TABLE IF EXISTS JPEMISSOR" )
      //:ExecuteCmd( "DROP TABLE IF EXISTS JPORDSER" )
      //:ExecuteCmd( "DROP TABLE IF EXISTS JPCOTACA" )
      //:ExecuteCmd( "DROP TABLE IF EXISTS JPVVDEM" )
      //:ExecuteCmd( "DROP TABLE IF EXISTS JPVVFIN" )
      //:ExecuteCmd( "DROP TABLE IF EXISTS JPTAREF" )
      //:ExecuteCmd( "DROP TABLE IF EXISTS JPORDBAR" )
      //:ExecuteCmd( "DROP TABLE IF EXISTS JPSERVI" )
      :ExecuteCmd( JPCOMBUSTIVELCreateMySql() )
      :ExecuteCmd( JPTABANPAGECreateMySql() )
      :ExecuteCmd( JPTABANPATICreateMySql() )
      :ExecuteCmd( JPTABANPINSCreateMySql() )
      :ExecuteCmd( JPTABANPLOCCreateMySql() )
      :ExecuteCmd( JPTABANPOPECreateMySql() )
      :ExecuteCmd( JPBARRACreateMySql() )
      :ExecuteCmd( JPDECRETCreateMySql() )
      :ExecuteCmd( JPEDICFGCreateMySql() )
      :ExecuteCmd( JPEMANFECreateMySql() )
      :ExecuteCmd( JPFISICACreateMySql() )
      :ExecuteCmd( JPIBPTCreateMySql() )
      :ExecuteCmd( JPLICMOVCreateMySql() )
      :ExecuteCmd( JPLOGNFECreateMySql() )
      :ExecuteCmd( JPNFBASECreateMySql() )
      :ExecuteCmd( JPNFEKEYCreateMySql() )
      :ExecuteCmd( JPPREHISCreateMySql() )
      :ExecuteCmd( JPPROMIXCreateMySql() )
      :ExecuteCmd( JPUSRMSGCreateMySql() )
      FOR nCont = 2008 TO Year( Date() )
         :ExecuteCmd( JPXMLCreateMySql( nCont ) )
      NEXT
      :ExecuteCmd( JPAGENDACreateMySql() )
      :ExecuteCmd( JPCADASCreateMySql() )
      :ExecuteCmd( JPESTOQCreateMySql() )
      :ExecuteCmd( JPFINANCreateMySql() )
      :ExecuteCmd( JPITEMCreateMySql() )
      :ExecuteCmd( JPITPEDCreateMySql() )
      :ExecuteCmd( JPNOTACreateMySql() )
      :ExecuteCmd( JPPEDICreateMySql() )
      :ExecuteCmd( JPTRANSPCreateMySql() )
   ENDWITH
   IF AppVersaoDbfAnt() < 20170602
      WITH OBJECT cnMySql
         IF :TableRecCount( "JPAGENDA" ) == 0
            :ExecuteCmd( "DROP TABLE JPAGENDA" )
            :ExecuteCmd( JPAGENDACreateMySql() )
         ENDIF
         IF :TableRecCount( "JPCADAS" ) == 0
            :ExecuteCmd( "DROP TABLE JPCADAS" )
            :ExecuteCmd( JPCADASCreateMySql() )
         ENDIF
         IF :TableRecCount( "JPESTOQ" ) == 0
            :ExecuteCmd( "DROP TABLE JPESTOQ" )
            :ExecuteCmd( JPESTOQCreateMySql() )
         ENDIF
         IF :TableRecCount( "JPFINAN" ) == 0
            :ExecuteCmd( "DROP TABLE JPFINAN" )
            :ExecuteCmd( JPFINANCreateMySql() )
         ENDIF
         IF :TableRecCount( "JPITEM" ) == 0
            :ExecuteCmd( "DROP TABLE JPITEM" )
            :ExecuteCmd( JPITEMCreateMySql() )
         ENDIF
         IF :TableRecCount( "JPITPED" ) == 0
            :ExecuteCmd( "DROP TABLE JPITPED" )
            :ExecuteCmd( JPITPEDCreateMySql() )
         ENDIF
         IF :TableRecCount( "JPNOTA" ) == 0
            :ExecuteCmd( "DROP TABLE JPNOTA" )
            :ExecuteCmd( JPNOTACreateMySql() )
         ENDIF
         IF :TableRecCount( "JPPEDI" ) == 0
            :ExecuteCmd( "DROP TABLE JPPEDI" )
            :ExecuteCmd( JPPEDICreateMySql() )
         ENDIF
         IF :TableRecCount( "JPTRANSP" ) == 0
            :ExecuteCmd( "DROP TABLE JPTRANSP" )
            :ExecuteCmd( JPTRANSPCreateMySql() )
         ENDIF
      ENDWITH
   ENDIF
   IF AppVersaoDbfAnt() < 20170815
      WITH OBJECT cnMySql
         :ExecuteCmd( "ALTER TABLE JPCONFI CHANGE COLUMN CNF_NOME CNF_NOME VARCHAR(40) NULL DEFAULT ''" )
         :ExecuteCmd( "ALTER TABLE JPCONFI CHANGE COLUMN CNF_PARAM CNF_PARAM VARCHAR(80) NULL DEFAULT ''" )
      ENDWITH
   ENDIF
   IF AppVersaoDbfAnt() < 20170922
      WITH OBJECT cnMySql
         :DeleteField( "IEQTDFIS",   "JPITEM" )
         :DeleteField( "IESLDFIS",   "JPITEM" )
         :DeleteField( "IEDIGFIS",   "JPITEM" )
         :DeleteField( "IEQTDRMA",   "JPITEM" )
         :DeleteField( "IEDIVERSOS", "JPITEM" )
         :DeleteField( "IEDESCNF",   "JPITEM" )
         :DeleteField( "IEBACKUP",   "JPITEM" )
         :DeleteField( "FIBACKUP",   "JPFINAN" )
         :DeleteField( "NFBACKUP",   "JPNOTA" )
         :DeleteField( "ESBACKUP",   "JPESTOQ" )
         :DeleteField( "IPBACKUP",   "JPITPED" )
         :DeleteField( "PDBACKUP",   "JPPEDI" )
         :DeleteField( "ESRECALC",   "JPESTOQ" )
         :DeleteField( "ESSLDVAL",   "JPESTOQ" )
         :DeleteField( "ESCCUSTD",   "JPESTOQ" )
         :DeleteField( "ESSDQTD",    "JPESTOQ" )
      ENDWITH
   ENDIF
   IF AppVersaoDbfAnt() < 20180126
      WITH OBJECT cnMySql
         IF ! :FieldExists( "IENCM", "JPITEM" )
            :ExecuteCmd( "ALTER TABLE JPITEM CHANGE COLUMN IECODNCM IENCM VARCHAR(8) NULL DEFAULT ''" )
         ENDIF
         IF ! :FieldExists( "IEGTIN", "JPITEM" )
            :ExecuteCmd( "ALTER TABLE JPITEM ADD COLUMN IEGTIN VARCHAR(14) NULL DEFAULT ''" )
         ENDIF
         IF ! :FieldExists( "IEGTINTRI", "JPITEM" )
            :ExecuteCmd( "ALTER TABLE JPITEM ADD COLUMN IEGTINTRI VARCHAR(14) NULL DEFAULT ''" )
         ENDIF
         IF ! :FieldExists( "IEGTINQTD", "JPITEM" )
            :ExecuteCmd( "ALTER TABLE JPITEM ADD COLUMN IEGTINQTD INT(3) DEFAULT 1" )
         ENDIF
      END WITH
   ENDIF
   IF AppVersaoDbfAnt() < 20180209
      WITH OBJECT cnMySql
         IF ! :FieldExists( "IERES2", "JPITEM" )
            :ExecuteCmd( "ALTER TABLE JPITEM ADD COLUMN IERES2 DOUBLE(14,3) NOT NULL DEFAULT '0'" )
         ENDIF
         IF ! :FieldExists( "IERES3", "JPITEM" )
            :ExecuteCmd( "ALTER TABLE JPITEM ADD COLUMN IERES3 DOUBLE(14,3) NOT NULL DEFAULT '0'" )
         ENDIF
         IF :FieldExists( "IERES4", "JPITEM" )
            :ExecuteCmd( "ALTER TABLE JPITEM DROP COLUMN IERES4" )
         ENDIF
         IF :FieldExists( "IERES5", "JPITEM" )
            :ExecuteCmd( "ALTER TABLE JPITEM DROP COLUMN IERES5" )
         ENDIF
         IF :FieldExists( "IEQTDE", "JPITEM" )
            :ExecuteCmd( "ALTER TABLE JPITEM CHANGE COLUMN IEQTD IEQTD1 DOUBLE(14,3) NOT NULL DEFAULT '0'"  )
         ENDIF
         IF :FieldExists( "IERESERVA", "JPITEM" )
            :ExecuteCmd( "ALTER TABLE JPITEM CHANGE COLUMN IERESERVA IERES1 DOUBLE(14,3) NOT NULL DEFAULT '0'" )
         ENDIF
      END WITH
   ENDIF
   IF AppVersaoDbfAnt() < 20180217
      IF cnMySql:FieldExists( "PDDEMFIN", "JPPEDIDO" )
         cnMySql:ExecuteCmd( "ALTER TABLE JPPEDI DROP COLUMN PDDEMFIN" )
      ENDIF
   ENDIF

   RETURN NIL

   // Not Static - called from other routines

FUNCTION JPREGUSOCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPREGUSO ( " + ;
      "RUID      INT(9)       NOT NULL AUTO_INCREMENT, " + ;
      "RUARQUIVO VARCHAR(15)  NOT NULL DEFAULT '', " + ;
      "RUCODIGO  VARCHAR(9)   NOT NULL DEFAULT '', " + ;
      "RUTEXTO   VARCHAR(100) NOT NULL DEFAULT '', " + ;
      "RUINFINC  VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY ( RUID ), " + ;
      "INDEX ARQUIVOCODIGO ( RUARQUIVO, RUCODIGO, RUID ) ) " + ;
      "COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPBARRACreateMySql()

   RETURN "CREATE TABLE IF NOT EXISTS JPBARRA ( " + ;
      "BRID      INT(9)      NOT NULL AUTO_INCREMENT, " + ;
      "BRNUMLAN  VARCHAR(6)  NULL DEFAULT '', " + ;
      "BRCODBAR  VARCHAR(22) NULL DEFAULT '', " + ;
      "BRCODBAR2 VARCHAR(22) NULL DEFAULT '', " + ;
      "BRITEM    VARCHAR(6)  NULL DEFAULT '', " + ;
      "BRPEDCOM  VARCHAR(6)  NULL DEFAULT '', " + ;
      "BRGARCOM  DATE        NULL DEFAULT NULL, " + ;
      "BRGARVEN  DATE        NULL DEFAULT NULL, " + ;
      "BRPEDVEN  VARCHAR(6)  NULL DEFAULT '', " + ;
      "BRINFCOM  VARCHAR(60) NULL DEFAULT '', " + ;
      "BRINFVEN  VARCHAR(60) NULL DEFAULT '', " + ;
      "BRINFINC  VARCHAR(80) NULL DEFAULT '', " + ;
      "BRINFALT  VARCHAR(80) NULL DEFAULT '', " + ;
      "PRIMARY KEY   ( BRID ), " + ;
      "INDEX NUMLAN  ( BRNUMLAN ), " + ; // sem unique pra evitar erro de conversão
      "INDEX CODBAR1 ( BRCODBAR, BRNUMLAN ), " + ;
      "INDEX CODBAR2 ( BRCODBAR2, BRNUMLAN ), " + ;
      "INDEX PEDVEN  ( BRPEDVEN, BRITEM, BRCODBAR, BRNUMLAN ), " + ;
      "INDEX PEDCOM  ( BRPEDCOM, BRITEM, BRCODBAR, BRNUMLAN ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

   // Esta é chamada de fora deste fonte

FUNCTION JPCONFICreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPCONFI ( " + ;
      "SSID      INT(9)      NOT NULL AUTO_INCREMENT, " + ;
      "CNF_NOME  VARCHAR(40) NULL DEFAULT '', " + ;
      "CNF_PARAM VARCHAR(80) NULL DEFAULT '', " + ;
      "SSINFINC  VARCHAR(80) NULL DEFAULT '', " + ;
      "SSINFALT  VARCHAR(80) NULL DEFAULT '', " + ;
      "PRIMARY KEY ( SSID ), " + ;
      "INDEX NOME ( CNF_NOME ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPDECRETCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPDECRET ( " + ;
      "DEID     INT(9)      NOT NULL AUTO_INCREMENT, " + ;
      "DENUMLAN VARCHAR(6)  NULL DEFAULT '', " + ;
      "DENOME   VARCHAR(30) NULL DEFAULT '', " + ;
      "DEDESCR1 TEXT        NULL, " + ;
      "DEDESCR2 TEXT        NULL, " + ;
      "DEDESCR3 TEXT        NULL, " + ;
      "DEDESCR4 TEXT        NULL, " + ;
      "DEDESCR5 TEXT        NULL, " + ;
      "DEINFINC VARCHAR(80) NULL DEFAULT '', " + ;
      "DEINFALT VARCHAR(80) NULL DEFAULT '', " + ;
      "PRIMARY KEY ( DEID ), " + ;
      "INDEX NUMLAN ( DENUMLAN ), " + ; // sem unique pra evitar erro de conversão
      "INDEX NOME ( DENOME ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPIBPTCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPIBPT ( " + ;
      "IBID      INT(9)      NOT NULL AUTO_INCREMENT, " + ;
      "IBCODIGO  VARCHAR(8)  NULL DEFAULT '', " + ;
      "IBEXCECAO VARCHAR(2)  NULL DEFAULT '', " + ;
      "IBNCMNBS  VARCHAR(1)  NULL DEFAULT '', " + ;
      "IBUF      VARCHAR(2)  NULL DEFAULT '', " + ;
      "IBNACALI  DOUBLE(7,2) NULL DEFAULT '0.00', " + ;
      "IBIMPALI  DOUBLE(7,2) NULL DEFAULT '0.00', " + ;
      "IBALIFEDN DOUBLE(7,2) NULL DEFAULT '0.00', " + ;
      "IBALIFEDI DOUBLE(7,2) NULL DEFAULT '0.00', " + ;
      "IBALIEST  DOUBLE(7,2) NULL DEFAULT '0.00', " + ;
      "IBALIMUN  DOUBLE(7,2) NULL DEFAULT '0.00', " + ;
      "IBINFINC  VARCHAR(80) NULL DEFAULT '', " + ;
      "IBINFALT  VARCHAR(80) NULL DEFAULT '', " + ;
      "PRIMARY KEY ( IBID ), " + ;
      "INDEX NUMLAN ( IBCODIGO, IBNCMNBS, IBUF ) " + ; // sem unique pra evitar erro de conversão
      ") " + ;
      "COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPPROMIXCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPPROMIX ( " + ;
      "PTID      INT(9)      NOT NULL AUTO_INCREMENT, " + ;
      "PTPRODUTO VARCHAR(6)  NULL DEFAULT '', " + ;
      "PTORDEM   VARCHAR(2)  NULL DEFAULT '', " + ;
      "PTITEM    VARCHAR(6)  NULL DEFAULT '', " + ;
      "PTQTDE    INT(6)      NULL DEFAULT '0', " + ;
      "PTINFINC  VARCHAR(80) NULL DEFAULT '', " + ;
      "PTINFALT  VARCHAR(80) NULL DEFAULT '', " + ;
      "PRIMARY KEY ( PTID ), " + ;
      "INDEX PRODUTOITEM ( PTPRODUTO, PTITEM ), " + ;
      "INDEX ITEMPRODUTO ( PTITEM, PTPRODUTO ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPUSRMSGCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPUSRMSG ( "+ ;
      "MSNUMLAN   INT(9)       NOT NULL AUTO_INCREMENT, " + ;
      "MSEMPRESA  CHAR(10)     NOT NULL DEFAULT '', " + ;
      "MSFROM     CHAR(10)     NOT NULL DEFAULT '', " + ;
      "MSTO       CHAR(10)     NOT NULL DEFAULT '', " + ;
      "MSTEXT     TEXT         NULL, " + ;
      "MSDATEFROM VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "MSDATETO   VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "MSANEXO    VARCHAR(30)  NOT NULL DEFAULT '', " + ;
      "MSOKFROM   CHAR(1) NOT  NULL     DEFAULT 'N', " + ;
      "MSOKTO     CHAR(1) NOT  NULL     DEFAULT 'N', " + ;
      "MSINFINC   VARCHAR(100) NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY ( MSNUMLAN ), " + ;
      "INDEX DESTINATARIO ( MSEMPRESA, MSTO, MSOKTO, MSDATETO ), " + ;
      "INDEX USUARIO ( MSEMPRESA, MSFROM, MSOKFROM, MSDATETO ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPXMLCreateMySql( nAno )

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPXML" + StrZero( nAno, 4 ) + " ( " + ;
      "XXCHAVE VARCHAR(44) NOT NULL DEFAULT '', " + ;
      "XXORDEM VARCHAR(2) NOT NULL DEFAULT '  ', " + ;
      "XXXML MEDIUMTEXT NULL, " + ;
      "XXBACKUP CHAR(1) NOT NULL DEFAULT ' ', " + ;
      "XXINFINC VARCHAR(100) NOT NULL DEFAULT ' ', " + ;
      "XXEVENTO VARCHAR(15) NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY ( XXCHAVE, XXORDEM, XXEVENTO ), " + ;
      "INDEX BACKUP ( XXBACKUP, XXCHAVE, XXORDEM, XXEVENTO ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPNFEKEYCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPNFEKEY ( " + ;
      "KKCHAVE    CHAR(44) NOT NULL DEFAULT '', " + ;
      "KKDATEMI   DATE NULL DEFAULT NULL, " + ;
      "KKEMINFE   CHAR(18) NOT NULL DEFAULT '', " + ;
      "KKDESNFE   CHAR(18) NOT NULL DEFAULT '', " + ;
      "KKREMNFE   CHAR(18) NOT NULL DEFAULT '', " + ;
      "KKMODFIS   VARCHAR(6) NOT NULL DEFAULT '', " + ;
      "KKNOTFIS   CHAR(9) NOT NULL DEFAULT '', " + ;
      "KKENVEMA   CHAR(1) NOT NULL DEFAULT 'N', " + ;
      "KKBACKUP   CHAR(1) NOT NULL DEFAULT 'S', " + ;
      "KKCONVERTE CHAR(1) NOT NULL DEFAULT 'N', " + ;
      "KKSTATUS   CHAR(3) NOT NULL DEFAULT '100', " + ;
      "KKINFINC   VARCHAR(100) NOT NULL DEFAULT '', "+ ;
      "PRIMARY KEY    ( KKCHAVE ), " + ;
      "INDEX BACKUP   ( KKBACKUP, KKCHAVE ), " + ;
      "INDEX KKEMINFE ( KKEMINFE, KKMODFIS, KKNOTFIS, KKCHAVE ), " + ;
      "INDEX CONVERTE ( KKCONVERTE, KKDATEMI, KKCHAVE ), " + ;
      "INDEX DATEMI   ( KKDATEMI ) USING BTREE, " + ;
      "INDEX NOTFIS   ( KKNOTFIS, KKMODFIS, KKCHAVE ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPEMANFECreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPEMANFE ( " + ;
      "IDEMANFE INT(11)      NOT NULL AUTO_INCREMENT, " + ;
      "ENEMINFE CHAR(18)     NOT NULL DEFAULT '', " + ;
      "ENDESNFE CHAR(18)     NOT NULL, " + ;
      "ENEMANFE VARCHAR(200) NULL DEFAULT '', " + ;
      "ENBACKUP CHAR(1) NULL DEFAULT 'S', " + ;
      "ENINFINC VARCHAR(100) NULL DEFAULT '', " + ;
      "ENINFALT VARCHAR(100) NULL DEFAULT '', " + ;
      "PRIMARY KEY  ( IDEMANFE ), " + ;
      "INDEX INDICE ( ENEMINFE, ENDESNFE ) " + ; // sem unique pra evitar erro de conversão
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPLOGNFECreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPLOGNFE ( "+ ;
      "IDLOGNFE INT(11)      NOT NULL AUTO_INCREMENT, " + ;
      "LNCHAVE  CHAR(44)     NOT NULL DEFAULT '', " + ;
      "LNEMANFE VARCHAR(250) NULL DEFAULT '', " + ;
      "LNINFMOV VARCHAR(100) NULL DEFAULT '', " + ;
      "LNBACKUP CHAR(1) NULL DEFAULT 'S', " + ;
      "LNINFINC VARCHAR(100) NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY  ( IDLOGNFE ), " + ;
      "INDEX INDICE ( LNCHAVE, IDLOGNFE ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPLICMOVCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPLICMOV ( " + ;
      "LCID      INT(11)   NOT NULL AUTO_INCREMENT, " + ;
      "LCNUMLAN  CHAR(6)   NOT NULL DEFAULT '', " + ;
      "LCLICOBJ  CHAR(6)   NOT NULL DEFAULT '', " + ;
      "LCDESCRI1 CHAR(100) NOT NULL DEFAULT '', " + ;
      "LCDESCRI2 CHAR(100) NOT NULL DEFAULT '', " + ;
      "LCDESCRI3 CHAR(100) NOT NULL DEFAULT '', " + ;
      "LCDESCRI4 CHAR(100) NOT NULL DEFAULT '', " + ;
      "LCDESCRI5 CHAR(100) NOT NULL DEFAULT '', " + ;
      "LCLICNUM  CHAR(96)  NOT NULL DEFAULT '', " + ;
      "LCLICDAT  CHAR(96)  NOT NULL DEFAULT '', " + ;
      "LCINFINC  CHAR(80)  NOT NULL DEFAULT '', " + ;
      "LCINFALT  CHAR(80)  NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY     ( LCID ), " + ;
      "INDEX IDXNUMLAN ( LCNUMLAN, LCID ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPEDICFGCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPEDICFG ( " + ;
      "EDID      INT(11)     NOT NULL AUTO_INCREMENT, " + ;
      "EDNUMLAN  VARCHAR(6)  NOT NULL DEFAULT '', " + ;
      "EDTIPO    VARCHAR(6)  NOT NULL DEFAULT '', " + ;
      "EDCODJPA  VARCHAR(6)  NOT NULL DEFAULT '', " + ;
      "EDCODEDI1 VARCHAR(20) NOT NULL DEFAULT '', " + ;
      "EDCODEDI2 VARCHAR(20) NOT NULL DEFAULT '', " + ;
      "EDDESEDI  VARCHAR(50) NOT NULL DEFAULT '', " + ;
      "EDINFINC  VARCHAR(80) NOT NULL DEFAULT '', " + ;
      "EDINFALT  VARCHAR(80) NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY       ( EDID ), " + ;
      "INDEX IDXJPEDICFG ( EDNUMLAN, EDID ), " + ;
      "INDEX IDXEDI      ( EDTIPO, EDCODEDI1, EDCODEDI2, EDNUMLAN ), " + ;
      "INDEX IDXJPA      ( EDTIPO, EDCODJPA, EDCODEDI1, EDNUMLAN ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPNFBASECreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPNFBASE ( " + ;
      "NBID       INT(11)     NOT NULL AUTO_INCREMENT, " + ;
      "NBNUMLAN   VARCHAR(6)  NOT NULL DEFAULT '', " + ;
      "NBNOME     VARCHAR(40) NOT NULL DEFAULT '', " + ;
      "NBENDERECO VARCHAR(50) NOT NULL DEFAULT '', " + ;
      "NBBAIRRO   VARCHAR(20) NOT NULL DEFAULT '', " + ;
      "NBCIDADE   VARCHAR(20) NOT NULL DEFAULT '', " + ;
      "NBUF       VARCHAR(2)  NOT NULL DEFAULT '', " + ;
      "NBCEP      VARCHAR(9)  NOT NULL DEFAULT '', " + ;
      "NBINFINC   VARCHAR(80) NOT NULL DEFAULT '', " + ;
      "NBINFALT   VARCHAR(80) NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY    ( NBID ), " + ;
      "INDEX NUMLAN   ( NBNUMLAN ), " + ;
      "INDEX NOME     ( NBNOME ), " + ;
      "INDEX ENDERECO ( NBENDERECO, NBNUMLAN ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPFISICACreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPFISICA ( " + ;
      "FSID      INT(11)      NOT NULL AUTO_INCREMENT, " + ;
      "FSITEM    VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "FSDESCRI  VARCHAR(60)  NOT NULL DEFAULT '', " + ;
      "FSPRODEP  VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "FSLOCAL   VARCHAR(10)  NOT NULL DEFAULT '', " + ;
      "FSDATA    DATE         NULL, " + ;
      "FSQTDDIG1 DOUBLE(16,4) NOT NULL DEFAULT '0', " + ;
      "FSQTDDIG2 DOUBLE(16,4) NOT NULL DEFAULT '0', " + ;
      "FSQTDDIG3 DOUBLE(16,4) NOT NULL DEFAULT '0', " + ;
      "FSQTDDIG4 DOUBLE(16,4) NOT NULL DEFAULT '0', " + ;
      "FSQTDJPA1 DOUBLE(16,4) NOT NULL DEFAULT '0', " + ;
      "FSQTDJPA2 DOUBLE(16,4) NOT NULL DEFAULT '0', " + ;
      "FSQTDJPA3 DOUBLE(16,4) NOT NULL DEFAULT '0', " + ;
      "FSQTDJPA4 DOUBLE(16,4) NOT NULL DEFAULT '0', " + ;
      "FSSTATUS  CHAR(1)      NOT NULL DEFAULT ' ', " + ;
      "FSINFINC  VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "FSINFALT  VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY      ( FSID ), " + ;
      "INDEX IDXDATA    ( FSDATA, FSITEM, FSDESCRI ), " + ;
      "INDEX IDXITEM    ( FSITEM, FSDESCRI, FSDATA ), " + ;
      "INDEX IDXANALISE ( FSITEM, FSDATA, FSDESCRI ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPPREHISCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPPREHIS ( " + ;
      "PHID     INT(11)      NOT NULL AUTO_INCREMENT, " + ;
      "PHITEM   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "PHCADAS  VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "PHFORPAG VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "PHDATA   DATE         NULL, " + ;
      "PHHORA   VARCHAR(8)   NOT NULL DEFAULT '', " + ;
      "PHVALOR  DOUBLE(16,4) NOT NULL DEFAULT '0.0', " + ;
      "PHOBS    VARCHAR(60)  NOT NULL DEFAULT '', " + ;
      "PHINFINC VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "PHINFALT VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY    ( PHID ), " + ;
      "INDEX IDXITEM  ( PHITEM, PHCADAS, PHFORPAG, PHDATA DESC, PHHORA DESC ), " + ;
      "INDEX IDXCADAS ( PHCADAS, PHITEM, PHFORPAG, PHDATA ), " + ;
      "INDEX IDXDATA  ( PHDATA, PHITEM, PHCADAS, PHFORPAG ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPCADASCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPCADAS ( " + ;
      "CDID       INT(11)      NOT NULL AUTO_INCREMENT, " + ;
      "CDCODIGO   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "CDNOME     VARCHAR(50)  NOT NULL DEFAULT '', " + ;
      "CDAPELIDO  VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDCNPJ     VARCHAR(18)  NOT NULL DEFAULT '', " + ;
      "CDDIVISAO  VARCHAR(3)   NOT NULL DEFAULT '', " + ;
      "CDGRUPO    VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "CDOUTDOC   VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDENDERECO VARCHAR(40)  NOT NULL DEFAULT '', " + ;
      "CDNUMERO   VARCHAR(10)  NOT NULL DEFAULT '', " + ;
      "CDCOMPL    VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDBAIRRO   VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDCIDADE   VARCHAR(21)  NOT NULL DEFAULT '', " + ;
      "CDUF       VARCHAR(2)   NOT NULL DEFAULT '', " + ;
      "CDCEP      VARCHAR(9)   NOT NULL DEFAULT '', " + ;
      "CDCNAE     VARCHAR(7)   NOT NULL DEFAULT '', " + ;
      "CDMAPA     VARCHAR(50)  NOT NULL DEFAULT '', " + ;
      "CDTELEFONE VARCHAR(30)  NOT NULL DEFAULT '', " + ;
      "CDINSEST   VARCHAR(18)  NOT NULL DEFAULT '', " + ;
      "CDCONTRIB  VARCHAR(1)   NOT NULL DEFAULT '', " + ;
      "CDCONTATO  VARCHAR(30)  NOT NULL DEFAULT '', " + ;
      "CDTELEF2   VARCHAR(15)  NOT NULL DEFAULT '', " + ;
      "CDTELEF3   VARCHAR(15)  NOT NULL DEFAULT '', " + ;
      "CDFAX      VARCHAR(30)  NOT NULL DEFAULT '', " + ;
      "CDEMAIL    VARCHAR(250) NOT NULL DEFAULT '', " + ;
      "CDEMANFE   VARCHAR(250) NOT NULL DEFAULT '', " + ;
      "CDEMACON   VARCHAR(250) NOT NULL DEFAULT '', " + ;
      "CDDATNAS   DATE         NULL, " + ;
      "CDMIDIA    VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "CDHOMEPAGE VARCHAR(100) NOT NULL DEFAULT '', " + ;
      "CDENDCOB   VARCHAR(40)  NOT NULL DEFAULT '', " + ;
      "CDNUMCOB   VARCHAR(10)  NOT NULL DEFAULT '', " + ;
      "CDCOMCOB   VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDBAICOB   VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDCIDCOB   VARCHAR(21)  NOT NULL DEFAULT '', " + ;
      "CDUFCOB    VARCHAR(2)   NOT NULL DEFAULT '', " + ;
      "CDCEPCOB   VARCHAR(9)   NOT NULL DEFAULT '', " + ;
      "CDCONCOB   VARCHAR(30)  NOT NULL DEFAULT '', " + ;
      "CDTELCOB   VARCHAR(30)  NOT NULL DEFAULT '', " + ; // 10 caracteres
      "CDFAXCOB   VARCHAR(30)  NOT NULL DEFAULT '', " + ; // 10 caracteres
      "CDFORPAG   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "CDNOMENT   VARCHAR(40)  NOT NULL DEFAULT '', " + ;
      "CDENDENT   VARCHAR(40)  NOT NULL DEFAULT '', " + ;
      "CDNUMENT   VARCHAR(10)  NOT NULL DEFAULT '', " + ;
      "CDCOMENT   VARCHAR(60)  NOT NULL DEFAULT '', " + ;
      "CDBAIENT   VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDCIDENT   VARCHAR(21)  NOT NULL DEFAULT '', " + ;
      "CDUFENT    VARCHAR(2)   NOT NULL DEFAULT '', " + ;
      "CDCEPENT   VARCHAR(9)   NOT NULL DEFAULT '', " + ;
      "CDCONENT   VARCHAR(30)  NOT NULL DEFAULT '', " + ;
      "CDTELENT   VARCHAR(30)  NOT NULL DEFAULT '', " + ; // 10 caracters
      "CDFAXENT   VARCHAR(30)  NOT NULL DEFAULT '', " + ;
      "CDVENDEDOR VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "CDPORTADOR VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "CDLIMCRE   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "CDTIPO     VARCHAR(1)   NOT NULL DEFAULT ' ', " + ;
      "CDCTACON   VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDCTAJUR   VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDCTADES   VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDVALMES   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "CDTRANSP   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "CDOBS      VARCHAR(100) NOT NULL DEFAULT '', " + ;
      "CDTRICAD   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "CDSITNFE   VARCHAR(1)   NOT NULL DEFAULT ' ', " + ;
      "CDSITFAZ   VARCHAR(1)   NOT NULL DEFAULT ' ', " + ;
      "CDSTATUS   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "CDINFINC   VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "CDINFALT   varchar(80)  NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY    ( CDID ), " + ;
      "INDEX IDXCADAS1 ( CDCODIGO ), " + ;
      "INDEX IDXCADAS2 ( CDNOME, CDCODIGO ), " + ;
      "INDEX IDXCADAS3 ( CDCNPJ, CDDIVISAO, CDCODIGO ), " + ;
      "INDEX IDXCADAS4 ( CDAPELIDO, CDCODIGO ), " + ;
      "INDEX IDXTELEF  ( CDTELEFONE, CDCODIGO ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPAGENDACreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPAGENDA ( " + ;
      "CDID       INT(11)      NOT NULL AUTO_INCREMENT, " + ;
      "CDCODIGO   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "CDNOME     VARCHAR(50)  NOT NULL DEFAULT '', " + ;
      "CDENDERECO VARCHAR(40)  NOT NULL DEFAULT '', " + ;
      "CDBAIRRO   VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDCIDADE   VARCHAR(21)  NOT NULL DEFAULT '', " + ;
      "CDUF       VARCHAR(2)   NOT NULL DEFAULT '', " + ;
      "CDCEP      VARCHAR(9)   NOT NULL DEFAULT '', " + ;
      "CDTELEFONE VARCHAR(30)  NOT NULL DEFAULT '', " + ;
      "CDTELEF2   VARCHAR(15)  NOT NULL DEFAULT '', " + ;
      "CDTELEF3   VARCHAR(15)  NOT NULL DEFAULT '', " + ;
      "CDFAX      VARCHAR(30)  NOT NULL DEFAULT '', " + ;
      "CDEMAIL    VARCHAR(250) NOT NULL DEFAULT '', " + ;
      "CDOBS      VARCHAR(100) NOT NULL DEFAULT '', " + ;
      "CDINFINC   VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "CDINFALT   varchar(80)  NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY    ( CDID ), " + ;
      "INDEX IDXNUMLAN ( CDCODIGO ), " + ;
      "INDEX IDXNOME   ( CDNOME, CDCODIGO ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPPEDICreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPPEDI ( " + ;
      "PDID       INT(11)      NOT NULL AUTO_INCREMENT, " + ;
      "PDPEDIDO   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "PDPEDREL   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "PDNOTREL   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "PDFILIAL   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "PDTRANSA   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "PDCONF     CHAR(1)      NOT NULL DEFAULT ' ', " + ;
      "PDDATEMI   DATE         NULL, " + ;
      "PDDATNOT   DATE         NULL, " + ; // 06/04/10
      "PDDATPRE   DATE         NULL, " + ;
      "PDCLIFOR   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "PDNOTFIS   VARCHAR(9)   NOT NULL DEFAULT '', " + ;
      "PDPERDES   DOUBLE(5,2)  NOT NULL DEFAULT '0', " + ;
      "PDPERADI   DOUBLE(5,2)  NOT NULL DEFAULT '0', " + ;
      "PDCONTATO  VARCHAR(60)  NOT NULL DEFAULT '', " + ;
      "PDVENDEDOR VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "PDPEDCLI   VARCHAR(25)  NOT NULL DEFAULT '', " + ;
      "PDVALTAB   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDVALCUS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDVALCUT   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDVALPRO   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDVALNOT   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDVALFRE   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDVALSEG   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDVALOUT   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDVALDES   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDVALADI   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDVALADU   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDVALIOF   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDPARCEL   VARCHAR(250) NOT NULL DEFAULT '', " + ;
      "PDDOLAR    DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDREACAO   VARCHAR(60)  NOT NULL DEFAULT '', " + ;
      "PDIIBAS    DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDIIVAL    DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDIPIBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDIPIVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDICMBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDICMVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDSUBBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDSUBVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDDIFCAL   CHAR(1)      NOT NULL DEFAULT ' ', " + ;
      "PDDIFVALI  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDDIFVALF  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDISSBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDISSVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDPISBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDPISVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDCOFBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDCOFVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDICSBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDICSALI   DOUBLE(5,2)  NOT NULL DEFAULT '0', " + ;
      "PDICSVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDIMPVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "PDDATCON   DATE         NULL, " + ;
      "PDDATCAN   DATE         NULL, " + ;
      "PDMOTCAN   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "PDTRANSP   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "PDFORPAG   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "PDEMAIL    VARCHAR(200) NOT NULL DEFAULT '', " + ;
      "PDOBS      VARCHAR(200) NOT NULL DEFAULT '', " + ;
      "PDLEIS     VARCHAR(140) NOT NULL DEFAULT '', " + ;
      "PDSTATUS   CHAR(1)      NOT NULL DEFAULT ' ', " + ;
      "PDINFINC   VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "PDINFALT   VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY ( PDID ), " + ;
      "INDEX IDXPEDIDO ( PDPEDIDO ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPITPEDCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPITPED ( " + ;
      "IPID       INT(11)      NOT NULL AUTO_INCREMENT, " + ;
      "IPPEDIDO   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IPFILIAL   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IPITEM     VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IPSEQ      VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IPPRECUS   DOUBLE(15,5) NOT NULL DEFAULT '0', " + ;
      "IPPREPED   DOUBLE(15,5) NOT NULL DEFAULT '0', " + ;
      "IPCFOP     VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IPQTDE     DOUBLE(14,3) NOT NULL DEFAULT '0', " + ;
      "IPQTDEF    DOUBLE(14,3) NOT NULL DEFAULT '0', " + ;
      "IPPEDCOM   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IPTRIBUT   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IPVALTAB   DOUBLE(15,5) NOT NULL DEFAULT '0', " + ;
      "IPVALCUS   DOUBLE(15,5) NOT NULL DEFAULT '0', " + ;
      "IPVALCUT   DOUBLE(15,5) NOT NULL DEFAULT '0', " + ;
      "IPGARANTIA INT(3)       NOT NULL DEFAULT '0', " + ;
      "IPPRENOT   DOUBLE(15,5) NOT NULL DEFAULT '0', " + ;
      "IPVALADI   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPVALFRE   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPVALSEG   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPVALOUT   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPVALADU   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPVALIOF   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPVALDES   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPVALPRO   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPVALNOT   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPLEIS     VARCHAR(70)  NOT NULL DEFAULT '', " + ;
      "IPORIMER   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IPIIBAS    DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPIIALI    DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "IPIIVAL    DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPIPICST   VARCHAR(2)   NOT NULL DEFAULT '', " + ;
      "IPIPIBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPIPIALI   DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "IPIPIVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPIPIICM   CHAR(1)      NOT NULL DEFAULT ' ', " + ;
      "IPIPIENQ   VARCHAR(3)   NOT NULL DEFAULT '', " + ;
      "IPICMCST   VARCHAR(4)   NOT NULL DEFAULT '', " + ;
      "IPICMBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPICMALI   DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "IPICMRED   DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "IPICMVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPICSBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPICSALI   DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "IPICSVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPSUBIVA   DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "IPSUBBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPSUBRED   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPSUBALI   DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "IPSUBVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPDIFCAL   VARCHAR(1)   NOT NULL DEFAULT ' ', " + ;
      "IPDIFBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPDIFALIF  DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "IPDIFALIU  DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "IPDIFALII  DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "IPDIFVALI  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPDIFVALF  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPPISBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPPISALI   DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "IPPISVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPPISCST   VARCHAR(2)   NOT NULL DEFAULT '', " + ;
      "IPPISENQ   VARCHAR(3)   NOT NULL DEFAULT '', " + ;
      "IPCOFBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPCOFALI   DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "IPCOFVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPCOFCST   VARCHAR(2)   NOT NULL DEFAULT '', " + ;
      "IPCOFENQ   VARCHAR(3)   NOT NULL DEFAULT '', " + ;
      "IPISSBAS   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPISSALI   DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "IPISSVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPIMPALI   DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "IPIMPVAL   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "IPINFINC   VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "IPINFALT   VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY ( IPID ), " + ;
      "INDEX IDXPEDIDO ( IPPEDIDO, IPITEM, IPSEQ ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPESTOQCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPESTOQ ( " + ;
      "ESID     INT(11)      NOT NULL AUTO_INCREMENT, " + ;
      "ESNUMLAN VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "ESFILIAL VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "ESDATLAN DATE         NULL, " + ;
      "ESTIPLAN CHAR(1)      NOT NULL DEFAULT ' ', " + ;
      "ESCLIFOR VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "ESTIPDOC VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "ESTRANSA VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "ESNUMDOC VARCHAR(9)   NOT NULL DEFAULT '', " + ;
      "ESITEM   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "ESQTDE   DOUBLE(14,3) NOT NULL DEFAULT '0', " + ;
      "ESVALOR  DOUBLE(15,5) NOT NULL DEFAULT '0', " + ;
      "ESNUMDEP CHAR(1)      NOT NULL DEFAULT ' ', " + ;
      "ESCCUSTO VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "ESDOCSER VARCHAR(2)   NOT NULL DEFAULT '', " + ;
      "ESCFOP   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "ESCCONTA VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "ESPEDIDO VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "ESOBS    VARCHAR(100) NOT NULL DEFAULT '', " + ;
      "ESINFINC VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "ESINFALT VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY ( ESID ), " + ;
      "INDEX IDXNUMLAN ( ESNUMLAN, ESTIPLAN ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPNOTACreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPNOTA ( " + ;
      "NFID      INT(11)      NOT NULL AUTO_INCREMENT, " + ;
      "NFNUMLAN  VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "NFFILIAL  VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "NFNOTFIS  VARCHAR(9)   NOT NULL DEFAULT '', " + ;
      "NFDATEMI  DATE         NULL, " + ;
      "NFHOREMI  VARCHAR(8)   NOT NULL DEFAULT '', " + ;
      "NFTRANSA  VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "NFCADDES  VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "NFVALPRO  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFVALNOT  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFVALFRE  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFVALSEG  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFVALOUT  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFVALDES  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFVALADU  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFVALIOF  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFIPIBAS  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFIPIVAL  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFICMBAS  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFICMVAL  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFSUBBAS  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFSUBVAL  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFDIFCAL  VARCHAR(1)   NOT NULL DEFAULT '', " + ;
      "NFDIFVALI DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFDIFVALF DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFPISBAS  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFPISVAL  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFCOFBAS  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFCOFVAL  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFISSBAS  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFISSVAL  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFICSBAS  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFICSALI  DOUBLE(6,2)  NOT NULL DEFAULT '0', " + ;
      "NFICSVAL  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFIMPVAL  DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "NFDATSAI  DATE         NULL, " + ;
      "NFHORSAI  VARCHAR(8)   NOT NULL DEFAULT '', " + ;
      "NFPESBRU  DOUBLE(8,2)  NOT NULL DEFAULT '0', " + ;
      "NFPESLIQ  DOUBLE(8,2)  NOT NULL DEFAULT '0', " + ;
      "NFCADTRA  VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "NFVEICULO VARCHAR(10)  NOT NULL DEFAULT '', " + ;
      "NFESPECIE VARCHAR(10)  NOT NULL DEFAULT '', " + ;
      "NFQTDVOL  INT(10)      NOT NULL DEFAULT '0', " + ;
      "NFCFOP    VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "NFCFOP2   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "NFPAGFRE  VARCHAR(1)   NOT NULL DEFAULT '', " + ;
      "NFSTATUS  VARCHAR(1)   NOT NULL DEFAULT '', " + ;
      "NFOBS1    VARCHAR(250) NOT NULL DEFAULT '', " + ;
      "NFOBS2    VARCHAR(250) NOT NULL DEFAULT '', " + ;
      "NFOBS3    VARCHAR(250) NOT NULL DEFAULT '', " + ;
      "NFOBS4    VARCHAR(250) NOT NULL DEFAULT '', " + ;
      "NFLEIS    VARCHAR(140) NOT NULL DEFAULT '', " + ;
      "NFPEDIDO  VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "NFCTE     VARCHAR(44)  NOT NULL DEFAULT '', " + ;
      "NFNFE     VARCHAR(44)  NOT NULL DEFAULT '', " + ;
      "NFINFINC  VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "NFINFALT  VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY ( NFID ), " + ;
      "INDEX IDXNUMLAN ( NFNUMLAN ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPITEMCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPITEM ( " + ;
      "IEID       INT(11)      NOT NULL AUTO_INCREMENT, " + ;
      "IEITEM     VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IEDESCRI   VARCHAR(60)  NOT NULL DEFAULT '', " + ;
      "IETIPO     VARCHAR(1)   NOT NULL DEFAULT '', " + ;
      "IEUNID     VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IEPRODEP   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IEPROSEC   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IEPROGRU   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IEPROLOC   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IEGTIN     VARCHAR(14)  NOT NULL DEFAULT '', " + ;
      "IEGARCOM   INT(3)       NOT NULL DEFAULT '0', " + ;
      "IEGARVEN   INT(3)       NOT NULL DEFAULT '0', " + ;
      "IENCM      VARCHAR(8)   NOT NULL DEFAULT ''," + ;
      "IECEST     VARCHAR(7)   NOT NULL DEFAULT '', " + ;
      "IEANP      VARCHAR(9)   NOT NULL DEFAULT '', " + ;
      "IEFORNEC   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IELIBERA   VARCHAR(1)   NOT NULL DEFAULT '', " + ;
      "IEQTD1     DOUBLE(14,3) NOT NULL DEFAULT '0', " + ;
      "IERES1     DOUBLE(14,3) NOT NULL DEFAULT '0', " + ;
      "IEQTD2     DOUBLE(14,3) NOT NULL DEFAULT '0', " + ;
      "IEQTD3     DOUBLE(14,3) NOT NULL DEFAULT '0', " + ;
      "IEQTD4     DOUBLE(14,3) NOT NULL DEFAULT '0', " + ;
      "IEQTD5     DOUBLE(14,3) NOT NULL DEFAULT '0', " + ;
      "IEQTD6     DOUBLE(14,3) NOT NULL DEFAULT '0', " + ;
      "IEQTD7     DOUBLE(14,3) NOT NULL DEFAULT '0', " + ;
      "IEQTD8     DOUBLE(14,3) NOT NULL DEFAULT '0', " + ;
      "IEQTD9     DOUBLE(14,3) NOT NULL DEFAULT '0', " + ;
      "IEQTDMIN   DOUBLE(14,3) NOT NULL DEFAULT '0', " + ;
      "IEULTCOM   DATE         NULL, " + ;
      "IEULTVEN   DATE         NULL, " + ;
      "IEORIMER   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IETRIPRO   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IECUSCON   DOUBLE(15,5) NOT NULL DEFAULT '0', " + ;
      "IEREAJUSTE VARCHAR(1)   NOT NULL DEFAULT '', " + ;
      "IELISTA    VARCHAR(1)   NOT NULL DEFAULT '', " + ;
      "IEVALOR    DOUBLE(15,5) NOT NULL DEFAULT '0', " + ;
      "IEULTPRE   DOUBLE(15,3) NOT NULL DEFAULT '0', " + ;
      "IEPESBRU   DOUBLE(9,3)  NOT NULL DEFAULT '0', " + ;
      "IEPESLIQ   DOUBLE(9,3)  NOT NULL DEFAULT '0', " + ;
      "IEALTURA   INT(10)      NOT NULL DEFAULT '0', " + ;
      "IELARGURA  INT(10)      NOT NULL DEFAULT '0', " + ;
      "IEPROFUND  INT(10)      NOT NULL DEFAULT '0', " + ;
      "IEVALCUS   DOUBLE(15,5) NOT NULL DEFAULT '0', " + ;
      "IEDATCUS   DATE         NULL, " + ;
      "IEUNICOM   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "IEQTDCOM   INT(8)       NOT NULL DEFAULT '0', " + ;
      "IEDESTEC   VARCHAR(150) NOT NULL DEFAULT '', " + ;
      "IEOBS      VARCHAR(100) NOT NULL DEFAULT '', " + ;
      "IEINFINC   VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "IEINFALT   VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY ( IEID ), " + ;
      "INDEX IDXITEM ( IEITEM ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPFINANCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPFINAN ( " + ;
      "FIID       INT(11)      NOT NULL AUTO_INCREMENT, " + ;
      "FINUMLAN   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "FIFILIAL   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "FITIPDOC   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "FINUMDOC   VARCHAR(9)   NOT NULL DEFAULT '', " + ;
      "FIPARCELA  VARCHAR(3)   NOT NULL DEFAULT '', " + ;
      "FIDATEMI   DATE         NULL, " + ;
      "FIDATVEN   DATE         NULL, " + ;
      "FIVALOR    DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "FIDOCAUX   VARCHAR(10)  NOT NULL DEFAULT '', " + ;
      "FICLIFOR   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "FISACADO   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "FICCUSTO   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "FIOPERACAO VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "FIPORTADOR VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "FIVENDEDOR VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "FIDATPAG   DATE         NULL, " + ;
      "FIDATPRE   DATE         NULL, " + ;
      "FIDATCAN   DATE         NULL, " + ;
      "FINUMBAN   VARCHAR(15)  NOT NULL DEFAULT '', " + ;
      "FIJURDES   DOUBLE(14,2) NOT NULL DEFAULT '0', " + ;
      "FITIPLAN   VARCHAR(1)   NOT NULL DEFAULT '', " + ;
      "FIPEDIDO   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "FIOBS      VARCHAR(100) NOT NULL DEFAULT '', " + ;
      "FIINFINC   VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "FIINFALT   VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY ( FIID ), " + ;
      "INDEX IDXNUMLAN ( FINUMLAN, FITIPDOC ), " + ;
      "INDEX IDXNUMDOC ( FINUMDOC, FIPARCELA, FITIPDOC, FINUMLAN ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPTRANSPCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPTRANSP ( " + ;
      "CDID       INT(11)      NOT NULL AUTO_INCREMENT, " + ;
      "CDCODIGO   VARCHAR(6)   NOT NULL DEFAULT '', " + ;
      "CDNOME     VARCHAR(50)  NOT NULL DEFAULT '', " + ;
      "CDAPELIDO  VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDCNPJ     VARCHAR(18)  NOT NULL DEFAULT '', " + ;
      "CDDIVISAO  VARCHAR(3)   NOT NULL DEFAULT '', " + ;
      "CDOUTDOC   VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDENDERECO VARCHAR(40)  NOT NULL DEFAULT '', " + ;
      "CDNUMERO   VARCHAR(10)  NOT NULL DEFAULT '', " + ;
      "CDCOMPL    VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDBAIRRO   VARCHAR(20)  NOT NULL DEFAULT '', " + ;
      "CDCIDADE   VARCHAR(21)  NOT NULL DEFAULT '', " + ;
      "CDUF       VARCHAR(2)   NOT NULL DEFAULT '', " + ;
      "CDCEP      VARCHAR(9)   NOT NULL DEFAULT '', " + ;
      "CDTELEFONE VARCHAR(30)  NOT NULL DEFAULT '', " + ;
      "CDINSEST   VARCHAR(18)  NOT NULL DEFAULT '', " + ;
      "CDCONTATO  VARCHAR(30)  NOT NULL DEFAULT '', " + ;
      "CDTELEF2   VARCHAR(15)  NOT NULL DEFAULT '', " + ;
      "CDTELEF3   VARCHAR(15)  NOT NULL DEFAULT '', " + ;
      "CDFAX      VARCHAR(30)  NOT NULL DEFAULT '', " + ;
      "CDEMAIL    VARCHAR(250) NOT NULL DEFAULT '', " + ;
      "CDOBS      VARCHAR(100) NOT NULL DEFAULT '', " + ;
      "CDINFINC   VARCHAR(80)  NOT NULL DEFAULT '', " + ;
      "CDINFALT   varchar(80)  NOT NULL DEFAULT '', " + ;
      "PRIMARY KEY    ( CDID ), " + ;
      "INDEX IDXCADAS1 ( CDCODIGO ), " + ;
      "INDEX IDXCADAS2 ( CDNOME, CDCODIGO ), " + ;
      "INDEX IDXCADAS3 ( CDCNPJ, CDDIVISAO, CDCODIGO ), " + ;
      "INDEX IDXCADAS4 ( CDAPELIDO, CDCODIGO ), " + ;
      "INDEX IDXTELEF  ( CDTELEFONE, CDCODIGO ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPTABANPAGECreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPTABANPAGE ( " + ;
      "AACNPJ   CHAR(8)  NOT NULL DEFAULT '', " + ;
      "AAANP    CHAR(10) NULL DEFAULT NULL, " + ;
      "AAVALDE  CHAR(6)  NULL DEFAULT '', " + ;
      "AAVALATE CHAR(6)  NULL DEFAULT '', " + ;
      "PRIMARY KEY ( AACNPJ ), " + ;
      "INDEX AACNPJUNIQUE ( AACNPJ ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPTABANPATICreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPTABANPATI ( " + ;
      "ATCNAE   CHAR(5)      NOT NULL DEFAULT '', " + ;
      "ATDESCRI VARCHAR(110) NULL DEFAULT NULL, " + ;
      "ATVALDE  CHAR(6)     NULL DEFAULT NULL, " + ;
      "ATVALATE CHAR(6)     NULL DEFAULT '', " + ;
      "PRIMARY KEY ( ATCNAE ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPTABANPINSCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPTABANPINS ( " + ;
      "AICNPJ   CHAR(14) NOT NULL DEFAULT '', " + ;
      "AIANP    CHAR(7)  NULL DEFAULT NULL, " + ;
      "AIVALDE  CHAR(6)  NULL DEFAULT NULL, " + ;
      "AIVALATE CHAR(6)  NULL DEFAULT '', " + ;
      "PRIMARY KEY ( AICNPJ ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPTABANPLOCCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPTABANPLOC ( " + ;
      "ALIBGE   CHAR(7)      NOT NULL DEFAULT '', " + ;
      "ALANP    CHAR(7)      NULL DEFAULT NULL, " + ;
      "ALNOME   VARCHAR(60)  NULL DEFAULT NULL, " + ;
      "ALUF     CHAR(2)      NULL DEFAULT NULL, " + ;
      "ALVALDE  CHAR(6)      NULL DEFAULT '', " + ;
      "ALVALATE CHAR(6)      NULL DEFAULT '', " + ;
      "PRIMARY KEY ( ALIBGE ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPTABANPOPECreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPTABANPOPE ( " + ;
      "AOCFOP    CHAR(6)      NOT NULL DEFAULT '', " + ;
      "AOANPREG  CHAR(7)      NULL DEFAULT NULL, " + ;
      "AOANPNREG CHAR(7)      NULL DEFAULT NULL, " + ;
      "AOANPOUT  CHAR(7)      NULL DEFAULT NULL, " + ;
      "AONOME    VARCHAR(100) NULL DEFAULT NULL, " + ;
      "AOVALDE   CHAR(10)     NULL DEFAULT '', " + ;
      "AOVALATE  CHAR(10)     NULL DEFAULT '', " + ;
      "PRIMARY KEY ( AOCFOP ), " + ;
      "INDEX AOCFOPUNIQUE ( AOCFOP ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"

STATIC FUNCTION JPCOMBUSTIVELCreateMySql()

   RETURN ;
      "CREATE TABLE IF NOT EXISTS JPCOMBUSTIVEL ( " + ;
      "CBID       INT(11)      NOT NULL AUTO_INCREMENT, " + ;
      "CBDATA     DATE         NULL, " + ;
      "CBS10PET   DOUBLE(8,5)  NULL DEFAULT 0, " + ;
      "CBS10SHE   DOUBLE(8,5)  NULL DEFAULT 0, " + ;
      "CBS10IPI   DOUBLE(8,5)  NULL DEFAULT 0, " + ;
      "CBS500PET  DOUBLE(8,5)  NULL DEFAULT 0, " + ;
      "CBS500SHE  DOUBLE(8,5)  NULL DEFAULT 0, " + ;
      "CBS500IPI  DOUBLE(8,5)  NULL DEFAULT 0, " + ;
      "PRIMARY KEY ( CBID ), " + ;
      "INDEX DATA ( CBDATA ) " + ;
      ") COLLATE=latin1_swedish_ci ENGINE=InnoDB"
