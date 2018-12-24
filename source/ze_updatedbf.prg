/*
ZE_UPDATEDBF - Cria DBFs
1995 José Quintas

2018.02.08 - Campos estoque e reserva do produto
2018.02.17 - Eliminados restos do demonstrativo
2018.11.27 - Sequencia no pedido de compra/venda
*/

#include "josequintas.ch"

FUNCTION ze_UpdateDbf()

   IF AppDatabase() != DATABASE_DBF
      RETURN NIL
   ENDIF
   SayScroll( "Verificando Tabelas DBF" )
   // JPREGUSO antes de todos
   JPREGUSOCreateDbf()
   JPCONFICreateDbf()
   JPBAAUTOCreateDbf()
   JPBAGRUPCreateDbf()
   JPBAMOVICreateDbf()
   CTDIARICreateDbf()
   CTHISTOCreateDbf()
   CTLANCACreateDbf()
   CTLOTESCreateDbf()
   CTPLANOCreateDbf()
   JPANPMOVCreateDbf()
   JPCADASCreateDbf()
   JPCIDADECreateDbf()
   JPCLISTACreateDbf()
   JPCOMISSCreateDbf()
   JPDOLARCreateDbf()
   JPEMPRECreateDbf()
   JPESTOQCreateDbf()
   JPFINANCreateDbf()
   JPFORPAGCreateDbf()
   JPITEMCreateDbf()
   JPIMPOSCreateDbf()
   JPITPEDCreateDbf()
   JPLFISCCreateDbf()
   JPMDFCABCreateDbf()
   JPMDFDETCreateDbf()
   JPMOTORICreateDbf()
   JPNOTACreateDbf()
   JPNUMEROCreateDbf()
   JPPEDICreateDbf()
   JPPRECOCreateDbf()
   JPPRETABCreateDbf()
   JPREFCTACreateDbf()
   JPSENHACreateDbf()
   JPTABELCreateDbf()
   JPTRANSACreateDbf()
   JPUFCreateDbf()
   JPVEICULCreateDbf()
   JPVENDEDCreateDbf()

   RETURN NIL

STATIC FUNCTION JPBAAUTOCreateDbf()

   LOCAL mStruOk

   SayScroll( "Verificando JPBAAUTO.DBF" )
   mStruOk := { ;
      { "BUCONTA",  "C", 15 }, ;
      { "BUHIST",   "C", 40 }, ;
      { "BUVALOR",  "N", 12,  2 }, ;
      { "BURESUMO", "C", 10 }, ;
      { "BUDATA",   "D", 8 }, ;
      { "BUINFINC", "C", 80 }, ;
      { "BUINFALT", "C", 80 }  }
   IF ! ValidaStru( "jpbaauto", mStruOk )
      MsgStop( "jpbaauto não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPBAGRUPCreateDbf()

   LOCAL mStruOk

   SayScroll( "Verificando JPBAGRUP.DBF" )
   mStruOk := { ;
      { "BGGRUPO",  "C", 10 }, ;
      { "BGRESUMO", "C", 10 }, ;
      { "BGMOSTRA", "C", 1 }, ;
      { "BGINFINC", "C", 80 }, ;
      { "BGINFALT", "C", 80 } }
   IF ! ValidaStru( "jpbagrup", mStruOk )
      MsgStop( "jpbagrup não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPBAMOVICreateDbf()

   LOCAL mStruOk

   SayScroll( "Verificando JPBAMOVI.DBF" )
   mStruOk := { ;
      { "BACONTA",  "C", 15 }, ;
      { "BAAPLIC",  "C",  1 }, ;
      { "BADATBAN", "D",  8 }, ;
      { "BADATEMI", "D",  8 }, ;
      { "BAHIST",   "C", 40 }, ;
      { "BAVALOR",  "N", 12,  2 }, ;
      { "BASALDO",  "N", 12,  2 }, ;
      { "BAIMPSLD", "C", 1 }, ;
      { "BARESUMO", "C", 10 }, ;
      { "BAINFINC", "C", 80 }, ;
      { "BAINFALT", "C", 80 }  }
   IF ! ValidaStru( "jpbamovi", mStruOk )
      MsgStop("jpbamovi não disponível!")
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION CTDIARICreateDbf()

   LOCAL mStruOk

   SayScroll( "CTDIARI, verificando atualizações" )
   mStruOk := { ;
      { "DILOTE",    "C", 6 }, ;
      { "DILANC",    "C", 6 }, ;
      { "DIMOV",     "C", 6 }, ;
      { "DIPARTIDA", "C", 1 }, ;
      { "DIDATA",    "D", 8 }, ;
      { "DIDEBCRE",  "C", 1 }, ;
      { "DICCONTA",  "C", 12 }, ;
      { "DIHIST",    "C", 250 }, ;
      { "DIVALOR",   "N", 17, 2 }, ;
      { "DICCUSTO",  "C", 6 }, ;
      { "DICONTRA",  "C", 12 }, ;
      { "DIBAIXA",   "D", 8 }, ;
      { "DIINFINC",  "C", 80 }, ;
      { "DIINFALT",  "C", 80 } }

   IF ! ValidaStru( "ctdiari", mStruOk )
      MsgStop( "ctdiari não disponível!" )
      QUIT
   ENDIF

   IF AppVersaoDbf() > 20170101
      RETURN NIL
   ENDIF

   IF ! UseSoDbf( "ctdiari", .T. )
      QUIT
   ENDIF

   GOTO TOP
   GrafTempo( "ctdiari" )
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      IF " " $ ctdiari->diCCusto .AND. ! Empty( ctdiari->diCCusto )
         REPLACE ctdiari->diCCusto WITH StrZero( Val( ctdiari->diCCusto ), Len( ctdiari->diCCusto ) )
      ENDIF
      IF ctdiari->diBaixa == Ctod("")
         REPLACE ctdiari->diBaixa WITH Stod( "29991231" )
      ENDIF
      SKIP
   ENDDO
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION CTHISTOCreateDbf()

   LOCAL mStruOk

   SayScroll( "CTHISTO, verificando atualizações" )

   mStruOk := { ;
      { "HIHISPAD", "C", 6 }, ;
      { "HIDESCRI", "C", 250}, ;
      { "HIINFINC", "C", 80 }, ;
      { "HIINFALT", "C", 80 } }

   IF ! ValidaStru( "cthisto", mStruOk )
      MsgStop( "cthisto não disponível!" )
      QUIT
   ENDIF
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION CTLANCACreateDbf()

   LOCAL mStruOk

   SayScroll( "CTLANCA, verificando atualizações" )
   mStruOk := { ;
      { "LACODIGO",  "C", 6 }, ;
      { "LASEQ",     "C", 6 }, ;
      { "LATIPO",    "C", 1 }, ;
      { "LAPARTIDA", "C", 1 }, ;
      { "LADEBCRE",  "C", 1 }, ;
      { "LACCONTA",  "C", 12 }, ;
      { "LACCUSTO",  "C", 6 }, ;
      { "LAHISPAD",  "C", 6 }, ;
      { "LAHISTO",   "C", 250 }, ;
      { "LAINFINC",  "C", 80 }, ;
      { "LAINFALT",  "C", 80 } }

   IF ! ValidaStru( "ctlanca", mStruOk )
      MsgStop( "ctlanca não disponível!" )
      QUIT
   ENDIF

   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION CTLOTESCreateDbf()

   LOCAL mStruOk

   SayScroll( "CTLOTES, verificando atualizações" )
   mStruOk := { ;
      { "LODATA",   "D", 8 }, ;
      { "LOLOTE",   "C", 6 }, ;
      { "LODESCRI", "C", 30 }, ;
      { "LOQTDINF", "N", 6 }, ;
      { "LOVALINF", "N", 17, 2 }, ;
      { "LOQTDCAL", "N", 6 }, ;
      { "LODEBCAL", "N", 17, 2 }, ;
      { "LOCRECAL", "N", 17, 2 }, ;
      { "LOINFINC", "C", 80 }, ;
      { "LOINFALT", "C", 80 } }

   IF ! ValidaStru( "ctlotes", mStruOk )
      MsgStop( "ctlotes não disponível!" )
      QUIT
   ENDIF

   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION CTPLANOCreateDbf()

   LOCAL mStruOk, nCont

   SayScroll( "CTPLANO, verificando atualizações" )
   mStruOk := { ;
      { "A_CODIGO", "C", 12 }, ;
      { "A_REDUZ",  "C", 6 }, ;
      { "A_NOME",   "C", 35 }, ;
      { "A_GRUPO",  "C", 1 }, ;
      { "A_TIPO",   "C", 1 }, ;
      { "A_GRAU",   "N", 1 }, ;
      { "A_CCUSTO", "C", 6 }, ;
      { "A_CTAADM", "C", 6 }, ;
      { "A_SDANT",  "N", 17, 2 }, ;
      { "TMPANT",   "N", 17, 2 }, ;
      { "TMPDEB",   "N", 17, 2 }, ;
      { "TMPCRE",   "N", 17, 2 }, ;
      { "ALTERADA", "C", 1 }, ;
      { "PLCTASRF", "C", 20 } }
   FOR nCont = 1 TO 96
      AAdd( mStruOk, { "A_DEB" + StrZero( nCont, 2 ), "N", 17, 2 } )
      AAdd( mStruOk, { "A_CRE" + StrZero( nCont, 2 ), "N", 17, 2 } )
   NEXT
   AAdd( mStruOk, { "PLINFINC", "C", 80 } )
   AAdd( mStruOk, { "PLINFALT", "C", 80 } )

   IF ! ValidaStru( "ctplano", mStruOk )
      MsgStop( "ctplano não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPANPMOVCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPANPMOV, verificando atualizações" )
   mStruOk := { ;
      { "AMNUMLAN",  "C", 6 }, ;
      { "AMDATREF",  "D", 8 }, ;
      { "AMANPNUM",  "C", 6 }, ;
      { "AMNUMDOC",  "C", 7 }, ;
      { "AMSERDOC",  "C", 2 }, ;
      { "AMDATEMI",  "D", 8 }, ;
      { "AMCLIFOR",  "C", 6 }, ;
      { "AMCNPJ",    "C", 18 }, ;
      { "AMANPAGE",  "C", 10 }, ;
      { "AMCIDADE",  "C", 40 }, ;
      { "AMUF",      "C", 2 }, ;
      { "AMANPLOC",  "C", 7 }, ;
      { "AMANPINS",  "C", 7 }, ;
      { "AMANPATI",  "C", 5 }, ;
      { "AMANPPAI",  "C", 4 }, ;
      { "AMCFOP",    "C", 10 }, ;
      { "AMANPOPE",  "C", 7 }, ;
      { "AMITEM",    "C", 6 }, ;
      { "AMANPPRO",  "C", 9 }, ;
      { "AMPRODES",  "C", 60 }, ;
      { "AMUNID",    "C", 3 }, ;
      { "AMANPUNI",  "C", 1 }, ;
      { "AMNFEKEY",  "C", 44 }, ;
      { "AMQTD",     "N", 14, 4 }, ;
      { "AMQTDKG",   "N", 14, 4 }, ;
      { "AMVALOR",   "N", 14, 4 }, ;
      { "AMSTATUS",  "C", 1 }, ;
      { "AMOK",      "C", 1 }, ;
      { "AMINFINC",  "C", 80 }, ;
      { "AMINFALT",  "C", 80 } }

   IF ! ValidaStru( "jpanpmov", mStruOk )
      MsgStop( "jpanpmov não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPCADASCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPCADAS, verificando atualizações" )
   mStruOk := { ;
      { "CDCODIGO",   "C", 6 }, ;
      { "CDNOME",     "C", 50 }, ;
      { "CDAPELIDO",  "C", 20 }, ;
      { "CDCNPJ",     "C", 18 }, ;
      { "CDDIVISAO",  "C", 3 }, ;
      { "CDGRUPO",    "C", 6 }, ;
      { "CDOUTDOC",   "C", 20 }, ;
      { "CDENDERECO", "C", 40 }, ;
      { "CDNUMERO",   "C", 10 }, ;
      { "CDCOMPL",    "C", 20 }, ;
      { "CDBAIRRO",   "C", 20 }, ;
      { "CDCIDADE",   "C", 21 }, ;
      { "CDUF",       "C", 2 }, ;
      { "CDCEP",      "C", 9 }, ;
      { "CDCNAE",     "C", 7 }, ;
      { "CDMAPA",     "C", 50 }, ;
      { "CDTELEFONE", "C", 30 }, ;
      { "CDINSEST",   "C", 18 }, ;
      { "CDSUFRAMA",  "C", 9 }, ; // Eliminar este campo jpcadas
      { "CDCONTATO",  "C", 30 }, ;
      { "CDTELEF2",   "C", 15 }, ;
      { "CDTELEF3",   "C", 15 }, ;
      { "CDFAX",      "C", 30 }, ;
      { "CDEMAIL",    "C", 250 }, ;
      { "CDEMANFE",   "C", 250 }, ;
      { "CDEMACON",   "C", 250 }, ;
      { "CDDATNAS",   "D", 8 }, ;
      { "CDMIDIA",    "C", 6 }, ;
      { "CDHOMEPAGE", "C", 100 }, ;
      { "CDENDCOB",   "C", 40 }, ;
      { "CDNUMCOB",   "C", 10 }, ;
      { "CDCOMCOB",   "C", 20 }, ;
      { "CDBAICOB",   "C", 20 }, ;
      { "CDCIDCOB",   "C", 21 }, ;
      { "CDUFCOB",    "C", 2 }, ;
      { "CDCEPCOB",   "C", 9 }, ;
      { "CDCONCOB",   "C", 30 }, ;
      { "CDTELCOB",   "C", 30 }, ; // 10 caracteres
      { "CDFAXCOB",   "C", 30 }, ; // 10 caracteres
      { "CDFORPAG",   "C", 6 }, ;
      { "CDNOMENT",   "C", 40 }, ;
      { "CDENDENT",   "C", 40 }, ;
      { "CDNUMENT",   "C", 10 }, ;
      { "CDCOMENT",   "C", 60 }, ;
      { "CDBAIENT",   "C", 20 }, ;
      { "CDCIDENT",   "C", 21 }, ;
      { "CDUFENT",    "C", 2 }, ;
      { "CDCEPENT",   "C", 9 }, ;
      { "CDCONENT",   "C", 30 }, ;
      { "CDTELENT",   "C", 30 }, ; // 10 caracters
      { "CDFAXENT",   "C", 30 }, ;
      { "CDVENDEDOR", "C", 6 }, ;
      { "CDPORTADOR", "C", 6 }, ;
      { "CDLIMCRE",   "N", 14, 2 }, ;
      { "CDTIPO",     "C", 1 }, ;
      { "CDCTACON",   "C", 20 }, ;
      { "CDCTAJUR",   "C", 20 }, ;
      { "CDCTADES",   "C", 20 }, ;
      { "CDVALMES",   "N", 14, 2 }, ;
      { "CDLIMHOR",   "N", 3 }, ; // eliminar este campo jpcadas
      { "CDTRANSP",   "C", 6 }, ;
      { "CDOBS",      "C", 100 }, ;
      { "CDTRICAD",   "C", 6 }, ;
      { "CDSITNFE",   "C", 1 }, ;
      { "CDSITFAZ",   "C", 1 }, ;
      { "CDSTATUS",   "C", 6 }, ;
      { "CDINFINC",   "C", 80 }, ;
      { "CDINFALT",   "C", 80 } }
   IF ! ValidaStru( "jpcadas", mStruOk )
      MsgStop( "jpcadas não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPCIDADECreateDbf()

   LOCAL mStruOk

   SayScroll( "JPCIDADE, verificando atualizações" )
   mStruOk := { ;
      { "CINUMLAN",  "C", 6 }, ;
      { "CINOME",    "C", 40}, ;
      { "CIUF",      "C", 2 }, ;
      { "CIIBGE",    "C", 7 }, ;
      { "CIINFINC",  "C", 80 }, ;
      { "CIINFALT",  "C", 80 } }
   IF ! ValidaStru( "jpcidade", mStruOk )
      MsgStop( PathAndFile( "jpcidade" ) + " não disponível!" )
      QUIT
   ENDIF
   IF AppVersaoDbfAnt() < 20160101
      JPCIDADEDefault()
   ENDIF

   RETURN NIL

STATIC FUNCTION JPCLISTACreateDbf()

   LOCAL mStruOk

   SayScroll( "JPCLISTA, verificando atualizações" )
   mStruOk := { ;
      { "CSNUMLAN",   "C", 6 }, ;
      { "CSDESCRI",   "C", 80 }, ;
      { "CSBLOQUEIO", "C", 1 }, ;
      { "CSINFINC",   "C", 80 }, ;
      { "CSINFALT",   "C", 80 } }
   IF ! ValidaStru( "jpclista", mStruOk )
      MsgStop( "JPCLISTA não disponível!" )
      QUIT
   ENDIF
   IF AppVersaoDbfAnt() >= 20130201
      RETURN NIL
   ENDIF
   IF ! UseSoDbf( "jpclista", .T. )
      QUIT
   ENDIF
   IF Eof()
      RecAppend()
      REPLACE jpclista->csNumLan WITH StrZero( 1, 6 ), ;
         jpclista->csDescri WITH "GERAL"
      RecUnlock()
   ENDIF
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION JPCOMISSCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPCOMISS, verificando atualizações" )
   mStruOk := { ;
      { "CMVENDEDOR", "C", 6 }, ;
      { "CMPRODEP",   "C", 6 }, ;
      { "CMVALOR",    "N", 7, 3 }, ;
      { "CMINFINC",   "C", 80 }, ;
      { "CMINFALT",   "C", 80 } }
   IF ! ValidaStru( "jpcomiss", mStruOk )
      MsgStop( "JPCOMISS não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

   // Chamada de fora deste PRG

FUNCTION JPCONFICreateDbf( lUpdate )

   LOCAL mStruOk

   IF AppDatabase() != DATABASE_DBF
      RETURN NIL
   ENDIF
   hb_Default( @lUpdate, .T. )
   SayScroll( "JPCONFI, verificando atualizações" )

   mStruOk := { ;
      { "CNF_NOME",  "C", 40 }, ;
      { "CNF_PARAM", "C", 80 }, ;
      { "SSINFINC",  "C", 80 }, ;
      { "SSINFALT",  "C", 80 } }
   IF ! ValidaStru( "jpconfi", mStruOk )
      MsgStop( "jpconfi não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPDOLARCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPDOLAR, verificando atualizações" )
   mStruOk := { ;
      { "DLDATA",   "D", 8 }, ;
      { "DLNUMLAN", "C", 6 }, ;
      { "DLMOEDA",  "C", 6 }, ;
      { "DLVALOR",  "N", 14, 2 }, ;
      { "DLINFINC", "C", 80 }, ;
      { "DLINFALT", "C", 80 } }
   IF ! ValidaStru( "jpdolar", mStruOk )
      MsgStop( "jpdolar não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPEMPRECreateDbf()

   LOCAL mStruOk

   SayScroll( "JPEMPRE, verificando atualizações" )
   mStruOk := { ;
      { "EMNUMLAN",   "C", 6 }, ;
      { "EMNOME",     "C", 60 }, ;
      { "EMENDERECO", "C", 50 }, ;
      { "EMBAIRRO",   "C", 20 }, ;
      { "EMCIDADE",   "C", 21 }, ;
      { "EMUF",       "C",  2 }, ;
      { "EMCEP",      "C",  9 }, ;
      { "EMTELEFONE", "C", 20 }, ;
      { "EMFAX",      "C", 20 }, ;
      { "EMEMAIL",    "C", 200 }, ;
      { "EMEMAILCC",  "C", 200 }, ;
      { "EMHOMEPAGE", "C", 200 }, ;
      { "EMCNPJ",     "C", 18 }, ;
      { "EMINSEST",   "C", 18 }, ;
      { "EMINSMUN",   "C", 20 }, ;
      { "EMLOCREG",   "C", 150 }, ;
      { "EMNUMREG",   "C", 11 }, ;
      { "EMDATREG",   "D", 8 }, ;
      { "EMTITULAR",  "C", 40 }, ;
      { "EMQUATIT",   "C", 3 }, ;
      { "EMCARTIT",   "C", 20 }, ;
      { "EMCPFTIT",   "C", 18 }, ;
      { "EMCONTADOR", "C", 40 }, ;
      { "EMQUACON",   "C", 3 }, ;
      { "EMCARCON",   "C", 20 }, ;
      { "EMCPFCON",   "C", 18 }, ;
      { "EMCRCCON",   "C", 9 }, ;
      { "EMUFCRC",    "C", 2 }, ;
      { "EMTRIEMP",   "C", 6 }, ;
      { "EMQTDPAG",   "N", 6 }, ;
      { "EMDIABAL",   "C", 1 }, ;
      { "EMDIADEM",   "C", 1 }, ;
      { "EMDIAMES",   "N", 3 }, ;
      { "EMDIAPLA",   "C", 1 }, ;
      { "EMDIATER",   "C", 1 }, ;
      { "EMFECHA",    "N", 3 }, ;
      { "EMANOBASE",  "N", 4 }, ;
      { "EMPICTURE",  "C", 20 }, ;
      { "EMRELEMI",   "C", 27 }, ;
      { "EMRESACU",   "C", 12 }, ;
      { "EMCODACU",   "C", 200 }, ;
      { "EMLOTE",     "C", 20 }, ;
      { "EMHISFEC",   "C", 100 }, ;
      { "EMDIARIO1",  "C", 200 }, ;
      { "EMDIARIO2",  "C", 200 }, ;
      { "EMDIARIO3",  "C", 200 }, ;
      { "EMDIARIO4",  "C", 200 }, ;
      { "EMDIARIO5",  "C", 200 }, ;
      { "EMDIARIO6",  "C", 200 }, ;
      { "EMDIARIO7",  "C", 200 }, ;
      { "EMDIARIO8",  "C", 200 }, ;
      { "EMDIARIO9",  "C", 200 }, ;
      { "EMINFINC",   "C", 80 }, ;
      { "EMINFALT",   "C", 80 } }
   IF ! ValidaStru( "jpempre", mStruOk )
      MsgStop( "jpempre não disponível!" )
      QUIT
   ENDIF
   IF AppVersaoDbfAnt() < 20160101
      JPEMPREDefault()
   ENDIF

   RETURN NIL

STATIC FUNCTION JPESTOQCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPESTOQ, verificando atualizações" )
   mStruOk := { ;
      { "ESNUMLAN", "C", 6 }, ;
      { "ESFILIAL", "C", 6 }, ;
      { "ESDATLAN", "D", 8 }, ;
      { "ESTIPLAN", "C", 1 }, ;
      { "ESCLIFOR", "C", 6 }, ;
      { "ESTIPDOC", "C", 6 }, ;
      { "ESTRANSA", "C", 6 }, ; // 2012-07-10 apenas adicionado
      { "ESNUMDOC", "C", 9 }, ;
      { "ESITEM",   "C", 6 }, ;
      { "ESQTDE",   "N", 14, 3 }, ;
      { "ESVALOR",  "N", 15, 5 }, ;
      { "ESNUMDEP", "C", 1 }, ;
      { "ESCCUSTO", "C", 6 }, ;
      { "ESDOCSER", "C", 2 }, ;
      { "ESCFOP",   "C", 6 }, ;
      { "ESCCONTA", "C", 20 }, ;
      { "ESPEDIDO", "C", 6 }, ;
      { "ESOBS",    "C", 100 }, ;
      { "ESINFINC", "C", 80 }, ;
      { "ESINFALT", "C", 80 } }
   IF ! ValidaStru( "jpestoq", mStruOk )
      MsgStop( "jpestoq não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPFINANCreateDbf()

   LOCAL mStruOk, nAtual, nTotal

   SayScroll("JPFINAN, verificando atualizações")
   mStruOk := { ;
      { "FINUMLAN",  "C", 6 }, ;
      { "FIFILIAL",  "C", 6 }, ;    // 21/06/05 - Atualizado
      { "FITIPDOC",  "C", 6 }, ;
      { "FINUMDOC",  "C", 9 }, ;
      { "FIPARCELA", "C", 3 }, ;
      { "FIDATEMI",  "D", 8 }, ;
      { "FIDATVEN",  "D", 8 }, ;
      { "FIVALOR",   "N", 14, 2 }, ;
      { "FIDOCAUX",  "C", 10 }, ;
      { "FICLIFOR",  "C", 6 }, ;
      { "FISACADO",  "C", 6 }, ;    // Representante/Representada 14/04/07
      { "FICCUSTO",  "C", 6 }, ;
      { "FIOPERACAO", "C", 6 }, ;
      { "FIPORTADOR", "C", 6 }, ;
      { "FIVENDEDOR", "C", 6 }, ;
      { "FIDATPAG",  "D", 8 }, ;
      { "FIDATPRE",  "D", 8 }, ;
      { "FIDATCAN",  "D", 8 }, ;
      { "FINUMBAN",  "C", 15 }, ;
      { "FIJURDES",  "N", 14, 2 }, ;
      { "FITIPLAN",  "C", 1 }, ;
      { "FIPEDIDO",  "C", 6 }, ;
      { "FIOBS",     "C", 100 }, ;
      { "FIINFINC",  "C", 80 }, ;
      { "FIINFALT",  "C", 80 } }
   IF ! ValidaStru( "jpfinan", mStruOk )
      MsgStop( "jpfinan não disponível!" )
      QUIT
   ENDIF
   IF AppVersaoDbfAnt() >= 20150930
      RETURN NIL
   ENDIF
   IF ! UseSoDbf( "jpfinan" )
      QUIT
   ENDIF
   GOTO TOP
   GrafTempo( "Ajustando jpfinan" )
   nAtual := 0
   nTotal := LastRec()
   DO WHILE ! Eof()
      GrafTempo( nAtual++, nTotal )
      IF " " $ jpfinan->fiParcela
         RecLock()
         REPLACE jpfinan->fiParcela WITH StrZero( Val( jpfinan->fiParcela ), 3 )
      ENDIF
      SKIP
   ENDDO
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION JPFORPAGCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPFORPAG, verificando atualizações" )
   mStruOk := { ;
      { "FPNUMLAN",   "C", 6 }, ;
      { "FPDESCRI",   "C", 80 }, ;
      { "FPALIADI",   "N", 8, 3 }, ;
      { "FPALIDES",   "N", 8, 3 }, ;
      { "FPEMISAI",   "C", 1 }, ;
      { "FPPADRAO",   "C", 1 }, ;
      { "FPDE1",      "N", 2 }, ;
      { "FPATE1",     "N", 2 }, ;
      { "FPQTMES1",   "N", 2 }, ;
      { "FPQTDIA1",   "N", 3 }, ;
      { "FPDIAFIM1",  "N", 2 }, ;
      { "FPDE2",      "N", 2 }, ;
      { "FPATE2",     "N", 2 }, ;
      { "FPQTMES2",   "N", 2 }, ;
      { "FPQTDIA2",   "N", 3 }, ;
      { "FPDIAFIM2",  "N", 2 }, ;
      { "FPDE3",      "N", 2 }, ;
      { "FPATE3",     "N", 2 }, ;
      { "FPQTMES3",   "N", 2 }, ;
      { "FPQTDIA3",   "N", 3 }, ;
      { "FPDIAFIM3",  "N", 2 }, ;
      { "FPDE4",      "N", 2 }, ;
      { "FPATE4",     "N", 2 }, ;
      { "FPQTMES4",   "N", 2 }, ;
      { "FPQTDIA4",   "N", 3 }, ;
      { "FPDIAFIM4",  "N", 2 }, ;
      { "FPDE5",      "N", 2 }, ;
      { "FPATE5",     "N", 2 }, ;
      { "FPQTMES5",   "N", 2 }, ;
      { "FPQTDIA5",   "N", 3 }, ;
      { "FPDIAFIM5",  "N", 2 }, ;
      { "FPPARCEL",   "C", 200 }, ;
      { "FPINFINC",   "C", 80 }, ;
      { "FPINFALT",   "C", 80 } }
   IF ! ValidaStru( "jpforpag", mStruOk )
      MsgStop( "jpforpag não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPITEMCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPITEM, verificando atualizações" )
   mStruOk := { ;
      { "IEITEM",    "C", 6 }, ;
      { "IEDESCRI",  "C", 60 }, ;
      { "IETIPO",    "C", 1 }, ;
      { "IEUNID",    "C", 6 }, ;
      { "IEPRODEP",  "C", 6 }, ;
      { "IEPROSEC",  "C", 6 }, ;
      { "IEPROGRU",  "C", 6 }, ;
      { "IEPROLOC",  "C", 6 }, ;
      { "IEGTIN",    "C", 14 }, ;
      { "IEGTINTRI", "C", 14 }, ;
      { "IEGTINQTD", "N", 3 }, ;
      { "IEGARCOM",  "N", 3 }, ;
      { "IEGARVEN",  "N", 3 }, ;
      { "IENCM",     "C", 8 }, ;
      { "IECEST",    "C", 7 }, ;
      { "IEANP",     "C", 9 }, ;
      { "IEFORNEC",  "C", 6 }, ;
      { "IELIBERA",  "C", 1 }, ;
      { "IEQTD1",    "N", 14, 3 }, ;
      { "IERES1",    "N", 14, 3 }, ;
      { "IEQTD2",    "N", 14, 3 }, ;
      { "IERES2",    "N", 14, 3 }, ;
      { "IEQTD3",    "N", 14, 3 }, ;
      { "IERES3",    "N", 14, 3 }, ;
      { "IEQTD4",    "N", 14, 3 }, ;
      { "IEQTD5",    "N", 14, 3 }, ;
      { "IEQTD6",    "N", 14, 3 }, ;
      { "IEQTD7",    "N", 14, 3 }, ;
      { "IEQTD8",    "N", 14, 3 }, ;
      { "IEQTD9",    "N", 14, 3 }, ;
      { "IEQTDMIN",  "N", 14, 3 }, ;
      { "IEULTCOM",  "D", 8 }, ;
      { "IEULTVEN",  "D", 8 }, ;
      { "IEORIMER",  "C", 6 }, ;  // Origem Mercad. adicionado 28.11.12
      { "IETRIPRO",  "C", 6 }, ;
      { "IECUSCON",  "N", 15, 5 }, ;
      { "IEREAJUSTE","C", 1, 0 }, ;
      { "IELISTA",   "C", 1, 0 }, ;
      { "IEVALOR",   "N", 15, 5 }, ;
      { "IEULTPRE",  "N", 15, 5 }, ;
      { "IEPESBRU",  "N", 9, 3 }, ;
      { "IEPESLIQ",  "N", 9, 3 }, ;
      { "IEALTURA",  "N", 10, 0 }, ;
      { "IELARGURA", "N", 10, 0 }, ;
      { "IEPROFUND", "N", 10, 0 }, ;
      { "IEVALCUS",  "N", 15, 5 }, ;
      { "IEDATCUS",  "D", 8 }, ;
      { "IEUNICOM",  "C", 6 }, ;
      { "IEQTDCOM",  "N", 8, 1 }, ;
      { "IEDESTEC",  "C", 150 }, ;
      { "IEOBS",     "C", 100 }, ;
      { "IEINFINC",  "C", 80 }, ;
      { "IEINFALT",  "C", 80 } }
   IF AppVersaoDbfAnt() < 20180702
      AAdd( mStruOk, { "IECODNCM",  "C", 8 } )
   ENDIF
   IF AppVersaoDbfAnt() < 20170620
      AAdd( mStruOk, { "IEQTDANT",  "N", 14, 3 } )
   ENDIF
   IF AppVersaoDbfAnt() < 20180210
      AAdd( mStruOk, { "IEQTDE",    "N", 14, 3 } )
      AAdd( mStruOk, { "IERESERVA", "N", 14, 3 } )
   ENDIF
   IF ! ValidaStru( "jpitem", mStruOk )
      MsgStop( "JPITEM nao disponivel!" )
      QUIT
   ENDIF
   IF AppVersaoDbfAnt() >= 20180702
      RETURN NIL
   ENDIF
   IF ! UseSoDbf( "jpitem" )
      QUIT
   ENDIF
   GOTO TOP
   DO WHILE ! Eof()
      IF Empty( jpitem->ieNcm ) .AND. FieldNum( "IECODNCM" ) != 0
         RecLock()
         REPLACE jpitem->ieNcm WITH jpitem->ieCodNcm
      ENDIF
      IF Empty( jpitem->ieQtd1 ) .AND. FieldNum( "IEQTDE" ) != 0
         RecLock()
         REPLACE jpitem->ieQtd1 WITH jpitem->ieQtde
      ENDIF
      IF Empty( jpitem->ieRes1 )
         IF FieldNum( "IERESERVA" ) != 0 .AND. jpitem->ieReserva != 0
            RecLock()
            REPLACE jpitem->ieRes1 WITH jpitem->ieReserva
         ENDIF
      ENDIF
      SKIP
   ENDDO
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION JPIMPOSCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPIMPOS, verificando atualizações" )
   mStruOk := { ;
      { "IMNUMLAN",  "C", 6 }, ;
      { "IMTRANSA",  "C", 6 }, ;
      { "IMTRIUF",   "C", 6 }, ;
      { "IMTRICAD",  "C", 6 }, ;
      { "IMTRIPRO",  "C", 6 }, ;
      { "IMORIMER",  "C", 1 }, ;     // ORIGEM A PARTIR DE 2013
      { "IMCFOP",    "C", 6 }, ;     // CFOP
      { "IMIIALI",   "N", 6, 2 }, ;  // Percentual de Imposto de Importacao
      { "IMIPICST",  "C", 2 }, ;     // CST IPI
      { "IMIPIALI",  "N", 6, 2 }, ;  // Percentual IPI
      { "IMIPIICM",  "C", 1 }, ;     // Incide ICMS s/ IPI
      { "IMIPIENQ",  "C", 3 }, ;     // Enquadramento IPI 09/12/12
      { "IMIPSALI",  "N", 6, 2 }, ;  // Credito de IPI Simples
      { "IMICMCST",  "C", 4 }, ;     // CST ou CSOSN
      { "IMICMRED",  "N", 6, 2 }, ;  // Base de reducao ICMS
      { "IMICMALI",  "N", 6, 2 }, ;  // Percentual ICMS
      { "IMICSALI",  "N", 6, 2 }, ;  // Credito de ICMS Simples
      { "IMFCPALI",  "N", 6, 2 }, ;  // Fundo de Combate à Pobreza
      { "IMSUBIVA",  "N", 6, 2 }, ;  // Percentual Agregado - Sim, Nao, Dig
      { "IMSUBRED",  "N", 6, 2 }, ;  // Reducao da Subst.Tribut.
      { "IMSUBALI",  "N", 6, 2 }, ;  // Aliquota de Substituicao Tributaria
      { "IMDIFCAL",  "C", 1 }, ;     // Fórmula de cálculo da Difal
      { "IMDIFALII", "N", 6, 2 }, ;  // DIFAL interestadual
      { "IMDIFALIU", "N", 6, 2 }, ;  // DIFAL UF Destino
      { "IMDIFALIF", "N", 6, 2 }, ;  // DIFAL FCP
      { "IMISSALI",  "N", 6, 2 }, ;  // Percentual de ISS
      { "IMPISCST",  "C", 2 }, ;     // CST PIS
      { "IMPISALI",  "N", 6, 2 }, ;  // Percentual de PIS
      { "IMPISENQ",  "C", 3 }, ;     // Enquadramento PIS
      { "IMCOFCST",  "C", 2 }, ;     // CST Cofins
      { "IMCOFALI",  "N", 6, 2 }, ;  // Percentual de Cofins
      { "IMCOFENQ",  "C", 3 }, ;     // Enquadramento Cofins
      { "IMLEIS",    "C", 70}, ;     // ate 10 decretos cada - com virgula pra funcionar At()
      { "IMOBS",     "C", 100 }, ;
      { "IMINFINC",  "C", 80 }, ;
      { "IMINFALT",  "C", 80 } }
   IF ! ValidaStru( "jpimpos", mStruOk )
      MsgStop( "JPIMPOS não disponível!" )
      QUIT
   ENDIF
   IF AppVersaoDbfAnt() >= 20160715
      RETURN NIL
   ENDIF
   IF ! AbreArquivos( "jpimpos" )
      QUIT
   ENDIF
   GOTO TOP
   DO WHILE ! Eof()
      RecLock()
      IF ! jpimpos->imDifCal $ "SNZ"
         IF jpimpos->imDifAlii == 0 .AND. jpimpos->imDifAliU == 0 .AND. jpimpos->imDifAlif == 0
            REPLACE jpimpos->imDifCal WITH "N"
         ELSE
            REPLACE jpimpos->imDifCal WITH "S"
         ENDIF
      ENDIF
      RecUnlock()
      SKIP
   ENDDO
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION JPITPEDCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPITPED, verificando atualizações" )
   mStruOk := { ;
      { "IPPEDIDO",   "C", 6 }, ;
      { "IPFILIAL",   "C", 6 }, ;
      { "IPITEM",     "C", 6 }, ;
      { "IPSEQ",      "C", 6 }, ;
      { "IPPRECUS",   "N", 15, 5 }, ; // Preco de Custo
      { "IPPREPED",   "N", 15, 5 }, ; // Valor Unitario Referencia
      { "IPCFOP",     "C", 6 }, ;
      { "IPQTDE",     "N", 14, 3 }, ; // Qtde Solicitada
      { "IPQTDEF",    "N", 14, 3 }, ; // Qtde Fornecida
      { "IPTRIBUT",   "C", 6 }, ;
      { "IPVALTAB",   "N", 15, 5 }, ; // Valor na Tabela
      { "IPVALCUS",   "N", 15, 5 }, ;  // Valor Total do Custo 19/06/12
      { "IPVALCUT",   "N", 15, 5 }, ; // criado 20/05/13 custo tabela
      { "IPGARANTIA", "N", 3, 0 }, ; // garantia
      ;
      { "IPPRENOT",   "N", 15, 5 }, ; // Preco Unitario pra Nota
      ;
      { "IPVALADI",   "N", 14, 2 }, ; // Valor Adicional Rateado // 17.08.12
      { "IPVALFRE",   "N", 14, 2 }, ; // adicionados em 22.10.10
      { "IPVALSEG",   "N", 14, 2 }, ; // inicialmente sem uso
      { "IPVALOUT",   "N", 14, 2 }, ;
      { "IPVALADU",   "N", 14, 2 }, ; // Desp Aduaneiras
      { "IPVALIOF",   "N", 14, 2 }, ; // IOF
      { "IPVALDES",   "N", 14, 2 }, ;
      { "IPVALPRO",   "N", 14, 2 }, ;  // Total dos Produtos pra Nota - sem IPI
      { "IPVALNOT",   "N", 14, 2 }, ;  // Total da Nota - Total Geral
      { "IPPEDCOM",   "C", 6 }, ;      // Sequencia no pedido de compra
      { "IPLEIS",     "C", 70 }, ;
      ;
      { "IPORIMER",   "C", 6 }, ;
      { "IPIIBAS",    "N", 14, 2 }, ;
      { "IPIIALI",    "N", 6, 2 }, ;
      { "IPIIVAL",    "N", 14, 2 }, ;
      { "IPIPIBAS",   "N", 14, 2 }, ;
      { "IPIPIALI",   "N", 6, 2 }, ;  // Aliquota de IPI
      { "IPIPIVAL",   "N", 14, 2 }, ; // Valor de IPI
      { "IPIPIICM",   "C", 1 }, ;     // Incide ICMS sobre IPI
      { "IPIPICST",   "C", 2 }, ;
      { "IPIPIENQ",   "C", 3 }, ;     // 09.12.12 - Enquadramento IPI
      { "IPICMBAS",   "N", 14, 2 }, ; // 28.02.09 - Base de calculo ICMS
      { "IPICMALI",   "N", 6, 2 }, ;  // Aliquota de ICMS
      { "IPICMRED",   "N", 6, 2 }, ;  // 28.02.09 - Reducao
      { "IPICMVAL",   "N", 14, 2 }, ; // Valor de ICMS
      { "IPICMCST",   "C", 4 }, ;
      { "IPFCPALI",   "N", 6, 2 }, ;
      { "IPFCPVAL",   "N", 14, 2 }, ;
      { "IPICSBAS",   "N", 14, 2 }, ; // Base de Calculo do Simples
      { "IPICSALI",   "N", 6, 2 }, ;  // Aliq Credito Simples
      { "IPICSVAL",   "N", 14, 2 }, ; // Valor Credito Simples
      { "IPSUBIVA",   "N", 6, 2 }, ;  // 28.02.09 - IVA
      { "IPSUBBAS",   "N", 14, 2 }, ; // 28.02.09 - ICMS Substituicao
      { "IPSUBRED",   "N", 6, 2 }, ;  // 23.06 - reducao
      { "IPSUBALI",   "N", 6, 2 }, ;
      { "IPSUBVAL",   "N", 14, 2 }, ;
      { "IPDIFCAL",   "C", 1 }, ;
      { "IPDIFBAS",   "N", 14, 2 }, ;
      { "IPDIFALIF",  "N", 6, 2 }, ;
      { "IPDIFALIU",  "N", 6, 2 }, ;
      { "IPDIFALII",  "N", 6, 2 }, ;
      { "IPDIFVALI",  "N", 14, 2 }, ;
      { "IPDIFVALF",  "N", 14, 2 }, ;
      { "IPPISBAS",   "N", 14, 2 }, ;
      { "IPPISALI",   "N", 6, 2 }, ;
      { "IPPISVAL",   "N", 14, 2 }, ;
      { "IPPISCST",   "C", 2 }, ;
      { "IPPISENQ",   "C", 3 }, ;
      { "IPCOFBAS",   "N", 14, 2 }, ;
      { "IPCOFALI",   "N", 6, 2 }, ;
      { "IPCOFVAL",   "N", 14, 2 }, ;
      { "IPCOFCST",   "C", 2 }, ;
      { "IPCOFENQ",   "C", 3 }, ;
      { "IPISSBAS",   "N", 14, 2 }, ;
      { "IPISSALI",   "N", 6, 2 }, ;
      { "IPISSVAL",   "N", 14, 2 }, ;
      { "IPIMPALI",   "N", 6, 2 }, ;
      { "IPIMPVAL",   "N", 14, 2 }, ;
      { "IPINFINC",   "C", 80 }, ;
      { "IPINFALT",   "C", 80 } }

   IF ! ValidaStru( "jpitped", mStruOk )
      MsgStop( "JPITPED não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPLFISCCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPLFISC, verificando atualizações" )
   mStruOk := { ;
      { "LFNUMLAN",  "C", 6 }, ;
      { "LFFILIAL",  "C", 6 }, ;
      { "LFTIPLAN",  "C", 1 }, ;
      { "LFMODFIS",  "C", 2 }, ;
      { "LFDOCPRO",  "C", 1 }, ; // emissao propria
      { "LFDOCSER",  "C", 2 }, ;
      { "LFDOCINI",  "C", 9 }, ;
      { "LFDOCFIM",  "C", 9 }, ;
      { "LFDOCCOM",  "C", 1 }, ; // Complemento (Doc. por CFOP e Aliquota)
      { "LFCLIFOR",  "C", 6 }, ;
      { "LFCFOP",    "C", 6 }, ;
      { "LFUF",      "C", 2 }, ;
      { "LFDATLAN",  "D", 8 }, ;
      { "LFDATDOC",  "D", 8 }, ;
      { "LFVALCON",  "N", 12, 2 }, ;
      { "LFICMBAS",  "N", 12, 2 }, ;
      { "LFICMALI",  "N", 7, 2 }, ;
      { "LFICMVAL",  "N", 12, 2 }, ;
      { "LFICMSUB",  "N", 12, 2 }, ;
      { "LFICMOUT",  "N", 12, 2 }, ;
      { "LFIPIBAS",  "N", 12, 2 }, ;
      { "LFIPIVAL",  "N", 12, 2 }, ;
      { "LFIPIOUT",  "N", 12, 2 }, ;
      { "LFCIFFOB",  "C", 1 }, ;
      { "LFCTADEB",  "C", 20 }, ; // Cta.Debito 20/10/04
      { "LFCTACRE",  "C", 20 }, ; // Cta.Credito 20/10/04
      { "LFCCUSTO",  "C", 6 }, ; // C.Custo 20/10/04
      { "LFGRF",     "C", 1 }, ; // somente adicionado 03/02/12
      { "LFOBS",     "C", 50 }, ;
      { "LFPEDIDO",  "C", 6 }, ; // somente adicionado
      { "LFINFINC",  "C", 80 }, ;
      { "LFINFALT",  "C", 80 } }
   IF ! ValidaStru( "jplfisc", mStruOk )
      MsgStop( "jplfisc não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPMDFCABCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPMDFCAB, Verificando atualizações" )
   mStruOk := { ;
      { "MCNUMLAN",  "C", 6 }, ;
      { "MCDATEMI",  "D", 8 }, ;
      { "MCCHAVE",   "C", 44 }, ;
      { "MCUFORI",   "C", 2 }, ;
      { "MCUFDES",   "C", 2 }, ;
      { "MCVEICULO", "C", 6 }, ;
      { "MCMOTORI",  "C", 6 }, ;
      { "MCSTATUS",  "C", 6 }, ;
      { "MCINFINC",  "C", 80 }, ;
      { "MCINFALT",  "C", 80 } }
   IF ! ValidaStru( "jpmdfcab", mStruOk )
      MsgStop( "jpmdfcab não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPMDFDETCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPMDFDET, Verificando atualizações" )
   mStruOk := { ;
      { "MDMDFNUM",  "C", 6 }, ;
      { "MDORDEM",   "C", 6 }, ;
      { "MDNUMDOC",  "C", 9 }, ;
      { "MDDATEMI",  "D", 8 }, ;
      { "MDUF",      "C", 2 }, ;
      { "MDCIDADE",  "C", 21 }, ;
      { "MDCLIENTE", "C", 6 }, ;
      { "MDPESO",    "N", 6 }, ;
      { "MDVALMER",  "N", 12, 2 }, ;
      { "MDCHAVE",   "C", 44 }, ;
      { "MDINFINC",  "C", 80 }, ;
      { "MDINFALT",  "C", 80 } }
   IF ! ValidaStru( "jpmdfdet", mStruOk )
      MsgStop( "jpmdfdet não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPMOTORICreateDbf()

   LOCAL mStruOk

   SayScroll( "JPMOTORI, verificando atualizações" )
   mStruOk := { ;
      { "MOMOTORI",  "C", 6 }, ;
      { "MONOME",    "C", 40}, ;
      { "MOCPF",     "C", 18 }, ;
      { "MOTELEFONE", "C", 20 }, ;
      { "MOINFINC",  "C", 80 }, ;
      { "MOINFALT",  "C", 80 } }
   IF ! ValidaStru( "jpmotori", mStruOk )
      MsgStop( PathAndFile( "jpmotori" ) + " não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPNOTACreateDbf()

   LOCAL mStruOk

   SayScroll( "jpnota, verificando atualizações" )

   mStruOk := { ;
      { "NFNUMLAN",  "C", 6 }, ;
      { "NFFILIAL",  "C", 6 }, ;
      { "NFNOTFIS",  "C", 9 }, ;
      { "NFDATEMI",  "D", 8 }, ;
      { "NFHOREMI",  "C", 8 }, ;
      { "NFTRANSA",  "C", 6 }, ; // 2012-07-10 apenas adicionado
      { "NFCADDES",  "C", 6 }, ;
      { "NFVALPRO",  "N", 14, 2 }, ;
      { "NFVALNOT",  "N", 14, 2 }, ;
      { "NFVALFRE",  "N", 14, 2 }, ;
      { "NFVALSEG",  "N", 14, 2 }, ;
      { "NFVALOUT",  "N", 14, 2 }, ;
      { "NFVALDES",  "N", 14, 2 }, ;
      { "NFVALADU",  "N", 14, 2 }, ;
      { "NFVALIOF",  "N", 14, 2 }, ;
      { "NFIPIBAS",  "N", 14, 2 }, ;
      { "NFIPIVAL",  "N", 14, 2 }, ;
      { "NFICMBAS",  "N", 14, 2 }, ;
      { "NFICMVAL",  "N", 14, 2 }, ;
      { "NFFCPVAL",  "N", 14, 2 }, ;
      { "NFSUBBAS",  "N", 14, 2 }, ;
      { "NFSUBVAL",  "N", 14, 2 }, ;
      { "NFDIFCAL",  "C", 1 }, ;
      { "NFDIFVALF", "N", 14, 2 }, ;
      { "NFDIFVALI", "N", 14, 2 }, ;
      { "NFPISBAS",  "N", 14, 2 }, ;
      { "NFPISVAL",  "N", 14, 2 }, ;
      { "NFCOFBAS",  "N", 14, 2 }, ;
      { "NFCOFVAL",  "N", 14, 2 }, ;
      { "NFISSBAS",  "N", 14, 2 }, ;
      { "NFISSVAL",  "N", 14, 2 }, ;
      { "NFICSBAS",  "N", 14, 2 }, ;
      { "NFICSALI",  "N", 5, 2 }, ;
      { "NFICSVAL",  "N", 14, 2 }, ;
      { "NFIMPVAL",  "N", 14, 2 }, ;
      { "NFDATSAI",  "D", 8 }, ;
      { "NFHORSAI",  "C", 8 }, ;
      { "NFPESBRU",  "N", 8, 2 }, ;
      { "NFPESLIQ",  "N", 8, 2 }, ;
      { "NFCADTRA",  "C", 6 }, ;
      { "NFVEICULO", "C", 10 }, ;
      { "NFESPECIE", "C", 10 }, ;
      { "NFQTDVOL",  "N", 10 }, ;
      { "NFCFOP",    "C", 6 }, ;
      { "NFCFOP2",   "C", 6 }, ;
      { "NFPAGFRE",  "C", 1 }, ;
      { "NFSTATUS",  "C", 1 }, ;
      { "NFOBS1",    "C", 250 }, ;
      { "NFOBS2",    "C", 250 }, ;
      { "NFOBS3",    "C", 250 }, ;
      { "NFOBS4",    "C", 250 }, ;
      { "NFLEIS",    "C", 140 }, ; // ate 20 decretos
      { "NFPEDIDO",  "C", 6 }, ;
      { "NFCTE",     "C", 44 }, ;
      { "NFNFE",     "C", 44 }, ;
      { "NFINFINC",  "C", 80 }, ;
      { "NFINFALT",  "C", 80 } }

   IF AppVersaoDbfAnt() < 99999999
      Aadd( mStruOk, { "NFMODFIS",  "C", 2 } )
      Aadd( mStruOk, { "NFCADEMI",  "C", 6 } ) // 0 = propria empresa
   ENDIF

   IF ! ValidaStru( "jpnota", mStruOk )
      MsgStop( "JPNOTA não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPNUMEROCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPNUMERO, verificando atualizações" )
   mStruOk := { ;
      { "NUTABELA",  "C", 10 }, ;
      { "NUCODIGO",  "C", 9  }, ;
      { "NUINFINC",  "C", 80 }, ;
      { "NUINFALT",  "C", 80 } }
   IF ! ValidaStru( "jpnumero", mStruOk )
      MsgStop( "jpnumero não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPPEDICreateDbf()

   LOCAL mStruOk

   SayScroll( "JPPEDI, verificando atualizações" )

   mStruOk := { ;
      { "PDPEDIDO",  "C", 6 }, ;
      { "PDPEDREL",  "C", 6 }, ;
      { "PDNOTREL",  "C", 9 }, ;
      { "PDFILIAL",  "C", 6 }, ;
      { "PDTRANSA",  "C", 6 }, ;
      { "PDCONF",    "C", 1 }, ;
      { "PDDATEMI",  "D", 8 }, ;
      { "PDDATNOT",  "D", 8 }, ; // acrescentado em 06/04/10
      { "PDDATPRE",  "D", 8 }, ;
      { "PDCLIFOR",  "C", 6 }, ;
      { "PDNOTFIS",  "C", 9 }, ;
      { "PDPERDES",  "N", 5, 2 }, ;
      { "PDPERADI",  "N", 5, 2 }, ;
      { "PDCONTATO", "C", 60 }, ;
      { "PDVENDEDOR", "C", 6 }, ;
      { "PDPEDCLI",  "C", 25 }, ;
      { "PDVALTAB",  "N", 14, 2 }, ;
      { "PDVALCUS",  "N", 14, 2 }, ;
      { "PDVALCUT",  "N", 14, 2 }, ;
      { "PDVALPRO",  "N", 14, 2 }, ;
      { "PDVALNOT",  "N", 14, 2 }, ;
      { "PDVALFRE",  "N", 14, 2 }, ;
      { "PDVALSEG",  "N", 14, 2 }, ;
      { "PDVALOUT",  "N", 14, 2 }, ;
      { "PDVALDES",  "N", 14, 2 }, ;
      { "PDVALADI",  "N", 14, 2 }, ;
      { "PDVALADU",  "N", 14, 2 }, ;
      { "PDVALIOF",  "N", 14, 2 }, ;
      { "PDPARCEL",  "C", 250, 0 }, ; // por enquanto grava 000 + vl.entrada com 12,2
      { "PDDOLAR",   "N", 14, 2 }, ;
      { "PDREACAO",  "C", 60 }, ;
      { "PDIIBAS",   "N", 14, 2 }, ;
      { "PDIIVAL",   "N", 14, 2 }, ;
      { "PDIPIBAS",  "N", 14, 2 }, ;
      { "PDIPIVAL",  "N", 14, 2 }, ;
      { "PDICMBAS",  "N", 14, 2 }, ;
      { "PDICMVAL",  "N", 14, 2 }, ;
      { "PDFCPVAL",  "N", 14, 2 }, ;
      { "PDSUBBAS",  "N", 14, 2 }, ;
      { "PDSUBVAL",  "N", 14, 2 }, ;
      { "PDDIFCAL",  "C",  1 }, ;
      { "PDDIFVALI", "N", 14, 2 }, ;
      { "PDDIFVALF", "N", 14, 2 }, ;
      { "PDISSBAS",  "N", 14, 2 }, ;
      { "PDISSVAL",  "N", 14, 2 }, ;
      { "PDPISBAS",  "N", 14, 2 }, ;
      { "PDPISVAL",  "N", 14, 2}, ;
      { "PDCOFBAS",  "N", 14, 2 }, ;
      { "PDCOFVAL",  "N", 14, 2 }, ;
      { "PDICSBAS",  "N", 14, 2 }, ;
      { "PDICSALI",  "N", 5, 2 }, ;
      { "PDICSVAL",  "N", 14, 2 }, ;
      { "PDIMPVAL",  "N", 14, 2 }, ;
      { "PDDATCON",  "D", 8 }, ;
      { "PDDATCAN",  "D", 8 }, ;
      { "PDMOTCAN",  "C", 6 }, ;
      { "PDTRANSP",  "C", 6 }, ;
      { "PDFORPAG",  "C", 6 }, ;
      { "PDEMAIL",   "C", 200 }, ; // Retorno em 19/02/09
      { "PDOBS",     "C", 200 }, ;
      { "PDLEIS",    "C", 140 }, ; // ate 20 decretos
      { "PDSTATUS",  "C", 1 }, ;
      { "PDINFINC",  "C", 80 }, ;
      { "PDINFALT",  "C", 80 } }

   IF ! ValidaStru( "JPPEDI", mStruOk )
      MsgStop( "JPPEDI não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPPRECOCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPPRECO, verificando atualizações" )
   mStruOk := { ;
      { "PCITEM",     "C", 6 }, ;
      { "PCCADAS",    "C", 6 }, ;
      { "PCFORPAG",   "C", 6 }, ;
      { "PCREAJUSTE", "C", 1 }, ;
      { "PCVALOR",    "N", 15, 4 }, ;
      { "PCSTATUS",   "C", 6 }, ;
      { "PCOBS",      "C", 50 }, ;
      { "PCINFINC",   "C", 80 }, ;
      { "PCINFALT",   "C", 80 } }
   IF ! ValidaStru( "jppreco", mStruOk )
      MsgStop( "JPPRECO não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPPRETABCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPPRETAB , verificando atualizações" )
   mStruOk := { ;
      { "PCITEM",   "C", 6 }, ;
      { "PCVALCUS", "N", 15, 4 }, ;
      { "PCVALOR",  "N", 15, 4 }, ;
      { "PCDATA",   "D", 8 }, ;
      { "PCINFINC", "C", 80 }, ;
      { "PCINFALT", "C", 80 } }
   IF ! ValidaStru( "jppretab", mStruOk )
      MsgStop( "JPPRETAB não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

   // Chamada de fora deste PRG

FUNCTION JPREGUSOCreateDbf( lUpdate )

   LOCAL mStruOk

   hb_Default( @lUpdate, .T. )
   IF AppcnMySqlLocal() != NIL .AND. ! File( "JPREGUSO.DBF" )
      RETURN NIL
   ENDIF
   SayScroll( "JPREGUSO, verificando atualizações" )
   mStruOk := { ;
      { "RUARQUIVO", "C", 9 }, ;
      { "RUCODIGO",  "C", 9 }, ;
      { "RUTEXTO",   "C", 100 }, ;
      { "RUINFINC",  "C", 80 } }
   IF ! ValidaStru( "jpreguso", mStruOk )
      MsgStop( "JPREGUSO não disponível!" )
      QUIT
   ENDIF
   IF ! lUpdate // apenas cria dbf
      RETURN NIL
   ENDIF
   IF AppVersaoDbfAnt() > 20150401
      RETURN NIL
   ENDIF
   IF ! UseSoDbf( "jpreguso" )
      QUIT
   ENDIF
   GOTO TOP
   GrafTempo( "Convertendo registro de uso" )
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      IF AppVersaoDbfAnt() < 20141226
         IF Val( jpreguso->ruCodigo ) > 0
            RecLock()
            REPLACE jpreguso->ruCodigo WITH StrZero( Val( jpreguso->ruCodigo ), 9 )
            RecUnlock()
         ENDIF
      ENDIF
      SKIP
   ENDDO
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION JPREFCTACreateDbf()

   LOCAL mStruOk

   SayScroll( "JPREFCTA, verificando atualizações" )
   mStruOk := {}
   AAdd( mStruOk, { "RCCODIGO", "C", 20 } )
   AAdd( mStruOk, { "RCDESCRI", "C", 100 } )
   AAdd( mStruOk, { "RCVALDE",  "C", 10 } )
   AAdd( mStruOk, { "RCVALATE", "C", 10 } )
   AAdd( mStruOk, { "RCTIPO",   "C", 1 } )
   AAdd( mStruOk, { "RCORGAO",  "C", 3 } )
   AAdd( mStruOk, { "RCINFINC", "C", 80 })
   AAdd( mStruOk, { "RCINFALT", "C", 80 } )
   IF ! ValidaStru( "jprefcta", mStruOk )
      MsgStop( "jprefcta não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPSENHACreateDbf()

   LOCAL mStruOk

   SayScroll( "JPSENHA, verificando atualizações" )
   mStruOk := { ;
      { "PWTYPE",     "C", 1 }, ;
      { "PWFIRST",    "C", 60 }, ;
      { "PWLAST",     "C", 60 }, ;
      { "PWINFINC",   "C", 80 }, ;
      { "PWINFALT",   "C", 80 } }
   IF AppVersaoDbfAnt() < 20170811
      AAdd( mStruOk, { "TIPO", "C", 1 } )
      AAdd( mStruOk, { "SENHA", "C", 61 } )
   ENDIF
   IF ! ValidaStru( "jpsenha", mStruOk )
      MsgStop( "jpsenha não disponível!" )
      QUIT
   ENDIF
   IF AppVersaoDbfAnt() < 20150101
      JPSENHADefault()
   ENDIF

   RETURN NIL

STATIC FUNCTION JPTABELCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPTABEL, verificando atualizações" )

   mStruOk := { ;
      { "AXTABELA",  "C", 6 }, ;
      { "AXCODIGO",  "C", 6 }, ;
      { "AXDESCRI",  "C", 80 }, ;
      { "AXPARAM01", "C", 6 }, ;
      { "AXPARAM02", "C", 6 }, ;
      { "AXPARAM03", "C", 80 }, ;
      { "AXPARAM04", "C", 80 }, ;
      { "AXPARAM05", "C", 80 }, ;
      { "AXINFINC",  "C", 80 }, ;
      { "AXINFALT",  "C", 80 } }

   IF ! ValidaStru( "jptabel", mStruOk )
      MsgStop( "jptabel não disponível!" )
      QUIT
   ENDIF
   IF AppVersaoDbfAnt() < 20130101
      JPTABELDefault()
   ENDIF
   IF AppVersaoDbfAnt() > 20140101
      RETURN NIL
   ENDIF

   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION JPTRANSACreateDbf()

   LOCAL mStruOk

   SayScroll( "JPTRANSA, verificando atualizações" )
   mStruOk := { ;
      { "TRTRANSA",  "C", 6 }, ;
      { "TRDESCRI",  "C", 80 }, ;
      { "TRREACAO",  "C", 100 }, ;
      { "TRINFINC",  "C", 80 }, ;
      { "TRINFALT",  "C", 80 } }
   IF ! ValidaStru( "jptransa", mStruOk )
      MsgStop( "JPTRANSA não disponível!" )
      QUIT
   ENDIF
   IF AppVersaoDbfAnt() >= 20160706
      RETURN NIL
   ENDIF
   IF ! UseSoDbf( "jptransa", .T. )
      QUIT
   ENDIF

   IF ! AbreArquivos( "jptransa" )
      QUIT
   ENDIF

   IF AppVersaoDbfAnt() < 20110101
      SayScroll( "Verificando transacoes" )
      ChecaTransacao( "001000", "COMPRA", "C+1,CULTENT" )
      ChecaTransacao( "502001", "DEVOLUCAO DE COMPRA", "C-1" )
      ChecaTransacao( "503000", " VENDA", "C+R,N-1,NULTSAI" )
      ChecaTransacao( "004503", "DEVOLUCAO DE VENDA", "C+1" )
      ChecaTransacao( "519000", "REMESSA P/ ARMAZEM", "C+R,N+2,N-1" )
      ChecaTransacao( "020519", "RETORNO DE REMESSA P/ ARMAZEM", "C+1,C-2" )
      ChecaTransacao( "519000", "REMESSA P/ ARMAZEM", "C+R,N+2,N-1" )
      ChecaTransacao( "020519", "RETORNO DE REMESSA P/ ARMAZEM", "C+1,C-2" )
      ChecaTransacao( "517000", "SAIDA EM COMODATO", "C+R,N-1" )
      ChecaTransacao( "018517", "RETORNO SAIDA EM COMODATO", "C+1" )
      ChecaTransacao( "555000", "VENDA DO ATIVO IMOBILIZADO", "C-1" )
      ChecaTransacao( "001000", "COMPRA", "C+1,CULTENT" )
      ChecaTransacao( "515000", "SAIDA DE BRINDES", "XX" )
      ChecaTransacao( "509000", "SAIDA P/ DEMONSTRACAO", "C+R,N-1" )
      ChecaTransacao( "010509", "RETORNO DE SAIDA P/ DEMONSTRACAO", "C+1" )
      ChecaTransacao( "511000", "SAIDA P/ BENEFIC/INDUSTRIALIZACAO", "C+R,N-1" )
      ChecaTransacao( "012511", "RETORNO DE SAIDA P/ BENEFIC/INDUSTRIALIZACAO", "C+1" )
      ChecaTransacao( "013000", "ENTRADA P/ BENEFIC/INDUSTRIALIZACAO", "XX" )
      ChecaTransacao( "514013", "RETORNO DE ENTRADA P/ BENEFIC/INDUSTRIALIZACAO", "XX" )
      ChecaTransacao( "499000", "X OUTRO TIPO DE ENTRADA", "C+1" )
      ChecaTransacao( "998000", "X OUTRO TIPO DE SAIDA", "C+R,N-1" )
   ENDIF

   IF AppVersaoDbfAnt() < 20160706
      GOTO TOP
      DO WHILE ! Eof()
         IF "IMPOSTO" $ jptransa->trReacao
            RecLock()
            REPLACE jptransa->trReacao WITH StrTran( jptransa->trReacao, "IMPOSTO", "CONSUMIDOR" )
         ENDIF
         SKIP
      ENDDO
   ENDIF
   CLOSE DATABASES

   RETURN NIL

FUNCTION ChecaTransacao( cTransacao, cDescricao, cReacao )

   SEEK cTransacao
   IF Eof()
      RecAppend()
      REPLACE jptransa->trTransa WITH cTransacao, ;
         jptransa->trDescri WITH cDescricao, ;
         jptransa->trReacao WITH cReacao
      RecUnlock()
   ENDIF

   RETURN NIL

STATIC FUNCTION JPUFCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPUF, verificando atualizações" )
   mStruOk := { ;
      { "UFUF",     "C", 2 }, ;
      { "UFDESCRI", "C", 80 }, ;
      { "UFTRIUF",  "C", 6 }, ;
      { "UFINFINC", "C", 80 }, ;
      { "UFINFALT", "C", 80 } }
   IF ! ValidaStru( "jpuf", mStruOk )
      MsgStop( "jpuf não disponível!" )
      QUIT
   ENDIF
   IF AppVersaoDbfAnt() < 20150101
      JPUFDefault()
   ENDIF

   RETURN NIL

STATIC FUNCTION JPVEICULCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPVEICUL, verificando atualizações" )
   mStruOk := { ;
      { "VENUMLAN",   "C", 6 }, ;
      { "VEPLACA",    "C", 8 }, ;
      { "VEMOTORI",   "C", 30 }, ;
      { "VETELEFONE", "C", 20 }, ;
      { "VEPESO",     "N", 6 }, ;
      { "VECAPACTOT", "N", 6 }, ;
      { "VECAPAC1",   "N", 6 }, ;
      { "VECAPAC2",   "N", 6 }, ;
      { "VECAPAC3",   "N", 6 }, ;
      { "VECAPAC4",   "N", 6 }, ;
      { "VECAPAC5",   "N", 6 }, ;
      { "VECAPAC6",   "N", 6 }, ;
      { "VECAPAC7",   "N", 6 }, ;
      { "VECAPAC8",   "N", 6 }, ;
      { "VECAPAC9",   "N", 6 }, ;
      { "VEINFINC",   "C", 80 }, ;
      { "VEINFALT",   "C", 80 } }
   IF ! ValidaStru( "jpveicul", mStruOk )
      MsgStop( "JPVEICUL não disponível!" )
      QUIT
   ENDIF

   RETURN NIL

STATIC FUNCTION JPVENDEDCreateDbf()

   LOCAL mStruOk

   SayScroll( "JPVENDED, verificando atualizações" )
   mStruOk := { ;
      { "VDVENDEDOR", "C", 6 }, ;
      { "VDDESCRI",   "C", 60 }, ;
      { "VDCOMISSAO", "N", 7, 3 }, ;
      { "VDLSTVEND",  "C", 250 }, ;
      { "VDINFINC",   "C", 80 }, ;
      { "VDINFALT",   "C", 80 } }
   IF ! ValidaStru( "jpvended", mStruOk )
      MsgStop( "JPVENDED não disponivel!" )
      QUIT
   ENDIF

   RETURN NIL
