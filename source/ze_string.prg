/*
ZE_STRING
José Quintas
*/

FUNCTION StringSql( cString )

   cString := Trim( cString )
   cString := StrTran( cString, [\], [\\] )
   cString := StrTran( cString, ['], [\'] )
   cString := StrTran( cString, Chr(13), "\" + Chr(13) )
   cString := StrTran( cString, Chr(10), "\" + Chr(10) )
   cString := ['] + cString + [']

   RETURN cString

FUNCTION DateSql( dDate )

   LOCAL cString

   IF Empty( dDate )
      cString := "NULL"
   ELSE
      cString := Transform( Dtos( dDate ), "@R 9999-99-99" )
   ENDIF

   RETURN cString

FUNCTION NumberSql( xValue )

   xValue := Ltrim( Str( xValue, 20, 6 ) )
   IF "." $ xValue
      DO WHILE Right( xValue, 1 ) == "0"
         xValue := Substr( xValue, 1, Len( xValue ) - 1 )
      ENDDO
      IF Right( xValue, 1 ) == "."
         xValue := Substr( xValue, 1, Len( xValue ) - 1 )
      ENDIF
   ENDIF

   RETURN xValue

FUNCTION ValueSql( xValue )

   LOCAL cString

   DO CASE
   CASE xValue == NIL
      cString := "NULL"
   CASE ValType( xValue ) == "N"
      cString := NumberSql( xValue )
   CASE ValType( xValue ) == "D"
      cString := DateSql( xValue )
   OTHERWISE
      cString := StringSql( xValue )
   ENDCASE

   RETURN cString

FUNCTION ToString( xValue )

   DO CASE
   CASE ValType( xValue ) == "L" ; RETURN iif( xValue, ".T.", ".F." )
   CASE ValType( xValue ) == "C" ; RETURN xValue
   CASE ValType( xValue ) == "D" ; RETURN Dtoc( xValue )
   CASE ValType( xValue ) == "N"
      xValue := Ltrim( Str( xValue ) )
      DO WHILE "." $ xValue .AND. Right( xValue, 1 ) == "0" .OR. Right( xValue, 1 ) == "."
         xValue := Substr( xValue, 1, Len( xValue ) - 1 )
      ENDDO
      RETURN Ltrim( Str( xValue ) )
   ENDCASE

   RETURN ""

FUNCTION UpperLower( mTexto )

   LOCAL mTexto2 := "", mMaiuscula := .T., nCont, mLetra

   FOR nCont = 1 TO Len( mTexto )
      mLetra := Substr( mTexto, nCont, 1 )
      DO CASE
      CASE mLetra == " "
         mTexto2 += mLetra
         mMaiuscula  := .T.
      CASE mMaiuscula
         mTexto2 += Upper( mLetra )
         mMaiuscula  := .F.
      OTHERWISE
         mTexto2 += Lower( mLetra )
      ENDCASE
   NEXT

   RETURN mTexto2

FUNCTION FillZeros( cString )

   cString := StrZero( Val( cString ), Len( cString ) )

   RETURN .T.
