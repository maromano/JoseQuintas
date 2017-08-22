/*
PUTILBACKUP - BACKUP DOS ARQUIVOS
1993

...
2016.06.20.1930 - Formatação de fonte
2016.07.21.1200 - Segurança backup remoto
2016.09.15.0800 - Qtde. backups
2016.10.01.0100 - Não faz backup de rmchart
2016.11.24.1500 - Mais empresas
2017.05.12.1500 - Backup cada 10 dias por 6 meses, máximo 30
2017.05.16.1740 - Empresa com nome vazio
*/

#require "hbziparc.hbc"
#include "inkey.ch"
#include "directry.ch"

PROCEDURE pUtilBackup

   IF ! MsgYesNo( "Confirma Criar ZIP de Backup?" )
      RETURN
   ENDIF
   CLOSE DATABASES
   CriaZip(.T.)
   CLOSE DATABASES

   RETURN

FUNCTION CriaZip( lNovo )

   LOCAL cZipName, acFileList, cFileName, nKey, lErro, cZipSufix, cZipAdicional, oElement, nCont

   hb_Default( @lNovo, .F. )
   cZipSufix  := "-backup-" + Dtos( Date() ) + "-" + Substr( Time(), 1, 2 ) + Substr( Time(), 4, 2 ) + Substr( Time(), 7, 2 ) + ".zip"
   cZipName   := AppEmpresaApelido() + "-backup-" + Dtos( Date() )
   IF Len( Directory( cZipName + "*.zip" ) ) > 0 .AND. ! lNovo
      RETURN NIL
   ENDIF
   CLOSE DATABASES
   ChecaAguarde()
   ChecaAguarde( .T., "Backup Sendo Efetuado" )
   SayScroll( "Verificando arquivos em uso para efetuar backup" )
   nKey   := 0
   DO WHILE .T.
      lErro := .F.
      acFileList := Directory( "*.dbf" )
      FOR EACH oElement IN acFileList
         cFileName := Lower( oElement[ F_NAME ] )
         IF Left( cFileName, 3 ) != "FOX" .AND. ! File( Substr( cFileName, 1, At( ".", cFileName ) - 1 ) + ".dbt" )
            USE ( cFileName ) EXCLUSIVE ALIAS tstbackup
            IF NetErr() .OR. ! Used()
               SayScroll( "Arquivo " + cFileName + " está em uso" )
               lErro = .T.
               USE
               EXIT
            ENDIF
            USE
         ENDIF
      NEXT
      IF nKey == K_ESC .OR. ! lErro
         EXIT
      ENDIF
      Mensagem( "Sistema em uso, tentando novamente em 10 segundos, ESC sai" )
      nKey := Inkey(10)
   ENDDO
   CLOSE DATABASES
   IF nKey == K_ESC
      fErase( "aguarde.txt" )
      RETURN NIL
   ENDIF
   cZipName := AppEmpresaApelido() + cZipSufix
   SayScroll( "Criando arquivo de backup" )
   SayScroll( "Aguarde o termino, ou o sistema podera ficar bloqueado" )
   GrafTempo( "Criando " + cZipName )
   acFileList := Directory( "*.*" )
   FOR EACH oElement IN acFileList
      GrafTempo( oElement:__EnumIndex, Len( acFileList ) )
      IF IsFileToBackup( oElement[ F_NAME ] )
         hb_ZipFile( cZipName, oElement[ F_NAME ] )
      ENDIF
      Inkey()
   NEXT
   CLOSE DATABASES
   Mensagem()
   fErase( "aguarde.txt" )
   ApagaZipAntigos()
   IF Upper( AppEmpresaApelido() ) != "DEMONSTRACAO" .AND. ! ( AppcnMySqlLocal() == NIL )
      SQLBackup()
      hb_ZipFile( cZipName, "backup.sql" )
      fErase( "backup.sql" )
   ENDIF
   IF Len( Directory( "..\haro\*.*" ) ) != 0
      cZipAdicional := AppEmpresaApelido() + "-LOCACAO-" + cZipSufix
      acFileList := Directory( "..\haro\*.*" )
      FOR EACH oElement IN acFileList
         IF IsFileToBackup( oElement[ F_NAME ] )
            hb_ZipFile( cZipAdicional, "..\haro\" + oElement[ F_NAME ] )
         ENDIF
      NEXT
      hb_ZipFile( cZipName, cZipAdicional )
      fErase( cZipAdicional )
      cZipAdicional := AppEmpresaApelido() + "-VENDAS-" + cZipSufix
      acFileList := Directory( "..\..\vendas\vendas\*.*" )
      FOR EACH oElement IN acFileList
         IF IsFileToBackup( oElement[ F_NAME ] )
            hb_ZipFile( cZipAdicional, "..\..\vendas\vendas\" + oElement[ F_NAME ] )
         ENDIF
      NEXT
      hb_ZipFile( cZipName, cZipAdicional )
      fErase( cZipAdicional )
   ENDIF
   IF AppEmpresaApelido() == "DEMONSTRACAO"
      RETURN NIL
   ENDIF
   IF Time() > "06:00" .OR. IsMaquinaJPA()
      IF ! MsgYesNo( "Envia pra JPA" )
         RETURN NIL
      ENDIF
   ENDIF
   Cls()
   SayScroll( "O envio do backup pode ser cancelado, nos próximos 5 segundos, teclando ESC" )
   FOR nCont = 1 TO 5
      IF Inkey(1) == K_ESC
         EXIT
      ENDIF
   NEXT
   IF LastKey() != K_ESC
      Cls()
      SayScroll()
      SayScroll( "Enquanto o backup está sendo enviado por esta janela," )
      SayScroll( "pode ser utilizada outra janela pra trabalhar com o aplicativo" )
      SayScroll( "Em atualização de versão, não poderá abrir outra janela" )
      UploadJPA( cZipName, "\www\backup\" + cZipName, "josequintas" )
   ENDIF

   RETURN NIL

PROCEDURE pUtilBackupEnvia

   LOCAL aFileList

   aFileList := Directory( AppEmpresaApelido() + "-backup*.zip" )
   IF Len( aFileList ) == 0
      MsgStop( "Crie primeiro o arquivo na opção de backup!" )
      RETURN
   ENDIF
   ASort( aFileList, , , { | a, b | Dtos( a[ F_DATE ] ) + a[ F_TIME ] > Dtos( b[ F_DATE ] ) + b[ F_TIME ] } )
   SayScroll( "O arquivo que será transmitido é " + aFileList[ 1, F_NAME ] )
   SayScroll( "Foi criado em " + Dtoc( aFileList[ 1, F_DATE] ) + " " + aFileList[ 1, F_TIME ] )
   SayScroll( "Seu tamanho é de " + LTrim( Str( Int( aFileList[ 1, F_SIZE ] / 1024 ) ) ) + " kb " )
   SayScroll()
   IF ( Date() - aFileList[ 1, F_DATE ] ) > 1
      IF ! MsgYesNo( "ATENÇÃO!!! Backup tem mais de um dia " + Dtoc( aFileList[ 1, F_DATE ] ) + ". Continua?" )
         RETURN
      ENDIF
   ENDIF
   IF ! MsgYesNo( "Confirma o envio do backup de " + Dtoc( aFileList[ 1, F_DATE ] ) + " para JPA?" )
     RETURN
   ENDIF

   Mensagem( "Enviando email de arquivo..." )
   UploadJPA( aFileList[ 1, F_NAME ], "\www\backup\" + aFileList[ 1, F_NAME ], "josequintas" )
   MsgExclamation( "Fim do envio!" )

   RETURN

STATIC FUNCTION ApagaZipAntigos()

   LOCAL oDirZip, oFile, dDate

   oDirZip := Directory( "*.rar" )
   FOR EACH oFile IN oDirZip
      fErase( oFile[ F_NAME ] )
   NEXT

   oDirZip := Directory( "*.zip" )
   ASort( oDirZip,,,{ | a, b | a[ F_NAME ] < b[ F_NAME ] } )

   dDate := Ctod("")
   FOR EACH oFile IN oDirZip
      DO CASE
      CASE Len( Directory( "*.zip" ) ) < 30
      CASE ! AppEmpresaApelido() $ oFile[ F_NAME ]
         SayScroll( "Excluindo " + oFile[ F_NAME ]  )
         fErase( oFile[ F_NAME ] )
      CASE Date() - oFile[ F_DATE ] > 200
         SayScroll( "Excluindo " + oFile[ F_NAME ]  )
         fErase( oFile[ F_NAME ] )
      CASE Left( Dtos( oFile[ F_DATE ] ), 7 ) != Left( Dtos( dDate ), 7 )
         dDate := oFile[ F_DATE ]
      CASE Date() - oFile[ F_DATE ] > 10
         SayScroll( "Excluindo " + oFile[ F_NAME ]  )
         fErase( oFile[ F_NAME ] )
      ENDCASE
   NEXT

   RETURN NIL

STATIC FUNCTION IsFileToBackup( cFileName )

   LOCAL lReturn := .F.

   cFileName := Upper( cFileName )
   DO CASE
   CASE ".CDX" $ cFileName
   CASE ".EXE" $ cFileName
   CASE ".ZIP" $ cFileName
   CASE ".RAR" $ cFileName
   CASE ".BAT" $ cFileName
   CASE "RMCHART" $ cFileName
   CASE cFileName == "AGUARDE.TXT"
   OTHERWISE
      lReturn := .T.
   ENDCASE

   RETURN lReturn
