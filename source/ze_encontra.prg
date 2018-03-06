/*
ZE_ENCONTRA
José Quintas
*/

MEMVAR m_Prog

FUNCTION Encontra( cChave, cAliasToSeek, cSeekOrder )

   LOCAL nSelect, cOrdSetFocus, lSeekOk, nRecNo

   hb_Default( @cAliasToSeek, Alias() )
   nSelect := Select()
   IF Select( cAliasToSeek ) == 0
      IF Type( "m_Prog" ) == "C"
         Errorsys_WriteErrorLog( "Modulo: " + m_Prog + " faltou abrir: " + cAliasToSeek, 3 )
      ELSE
         Errorsys_WriteErrorLog( "Modulo: N/A faltou abrir: " + cAliasToSeek, 3 )
      ENDIF
      AbreArquivos( cAliasToSeek )
   ENDIF
   SELECT ( Select( cAliasToSeek ) )
   cOrdSetFocus := OrdSetFocus()
   IF cSeekOrder == NIL
      cSeekOrder := OrdSetFocus()
   ELSEIF Type( "cSeekOrder" ) == "N"
      cSeekOrder := OrdName( cSeekOrder ) // Converte numero para nome da Tag
   ENDIF
   OrdSetFocus( cSeekOrder )
   SEEK ( cChave )
   lSeekOk := ( ! Eof() )
   nRecNo  := RecNo()
   IF ! ( cOrdSetFocus == OrdSetFocus() )
      OrdSetFocus( cOrdSetFocus )
      GOTO ( nRecNo )
   ENDIF
   SELECT ( nSelect )

   RETURN ( lSeekOk )
