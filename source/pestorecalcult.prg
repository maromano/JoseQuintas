/*
PESTORECALCULT - Recalcula ultima compra/venda e custo contábil
José Quintas
*/

PROCEDURE pEstoRecalcUlt

   LOCAL nAtual, nTotal

   IF ! MsgYesNo( "Confirma processamento?" )
      RETURN
   ENDIF
   IF ! AbreArquivos( "jpitem", "jpestoq", "jppedi", "jptransa" )
      RETURN
   ENDIF
   SayScroll( "18/03/10 - Ajustando custo contábil e última entrada/saída" )
   SELECT jpitem
   GOTO TOP
   GrafTempo( "Atualizando últ.entrada/saída e custo contábil" )
   nAtual := 0
   nTotal := LastRec()
   DO WHILE ! Eof()
      GrafTempo( nAtual++, nTotal )
      UltimaEntradaItem( jpitem->ieItem )
      UltimaSaidaItem( jpitem->ieItem )
      CustoContabilItem()
      SKIP
   ENDDO
   CLOSE DATABASES
   MsgExclamation( "Fim" )

   RETURN
