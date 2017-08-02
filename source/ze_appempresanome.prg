/*
ZE_APPEMPRESANOME
José Quintas
*/

FUNCTION AppEmpresaNome( xValue )

   STATIC AppEmpresaNome := ""

   IF xValue != NIL
      AppEmpresaNome := Trim( xValue )
   ENDIF

   RETURN AppEmpresaNome

