/*
ZE_NOVAVERSAO
1995 José Quintas
*/

#include "inkey.ch"
#include "directry.ch"

FUNCTION NovaVersao()

   LOCAL cTime, cTimeExe, oFile
   THREAD STATIC cTimeOld := "", cTimeExeOld := ""

   IF Empty( cTimeOld )
      cTimeOld := Time()
   ENDIF
   cTime := Time()
   IF Left( cTime, 7 ) == Left( cTimeOld, 7 )
      RETURN NIL
   ENDIF
   cTimeExe := ""
   FOR EACH oFile IN Directory( "*.EXE" )
      IF Dtos( oFile[ F_DATE ] ) + oFile[ F_TIME ] > cTimeExe
         cTimeExe := Dtos( oFile[ F_DATE ] ) + oFile[ F_TIME ]
      ENDIF
   NEXT
   IF Empty( cTimeExeOld )
      cTimeExeOld := cTimeExe
   ENDIF
   IF cTimeExe > cTimeExeOld
      CLOSE DATABASES
      MsgWarning( "Detectada instalação de novo programa!" + hb_Eol() + "Recarregue o sistema!" )
      CLS
      QUIT
   ENDIF
   ChecaAguarde()
   cTimeOld := Time()

   RETURN NIL

FUNCTION ChecaAguarde( lCriaAguarde, cTexto )

   LOCAL nKey
   MEMVAR m_Prog

   hb_Default( @lCriaAguarde, .F. )
   hb_Default( @cTexto, "" )
   IF lCriaAguarde
      HB_MemoWrit( "aguarde.txt", cTexto + Pad( AppUserName(), 10 ) + " " + DriveSerial() + " " + m_Prog )
      RETURN NIL
   ENDIF
   IF ! File( "aguarde.txt" )
      RETURN NIL
   ENDIF
   DO WHILE File( "aguarde.txt" )
      Cls
      ?
      ? "Atenção!"
      ?
      ? "Informação recebida"
      ?
      ? MemoRead( "aguarde.txt", 200 )
      ?
      ? "Na pasta do sistema foi encontrado o arquivo AGUARDE.TXT."
      ? "O sistema cria esse arquivo quando um processo exige que"
      ? "nenhuma outra máquina esteja usando o sistema."
      ? "Por exemplo o backup e atualizações, onde todos tem que"
      ? "parar de usar o sistema."
      ?
      ? "Ao término do processo, o sistema será liberado"
      ?
      ? "Se por acaso nao deveria estar bloqueado, entao:"
      ? "Entre na pasta do sistema e apague o arquivo AGUARDE.TXT"
      ? "Isto será por sua conta e risco"
      ?
      ? "Último teste em " + Time()
      ? "O sistema tentará novamente após 2 minutos"
      ?
      ? "Tecle ENTER para tentar imediatamente, ESC para desistir"
      nKey := Inkey(120)
      IF nKey == K_ESC
         CLS
         QUIT
      ENDIF
   ENDDO
   Cls
   ?
   ? "Como pode se tratar de uma atualização de versao do programa"
   ? "será necessário carregar o sistema novamente."
   ? "Tecle ENTER"
   Inkey(0)
   CLS
   QUIT

   RETURN NIL

//FUNCTION LastTimeFile( cFiltro )

//   LOCAL cTime, aFile, nCont, cTimeTemp

//   cTime    := Space(6)
//   aFile := Directory( hb_DirBase() + cFiltro )
//   FOR nCont = 1 TO Len( aFile )
//      cTimeTemp := ( Dtos( aFile[ nCont, 3 ] ) + aFile[ nCont, 4 ] )
//      IF cTimeTemp > cTime
//         cTime := cTimeTemp
//      ENDIF
//   NEXT

//   RETURN cTime
