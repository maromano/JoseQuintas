/*
ze_update00 - TODAS AS CONVERSOES
ZE_UPDATE00 José Quintas
*/

#include "josequintas.ch"
#include "directry.ch"

FUNCTION ze_Update00()

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

   IF AppVersaoDbfAnt() < 0; RemoveLixo();              ENDIF

   RETURN NIL

STATIC FUNCTION RemoveLixo( ... )

   LOCAL acMaskList, acFileList, oFile, oMask, cPath

   acMaskList := hb_AParams()

   IF Len( acMaskList ) != 0
      FOR EACH oMask IN acMaskList
         cPath := iif( "\" $ oMask, Substr( oMask, 1, Rat( "\", oMask ) ), "" )
         acFileList := Directory( oMask )
         FOR EACH oFile IN acFileList
            fErase( cPath + oFile[ F_NAME ] )
            Errorsys_WriteErrorLog( "Eliminado arquivo desativado " + cPath + oFile[ F_NAME ] )
         NEXT
      NEXT
      RETURN NIL
   ENDIF
   RemoveLixo( "*.lzh", "*.tmp", "*.pdf", "*.prn", "*.idx", "*.ndx", "*.cnf", "*.fpt", "*.ftp", "*.vbs", "*.car" )
   RemoveLixo( "temp\*.tmp", "jpawprt.exe", "getmail.exe", "*.htm", "rastrea.dbf", "jplicmov.dbf" )
   RemoveLixo( "rastrea.cdx", "jplicmov.cdx", "ts069", "ts086", "jpa.cfg.backup", "msg_os_fornecedor.txt" )
   RemoveLixo( "jpordser.dbf", "jpcotaca.dbf", "jpvvdem.dbf", "jpvvfin.dbf", "jpordbar.dbf" )
   RemoveLixo( "jpaprint.cfg", "preto.jpg", "jpnfexx.dbf", "aobaagbe", "bbchdjfe", "ajuda.hlp" )
   RemoveLixo( "jpaerror.txt", "ads.ini", "adslocal.cfg", "setupjpa.msi", "duplicados.txt" )

   RETURN NIL
