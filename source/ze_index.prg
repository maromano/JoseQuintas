/*
ZE_INDEX - ROTINAS AUXILIARES DE INDEXACAO
1990.12 José Quintas
*/

#include "inkey.ch"
#include "set.ch"

FUNCTION ModuloPackIndex( aDbfInd, lNoUserSelection )

   LOCAL acTxtDbf := {}
   LOCAL alMakeIndex := {}
   LOCAL nCont, nOpcAll, acTxtAll, nOpcFile

   CLOSE DATABASES
   hb_Default( @lNoUserSelection, .F. )
   FOR nCont = 1 TO Len( aDbfInd )
      AAdd( acTxtDbf, aDbfInd[ nCont, 1 ] + " - " + aDbfInd[ nCont, 2 ] )
      AAdd( alMakeIndex, .T. )
   NEXT

   WOpen( 5, 10, 9, 36, "Regrava/Organiza" )
   nOpcAll := 1
   DO WHILE .T.
      Mensagem( "Selecione e tecle ENTER, ou <código>, ESC sai" )
      acTxtAll := {}
      AAdd( acTxtAll, { 7, 11, " A - Todos os arquivos   " } )
      AAdd( acTxtAll, { 8, 11, " B - Selecionar arquivo  " } )
      IF lNoUserSelection
         nOpcAll := 1
      ELSE
         nOpcAll := MouseMenu( acTxtAll, nOpcAll )
      ENDIF
      IF lastkey() == K_ESC .OR. nOpcAll == 0
         EXIT
      ENDIF

      IF nOpcAll == 1
         IF ! lNoUserSelection
            IF ! MsgYesNo( "Confirma a operação" )
               LOOP
            ENDIF
         ENDIF
         CriaZip( .T. )
         ChecaAguarde( .T., "Reindexação em andamento" )
         ze_DbfPackIndex( aDbfInd )
         GravaOcorrencia( ,, "Reindexacao Geral" )
         fErase( "aguarde.txt" )
         IF ! lNoUserSelection
            MsgExclamation( "Fim do processamento!" )
         ENDIF
         EXIT
      ENDIF

      WOpen( 6, 20, Min( MaxRow()-4, 8 + Len( acTxtDbf ) ), 70, "Arquivos" )

      DO WHILE .T.

         Mensagem( "Selecione e tecle ENTER, ESC sai (se não souber, é melhor fazer para todos)" )
         nOpcFile = achoice( 8, 21, Min( MaxRow() - 5, 7 + Len( acTxtDbf ) ), 69, acTxtDbf, alMakeIndex )

         IF lastkey() == K_ESC .OR. nOpcFile == 0
            EXIT
         ENDIF

         IF MsgYesNo( "Confirme para " + acTxtDbf[ nOpcFile ] )
            WSave()
            ChecaAguarde( .T., "Reindexando arquivo " + acTxtDbf[ nOpcFile ] )
            ze_DbfPackIndex( { aDbfInd[ nOpcFile ] } )
            fErase( "aguarde.txt" )
            WRestore()
            alMakeIndex[ nOpcFile ] := .F.
         ENDIF
      ENDDO
      WClose()
   ENDDO
   WClose()

   RETURN NIL

FUNCTION ze_DbfPackIndex( aDbfInd )

   LOCAL lError := .F.
   LOCAL cColorOld  := SetColor()
   LOCAL cSetDevice := Set( _SET_DEVICE, "SCREEN" )
   LOCAL lSetDeleted := Set( _SET_DELETED, .F. )
   LOCAL alFinished   := {}
   LOCAL nCont, nCont2, cPicture, nQtRecTotal, nQtThisDbf, nQtTry
   LOCAL nQtRecOk, cTmpFile, cDbfName, mStruOk
   LOCAL acLimitNumber

   // 22/04/05
   LOCAL cTag, cKey, cFor, cFpt

   WSave( MaxRow() - 1, 0, MaxRow(), MaxCol() )
   nQtRecTotal := 0
   FOR nCont = 1 TO Len( aDbfInd )
      IF ! UseSoDbf( PathAndFile( aDbfInd[ nCont, 1 ] ) )
         lError := .T.
         EXIT
      ENDIF
      nQtThisDbf  := ( LastRec() + 1 ) // Alterado de +2, em 22/04/05
      nQtRecTotal += nQtThisDbf // Verificacao de numeros
      nQtRecTotal += nQtThisDbf // Compactacao
      nQtRecTotal += ( nQtThisDbf * Len( aDbfInd[ nCont, 3 ] ) ) // Indexacao
      CLOSE DATABASES
      AAdd( alFinished, .F. )
   NEXT
   IF ! lError
      nQtRecOk := 0
      GrafTempo( "Compactando arquivos" )
      nQtTry := 1
      DO WHILE .T.
         FOR nCont = 1 TO Len( aDbfInd )
            cTmpFile := MyTempFile( , ".\" )
            cDbfName     := PathAndFile( aDbfInd[ nCont, 1 ] )
            IF ! alFinished[ nCont ]
               IF UseSoDbf( cDbfName, .T., .F., .F. ) // s/mens.
                  fErase( cDbfName + ".cdx" )
                  SayScroll( "Verificando campos inválidos " + cDbfName )
                  mStruOk := dbStruct()
                  acLimitNumber := {}
                  FOR nCont2 = 1 TO Len( mStruOk )
                     IF mStruOk[ nCont2, 2 ] == "N"
                        IF mStruOk[ nCont2, 4 ] == 0
                           cPicture := Replicate( "9", mStruOk[ nCont2, 3 ] )
                        ELSE
                           cPicture := Replicate( "9", mStruOk[ nCont2, 3 ] - mStruOk[ nCont2, 4 ] - 1 ) + "." + Replicate( "9", mStruOk[ nCont2, 4 ] )
                        ENDIF
                        AAdd( acLimitNumber, { nCont2, Val( cPicture ) } )
                     ENDIF
                  NEXT
                  GOTO TOP
                  IF Len( acLimitNumber ) > 0
                     DO WHILE ! Eof()
                        GrafInd( nQtRecOk, nQtRecTotal )
                        FOR nCont2 = 1 TO Len( acLimitNumber )
                           IF FieldGet( acLimitNumber[ nCont2, 1 ] ) > acLimitNumber[ nCont2, 2 ] .OR. FieldGet( acLimitNumber[ nCont2, 1 ] ) < -acLimitNumber[ nCont2, 2 ] / 10
                              SayScroll( "Arquivo " + cDbfName + " campo " + FieldName( acLimitNumber[ nCont2, 1 ] ) + " inválido" )
                              SayScroll( "Arquivo " + cDbfName + " campo inválido" )
                              SayScroll( "Conteúdo atual " + Str( FieldGet( acLimitNumber[ nCont2, 1 ] ) ) + " maximo " + Str( acLimitNumber[ nCont2, 2 ] ) )
                              FieldPut( acLimitNumber[ nCont2, 1 ], 0 )
                           ENDIF
                        NEXT
                        SKIP
                     ENDDO
                  ENDIF
                  nQtRecOk += ( LastRec() + 1 )
                  SayScroll( "Regravando arquivo " + cDbfName + ", " + aDbfInd[ nCont, 2 ] )
                  nQtThisDbf := LastRec()
                  SayScroll( "Qtde inicial: " + LTrim( Str( LastRec() ) ) + " Registro(s)" )
                  COPY STRUCTURE TO ( cTmpFile )
                  USE ( cTmpFile ) ALIAS temp EXCLUSIVE
                  SET DELETED OFF
                  APPEND FROM ( cDbfName ) FOR GrafInd( nQtRecOk, nQtRecTotal ) .AND. ! Deleted()
                  SayScroll( "Qtde final: " + LTrim( Str( LastRec() ) ) + " Registro(s)" )
                  SET DELETED ON
                  IF nQtThisDbf != LastRec() // recalcula total
                     nQtRecTotal += ( LastRec() - nQtThisDbf ) // compactacao
                     nQtRecTotal += ( ( LastRec() - nQtThisDbf ) * Len( aDbfInd[ nCont, 3 ] ) )
                  ENDIF
                  nQtRecOk += ( LastRec() + 1 )
                  USE
                  fErase( cDbfName + ".dbf" )
                  IF File( cTmpFile + ".dbf" )
                     fRename( cTmpFile + ".dbf", cDbfName + ".dbf" )
                  ELSE
                     fRename( cTmpFile, cDbfName + ".dbf" )
                  ENDIF
                  fErase( cDbfName + ".fpt" )
                  IF File( cTmpFile + ".fpt" )
                     fRename( cTmpFile + ".fpt", cDbfName + ".fpt" )
                  ELSE
                     IF Substr( cTmpFile, Len( cTmpFile ) - 3, 1 ) == "."
                        cFpt := Substr( cTmpFile, 1, Len( cTmpFile ) - 3 ) + "fpt"
                        IF File( cFpt )
                           fRename( cFpt, cDbfName + ".FPT" )
                        ENDIF
                     ENDIF
                  ENDIF
                  UseSoDbf( cDbfName, .T. )
                  SayScroll( "Criando ordens de pesquisa (índices) para " + cDbfName + "..." )
                  fErase( cDbfName + ".cdx" )
                  FOR nCont2 = 1 TO Len( aDbfInd[ nCont, 3 ] )
                     cTag := aDbfInd[ nCont, 3, nCont2, 1 ]
                     cKey := aDbfInd[ nCont, 3, nCont2, 2 ]
                     SET INDEX TO // para usar while
                     GOTO TOP     // para usar while
                     IF Len( aDbfInd[ nCont, 3, nCont2 ] ) == 2
                        INDEX ON &cKey TAG ( cTag ) EVAL GrafInd( nQtRecOk, nQtRecTotal )
                     ELSE
                        cFor := aDbfInd[ nCont, 3, nCont2, 3 ]
                        INDEX ON &cKey TAG ( cTag ) FOR &( cFor ) EVAL GrafInd( nQtRecOk, nQtRecTotal )
                     ENDIF
                     nQtRecOk += ( LastRec() + 1 )
                  NEXT
                  CLOSE DATABASES
                  alFinished[ nCont ] := .T.
               ELSE
                  SayScroll( "Arquivo " + cDbfName + ", não disponível" )
                  Inkey(0.5)
               ENDIF
            ENDIF
         NEXT
         FOR nCont = 1 TO Len( alFinished )
            IF ! alFinished[ nCont ]
               nQtTry += 1
               SayScroll( "Tentando novamente pela " + Str( nQtTry, 3 ) + " vez... ESC cancela" )
               Inkey(10)
               EXIT
            ENDIF
         NEXT
         IF nCont > Len( alFinished ) .OR. LastKey() == K_ESC
            EXIT
         ENDIF
      ENDDO
   ENDIF
   WRestore()
   Set( _SET_DEVICE, cSetDevice )
   Set( _SET_DELETED, lSetDeleted )
   SetColor( cColorOld )

   RETURN NIL

FUNCTION GrafInd( nQtRecOk, nQtRecTot )

   IF ! ( RecNo() > LastRec() )
      GrafTempo( nQtRecOk + RecNo(), nQtRecTot )
   ENDIF

   RETURN .T.
