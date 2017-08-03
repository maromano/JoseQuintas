/*
ZE_UPDATESTRU - Atualiza estruturas de DBF
José Quintas
*/

FUNCTION ValidaStru( cDbfFile, mStruOk, lApagaAnterior )

   LOCAL mStruFile, nCont, nCont2, nCont3, cTempFile, mSelect, nLastRec, mDbt
   LOCAL mNumericos, mNumero, mPicture, mNumCampo, mDbfMemo, mMudaStru
   LOCAL mCdxName

   hb_Default( @lApagaAnterior, .F. )
   mMudaStru := .F.

   IF ! ".dbf" $ Lower( cDbfFile ) .AND. ! ".tmp" $ Lower( cDbfFile )
      cDbfFile := cDbfFile + ".dbf"
   ENDIF
   mSelect  := Select()
   FOR nCont = 1 TO Len( mStruOk )
      IF Len( mStruOk[ nCont, 1 ] ) > 10
         MsgExclamation( "ValidaStru: Nome inválido " + cDbfFile + ", campo " + mStruOk[ nCont, 1 ] )
      ENDIF
      FOR nCont2 = 1 TO Len( mStruOk )
         IF mStruOk[ nCont, 1 ] == mStruOk[ nCont2, 1 ] .AND. nCont != nCont2
            MsgExclamation( "ValidaStru: Nome repetido " + cDbfFile + ", campo " + mStruOk[ nCont, 1 ] )
         ENDIF
      NEXT
      IF Len( mStruOk[ nCont ] ) == 3 // Decimais zero quando nao definir
         AAdd( mStruOk[ nCont ], 0 )
      ENDIF
   NEXT
   SELECT 0
   IF lApagaAnterior .OR. ! File( cDbfFile )
      dbCreate( cDbfFile, mStruOk )
      fErase( cDbfFile + ".cdx" )
      IF ! ".TMP" $ Upper( cDbfFile )
         GravaOcorrencia( ,, cDbfFile + ", Estrutura, criacao" )
      ENDIF
   ELSE
      mDbfMemo := Substr( cDbfFile, 1, RAt( ".", cDbfFile ) - 1 )
      fErase( mDbfMemo + ".dbt" ) // Apaga sempre que existir
   ENDIF
   USE ( cDbfFile ) ALIAS Validastru
   IF NetErr()
      USE
      MsgStop( cDbfFile + " não disponível, processo interrompido!" )
      SELECT ( mSelect )
      RETURN .F.
   ELSE
      mStruFile := dbStruct()
      USE
      FOR nCont = 1 TO Len( mStruOk )
         IF Len( mStruOk[ nCont, 1 ] ) > 10
            MsgStop( "Nome Inválido" + cDbfFile + " " + mStruOk[ nCont, 1 ] )
         ENDIF
         mNumCampo := 0
         FOR nCont2 = 1 TO Len( mStruFile )
            IF Pad( mStruFile[ nCont2, 1 ], 10 ) == Pad( Upper( mStruOk[ nCont, 1 ] ), 10 )
               FOR nCont3 = 2 TO 4
                  IF mStruFile[ nCont2, nCont3 ] != mStruOk[ nCont, nCont3 ]
                     SayScroll( cDbfFile + " (*) " + mStruFile[ nCont2, 1 ] )
                     mMudaStru := .T.
                  ENDIF
               NEXT
               mNumCampo := nCont2
            ENDIF
         NEXT
         IF mNumCampo == 0
            SayScroll( cDbfFile+" (+) "+mStruOk[ nCont, 1 ] )
            GravaOcorrencia( ,, cDbfFile+" (+) " + mStruOk[ nCont, 1 ] )
            mMudaStru := .T.
         ENDIF
      NEXT
      FOR nCont = 1 TO Len( mStruFile )
         mNumCampo := 0
         FOR nCont2 = 1 TO Len( mStruOk )
            IF Pad( mStruFile[ nCont, 1], 10 ) == Pad( Upper( mStruOk[ nCont2, 1 ] ), 10 )
               mNumCampo := nCont2
               EXIT
            ENDIF
         NEXT
         IF mNumCampo == 0
            SayScroll( cDbfFile + " (-) " + mStruFile[ nCont, 1 ] )
            GravaOcorrencia( ,, cDbfFile  + " (-) " + mStruFile[ nCont, 1 ] )
            mMudaStru := .T.
         ENDIF
      NEXT
   ENDIF
   IF mMudaStru
      mCdxName := cDbfFile
      IF "." $ mCdxName
         mCdxName := Substr( mCdxName, 1, At( ".", mCdxName ) - 1 ) + ".cdx"
      ENDIF
      fErase( mCdxName )
      USE ( cDbfFile ) ALIAS ValidaStru EXCLUSIVE
      IF NetErr()
         USE
         MsgStop( "(" + cDbfFile + ") em uso, não pode ser atualizado!" )
         SELECT ( mSelect )
         RETURN .F.
      ENDIF
      ChecaAguarde( .T., "Atualização em andamento de " + cDbfFile )
      SayScroll( cDbfFile + ", verificando antes de atualizar estrutura" )
      GOTO TOP
      mNumericos := {}
      FOR nCont = 1 TO Len( mStruFile )
         GrafProc()
         IF mStruFile[ nCont, 2 ] == "N"
            //Verifica se campo permanece, senao despreza checagem
            mNumCampo := 0
            FOR nCont2 = 1 TO Len( mStruOk )
               IF Pad( mStruFile[ nCont, 1 ], 10 ) == Pad( mStruOk[ nCont2 ], 10 )
                  mNumCampo := nCont
               ENDIF
            NEXT
            IF mNumCampo != 0
               IF mStruFile[ nCont, 4 ] == 0
                  mPicture := Replicate( "9", mStruOk[ mNumCampo, 3 ] )
               ELSE
                  mPicture := Replicate( "9", mStruOk[ mNumCampo, 3 ] - mStruOk[ mNumCampo, 4 ] - 1 ) + "." + Replicate( "9", mStruOk[ mNumCampo, 4 ] )
               ENDIF
               AAdd( mNumericos, { nCont, Val( mPicture ) } )
            ENDIF
         ENDIF
      NEXT
      IF Len( mNumericos ) > 0
         GrafTempo()
         DO WHILE ! Eof()
            GrafTempo( RecNo(), LastRec() + 1 ) // GrafProc()
            FOR nCont = 1 TO Len( mNumericos )
               GrafProc()
               mNumero := FieldGet( mNumericos[ nCont, 1 ] )
               IF mNumero > mNumericos[ nCont, 2 ] .OR. mNumero < -Int( mNumericos[ nCont, 2 ] / 10 )
                  SayScroll( cDbfFile + ", inválido, " + FieldName( mNumericos[ nCont, 1 ] ) + ", reg." + LTrim( Str( Recno() ) ) + ", campo zerado" )
                  GravaOcorrencia( ,, cDbfFile+", inválido, " + FieldName( mNumericos[ nCont, 1 ] ) + ", reg." + LTrim( Str( Recno() ) ) + ", campo zerado" )
                  RecLock()
                  FieldPut( mNumericos[ nCont, 1 ], 0 )
               ENDIF
            NEXT
            RecUnlock()
            SKIP
         ENDDO
      ENDIF
      nLastRec := LastRec()
      USE
      Mensagem()
      SayScroll( cDbfFile + ", atualizando" )
      cTempFile := MyTempFile( "dbf", ".\" )
      dbCreate( cTempFile, mStruOk )
      USE ( cTempFile ) ALIAS ValidaStru EXCLUSIVE
      GrafTempo()
      APPEND FROM ( cDbfFile ) FOR GrafTempo( RecNo(), nLastRec + 1 )
      USE
      Mensagem()
      fErase( cDbfFile )
      fRename( cTempFile, cDbfFile )
      mDbt := Left( cDbfFile, Len( cDbfFile ) - 3 ) + "fpt"
      IF File( mDbt )
         fErase( mDbt )
      ENDIF
      IF File( Left( cTempFile, Len( cTempFile ) - 3 ) + "fpt" )
         fRename( Left( cTempFile, Len( cTempFile ) - 3 ) + "fpt", mDbt )
      ENDIF
      fErase( cDbfFile + ".cdx" )
      IF ! ".TMP" $ Upper( cDbfFile )
         GravaOcorrencia( ,, cDbfFile + ", Estrutura, Criado e/ou atualizado, Ok" )
      ENDIF
      fErase( "aguarde.txt" )
   ENDIF
   SELECT ( mSelect )

   RETURN .T.
