/*
ZE_APPINICIALIZA
José Quintas
*/

REQUEST HB_CODEPAGE_PTISO

#include "josequintas.ch"
#include "inkey.ch"
#include "hbgtinfo.ch"
#include "directry.ch"

FUNCTION AppInicializa()

   AppInitSets()
   AppInitDisk()
   CheckSystemDate()

   RETURN NIL

FUNCTION AppInitSets( lVisible )

   hb_Default( @lVisible, .T. )
   Set( _SET_CODEPAGE, "PTISO" )
   hb_gtInfo( HB_GTI_COMPATBUFFER, .F. )
   SetBlink(.T.)
   SetCancel(.F.)
   Set( _SET_HBOUTLOGINFO, GetEnv( "CLIENTNAME" ) + " " + GetEnv( "COMPUTERNAME" ) + " " + GetEnv( "USERNAME" ) )
   SET CONFIRM    ON
   SET DATE       BRITISH
   SET DECIMALS   TO 6 // não vão corrigir o Harbour
   SET DELETED    ON
   SET EPOCH      TO Year( Date() ) - 90
   SET EXCLUSIVE  OFF
   SET SCOREBOARD OFF
   SET STATUS     OFF
   SET WRAP       OFF
   ReadExit( .T. )
   SET KEY K_F1          TO HELP
   SET KEY K_ALT_S       TO GoDos
   SET KEY K_ALT_M       TO ChangeMultiThread
   SET KEY K_SH_F9       TO Calendario
   SET KEY K_SH_F10      TO Calculadora
   SET KEY K_F9          TO Pesquisa
   SET KEY K_F10         TO Pesquisa
   SET KEY K_ALT_Q       TO AltC
   RddSetDefault( "DBFCDX" )
   Sx_AutoOpen( .F. )
   SET EVENTMASK TO INKEY_ALL - INKEY_MOVE + HB_INKEY_GTEVENT // está atrapalhando aceitar eventos de GT
   IF lVisible
      IF Upper( GetEnv( "COMPUTERNAME" ) ) == "SERVERJPA"
         SetMode( 50, 132 )
      ELSE
         SetMode( 40, 132 ) // menor que 130 colunas nao visualiza texto de ocorrencias, 132 cabe relatorios matriciais
      ENDIF
      GtSetupFont()
      GtSetupPalette()
      CLS
   ENDIF
   //wvt_SetGui(.T.)
   //wvt_SetMouseMove( .T. )
   hb_gtInfo( HB_GTI_ICONRES, "AppIcon" )
   hb_gtInfo( HB_GTI_WINTITLE, "Sistema JPA" )
   hb_gtInfo( HB_GTI_SELECTCOPY, .T. )
   hb_gtInfo( HB_GTI_MAXIMIZED, .F. )
   hb_gtInfo( HB_GTI_CLOSABLE, .F. )
   // hb_gtInfo( HB_GTI_STDERRCON, .T. )
   hb_gtInfo( HB_GTI_INKEYFILTER, { | nKey | MyInkeyFilter( nKey ) } )

   RETURN NIL

STATIC FUNCTION AppInitDisk()

   LOCAL mStruOk

   hb_vfDirMake( "TEMP" )
   hb_vfDirMake( "IMPORTA" )
   hb_vfDirMake( "EXPORTA" )
   hb_vfDirMake( "NFE" )
   hb_vfDirMake( "ITAU" )
   hb_vfDirMake( "XML" )
   IF ! File( "jpconfi.dbf" ) .AND. AppDatabase() == DATABASE_DBF
      mStruOk := { ;
         { "CNF_NOME","C",20,0 }, ;
         { "CNF_PARAM", "C", 55, 0 } }
      dbCreate( "jpconfi.dbf", mStruOk )
   ENDIF
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION CheckSystemDate()

   LOCAL cDate := "", oFile

   FOR EACH oFile IN Directory( "*.DBF" )
      IF Dtos( oFile[ F_DATE ] ) > cDate
         cDate := Dtos( oFile[ F_DATE ] )
      ENDIF
   NEXT
   IF Dtos( Date() ) < cDate
      IF ! MsgYesNo( "Data do computador " + Dtoc( Date() ) + " menor que última data de arquivo " + cDate + ". Prossegue assim mesmo?" )
         CLS
         QUIT
      ENDIF
      IF ! MsgYesNo( "Vai se responsabilizar por eventual estrago?" )
         CLS
         QUIT
      ENDIF
   ENDIF

   RETURN NIL
