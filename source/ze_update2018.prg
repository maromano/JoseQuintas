/*
ZE_UPDATE2018 - Conversões 2018
2018 José Quintas

2018.04.03 Movidas atualizações permanentes pra este fonte
*/

#include "directry.ch"

FUNCTION ze_Update2018()

   IF AppVersaoDbfAnt() < 20180501; Costureiras(); ENDIF
   IF AppVersaoDbfAnt() < 20170816; RemoveLixo();       ENDIF
   IF AppVersaoDbfAnt() < 20170820; pw_DeleteInvalid(); ENDIF // Último, pra remover desativados
   // IF AppVersaoDbfAnt() < 20180401; Update20180401();   ENDIF

   RETURN NIL

STATIC FUNCTION Costureiras()

   LOCAL oElement, aList := { ;
      { "020000", "REMESSA PRA CORTE", "C+5" }, ;
      { "021000", "REMESSA PRA SELO", "C+6" }, ;
      { "022000", "REMESSA PRA COSTURA", "C+7" }, ;
      { "023000", "REMESSA PRA EMBALAGEM", "C+8" }, ;
      { "024000", "CORTE INTERNO", "C+9" }, ;
      { "030020", "RETORNO DE CORTE", "C-5,C+9" }, ;
      { "031021", "RETORNO DE SELO", "C-6,C+9" }, ;
      { "032022", "RETORNO DE COSTURA", "C-7,C+9" }, ;
      { "033023", "RETORNO DE EMBALAGEM", "C-8,C+9" } }

   IF ! "DRICAR" $ AppEmpresaApelido()
      RETURN NIL
   ENDIF
   IF ! AbreArquivos( "jptransa" )
      RETURN NIL
   ENDIF
   FOR EACH oElement IN aList
      IF ! Encontra( oElement[ 1 ], "jptransa", "numlan" )
         RecAppend()
         REPLACE ;
            jptransa->trTransa WITH oElement[ 1 ], ;
            jptransa->trDescri WITH oElement[ 2 ], ;
            jptransa->trReacao WITH oElement[ 3 ]
         RecUnlock()
      ENDIF
   NEXT
   CLOSE DATABASES

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
   RemoveLixo( "*.lzh", "*.tmp", "*.prn", "*.idx", "*.ndx", "*.cnf", "*.fpt", "*.ftp", "*.vbs", "*.car" )
   RemoveLixo( "temp\*.tmp", "jpawprt.exe", "getmail.exe", "*.htm", "rastrea.dbf", "jplicmov.dbf" )
   RemoveLixo( "rastrea.cdx", "jplicmov.cdx", "ts069", "ts086", "jpa.cfg.backup", "msg_os_fornecedor.txt" )
   RemoveLixo( "jpordser.dbf", "jpcotaca.dbf", "jpvvdem.dbf", "jpvvfin.dbf", "jpordbar.dbf" )
   RemoveLixo( "jpaprint.cfg", "preto.jpg", "jpnfexx.dbf", "aobaagbe", "bbchdjfe", "ajuda.hlp" )
   RemoveLixo( "jpaerror.txt", "ads.ini", "adslocal.cfg", "setupjpa.msi", "duplicados.txt" )
   RemoveLixo( "jpanpins.dbf", "jpanpope.dbf", "jpanpage.dbf", "ba_auto.dbf", "ba_grup.dbf" )
   RemoveLixo( "ba_movi.dbf", "jpnfexml.dbf" )

   RETURN NIL
