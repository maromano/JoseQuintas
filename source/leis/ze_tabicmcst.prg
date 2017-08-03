/*
ZE_TABICMCST
ULTIMA ATUALIZACAO: 2017.06
*/

FUNCTION ZE_TABICMCST()

   LOCAL aList := {}

   AAdd( aList, { "00 ", "TRIBUTADA INTEGRALMENTE" } )
   AAdd( aList, { "10 ", "TRIBUTADA COM COBRANCA DO ICMS POR ST" } )
   AAdd( aList, { "20 ", "COM REDUCAO DA BASE DE CALCULO" } )
   AAdd( aList, { "30 ", "ISENTA OU NAO TRIBUTADA COM ICMS ST" } )
   AAdd( aList, { "40 ", "ISENTA" } )
   AAdd( aList, { "41 ", "NAO TRIBUTADA" } )
   AAdd( aList, { "50 ", "SUSPENSAO" } )
   AAdd( aList, { "51 ", "DIFERIMENTO" } )
   AAdd( aList, { "60 ", "SUBST.TRIBUTARIA" } )
   AAdd( aList, { "70 ", "REDUCAO DA BASE DE CALCULO E ICMS ST" } )
   AAdd( aList, { "90 ", "OUTRAS" } )
   AAdd( aList, { "101", "TRIBUTADA SIMPLES NAC. COM CREDITO" } )
   AAdd( aList, { "102", "TRIBUTADA SIMPLES NAC. SEM CREDITO" } )
   AAdd( aList, { "103", "ISENCAO DO ICMS SIMPLES NAC" } )
   AAdd( aList, { "201", "TRIBUTADA SIMPLES NAC. COM CREDITO E ICMS ST" } )
   AAdd( aList, { "202", "TRIBUTADA SIMPLES NAC. SEM CREDITO E ICMS ST" } )
   AAdd( aList, { "203", "ISENCAO DO ICMS SIMPLES NAC.E ICMS ST" } )
   AAdd( aList, { "300", "IMUNE DO SIMPLES NACIONAL" } )
   AAdd( aList, { "400", "NAO TRIBUTADA PELO SIMPLES NACIONAL" } )
   AAdd( aList, { "500", "SIMPLES NAC ICMS COBRADO ANTERIORMENTE POR ST" } )
   AAdd( aList, { "900", "OUTROS (SIMPLES NACIONAL)" } )

   RETURN ALIST
