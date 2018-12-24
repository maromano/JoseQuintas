/*
ERRORSYS                                                       *

...
2014.04.04.1355 - Nome do usuário JPA
2014.07.06.2130 - Ajuste ref. dos error 64 pra tentar contornar
2014.07.22.2130 - Ajuste ref. dos error 64 situações específicas
2014.08.08.1026 - Não tenta novamente em erro gravação
2014.09.24.1825 - Tenta somente se for erro 64 ref servidor
2014.10.28.0910 - Ajuste no texto
2016.06.30.1120 - Formatação do fonte
*/

#include "error.ch"
#include "hbgtinfo.ch"

// put messages to STDERR
#command ? <list,...>   =>  ?? hb_Eol() ; ?? <list>
#command ?? <list,...>  =>  OutErr(<list>)

* Note:  automatically executes at startup

PROCEDURE ERRORSYS

   ErrorBlock( { | e | JoseQuintasError( e ) } )

   RETURN

STATIC FUNCTION JoseQuintasError( e )

   LOCAL nCont, cMessage, aOptions, nChoice

   // by default, division by zero yields zero
   IF ( e:GenCode == EG_ZERODIV )
      RETURN ( 0 )
   ENDIF

   // Only retry if open error 2014.09.24.1810
   IF e:OsCode == 64 .AND. e:GenCode == EG_OPEN
      //wOpen( 10, 10, 20, 80, "Atenção" )
      //@ 15, 15 SAY "Servidor sumiu. Tentar novamente em 2 segundos"
      //Inkey(2)
      //wClose()
      RETURN .T.
   ENDIF

   // For network open error, set NETERR() and subsystem default
   IF ( e:GenCode == EG_OPEN .AND. e:OsCode == 32 .AND. e:CanDefault )
      NetErr( .T. )
      RETURN ( .F. )     // NOTE
   ENDIF

   // for lock error during APPEND BLANK, set NETERR() and subsystem default
   IF ( e:GenCode == EG_APPENDLOCK .AND. e:CanDefault )
      NetErr( .T. )
      RETURN ( .F. )     // NOTE
   ENDIF

   // build error message
   cMessage := ErrorMessage(e)

   // build options array
   // aOptions := { "Break", "Quit" }
   aOptions := { "Quit" }

   IF e:GenCode == EG_WRITE .OR. e:GenCode == EG_READ .OR. e:GenCode == EG_LOCK .OR. e:GenCode == EG_APPENDLOCK
      e:CanRetry := .T.
   ENDIF

   IF ( e:CanRetry )
      AAdd( aOptions, "Retry" )
   ENDIF

   IF ( e:CanDefault )
      AAdd( aOptions, "Default" )
   ENDIF

   // put up alert box
   IF "DATA WIDTH ERROR" $ Upper( cMessage ) .AND. e:CanDefault
      nChoice := aScan( aOptions, "Default" )
   ELSE
      nChoice := 0
   ENDIF
   DO WHILE ( nChoice == 0 )
      IF ( Empty(e:osCode) )
         nChoice := Alert( cMessage, aOptions )
      ELSE
         nChoice := Alert( cMessage + ";(DOS Error " + Ltrim( Str( e:OsCode ) ) + ")", aOptions )
      ENDIF
      IF ( nChoice == NIL )
         EXIT
      ENDIF
   ENDDO

   IF ! Empty( nChoice )
      // do as instructed
      IF ( aOptions[ nChoice ] == "Break" )
         Break(e)
      ELSEIF ( aOptions[ nChoice ] == "Retry" )
         RETURN (.T.)
      ELSEIF ( aOptions[ nChoice ] == "Default" )
         RETURN (.F.)
      ENDIF
   ENDIF

   // display message and traceback
   IF ! Empty( e:OsCode )
      cMessage += " (DOS Error " + Ltrim( Str( e:OsCode ) ) + ") "
   ENDIF

   Errorsys_WriteErrorLog( , 1 ) // com id maquina
   ? cMessage
   Errorsys_WriteErrorLog( cMessage )
   nCont := 2
   DO WHILE ( ! Empty( ProcName( nCont ) ) )
      cMessage := "Called from " + Trim( ProcName( nCont ) ) + "(" + Ltrim( Str( ProcLine( nCont ) ) ) + ")  "
      ? cMessage
      Errorsys_WriteErrorLog( cMessage )
      nCont++
   ENDDO
   Errorsys_WriteErrorLog( Replicate( "-", 80 ) )
   RUN ( "start notepad.exe hb_out.log" )
   // give up
   ErrorLevel( 1 )
   QUIT

   RETURN .F.

STATIC FUNCTION ErrorMessage( e )

   LOCAL cMessage

   // start error message
   cMessage := if( e:Severity > ES_WARNING, "Error ", "Warning " )

   // add subsystem name IF available
   IF ( ValType( e:SubSystem ) == "C" )
      cMessage += e:SubSystem()
   ELSE
      cMessage += "???"
   ENDIF

   // add subsystem's error code IF available
   IF ( ValType( e:SubCode ) == "N" )
      cMessage += ( "/" + Ltrim(Str( e:SubCode ) ) )
   ELSE
      cMessage += "/???"
   ENDIF

   // add error description IF available
   IF ( ValType( e:Description ) == "C" )
      cMessage += ( "  " + e:Description )
   ENDIF

   // add either filename or operation
   IF ! Empty( e:Filename )
      cMessage += (": " + e:Filename )
   ELSEIF ! Empty( e:Operation )
      cMessage += ( ": " + e:Operation )
   ENDIF

   RETURN cMessage

FUNCTION Errorsys_WriteErrorLog( cText, nDetail )

   LOCAL nHandle, cFileName, nCont, nCont2

   hb_Default( @cText, "" )
   hb_Default( @nDetail, 0 )

   IF nDetail > 0
      Errorsys_WriteErrorLog()
      Errorsys_WriteErrorLog( "Error on "       + Dtoc( Date() ) + " " + Time() )
      Errorsys_WriteErrorLog( "EXE Name; " + hb_Argv(0) )
      Errorsys_WriteErrorLog( "JPA: "           + AppVersaoExe() )
      Errorsys_WriteErrorLog( "Login JPA: "     + AppUserName() )
      Errorsys_WriteErrorLog( "Alias:  "        + Alias() )
      Errorsys_WriteErrorLog( "Folder: "        + hb_cwd() )
      //Errorsys_WriteErrorLog( "MySQL local: "   + iif( AppcnMySqlLocal() == NIL, "NÃO", "SIM" ) + " ODBC " + Str( AppODBCMySql(), 1 ) + ".x" )
      Errorsys_WriteErrorLog( "Windows: "       + OS() )
      Errorsys_WriteErrorLog( "Computer Name: " + GetEnv( "COMPUTERNAME" ) )
      Errorsys_WriteErrorLog( "Windows User: "  + GetEnv( "USERNAME" ) )
      Errorsys_WriteErrorLog( "Logon Server: "  + Substr( GetEnv( "LOGONSERVER" ), 2 ) )
      Errorsys_WriteErrorLog( "User Domain: "   + GetEnv( "USERDOMAIN" ) )
      Errorsys_WriteErrorLog( "Harbour: "       + Version() )
      Errorsys_WriteErrorLog( "Compiler: "      + HB_Compiler() )
      Errorsys_WriteErrorLog( "GT: "            + hb_GtInfo( HB_GTI_VERSION ) )
      Errorsys_WriteErrorLog()
      Errorsys_WriteErrorLog()
   ENDIF
   cFileName := "hb_out.log"
   IF ! File( cFileName )
      nHandle := fCREATE( cFileName )
      fClose( nHandle )
   ENDIF

   nHandle := fOpen( cFileName, 1 )
   fSeek( nHandle, 0, 2 )
   fWrite( nHandle, cText + Space(2) + hb_Eol() )
   IF nDetail > 1
      nCont  := 2
      nCont2 := 0
      DO WHILE nCont2 < 5
         IF Empty( ProcName( nCont ) )
            nCont2++
         ELSE
            cText := "Called from " + Trim( ProcName( nCont ) ) + "(" + Ltrim( Str( ProcLine( nCont ) ) ) + ")  "
            fWrite( nHandle, cText + hb_Eol() )
         ENDIF
         nCont++
      ENDDO
      fWrite( nHandle, hb_Eol() )
   ENDIF
   fClose( nHandle )

   RETURN NIL
