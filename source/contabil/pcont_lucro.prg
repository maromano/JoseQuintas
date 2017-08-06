/*
PCONTLUCRO - CALCULO DO LUCRO
José Quintas
*/

FUNCTION AppLucroDebito()

   THREAD STATIC AppLucroDebito

   IF appLucroDebito == NIL
      AppLucroDebito := Array( 96 )
      Afill( AppLucroDebito, 0 )
   ENDIF

   RETURN AppLucroDebito

FUNCTION AppLucroCredito()

   THREAD STATIC AppLucroCredito

   IF AppLucroCredito == NIL
      AppLucroCredito := Array( 96 )
      Afill( AppLucroCredito, 0 )
   ENDIF

   RETURN AppLucroCredito

