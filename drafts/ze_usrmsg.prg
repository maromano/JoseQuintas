/*
PUSRMSG - MENSAGENS ENTRE USUARIOS
2013.12 José Quintas
*/

#include "inkey.ch"
#include "hbclass.ch"
#include "hbgtinfo.ch"
#include "hbthread.ch"

//Aadd( AppMessage(), MessageClass():New() )
//AppMessage()[ 1 ]:cUser := "SysMain"
//Aadd( AppMessage(), MessageClass():New() )
//AppMessage()[ 2 ]:cUser := "SysSelect"
//AppMessage()[ 1 ]:Execute()
//wvgSetAppWindow():Show() // pra acertar foco

STATIC FUNCTION AppMessage()

   STATIC AppMessage := { NIL, NIL }

   RETURN AppMessage

PROCEDURE PUSRMSG

   IF AppMessage()[ 2 ]:lExit
      AppMessage()[ 2 ]:Execute()
   ENDIF
   IF AppMessage()[ 1 ]:lExit
      AppMessage()[ 2 ]:Execute()
   ENDIF

   RETURN

CREATE CLASS MessageClass

   VAR    cUser         INIT ""                            // User of window
   VAR    lExit         INIT .T.                           // End task
   VAR    acMessage     INIT {}                            // Text to show
   METHOD MessageFromUser( cUser, cDateFrom, cText )    // Distribute message to user
   METHOD SendMessage()                                 // Send a new message
   METHOD Execute( cUser )                              //
   METHOD UserExecute()                                 // Execute for user window
   METHOD MainExecute()                                 // Execute for main window
   METHOD CheckMasterThread()                           // Check if master thread is running
   METHOD Close()                                       // Close window
   METHOD SelectExecute()

   ENDCLASS

METHOD Close() CLASS MessageClass

   LOCAL nCont

   ::lExit := .T.
   IF ::cUser == "SysMain"
      FOR nCont = 2 TO Len( AppMessage() )
         AppMessage()[ nCont ]:Close()
      NEXT
   ENDIF

   RETURN NIL

METHOD Execute( cUser ) CLASS MessageClass

   IF cUser != NIL
      ::cUser := cUser
   ENDIF
   ::lExit := .F.
   IF ::cUser == "SysMain"
      hb_ThreadStart( { || ::MainExecute() } )
   ELSEIF ::cUser == "SysSelect"
      hb_ThreadStart( { || ::SelectExecute() } )
   ELSE
      hb_ThreadStart( { || ::UserExecute() } )
   ENDIF

   RETURN NIL

METHOD UserExecute() CLASS MessageClass

   LOCAL nKey, nCont

   hb_gtReload( hb_gtInfo( HB_GTI_VERSION ) )
   AppInitSets()
   SetMode( 40, 40 )
   SetColor( SetColorNormal() )
   CLS
   @ 0, 0 SAY Padc( ::cUser, MaxCol() + 1 ) COLOR SetColorTitulo()
   HB_GtInfo( HB_GTI_WINTITLE, ::cUser + "(PARA " + AppUserName() + ")" )
   //   HB_GtInfo( HB_GTI_RESIZEMODE, HB_GTI_RESIZEMODE_ROWS )
   Mensagem( "Tecle ENTER para enviar mensagem" )
   DO WHILE ! ::lExit
      FOR nCont = 1 TO Len( ::acMessage )
         IF ! Empty( ::acMessage[ nCont, 1 ] )
            SayScroll( ::acMessage[ nCont, 1 ] )
            SayScroll( Space(3) + ::acMessage[ nCont, 2 ] )
            ::acMessage[ nCont, 1 ] := ""
            ::acMessage[ nCont, 2 ] := ""
            wvgSetAppWindow():Show()
         ENDIF
      NEXT
      nKey := Inkey(1)
      IF nKey == K_ESC
         EXIT
      ENDIF
      IF nKey == K_ENTER
         ::SendMessage()
      ENDIF
      ::CheckMasterThread()
   ENDDO
   ::lExit := .T.

   RETURN NIL

METHOD CheckMasterThread() CLASS MessageClass

   IF AppThreadMaster() != NIL
      IF hb_ThreadWait( AppThreadMaster(), 0.1, .T. ) == 1
         ::lExit := .T.
      ENDIF
   ENDIF

   RETURN NIL

METHOD MainExecute() CLASS MessageClass

   LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() ), lError
   MEMVAR m_Prog
   PUBLIC m_Prog := "PUSRMSG"

   hb_gtReload( hb_gtInfo( HB_GTI_VERSION ) )
   AppInitSets()
   SetMode( 4, 4 )
   //   SetColor( SetColorNormal() )
   //   BEGIN SEQUENCE WITH __BreakBlock()
   //      cnMySql:Open( .F. )
   //   END SEQUENCE
   //   CLS
   HB_GtInfo( HB_GTI_WINTITLE, "Verificando mensagens" )
   //   HB_GtInfo( HB_GTI_RESIZEMODE, HB_GTI_RESIZEMODE_ROWS )
   wvgSetAppWindow():Hide()
   DO WHILE ! ::lExit
      lError := .T.
      BEGIN SEQUENCE WITH __BreakBlock()
         //cnMySql:Open()
         cnMySql:cSql := "SELECT * FROM JPUSRMSG WHERE MSEMPRESA=" + StringSql( AppEmpresaApelido() ) + " AND MSTO=" + StringSql( AppUserName() ) + " AND MSOKTO='N'"
         cnMySql:Execute( , .F. )
         DO WHILE ! cnMySql:Eof()
            IF cnMySql:StringSql( "MSTO" ) == Trim( AppUserName() )
               //               SayScroll( "Chegou mensagem " + cnMySql:StringSql( "MSFROM" ) )
               ::MessageFromUser( cnMySql:StringSql( "MSFROM" ), cnMySql:StringSql( "MSDATEFROM" ) + " " + cnMySql:StringSql( "MSFROM" ), cnMySql:StringSql( "MSTEXT" ) )
               WITH OBJECT cnMySql
                  :QueryCreate()
                  :QueryAdd( "MSOKTO", "S" )
                  :QueryAdd( "MSDATETO", Transform( Dtos( Date() ), "@R 9999-99-99" ) + " " + Time() )
                  :QueryExecute( "JPUSRMSG", "MSNUMLAN=" + NumberSql( cnMySql:NumberSql( "MSNUMLAN" ) ) )
               END WITH
            ENDIF
            cnMySql:MoveNext()
         ENDDO
         cnMySql:CloseRecordset()
         //cnMySql:CloseConnection()
         lError := .F.
      END SEQUENCE
      IF lError .OR. Inkey(15) == K_ESC
         ::lExit := .T.
      ENDIF
      ::CheckMasterThread()
   ENDDO

   RETURN NIL

METHOD SelectExecute() CLASS MessageClass

   LOCAL aLstUser := {}, nOpcUser := 0, cUser

   hb_gtReload( hb_gtInfo( HB_GTI_VERSION ) )
   AppInitSets()
   SetMode( 15, 40 )
   HB_GtInfo( HB_GTI_WINTITLE, "Lista de Usuários" )
   SetColor( SetColorNormal() )
   CLS
   //   HB_GtInfo( HB_GTI_RESIZEMODE, HB_GTI_RESIZEMODE_ROWS )
   IF ! AbreArquivos( "jpsenha" )
      RETURN NIL
   ENDIF
   GOTO TOP
   SEEK "S"
   DO WHILE jpsenha->pwType == "S" .AND. ! Eof()
      cUser := pw_Descriptografa( jpsenha->First )
      IF Trim( cUser ) != Trim( AppUserName() )
         AAdd( aLstUser, pw_Descriptografa( jpsenha->First ) )
      ENDIF
      SKIP
   ENDDO
   IF AppUserName() != "JOSEQ"
      Aadd( aLstUser, Pad( "JOSEQ", 10 ) )
   ENDIF
   CLOSE DATABASES
   DO WHILE ! ::lExit
      Mensagem( "Selecione usuario a enviar mensagem" )
      wAchoice( 2, 2, aLstUser, @nOpcUser, "USUÁRIO" )
      Mensagem()
      IF LastKey() == K_ESC .OR. nOpcUser == 0
         EXIT
      ENDIF
      ::MessageFromUser( Trim( aLstUser[ nOpcUser ] ), "", "" )
   ENDDO
   ::lExit := .T.
   ::Close()

   RETURN NIL

METHOD MessageFromUser( cUser, cDateFrom, cText ) CLASS MessageClass

   LOCAL nNumWindow := 0, nCont

   FOR nCont = 1 TO Len( AppMessage() )
      IF AppMessage()[ nCont ]:cUser == cUser
         nNumWindow := nCont
         EXIT
      ENDIF
   NEXT
   IF nNumWindow == 0
      Aadd( AppMessage(), MessageClass():New() )
      nNumWindow := Len( AppMessage() )
      AppMessage()[ nNumWindow ]:Execute( cUser )
   ELSEIF AppMessage()[ nNumWindow ]:lExit
      AppMessage()[ nNumWindow ]:= MessageClass():New()
      AppMessage()[ nNumWindow ]:Execute( cUser )
   ENDIF
   IF ! Empty( cText )
      Aadd( AppMessage()[ nNumWindow ]:acMessage, { cDateFrom, cText, .T. }  )
   ENDIF

   RETURN NIL

METHOD SendMessage() CLASS MessageClass

   LOCAL cText := Space(100), GetList := {}, cDateFrom, cnMySql := ADOClass():New( AppcnMySqlLocal() )
   MEMVAR m_Prog
   PUBLIC m_Prog

   wSave( MaxRow()-1, 0, MaxRow(), MaxCol() )
   Mensagem( "Digite mensagem a ser enviada, ESC abandona" )
   @ MaxRow(), 0 SAY "Mensagem:" GET cText PICTURE "@S" + Ltrim( Str( MaxCol() - 10 ) )
   READ
   wRestore()
   IF LastKey() == K_ESC .OR. Empty( cText ) .OR. ::lExit
      RETURN NIL
   ENDIF
   BEGIN SEQUENCE WITH __BreakBlock()
      //cnMySql:Open( .F. )
      cDateFrom := Transform( Dtos( Date() ), "@R 9999-99-99" ) + " " + Time()
      WITH OBJECT cnMySql
         :QueryCreate()
         :QueryAdd( "MSEMPRESA",  AppEmpresaApelido() )
         :QueryAdd( "MSFROM",     AppUserName() )
         :QueryAdd( "MSTO",       ::cUser )
         :QueryAdd( "MSDATEFROM", cDateFrom )
         :QueryAdd( "MSMSTEXT",   cText )
         :QueryAdd( "MSINFINC",   LogInfo() )
         :QueryExecuteInsert( "JPUSRMSG" )
      END WITH
      //cnMySql:CloseConnection()
      Aadd( ::acMessage, { cDateFrom, cText } )
   END SEQUENCE

   RETURN NIL
