/*
AJUSTACFOP - Ajusta tabelas do governo que geram geradas
José Quintas
*/

REQUEST HB_CODEPAGE_PTISO

FUNCTION Main()

   LOCAL aList := {}, aList1, aList2, oTabelaJPA, oTabelaGoverno, oElement, cTxt

   Set( _SET_CODEPAGE, "PTISO" )

   aList1 := jq_TabCfop()
   aList2 := jq_TabCfopx()

   FOR EACH oTabelaJPA IN aList1 DESCEND
      IF Right( oTabelaJPA[ 1 ], 1 ) == "0"
         AAdd( aList, { oTabelaJPA[ 1 ], oTabelaJPA[ 2 ], 0, 0, 0, 0 } )
         hb_Adel( aList1, oTabelaJPA:__EnumIndex, .T. )
      ELSE
         FOR EACH oTabelaGoverno IN aList2 DESCEND
            IF oTabelaJPA[ 1 ] == Transform( Str( oTabelaGoverno[ 1 ], 4 ), "@R 9.999" )
               AAdd( aList, { oTabelaJPA[ 1 ], Upper( oTabelaGoverno[ 2 ] ), oTabelaGoverno[ 3 ], oTabelaGoverno[ 4 ], oTabelaGoverno[ 5 ], oTabelaGoverno[ 6 ] } )
               hb_Adel( aList1, oTabelaJPA:__EnumIndex, .T. )
               hb_Adel( aList2, oTabelaGoverno:__EnumIndex, .T. )
               EXIT
            ENDIF
         NEXT
      ENDIF
   NEXT
   ? "Restaram JPA"
   FOR EACH oElement IN aList1
      ? oElement[ 1 ], oElement[ 2 ]
      AAdd( aList, { oElement[ 1 ], oElement[ 2 ], 1, 0, 0, 0 } )
   NEXT

   ASort( aList,,, { | a, b | a[ 1 ] < b[ 1 ] } )

   cTxt := [FUNCTION jq_TabCfOp()] + hb_Eol()
   cTxt += hb_Eol()
   cTxt += [   LOCAL aList := {}] + hb_Eol()
   cTxt += hb_Eol()
   FOR EACH oElement IN aList
      cTxt += [   AAdd( aList, { "] + oElement[ 1 ] + [", "] + RetiraAcento( Trim( oElement[ 2 ] ) ) + [", ] + Ltrim( Str( oElement[ 3 ] ) ) + [, ] + ;
         Ltrim( Str( oElement[ 4 ] ) ) + [, ] + Ltrim( Str( oElement[ 5 ] ) ) + [, ] + Ltrim( Str( oElement[ 6 ] ) ) + [ } )] + hb_Eol()
      Inkey()
   NEXT
   cTxt += hb_Eol()
   cTxt += [   RETURN aList] + hb_Eol()
   cTxt += hb_Eol()
   hb_MemoWrit( "jq_tabcfopnew.prg", cTxt )

   RETURN NIL

STATIC FUNCTION RetiraAcento( cTexto )

   LOCAL cLetra

   FOR EACH cLetra IN @cTexto
      DO CASE
      CASE cLetra $ "abcdefghijklmnopqrstuvwxyz"
      CASE cLetra $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      CASE cLetra $ "0123456789"
      CASE cLetra $ " /,.()-"
      CASE cLetra $ "ÀÁÃ" ; cLetra := "A"
      CASE cLetra $ "ÊÉ"  ; cLetra := "E"
      CASE cLetra $ "Í"  ; cLetra := "I"
      CASE cLetra $ "ÔÕÕÓ" ; cLetra := "O"
      CASE cLetra $ "Ç"  ; cLetra := "C"
      CASE cLetra $ "Ü"  ; cLetra := "U"
      CASE cLetra == Chr(0) ; cLetra := ""
      OTHERWISE
         ? cLetra, Asc( cLetra ), cLetra:__EnumIndex, Substr( cTexto, cLetra:__EnumIndex - 25, 50 )
      ENDCASE
   NEXT

   RETURN cTexto
