/*
JPA_LOAD - INICIO DO APLICATIVO
1995.04 José Quintas
*/

#include "josequintas.ch"
#include "hbgtinfo.ch"
#include "inkey.ch"
#include "hbthread.ch"
#include "directry.ch"

REQUEST DBFFPT
REQUEST DBFCDX
REQUEST DESCEND // pra continuar compatível com índice anterior

MEMVAR m_Prog

FUNCTION Sistema( cParam )

   LOCAL mMenuOpcoes, lAvisaLicencas
   PUBLIC m_Prog

   hb_gtReload( hb_gtInfo( HB_GTI_VERSION ) )

   hb_Default( @cParam, "" )
   cParam := Upper( cParam )
   m_Prog := "JPA"

   AppInicializa()
   JpaCfg()
   IF Empty( AppEmpresaApelido() )
      AppEmpresaNome( "NAOCONF" )
      AppEmpresaApelido( "NAOCONF" )
   ENDIF
   IF File( "hb_out.log" )
      JpaLogErro()
   ENDIF

   IF GetEnv( "COMPUTERNAME" ) == "JOSEJPA" .AND. ! ( Upper( hb_FNameName( hb_ProgName() ) + ".EXE" ) == "JPA.EXE" )
      IF ! MsgYesNo( "Nome do EXE não é JPA.EXE. Continua" )
         QUIT
      ENDIF
   ENDIF

   SetColor( SetColorNormal() )
   TelaPrinc( "JPA " + AppVersaoExe() )

   DO CASE
   CASE cParam == "MULTIEMPRESA" .OR. cParam == "/MULTIEMPRESA"
      SelecEmp()

   CASE cParam == "/13DEMAIO"
      DO ETCMAIO
      CLOSE DATABASES
      CLS
      QUIT

   CASE cParam == "/ATUALIZA"
      pUpdateExeDown()
      CLS
      QUIT

   ENDCASE
   JpaCfg()
   SetColor( SetColorNormal() )
   IF Len( Directory( "*.dbf" ) ) <= 1 .AND. AppDatabase() == DATABASE_DBF
      IF ! MsgYesNo( "Não tem arquivos de dados, continua criando-os?" )
         QUIT
      ENDIF
   ENDIF
   ze_Update()
   DO WHILE .T.
      Cls()
      TelaEntrada()
      IF Lastkey() == K_ESC
         EXIT
      ENDIF
      AppIsMultithread( AppUserLevel() == 0 )
      mMenuOpcoes := MenuCria( .F. )
      IF ! AbreArquivos( "jpsenha" )
         QUIT
      ENDIF
      pw_MenuAcessos( mMenuOpcoes, AppUserName() )     // Esta funcao e' recursiva
      CLOSE DATABASES
      IF Len( mMenuOpcoes ) == 0
         MsgWarning( "Nenhuma opção liberada para este usuário!" )
      ELSE
         TelaPrinc( "JPA " + AppVersaoExe() )
         lAvisaLicencas := pw_TemAcesso( "PJPLICMOV" )
         IF lAvisaLicencas
            JPLICMOVClass():ShowVencidas()
         ENDIF
         MenuPrinc( mMenuOpcoes )
      ENDIF
       IF AppUserLevel() != 0
         EXIT // não deixa mais trocar usuario
      ENDIF
   ENDDO
   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION SelecEmp()

   LOCAL mEmpresa, oSetKey, GetList := {} // mTmpFile

   oSetKey := SaveSetKey( -8 )
   SetColor( SetColorNormal() )
   Cls()
   mEmpresa := ""
   DO WHILE .T.
      mEmpresa := Pad( mEmpresa, 20 )
      SET KEY K_F9 TO PesquisaEmpresa
      @ 12, 20 SAY "Empresa desejada" GET mEmpresa PICTURE "@K!"
      Mensagem( "Digite empresa, F9 Pesquisa, ESC Sai" )
      READ
      SET KEY K_F9 TO
      IF LastKey() == K_ESC
         QUIT
      ENDIF
      mEmpresa := StrTran( Trim( mEmpresa ), " ", "" )
      IF Empty( mEmpresa )
         MsgWarning( "Nome da empresa em branco" )
         LOOP
      ENDIF
      IF File( mEmpresa + "\jpa.cnf" ) .OR. File( mEmpresa + "\jpa.cfg" )
         DirChange( mEmpresa )
         hb_ThreadStart( { || Sistema() } )
         Inkey(1)
         QUIT
      ENDIF
      IF ! MsgYesNo( mEmpresa + " não instalada! Instala?" )
         LOOP
      ENDIF
      WSave()
      hb_vfDirMake( mEmpresa )
      DirChange( mEmpresa )
      hb_ThreadStart( { || Sistema() } )
      Inkey(1)
      WRestore()
      QUIT
   ENDDO
   RestoreSetKey( oSetKey )

   RETURN NIL

PROCEDURE PesquisaEmpresa

   LOCAL aFiles, cTmpDbf, cTmpCdx, oElement

   SET KEY K_F9 TO
   cTmpDbf := MyTempFile( "DBF" )
   aFiles  := Directory( "*.*", "D" )
   dbCreate( cTmpDbf, { { "EMAPELIDO", "C", 20, 0 }, { "EMDATA", "D",  8, 0 }, { "EMHORA", "C",  8, 0 } } )
   USE ( cTmpDbf ) EXCLUSIVE NEW ALIAS temp
   cTmpCdx := MyTempFile( "CDX" )
   INDEX ON temp->emApelido TO ( cTmpCdx )
   FOR EACH oElement IN aFiles
      IF "D" $ oElement[ F_ATTR ] .AND. Trim( oElement[ F_NAME ] ) <> "." .AND. Trim( oElement[ F_NAME ] ) <> ".." .AND. ! " " $ Trim( oElement[ F_NAME ] )
         APPEND BLANK
         REPLACE ;
            temp->emApelido WITH Upper( oElement[ F_NAME ] ), ;
            temp->emData    WITH oElement[ F_DATE ], ;
            temp->emHora    WITH oElement[ F_TIME ]
      ENDIF
   NEXT
   GOTO TOP
   FazBrowse()
   IF LastKey() != K_ESC
      KEYBOARD Trim( temp->emApelido ) + Chr( K_ENTER )
   ENDIF
   CLOSE DATABASES
   fErase( cTmpDbf )
   fErase( cTmpCdx )
   SET KEY K_F9 TO PesquisaEmpresa

   RETURN
