/*
ZE_REDE - ROTINAS PARA USO EM REDE
1995.04 José Quintas
*/

#include "inkey.ch"

FUNCTION RecLock( lForever )

   LOCAL nCont := 1

   hb_Default( @lForever, .T. )
   wSave( MaxRow() - 1, 0, MaxRow(), MaxCol() )
   DO WHILE .T.
      IF rLock()
         SKIP 0
         EXIT
      ENDIF
      Mensagem( "Aguardando liberação do registro em " + Alias() + "... Tentativa " + lTrim( Str( nCont ) ) + iif( lForever, "", ". ESC cancela" ) )
      IF Inkey( 0.5 ) == K_ESC .AND. ! lForever
         EXIT
      ENDIF
      nCont += 1
   ENDDO
   WRestore()

   RETURN ( rLock() )

FUNCTION RecAppend( lForever )

   LOCAL nCont := 1, lOk := .F.

   hb_Default( @lForever, .T. )
   wSave( MaxRow()-1, 0, MaxRow(), MaxCol() )
   DO WHILE .T.
      APPEND BLANK
      IF ! NetErr()
         lOk := .T.
         RecLock()
         SKIP 0
         EXIT
      ENDIF
      Mensagem( "Aguardando liberação do arquivo: " + Alias() + "... Tentativa " + LTrim( Str( nCont ) ) + iif( lForever, "", ". ESC cancela" ) )
      IF Inkey( 0.5 ) == K_ESC .AND. ! lForever
         EXIT
      ENDIF
      nCont += 1
   ENDDO
   WRestore()

   RETURN lOk

FUNCTION RecDelete( lForever )

   LOCAL lOk := .F.

   hb_Default( @lForever, .T. )
   IF RecLock( lForever )
      DELETE
      RecUnlock()
      lOk := .T.
   ENDIF

   RETURN lOk

FUNCTION RecUnlock()

   SKIP 0
   UNLOCK

   RETURN NIL
