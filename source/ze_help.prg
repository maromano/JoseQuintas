/*
ZE_HELP - HELP DO SISTEMA
1993.06 José Quintas
*/

#include "hbthread.ch"
#include "hbgtinfo.ch"
#include "inkey.ch"

MEMVAR m_Prog

PROCEDURE HELP

   PARAMETERS P1, P2, P3

   hb_ThreadStart( @RotinaHelp(), m_Prog )

   RETURN

FUNCTION RotinaHelp( Param1 )

   LOCAL mTexto, mTextoEdit, oSetKey, cnJoseQuintas := ADOClass():New( AppcnJoseQuintas() )

   PUBLIC m_Prog

   m_Prog  := Param1
   hb_gtReload( hb_gtInfo( HB_GTI_VERSION ) )
   AppInitSets()
   SetColor( SetColorNormal() )
   CLS
   IF ! IsInternet()
      RETURN NIL
   ENDIF
   HB_GtInfo( HB_GTI_WINTITLE, "HELP " + m_Prog )
   oSetKey := SaveSetKey( -18, -19, -8, -9, 28 )
   Mensagem( "Aguarde... pesquisando arquivo de ajuda..." )
   cnJoseQuintas:cSql := "SELECT * FROM WEBHELP WHERE HLOLD='N' AND HLMODULO=" + StringSql( m_Prog )
   mTexto := ""
   cnJoseQuintas:Open()
   BEGIN SEQUENCE WITH __BreakBlock()
      cnJoseQuintas:Execute()
      IF ! cnJoseQuintas:Eof()
         mTexto := cnJoseQuintas:StringSql( "HLTEXTO" )
      ENDIF
      cnJoseQuintas:CloseRecordset()
   END SEQUENCE
   @ 0, 0 SAY Padc( "HELP " + m_Prog, MaxCol() + 1 ) COLOR SetColorFocus()
   Mensagem( "Utilize as setas para consulta, ESC retorna ao sistema" )
   mTextoEdit := MemoEdit( mTexto, 1, 0, MaxRow()-2, MaxCol(), AppUserLevel() == 0 )
   WClose()
   IF ! mTexto == mTextoEdit .AND. Lastkey() != K_ESC
      WITH OBJECT cnJoseQuintas
         :cSql := "UPDATE WEBHELP SET HLOLD='S' WHERE HLMODULO=" + StringSql( m_Prog )
         :ExecuteCmd()
         IF ! Empty( mTextoEdit )
            :QueryCreate()
            :QueryAdd( "HLMODULO", m_Prog )
            :QueryAdd( "HLTEXTO", mTextoEdit )
            :QueryAdd( "HLINFINC", LogInfo() )
            :QueryExecuteInsert( "WEBHELP" )
         ENDIF
      END WITH
   ENDIF
   cnJoseQuintas:CloseConnection()
   KEYBOARD Chr( 205 )
   Inkey(0)
   RestoreSetKey( oSetKey )

   RETURN NIL
