/*
ZE_TABIPICST
ULTIMA ATUALIZACAO: 2017.06
*/

FUNCTION ZE_TABIPICST()

   LOCAL aList := {}

   AAdd( aList, { "00", "ENTRADA COM RECUPERACAO DE CREDITO" } )
   AAdd( aList, { "01", "ENTRADA TRIBUTADA COM ALIQUOTA ZERO" } )
   AAdd( aList, { "02", "ENTRADA ISENTA" } )
   AAdd( aList, { "03", "ENTRADA NAO TRIBUTADA" } )
   AAdd( aList, { "04", "ENTRADA IMUNE" } )
   AAdd( aList, { "05", "ENTRADA COM SUSPENSAO" } )
   AAdd( aList, { "49", "OUTRAS ENTRADAS" } )
   AAdd( aList, { "50", "SAIDA TRIBUTADA" } )
   AAdd( aList, { "51", "SAIDA TRIBUTADA COM ALIQUOTA ZERO" } )
   AAdd( aList, { "52", "SAIDA ISENTA" } )
   AAdd( aList, { "53", "SAIDA NAO TRIBUTADA" } )
   AAdd( aList, { "54", "SAIDA IMUNE" } )
   AAdd( aList, { "55", "SAIDA COM SUSPENSAO" } )
   AAdd( aList, { "99", "OUTRAS SAIDAS" } )

   RETURN ALIST
