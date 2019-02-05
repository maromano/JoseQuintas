/*
ze_update0000 - TODAS AS CONVERSOES
José Quintas
*/

#include "josequintas.ch"
#include "directry.ch"

FUNCTION ze_Update0000()

   SayScroll()
   SayScroll( "Verificando se há ajustes adicionais" )
   DelTempFiles()
   IF AppDatabase() != DATABASE_DBF
      RETURN NIL
   ENDIF
   ze_UpdateDbf()
   ze_UpdateMysql()
   IF AppVersaoDbfAnt() < 20170101; ze_Update2016(); ENDIF
   IF AppVersaoDbfAnt() < 20180101; ze_Update2017(); ENDIF
   IF AppVersaoDbfAnt() < 20190101; ze_update2018(); ENDIF
   IF AppVersaoDbfAnt() < 20200101; ze_Update2019(); ENDIF
   //ze_update9999()

   RETURN NIL
