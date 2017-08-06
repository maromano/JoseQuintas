/*
ZE_ABREARQUIVOS - ABERTURA DE ARQUIVOS
1995 José Quintas
*/

#include "josequintas.ch"
#require "hbnetio.hbc"

FUNCTION AbreArquivos( ... )

   LOCAL nCont, lAbriu := .T., cDbfName, nSelect, acDbfList

   acDbfList := hb_AParams()
   FOR nCont = 1 TO Len( acDbfList )
      cDbfName := Lower( acDbfList[ nCont ] )
      nSelect  := Select( cDbfName )
      SELECT ( nSelect )
      IF ! File( PathAndFile( cDbfName ) + ".dbf" ) .AND. AppDatabase() == DATABASE_DBF
         MsgStop( "Arquivo " + PathAndFile( cDbfName ) + ".dbf não existe!" )
         CLOSE DATABASES
         lAbriu := .F.
         EXIT
      ENDIF
      USE ( PathAndFile( cDbfName ) )
      IF NetErr()
         CLOSE DATABASES
         MsgStop( "Arquivo " + cDbfName + " não pode ser aberto neste momento!" )
         lAbriu := .F.
         EXIT
      ENDIF
      IF ! Used()
         CLOSE DATABASES
         MsgStop( "Arquivo " + cDbfName + " não pode ser aberto. Pode estar ruim!" )
         lAbriu := .F.
         EXIT
      ENDIF
      IF Select( cDbfName ) == 0
         CLOSE DATABASES
         MsgStop( "Arquivo " + cDbfName + " falha na checagem de Select()" )
         lAbriu := .F.
         EXIT
      ENDIF
      IF Upper( Alias() ) != Upper( cDbfName )
         CLOSE DATABASES
         MsgStop( "Arquivo " + cDbfName + " falha na checagem de Alias()" )
         lAbriu := .F.
         EXIT
      ENDIF
      IF ! AbreInd( cDbfName )
         lAbriu := .F.
         CLOSE DATABASES
         EXIT
      ENDIF
   NEXT
   IF lAbriu
      GOTO TOP
   ENDIF

   RETURN lAbriu

FUNCTION AbreInd( cDbf )

   LOCAL oElement, lTxtAguarde, nRecOk, nRecTot, acIndice
   MEMVAR xCampo
   PRIVATE xCampo

   acIndice := IndDbf( cDbf )
   IF Len( acIndice ) == 0
      RETURN .T.
   ENDIF
   IF ! File( PathAndFile( cDbf ) + ".cdx" ) .AND. AppDatabase() == DATABASE_DBF
      //IF ! fLock()
      //   MsgStop( "Arquivo está em uso! Não pode reindexar!" )
      //   RETURN .F.
      //ENDIF
      lTxtAguarde := File( "aguarde.txt" )
      IF ! lTxtAguarde
         ChecaAguarde( .T., "Reindexação em andamento" )
      ENDIF
      nRecOk  := 0
      nRecTot := 1 + ( LastRec() * Len( acIndice ) )
      WSave( MaxRow() - 1, 0, MaxRow(), MaxCol() )
      Mensagem()
      GrafTempo( "Criando " + PathAndFile( cDbf ) + ".cdx" )
      FOR EACH oElement IN acIndice
         SET INDEX TO // para usar for
         GOTO TOP     // para usar for
         xCampo := oElement[ 2 ]
         IF Len( oElement ) == 2
            INDEX ON &xCampo TAG ( oElement[ 1 ] ) EVAL GrafInd( nRecOk, nRecTot )
         ELSE
            INDEX ON &xCampo TAG ( oElement[ 1 ] ) FOR &( oElement[ 3 ] ) EVAL GrafInd( nRecOk, nRecTot )
         ENDIF
         SET INDEX TO
         nRecOk += LastRec()
      NEXT
      WRestore()
      IF ! lTxtAguarde
         fErase( "aguarde.txt" )
      ENDIF
      SET INDEX TO
      //UNLOCK
      //USE ( PathAndFile( cDbf ) ) // Reabre arquivo se reindexou
   ENDIF
   dbSetIndex( PathAndFile( cDbf ) + ".CDX" )
   SET ORDER TO 1

   RETURN .T.

FUNCTION PathAndFile( cFileName )

   IF AppDatabase() == DATABASE_HBNETIO
      cFileName := "net:" + AppEmpresaApelido() + "/" + cFileName
   ENDIF
   cFileName := Lower( cFileName )

   RETURN cFileName

FUNCTION UseSoDbf( cDbfFile, lExclusivo, lInfinito, lShowMsg )

   LOCAL lOk   := .T.

   hb_Default( @lExclusivo, .F. )
   hb_Default( @lInfinito, .F. )
   hb_Default( @lShowMsg, .T. )
   SELECT ( Select( cDbfFile ) )
   DO WHILE .T.
      IF lExclusivo
         USE ( cDbfFile ) EXCLUSIVE
      ELSE
         USE ( cDbfFile )
      ENDIF
      IF NetErr()
         USE
         IF ! lShowMsg
            lOk := .F.
            EXIT
         ENDIF
         IF ! MsgYesNo( cDbfFile + " não disponível ou em uso! Tentar novamente?" )
            lOk := .F.
            EXIT
         ENDIF
      ELSEIF ! Used()
         IF ! lShowMsg
            lOk := .F.
            EXIT
         ENDIF
         IF ! MsgYesNo( cDbfFile + " danificado! Tentar novamente?" )
            lOk := .F.
            EXIT
         ENDIF
      ELSE
         EXIT
      ENDIF
   ENDDO
   IF lOk .AND. lExclusivo
      fErase( cDbfFile + ".cdx" )
   ENDIF

   RETURN lOk
