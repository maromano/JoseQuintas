/*
PADMINACESSO - Usuários/Senhas/Acessos
1998.01 José Quintas

2018.04.19 Correção ref erro com FOR EACH
*/

#include "inkey.ch"

#define MODULE_DESCRIPTION 1
#define MODULE_LIST        2
#define MODULE_NAME        3
#define MODULE_USER        4
#define MODULE_GROUP       5

#define JPSENHA_NO_CRIPTO .F.
#define PW_DELETE .T.

MEMVAR private_cUser, private_acUserList

PROCEDURE pAdminAcesso

   LOCAL   nNumUsuario, nOpcAcao, acTxtAcao, lIsGrupo, nQtd
   PRIVATE private_cUser
   PRIVATE private_acUserList

   IF ! AbreArquivos( "jpsenha" )
      RETURN
   ENDIF
   SELECT jpsenha

   private_acUserList := pw_UserList( { " **NOVO**" }, "GS" )

   WOpen( 2, 5, MaxRow() - 4, 32, "USUÁRIOS/GRUPOS" )
   DO WHILE .T.
      nNumUsuario := 1
      Mensagem( "Selecione e tecle ENTER, ESC sai" )
      Scroll( 4, 6, MaxRow() - 5, 31, 0 )
      FazAchoice( 4, 6, MaxRow() - 5, 31, private_acUserList, @nNumUsuario )
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      private_cUser := Pad( private_acUserList[ nNumUsuario ], 20 )
      IF nNumUsuario == 1
         NovoUsuario()
      ELSE
         lIsGrupo := ( Left( private_cUser, 5 ) == "GRUPO" )
         nOpcAcao := 1
         DO WHILE .T.
            IF lIsGrupo
               acTxtAcao := { "Define Membros", "Altera Acessos", "Importa Acessos", "Exclui este grupo" }
            ELSE
               acTxtAcao := { "Altera Senha", "Altera Acessos", "Importa Acessos", "Exclui este usuário", "Grupos do usuário" }
               IF AppUserLevel() == 0
                  AAdd( acTxtAcao, "Mostra senha do usuário" )
               ENDIF
            ENDIF
            WAchoice( 8, 21, acTxtAcao, @nOpcAcao, iif( lIsGrupo, "GRUPO:", "USUÁRIO:" ) + private_cUser )
            DO CASE
            CASE LastKey() == K_ESC
               EXIT
            CASE nOpcAcao == 1
               IF lIsGrupo
                  SelecionaMembros( private_cUser )
               ELSE
                  pw_AddPassword( private_cUser )
               ENDIF
            CASE nOpcAcao == 2
               AlteraAcessos( private_cUser )
            CASE nOpcAcao == 3
               ImportaAcessos( private_cUser )
            CASE nOpcAcao == 4
               GOTO TOP
               nQtd := 0
               DO WHILE ! Eof()
                  IF jpsenha->pwType == "M" .AND. pw_Descriptografa( jpsenha->pwLast ) == private_cUser
                     nQtd += 1
                  ENDIF
                  SKIP
               ENDDO
               IF nQtd != 0
                  MsgExclamation( "Tem usuários neste grupo, não pode ser excluído" )
                  LOOP
               ENDIF
               IF MsgYesNo( "Confirma exclusão do grupo/usuário " + Trim( private_cUser ) )
                  pw_DeleteUser( private_cUser )
                  hb_ADel( private_acUserList, nNumUsuario, .T. )
               ENDIF
               EXIT
            CASE nOpcAcao == 5
               MostraGrupos( private_cUser )
            CASE nOpcAcao == 6
               Encontra( "S" + pw_Criptografa( private_cUser ) )
               MsgExclamation( "Usuário " + private_cUser + ", senha " + pw_Descriptografa( jpsenha->pwLast ) )
            ENDCASE
         ENDDO
      ENDIF
   ENDDO
   WClose()

   RETURN

STATIC FUNCTION pw_AddPassword( cUsuario )

   LOCAL cSenha

   WOpen( 8, 25, 11, 50, "SENHA" )
   Mensagem( "Digite nova senha, ESC sai" )
   cSenha := GetSecret( 10, 27 )
   Mensagem()
   IF LastKey() != K_ESC
      IF MsgYesNo( "Confirma nova senha?" )
         pw_AddUserPassword( cUsuario, cSenha )
         GravaOcorrencia( ,,"Alterada senha do usuário " + cUsuario )
      ENDIF
   ENDIF
   WClose()

   RETURN NIL

STATIC FUNCTION AlteraAcessos( cUsuario )

   LOCAL acMainList

   acMainList := aClone( MenuCria() ) // 13/11/05
   pw_MenuAcessos( acMainList, Pad( AppUserName(), 20 ) ) // 13/11/05
   TestaLiberado( acMainList, cUsuario )
   BoxAcesso( 4, 15, acMainList, 1, "ACESSOS DE " + Trim( cUsuario ), .F., .F., .F. )
   IF MsgYesNo( "Atualiza acessos de " + cUsuario  )
      IF AppUserName() == "TESTE"
         MsgStop( "Demonstração não atualiza acessos!" )
      ELSE
         AtAcesso( acMainList, cUsuario, )
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION TestaLiberado( acMainList, cUsuario, acGrupoList )

   LOCAL oEachOption, oEachGrupo, oElement

   IF acGrupoList == NIL
      acGrupoList := pw_GroupList( cUsuario )
   ENDIF
   FOR EACH oEachOption IN acMainList
      DO WHILE Len( oEachOption ) < 5
         AAdd( oEachOption, .F. )
      ENDDO
      IF ValType( oEachOption[ MODULE_USER ] ) != "L" .OR. ValType( oEachOption[ MODULE_GROUP ] ) != "L"
         oEachOption[ MODULE_USER  ] := .F.
         oEachOption[ MODULE_GROUP ] := .F.
      ENDIF
      IF Len( oEachOption[ MODULE_LIST ] ) > 0
         TestaLiberado( oEachOption[ MODULE_LIST ], cUsuario, acGrupoList )
         oEachOption[ MODULE_USER ]  := .F.
         oEachOption[ MODULE_GROUP ] := .F.
         FOR EACH oElement IN oEachOption[ MODULE_LIST ]
            oEachOption[ MODULE_USER  ] := oEachOption[ MODULE_USER ] .OR. oElement[ MODULE_USER ]
            oEachOption[ MODULE_GROUP ] := oEachOption[ MODULE_GROUP ] .OR. oElement[ MODULE_GROUP ]
         NEXT
      ELSE
         IF ValType( oEachOption[ MODULE_NAME ] ) == "B"
            oEachOption[ MODULE_USER ] := .T.
         ELSEIF ValType( oEachOption[ MODULE_NAME ] ) == "C"
            IF Encontra( "A" + pw_Criptografa( cUsuario ) + pw_Criptografa( oEachOption[ MODULE_NAME ] ), "jpsenha" )
               oEachOption[ MODULE_USER ] := .T.
            ENDIF
            FOR EACH oEachGrupo IN acGrupoList
               IF Encontra( "A" + pw_Criptografa( oEachGrupo ) + pw_Criptografa( oEachOption[ MODULE_NAME ] ), "jpsenha" )
                  // temporariamente desativado - vai desativar pro usuario, se já ativado pro grupo
                  // oEachOption[ MODULE_USER ]  := .F.
                  oEachOption[ MODULE_GROUP ] := .T.
                  EXIT
               ENDIF
            NEXT
         ENDIF
      ENDIF
   NEXT

   RETURN NIL

STATIC FUNCTION BoxAcesso( nTop, nLeft, acMainList, nOpc, cTitulo, lSaiSetas, lYesUser, lYesGroup )

   LOCAL nBottom, nRight, nKey, aOption

   nBottom := nTop + Len( acMainList ) + 2
   IF nBottom > MaxRow() - 4
      nTop := nTop + MaxRow() - 4 - nBottom
      nBottom := nTop + Len( acMainList ) + 2
   ENDIF
   nRight := nLeft + 43
   WOpen( nTop, nLeft, nBottom, nRight, cTitulo )
   Mensagem( "Selecione e tecle ENTER, S (Tem Acesso), N (Sem Acesso), ESC sai" )
   DO WHILE .T.
      @ nTop + 1, nLeft + 35 SAY "Usu Gru" COLOR SetColorBox()
      FOR EACH aOption IN acMainList
         @ nTop + 1 + aOption:__EnumIndex, nLeft + 1 SAY " " + Pad( aOption[ MODULE_DESCRIPTION ], 31 ) + ;
            iif( Len( aOption[ MODULE_LIST ] ) > 0, Chr(16), " " ) + " " + ;
            iif( aOption[ MODULE_USER ],  "SIM", "---" ) + " "  + ;
            iif( aOption[ MODULE_GROUP ], "SIM", "---" ) + " " COLOR iif( aOption:__EnumIndex == nOpc, SetColorFocus(), SetColorBox() )
      NEXT
      SetColor( SetColorNormal() )
      nKey := Inkey(0)
      DO CASE
      CASE nKey == K_ESC
         EXIT
      CASE lSaiSetas .AND. ( nKey == K_RIGHT .OR. nKey == Asc( "6" ) .OR. nKey == K_LEFT .OR. nKey == Asc( "4" ) ) // setas
         EXIT
      CASE nKey == K_LBUTTONDOWN
         IF MROW() > nTop + 1 .AND. MROW() < nTop + 2 + Len( acMainList ) .AND. MCOL() > nLeft .AND. MCOL() < nLeft + 38
            nOpc := MROW() - nTop - 1
            KEYBOARD Chr( K_ENTER )
         ENDIF
      CASE nKey == K_RBUTTONDOWN                       ; KEYBOARD Chr( K_ESC )
      CASE nKey == K_DOWN     .OR. nKey == Asc( "2" )  ; nOpc := iif( nOpc == Len( acMainList ), 1, nOpc + 1 )
      CASE nKey == K_UP       .OR. nKey == Asc( "8" )  ; nOpc := iif( nOpc == 1, Len( acMainList ), nOpc - 1 )
      CASE nKey == K_HOME     .OR. nKey == Asc( "7" )  ; nOpc := 1
      CASE nKey == K_END      .OR. nKey == Asc( "1" )  ; nOpc := Len( acMainList )
      CASE nKey == Asc( "S" ) .OR. nKey == Asc( "s" )  ; AcessoLiberado( @acMainList, nOpc, .T. )
      CASE nKey == Asc( "N" ) .OR. nKey == Asc( "n" )  ; AcessoLiberado( @acMainList, nOpc, .F. )
      CASE nKey == K_ENTER
         IF Len( acMainList[ nOpc, MODULE_LIST ] ) > 0
            BoxAcesso( nTop + 2, nLeft + 10, @acMainList[ nOpc, MODULE_LIST ], 1, acMainList[ nOpc, MODULE_DESCRIPTION ], ;
               .T., @acMainList[ nOpc, MODULE_USER ], @acMainList[ nOpc, MODULE_GROUP ] )
         ELSE
            SelecionaUsuarios( nLeft + 20, acMainList[ nOpc, MODULE_NAME ] )
         ENDIF
      ENDCASE
   ENDDO
   FOR EACH aOption IN acMainList
      IF aOption[ MODULE_USER ]
         lYesUser := .T.
      ENDIF
      IF aOption[ MODULE_GROUP ]
         lYesGroup := .T.
      ENDIF
   NEXT
   WClose()

   RETURN NIL

STATIC FUNCTION AcessoLiberado( acMainList, nOpc, lYes )

   LOCAL nCont

   IF ValType( acMainList[ nOpc, MODULE_NAME ] ) != "B"
      acMainList[ nOpc, MODULE_USER ] := lYes
      FOR nCont = 1 TO Len( acMainList[ nOpc, MODULE_LIST ] )
         AcessoLiberado( @acMainList[ nOpc, MODULE_LIST ], nCont, lYes )
      NEXT
   ENDIF

   RETURN NIL

STATIC FUNCTION AtAcesso( oMenuList, cUsuario )

   LOCAL acPrgList := {}, cModule

   ListaProg( oMenuList, @acPrgList )
   SEEK "A" + pw_Criptografa( cUsuario )
   DO WHILE jpsenha->pwType == "A" .AND. jpsenha->pwFirst == pw_Criptografa( cUsuario ) .AND. ! Eof()
      GrafProc()
      RecDelete()
      SKIP
   ENDDO
   FOR EACH cModule IN acPrgList
      pw_AddUserModule( cUsuario, cModule )
   NEXT
   GravaOcorrencia( ,, "Alteração Grupo/Usuário (Acessos) " + cUsuario )

   RETURN NIL

STATIC FUNCTION ListaProg( oMenuList, acPrgList )

   LOCAL oElement

   hb_Default( @acPrgList, {} )
   FOR EACH oElement IN oMenuList
      DO WHILE Len( oElement ) < 4
         AAdd( oElement, Len( oElement ) < 3 ) // .T. or .F.
      ENDDO
      hb_Default( @oElement[ 3 ], .T. )
      hb_Default( @oElement[ 4 ], .F. )
      IF Len( oElement[ MODULE_LIST ] ) > 0
         ListaProg( oElement[ MODULE_LIST ], acPrgList )
      ELSEIF ValType( oElement[ MODULE_NAME ] ) == "C" .AND. oElement[ MODULE_USER ]
         AAdd( acPrgList, oElement[ MODULE_NAME ] )
      ENDIF
   NEXT

   RETURN acPrgList

STATIC FUNCTION ImportaAcessos( cUserTarget )

   LOCAL cUserSource := Space(20), acModuleList, GetList := {}, cModule

   WOpen( 8, 25, 11, 55, "IMPORTAR DE" )
   DO WHILE .T.
      @ 10, 27 GET cUserSource PICTURE "@!"
      Mensagem( "Digite nome do grupo/usuário a importar acessos, ESC sai" )
      READ
      Mensagem()
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      IF Trim( cUserTarget ) == "TESTE"
         MsgStop( "Demonstração não importa acessos!" )
         LOOP
      ENDIF
      IF ! Encontra( "S" + pw_Criptografa( cUserSource ) )
         MsgStop( "Grupo/Usuário não existe!" )
         LOOP
      ENDIF
      IF MsgYesNo( "Confirma importação?" )
         IF MsgYesNo( "Elimina os acessos atuais deste usuário?" )
            SEEK "A" + pw_Criptografa( cUserTarget )
            DO WHILE jpsenha->pwType == "A" .AND. jpsenha->pwFirst == pw_Criptografa( cUserTarget ) .AND. ! Eof()
               RecDelete()
               SKIP
            ENDDO
            SEEK "M" + pw_Criptografa( cUserTarget )
            DO WHILE jpsenha->pwType == "A" .AND. jpsenha->pwFirst == pw_Criptografa( cUserTarget ) .AND. ! Eof()
               RecDelete()
               SKIP
            ENDDO
         ENDIF
         acModuleList := {}
         SEEK "A" + pw_Criptografa( cUserSource )
         DO WHILE jpsenha->pwType == "A" .AND. jpsenha->pwFirst == pw_Criptografa( cUserSource ) .AND. ! Eof()
            AAdd( acModuleList, pw_Descriptografa( jpsenha->pwLast ) )
            SKIP
         ENDDO
         FOR EACH cModule IN acModuleList
            pw_AddUserModule( cUserTarget, cModule )
         NEXT
         acModuleList := {}
         SEEK "M" + pw_Criptografa( cUserSource )
         DO WHILE jpsenha->pwType == "M" .AND. jpsenha->pwFirst == pw_Criptografa( cUserSource ) .AND. ! Eof()
            AAdd( acModuleList, pw_Descriptografa( jpsenha->pwLast ) )
            SKIP
         ENDDO
         FOR EACH cModule IN acModuleList
            pw_AddUserGroup( cUserTarget, cModule )
         NEXT
         GravaOcorrencia( ,, "Alteração Grupo/Usuário (Acessos) " + cUserTarget + ", importado de " + cUserSource )
      ENDIF
      EXIT
   ENDDO
   WClose()

   RETURN NIL

FUNCTION pw_AlteraSenha()

   LOCAL cCorAnt, cSenhaAtual, cSenhaAnterior, cSenhaConfirma

   IF ! AbreArquivos( "jpsenha" )
      RETURN NIL
   ENDIF
   cCorAnt := SetColor()
   WSave()
   SetColor( SetColorNormal() )
   Cls()
   DO WHILE .T.
      @ 6, 10 SAY "Senha anterior...:"
      @ 8, 10 SAY "Nova Senha.......:"
      @ 10,10 SAY "Confirmação......:"
      cSenhaAnterior := GetSecret( 6, 29 )
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      cSenhaAtual    := GetSecret( 8, 29 )
      IF LastKey() == K_ESC
         LOOP
      ENDIF
      cSenhaConfirma := GetSecret( 10, 29 )
      IF LastKey() == K_ESC
         LOOP
      ENDIF
      IF cSenhaAtual != cSenhaConfirma
         MsgWarning( "Nova senha e confirmação são diferentes!" )
         LOOP
      ENDIF
      IF ! Encontra( "S" + pw_Criptografa( AppUserName() ) + pw_Criptografa( cSenhaAnterior ), "jpsenha" )
         MsgStop( "Senha anterior inválida!" )
         LOOP
      ENDIF
      pw_AddUserPassword( AppUserName(), cSenhaAtual )
      EXIT
   ENDDO
   WRestore()
   SetColor( cCorAnt )
   CLOSE DATABASES

   RETURN NIL

FUNCTION pw_TemAcesso( cModulo, cUsuario )

   LOCAL lReturn := .F., nSelect, acGrupoList, cGrupo

   nSelect := Select()
   IF AppUserLevel() == 0
      lReturn := .T.
   ELSE
      IF Select( "jpsenha" ) == 0
         AbreArquivos( "jpsenha" )
      ENDIF
      hb_Default( @cUsuario, AppUserName() )
      IF Encontra( "A" + pw_Criptografa( cUsuario ) + pw_Criptografa( cModulo ), "jpsenha" )
         lReturn := .T.
      ELSE
         acGrupoList := pw_GroupList( cUsuario )
         FOR EACH cGrupo IN acGrupoList
            IF Encontra( "A" + pw_Criptografa( cGrupo ) + pw_Criptografa( cModulo ), "jpsenha" )
               lReturn := .T.
               EXIT
            ENDIF
         NEXT
      ENDIF
   ENDIF
   SELECT ( nSelect )

   RETURN lReturn

STATIC FUNCTION SelecionaUsuarios( nLeft, mProg )

   LOCAL mOpcUser := {}, mOpcao, mOpcUser2, mOpcao2, cModulo, oElement

   IF ValType( mProg ) != "C"
      RETURN NIL
   ENDIF
   cModulo := pw_Criptografa( mProg )
   SELECT jpsenha
   GOTO TOP
   DO WHILE ! Eof()
      IF jpsenha->pwType == "A" .AND. jpsenha->pwLast == cModulo
         AAdd( mOpcUser, pw_Descriptografa( jpsenha->pwFirst ) )
      ENDIF
      SKIP
   ENDDO
   IF Len( mOpcUser ) == 0
      AAdd( mOpcUser, "" )
   ELSE
      aSort( mOpcUser )
      aSize( mOpcUser, Len( mOpcUser ) + 1 )
      AIns( mOpcUser, 1 )
   ENDIF
   mOpcUser[ 1 ] := "*INSERIR*"
   WOpen( 3, nLeft, MaxRow() - 4, nLeft + 27, mProg )
   mOpcao := 1
   DO WHILE .T.
      IF mOpcao > Len( mOpcUser )
         mOpcao := Len( mOpcUser )
      ENDIF
      Scroll( 4, nLeft + 1, MaxRow() - 5, nLeft + 26, 0 )
      FazAchoice( 4, nLeft + 1, MaxRow() - 5, nLeft + 26, mOpcUser, @mOpcao )
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      IF mOpcao != 1 // Inserir
         IF MsgYesNo( "Exclui grupo/usuário deste acesso?" )
            pw_AddUserModule( mOpcUser[ mOpcao ], mProg, PW_DELETE )
            hb_ADel( mOpcUser, mOpcao, .T. )
         ENDIF
         LOOP
      ENDIF
      mOpcUser2 := {}
      FOR EACH oElement IN private_acUserList
         IF oElement:__EnumIndex != 1 .AND. AScan( mOpcUser, oElement ) == 0
            AAdd( mOpcUser2, oElement )
         ENDIF
      NEXT
      IF Len( mOpcUser2 ) == 0
         MsgWarning( "Todos os grupos/usuários já tem acesso!" )
         LOOP
      ENDIF
      mOpcao2 := 1
      WOpen( 2, nLeft + 10, MaxRow() - 4, nLeft + 37, "LIBERAR" )
      DO WHILE .T.
         IF Len( mOpcUser2 ) == 0
            EXIT
         ENDIF
         IF mOpcao2 > Len( mOpcUser2 )
            mOpcao2 := Len( mOpcUser2 )
         ENDIF
         Scroll( 4, nLeft + 11, MaxRow() - 5, nLeft + 36, 0 )
         FazAchoice( 4, nLeft + 11, MaxRow() - 5, nLeft + 36, mOpcUser2, @mOpcao2 )
         IF Lastkey() == K_ESC
            EXIT
         ENDIF
         pw_AddUserModule( mOpcUser2[ mOpcao2 ], mProg )
         AAdd( mOpcUser, mOpcUser2[ mOpcao2 ] )
         hb_ADel( mOpcUser2, mOpcao2, .T. )
      ENDDO
      WClose()
   ENDDO
   WClose()

   RETURN NIL

STATIC FUNCTION NovoUsuario()

   LOCAL cNome := Space(20), GetList := {}, nOpc := 1, acOpcList := { "Usuário", "Grupo" }

   wAchoice( 6, 20, acOpcList, @nOpc, "GRUPO/USUÁRIO" )
   IF LastKey() == K_ESC
      RETURN NIL
   ENDIF
   WOpen( 6, 20, 9, 45, "NOVO " + Upper( acOpcList[ nOpc ] ) )
   DO WHILE .T.
      @ 8, 22 GET cNome PICTURE "@K!"
      Mensagem( "Digite nome do " + acOpcList[ nOpc ] + ", ESC sai" )
      READ
      Mensagem()
      IF LastKey() == K_ESC .OR. Empty( cNome )
         EXIT
      ENDIF
      IF nOpc == 2 .AND. Left( cNome, 5 ) != "GRUPO"
         cNome := Pad( "GRUPO" + cNome, 20 )
      ENDIF
      IF cNome == Pad( MyUser(), 20 ) ;
            .OR. Encontra( "S" + pw_Criptografa( cNome ) ) ;
            .OR. Encontra( "G" + pw_Criptografa( cNome ) )
         MsgWarning( acOpcList[ nOpc ] + " já cadastrado!" )
         LOOP
      ENDIF
      IF MsgYesNo( "Confirma inclusão?" )
         IF nOpc == 1
            pw_AddUserPassword( cNome, "" )
         ELSE
            pw_AddGroup( cNome )
         ENDIF
         AAdd( private_acUserList, cNome )
         aSort( private_acUserList )
         GravaOcorrencia( ,, "Inclusão " + acOpcList[ nOpc ] + " " + cNome )
      ENDIF
      EXIT
   ENDDO
   WClose()

   RETURN NIL

STATIC FUNCTION SelecionaMembros( cGrupo )

   LOCAL acUserList := {}, nOpcUser, acNewUserList, nOpcNewUser, oElement

   GOTO TOP
   DO WHILE ! Eof()
      IF jpsenha->pwType == "M" .AND. jpsenha->pwLast == pw_Criptografa( cGrupo )
         AAdd( acUserList, pw_Descriptografa( jpsenha->pwFirst ) )
      ENDIF
      SKIP
   ENDDO
   IF Len( acUserList ) == 0
      AAdd( acUserList, "" )
   ELSE
      aSort( acUserList )
      aSize( acUserList, Len( acUserList ) + 1 )
      AIns( acUserList, 1 )
   ENDIF
   acUserList[ 1 ] := "*INSERIR*"
   WOpen( 2, 15, MaxRow() - 4, 42, "GRUPO:" + Trim( cGrupo ) )
   nOpcUser := 1
   DO WHILE .T.
      IF nOpcUser > Len( acUserList )
         nOpcUser := Len( acUserList )
      ENDIF
      Scroll( 4, 16, MaxRow() - 5, 41, 0 )
      FazAchoice( 4, 16, MaxRow() - 5, 41, acUserList, @nOpcUser )
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      IF nOpcUser != 1 // Inserir
         IF MsgYesNo( "Exclui usuário deste grupo?" )
            pw_AddUserGroup( acUserList[ nOpcUser ], cGrupo, PW_DELETE )
            hb_ADel( acUserList, nOpcUser, .T. )
         ENDIF
         LOOP
      ENDIF
      acNewUserList := {}
      FOR EACH oElement IN private_acUserList
         IF oElement:__EnumIndex != 1 .AND. aScan( acUserList, oElement ) == 0
            AAdd( acNewUserList, oElement )
         ENDIF
      NEXT
      IF Len( acNewUserList ) == 0
         MsgWarning( "Todos os usuários já tem acesso!" )
         LOOP
      ENDIF
      nOpcNewUser := 1
      WOpen( 2, 26, MaxRow() - 4, 51, "INCLUIR" )
      DO WHILE .T.
         IF Len( acNewUserList ) == 0
            EXIT
         ENDIF
         IF nOpcNewUser > Len( acNewUserList )
            nOpcNewUser := Len( acNewUserList )
         ENDIF
         Scroll( 4, 27, MaxRow() - 5, 50, 0 )
         FazAchoice( 4, 27, MaxRow() - 5, 50, acNewUserList, @nOpcNewUser )
         IF Lastkey() == K_ESC
            EXIT
         ENDIF
         IF Encontra( "G" + pw_Criptografa( acNewUserList[ nOpcNewUser ] ), "jpsenha" )
            MsgExclamation( "Não pode definir um grupo como membro de outro grupo" )
            LOOP
         ENDIF
         pw_AddUserGroup( acNewUserList[ nOpcNewUser ], cGrupo )
         AAdd( acUserList, acNewUserList[ nOpcNewUser ] )
         hb_ADel( acNewUserList, nOpcNewUser, .T. )
      ENDDO
      WClose()
   ENDDO
   WClose()

   RETURN NIL

STATIC FUNCTION MostraGrupos( cUsuario )

   LOCAL acGrupoList

   acGrupoList := pw_GroupList( cUsuario )
   IF Len( acGrupoList ) == 0
      MsgExclamation( "Usuário não pertence a nenhum grupo" )
      RETURN NIL
   ENDIF
   wAchoice( 10, 40, acGrupoList, 1, "GRUPOS DO USUÁRIO" )

   RETURN NIL

FUNCTION pw_MenuAcessos( acMainList, cUsuario, acGrupoList )

   LOCAL lTiraOpc, nCont, nQtdOpc, oEachOption, oEachGrupo

   IF Trim( cUsuario ) == MyUser()
      RETURN NIL
   ENDIF
   IF acGrupoList == NIL
      acGrupoList := pw_GroupList( cUsuario )
   ENDIF
   FOR nCont = 1 TO Len( acMainList )
      lTiraOpc := .T.
      IF Len( acMainList[ nCont, 2 ] ) > 0
         pw_MenuAcessos( @acMainList[ nCont, 2 ], cUsuario )
         IF Len( acMainList[ nCont, 2 ] ) != 0
            nQtdOpc := 0
            FOR EACH oEachOption IN acMainList[ nCont, 2 ]
               IF ! oEachOption[ 1 ] == "-"
                  nQtdOpc++
               ENDIF
            NEXT
            IF nQtdOpc != 0
               lTiraOpc := .F.
            ENDIF
         ENDIF
      ELSEIF ValType( acMainList[ nCont, 3 ] ) == "B"
         lTiraOpc := .F.
      ELSEIF ValType( acMainList[ nCont, 3 ] ) == "C"
         IF acMainList[ nCont, 3 ] == "-"
            IF nCont == 1 .OR. nCont == Len( acMainList ) .OR. ( nCont > 1 .AND. acMainList[ nCont - 1, 3 ] == "-" ) // ref. traço primeiro, último ou repetido
               lTiraOpc := .T.
            ELSE
               lTiraOpc := .F.
            ENDIF
         ELSE
            IF Encontra( "A" + pw_Criptografa( AppUserName() ) + pw_Criptografa( acMainList[ nCont, 3 ] ), "jpsenha" )
               lTiraOpc := .F.
            ELSE
               FOR EACH oEachGrupo IN acGrupoList
                  IF Encontra( "A" + pw_Criptografa( oEachGrupo ) + pw_Criptografa( acMainList[ nCont, 3 ] ), "jpsenha" )
                     lTiraOpc := .F.
                     EXIT
                  ENDIF
               NEXT
            ENDIF
         ENDIF
      ENDIF
      IF lTiraOpc
         hb_ADel( acMainList, nCont, .T. )
         nCont -= 1 // 0 - alterado 2015.07.28.1430
      ENDIF
   NEXT

   RETURN NIL

FUNCTION pw_DeleteInvalid()

   LOCAL acUserList := {}, mTemp, cModule, lExclui, cUser, nAtual, nTotal, acModuleList := {}, acGrupoList := {}, cLetra

   SayScroll( "Verificando acessos desativados/duplicados" )
   IF ! AbreArquivos( "jpsenha" )
      QUIT
   ENDIF
   GOTO TOP
   DO WHILE ! Eof()
      IF jpsenha->pwType == "S"
         AAdd( acUserList, jpsenha->pwFirst )
      ELSEIF jpsenha->pwType == "G"
         AAdd( acGrupoList, jpsenha->pwFirst )
      ENDIF
      SKIP
   ENDDO
   ListaProg( MenuCria(), @acModuleList ) // executar esta funcao
   GOTO TOP
   mTemp  := Chr(205)
   nTotal := LastRec()
   nAtual := 0
   GrafTempo( "Verificando" )
   DO WHILE ! Eof()
      GrafTempo( nAtual++, nTotal )
      cModule := Trim( pw_Descriptografa( jpsenha->pwLast ) )
      cUser   := Trim( pw_Descriptografa( jpsenha->pwFirst ) )
      lExclui := .F.
      DO CASE
      CASE jpsenha->pwType + jpsenha->pwFirst + jpsenha->pwLast == mTemp // se repetido exclui
         GravaOcorrencia( ,, "(*) Acesso em duplicidade " + cUser + ", " + cModule )
         lExclui := .T.
      CASE jpsenha->pwType == "M"
         IF AScan( acGrupoList, jpsenha->pwLast ) == 0
            lExclui := .T.
         ENDIF
      CASE jpsenha->pwType != "A" // nao se trata de acesso
      CASE aScan( acModuleList, cModule ) == 0
         GravaOcorrencia( ,, "(*) Módulo desativado/substituído " + cUser + ", " + cModule )
         lExclui := .T.
      CASE aScan( acUserList, jpsenha->pwFirst ) == 0 // Usuario nao existe
         lExclui := .T.
      ENDCASE
      IF ! lExclui
         FOR EACH cLetra IN cModule
            IF ! cLetra $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_ "
               lExclui := .T.
               EXIT
            ENDIF
         NEXT
      ENDIF
      IF ! lExclui
         FOR EACH cLetra IN cUser
            IF ! cLetra $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_ "
               lExclui := .T.
               EXIT
            ENDIF
         NEXT
      ENDIF
      IF lExclui
         IF jpsenha->pwType == "M"
            GravaOcorrencia( , , "(*) Retirado grupo " + pw_Descriptografa( jpsenha->pwLast ) + " do usuário " + cUser )
         ELSE
            GravaOcorrencia( ,, "(*) Retirado acesso do usuário " + cUser + ", módulo " + cModule )
         ENDIF
         RecDelete()
      ENDIF
      mTemp := jpsenha->pwType + jpsenha->pwFirst + jpsenha->pwLast
      SKIP
   ENDDO
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION pw_GroupList( cUsuario )

   LOCAL acGrupoList := {}, nSelect := Select()

   SELECT jpsenha
   SEEK "M" + pw_Criptografa( cUsuario )
   DO WHILE jpsenha->pwType == "M" .AND. jpsenha->pwFirst == pw_Criptografa( cUsuario ) .AND. ! Eof()
      AAdd( acGrupoList, pw_Descriptografa( jpsenha->pwLast ) )
      SKIP
   ENDDO
   SELECT ( nSelect )

   RETURN acGrupoList

STATIC FUNCTION pw_UserList( acUserList, cTypeList )

   hb_Default( @acUserList, {} )
   hb_Default( @cTypeList, "GS" )

   GOTO TOP
   DO WHILE ! Eof()
      IF jpsenha->pwType $ cTypeList
         AAdd( acUserList, pw_Descriptografa( jpsenha->pwFirst ) )
      ENDIF
      SKIP
   ENDDO
   aSort( acUserList )

   RETURN acUserList

STATIC FUNCTION pw_DeleteUser( cUsuario )

   GOTO TOP
   DO WHILE ! Eof()
      DO CASE
      CASE jpsenha->pwType $ "SGAM" .AND. jpsenha->pwFirst == pw_Criptografa( cUsuario )
         RecDelete()
      CASE jpsenha->pwType $ "M" .AND. jpsenha->pwLast == pw_Criptografa( cUsuario )
         RecDelete()
      ENDCASE
      SKIP
   ENDDO
   GravaOcorrencia( ,, "Exclusão GRUPO/USUÁRIO " + private_cUser )

   RETURN NIL

FUNCTION pw_DeleteModule( cModule )

   LOCAL nSelect := Select()

   cModule := pw_Criptografa( cModule )
   SELECT jpsenha
   GOTO TOP
   DO WHILE ! Eof()
      IF jpsenha->pwType == "A" .AND. jpsenha->pwLast == cModule
         RecDelete()
      ENDIF
      SKIP
   ENDDO
   SELECT ( nSelect )

   RETURN NIL

FUNCTION pw_AddModule( cModuloNovo, cModuloOrigem )

   LOCAL acUserList := {}, nSelect, cUsuario

   hb_Default( @cModuloOrigem, "PADMINACESSO" )

   nSelect := Select()
   SELECT jpsenha
   GOTO TOP
   DO WHILE ! Eof()
      IF jpsenha->pwType == "A" .AND. jpsenha->pwLast == pw_Criptografa( cModuloOrigem )
         AAdd( acUserList, pw_Descriptografa( jpsenha->pwFirst ) )
      ENDIF
      SKIP
   ENDDO
   FOR EACH cUsuario IN acUserList
      pw_AddUserModule( cUsuario, cModuloNovo )
   NEXT
   SELECT ( nSelect )

   RETURN NIL

FUNCTION pw_AddGroup( cGroup, lDelete )

   hb_Default( @lDelete, .F. )

   SEEK "G" + pw_Criptografa( cGroup )
   IF lDelete
      IF Eof()
         RecDelete()
      ENDIF
   ELSE
      IF Eof()
         RecAppend()
      ENDIF
      RecLock()
      REPLACE ;
         jpsenha->pwType  WITH "G", ;
         jpsenha->pwFirst WITH pw_Criptografa( cGroup ), ;
         jpsenha->pwLast  WITH pw_Criptografa( "CAUTION" )
      RecUnlock()
   ENDIF

   RETURN NIL

FUNCTION pw_AddUserPassword( cUser, cPassword, lDelete )

   hb_Default( @lDelete, .F. )

   SEEK "S" + pw_Criptografa( cUser )
   IF lDelete
      IF ! Eof()
         RecDelete()
      ENDIF
   ELSE
      IF Eof()
         RecAppend()
      ENDIF
      RecLock()
      REPLACE ;
         jpsenha->pwType  WITH "S", ;
         jpsenha->pwFirst WITH pw_Criptografa( cUser ), ;
         jpsenha->pwLast  WITH pw_Criptografa( cPassword )
      RecUnlock()
   ENDIF

   RETURN NIL

FUNCTION pw_AddUserModule( cUser, cModule, lDelete )

   hb_Default( @lDelete, .F. )

   SEEK "A" + pw_Criptografa( cUser ) + pw_Criptografa( cModule )
   IF lDelete
      IF ! Eof()
         RecDelete()
      ENDIF
   ELSE
      IF Eof()
         RecAppend()
         REPLACE ;
            jpsenha->pwType  WITH "A", ;
            jpsenha->pwFirst WITH pw_Criptografa( cUser ), ;
            jpsenha->pwLast  WITH pw_Criptografa( cModule )
         RecUnlock()
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION pw_AddUserGroup( cUser, cGroup, lDelete )

   hb_Default( @lDelete, .F. )
   SEEK "M" + pw_Criptografa( cUser ) + pw_Criptografa( cGroup )
   IF lDelete
      IF ! Eof()
         RecDelete()
      ENDIF
   ELSE
      IF Eof()
         RecAppend()
         REPLACE ;
            jpsenha->pwType  WITH "M", ;
            jpsenha->pwFirst WITH pw_Criptografa( cUser ), ;
            jpsenha->pwLast  WITH pw_Criptografa( cGroup )
      ENDIF
   ENDIF

   RETURN NIL
