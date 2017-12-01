/*
PFISCTOTAIS - TOTAL DE LANCAMENTOS NO LFISCAL
2005.11 José Quintas
*/

PROCEDURE pFiscTotais

   LOCAL mTmpFile, mStruOk, mTipLan, mMesLan, mTotal, mAnoLan

   IF ! AbreArquivos( "jplfisc" )
      RETURN
   ENDIF
   SELECT jplfisc

   IF ! MsgYesNo( "Faz somatória do LFiscal para resumo?" )
      RETURN
   ENDIF

   Mensagem( "Aguarde, somando..." )
   mTmpFile := TempFileArray(2)

   mStruOk := { { "MES", "C", 7, 0 }, { "ENTRADAS", "N", 10, 0 }, { "SAIDAS", "N", 10, 0 } }
   fErase( mTmpFile[ 1 ] )
   SELECT 0
   dbCreate( mTmpFile[ 1 ], mStruOk )
   USE ( mTmpFile[ 1] ) alias temp
   INDEX ON temp->Mes TO ( mTmpFile[ 2 ] )
   SELECT jplfisc
   OrdSetFocus( "jplfisc3" )
   GOTO TOP
   DO WHILE ! Eof()
      GrafProc()
      mTipLan := jplfisc->lfTipLan
      mMesLan := Month( jplfisc->lfDatLan )
      mAnoLan := Year( jplfisc->lfDatLan )
      mTotal  := 0
      DO WHILE mMesLan == Month( jplfisc->lfDatLan ) .AND. mAnoLan == Year( jplfisc->lfDatLan ) .AND. ;
            mTipLan == jplfisc->lfTipLan .AND. ! Eof()
         mTotal += 1
         SKIP
      ENDDO
      SELECT temp
      SEEK StrZero( mAnoLan, 4 ) + "/" + StrZero( mMesLan, 2 )
      IF Eof()
         RecAppend()
         REPLACE temp->Mes WITH StrZero( mAnoLan, 4 ) + "/" + StrZero( mMesLan, 2 )
         RecUnlock()
      ENDIF
      RecLock()
      IF mTipLan == "1"
         REPLACE temp->Saidas WITH  temp->Saidas + mTotal
      ELSE
         REPLACE temp->Entradas WITH  temp->Entradas + mTotal
      ENDIF
      RecUnlock()
      SELECT jplfisc
   ENDDO
   SELECT temp
   GOTO TOP
   FazBrowse( { { "MES   ENTRADAS   SAÍDAS", { || temp->Mes + " " + Str( temp->Entradas, 10 ) + " " + Str( temp->Saidas, 10 ) } } } )
   SELECT ( Select( "temp" ) )
   CLOSE DATABASES
   fErase( mTmpFile[ 1 ] )
   fErase( mTmpFile[ 2 ] )

   RETURN
