/*
JPA - MAIN
2013.05 Jos� Quintas

2018.03.26 ***teste*** Fecha ADO antes do NETIO
*/

#require "hbnetio.hbc"

#include "josequintas.ch"
#include "hbclass.ch"
#include "hbthread.ch"
#include "hbgtinfo.ch"
#include "directry.ch"

PROCEDURE Main

   PARAMETERS cParam
   MEMVAR cParam
   LOCAL xParam, nThreads := 2, cPath, oExeList

   cPath    := hb_FNameDir( hb_ProgName() )
   oExeList := Directory( cPath + "JPA*.EXE" )
   ASort( oExeList, , , { | a, b | Dtos( a[ F_DATE ] ) + a[ F_TIME ] > Dtos( b[ F_DATE ] ) + b[ F_TIME ] } )
   IF Len( oExeList ) < 1
      MsgExclamation( "Nenhum JPA*.EXE na pasta atual. Prov�vel nome de EXE errado" )
      QUIT
   ENDIF
   IF Upper( oExeList[ 1, F_NAME ] ) != Upper( hb_FNameNameExt( hb_ProgName() ) )
      MsgExclamation( "JPA executado nao eh o JPA mais recente." + hb_Eol() + ;
         "Corrija o atalho para SJPA.EXE" + hb_Eol() + ;
         "Agora, trocando para o JPA mais recente da pasta" )
      WAPI_ShellExecute( NIL, "open", cPath + oExeList[ 1, F_NAME ], cParam, hb_cwd(), SW_SHOWNORMAL )
      QUIT
   ENDIF
   IF cParam != NIL
      IF "/windows" $ cParam
         AppMenuWindows( .T. )
      ENDIF
      xParam := cParam
   ENDIF
   hb_gtReload( "WVG" )
   ze_NetIoOpen()
   AppInitSets( .F. ) // pra nao criar tela pra thread principal
   hb_Default( @xParam, "" )
   Inkey(1)
   hb_ThreadStart( { || Sistema( xParam ) } )
   Inkey(2)
   //_hmge_Init()
   DO WHILE nThreads > 1
      __vmCountThreads( @nThreads, 0 )
      IF AppcnMySqlLocal() != NIL
         IF AppcnMySqlLocal():State != AD_STATE_CLOSED
            AppcnMySqlLocal():Execute( "SHOW PROCESSLIST" )
         ENDIF
      ENDIF
      Inkey(2)
   ENDDO
   //hb_ThreadWaitForAll()
   IF hb_IsObject( AppcnServerJPA() )
      BEGIN SEQUENCE WITH __BreakBlock()
         IF AppcnServerJPA():State != AD_STATE_CLOSED
            AppcnServerJPA():Close()
         ENDIF
      END SEQUENCE
   ENDIF
   IF hb_IsObject( AppcnMySqlLocal() )
      BEGIN SEQUENCE WITH __BreakBlock()
         IF AppcnMySqlLocal():State != AD_STATE_CLOSED
            AppcnMySqlLocal():Close()
         ENDIF
      END SEQUENCE
   ENDIF
   ze_NetIoClose()
   Inkey(2)

   RETURN

FUNCTION RunModule( cModule, cTitulo, p1, p2, p3 )

   LOCAL mHrInic

   IF AppIsMultiThread() .OR. pCount() > 2
      GTSetupFont( .T. )
      hb_ThreadStart( { || DoPrg( cModule, cTitulo, p1, p2, p3 ) } )
   ELSE
      wSave()
      Mensagem()
      SayTitulo( cTitulo )
      Cls()
      @ MaxRow() - 2, 0 TO MaxRow() - 2, MaxCol() COLOR SetColorTraco()
      mHrInic := Time()
      Do( cModule, p1, p2, p3 )
      LogDeUso( mHrInic, cModule )
      wRestore()
   ENDIF

   RETURN NIL

FUNCTION DoPrg( cModule, cTitulo, p1, p2, p3 )

   LOCAL mHrInic //, oStatusbar
   MEMVAR m_Prog
   PRIVATE m_Prog

   m_Prog := cModule
   hb_gtReload( "WVG" )
   AppInitSets()
   HB_GtInfo( HB_GTI_WINTITLE, cTitulo )
   // oStatusbar := wvgStatusBar():New( wvgSetAppWindow(), , , { -2, -2 } , , .T. ):Create()
   SetColor( SetColorNormal() )
   CLS
   SayTitulo( cTitulo )
   @ MaxRow() - 2, 0 TO MaxRow() - 2, MaxCol() COLOR SetColorTraco()
   mHrInic := Time()
   Do( cModule, p1, p2, p3 )
   LogDeUso( mHrInic, cModule )
   //  HB_SYMBOL_UNUSED( oStatusbar )

   RETURN NIL

CREATE CLASS RunWhileThreadClass

   VAR lExit        INIT .F.
   VAR nThreadId
   VAR nInterval    INIT 600
   VAR cWindowTitle INIT ""
   VAR bCode
   METHOD New()     INLINE ::nThreadId := hb_ThreadSelf(), SELF
   METHOD Execute( bCode )

   ENDCLASS

METHOD Execute( bCode ) CLASS RunWhileThreadClass

   LOCAL nCont

   hb_gtReload( hb_gtInfo( HB_GTI_VERSION ) )
   IF bCode != NIL
      ::bCode := bCode
   ENDIF
   AppInitSets()
   HB_GtInfo( HB_GTI_WINTITLE, ::cWindowTitle )
   wvgSetAppWindow():Hide()
   DO WHILE ! ::lExit
      Eval( ::bCode )
      FOR nCont = 1 TO ::nInterval
         hb_ReleaseCPU()
         IF hb_ThreadWait( ::nThreadId, 0.1, .T. ) == 1
            ::lExit := .T.
         ENDIF
         Inkey(1)
         IF ::lExit
            EXIT
         ENDIF
      NEXT
   ENDDO

   RETURN NIL

PROCEDURE HB_GTSYS()

   REQUEST HB_GT_GUI_DEFAULT
   REQUEST HB_GT_WVG
   REQUEST HB_GT_WGU
   REQUEST HB_GT_WVT

   RETURN

   // Inherit copy of public
   // hb_threadJoin( hb_threadStart( HB_BITOR( HB_THREAD_INHERIT_PUBLIC, HB_THREAD_MEMVARS_COPY ), @thFunc() ) )

   // ? "Inherit copy of privates."
   // hb_threadJoin( hb_threadStart( HB_BITOR( HB_THREAD_INHERIT_PRIVATE, HB_THREAD_MEMVARS_COPY ), @thFunc() ) )

   // ? "Inherit copy of publics and privates."
   // hb_threadJoin( hb_threadStart( HB_BITOR( HB_THREAD_INHERIT_MEMVARS, HB_THREAD_MEMVARS_COPY ), @thFunc() ) )

   // s_mainThreadID := hb_threadSelf()

   // RunThread( /* HB_BITOR( HB_THREAD_INHERIT_PUBLIC, HB_THREAD_MEMVARS_COPY ) /* @DoPrg( cModule, cTitulo ) )
