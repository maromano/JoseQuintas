/*
ZE_APPEMPRESAAPELIDO
José Quintas
*/

FUNCTION AppEmpresaApelido( xValue )

   STATIC AppEmpresaApelido := ""

   IF xValue != NIL
      AppEmpresaApelido := Trim( xValue )
   ENDIF

   RETURN AppEmpresaApelido

