/*
ZE_UPDATE2019 - Conversões 2019
2019 José Quintas
*/

#include "directry.ch"

FUNCTION ze_Update2019()

   IF AppVersaoDbfAnt() < 20190202.2; Conv0202(); ENDIF

   RETURN NIL

STATIC FUNCTION Conv0202()

   IF ! AbreArquivos( "jptabel" )
      QUIT
   ENDIF
   SET ORDER TO 0
   DO WHILE ! Eof()
      IF jptabel->axTabela == "IPICST" .AND. Len( Trim( jptabel->axCodigo ) ) > 2
         RecLock()
         REPLACE jptabel->axCodigo WITH StrZero( Val( jptabel->axCodigo ), 2 )
         RecUnlock()
      ENDIF
      SKIP
   ENDDO
   CLOSE DATABASES

   RETURN NIL
