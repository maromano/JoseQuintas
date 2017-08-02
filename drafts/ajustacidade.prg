/*
AJUSTACIDADE - Ajusta caracteres dos arquivos PRG indicados
*/

REQUEST HB_CODEPAGE_PTISO

FUNCTION Main()

   LOCAL aList := {}, aList1, aList2, oTabelaJPA, oTabelaGoverno, oElement, cTxt

   Set( _SET_CODEPAGE, "PTISO" )

   aList1 := jq_TabCidade()
   aList2 := jq_TabCidadex()

   FOR EACH oTabelaJPA IN aList1 DESCEND
      IF oTabelaJPA[ 2 ] == "EX"
         AAdd( aList, { oTabelaJPA[ 1 ], oTabelaJPA[ 2 ], oTabelaJPA[ 3 ] } )
         hb_Adel( aList1, oTabelaJPA:__EnumIndex, .T. )
      ELSE
         FOR EACH oTabelaGoverno IN aList2 DESCEND
            IF oTabelaJPA[ 3 ] == oTabelaGoverno[ 3 ]
               AAdd( aList, { oTabelaJPA[ 1 ], oTabelaJPA[ 2 ], oTabelaJPA[ 3 ] } )
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
      AAdd( aList, { oElement[ 1 ], oElement[ 2 ], oElement[ 3 ] } )
   NEXT
   ? "Restaram Governo"
   FOR EACH oElement IN aList2
      ? oElement[ 4 ], Substr( oElement[ 3 ], 1, 2 ), oElement[ 3 ]
      AAdd( aList, { oElement[ 4 ], ToUF( oElement[ 3 ] ), oElement[ 3 ] } )
   NEXT

   ASort( aList,,, { | a, b | a[ 3 ] < b[ 3 ] } )

   cTxt := [FUNCTION jq_TabCidade()] + hb_Eol()
   cTxt += hb_Eol()
   cTxt += [   LOCAL aList := {}] + hb_Eol()
   cTxt += hb_Eol()
   FOR EACH oElement IN aList
      cTxt += [   AAdd( aList, { "] + RetiraAcento( oElement[ 2 ] ) + [", "] + oElement[ 3 ] + [", "] + RetiraAcento( Trim( oElement[ 1 ] ) ) + [" } )] + hb_Eol()
      Inkey()
   NEXT
   cTxt += hb_Eol()
   cTxt += [   RETURN aList] + hb_Eol()
   cTxt += hb_Eol()
   hb_MemoWrit( "jq_tabcidadenew.prg", cTxt )

   RETURN NIL

STATIC FUNCTION RetiraAcento( cTexto )

   LOCAL cLetra

   cTexto := Upper( cTexto )

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

STATIC FUNCTION ToUF( cValue )

   cValue := Left( cValue, 2 )
   DO CASE
   CASE cValue == "15" ; cValue := "PA"
   CASE cValue == "22" ; cValue := "PI"
   CASE cValue == "42" ; cValue := "SC"
   CASE cValue == "43" ; cValue := "RS"
   CASE cValue == "50" ; cValue := "MS"
   CASE cValue == "53" ; cValue := "DF"
   ENDCASE

   RETURN cValue
