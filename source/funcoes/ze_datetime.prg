/*
ZE_DATETIME
José Quintas
*/

FUNCTION UltDia( dData )

   dData += ( 40 - Day( dData ) )
   dData -= Day( dData )

   RETURN dData

FUNCTION Idade( dDataNasc, dDataCalc )

   LOCAL nDias, nMeses, nAnos

   hb_Default( @dDataCalc, Date() )
   IF Dtoc( dDataNasc ) == "  /  /  "
      RETURN "*Indefinido*"
   ENDIF
   nAnos := Year( dDataCalc ) - Year( dDataNasc )
   IF Substr( Dtos( dDataCalc ), 5 ) < Substr( Dtos( dDataNasc ), 5 )
      nAnos = nAnos - 1
   ENDIF
   nMeses = ( 12 - Month( dDataNasc ) ) + Month( dDataCalc )
   DO CASE
   CASE Day( dDataCalc ) = Day( dDataNasc )
      nDias := 0
   CASE Day( dDataCalc ) < Day( dDataNasc )
      nMeses = nMeses - 1
      nDias := Day( UltDia( dDataNasc ) ) - Day( dDataNasc ) + Day( dDataCalc )
   OTHERWISE
      nDias := Day( dDataCalc ) - Day( dDataNasc )
   ENDCASE
   nMeses = Mod( nMeses, 12 )

   RETURN LTrim( Str( nAnos, 3 ) ) + " ano(s), " + LTrim( Str( nMeses, 3 ) ) + " mes(es), " + LTrim( Str( nDias, 3 ) ) + " dia(s)"

FUNCTION TimeAdd( cTime, cTipo, nQtde )

   LOCAL nHora, nMinuto, nSegundo, cResultado

   nHora    := Val( Substr( cTime, 1, 2 ) )
   nMinuto  := Val( Substr( cTime, 4, 2 ) )
   nSegundo := Val( Substr( cTime, 7, 2 ) )
   DO CASE
   CASE cTipo == "H"
      nHora += nQtde
   CASE cTipo == "M"
      nMinuto += nQtde
   CASE cTipo == "S"
      nSegundo += nQtde
   ENDCASE
   IF nSegundo >= 60
      nMinuto += Int( nSegundo / 60 )
      nSegundo -= ( Int( nSegundo / 60 ) * 60 )
   ENDIF
   IF nMinuto >= 60
      nHora += Int( nMinuto / 60 )
      nMinuto -= ( Int( nMinuto / 60 ) * 60 )
   ENDIF
   IF nHora > 23
      cResultado := "23:59:59"
   ELSE
      nHora := nHora - ( Int( nHora / 24 ) * 24 )
      cResultado := StrZero( nHora, 2 ) + ":" + StrZero( nMinuto, 2 ) + ":" + StrZero( nSegundo, 2 )
   ENDIF

   RETURN cResultado
