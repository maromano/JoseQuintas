/*
ZE_SETKEY
José Quintas
*/

FUNCTION SaveSetKey( ... )

   LOCAL oSetKey, oKeys, nCont

   oSetKey := {}
   oKeys := hb_aParams()
   FOR nCont = 1 TO Len( oKeys )
      AAdd( oSetKey, { oKeys[ nCont ], SetKey( oKeys[ nCont ], ) } )
      SET KEY oKeys[ nCont ] TO
   NEXT

   RETURN oSetKey

FUNCTION RestoreSetKey( oSetKey )

   LOCAL nCont

   FOR nCont = 1 TO Len( oSetKey )
      SetKey( oSetKey[ nCont, 1 ], oSetKey[ nCont, 2 ] )
   NEXT

   RETURN NIL


