/*
ZE_UPDATESTRU - Atualiza estruturas de DBF
José Quintas
*/

#include "dbstruct.ch"

FUNCTION ValidaStru( cDbfFile, mStruOk, lApagaAnterior )

   LOCAL cTempFile, mSelect, nLastRec, mDbt, mDbfMemo, mMudaStru, mCdxName

   hb_Default( @lApagaAnterior, .F. )

   IF ! ".DBF" $ Lower( cDbfFile ) .AND. ! ".TMP" $ Upper( cDbfFile )
      cDbfFile := cDbfFile + ".DBF"
   ENDIF
   mSelect  := Select()
   TestaNovaEstrutura( cDbfFile, @mStruOk )
   SELECT 0
   IF lApagaAnterior .OR. ! File( cDbfFile )
      dbCreate( cDbfFile, mStruOk )
      fErase( cDbfFile + ".CDX" )
      IF ! ".TMP" $ Upper( cDbfFile )
         GravaOcorrencia( ,, cDbfFile + ", Estrutura, criacao" )
      ENDIF
   ELSE
      mDbfMemo := Substr( cDbfFile, 1, Rat( ".", cDbfFile ) - 1 )
      fErase( mDbfMemo + ".DBT" ) // Apaga sempre que existir
   ENDIF
   USE ( cDbfFile ) ALIAS Validastru
   IF NetErr()
      USE
      MsgStop( cDbfFile + " não disponível, processo interrompido!" )
      SELECT ( mSelect )
      RETURN .F.
   ENDIF
   mMudaStru := ! ComparaEstrutura( cDbfFile, mStruOk )
   USE
   IF mMudaStru
      mCdxName := cDbfFile
      IF "." $ mCdxName
         mCdxName := Substr( mCdxName, 1, At( ".", mCdxName ) - 1 ) + ".CDX"
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
      TestaCamposNumericos( cDbfFile, mStruOk )
      nLastRec := LastRec()
      USE
      Mensagem()
      SayScroll( cDbfFile + ", atualizando" )
      cTempFile := MyTempFile( "DBF", ".\" )
      dbCreate( cTempFile, mStruOk )
      USE ( cTempFile ) ALIAS ValidaStru EXCLUSIVE
      GrafTempo()
      APPEND FROM ( cDbfFile ) FOR GrafTempo( RecNo(), nLastRec + 1 )
      USE
      Mensagem()
      fErase( cDbfFile )
      fRename( cTempFile, cDbfFile )
      mDbt := Left( cDbfFile, Len( cDbfFile ) - 3 ) + "FPT"
      IF File( mDbt )
         fErase( mDbt )
      ENDIF
      IF File( Left( cTempFile, Len( cTempFile ) - 3 ) + "FPT" )
         fRename( Left( cTempFile, Len( cTempFile ) - 3 ) + "FPT", mDbt )
      ENDIF
      fErase( cDbfFile + ".CDX" )
      IF ! ".TMP" $ Upper( cDbfFile )
         GravaOcorrencia( ,, cDbfFile + ", Estrutura, Criado e/ou atualizado, Ok" )
      ENDIF
      fErase( "aguarde.txt" )
   ENDIF
   SELECT ( mSelect )

   RETURN .T.

STATIC FUNCTION TestaNovaEstrutura( cDbfFile, aStructure )

   LOCAL oElement, oElement2

   FOR EACH oElement IN aStructure
      oElement[ DBS_NAME ] := Upper( oElement[ DBS_NAME ] )
      IF Len( oElement[ DBS_NAME ] ) > 10
         MsgExclamation( "ValidaStru: Nome inválido " + cDbfFile + ", campo " + oElement[ DBS_NAME ] )
      ENDIF
      FOR EACH oElement2 IN aStructure
         IF oElement[ DBS_NAME ] == oElement2[ DBS_NAME ] .AND. oElement:__EnumIndex != oElement2:__EnumIndex
            MsgExclamation( "ValidaStru: Nome repetido " + cDbfFile + ", campo " + oElement[ DBS_NAME ] )
         ENDIF
      NEXT
      IF Len( oElement ) == 3 // Decimais zero quando nao definir
         AAdd( oElement, 0 )
      ENDIF
   NEXT

   RETURN NIL

STATIC FUNCTION ComparaEstrutura( cDbfFile, aNova )

   LOCAL oElement, oElement2, nNumCampo, lOk := .T., aArquivo, nCont

   aArquivo := dbStruct()
   FOR EACH oElement IN aNova
      nNumCampo := 0
      FOR EACH oElement2 IN aArquivo
         IF Pad( oElement[ DBS_NAME ], 10 ) == Pad( oElement2[ DBS_NAME ], 10 )
            FOR nCont = 2 TO 4
               IF oElement[ nCont ] != oElement2[ nCont ]
                  SayScroll( cDbfFile + " (*) " + oElement[ DBS_NAME ] )
                  lOk := .F.
               ENDIF
            NEXT
            nNumCampo := oElement2:__EnumIndex
         ENDIF
      NEXT
      IF nNumCampo == 0
         SayScroll( cDbfFile + " (+) " + oElement[ DBS_NAME ] )
         GravaOcorrencia( ,, cDbfFile+" (+) " + oElement[ DBS_NAME ] )
         lOk := .F.
      ENDIF
   NEXT
   FOR EACH oElement IN aArquivo
      nNumCampo := 0
      FOR EACH oElement2 IN aNova
         IF Pad( oElement[ DBS_NAME ], 10 ) == Pad( oElement2[ DBS_NAME ], 10 )
            nNumCampo := oElement2:__EnumIndex
            EXIT
         ENDIF
      NEXT
      IF nNumCampo == 0
         SayScroll( cDbfFile + " (-) " + oElement[ DBS_NAME ] )
         GravaOcorrencia( ,, cDbfFile  + " (-) " + oElement[ DBS_NAME ] )
         lOk := .F.
      ENDIF
   NEXT

   RETURN lOk

STATIC FUNCTION TestaCamposNumericos( cDbfFile, mStruOk )

   LOCAL mStruFile, aNumericos := {}, oElement, oElement2, cPicture, nValue

   SayScroll( cDbfFile + ", verificando antes de atualizar estrutura" )
   mStruFile := dbStruct()
   GOTO TOP
   FOR EACH oElement IN mStruFile
      GrafProc()
      IF oElement[ DBS_TYPE ] == "N"
         //Verifica se campo permanece, senao despreza checagem
         FOR EACH oElement2 IN mStruOk
            IF Pad( oElement[ DBS_NAME ], 10 ) == Pad( oElement2[ DBS_NAME ], 10 )
               IF oElement2[ DBS_DEC ] == 0
                  cPicture := Replicate( "9", oElement2[ DBS_LEN ] )
               ELSE
                  cPicture := Replicate( "9", oElement2[ DBS_LEN ] - oElement2[ DBS_DEC ] - 1 ) + "." + ;
                     Replicate( "9", oElement2[ DBS_DEC ] )
               ENDIF
               AAdd( aNumericos, { oElement:__EnumIndex, Val( cPicture ) } )
               EXIT
            ENDIF
         NEXT
      ENDIF
   NEXT
   IF Len( aNumericos ) > 0
      GrafTempo()
      DO WHILE ! Eof()
         GrafTempo( RecNo(), LastRec() + 1 ) // GrafProc()
         FOR EACH oElement IN aNumericos
            GrafProc()
            nValue := FieldGet( oElement[ 1 ] )
            IF nValue > oElement[ 2 ] .OR. nValue < -Int( oElement[ 2 ] / 10 )
               SayScroll( cDbfFile + ", inválido, " + FieldName( oElement[ 1 ] ) + ", reg." + LTrim( Str( Recno() ) ) + ", campo zerado" )
               GravaOcorrencia( ,, cDbfFile+", inválido, " + FieldName( oElement[ 1 ] ) + ", reg." + LTrim( Str( Recno() ) ) + ", campo zerado" )
               RecLock()
               FieldPut( oElement[ 1 ], 0 )
            ENDIF
         NEXT
         SKIP
      ENDDO
   ENDIF

   RETURN NIL
