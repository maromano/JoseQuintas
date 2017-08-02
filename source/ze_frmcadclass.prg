/*
ZE_FRMCADCLASS - CLASSE PARA CADASTROS
2013.01.01.0000 - JOSE MARIA

...
2016.02.26.1300 - ::Show() salvando/restaurando Select()
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"
#include "dbstruct.ch"

CREATE CLASS frmCadastroClass INHERIT frmGuiClass

   VAR    nUltRec         INIT 0
   VAR    nNumTab         INIT 1
   VAR    xValues         INIT {}
   VAR    axKeyValue      INIT { " ", " ", " ", " ", " " } // Caso use pra GET, tamanho 1
   VAR    cDataTable      INIT ""
   VAR    cDataField      INIT ""
   VAR    cDataFilter     INIT ""
   VAR    cnMySql         INIT NIL

   METHOD MoveFirst()
   METHOD MoveLast()
   METHOD MovePrevious()
   METHOD MoveNext()
   METHOD Skip( nSkip )
   METHOD Delete()
   METHOD AutoConfigure()
   METHOD TelaDados( lEdit )
   METHOD Especifico( lExiste )
   METHOD EspecificoExiste( lExiste, lEof )
   METHOD CanUpdate()
   METHOD Execute()
   METHOD UserFunction( lProcessou )
   METHOD Show( lEdit )

   ENDCLASS

METHOD CanUpdate() CLASS frmCadastroClass

   RETURN .T.

METHOD UserFunction( lProcessou ) CLASS frmCadastroClass

   LOCAL nSelect := Select()

   DO CASE
   CASE .F.
   OTHERWISE
      lProcessou := .F.
   ENDCASE
   SELECT ( nSelect )

   RETURN lProcessou

METHOD MoveFirst() CLASS frmCadastroClass

   IF ::cnMySql == NIL
      GOTO TOP
   ELSE
      ::cnMySql:cSql := "SELECT " + ::cDataField + " FROM " + ::cDataTable + " ORDER BY " + ::cDataField + " LIMIT 1"
      ::cnMySql:Execute()
      IF ! ::cnMySql:Eof()
         ::axKeyValue[ 1 ] := ::cnMySql:Value( ::cDataField )
      ENDIF
      ::cnMySql:CloseRecordset()
   ENDIF

   RETURN NIL

METHOD MoveLast() CLASS frmCadastroClass

   IF ::cnMySql == NIL
      GOTO BOTTOM
   ELSE
      ::cnMySql:cSql := "SELECT " + ::cDataField + " FROM " + ::cDataTable + " ORDER BY " + ::cDataField + " DESC LIMIT 1"
      ::cnMySql:Execute()
      IF ! ::cnMySql:Eof()
         ::axKeyValue[ 1 ] := ::cnMySql:Value( ::cDataField )
      ENDIF
      ::cnMySql:CloseRecordset()
   ENDIF

   RETURN NIL

METHOD Skip( nSkip ) CLASS frmCadastroClass

   LOCAL nSkipped := 0

   DO CASE
   CASE nSkip == 0
      SKIP 0
   CASE nSkip > 0 .AND. ! Eof()
      DO WHILE nSkipped < nSkip .AND. ! Eof()
         SKIP
         IF Eof()
            GOTO BOTTOM
            EXIT
         ENDIF
         nSkipped++
      ENDDO
   CASE nSkip < 0
      DO WHILE nSkipped > nSkip .AND. ! Bof()
         SKIP -1
         IF Bof()
            GOTO TOP
            EXIT
         ENDIF
         nSkipped--
      ENDDO
   ENDCASE

   RETURN nSkipped

METHOD MovePrevious() CLASS frmCadastroClass

   IF ::cnMySql == NIL
      IF ::Skip( -1 ) != -1
         MsgExclamation( "Não tem registro anterior" )
         ::MoveFirst()
      ENDIF
   ELSE
      ::cnMySql:cSql := "SELECT " + ::cDataField + " FROM " + ::cDataTable + " WHERE " + ::cDataField + " < " + ValueSQL( ::axKeyValue[ 1 ] ) + ;
      " ORDER BY " + ::cDataField + " DESC LIMIT 1"
      ::cnMySql:Execute()
      IF ::cnMySql:Eof()
         MsgExclamation( "Não tem registro anterior" )
      ELSE
         ::axKeyValue[ 1 ] := ::cnMySql:Value( ::cDataField )
      ENDIF
      ::cnMySql:CloseRecordset()
   ENDIF

   RETURN NIL

METHOD MoveNext() CLASS frmCadastroClass

   IF ::cnMySql == NIL
      IF ::Skip( 1 ) != 1
         MsgExclamation( "Não tem registro seguinte" )
         ::MoveLast()
      ENDIF
   ELSE
      ::cnMySql:cSql := "SELECT " + ::cDataField + " FROM " + ::cDataTable + " WHERE " + ::cDataField + " > " + ;
         ValueSQL( ::axKeyValue[ 1 ] ) + " ORDER BY " + ::cDataField + " LIMIT 1"
      ::cnMySql:Execute()
      IF ::cnMySql:Eof()
         MsgExclamation( "Não tem registro seguinte" )
      ELSE
         ::axKeyValue[ 1 ] := ::cnMySql:Value( ::cDataField )
      ENDIF
      ::cnMySql:CloseRecordset()
   ENDIF

   RETURN NIL

METHOD Delete() CLASS frmCadastroClass

   IF ! MsgYesNo( "Exclui cadastro?" )
      RETURN NIL
   ENDIF
   IF ::cnMySql == NIL
      RecDelete()
      IF ::Skip( 1 ) != 1
         ::MoveLast()
      ENDIF
   ELSE
      ::cnMySql:cSql := "DELETE FROM " + ::cDataTable + " WHERE " + ::cDataField + "=" + ValueSQL( ::axKeyValue[ 1 ] )
      ::cnMySql:ExecuteCmd()
   ENDIF

   RETURN NIL

METHOD AutoConfigure()

   LOCAL oField, nRowIni, oStru, nRow, nCol, nTab, xPicture

   IF Len( ::xValues ) == 0
      oStru   := dbStruct()
      nRowIni := 7
      nRow    := nRowIni
      nCol    := 1
      nTab    := 1
      FOR EACH oField IN oStru
         IF oField[ DBS_TYPE ] == "N"
            IF oField[ DBS_DEC ] == 0
               xPicture := Replicate( "9", oFIeld[ DBS_LEN ] )
            ELSE
               xPicture := Replicate( "9", oField[ DBS_LEN ] - oField[ DBS_DEC ] ) + "." + Replicate( "9", oField[ DBS_DEC ] )
            ENDIF
         ELSE
            xPicture := NIL
         ENDIF
            nRow += 1
            IF nRow > MaxRow() - 3
               nTab += 1
               nRow := nRowIni
               AAdd( ::acTabName, Str( nTab,2 ) )
            ENDIF
         AAdd( ::xValues, { oField[ DBS_NAME ], FieldGet( oField:__EnumIndex ), xPicture, nTab, nRow, nCol } )
      NEXT
   ENDIF

   RETURN NIL

METHOD Especifico( lExiste ) CLASS frmCadastroClass

   LOCAL GetList := {}
   LOCAL mChave := FieldGet( 1 )

   IF ::cOpc == "I"
      mChave = Pad( "*NOVO*", Len( mChave ) )
   ENDIF
   @ Row() + 1, 20 GET mChave PICTURE "@K 999999" VALID NovoMaiorZero( @mChave )
   Mensagem( "Digite código para cadastro, F9 pesquisa, ESC volta" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. ( Val( mChave ) == 0 .AND. ! Trim( mChave ) == "*NOVO*" )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK mChave
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { mChave }

   RETURN .T.

METHOD EspecificoExiste( lExiste, lEof ) CLASS frmCadastroClass

   IF lExiste .AND. lEof
      MsgWarning( "Cadastro não encontrado" )
      RETURN .F.
   ENDIF
   IF ! lExiste .AND. ! lEof
      MsgWarning( "Cadastro já existe" )
      RETURN .F.
   ENDIF

   RETURN .T.

METHOD TelaDados( lEdit ) CLASS frmCadastroClass

   LOCAL oField, GetList := {}

   hb_Default( @lEdit, .F. )
   FOR EACH oField IN ::xValues
      oField[ 2 ] := FieldGet( oField:__EnumIndex )
   NEXT

   IF lEdit
      ::nNumTab := 1
   ENDIF

   DO WHILE .T.
      ::ShowTabs() // Limpa tela e posiciona linha
      FOR EACH oField IN ::xValues
         IF oField[ 4 ] == ::nNumTab
            @ oField[ 5 ], oField[ 6 ] ;
               SAY Upper( Substr( oField[ 1 ], 1, 1 ) ) + Pad( Lower( Substr( oField[ 1 ], 2 ) ), 10, "." ) + ":" ;
               GET oField[ 2 ] PICTURE oField[ 3 ]
         ENDIF
      NEXT
      // SetPaintGetList( GetList )
      IF lEdit
         Mensagem( "Digite campos, ESC Sai" )
         READ
         Mensagem()
      ELSE
         CLEAR GETS
      ENDIF
      IF LastKey() == K_ESC .OR. ! lEdit
         EXIT
      ELSEIF LastKey() == K_UP
         ::nNumTab := iif( ::nNumTab == 1, 1, ::nNumTab - 1 )
      ELSE
         ::nNumTab += 1
         IF ::nNumTab > Atail( ::xValues )[ 4 ]
            EXIT
         ENDIF
      ENDIF
   ENDDO
   IF ! lEdit
      RETURN NIL
   ENDIF
   ::nNumTab := 1
   IF LastKey() == K_ESC
      RETURN NIL
   ENDIF
   IF ::cOpc == "I"
      RecAppend()
   ENDIF
   RecLock()
   FOR EACH oField IN ::xValues
      FieldPut( oField:__EnumIndex, oField[ 2 ] )
   NEXT
   RecUnlock()

   RETURN NIL

METHOD Execute() CLASS frmCadastroClass

   LOCAL lExiste, nSelect := Select(), nRecNo, oRecValues

   ::FormBegin()
   ::MoveLast()
   ::cOpc := "C"
   DO WHILE .T.
      SELECT ( nSelect ) // Precaucao
      ::RowIni()
      ::TelaDados()
      SELECT ( nSelect ) // Precaucao
      ::OptionSelect()
      ::nUltRec := RecNo()
      IF Substr( ::cOpc, 1, 1 ) == "T" .AND. Val( Substr( ::cOpc, 2 ) ) != 0
         // Pra posicionar tela e ajustar tabs
         ::nNumTab := Val( Substr( ::cOpc, 2 ) )
         ::ShowTabs()
      ENDIF
      IF LastKey() == K_ESC .OR. ::cOpc == Chr( K_ESC )
         EXIT
//      ELSEIF ::cOpc == "Y" // não lembro porque disto
//         LOOP
      ENDIF
      DO CASE
      CASE ::UserFunction( .T. )
         LOOP
      CASE Substr( ::cOpc, 1, 1 ) == "T" .AND. Val( Substr( ::cOpc, 2 ) ) != 0
         LOOP
      CASE ::cOpc == "P"
         ::MoveFirst()
         LOOP
      CASE ::cOpc == "U"
         ::MoveLast()
         LOOP
      CASE ::cOpc == "+"
         ::MoveNext()
         LOOP
      CASE ::cOpc == "-"
         ::MovePrevious()
         LOOP
      ENDCASE
      SELECT ( nSelect ) // Precaucao
      lExiste := ( ::cOpc !="I" )
      nRecNo := RecNo()
      IF ! Empty( IndexKey(0) )
         SEEK "NIL"
      ENDIF
      ::nNumTab := 1
      ::RowIni()
      ::TelaDados()
      SELECT ( nSelect ) // Precaucao
      IF ! Empty( Alias() ) // somente se usar DBF
         GOTO ( nRecNo )
      ENDIF
      ::RowIni()
      IF ! ::Especifico( lExiste )
         IF ! Empty( Alias() )
            IF Eof()
               GOTO ::nUltRec
            ENDIF
            LOOP
         ENDIF
      ENDIF
      SELECT ( nSelect ) // Precaucao
      ::RowIni()
      ::TelaDados()
      SELECT ( nSelect ) // Precaucao
      IF ::cOpc $ "EA"
         IF ! ::CanUpdate()
            LOOP
         ENDIF
      ENDIF
      IF ::cOpc == "E"
         ::Delete()
         LOOP
      ENDIF
      IF ::cOpc $ "IA"
         //IF ::cOpc == "A"
            //IF ! ::CanUpdate()
               //LOOP
            //ENDIF
         //ENDIF
         oRecValues := RecValuesClass():New()
         ::nNumTab := 1 // pra facilitar
         ::RowIni()
         ::TelaDados( .T. )
         SELECT ( nSelect ) // Precaucao
         IF ::nNumTab > Len( ::acTabName ) // pra facilitar
            ::nNumTab := 1
         ENDIF
         IF ::cOpc == "A"
            oRecValues:WriteLog()
         ENDIF
      ENDIF
   ENDDO
   ::FormEnd()

   RETURN NIL

METHOD Show( lEdit )

   LOCAL nSelect, oRecValues

   hb_Default( @lEdit, .F. )
   nSelect    := Select()

   ::cOpc     := iif( lEdit, "A", "C" )
   oRecValues := RecValuesClass():New()
   ::nNumTab  := 1 // pra facilitar
   ::RowIni()
   ::TelaDados( lEdit )
   ::nNumTab := 1
   IF ::cOpc == "A"
      oRecValues:WriteLog()
   ENDIF
   Select ( nSelect )

   RETURN NIL

// Alterado pra usar com MySQL a partir de DBF

CREATE CLASS RecValuesClass

   VAR  aValues

   METHOD WriteLog( xTable, xKey )
   METHOD Init()

   ENDCLASS

METHOD Init() CLASS RecValuesClass

   LOCAL nCont

   ::aValues := {}
   FOR nCont = 1 TO FCount()
      Aadd( ::aValues, FieldGet( nCont ) )
   NEXT

   RETURN NIL

METHOD WriteLog( xTable, xKey ) CLASS RecValuesClass

   LOCAL cAlias, cCodigo, nCont, cTexto

   IF ! xTable == NIL .AND. ! xKey == NIL
      FOR nCont = 1 TO FCount()
         cTexto := ""
         IF ::aValues[ nCont ] != FieldGet( nCont ) .AND. ! "INFINC" $ FieldName( nCont ) .AND. ! "INFALT" $ FieldName( nCont )
            cTexto += FieldName( nCont ) + " DE " + Trim( Transform( ::aValues[ nCont ], "" ) )
            cTexto += " PARA " + Trim( Transform( FieldGet( nCont ), "" ) )
            GravaOcorrencia( Upper( xTable ), xKey, cTexto )
         ENDIF
      NEXT
      RETURN NIL
   ENDIF

   cAlias := Lower( Alias() )
   DO CASE
   CASE cAlias == "jpcadas"    ; cCodigo := StrZero( Val( jpcadas->cdCodigo ), 9 )
   CASE cAlias == "jpestoq"    ; cCodigo := StrZero( Val( jpestoq->esNumLan ), 9 )
   CASE cAlias == "jpfinan"    ; cCodigo := StrZero( Val( jpfinan->fiNumLan ), 9 )
   CASE cAlias == "jpitem"     ; cCodigo := StrZero( Val( jpitem->ieItem ), 9 )
   CASE cAlias == "jppedi"     ; cCodigo := StrZero( Val( jppedi->pdPedido ), 9 )
   CASE cAlias == "jptransa"   ; cCodigo := StrZero( Val( jptransa->trTransa ), 9 )
   CASE cAlias == "jpuf"       ; cCodigo := jpuf->ufUf
   OTHERWISE
      cCodigo := ""
   ENDCASE
   IF Empty( cCodigo )
      RETURN NIL
   ENDIF
   FOR nCont = 1 TO FCount()
      cTexto := ""
      IF ::aValues[ nCont ] != FieldGet( nCont ) .AND. ! "INFINC" $ FieldName( nCont ) .AND. ! "INFALT" $ FieldName( nCont )
         cTexto += FieldName( nCont ) + " DE " + Trim( Transform( ::aValues[ nCont ], "" ) )
         DO CASE
         CASE FieldName( nCont ) == "UFTRIUF"    ; cTexto += Logjptabel( AUX_TRIUF,  ::aValues[ nCont ], FieldGet( nCont ) )
         CASE FieldName( nCont ) == "CDGRUPO"    ; cTexto += Logjptabel( AUX_CLIGRU, ::aValues[ nCont ], FieldGet( nCont ) )
         CASE FieldName( nCont ) == "CDPORTADOR" ; cTexto += Logjptabel( AUX_FINPOR, ::aValues[ nCont ], FieldGet( nCont ) )
         CASE FieldName( nCont ) == "CDTRICAD"   ; cTexto += Logjptabel( AUX_TRICAD, ::aValues[ nCont ], FieldGet( nCont ) )
         CASE FieldName( nCont ) == "FIPORTADOR" ; cTexto += Logjptabel( AUX_FINPOR, ::aValues[ nCont ], FieldGet( nCont ) )
         CASE FieldName( nCont ) == "FIOPERACAO" ; cTexto += Logjptabel( AUX_FINOPE, ::aValues[ nCont ], FieldGet( nCont ) )
         CASE FieldName( nCont ) == "FICCUSTO"   ; cTexto += Logjptabel( AUX_CCUSTO, ::aValues[ nCont ], FieldGet( nCont ) )
         CASE FieldName( nCont ) == "IEPRODEP"   ; cTexto += Logjptabel( AUX_PRODEP, ::aValues[ nCont ], FieldGet( nCont ) )
         CASE FieldName( nCont ) == "IEPROSEC"   ; cTexto += Logjptabel( AUX_PROSEC, ::aValues[ nCont ], FieldGet( nCont ) )
         CASE FieldName( nCont ) == "IEPROGRU"   ; cTexto += Logjptabel( AUX_PROGRU, ::aValues[ nCont ], FieldGet( nCont ) )
         CASE FieldName( nCont ) == "IEPROUNI"   ; cTexto += Logjptabel( AUX_PROUNI, ::aValues[ nCont ], FieldGet( nCont ) )
         CASE FieldName( nCont ) == "IETRIPRO"   ; cTexto += Logjptabel( AUX_TRIPRO, ::aValues[ nCont ], FieldGet( nCont ) )
         OTHERWISE                               ; cTexto += " PARA " + Trim( Transform( FieldGet( nCont ), "" ) )
         ENDCASE
      ENDIF
      IF ! Empty( cTexto )
         GravaOcorrencia( Upper( Alias() ), cCodigo , cTexto )
      ENDIF
   NEXT

   RETURN NIL

STATIC FUNCTION LogJptabel( cTabela, cCampoAnt, cCampoAtual )

   LOCAL cTexto := ""

   Encontra( cTabela + cCampoAnt, "jptabel", "numlan" )
   cTexto += " (" + Trim( jptabel->axDescri ) + ")"
   Encontra( cTabela + cCampoAtual, "jptabel", "numlan" )
   cTexto += " PARA " + cCampoAtual + " (" + Trim( jptabel->axDescri ) + ")"

   RETURN cTexto

FUNCTION NovoMaiorZero( cCodigo )

   IF Trim( cCodigo ) == "*NOVO*"
      RETURN .T.
   ENDIF
   cCodigo := StrZero( Val( cCodigo ), Len( cCodigo ) )

   RETURN Val( cCodigo ) > 0
