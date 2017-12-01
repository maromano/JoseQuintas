/*
PCONTNUMDIA - NUMERACAO DO(S) DIARIO(S)
1992.07 José Quintas
*/

#include "inkey.ch"

PROCEDURE PCONTNUMDIA

   LOCAL nCont, nCont2, GetList := {}, nNumMes, m_Ano, nLivro, nPagina
   MEMVAR m_cMes, cCont
   PRIVATE m_cMes, cCont

   IF ! AbreArquivos( "jpempre" )
      RETURN
   ENDIF
   SELECT jpempre
   @ 5, 22 SAY "MESES"
   @ 5, 40 SAY "DIÁRIO"
   @ 5, 50 SAY "PÁGINA"

   FOR nCont = 0 TO 7
      FOR nCont2 = 1 TO 12
         nNumMes := nCont * 12 + nCont2
         m_ano := jpempre->emAnoBase + nCont
         @ 6 + nCont2, 22 SAY Replicate( ".", 15 ) + ":"
         @ 6 + nCont2, 40 SAY Space(5)
         @ 6 + nCont2, 50 SAY Space(5)
         IF nNumMes <= 96
            m_cmes    := StrZero( nNumMes, 2 )
            @ 6 + nCont2, 22 SAY NomeMes( nNumMes ) + "/" + StrZero( m_ano, 4 )
            nLivro := nPagina := 0
            DiarioLoad( nNumMes, @nLivro, @nPagina )
            m_Livro&m_cMes := nLivro
            m_Pagina&m_cMes := nPagina
            @ 6 + nCont2, 40 GET m_Livro&m_cmes  PICTURE "@K 9999" VALID m_Livro&m_cMes >= 0
            @ 6 + nCont2, 50 GET m_Pagina&m_cMes PICTURE "@K 9999" VALID m_Pagina&m_cMes >= 0
         ENDIF
      NEXT
      Mensagem( "Digite campos, ESC abandona todas as alterações" )
      READ
      IF lastkey() == K_ESC
         EXIT
      ENDIF
   NEXT
   IF Lastkey() != K_ESC
      FOR nCont = 1 TO 96
         m_cMes := StrZero( nCont, 2 )
         DiarioSave( nCont, m_Livro&m_cMes, m_Pagina&m_cMes )
      NEXT
   ENDIF
   CLOSE DATABASES

   RETURN

FUNCTION DiarioLoad( nMes, nLivro, nPagina )

   LOCAL nNumAno, nNumMes, cTxt

   nNumAno := Int( ( nMes - 1 ) / 12 ) + 1
   nNumMes := Mod( ( nMes - 1 ), 12 ) + 1
   cTxt    := Substr( &( "jpempre->emDiario" + Str( nNumAno, 1 ) ), nNumMes * 10 - 9, 10 )
   nLivro  := Val( Substr( cTxt, 1, 4 ) )
   nPagina := Val( Substr( cTxt, 6, 4 ) )

   RETURN NIL

FUNCTION DiarioSave( nMes, nLivro, nPagina )

   LOCAL nNumAno, nNumMes, cTxt, anLivro, anPagina, nCont, nSelect

   nSelect  := Select()
   anLivro  := Array(12)
   anPagina := Array(12)
   aFill( anLivro, 0 )
   aFill( anPagina, 0 )
   nNumAno := Int( ( nMes - 1 ) / 12 ) + 1
   nNumMes := Mod( ( nMes - 1 ), 12 ) + 1
   FOR nCont = 1 TO 12
      anLivro[ nCont ]  := Val( Substr( &( "jpempre->emDiario" + Str( nNumAno, 1 ) ), nCont * 10 - 9, 4 ) )
      anPagina[ nCont ] := Val( Substr( &( "jpempre->emDiario" + Str( nNumAno, 1 ) ), nCont * 10 - 4, 4 ) )
   NEXT
   anLivro[ nNumMes ]  := nLivro
   anPagina[ nNumMes ] := nPagina
   cTxt := ""
   FOR nCont = 1 TO 12
      cTxt += StrZero( anLivro[ nCont ], 4 ) + "," + StrZero( anPagina[ nCont ], 4 ) + ","
   NEXT
   SELECT jpempre
   RecLock()
   REPLACE &( "jpempre->emDiario" + Str( nNumAno, 1 ) ) WITH cTxt
   RecUnlock()
   SELECT ( nSelect )

   RETURN NIL
