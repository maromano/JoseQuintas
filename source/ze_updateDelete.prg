/*
ZE_UPDATEDELETE - Apaga Informação antiga
2017.08.21 José Quintas
*/

FUNCTION ApagaAntigo()

   ApagaEstoqueAntigo( Stod( "20080101" ) )
   ApagaNotaAntigo( Stod( "20080101" ) )
   ApagaAnpAntigo( Stod( "20140101" ) )
   ApagaPedidoAntigo( Stod( "20080101" ) )
   AjustaRefPedidos()

   ApagaMySqlAntigo()

   RETURN NIL

STATIC FUNCTION ApagaEstoqueAntigo( dDataLimite )

   LOCAL cItem, aSaldos, nCont, nNumDep, oElement
   LOCAL nNumLan := 1, aRecNoList, nRecNo, nAtual := 0
   LOCAL nQtd, nQtdLanc, nQtdLancSaldo

   SayScroll( "Eliminando estoque anterior a " + Dtoc( dDataLimite ) )
   IF ! AbreArquivos( "jptabel", "jpitem", "jpestoq" )
      QUIT
   ENDIF
   SELECT jpestoq
   OrdSetFocus( "jpestoq3" ) // item + data + E/s + numlan
   GrafTempo( "Eliminando estoque antigo" )
   GOTO TOP
   DO WHILE ! Eof()
      Inkey()
      GrafTempo( nAtual++, LastRec() )
      cItem   := jpestoq->esItem
      IF Encontra( cItem, "jpitem", "item" ) .AND. "IMOBILIZADO" $ AuxProDepClass():Descricao( jpitem->ieProDep )
         SKIP
         LOOP
      ENDIF
      aSaldos := {}
      FOR nCont = 1 TO 9
         AAdd( aSaldos, { 0, 0 } )
      NEXT
      aRecNoList := {}
      DO WHILE cItem == jpestoq->esItem .AND. jpestoq->esDatLan < dDataLimite .AND. ! Eof()
         Inkey()
         nNumDep := Max( 1, Val( jpestoq->esNumDep ) )
         IF jpestoq->esTipLan == "2"
            IF aSaldos[ nNumDep, 1 ] <= 0
               aSaldos[ nNumDep, 1 ] += jpestoq->esQtde
               IF aSaldos[ nNumDep, 1 ] < 0
                  aSaldos[ nNumDep, 2 ] := 0
               ELSE
                  aSaldos[ nNumDep, 2 ] := aSaldos[ nNumDep, 1 ] * jpestoq->esValor
               ENDIF
            ELSE
               aSaldos[ nNumDep, 1 ] += jpestoq->esQtde
               aSaldos[ nNumDep, 2 ] += jpestoq->esValor * jpestoq->esQtde
            ENDIF
         ELSE
            aSaldos[ nNumDep, 2 ] -= aSaldos[ nNumDep, 2 ] / aSaldos[ nNumDep, 1 ] * jpestoq->esQtde
            aSaldos[ nNumDep, 1 ] -= jpestoq->esQtde
            IF aSaldos[ nNumDep, 2 ] < 0 .OR. aSaldos[ nNumDep, 1 ] == 0
               aSaldos[ nNumDep, 2 ] := 0
            ENDIF
         ENDIF
         AAdd( aRecNoList, RecNo() )
         SKIP
      ENDDO
      FOR EACH oElement IN aSaldos
         Inkey()
         IF oElement[ 1 ] != 0
            RecAppend()
            REPLACE ;
               jpestoq->esNumLan WITH "SALDO", ;
               jpestoq->esNumDoc WITH "SALDO", ;
               jpestoq->esItem   WITH cItem, ;
               jpestoq->esObs    WITH "SALDO NESTA DATA", ;
               jpestoq->esTipLan WITH iif( oElement[ 1 ] > 0, "2", "1" ), ;
               jpestoq->esDatLan WITH dDataLimite - 1, ;
               jpestoq->esNumDep WITH Str( oElement:__EnumIndex, 1 ), ;
               jpestoq->esQtde   WITH Abs( oElement[ 1 ] ), ;
               jpestoq->esValor  WITH Abs( oElement[ 2 ] ) / iif( oElement[ 1 ] == 0, 1, oElement[ 1 ] )
            RecUnlock()
         ENDIF
      NEXT
      FOR EACH oElement IN aRecNoList
         Inkey()
         GOTO ( oElement )
         RecDelete()
      NEXT
      SEEK cItem SOFTSEEK
      DO WHILE cItem == jpestoq->esItem .AND. ! Eof()
         Inkey()
         SKIP
      ENDDO
   ENDDO
   GOTO TOP
   GrafTempo( "Verificando saldo negativo" )
   DO WHILE ! Eof()
      Inkey()
      cItem := jpestoq->esItem
      nQtd          := 0
      nQtdLanc      := 0
      nQtdLancSaldo := 0
      nNumDep       := 0
      DO WHILE jpestoq->esItem == cItem .AND. ! Eof()
         Inkey()
         IF jpestoq->esNumLan == Pad( "SALDO", 6 )
            nQtdLancSaldo += 1
            nNumDep := Val( jpestoq->esNumDep )
         ELSE
            nQtdLanc += 1
            nNumDep  := 0
         ENDIF
         IF jpestoq->esTipLan== "1"
            nQtd -= jpestoq->esQtde
         ELSE
            nQtd += jpestoq->esQtde
         ENDIF
         SKIP
      ENDDO
      IF nQtdLanc == 0 .AND. nQtdLancSaldo == 1 .AND. nQtd < 0 .AND. nNumDep == 1
         SEEK cItem
         IF jpestoq->esNumLan == Pad( "SALDO", 6 ) .AND. jpestoq->esTipLan == "1" .AND. jpestoq->esTipLan == "1" // segurança
            Encontra( cItem, "jpitem", "item" )
            SayScroll( "Eliminado saldo negativo " + jpitem->ieDescri )
            RecDelete()
         ENDIF
         SKIP
      ENDIF
   ENDDO
   OrdSetFocus( "numlan" )
   DO WHILE .T.
      Inkey()
      SEEK Pad( "SALDO", 6 )
      nRecNo := RecNo()
      IF Eof()
         EXIT
      ENDIF
      DO WHILE .T.
         Inkey()
         SEEK StrZero( nNumLan, 6 )
         IF Eof()
            EXIT
         ENDIF
         nNumLan += 1
      ENDDO
      GOTO nRecNo
      RecLock()
      REPLACE jpestoq->esNumLan WITH StrZero( nNumLan, 6 )
      RecUnlock()
      nNumLan += 1
   ENDDO
   CLOSE DATABASES
   ze_DbfPackIndex( DbfInd( "jpestoq" ) )

   RETURN NIL

STATIC FUNCTION ApagaNotaAntigo( dDataLimite )

   GrafTempo( "Eliminando notas anteriores a " + Dtoc( dDataLimite ) )
   IF ! AbreArquivos( "jpnota" )
      QUIT
   ENDIF
   SET ORDER TO 0
   GOTO TOP
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      Inkey()
      IF jpnota->nfDatEmi < dDataLimite
         RecDelete()
      ENDIF
      SKIP
   ENDDO
   CLOSE DATABASES
   ze_DbfPackIndex( DbfInd( "jpnota" ) )

   RETURN NIL

STATIC FUNCTION ApagaAnpAntigo( dDataLimite )

   GrafTempo( "Apagando ANP anterior a " + Dtoc( dDataLimite ) )
   IF ! AbreArquivos( "jpanpmov" )
      QUIT
   ENDIF
   SET ORDER TO 0
   GOTO TOP
   GrafTempo( "Eliminando ANP anterior a " + Dtoc( dDataLimite ) )
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      Inkey()
      IF jpanpmov->amDatRef < dDataLimite
         RecDelete()
      ENDIF
      SKIP
   ENDDO
   CLOSE DATABASES
   ze_DbfPackIndex( DbfInd( "jpanpmov" ) )

   RETURN NIL

STATIC FUNCTION ApagaPedidoAntigo( dDataLimite )

   IF ! AbreArquivos( "jppedi", "jpitped", "jpnota", "jpfinan", "jpestoq" )
      QUIT
   ENDIF
   SELECT jppedi
   SET ORDER TO 0
   GOTO TOP
   GrafTempo( "Eliminando pedidos anteriores a " + Dtoc( dDataLimite ) )
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      Inkey()
      IF jppedi->pdDatEmi >= dDataLimite .OR. RecNo() > LastRec() - 100
         SKIP
         LOOP
      ENDIF
      IF ! Empty( jppedi->pdPedido )
         SELECT jpitped
         SEEK jppedi->pdPedido
         DO WHILE jppedi->pdPedido == jpitped->ipPedido .AND. ! Eof()
            RecDelete()
            SKIP
         ENDDO
         SELECT jpestoq
         OrdSetFocus( "pedido" )
         DO WHILE .T.
            SEEK jppedi->pdPedido
            IF Eof()
               EXIT
            ENDIF
            RecLock()
            REPLACE jpestoq->esPedido WITH ""
            RecUnlock()
         ENDDO
         SELECT jpnota
         OrdSetFocus( "pedido" )
         DO WHILE .T.
            SEEK jppedi->pdPedido
            IF Eof()
               EXIT
            ENDIF
            RecLock()
            REPLACE jpnota->nfPedido WITH ""
            RecUnlock()
         ENDDO
         SELECT jpfinan
         OrdSetFocus( "pedido" )
         DO WHILE .T.
            SEEK jppedi->pdPedido
            IF Eof()
               EXIT
            ENDIF
            RecLock()
            REPLACE jpfinan->fiPedido WITH ""
            RecUnlock()
         ENDDO
         SELECT jppedi
      ENDIF
      RecDelete()
      SKIP
   ENDDO
   CLOSE DATABASES
   ze_DbfPackIndex( DbfInd( "jppedi" ) )
   ze_DbfPackIndex( DbfInd( "jpitped" ) )

   RETURN NIL

STATIC FUNCTION AjustaRefPedidos()

   IF ! AbreArquivos( "jpnota", "jpestoq", "jpfinan", "jppedi", "jpitped" )
      QUIT
   ENDIF
   OrdSetFocus( "pedido" )
   SELECT jpitped
   SET ORDER TO 0
   GOTO TOP
   GrafTempo( "Eliminando itens de pedido" )
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      Inkey()
      IF Empty( jpitped->ipPedido ) .OR. ! Encontra( jpitped->ipPedido, "jppedi", "pedido" )
         RecDelete()
      ENDIF
      SKIP
   ENDDO
   SELECT jpnota
   SET ORDER TO 0
   GOTO TOP
   GrafTempo( "Ajustando notas fiscais" )
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      Inkey()
      IF ! Empty( jpnota->nfPedido) .AND. ! Encontra( jpnota->nfPedido, "jppedi", "pedido" )
         RecLock()
         REPLACE jpnota->nfPedido WITH ""
         RecUnlock()
      ENDIF
      SKIP
   ENDDO
   SELECT jpestoq
   SET ORDER TO 0
   GOTO TOP
   GrafTempo( "Ajustando estoque" )
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      Inkey()
      IF ! Empty( jpestoq->esPedido ) .AND. ! Encontra( jpestoq->esPedido, "jppedi", "pedido" )
         RecLock()
         REPLACE jpestoq->esPedido WITH ""
         RecUnlock()
      ENDIF
      SKIP
   ENDDO
   SELECT jpfinan
   SET ORDER TO 0
   GOTO TOP
   GrafTempo( "Ajustando financeiro" )
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      Inkey()
      IF ! Empty( jpfinan->fiPedido) .AND. ! Encontra( jpfinan->fiPedido, "jppedi", "pedido" )
         RecLock()
         REPLACE jpfinan->fiPedido WITH ""
         RecUnlock()
      ENDIF
      SKIP
   ENDDO

   CLOSE DATABASES

   RETURN NIL

STATIC FUNCTION ApagaMySqlAntigo()

   LOCAL cnMySql := ADOClass():New( AppcnMySqlLocal() )
   LOCAL cnServerJPA := ADOClass():New( AppcnServerJPA() )

   IF AppcnMySqlLocal() == NIL
      RETURN NIL
   ENDIF
   cnMySql:ExecuteCmd( "DELETE FROM JPREGUSO WHERE RUINFINC < '2015/01/01'" )
   cnMySql:ExecuteCmd( "DELETE FROM JPFISICA WHERE FSDATA < '2014-01-01'" )

   IF ! IsMaquinaJPA()
      RETURN NIL
   ENDIF
   cnServerJPA:ExecuteCmd( "DELETE FROM JPEMANFE WHERE ENINFALT < '2017/01/01'" )
   cnServerJPA:Close()

   RETURN NIL
