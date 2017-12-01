/*
PPRECANCEL - CANCELA REAJUSTE DE PRECOS
2013 José Quintas
*/

#include "inkey.ch"

PROCEDURE pPreCancel

   LOCAL mDataReajuste := Ctod(""), GetList := {}
   LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() )

   IF ! AbreArquivos( "jppreco" )
      RETURN
   ENDIF
   @ 13, 1 SAY "Data pra excluir reajuste:" GET mDataReajuste
   Mensagem( "Digite data, ESC Sai" )
   READ
   Mensagem()

   IF LastKey() == K_ESC .OR. ! MsgYesNo( "Exclui reajustes de " + Dtoc( mDataReajuste ) + "?" )
      CLOSE DATABASES
      RETURN
   ENDIF

   Mensagem( "Anulando reajuste" )
   WITH OBJECT cnMySql
      :ExecuteCmd( "DELETE FROM JPPREHIS WHERE PHDATA=" + DateSql( mDataReajuste ) + " AND PHOBS LIKE 'REAJ.%'" )
      :cSql := "SELECT PHID, PHITEM, PHCADAS, PHFORPAG, PHVALOR FROM JPPREHIS" + ;
         " INNER JOIN" + ;
         " ( SELECT MAX( PHID ) AS ULTIMOLANC FROM JPPREHIS GROUP BY PHITEM, PHCADAS, PHFORPAG ) AS ULTIMO" + ;
         " ON JPPREHIS.PHID = ULTIMO.ULTIMOLANC" + ;
         " ORDER BY PHITEM, PHCADAS, PHFORPAG"
      :Execute()
      DO WHILE ! :Eof()
         SELECT jppreco
         SEEK :StringSql( "PHITEM" ) + :StringSql( "PHCADAS" ) + :StringSql( "PHFORPAG" )
         IF ! Eof()
            RecLock()
            REPLACE jppreco->pcValor WITH :NumberSql( "PHVALOR" )
            RecUnlock()
         ENDIF
         :MoveNext()
      ENDDO
      :CloseRecordset()
   END WITH
   CLOSE DATABASES

   RETURN

   /*
   UPDATE JPPRECO
   JOIN
   ( SELECT PHID, PHITEM, PHCADAS, PHFORPAG, PHVALOR FROM JPPREHIS
   INNER JOIN
   ( SELECT MAX( PHID ) AS ULTIMOLANC FROM JPPREHIS GROUP BY PHITEM, PHCADAS, PHFORPAG ) AS ULTIMO
   ON JPPREHIS.PHID = ULTIMO.ULTIMOLANC
   ) AS NOVOPRECO
   ON JPPRECO.PCITEM=NOVOPRECO.PHVALOR AND JPPRECO.PHCADAS = NOVOPRECO.PHCADAS AND JPPRECO.PCFORPAG=NOVOPRECO.PHFORPAG

   SET JPPRECO.PCVALOR = NOVOPRECO.PHVALOR
   */
