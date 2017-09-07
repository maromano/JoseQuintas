/*
ZE_GOOGLEMAPS - Mostra mapa do google
2017.09.01 José Quintas
*/

FUNCTION GoogleMaps( ... )

   LOCAL aList, oElement, cCmd

   aList := hb_AParams()

   IF Len( aList ) > 0 .AND. ValType( aList[ 1 ] ) == "A"
      aList := aList[ 1 ]
   ENDIF
   IF Len( aList ) == 0
      MsgExclamation( "Nenhum CEP pra mostrar mapa" )
      RETURN NIL
   ELSEIF Len( aList ) == 1
      cCmd := "http://www.google.com.br/maps/place/" + aList[ 1 ] + "/"
   ELSE
      cCmd := "http://www.google.com.br/maps/dir/"
      IF Len( aList ) > 20
         MsgExclamation( "Limitando a 20 CEPs" )
         ASize( aList, 20 )
      ENDIF
      FOR EACH oElement IN aList
         cCmd += oElement + "/"
      NEXT
   ENDIF
   ShellExecuteOpen( cCmd )

   RETURN NIL
