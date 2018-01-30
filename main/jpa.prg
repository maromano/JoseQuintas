/*
JPA - MAIN
2013.05 José Quintas
*/

#require "hbnetio.hbc"

#include "josequintas.ch"
#include "hbclass.ch"
#include "hbthread.ch"
#include "hbgtinfo.ch"

PROCEDURE Main

   PARAMETERS cParam
   MEMVAR cParam
   LOCAL xParam

   IF cParam != NIL
      IF "/windows" $ cParam
         AppMenuWindows( .T. )
      ENDIF
      xParam := cParam
   ENDIF
   ze_NetIoOpen()
   AppInitSets( .F. ) // pra nao criar tela pra thread principal
   hb_Default( @xParam, "" )
   Inkey(1)
   hb_ThreadStart( { || Sistema( xParam ) } )
   Inkey(2)
   //_hmge_Init()
   hb_ThreadWaitForAll()
   ze_NetIoClose()
   IF ! ( AppcnServerJPA() == NIL )
      BEGIN SEQUENCE WITH __BreakBlock()
         IF AppcnServerJPA():State != AD_STATE_CLOSED
            AppcnServerJPA():Close()
         ENDIF
      END SEQUENCE
   ENDIF
   IF ! ( AppcnMySqlLocal() == NIL )
      BEGIN SEQUENCE WITH __BreakBlock()
         IF AppcnMySqlLocal():State != AD_STATE_CLOSED
            AppcnMySqlLocal():Close()
         ENDIF
      END SEQUENCE
   ENDIF
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
   hb_gtReload( hb_gtInfo( HB_GTI_VERSION ) )
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

   REQUEST HB_GT_WVG_DEFAULT

   RETURN

   // Inherit copy of public
   // hb_threadJoin( hb_threadStart( HB_BITOR( HB_THREAD_INHERIT_PUBLIC, HB_THREAD_MEMVARS_COPY ), @thFunc() ) )

   // ? "Inherit copy of privates."
   // hb_threadJoin( hb_threadStart( HB_BITOR( HB_THREAD_INHERIT_PRIVATE, HB_THREAD_MEMVARS_COPY ), @thFunc() ) )

   // ? "Inherit copy of publics and privates."
   // hb_threadJoin( hb_threadStart( HB_BITOR( HB_THREAD_INHERIT_MEMVARS, HB_THREAD_MEMVARS_COPY ), @thFunc() ) )

   // s_mainThreadID := hb_threadSelf()

   // RunThread( /* HB_BITOR( HB_THREAD_INHERIT_PUBLIC, HB_THREAD_MEMVARS_COPY ) /* @DoPrg( cModule, cTitulo ) )
