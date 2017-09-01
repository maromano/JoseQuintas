/*
ZE_GOOGLEMAPS - Mostra mapa do google
2017.09.01 José Quintas
*/

FUNCTION GoogleMaps( aCepList )

   LOCAL oElement, cCmd

   IF ValType( aCepList ) != "A" .OR. Len( aCepList ) == 0
      MsgExclamation( "Nenhum CEP pra mostrar mapa" )
      RETURN NIL
   ELSEIF Len( aCepList ) == 1
      cCmd := "http://www.google.com.br/maps/place/" + aCepList[ 1 ] + "/"
   ELSE
      cCmd := "http://www.google.com.br/maps/dir/"
      IF Len( aCepList ) > 20
         MsgExclamation( "Limitando a 20 CEPs" )
         ASize( aCepList, 20 )
      ENDIF
      FOR EACH oElement IN aCepList
         cCmd += oElement + "/"
      NEXT
   ENDIF
   ShellExecuteOpen( cCmd )

   RETURN NIL
