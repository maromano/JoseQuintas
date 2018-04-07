/*
ZE_APRES - TELA DE APRESENTACAO
1992.12 José Quintas
*/

#include "inkey.ch"
#include "hbgtinfo.ch"
#include "wvgparts.ch"

FUNCTION TelaEntrada()

   LOCAL cCorAnt, nRow, aControlList := {}, oControl

   cCorAnt     := SetColor()
   SetColor( SetColorNormal() )
   CLS
   nRow := Int( ( MaxRow() - 20 ) / 2 )
   WITH OBJECT oControl := wvgtstPushButton():New()
      :PointerFocus := .F.
      :oImage       := { , WVG_IMAGE_BITMAPRESOURCE, "JPATECNOLOGIA",, 1 }
      :lImageResize := .T.
      :Create( , , { -nRow, -34 }, { -11, -64 } )
   ENDWITH
   AAdd( aControlList, oControl )
   @ nRow + 12, 34 SAY Padc( "Licenciado: " + AppEmpresaNome(), 64 )
   @ Row() + 2, 34 SAY Padc( "JPA Versao " + AppVersaoExe(), 64 )
   @ Row() + 1, 34 SAY Padc( "Harbour 3.4 + " + hb_Compiler(), 64 )
   @ Row() + 1, 34 SAY Padc( "MySQL ODBC " + Str( AppODBCMySql(), 1 ) + ".x", 64 )
   WITH OBJECT oControl := wvgTstIcon():New()
      :SetColorBG( "W/B" )
      :cImage := "icoUserId"
      :Create( , , { -nRow - 18, -35 }, { -4, -9 } )
      :SetImage( .T. )
   ENDWITH
   AAdd( aControlList, oControl )
   SetColor( cCorAnt )
   PegaSenha( Row() + 2, 34, 64 )
   FOR EACH oControl IN aControlList
      oControl:Destroy()
   NEXT
   wvgSetAppWindow():Refresh()

   RETURN NIL

FUNCTION PegaSenha( nLini, nColi, nLen )

   LOCAL csenha, cUsuario

   hb_Default( @nLen, 20 )

   IF ! AbreArquivos( "jpsenha" )
      QUIT
   ENDIF
   AppUserName( "JPA" )
   AppUserLevel( 2 )
   //Scroll( nLini, nColi + 12, nLini + 4, nColi + 50, 0 )
   //@ nLini, nColi + 12 TO nLini + 4, nColi + 50
   DO WHILE .T.
      @ nLini + 1, nColi + 15 SAY "Usuário   "
      @ Row(), Col() SAY Replicate( "*", 20 ) COLOR SetColorFocus()
      @ nLini + 3, nColi + 17 SAY   "Senha   "
      @ Row(), Col() SAY Replicate( "*", 20 ) COLOR SetColorFocus()
      //@ nLini, nColi + 23 TO nLini + 2, nColi + 46
      //@ nLini + 3, nColi + 23 TO nLini + 5, nColi + 46
      cUsuario = GetSecret( nLini + 1, nColi + 25 )
      IF LastKey() != K_ESC
         cSenha = GetSecret( nLini + 3, nColi + 25 )
      ENDIF
      IF LastKey() == K_ESC
         IF MsgYesNo( "Confirma saida do sistema?" )
            CLOSE DATABASES
            CLS
            QUIT
         ENDIF
         LOOP
      ENDIF
      //AppUserPassword( cSenha )
      IF cUsuario == Pad( MyUser(), 20 ) .AND. cSenha == Pad( MyPassword(), 20 )
         AppUserName( MyUser() )
         AppUserLevel( 0 )
         //AppUserPassword( "" )
         EXIT
      ENDIF
      IF ! AbreArquivos( "jpsenha" )
         MsgStop( "Arquivo de login não disponível" )
         LOOP
      ENDIF
      IF ! Encontra( "S" + pw_Criptografa( cUsuario ) + pw_Criptografa( cSenha ), "jpsenha" ) .AND. AppUserLevel() != 0
         MsgWarning( "Usuário ou Senha inválidos!" )
         CLOSE DATABASES
         LOOP
      ENDIF
      AppUserName( cUsuario )
      IF pw_TemAcesso( "PADMINACESSO" ) .AND. AppUserLevel() != 0
         AppUserLevel( 1 )
      ENDIF
      EXIT
   ENDDO
   CLOSE DATABASES

   RETURN NIL
