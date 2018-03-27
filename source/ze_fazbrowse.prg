/*
ZE_FAZBROWSE - FUNCOES A SEREM USADAS COM DBFS
1991.04 José Quintas
Algumas funções da superlib

2018.03.20 Ajuste ref array de pesquisa
*/

#include "inkey.ch"
#include "tbrowse.ch"

MEMVAR m_Prog, cUserScope, cSetFilterOld, oNowSearch

#define SEARCH_TEXT    1
#define SEARCH_FILTER  2
#define SEARCH_ALIAS   3
#define SEARCH_TBROWSE 4

FUNCTION FazBrowse( oTBrowse, bUserFunction, cDefaultScope, nFixToCol, lCanChangeOrder, cMsgTextAdd )

   LOCAL cMsgText, nCont, cOrdFocusOld, mTexto, nKey, mRecNo, nMRow, nMCol, aHotKeys, mSFilter, mDirecao, oBrowse, lMore
   LOCAL mTxtTemp, nSetOrder, mAcao, Temp, GetList := {}, oFrm
   LOCAL nTop := 1, nLeft := 0, nBottom := MaxRow() - 3, nRight := MaxCol(), oElement

   //   LOCAL aBlocks := {}, aLastPaint
   THREAD STATIC oLastSearch := { "", "", "", {} }
   oNowSearch := { "", "", "", {} }

   hb_Default( @cDefaultScope, "" )
   hb_Default( @lCanChangeOrder, .T. )
   hb_Default( @cMsgTextAdd, "" )

   //IF AppUserLevel() == 0
   //   nBrowse := iif( nBrowse == 2, 1, nBrowse + 1 )
   //   DO CASE
   //   CASE nBrowse == 1
   //      HwguiBrowse( oTBrowse )
   //      IF Len( AppForms() ) > 0
   //         Atail( AppForms() ):GUIHide()
   //      ENDIF
   //      RETURN NIL
   //   CASE nBrowse == 2
   //      HmgeBrowse( oTBrowse )
   //IF Len( AppForms() ) > 0
   //   Atail( AppForms() ):GUIHide()
   //ENDIF
   //      RETURN NIL
   //   OTHERWISE
   //      // usa o normal
   //   ENDCASE
   ///ENDIF
   IF Deleted()
      SKIP -1
   ENDIF
   IF Eof() .OR. Bof()
      GOTO TOP
      IF Eof()
         MsgWarning( "Não há dados cadastrados!" )
         RETURN .T.
      ENDIF
   ENDIF
   IF oLastSearch[ SEARCH_ALIAS ] != Alias()
      oLastSearch[ SEARCH_TEXT ] := ""
      oLastSearch[ SEARCH_FILTER ] := ""
      oLastSearch[ SEARCH_ALIAS ]  := Alias()
   ENDIF
   oNowSearch[ SEARCH_FILTER ] := oLastSearch[ SEARCH_FILTER ]
   oNowSearch[ SEARCH_TEXT ] := oLastSearch[ SEARCH_TEXT ]
   cSetFilterOld   := ".T."
   cUserScope      := cDefaultScope
   cOrdFocusOld    := OrdSetFocus()

   IF oTBrowse == NIL
      oTBrowse := {}
      FOR nCont = 1 TO FCount()
         AAdd( oTBrowse, { FieldName( nCont ), FieldBlock( FieldName( nCont ) ) } )
      NEXT
   ENDIF
   oBrowse               := TBrowseDb( nTop + 5, nLeft, nBottom, nRight )
   oBrowse:HeadSep       := Chr(196)
   oBrowse:FootSep       := ""
   oBrowse:ColSep        := Chr(179)
   oBrowse:SkipBlock     := { | nSkip | FazBrowseSkip( nSkip ) }
   oBrowse:GoBottomBlock := { || FazBrowseBottom() }
   oBrowse:GoTopBlock    := { || FazBrowseTop() }
   oBrowse:FrameColor    := "3/1"
   FOR EACH oElement IN oTBrowse
      temp := tbColumnNew( oElement[ 1 ], oElement[ 2 ] )
      IF Len( oElement ) > 2
         temp:ColorBlock := oElement[ 3 ]
      ENDIF
      oBrowse:AddColumn( temp )
   NEXT
   oNowSearch[ SEARCH_TBROWSE ] := aClone( oTBrowse )
   oBrowse:ColorSpec := SetColorTBrowse()
   IF nFixToCol != NIL
      oBrowse:freeze := nFixToCol
   ENDIF
   IF ! Empty( OrdKey() ) .AND. ValType( &( OrdKey() ) ) == "C"
      IF FazBrowseChave() != cUserScope
         SEEK cUserScope
      ENDIF
   ENDIF
   IF Len( AppForms() ) > 0
      Atail( AppForms() ):GUIHide()
   ENDIF
   wSave()
   Cls()
   oFrm := frmGuiClass():New()
   oFrm:lNavigateOptions := .F.
   oFrm:cOptions         := "C"
   AAdd( oFrm:acMenuOptions, "<Ctrl-PgUp>Primeiro" )
   AAdd( oFrm:acMenuOptions, "<PgUp>Pág.Ant" )
   Aadd( oFrm:acMenuOptions, "<Up>Sobe" )
   AAdd( oFrm:acMenuOptions, "<Down>Desce" )
   AAdd( oFrm:acMenuOptions, "<PgDn>Pág.Seg" )
   AAdd( oFrm:acMenuOptions, "<Ctrl-PgDn>Último" )
   Aadd( oFrm:acMenuOptions, "<Alt-L>Pesq.Frente" )
   Aadd( oFrm:acMenuOptions, "<Alt-T>Pesq.Tras" )
   Aadd( oFrm:acMenuOptions, "<Alt-F>Filtro" )
   IF OrdCount() > 1 .AND. lCanChangeOrder
      Aadd( oFrm:acMenuOptions, "<F5>Ordem" )
   ENDIF
   oFrm:FormBegin()
   //@ nTop, nLeft CLEAR TO nBottom, nRight
   //@ nTop, nLeft TO nBottom, nRight
   // @ nTop + 3, nRight, nBottom - 1, nRight BOX Replicate( Chr(176), 9 )
   // @ nBottom, nLeft + 1, nBottom, nRight - 1 BOX Replicate( Chr(176), 9 )
   aHotKeys := {}
   //    { nTop + 1, nRight, nTop + 1, nRight, "", K_CTRL_PGUP }, ;
   //    { nTop + 2, nRight, nTop + 2, nRight, "", K_CTRL_PGUP }, ;
   //    { nTop + 3, nRight, nTop + 3, nRight, Chr(30), K_UP }, ;
   //    { nTop + 4, nRight, nTop + 4, nRight, Chr(30), K_UP }, ;
   //    { nBottom - 2, nRight, nBottom - 2, nRight, Chr(31), K_DOWN }, ;
   //    { nBottom - 1, nRight, nBottom - 1, nRight, Chr(31), K_DOWN }, ;
   //    { nBottom, nRight, nBottom, nRight, "", K_CTRL_PGDN }, ;
   //    { nBottom, nLeft + 1, nBottom, nLeft + 2, Chr(17) + Chr(17), K_LEFT }, ;
   //    { nBottom, nRight - 2, nBottom, nRight - 1, Chr(16) + Chr(16), K_RIGHT }, ;
   //    ;// Nesta ordem, se tiver area livre, PgUp e PgDn funciona
   //    { nTop + 5, nRight, nTop + 5, nRight, "", K_PGUP }, ;
   //    { nTop + 6, nRight, nTop + 6, nRight, "", K_PGUP }, ;
   //    { nBottom - 4,nRight, nBottom - 4, nRight, "", K_PGDN }, ;
   //    { nBottom - 3,nRight, nBottom - 3, nRight, "", K_PGDN }, ;
   //    { nBottom, nLeft + 3, nBottom, nLeft + 12, "[Localiza]", K_ALT_L}, ;
   //    { nBottom, nLeft + 13, nBottom, nLeft + 20, "[Filtro]", K_ALT_F}, ;
   //    { nBottom, nLeft + 21, nBottom, nLeft + 27, "[Ordem]", K_F5 } }
   // FOR EACH oElement IN aHotKeys
   //    @ oElement[ 1 ], oElement[ 2 ] SAY oElement[ 5 ]
   // NEXT
   IF lCanChangeOrder
      mTxtTemp := Alias() + " (Ordem" + lTrim( Str( IndexOrd() ) ) +"): " + OrdKey()
      mTxtTemp := Trim( pad( mTxtTemp, ( nRight - nLeft - 1 ) ) )
      //@ nTop, nLeft TO nTop, nRight COLOR SetColorTBrowseFrame()
      @ nTop + 4, nLeft + 1 SAY mTxtTemp
   ENDIF

   mSFilter      := ""
   cSetFilterOld := dbFilter()
   cSetFilterOld := iif( Len( Trim( cSetFilterOld ) ) == 0, ".T.", cSetFilterOld )
   lmore := .T.
   DO WHILE ! oBrowse:Stable
      oBrowse:Stabilize()
   ENDDO
   DO WHILE lmore
      cMsgText := ""
      IF Len( Trim( cUserScope ) ) != 0
         cMsgText += "Selec.: [" + cUserScope + "], "
      ENDIF
      IF Len( Trim( mSFilter ) ) != 0
         cMsgText += "Filtro: [" + mSFilter + "], "
      ENDIF
      cMsgText += "Selecione e tecle ENTER, Alt-L pesq.frente, Alt-F filtro, Alt-T pesq.trás, "
      IF OrdCount() > 1 .AND. lCanChangeOrder
         cMsgText += "<F5> ordem, "
      ENDIF
      IF Len( cMsgTextAdd ) > 0
         cMsgText += ( cMsgTextAdd + ", " )
      ENDIF
      cMsgText += "ESC sai"
      Mensagem( cMsgText )
      SET CURSOR OFF
      oBrowse:RefreshCurrent()
      nkey := 0
      DO WHILE nkey == 0 .AND. ! oBrowse:Stable
         oBrowse:Stabilize()
         nkey := Inkey()
      ENDDO
      IF nKey == 0
         oBrowse:RefreshCurrent()
         DO WHILE ! oBrowse:Stabilize()
         ENDDO
         oBrowse:ColorRect( { oBrowse:RowPos, 1, oBrowse:RowPos, oBrowse:ColCount }, { 3, 3 } ) // linha está com o cursor
         oBrowse:ColorRect( { oBrowse:RowPos, oBrowse:ColPos, oBrowse:RowPos, oBrowse:ColPos }, { 2, 2 } ) // linha/coluna está com o cursor
         nkey := Inkey(600)
         IF nKey == 0
            KEYBOARD Chr( K_ESC )
         ENDIF
      ENDIF
      IF ( mAcao := SetKey( nKey ) ) != NIL
         Eval( mAcao, ProcName(), ProcLine(), ReadVar() )
      ENDIF
      //Traduz Mouse
      nMRow := MROW()
      nMCol := MCOL()
      DO CASE
      CASE nKey == K_RBUTTONDOWN
         KEYBOARD Chr( K_ESC )
         LOOP
      CASE nKey == K_LBUTTONDOWN
         FOR EACH oElement IN aHotKeys
            IF nMRow >= oElement[ 1 ] .AND. nMRow <= oElement[ 3 ] .AND. nMCol >= oElement[ 2 ] .AND. nMCol <= oElement[ 4 ]
               nKey := oElement[ 6 ]
               EXIT
            ENDIF
         NEXT
      ENDCASE
      DO CASE
      CASE nKey > 999
         DO CASE
         CASE mBrzMove( oBrowse, nMRow, nMCol, nTop + 1, nLeft + 1, nBottom - 1, nRight - 1 ) // Move cursor
         CASE mBrzClick( oBrowse, nMRow, nMCol ) // click no tbrowse atual
            KEYBOARD Chr( K_ENTER )
            nKey := Inkey(0)
         ENDCASE
      CASE nkey == K_DOWN ;       oBrowse:Down()    ;  LOOP
      CASE nkey == K_PGDN ;       oBrowse:PageDown() ; LOOP
      CASE nkey == K_PGUP ;       oBrowse:PageUp() ;   LOOP
      CASE nkey == K_CTRL_PGDN ;  oBrowse:GoBottom() ; LOOP
      CASE nkey == K_UP ;         oBrowse:Up() ;       LOOP
      CASE nkey == K_CTRL_PGUP ;  oBrowse:GoTop() ;    LOOP
      CASE nkey == K_HOME ;       oBrowse:GoTop() ;    LOOP
      CASE nkey == K_END ;        oBrowse:GoBottom() ; LOOP
      CASE nkey == K_RIGHT ;      oBrowse:Right() ;    LOOP
      CASE nkey == K_LEFT ;       oBrowse:Left() ;     LOOP
      CASE ( nkey > 31 .AND. nkey <= 127 ) .AND. ( ! Empty( OrdKey() ) .AND. ValType( &( OrdKey() ) ) == "C" )
         IF dbSeek( cUserScope + Chr( nkey ) )
            cUserScope += Chr( nkey )
         ELSEIF dbSeek( cUserScope + Upper( Chr( nkey ) ) )
            cUserScope += Upper( Chr( nkey ) )
         ELSE
            MsgWarning( "Não Localizado texto iniciando com " + cUserScope + Chr( nkey ) + "!" )
            KEYBOARD Chr( 205 )
            Inkey(0)
         ENDIF
         dbSeek( cUserScope )
         oBrowse:RefreshAll()
         LOOP

      CASE nkey = K_BS
         cUserScope := left( cUserScope, Max( Len( cUserScope ) - 1, Len( cDefaultScope ) ) )
         IF ! Empty( OrdKey() ) .AND. ValType( &( OrdKey() ) ) == "C"
            dbSeek( cUserScope )
            oBrowse:RefreshAll()
         ENDIF
         LOOP

      CASE nKey == K_F5 .AND. OrdCount() > 1 .AND. lCanChangeOrder
         nSetOrder := IndexOrd()
         IF Len( OrdKey( nSetOrder + 1 ) ) != 0  && nenhum indice depois
            SET ORDER TO ( nSetOrder + 1 )
         ELSE
            SET ORDER TO 1
         ENDIF
         mTxtTemp := Alias() + " (Ordem" + LTrim( Str( IndexOrd() ) ) + "): " + OrdKey()
         mTxtTemp := pad( mTxtTemp, ( nRight - nLeft - 1 ) )
         @ nTop + 4, nLeft + 1 SAY mTxtTemp COLOR SetColorTitulo()
         IF OrdKey() == "C" .AND. ! Empty( OrdKey() ) .AND. ValType( &( OrdKey() ) ) == "C"
            IF ! dbSeek( cUserScope )
               oBrowse:GoTop()
               cUserScope = cDefaultScope
               MsgExclamation( "Retornando filtro a vazio!" )
            ENDIF
         ELSE
            cUserScope := cDefaultScope
            IF Eof()
               oBrowse:GoTop()
            ENDIF
         ENDIF
         oBrowse:GoTop()
         oBrowse:RefreshAll()
         LOOP

      CASE nKey == K_ALT_L .OR. nKey == K_CTRL_L .OR. nKey == K_ALT_T
         mDirecao := iif( nKey == K_ALT_L .OR. nKey == K_CTRL_L, 1, -1 )
         mTexto   := Pad( oNowSearch[ SEARCH_TEXT ], 100 )
         WSave( MaxRow() - 1, 0, MaxRow(), MaxCol() )
         Mensagem( "Digite combinação de palavras para Localização p/" + iif( mDirecao > 0, "frente", "trás" ) + ", ESC sai" )
         SET CURSOR ON
         @ MaxRow(), 0 GET mTexto PICTURE ( "@K!S" + LTrim( Str( MaxCol() - 4 ) ) )
         READ
         SET CURSOR OFF
         Mensagem()
         WRestore()
         oNowSearch[ SEARCH_TEXT ]  := AllTrim( mTexto )
         oLastSearch[ SEARCH_TEXT ] := oNowSearch[ SEARCH_TEXT ]
         IF Lastkey() != K_ESC .AND. ! Empty( oNowSearch[ SEARCH_TEXT ] )
            Mensagem( "Aguarde... Localizando combinacao de palavras... ESC interrompe" )
            mRecNo := RecNo()
            IF mDirecao < 0 .AND. ! Bof()
               SKIP -1
            ENDIF
            IF mDirecao > 0 .AND. ! Eof()
               SKIP
            ENDIF
            DO WHILE .T.
               nKey := Inkey()
               IF nKey == K_ESC
                  EXIT
               ENDIF
               GrafProc()
               IF WordInRecord( 1 )
                  EXIT
               ENDIF
               IF FazBrowseSkip( mDirecao ) != mDirecao
                  EXIT
               ENDIF
            ENDDO
            IF Eof()
               MsgWarning( "Combinação de palavras não Localizada!" )
               GOTO mRecNo
            ELSE
               oBrowse:RefreshAll()
            ENDIF
         ENDIF
         LOOP

      CASE nKey == K_ALT_F
         msFilter := Pad( oNowSearch[ SEARCH_FILTER ], 100 )
         wOpen( 5, 5, 10, MaxCol()-1, "Palavras para filtro, ESC Sai" )
         SET CURSOR ON
         @ 7, 7 GET msFilter PICTURE ( "@K!S" + lTrim( Str( MaxCol() - 4 ) ) )
         READ
         wClose()
         mSFilter := AllTrim( mSFilter )
         SET CURSOR OFF
         Mensagem()
         oNowSearch[ SEARCH_FILTER ] := msFilter
         IF Lastkey() != K_ESC
            IF Empty( mSFilter )
               SET FILTER TO &cSetFilterOld
            ELSE
               SET FILTER TO WordInRecord( 2 ) .AND. &cSetFilterOld
            ENDIF
            oBrowse:GoTop()
            oBrowse:RefreshAll()
         ENDIF
         LOOP
      ENDCASE
      SET CURSOR ON
      IF bUserFunction == NIL
         lmore := ( nkey != K_ENTER .AND. nkey != K_ESC )
         IF nKey == K_ENTER
            DO WHILE ! oBrowse:Stable // alterado 2015.12.26 00:50
               oBrowse:Stabilize()
            ENDDO
         ENDIF
      ELSE
         lmore := ( nkey != K_ESC )
         DO WHILE ! oBrowse:Stable
            oBrowse:Stabilize()
         ENDDO
         mRecNo := RecNo()
         IF ValType( bUserFunction ) == "C"
            &bUserFunction( oBrowse, nKey )
         ELSE
            Eval( bUserFunction, oBrowse, nKey )
         ENDIF
         IF FazBrowseChave() != cUserScope .AND. ! Empty( OrdKey() ) .AND. ValType( &( OrdKey() ) ) == "C"
            SEEK cUserScope
         ENDIF
         IF Eof() .OR. mRecNo != RecNo() .OR. Deleted()
            Eval( oBrowse:SkipBlock, 1 )
         ENDIF
         oBrowse:RefreshAll()
      ENDIF
   ENDDO
   SET CURSOR ON
   IF cSetFilterOld == ".T."
      SET FILTER TO
   ELSE
      //mRecno := RecNo()
      SET FILTER TO &cSetFilterOld
      SKIP 0 // alterado 26/06/09
      //oBrowse:GoTop()
      //GOTO mRecNo
   ENDIF
   * oBrowse:RefreshAll() // Retirado para verificar problemas
   IF cOrdFocusOld != OrdSetFocus()
      mRecNo := RecNo()
      OrdSetFocus( cOrdFocusOld )
      GOTO mRecNo
   ENDIF
   oFrm:FormEnd()
   WRestore()
   IF Len( AppForms() ) > 0
      Atail( AppForms() ):GUIShow()
   ENDIF

   RETURN ( nkey == K_ENTER )

STATIC FUNCTION FazBrowseSkip( nSkip )

   LOCAL nSkipped, nRecNo

   nSkipped := 0
   IF ! Eof()
      IF FazBrowseChave() != cUserScope
         GOTO LastRec() + 1
      ENDIF
      IF ( nSkip == 0 )
         SKIP 0
      ELSEIF ( nSkip > 0 .AND. FazBrowseChave() = cUserScope .AND. ! Eof() )
         DO WHILE nSkipped < nSkip
            SKIP
            IF Eof() .OR. FazBrowseChave() > cUserScope
               SKIP -1
               EXIT
            ENDIF
            nSkipped++
         ENDDO
      ELSEIF ( nSkip < 0 ) .AND. FazBrowseChave() = cUserScope
         DO WHILE  ( nSkipped > nSkip )
            nRecno := RecNo()
            SKIP -1
            IF Bof() .OR. nRecNo == RecNo() .OR. FazBrowseChave() < cUserScope
               IF FazBrowseChave() < cUserScope
                  SKIP
               ENDIF
               EXIT
            ENDIF
            nSkipped--
         ENDDO
      ENDIF
   ENDIF

   RETURN nSkipped

STATIC FUNCTION FazBrowseBottom()

   IF Len( cUserScope ) == 0
      GOTO BOTTOM
   ELSE
      SEEK cUserScope + Replicate( Chr(255), 10 ) SOFTSEEK
      SKIP -1
   ENDIF

   RETURN NIL

STATIC FUNCTION FazBrowseTop()

   IF Len( cUserScope ) == 0
      GOTO TOP
   ELSE
      SEEK cUserScope SOFTSEEK
   ENDIF

   RETURN NIL

STATIC FUNCTION FazBrowseChave()

   IF ! Empty( OrdKey() ) .AND. ValType( &( OrdKey() ) ) == "C"
      RETURN Left( &( OrdKey() ), Len( cUserScope ) )
   ENDIF

   RETURN cUserScope

FUNCTION WordInRecord( nType, lAllWords )

   LOCAL cTextSearch, lFound, acWordList, oElement, nCont

   IF nType == 1
      acWordList := hb_RegExSplit( " ", oNowSearch[ SEARCH_TEXT ] )
   ELSE
      acWordList := hb_RegExSplit( " ", oNowSearch[ SEARCH_FILTER ] )
   ENDIF
   IF Len( acWordList ) == 0
      RETURN .T.
   ENDIF

   hb_Default( @lAllWords, .T. )
   lFound    := .F.
   IF nType == 1
      FOR EACH cTextSearch IN acWordList
         FOR EACH oElement IN oNowSearch[ SEARCH_TBROWSE ]
            IF lFound := ( cTextSearch $ Upper( Transform( Eval( oElement[ 2 ] ), "" ) ) )
               EXIT
            ENDIF
         NEXT
         IF ( ! lFound .AND. lAllWords ) .OR. ( lFound .AND. ! lAllWords )
            EXIT
         ENDIF
      NEXT
   ELSE
      FOR EACH cTextSearch IN acWordList
         FOR nCont = 1 TO FCount()
            IF lFound := ( cTextSearch $ Upper( Transform( FieldGet( nCont ), "" ) ) )
               EXIT
            ENDIF
         NEXT
         IF ( ! lFound .AND. lAllWords ) .OR. ( lFound .AND. ! lAllWords )
            EXIT
         ENDIF
      NEXT
   ENDIF

   RETURN lFound

FUNCTION DbView( nTop, nLeft, nBottom, nRight, oTBrowse, bUserFunction, nFixToCol, mSkipVar, bSkipCpo, aHotKeys )

   LOCAL oBrowse, nkey, lmore, col, mRecNo
   LOCAL nMRow, nMCol, nCont, oElement

   IF oTBrowse == NIL
      oTBrowse := {}
      FOR nCont = 1 TO FCount()
         AAdd( oTBrowse, { FieldName( nCont ), FieldBlock( FieldName( nCont ) ) } )
      NEXT
   ENDIF
   oBrowse := tbrowsedb( nTop, nLeft, nBottom, nRight )
   oBrowse:HeadSep := Chr(196)
   oBrowse:FootSep := Chr(196)
   oBrowse:ColSep  := Chr(179)
   oBrowse:FrameColor := SetColorTbrowseFrame()
   IF mSkipvar != NIL .AND. bSkipcpo != NIL
      oBrowse:SkipBlock     := { | nSkip | dbViewSkip( nSkip, mSkipvar, bSkipcpo ) }
      oBrowse:GoBottomBlock := { || dbViewBottom( mSkipvar ) }
      oBrowse:GoTopBlock    := { || dbViewTop( mSkipvar ) }
   ENDIF
   FOR EACH oElement IN oTBrowse
      Col := TbColumnNew( oElement[ 1 ], oElement[ 2 ] )
      IF Len( oElement ) > 2
         col:ColorBlock := oElement[ 3 ]
      ENDIF
      oBrowse:AddColumn( col )
   NEXT
   oBrowse:ColorSpec := SetColorTBrowse()

   IF nFixToCol != NIL
      oBrowse:freeze := nFixToCol
   ENDIF
   IF aHotKeys == NIL
      aHotKeys := {}
   ELSE
      FOR EACH oElement IN aHotKeys
         @ oElement[ 1 ], oElement[ 2 ] SAY oElement[ 5 ]
      NEXT
   ENDIF
   DO WHILE ! oBrowse:Stable
      oBrowse:Stabilize()
   ENDDO
   lmore := .T.
   DO WHILE lmore
      oBrowse:RefreshCurrent()
      nkey := 0
      DO WHILE ! oBrowse:Stable // // Problemas ao acelerar dbview
         oBrowse:Stabilize()
         //   nkey := Inkey()
      ENDDO
      IF oBrowse:Stable
         oBrowse:ColorRect( { oBrowse:RowPos, 1, oBrowse:RowPos, oBrowse:ColCount }, { 3, 3 } ) // linha está com o cursor
         oBrowse:ColorRect( { oBrowse:RowPos, oBrowse:ColPos, oBrowse:RowPos, oBrowse:ColPos }, { 2, 2 } ) // linha/coluna está com cursor
         nkey := Inkey(600)
         IF nKey == 0
            KEYBOARD Chr( K_ESC )
            LOOP
         ENDIF
      ENDIF
      nMRow := MROW()
      nMCol := MCOL()
      DO CASE
      CASE SetKey( nKey ) != NIL
         Eval( SetKey( nKey ), ProcLine(), ProcName(), ReadVar() )
      CASE nKey > 999
         DO CASE
         CASE mBrzMove( oBrowse, nMRow, nMCol, nTop + 2, nLeft + 1, nBottom, nRight - 1 ) // Move cursor
         CASE mBrzClick( oBrowse, nMRow, nMCol ) // click no tbrowse atual
            KEYBOARD Chr( K_ENTER )
            Inkey(0)
            nKey := 13
         CASE nKey == K_LBUTTONDOWN
            FOR EACH oElement IN aHotKeys
               IF nMRow >= oElement[ 1 ] .AND. nMRow <= oElement[ 3 ] .AND. nMCol >= oElement[ 2 ] .AND. nMCol <= oElement[ 4 ]
                  nKey := oElement[ 6 ]
                  EXIT
               ENDIF
            NEXT
         ENDCASE
      CASE nkey == K_DOWN ;      oBrowse:Down() ;     LOOP
      CASE nkey == K_PGDN ;      oBrowse:PageDown() ; LOOP
      CASE nkey == K_PGUP ;      oBrowse:PageUp()   ; LOOP
      CASE nkey == K_CTRL_PGDN ; oBrowse:GoBottom() ; LOOP
      CASE nkey == K_UP ;        oBrowse:Up() ;       LOOP
      CASE nkey == K_CTRL_PGUP ; oBrowse:GoTop() ; oBrowse:RefreshAll() ; LOOP
      CASE nkey == K_HOME ;      oBrowse:GoTop() ;    LOOP
      CASE nkey == K_END ;       oBrowse:GoBottom() ; LOOP
      CASE nkey == K_RIGHT ;     oBrowse:Right() ;    LOOP
      CASE nkey == K_LEFT ;      oBrowse:Left() ;     LOOP
      CASE nKey == Asc( "0" );   hb_KeyPut( K_INS );  LOOP
      CASE nKey == Asc( "." );   hb_KeyPut( K_DEL );  LOOP
      CASE nKey == Asc( "7" );   hb_KeyPut( K_HOME ); LOOP
      CASE nKey == Asc( "8" );   hb_KeyPut( K_UP );   LOOP
      CASE nKey == Asc( "2" );   hb_KeyPut( K_DOWN ); LOOP
      CASE nKey == Asc( "9" );   hb_KeyPut( K_PGUP ); LOOP
      CASE nKey == Asc( "3" );   hb_KeyPut( K_PGDN ); LOOP
      ENDCASE
      IF nkey == K_ESC .OR. ( nkey == K_ENTER .AND. bUserFunction == NIL ) // ENTER só sai se não existir função definida
         lmore := .F.
      ENDIF
      IF bUserFunction # NIL
         DO WHILE ! oBrowse:Stable
            oBrowse:Stabilize()
         ENDDO
         WSave( MaxRow() - 1, 0, MaxRow(), MaxCol() )
         mRecno := RecNo()
         IF ValType( bUserFunction ) == "C"
            &bUserFunction( oBrowse, nKey )
         ELSE
            Eval( bUserFunction, oBrowse, nKey )
         ENDIF
         nKey := 0 // Testar se resolve saída indesejavel
         IF mRecno != RecNo() .OR. Deleted()
            Eval( oBrowse:SkipBlock, 1 )
         ENDIF
         oBrowse:RefreshAll()
         WRestore()
      ENDIF
   ENDDO
   //SetCursor( SC_NORMAL )

   RETURN  ( nkey == K_ENTER )

STATIC FUNCTION dbViewSkip( nSkip, cScopeValue, bScopeMacro )

   LOCAL nSkipped := 0, nRecNo // Para ADO

   IF ! Eof()
      IF Eval( bScopeMacro ) != cScopeValue
         GOTO LastRec() + 1
      ENDIF
      IF ( nSkip == 0 )
         SKIP 0
      ELSEIF ( nSkip > 0 .AND. Eval( bScopeMacro ) = cScopeValue .AND. ! Eof() )
         DO WHILE nSkipped < nSkip
            SKIP
            IF Eof() .OR. Eval( bScopeMacro ) > cScopeValue
               SKIP -1
               EXIT
            ENDIF
            nSkipped++
         ENDDO
      ELSEIF ( nSkip < 0 ) .AND. Eval( bScopeMacro ) = cScopeValue
         DO WHILE  ( nSkipped > nSkip )
            nRecNo := RecNo() // alterado aqui pra ADO
            SKIP -1
            IF Bof() .OR. nRecNo == RecNo() .OR. Eval( bScopeMacro ) < cScopeValue // alterado aqui pra ADO
               IF Eval( bScopeMacro ) < cScopeValue
                  SKIP
               ENDIF
               EXIT
            ENDIF
            nSkipped--
         ENDDO
      ENDIF
   ENDIF

   RETURN ( nSkipped )

STATIC FUNCTION dbViewBottom( cScopeValue )

   SEEK cScopeValue + Replicate( Chr(255), 10 ) SOFTSEEK
   SKIP -1

   RETURN NIL

STATIC FUNCTION dbViewTop( cScopeValue )

   SEEK cScopeValue SOFTSEEK

   RETURN NIL

   //STATIC nBrowse := 0

   /*
   Anotação ref. fazer zebrado

   //temp:ColorBlock := { || { iif( OrdKeyNo() % 2 == 0, 4, 3 ), 2 } } // aqui fica zebrado

   oBrowse:RefreshCurrent()
   //oBrowse:ColorRect( { oBrowse:RowPos, 1, oBrowse:RowPos, oBrowse:ColCount }, { Iif( OrdKeyNo() % 2 == 0, 1, 3 ), 1 } ) // linhas não posicionadas
   DO WHILE ( ! oBrowse:Stabilize() )
   ENDDO
   oBrowse:ColorRect( { oBrowse:RowPos, 1, oBrowse:RowPos, oBrowse:ColCount }, { 2, 2 } ) // linha posicionada
   nkey := Inkey(600)
   IF nKey == 0
   KEYBOARD Chr( K_ESC )
   ENDIF
   */

FUNCTION MBrzClick( oTb, nMRow, nMCol )

   LOCAL nTbCol, nTbColEnd, nTbRow, lThis

   lThis := .F.
   oTb:Invalidate()
   DO WHILE ! oTb:Stabilize()
   ENDDO
   nTbCol    := Col()
   nTbColEnd := nTbCol + oTb:colwidth( oTb:ColPos ) - 1
   nTbRow    := Row()
   IF nMCol >= nTbCol .AND. nMCol <= nTbColEnd .AND. nMRow == nTbRow
      lThis := .T.
   ENDIF

   RETURN lThis

FUNCTION MBrzMove( oTb, nMRow, nMCol, nTop, nLeft, nBottom, nRight )

   LOCAL nTbCol, nTbColEnd, nTbRow
   LOCAL lHandled := .F.

   oTb:Invalidate()
   DO WHILE !oTb:stabilize()
   ENDDO
   IF nTop == NIL .OR. nLeft == NIL .OR. nBottom == NIL .OR. nRight == NIL
      nTop    := MBRZFDATA( oTb )
      nBottom := MBRZLDATA( oTb )
      nLeft   := oTb:nLeft
      nRight  := oTb:nRight
   ENDIF
   nTbCol    := COL()
   nTbRow    := ROW()
   IF nMRow >= nTop .AND. nMRow <= nBottom .AND. nMCol >= nLeft .AND. nMCol <= nRight
      IF nMCol < nTbCol
         lHandled := .T.
         DO WHILE nMCol < nTbCol .AND. oTb:ColPos > oTb:LeftVisible - oTb:Freeze
            oTb:left()
            DO WHILE !oTb:Stabilize()
            ENDDO
            nTbCol    := COL()
         ENDDO
      ELSE
         nTbColEnd := nTbCol + oTb:ColWidth( oTb:ColPos ) - 1
         IF nMCol > nTbColEnd
            lHandled := .T.
            DO WHILE nMCol > nTbCol .AND. nMCol > nTbColend .AND. oTb:ColPos < oTb:RightVisible
               oTb:Right()
               DO WHILE ! oTb:Stabilize()
               ENDDO
               nTbCol    := Col()
               nTbColEnd := nTbCol + oTb:ColWidth( oTb:ColPos ) - 1
            ENDDO
         ENDIF
      ENDIF
      IF nMRow < nTbRow
         lHandled := .T.
         DO WHILE nTbRow > nMRow
            oTb:up()
            nTbRow--
         ENDDO
      ELSEIF nMRow > nTbRow
         lHandled := .T.
         DO WHILE nTbRow < nMRow
            oTb:down()
            nTbRow++
         ENDDO
      ENDIF
   ENDIF
   IF lHandled
      oTb:RefreshCurrent() // adicionado 2015/09/25
      DO WHILE ! oTb:stabilize()
      ENDDO
   ENDIF

   RETURN lHandled

   /*
   DETERMINE FIRST DATA ROW PHYSICAL
   */

STATIC FUNCTION MBRZFDATA( oTb )

   LOCAL nFirst := oTb:nTop, nCont, lHeadSep, nHeading, cHead

   nHeading := 0
   lHeadSep := ! Empty( oTb:Headsep )
   FOR nCont = 1 TO oTb:ColCount()
      IF ! Empty( oTb:GetColumn( nCont ):Headsep )
         lHeadSep := .T.
      ENDIF
      cHead := oTb:GetColumn( nCont ):Heading
      IF cHead != NIL
         nHeading := MAX( nHeading, mlCount( StrTran( cHead,";", hb_eol() ) ) )
      ENDIF
   NEXT
   nFirst += ( nHeading + iif( lHeadsep, 1, 0 ) )

   RETURN nFirst

   /*
   DETERMINE LAST DATA ROW PHYSICAL
   */

STATIC FUNCTION mBrzlData( oTb )

   LOCAL nLast := oTb:nbottom, nCont, lFootSep, nFooting, cFoot

   nFooting := 0
   lFootSep := ! Empty( oTb:FootSep )
   FOR nCont = 1 TO oTb:ColCount()
      IF ! Empty( oTb:GetColumn( nCont ):FootSep )
         lFootSep := .T.
      ENDIF
      cFoot := oTb:GetColumn( nCont ):Footing
      IF cFoot != NIL
         nFooting := Max( nFooting, MLCount( StrTran( cFoot, ";", hb_eol() ) ) )
      ENDIF
   NEXT
   nLast -= ( nFooting + iif( lFootsep, 1, 0 ) )

   RETURN nLast

   * CASE ISMOUSEAT( nMRow, nMCol, nBot + 2, nLeft, nBot + 2, nLeft + 2 )
   *    oTb:up()

FUNCTION IsMouseAt( nMRow, nMCol, nTop, nLeft, nBottom, nRight )

   RETURN ( nMRow >= nTop .AND. nMRow <= nBottom .AND. nMCol >= nLeft .AND. nMCol <= nRight )
