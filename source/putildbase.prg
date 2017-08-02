/*
PUTILDBASE - Imitação do dBase
1999 - José Quintas
*/

#include "inkey.ch"
#include "hbclass.ch"
#include "directry.ch"

MEMVAR DBASE_EXCLUSIVE, DBASE_ODOMETER
MEMVAR DBASE_ALL, DBASE_NEXT, DBASE_FOR, DBASE_WHILE, DBASE_RECORD
MEMVAR cEmptyValue
MEMVAR m_Name, m_Opc, m_Row, m_Item, m_IniVet, acStructure
MEMVAR m_Expr, m_Campo, lChanged, m_Posi
MEMVAR m_NomVar, m_Conte, cFileName, Ret_Val, Mode
MEMVAR Line, Col, m_Col, Opc, IniVet, Modo

PROCEDURE pUtilDbase

   LOCAL   nCont, GetList := {}, nKey, acCmdList := {}, nCmdPos := 0, cTextCmd, mCmd
   PRIVATE DBASE_EXCLUSIVE, DBASE_ODOMETER
   PRIVATE DBASE_ALL, DBASE_NEXT, DBASE_FOR, DBASE_WHILE, DBASE_RECORD

   IF MaxRow() > 100
      SetMode( 38, 132 )
      CLS
   ENDIF
   DBASE_EXCLUSIVE := .F.
   DBASE_ODOMETER  := 100

   CLOSE DATABASES // pode ter algum aberto
   MsgWarning( "Atention! If you don't know Foxpro command, don't use it!" + hb_eol() + ;
      "Depending on changes, use REINDEX option." + hb_eol() + ;
      "type QUIT when work finished" )
   FOR nCont = 1 TO MaxRow()
      SayScroll()
   NEXT
   Mensagem( "Type command and ENTER, or QUIT to exit" )
   cTextCmd := ""
   DO WHILE .T.
      cTextCmd := Pad( cTextCmd, 1000 )
      @ MaxRow() - 3, 0 GET cTextCmd PICTURE "@S" + Ltrim( Str( MaxCol() - 1 ) )
      READ
      nKey := LastKey()
      DO CASE
      CASE LastKey() == K_ESC
         LOOP
      CASE nKey = K_UP
         IF Len( acCmdList ) >= 1 .AND. nCmdPos >= 1
            cTextCmd  := acCmdList[ nCmdPos ]
            nCmdPos := iif( nCmdPos <= 1, 1, nCmdPos - 1 )
         ENDIF
         LOOP
      CASE nKey = K_DOWN
         IF nCmdPos < Len( acCmdList )
            nCmdPos += 1
            cTextCmd := acCmdList[ nCmdPos ]
         ENDIF
         LOOP
      CASE Empty( cTextCmd )
         LOOP
      ENDCASE
      SayScroll()
      cTextCmd := Trim( cTextCmd )
      Aadd( acCmdList, AllTrim( cTextCmd ) )
      nCmdPos := Len( acCmdList )
      GravaOcorrencia( ,, "(*)" + cTextCmd )
      mCmd := Lower( Trim( Left( ExtractParameter( @cTextCmd, " " ), 4 ) ) )
      DO CASE
      CASE mCmd == "!"    ;  cmdRun( cTextCmd )
      CASE mCmd == "?"    ;  cmdPrint( cTextCmd )
      CASE mCmd == "appe" ;  cmdAppend( cTextCmd )
      CASE mCmd == "brow" ;  cmdBrowse()
      CASE mCmd == "clea" ;  Scroll( 2, 0, MaxRow() - 3, MaxCol(), 0 )
      CASE mCmd == "clos" ;  CLOSE DATABASES
      CASE mCmd == "cont" ;  cmdContinue()
      CASE mCmd == "copy" ;  cmdCopy( cTextCmd )
      CASE mCmd == "crea" ;  cmdCreate( cTextCmd )
      CASE mCmd == "dele" ;  cmdDelete( cTextCmd )
      CASE mCmd == "dir"  ;  cmdDir( cTextCmd )
      CASE mCmd == "disp" ;  cmdList( cTextCmd )
      CASE mCmd == "edit" ;  cmdEdit( cTextCmd )
      CASE mCmd == "ejec" ;  EJECT
      CASE mCmd == "go"   ;  cmdGoTo( cTextCmd )
      CASE mCmd == "goto" ;  cmdGoto( cTextCmd )
      CASE Type( mCmd ) == "N" .AND. ! " " $ cTextCmd ; cmdGoTo( cTextCmd )
      CASE mCmd == "inde" ;  cmdIndex( cTextCmd )
      CASE mCmd == "list" ;  cmdList( cTextCmd )
      CASE mCmd == "loca" ;  cmdLocate( cTextCmd )
      CASE mCmd == "modi" ;  cmdModify( cTextCmd )
      CASE mCmd == "pack" ;  cmdPack()
      CASE mCmd == "quit" ;  EXIT
      CASE mCmd == "reca" ;  cmdRecall( cTextCmd )
      CASE mCmd == "rein" ;  cmdReindex()
      CASE mCmd == "repl" ;  cmdReplace( cTextCmd )
      CASE mCmd == "run"  ;  cmdRun( cTextCmd )
      CASE mCmd == "seek" ;  cmdSeek( cTextCmd )
      CASE mCmd == "sele" ;  cmdSelect( cTextCmd )
      CASE mCmd == "set"  ;  cmdSet( cTextCmd )
      CASE mCmd == "skip" ;  cmdSkip( cTextCmd )
      CASE mCmd == "stor" ;  cmdStore( cTextCmd )
      CASE mCmd == "sum"  ;  cmdSum( cTextCmd )
      CASE mCmd == "tota" ;  cmdTotal( cTextCmd )
      CASE mCmd == "unlo" ;  cmdUnLock( cTextCmd )
      CASE mCmd == "use"  ;  cmdUse( cTextCmd )
      CASE mCmd == "zap"  ;  cmdZap()
      CASE Left( cTextCmd, 1 ) == "="
         cTextCmd := Substr( cTextCmd, 2 ) + " to " + mCmd
         cmdStore( cTextCmd )
      OTHERWISE
         SayScroll( "Invalid command" )
      ENDCASE
      SayScroll()
      cTextCmd := ""
   ENDDO
   CLOSE DATABASES
   SET UNIQUE    OFF
   SET EXCLUSIVE OFF
   SET DELETED   ON
   SET CONFIRM   ON
   MsgWarning( "Remember your changes, can be needed REINDEX option" )

   RETURN

STATIC FUNCTION ExtractParameter( cTextCmd, mTipo, mLista )

   LOCAL mCont, mParametro, m_Procu, mContIni, mTemp, mContFim

   cTextCmd := AllTrim( cTextCmd )

   DO CASE
   CASE mTipo == " "  .OR. mTipo == ","
      mParametro := Substr( cTextCmd, 1, At( mTipo, cTextCmd + mTipo ) - 1 )
      cTextCmd   := Substr( cTextCmd, At( mTipo, cTextCmd + mTipo ) + 1 )
      mParametro := AllTrim( mParametro )
      cTextCmd   := AllTrim( cTextCmd )
      RETURN mParametro

   CASE mTipo == "alias"
      cTextCmd := " " + cTextCmd + " "
      mContini := At( " alias ", cTextCmd )
      IF mContini == 0
         RETURN ""
      ENDIF
      mContfim := mContini + 7
      DO WHILE Substr( cTextCmd, mContfim, 1 ) == " " .AND. mContfim < len( cTextCmd )
         mContFim := mContfim + 1
      ENDDO
      mParametro := AllTrim( ExtractParameter( Substr( cTextCmd, mContfim ), " " ) )
      cTextCmd   := Substr( cTextCmd, 1, mContini ) + Substr( cTextCmd, mContfim + Len( mParametro ) + 1 )
      cTextCmd   := AllTrim( cTextCmd )
      RETURN mParametro

   CASE mTipo == "set"
      mParametro := ""
      IF Lower( cTextCmd ) == "on"
         mParametro := .T.
      ELSEIF Lower( cTextCmd ) == "off"
         mParametro := .F.
      ELSEIF Type( cTextCmd ) == "L"
         mParametro := &cTextCmd
      ENDIF
      RETURN mParametro

   CASE mTipo == "par,"
      mParametro := 0
      mLista := {}
      DO WHILE Len( cTextCmd ) > 0
         mTemp := ""
         DO WHILE Len( cTextCmd ) > 0
            mContini := At( ",", cTextCmd + "," )
            mTemp    := mTemp + Substr( cTextCmd, 1, mContini - 1 )
            cTextCmd   := Substr( cTextCmd, mContini + 1 )
            IF Type( mTemp ) $ "NCDLM"
               EXIT
            ENDIF
            mTemp := mTemp + ","
         ENDDO
         mParametro = mParametro + 1
         Aadd( mLista, mTemp )
      ENDDO
      RETURN mParametro

   CASE mTipo == "to"
      cTextCmd     := " " + cTextCmd + " "
      mParametro := ""
      IF " to " $ Lower( cTextCmd )
         mParametro := AllTrim( Lower( substr( cTextCmd, At( " to ", Lower( cTextCmd ) ) + 4 ) ) )
         IF mParametro == "prin"
            mParametro := "print"
         ENDIF
         cTextCmd = AllTrim( substr( cTextCmd, 1, at( " to ", Lower( cTextCmd ) ) - 1 ) )
      ENDIF

   CASE mTipo == "structure" .OR. mTipo == "status" .OR. mTipo == "Exclusive" .OR. mTipo == "index" .OR. mTipo == "sdf" .OR. mTipo == "extended"
      cTextCmd     := " " + cTextCmd + " "
      mParametro := .F.
      FOR mCont = 4 TO 9
         m_procu := " " + substr( mTipo, 1, mCont ) + " "
         IF m_procu $ Lower( cTextCmd )
            mParametro = .T.
            cTextCmd = Stuff( cTextCmd, at( m_procu, Lower( cTextCmd ) ), Len( m_procu ) - 1, "" )
         ENDIF
      NEXT
      cTextCmd := Alltrim( cTextCmd )

   OTHERWISE
      CLS
      SayScroll( "Syntax error" )
      QUIT
   ENDCASE
   cTextCmd := AllTrim( cTextCmd )

   RETURN mParametro

STATIC FUNCTION cmdDelete( cTextCmd )

   LOCAL m_ContDel, m_ContReg, nKey

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF ! ExtractForWhile( @cTextCmd )
      RETURN NIL
   ENDIF
   IF Len( cTextCmd ) != 0
      SayScroll( "Invalid " + cTextCmd )
      RETURN NIL
   ENDIF
   DO CASE
   CASE DBASE_ALL
      GOTO TOP
   CASE DBASE_RECORD != 0
      GOTO DBASE_RECORD
   ENDCASE
   m_Contreg := 0
   m_Contdel := 0
   nKey    := 0
   SayScroll()
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey = Inkey()
      IF ! &( DBASE_WHILE )
         EXIT
      ENDIF
      m_Contreg := m_Contreg + 1
      IF &( DBASE_FOR )
         RecDelete()
         m_Contdel := m_Contdel + 1
         IF Mod( m_Contdel, DBASE_ODOMETER ) == 0
            @ MaxRow() - 3, 0 SAY Str( m_Contdel ) + " record(s) deleted"
         ENDIF
      ENDIF
      IF DBASE_RECORD != 0
         EXIT
      ENDIF
      SKIP
      IF m_Contreg == DBASE_NEXT
         EXIT
      ENDIF
   ENDDO
   @ MaxRow() - 3, 0 SAY Str( m_Contdel ) + " record(s) deleted"
   IF LastKey() = K_ESC
      SayScroll( "Interrupted" )
   ENDIF

   RETURN NIL

STATIC FUNCTION cmdEdit( cTextCmd )

   LOCAL nCont, GetList := {}, m_Tela, lInsert, odbStruct, m_Ini, m_Fim, m_Grava, m_QtTela, mPageRec, oElement

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Len( cTextCmd ) != 0
      IF Type( cTextCmd ) != "N"
         SayScroll( "Need to be a number" )
         RETURN NIL
      ENDIF
      IF &( cTextCmd ) < 1 .OR. &( cTextCmd ) > LastRec()
         SayScroll( "Invalid record number" )
         RETURN NIL
      ENDIF
      GOTO &( cTextCmd )
   ENDIF

   // edita registro

   lInsert  := Eof()
   mPageRec  := MaxRow()-6
   odbStruct := dbStruct()
   m_QtTela  := Int( ( Len( odbStruct ) + mPageRec - 1 ) / mPageRec)
   FOR nCont = 1 TO Len( odbStruct )
      Aadd( odbStruct[ nCont ], "" ) // picture
      Aadd( odbStruct[ nCont ], FieldGet( nCont ) ) // value
   NEXT

   DO WHILE .T.
      IF ! lInsert
         IF ! rLock()
            SayScroll( "Can't lock record" )
            RETURN NIL
         ENDIF
      ENDIF
      FOR EACH oElement IN odbStruct
         oElement[ 6 ] := FieldGet( oElement:__EnumIndex )
         IF ValType( oElement[ 6 ] ) == "C"
             oElement[ 5 ] := iif( Len( oElement[ 6 ] ) > ( MaxCol() - 25 ), "@S" + Ltrim( Str( MaxCol() - 25 ) ), "@X" )
          ENDIF
      NEXT
      m_grava = .F.
      m_tela  = 1
      DO WHILE .T.
         Cls()
         m_ini := m_tela * mPageRec - mPageRec + 1
         m_fim := iif( m_tela = m_qttela, Len( odbStruct ), m_ini + mPageRec - 1 )
         @ 2, 1 SAY iif( lInsert .OR. Eof(), "INSERT", "EDIT  " ) + " - Registro.: " + STR( RecNo() ) + "   " + iif( Deleted(), "(DELETED)", "" )
         FOR nCont = m_ini TO m_fim
             @ nCont + 3 - m_ini, 1 SAY Pad( odbstruct[ nCont, 1 ], 18, "." ) + ": " GET odbStruct[ nCont, 6 ] PICTURE ( odbStruct[ nCont, 5 ] )
         NEXT
         READ
         m_grava = iif( updated(), .T., m_grava )
         DO CASE
         CASE LastKey() == K_ESC
            EXIT
         CASE LastKey() == K_CTRL_L // .OR. ( LastKey() == K_UP .AND. Pad( ReadVar(), 10 ) == Pad( GetList[ 1, 2 ], 10 ) )
            m_tela := m_tela - 1
         CASE LastKey() = K_CTRL_W
            m_grava := .T.
            EXIT
         OTHERWISE
            m_tela := m_tela + 1
         ENDCASE
         IF m_tela < 1 .OR. m_tela > m_qttela
            EXIT
         ENDIF
      ENDDO
      IF LastKey() != K_ESC .AND. m_grava
         IF lInsert .OR. Eof()
            APPEND BLANK
            DO WHILE NetErr()
               Inkey(.2)
               APPEND BLANK
            ENDDO
         ENDIF
         FOR EACH oElement IN odbStruct
            FieldPut( oElement:__EnumIndex, oElement[ 6 ] )
         NEXT
      ENDIF
      DO CASE
      CASE LastKey() = K_ESC .OR. LastKey() = K_CTRL_W
         EXIT
      CASE LastKey() == K_CTRL_R
         IF ! Bof()
            SKIP -1
         ENDIF
         IF Bof()
            EXIT
         ENDIF
         lInsert := ! Eof()
      OTHERWISE
         IF ! Eof()
            SKIP
         ENDIF
         lInsert := lInsert .OR. Eof()
      ENDCASE
   ENDDO

   RETURN NIL

STATIC FUNCTION cmdList( cTextCmd )

   LOCAL m_Status, m_Struct, nCont

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   m_Status := ExtractParameter( @cTextCmd, "status" )
   m_Struct := ExtractParameter( @cTextCmd, "structure" )
   nCont    := 0 + iif( m_status, 1, 0 ) + iif( m_struct, 1, 0 ) + iif( Len( cTextCmd ) == 0, 0, 1 )
   IF nCont > 1
      SayScroll( "Invalid parameters" )
      RETURN NIL
   ENDIF
   DO CASE
   CASE m_status
      cmdListStatus()
   CASE m_struct
      cmdListStructure()
   OTHERWISE
      cmdListData( cTextCmd )
   ENDCASE
   IF LastKey() == K_ESC
      SayScroll( "Interrupted" )
   ENDIF

   RETURN NIL

STATIC FUNCTION cmdListStatus()

   LOCAL nCont, nCont2, nSelect := Select()

   FOR nCont = 1 TO 255
      IF Len( Trim( Alias( nCont ) ) ) != 0
         SELECT ( nCont )
         SayScroll()
         SayScroll( "Alias " + Str( nCont, 2 ) + " -> " + Alias() + iif( nCont == nSelect, "  ==> Actual Alias", "" ) )
         FOR nCont2 = 1 TO 100
            IF Len( Trim( OrdKey(nCont2 ) ) ) == 0
               EXIT
            ENDIF
            SayScroll( "   Tag " + OrdName( nCont2 ) + " -> " + OrdKey( nCont2 ) )
         NEXT
         IF Len( Trim( dbFilter() ) ) != 0
            SayScroll( "          Filter: " + dbFilter() )
         ENDIF
         IF Len( Trim( dbRelation() ) ) != 0
            SayScroll("          Relation: " + dbRelation() + " Alias: " + Alias( dbRSelect() ) )
         ENDIF
      ENDIF
   NEXT
   SELECT ( nSelect )
   SayScroll( "Current Path -> " + hb_cwd() )
   SayScroll()

   RETURN NIL

STATIC FUNCTION cmdListStructure()

   LOCAL nRow, aStructure, oElement

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   aStructure := dbStruct()
   SayScroll( "Filename........: " + Alias() )
   SayScroll( "Qt.Records......: " + LTrim( Str( LastRec() ) ) )
   SayScroll()
   SayScroll( "  #  ---Name---  Type  Lenght   Decimals" )
   SayScroll()
   nRow := 5
   FOR EACH oElement IN aStructure
      SayScroll( Str( oElement:__EnumIndex, 3 ) + "  " + pad( oElement[ 1 ], 14 ) + oElement[ 2 ] + "      " + Str( oElement[ 3 ] ) + "      " + Str( oElement[ 4 ] ) )
      nRow += 1
      IF nRow > ( MaxRow() - 8 )
         SayScroll( "Hit any to continue" )
         Inkey(0)
         IF LastKey() == K_ESC
            EXIT
         ENDIF
         nRow := 0
      ENDIF
   NEXT
   IF LastKey() != K_ESC
      SayScroll()
      SayScroll( "Total Record Size.: " + Str( RecSize() ) + " bytes")
      SayScroll()
   ENDIF

   RETURN NIL

STATIC FUNCTION cmdListData( cTextCmd )

   LOCAL nKey, m_ContReg, m_Lista, cTxt, oElement, nCont

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   cTextCmd = " " + cTextCmd + " "

   IF ! ExtractForWhile( @cTextCmd )
      RETURN NIL
   ENDIF

   // prepara lista dos dados

   cTextCmd = alltrim( cTextCmd )
   m_Lista := {}
   IF len( cTextCmd ) = 0
      FOR nCont = 1 TO FCount()
         Aadd( m_Lista, FieldName( nCont ) )
      NEXT
   ELSE
      ExtractParameter( cTextCmd, "par,", @m_lista )
   ENDIF

   // lista do indicado

   DO CASE
   CASE DBASE_ALL
      GOTO TOP
   CASE DBASE_RECORD != 0
      GOTO DBASE_RECORD
   ENDCASE

   m_Contreg = 0
   nKey   = 0
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey = Inkey()
      IF ! &( DBASE_WHILE )
         EXIT
      ENDIF
      m_Contreg = m_Contreg + 1
      cTxt := ""
      IF &( DBASE_FOR )
         cTxt := cTxt + Str( RecNo(), 6 ) + " " + iif( Deleted(), "del", "   " ) + " "
         FOR EACH oElement IN m_Lista
            IF MacroType( oElement ) $ "CLDN"
               cTxt += Transform( &oElement, "" )
            ENDIF
            IF oElement:__EnumIndex != Len( m_lista )
               cTxt += " "
            ENDIF
         NEXT
         cTxt := Trim( cTxt )
         DO WHILE Len( cTxt ) != 0
            SayScroll( Left( cTxt, MaxCol() + 1 ) )
            cTxt := Substr( cTxt, MaxCol() + 2 )
         ENDDO
      ENDIF
      IF DBASE_RECORD != 0
         EXIT
      ENDIF
      SKIP
      IF m_Contreg = DBASE_NEXT
         EXIT
      ENDIF
   ENDDO

   RETURN NIL

STATIC FUNCTION cmdModify( cTextCmd )

   LOCAL m_Tipo

   m_Tipo = Lower( ExtractParameter( @cTextCmd, " " ) )
   DO CASE
   CASE Empty( m_Tipo )
      SayScroll( "Need more parameters" )
   CASE Len( m_Tipo ) < 4
      SayScroll( "Invalid parameter" )
   CASE Lower( m_Tipo ) == substr( "structure", 1, len( m_Tipo ) )
      cmdModifyStructure( cTextCmd )
   CASE Lower( m_Tipo ) == substr( "command", 1, len( m_Tipo ) )
      cmdModifyCommand( cTextCmd )
   OTHERWISE
      SayScroll( "Invalid parameter" )
   ENDCASE

   RETURN NIL

STATIC FUNCTION cmdModifyCommand( cFileName )

   IF len( trim( cFileName) ) = 0
      SayScroll( "Need filename" )
      RETURN NIL
   ENDIF
   IF ! "." $ cFileName
      cFileName = cFileName + ".pro"
   ENDIF
   wSave()
   cmdEditAFile( cFileName )
   wRestore()
   SayScroll()

   RETURN NIL

STATIC FUNCTION cmdEditAFile( cFileName )

   LOCAL cTexto
   PRIVATE lChanged := .F., Ret_Val := 0

   IF Type( "cFileName" ) != "C"
      cFileName = "none"
   ENDIF
   cTexto := MemoRead( cFileName )
   CLS
   @ 1, 0 TO MaxRow() - 1, MaxCol()
   @ MaxRow(), 0 SAY Pad( Lower( cFileName ), 54 )
   cTexto = MemoEdit( cTexto, 2, 1, MaxRow() - 2, MaxCol() - 1, .T., { | ... | FuncMemoEdit( ... ) }, 132, 3 )
   IF ! cFileName == "none" .AND. ! Empty( cTexto ) .AND. ret_val == 23
      lChanged = .F.
      RunCmd( "copy " + cFileName + " *.bak" )
      HB_MemoWrit( cFileName, cTexto )
   ENDIF

   RETURN NIL

****
*       mfunc()
*
*       memoedit user function
****
STATIC FUNCTION FuncMemoEdit( Mode, Line, Col )

   LOCAL KeyPress, Ret_Val // , Rel_Row, Rel_Col, Line_Num, Col_Num

   ret_val = 0
   DO CASE
   CASE mode = 3
   CASE mode = 0
      * idle
      @ MaxRow(), MaxCol() - 20 SAY "line: " + Pad( Ltrim( Str( Line ) ), 4 )
      @ MaxRow(), MaxCol() - 8  SAY "col: "  + Pad( Ltrim( Str( Col ) ), 3 )
   OTHERWISE
      * keystroke exception
      keypress := LastKey()
      * save values to possibly resume edit
      //line_num := line
      //col_num  := col
      //rel_row  := row() - 2
      //rel_col  := col() - 1
      IF mode == 2
         lChanged = .T.
      ENDIF
      DO CASE
      CASE keypress = K_CTRL_W
         * ctr-w..write file
         ret_val = 23
      CASE keypress = K_ESC
         * esc..Exit
         IF ! lChanged
            * no change
            ret_val = K_ESC
         ELSE
            * changes have been made to memo
            IF MsgYesNo( "Abort?" )
               ret_val = K_ESC
            ELSE
               ret_val = 32
            ENDIF
         ENDIF
      ENDCASE
   ENDCASE

   RETURN ret_val

STATIC FUNCTION cmdCreate( cTextCmd )

   LOCAL m_From

   IF Empty( cTextCmd )
      SayScroll( "Invalid parameters" )
      RETURN NIL
   ENDIF
   IF " from " $ Lower( " " + cTextCmd + " " )
      m_Posi  = at( " from ", Lower( " " + cTextCmd + " " ) )
      m_from  = substr( cTextCmd, m_Posi + 5 )
      cTextCmd = substr( cTextCmd, 1, m_Posi - 1 )
      IF cTextCmd == ""
         SayScroll( "Need filename" )
         RETURN NIL
      ENDIF
      IF ! "." $ m_from
         m_from = m_from + ".dbf"
      ENDIF
      IF ! File( m_from )
         SayScroll( "Source filename not found" )
         RETURN NIL
      ENDIF
      IF ! "." $ cTextCmd
         cTextCmd = cTextCmd + ".dbf"
      ENDIF
      IF File( cTextCmd )
         IF ! MsgYesNo( "File exists, overwrite?" )
            RETURN NIL
         ENDIF
      ENDIF
      CREATE ( cTextCmd ) FROM ( m_from )
      RETURN NIL
   ENDIF

   IF ! "." $ cTextCmd
      cTextCmd = cTextCmd + ".dbf"
   ENDIF

   IF File( cTextCmd + ".dbf" )
      IF ! MsgYesNo( "File exist, overwrite?" )
         RETURN NIL
      ENDIF
   ENDIF

   cmdModifyStructure( cTextCmd )

   RETURN NIL

STATIC FUNCTION cmdSum( cTextCmd )

   LOCAL m_ContSum, m_ContReg, nKey, m_Lista, m_Soma, m_Vari, m_To, oElement

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   // valida parametros

   m_to     = ExtractParameter( @cTextCmd, "to" )

   IF ! ExtractForWhile( @cTextCmd )
      RETURN NIL
   ENDIF

   m_Lista := {}

   ExtractParameter( @cTextCmd, "par,", @m_lista )
   ExtractParameter( @m_to,    "par,", @m_vari  )
   m_Soma := Array( Len( m_Lista ) )
   Afill( m_Soma, 0 )

   IF Len( m_Lista ) == 0 .OR. ( Len( m_Vari ) != 0 .AND. Len( m_Vari ) != Len( m_lista ) ) .OR. len( cTextCmd ) != 0 // if anything more
      SayScroll( "Invalid parameters" )
      RETURN NIL
   ENDIF

   FOR EACH oElement IN m_Lista
      IF Type( oElement ) != "N"
         SayScroll( "Field not numeric" )
         RETURN NIL
      ENDIF
   NEXT

   // executa comando

   DO CASE
   CASE DBASE_ALL
      GOTO TOP
   CASE DBASE_RECORD != 0
      GOTO DBASE_RECORD
   ENDCASE

   m_Contreg = 0
   m_Contsum = 0
   nKey   = 0
   SayScroll()
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey = Inkey()
      IF ! &( DBASE_WHILE )
         EXIT
      ENDIF
      m_Contreg = m_Contreg + 1
      IF &( DBASE_FOR )
         FOR EACH oElement IN m_Lista
            m_soma[ oElement:__EnumIndex ] += &( oElement )
         NEXT
         m_Contsum += 1
         IF Mod( m_Contsum, DBASE_ODOMETER ) = 0
            @ MaxRow() - 3, 0 SAY Str( m_Contsum ) + " record(s) in sum"
         ENDIF
      ENDIF
      IF DBASE_RECORD != 0
         EXIT
      ENDIF
      SKIP
      IF m_Contreg = DBASE_NEXT
         EXIT
      ENDIF
   ENDDO
   @ MaxRow() - 3, 0 SAY Str( m_Contsum ) + " record(s) in sum"
   cTextCmd := ""
   FOR EACH oElement IN m_Lista
      cTextCmd += Str( m_soma[ oElement:__EnumIndex ] ) + " "
   NEXT
   SayScroll( cTextCmd )
   IF LastKey() == K_ESC
      SayScroll( "Interrupted" )
   ENDIF

   RETURN NIL

STATIC FUNCTION cmdSetRelation( cComando )

   LOCAL cRelationInto
   LOCAL lAdditive := .F., cTrecho, nSelect, oElement
   LOCAL cOrdKeyFromType, cOrdKeyToType
   LOCAL acRelationTo := {}, acRelationInto := {}

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   cTrecho := ExtractParameter( cComando, " " )
   IF Lower( cTrecho ) == substr( "additive", 1, Max( Len( cTrecho ), 4 ) )
      lAdditive = .T.
      ExtractParameter( @cComando, " " ) // elimina proximo parametro
   ENDIF
   IF ! lAdditive
      SET RELATION TO
   ENDIF
   IF Empty( cComando )
      RETURN NIL
   ENDIF
   IF ! " into " $ Lower( cComando )
      SayScroll( "Invalid parameters" )
      RETURN NIL
   ENDIF
   // retira parametros to, into
   DO WHILE Len( cComando ) != 0 .AND. Len( acRelationTo ) < 8
      Aadd( acRelationTo, substr( cComando, 1, at( " into ", Lower( cComando) ) - 1 ) )
      Aadd( acRelationInto, substr( cComando, at( " into ", Lower( cComando ) ) + 6 ) )
   ENDDO

   // valida relacoes, valida alias e executa

   IF ! lAdditive
      SET RELATION TO
   ENDIF

   FOR EACH oElement IN acRelationTo

      cRelationInto := acRelationInto[ oElement:__EnumIndex ]

      IF Type( cRelationInto ) = "N"
         IF Alias( cRelationInto ) = 0
            SayScroll( "Alias not in use " + cRelationInto )
            RETURN NIL
         ENDIF
      ELSEIF Select( cRelationInto ) = 0
         SayScroll( "Alias not in use " + cRelationInto )
         RETURN NIL
      ENDIF
      nSelect := Select()
      SELECT ( Select( cRelationInto ) )
      IF Empty( OrdKey() )
         IF oElement != "recno()"
            SELECT ( nSelect )
            SayScroll( "File not indexed to make relation" )
            RETURN NIL
         ENDIF
      ELSE
         cOrdKeyFromType := Type( OrdKey( IndexOrd() ) )
         SELECT ( nSelect )
         cOrdKeyToType := Type( oElement )
         IF cOrdKeyFromType != cOrdKeyToType
            SELECT ( nSelect )
            SayScroll( "Key type: " + cOrdKeyToType + ", in command: " + cOrdKeyFromType )
            RETURN NIL
         ENDIF
      ENDIF
      SELECT ( nSelect )
      SET RELATION ADDITIVE TO &oElement INTO &cRelationInto
   NEXT

   RETURN NIL

STATIC FUNCTION cmdStore( cTextCmd )

   IF ! " to " $ Lower( cTextCmd )
      SayScroll( "Need TO" )
      RETURN NIL
   ENDIF
   m_nomvar := ExtractParameter( @cTextCmd, "to" )
   m_Conte  := cTextCmd
   IF ! Type( m_Conte ) $ "NCLD"
      SayScroll( "Invalid content" )
      RETURN NIL
   ENDIF

   //declare m_lista[ 100 ]
   //m_qtparam = ExtractParameter( @cTextCmd, "par,", @m_lista )
   //
   //for nCont = 1 to m_qtparam
   //   m_nomevar  = m_lista[ nCont ]
      &m_nomvar = &m_Conte
   //next

   RETURN NIL

STATIC FUNCTION cmdAppend( cTextCmd )

   LOCAL mQtRec, m_Sdf
   PRIVATE cFileName

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Empty( cTextCmd )
      GOTO BOTTOM
      SKIP
      cmdEdit( "" )
      RETURN NIL
   ENDIF
   // verifica se e' APPEND BLANK
   IF Lower( cTextCmd ) == "blan" .OR. Lower( cTextCmd ) == "blank"
      APPEND BLANK
      DO WHILE NetErr()
         Inkey(.2)
         APPEND BLANK
      ENDDO
      RETURN NIL
   ENDIF
   // valida APPEND FROM
   IF Lower( ExtractParameter( @cTextCmd, " " ) ) != "from"
      SayScroll( "Invalid parameter" )
      RETURN NIL
   ENDIF
   // valida para append sdf
   m_sdf     := ExtractParameter( @cTextCmd, "sdf" )
   cFileName := ExtractParameter( @cTextCmd, " " )
   IF ! "." $ cFileName
      cFileName = cFileName + iif( m_sdf, ".txt", ".dbf" )
   ENDIF
   IF ! File( cFileName )
      SayScroll( "File not found" )
      RETURN NIL
   ENDIF
   IF select( cFileName ) != 0
      SayScroll( "File in use" )
      RETURN NIL
   ENDIF
   IF ! ExtractForWhile( @cTextCmd )
      RETURN NIL
   ENDIF
   IF len( cTextCmd ) != 0 .OR. DBASE_RECORD != 0 .OR. DBASE_NEXT != 0 .OR. DBASE_WHILE != ".T."
      SayScroll( "Invalid parameters in APPEND" )
      RETURN NIL
   ENDIF
   // executa comando
   mQtRec := LastRec()
   IF m_sdf
      APPEND FROM ( cFileName ) FOR &( DBASE_FOR ) WHILE ( Inkey() != K_ESC ) SDF
   ELSE
      APPEND FROM ( cFileName ) FOR &( DBASE_FOR ) WHILE ( Inkey() != K_ESC )
   ENDIF
   SayScroll( Ltrim( Str( LastRec() - mQtRec ) ) + " Record(s) appended" )

   RETURN NIL

STATIC FUNCTION cmdCopy( cTextCmd )

   LOCAL m_Struct, m_Extend, m_SDF, m_To

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   // valida parametros

   m_struct := ExtractParameter( @cTextCmd, "structure" )
   m_extend := ExtractParameter( @cTextCmd, "extended" )
   m_sdf    := ExtractParameter( @cTextCmd, "sdf" )
   m_To     := ExtractParameter( @cTextCmd, "to" )
   IF ! ExtractForWhile( @cTextCmd )
      RETURN NIL
   ENDIF
   IF len( cTextCmd ) != 0
      SayScroll( "Invalid parameter " + cTextCmd )
      RETURN NIL
   ENDIF
   IF len( m_to ) = 0
      SayScroll( "Need destination filename" )
      RETURN NIL
   ENDIF
   IF DBASE_NEXT == 0 .AND. DBASE_RECORD == 0
      DBASE_NEXT := LastRec()
   ENDIF

   IF ! "." $ m_to
      m_to = m_to + ".dbf"
   ENDIF

   IF File( m_to )
      IF ! MsgYesNo( "Filename already exists, overwrite?")
         SayScroll( "Cancelled" )
         RETURN NIL
      ENDIF
   ENDIF

   DO CASE
   CASE m_struct
      IF m_extend
         COPY TO ( m_to ) STRUCTURE EXTENDED
      ELSE
         COPY TO ( m_to ) STRUCTURE
      ENDIF

   CASE DBASE_RECORD != 0
      IF m_Sdf
         COPY TO ( m_To ) SDF RECORD ( DBASE_RECORD )
      ELSE
         COPY TO ( m_To ) RECORD ( DBASE_RECORD )
      ENDIF

   CASE DBASE_WHILE != ".T." .OR. "while .T." $ Lower( cTextCmd )
      IF m_Sdf
         COPY TO ( m_To ) FOR &( DBASE_FOR ) WHILE &( DBASE_WHILE ) NEXT DBASE_NEXT SDF
      ELSE
         COPY TO ( m_To ) FOR &( DBASE_FOR ) WHILE &( DBASE_WHILE ) NEXT DBASE_NEXT
      ENDIF

   CASE ! DBASE_NEXT != 0
      IF m_Sdf
         COPY TO ( m_To ) FOR &( DBASE_FOR ) NEXT DBASE_NEXT SDF
      ELSE
         COPY TO ( m_To ) FOR &( DBASE_FOR ) NEXT DBASE_NEXT
      ENDIF

   OTHERWISE
      GOTO TOP
      IF m_sdf
         COPY TO ( m_to ) FOR &( DBASE_FOR ) sdf
      ELSE
         COPY TO ( m_to ) FOR &( DBASE_FOR )
      ENDIF

   ENDCASE

   RETURN NIL

STATIC FUNCTION cmdReplace( cTextCmd )

   LOCAL nCont, m_ContRep, m_ContReg, m_Name, m_With, nKey
   PRIVATE m_Campo, m_Expr

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF ! ExtractForWhile( @cTextCmd )
      RETURN NIL
   ENDIF

   IF Len( cTextCmd ) = 0
      SayScroll( "Invalid parameters" )
      RETURN NIL
   ENDIF

   m_Name := Array(100)
   m_With := Array(100)
   afill( m_name, "" )
   nCont = 1
   DO WHILE Len( cTextCmd) > 0
      m_expr   := alltrim( substr( cTextCmd, rat( " with ", Lower( cTextCmd ) ) + 5 ) )
      cTextCmd := alltrim( substr( cTextCmd, 1, rat( " with ", Lower( cTextCmd ) ) ) )
      cTextCmd := "," + cTextCmd
      m_campo  := alltrim( substr( cTextCmd, rat( ",", Lower( cTextCmd ) ) + 1 ) )
      cTextCmd := alltrim( substr( cTextCmd, 2, rat( ",", Lower( cTextCmd ) ) - 2 ) )
      DO CASE
      CASE Type( m_expr ) $ "U,UI,UE"
         SayScroll( "Invalid content" )
         RETURN NIL

      CASE Type( m_campo ) $ "U,UI,UE"
         SayScroll( "Invalid fieldname" )
         RETURN NIL

      CASE Type( m_campo ) != Type( m_expr )
         SayScroll( "Types mismatched -> " + m_campo + " with " + m_expr)
         RETURN NIL
      ENDCASE
      m_name[ nCont ] = m_campo
      m_with[ nCont ] = m_expr
      nCont += 1
   ENDDO

   // executa comando

   DO CASE
   CASE DBASE_ALL
      GOTO TOP
   CASE DBASE_RECORD != 0
      GOTO DBASE_RECORD
   ENDCASE

   m_Contreg := 0
   m_Contrep := 0
   nKey      := 0
   SayScroll()
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey = Inkey()
      IF ! &( DBASE_WHILE )
         EXIT
      ENDIF
      m_Contreg = m_Contreg + 1
      IF &( DBASE_FOR )
         DO WHILE .T.
            IF rLock()
               EXIT
            ENDIF
            @ Row(), 0 SAY space(79)
            @ Row(), 0 SAY "Waiting lock record " + str( recno() )
         ENDDO

         FOR nCont = 1 TO 100
            IF len( m_name[ nCont ] ) = 0
               EXIT
            ENDIF
            m_campo = m_name[ nCont ]
            m_expr  = m_with[ nCont ]
            REPLACE &( m_campo ) WITH &( m_expr )
         NEXT

         m_Contrep = m_Contrep + 1
         IF Mod( m_Contrep, DBASE_ODOMETER ) = 0
            @ Row(), 0 SAY str( m_Contrep ) + " record(s) updated"
         ENDIF
      ENDIF
      IF DBASE_RECORD != 0
         EXIT
      ENDIF
      SKIP
      IF m_Contreg = DBASE_NEXT
         EXIT
      ENDIF
   ENDDO
   @ Row(), 0 SAY str( m_Contrep ) + " record(s) updated"
   IF LastKey() = K_ESC
      SayScroll( "Cancelled" )
   ENDIF

   RETURN NIL

STATIC FUNCTION cmdLocate( cTextCmd )

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF ! ExtractForWhile( @cTextCmd )
      RETURN NIL
   ENDIF

   IF len( cTextCmd ) != 0 .OR. DBASE_RECORD != 0
      SayScroll( "Invalid parameter " + cTextCmd )
      RETURN NIL
   ENDIF

   IF DBASE_ALL
      GOTO TOP
   ENDIF

   LOCATE FOR &( DBASE_FOR ) WHILE &( DBASE_WHILE ) .AND. Inkey() != K_ESC

   IF LastKey() = K_ESC
      SayScroll( "Cancelled" )
   ELSE
     IF Eof() .OR. ! &( DBASE_WHILE )
        SayScroll( "Not found" )
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION cmdModifyStructure( cTextCmd )

   LOCAL nCont, GetList := {}, m_Mudou, m_Len, m_Type, m_Dec, m_Tipos, mTempFile, m_JaExiste, m_Regs
   PRIVATE acStructure, m_Opc, m_Name, m_Row, cEmptyValue, m_IniVet, m_Col

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   // salva configuracao atual

   m_row := Row()
   m_col := Col()
   wSave()
   Cls()

   // prepara tela da estrutura

   @ 4, 20 SAY " -------------------------------------------- "
   @ 5, 20 SAY "|                                            |"
   @ 6, 20 SAY "|--------------------------------------------|"
   @ 7, 20 SAY "| Name       | Type      | Len   | Dec |"
   @ 8, 20 SAY "|--------------------------------------------|"
   cEmptyValue = "            |           |       |           "
   FOR nCont = 9 TO 19
      @ nCont, 20 SAY Chr(179) + cEmptyValue + Chr(179)
   NEXT
   @ 20,20 SAY "|--------------------------------------------|"
   @ 21,20 SAY "| < >  ESC ENTER (I)nsert (D)elete (S)ave    |"
   @ 22,20 SAY " -------------------------------------------- "

   m_tipos := "CharacterNumeric  Data     Boolean  Memo     "

   IF len( cTextCmd ) = 0
      cTextCmd   := Alias()
      m_jaexiste := .T.
   ELSE
      m_jaexiste := .F.
   ENDIF

   // mostra campos na tela

   DECLARE acStructure[ 200 ]
   afill( acStructure, "" )
   acStructure[ 1 ] := cEmptyValue
   @ 5, 20 + int( ( 38 - len( cTextCmd ) ) / 2 ) Say cTextCmd

   IF m_jaexiste
      m_regs := fCount()
      m_Name := Array( m_Regs )
      m_Type := Array( m_Regs )
      m_Len  := Array( m_Regs )
      m_Dec  := Array( m_Regs )
      afields( m_name, m_type, m_len, m_dec )
      FOR nCont = 1 TO m_regs
         acStructure[ nCont ] = " " + pad( m_name[ nCont ], 10 ) + " | " + ;
                 substr( "CharacterNumeric  Boolean  Date     Memo     ", ;
                 at( m_type[ nCont ], "CNLDM" ) * 9 - 8, 9 ) + " |  " +  ;
                 str( m_len[ nCont ], 3 ) + "  | " + ;
                 str( m_dec[ nCont ], 3 ) + " "
      NEXT
      acStructure[ m_regs + 1 ] = cEmptyValue
   ENDIF

   // permite selecao e alteração

   m_mudou = .F.
   STORE 1 to m_opc, m_inivet
   DO WHILE .T.
      achoice( 9, 21, 19, 58, acStructure, .T., { | ... | FuncModiStru( ... ) }, m_opc, m_inivet )
      DO CASE
      CASE LastKey() == K_ESC .OR. Lower( chr( LastKey() ) ) == "q"
         IF MsgYesNo( "Abort?" )
            EXIT
         ENDIF

      CASE Lower( chr( LastKey() ) ) == "d"
         m_row := Row()
         IF acStructure[ m_opc ] # cEmptyValue
            adel( acStructure, m_opc )
            scroll( m_row, 21, 19, 58, 1 )
            @ 19, 21 Say cEmptyValue
            m_mudou = .T.
         ENDIF

      CASE Lower( chr( LastKey() ) ) = "s"
         IF acStructure[ 1 ] == cEmptyValue .OR. ! m_mudou
            EXIT
         ENDIF
         IF ! MsgYesNo( "Confirm?" )
            LOOP
         ENDIF
         mTempFile := MyTempFile( "DBF" )
         CREATE ( mTempFile )
         FOR nCont = 1 TO 200
            IF acStructure[ nCont ] == cEmptyValue
               nCont := 200
            ELSE
               m_name := substr( acStructure[ nCont ], 2, 10 )
               m_type := substr( acStructure[ nCont ], 15, 1 )
               m_len  := val( substr( acStructure[ nCont ], 28, 3 ) )
               m_dec  := val( substr( acStructure[ nCont ], 35, 3 ) )
               APPEND BLANK
               REPLACE field_name WITH m_name, ;
                       field_type with m_type, ;
                       field_len  WITH m_len,  ;
                       field_dec  with m_dec
            ENDIF
         NEXT
         IF LastRec() > 0
            IF m_jaexiste
               USE
               IF File( cTextCmd + ".bak" )
                  fErase( cTextCmd + ".bak" )
               ENDIF
               fRename( cTextCmd + ".dbf", cTextCmd + ".bak" )
            ENDIF
            CREATE ( cTextCmd ) FROM ( mTempFile )
            USE ( cTextCmd )
            IF m_jaexiste
               APPEND FROM ( cTextCmd + ".bak" )
            ENDIF
            USE ( cTextCmd )
         ENDIF
         fErase( mTempFile )
         EXIT

      CASE Lower( chr( LastKey() ) ) == "i" .OR. LastKey() == K_ENTER
         m_row = ROW()
         IF Lower( chr( LastKey() ) ) == "i" .OR. ;
            acStructure[ m_opc ] = cEmptyValue
            IF m_row < 19
               scroll( m_row, 21, 19, 58, -1 )
               @ m_row, 21 Say cEmptyValue
            ENDIF
            ains( acStructure, m_opc )
            acStructure[ m_opc ] = cEmptyValue
         ENDIF
         m_name := substr( acStructure[ m_opc ], 2, 10 )
         m_type := substr( acStructure[ m_opc ], 15, 1 )
         m_len  := val( substr( acStructure[ m_opc ], 28, 3 ) )
         m_dec  := val( substr( acStructure[ m_opc ], 35, 3 ) )
         m_row  := row()
         @ m_row, 22 GET m_name PICTURE "@!"  VALID StruNameOk()
         @ m_row, 35 GET m_type PICTURE "!A"  VALID StruTypeOk( m_Type, @m_Len, @m_Dec )
         @ m_row, 48 GET m_len  PICTURE "999" VALID StruLenOk( m_Len, m_Type )
         @ m_row, 56 GET m_dec  PICTURE "99"  VALID StruDecimalsOk( m_Dec, m_Type )
         READ
         IF LastKey() # K_ESC
            acStructure[ m_opc ] = " " + m_name + " | " + substr( m_tipos, at( m_type, m_tipos ), 9 ) + " |  " + str( m_len, 3 ) + "  | " + str( m_dec, 3 ) + " "
            m_mudou := .T.
         ELSE
            adel( acStructure, m_opc )
         ENDIF
      ENDCASE
   ENDDO
   wRestore()

   RETURN NIL

// funcao de movimentacao
STATIC FUNCTION FuncModiStru( Modo, Opc, IniVet )

   m_opc    := opc
   m_inivet := inivet
   DO CASE
   CASE modo != 3
      RETURN 2
   CASE LastKey() == K_HOME
      KEYBOARD Chr( K_CTRL_PGUP )
      RETURN 2
   CASE LastKey() == K_END
      KEYBOARD Chr( K_CTRL_PGDN )
      RETURN 2
   CASE LastKey() == K_ESC .OR. LastKey() == K_ENTER
      RETURN 0
   CASE Lower( chr( LastKey() ) ) $ "qsid"
      RETURN 0
   ENDCASE

   RETURN 2

// funcao para validar nome
STATIC FUNCTION StruNameOk()

   LOCAL  nCont

   DO CASE
   CASE LastKey() == K_ESC
      RETURN .T.
   CASE Empty( m_name )
      RETURN .F.
   ENDCASE
   FOR nCont = 1 TO 200
      DO CASE
      CASE acStructure[ nCont ] = cEmptyValue
         nCont = 200
      CASE substr( acStructure[ nCont ], 2, 10 ) == m_name .AND. nCont != m_opc
         RETURN .F.
      ENDCASE
   NEXT

   RETURN .T.

// funcao para validar tipo
STATIC FUNCTION StruTypeOk( cType, nLen, nDecimais )

   LOCAL lOk := .T.

   DO CASE
   CASE cType == "C"
      @ m_Row, 35 SAY "Character"
   CASE cType == "N"
      @ m_Row, 35 Say "Numeric"
   CASE cType == "L"
      @ m_Row, 35 SAY "Boolean"
      nLen      := 1
      nDecimais := 0
   CASE cType == "D"
      @ m_Row, 35 SAY "Date"
      nLen      := 8
      nDecimais := 0
   CASE cType == "M"
      @ m_Row, 35 Say "Memo"
      nLen      := 10
      nDecimais := 0
   OTHERWISE
      lOk := .F.
   ENDCASE

   RETURN lOk

// funcao para validar tamanho
STATIC FUNCTION StruLenOk( nLen, cType )

   LOCAL lOk := ( nLen > 0 )
   DO CASE
   CASE cType == "L"
      lOk := ( nLen == 1 )
   CASE cType == "D"
      lOk := ( nLen == 8 )
   CASE cType == "M"
      lOk := ( nLen==10)
   ENDCASE

   RETURN lOk

// funcao para validar decimais
STATIC FUNCTION StruDecimalsOk( nDecimais, cType )

   DO CASE
   CASE cType $ "LDM"
      RETURN ( nDecimais == 0 )
   CASE nDecimais < 0
      RETURN .F.
   ENDCASE

   RETURN .T.

STATIC FUNCTION cmdPrint( cTextCmd )

   LOCAL m_Lista := {}, cTxt, oElement
   PRIVATE m_picture, m_item, m_picture

   IF Empty( cTextCmd )
      SayScroll()
      RETURN NIL
   ENDIF

   ExtractParameter( cTextCmd, "par,", @m_lista )

   cTxt := ""
   FOR EACH oElement IN m_Lista
      m_item = oElement
      IF ! Type( m_item ) $ "NCLDM"
         IF Right( m_item, 1 ) == ","
            m_item := Substr( m_item, 1, Len( m_item ) - 1 )
         ENDIF
         SayScroll( "Variable not found" )
         RETURN NIL
      ENDIF
      DO CASE
      CASE Type( m_item ) $ "CLDN"
         cTxt += Transform( &( m_Item ), "" ) + " "
      CASE Type( m_item ) = "M"
         cTxt += "memo" + " "
      ENDCASE
   NEXT
   SayScroll( cTxt )

   RETURN NIL

STATIC FUNCTION cmdUse( cTextCmd )

   LOCAL cDbfName, cCdxName, cAlias, lExclusive, nCont
   THREAD STATIC nTempAlias := 1

   IF Empty( cTextCmd )
      USE
      RETURN NIL
   ENDIF

   cDbfName = ExtractParameter( @cTextCmd, " " )

   IF Len( cDbfName ) == 0
      SayScroll( "Invalid filename" + cDbfName )
      RETURN NIL
   ENDIF

   IF Select( cDbfName ) != 0
      SayScroll( "File already open!" + cDbfName )
      RETURN NIL
   ENDIF

   IF ! "." $ cDbfName
      cDbfName += ".dbf"
   ENDIF

   IF ! File( cDbfName )
      SayScroll( "File not found " + cDbfName )
      RETURN NIL
   ENDIF

   // Valida uso exclusivo

   lExclusive := ExtractParameter( @cTextCmd, "Exclusive" )
   cAlias     := ExtractParameter( @cTextCmd, "alias" )

   IF ! Empty( cAlias )
      IF Len( cAlias ) < 2 .OR. Len( cAlias ) > 10 .OR. Val( cAlias ) != 0
         SayScroll( "Invalid ALIAS " + cAlias )
         RETURN NIL
      ENDIF
      FOR nCont = 1 TO Len( cAlias )
         IF ! Lower( Substr( cAlias, nCont, 1 ) ) $ "abcdefghijklmnopqrstuvwxyz_0123456789"
            SayScroll( "Invalid ALIAS " + cAlias )
            RETURN NIL
         ENDIF
      NEXT
   ENDIF

   IF Len( cAlias ) == 0
      IF Len( hb_FNameName( cDbfName ) )  > 8
         cAlias := "TMP" + StrZero( nTempAlias, 7 )
      ELSE
         cAlias := hb_FNameName( cDbfName )
      ENDIF
   ENDIF

   // Abre e confirma abertura de dbfs

   IF lExclusive
      USE ( cDbfName ) ALIAS ( cAlias ) EXCLUSIVE
      IF NetErr()
         SayScroll( "Can't open exclusive" )
         RETURN NIL
      ENDIF
   ELSE
      USE ( cDbfName ) ALIAS ( cAlias ) // SHARED
      IF NetErr()
         SayScroll( "File in use" )
         RETURN NIL
      ENDIF
   ENDIF

   nTempAlias += 1

   // Valida abertura de indice

   IF ! ExtractParameter( @cTextCmd, "index" )
      RETURN NIL
   ENDIF
   DO WHILE .T.
      cCdxName := ExtractParameter( @cTextCmd, "," )
      IF Len( cCdxName ) = 0
         EXIT
      ENDIF
      IF ! "." $ cCdxName
         cCdxName += ".cdx"
         IF ! File( cCdxName )
            SayScroll( cCdxName + " not found" )
         ELSE
            dbSetIndex( cCdxName )
         ENDIF
      ENDIF
   ENDDO

   RETURN NIL

STATIC FUNCTION cmdRecall( cTextCmd )

   LOCAL nContReg := 0, nContDel := 0, nKey := 0

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF ! ExtractForWhile( @cTextCmd )
      RETURN NIL
   ENDIF

   IF Len( cTextCmd ) != 0
      SayScroll( "Invalid parameter " + cTextCmd )
      RETURN NIL
   ENDIF

   DO CASE
   CASE DBASE_ALL
      GOTO TOP
   CASE DBASE_RECORD != 0
      GOTO ( DBASE_RECORD )
   ENDCASE

   SayScroll()
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey = Inkey()
      IF ! &( DBASE_WHILE )
         EXIT
      ENDIF
      nContreg += 1
      IF &( DBASE_FOR )
         RecLock()
         RECALL
         nContDel += 1
         IF Mod( nContDel, DBASE_ODOMETER ) = 0
            @ MaxRow() - 3, 0 SAY Str( nContDel ) + " record(s) recalled"
         ENDIF
      ENDIF
      IF DBASE_RECORD != 0
         EXIT
      ENDIF
      SKIP
      IF nContReg == DBASE_NEXT
         EXIT
      ENDIF
   ENDDO
   @ MaxRow() - 3, 0 SAY Str( nContDel ) + " record(s) recalled"
   IF LastKey() = K_ESC
      SayScroll( "Interrupted" )
   ENDIF

   RETURN NIL

STATIC FUNCTION cmdSet( cTextCmd )

   LOCAL cSet, lOn, cIndice

   cSet := Lower( Trim( ExtractParameter( @cTextCmd, " " ) ) )
   DO CASE
   CASE Len( cSet ) < 4
      SayScroll( "Min 4 letters for command" )
      RETURN NIL
   CASE cSet $ "alternate"
      IF Upper( cTextCmd ) == "ON"
         SET ALTERNATE ON
      ELSEIF Upper( cTextCmd ) == "OFF"
         SET ALTERNATE OFF
      ELSE
         IF Lower( ExtractParameter( @cTextCmd, " " ) ) != "to"
            SayScroll( "Syntax error" )
            RETURN NIL
         ENDIF
         SET ALTERNATE TO ( cTextCmd )
      ENDIF

   CASE cSet $ "century,deleted,unique,confirm,exclusive"
      IF Upper( cTextCmd ) != "ON" .AND. Upper( cTextCmd ) != "OFF"
         SayScroll( "Need to be ON or OFF" )
         RETURN NIL
      ENDIF
      lOn := iif( Upper( cTextCmd ) == "ON", .T., .F. )
      DO CASE
      CASE cSet $ "alternate"
         IF lOn
            SET ALTERNATE ON
         ELSE
            SET ALTERNATE OFF
         ENDIF
      CASE cSet $ "century"
         IF lOn
            SET CENTURY ON
         ELSE
            SET CENTURY OFF
         ENDIF
      CASE cSet $ "confirm"
         IF lOn
            SET CONFIRM ON
         ELSE
            SET CONFIRM OFF
         ENDIF
      CASE cSet $ "deleted"
         IF lOn
            SET DELETED ON
         ELSE
            SET DELETED OFF
         ENDIF
      CASE cSet $ "unique"
         IF lOn
            SET UNIQUE ON
         ELSE
            SET UNIQUE OFF
         ENDIF
      CASE cSet $ "exclusive"
         IF lOn
            SET EXCLUSIVE ON
         ELSE
            SET EXCLUSIVE OFF
         ENDIF
         DBASE_EXCLUSIVE := lOn
      ENDCASE
   CASE cSet $ "filter,history,index,order,relation"
      IF cSet $ "filter,index,order,relation" .AND. ! Used()
         SayScroll( "No file in use" )
         RETURN NIL
      ENDIF
      IF Lower( ExtractParameter( @cTextCmd, " " ) ) != "to"
         SayScroll( "Syntax error" )
         RETURN NIL
      ENDIF
      IF cSet == "relation"
         cmdSetRelation( cTextCmd )
      ELSEIF cSet == "order"
         IF Empty( cTextCmd )
            SET ORDER TO 1
            RETURN NIL
         ENDIF
         IF Type( cTextCmd ) != "N"
            SayScroll( "Order need to be number" )
            RETURN NIL
         ENDIF
         SET ORDER TO &( cTextCmd )
      ELSEIF cSet == "filter"
         IF Empty( cTextCmd )
            SET FILTER TO
            RETURN NIL
         ENDIF
         IF Type( cTextCmd ) != "L"
            SayScroll( "Filter need to be true or false" )
            RETURN NIL
         ENDIF
         SET FILTER TO &( cTextCmd )
      ELSEIF cSet == "index"
         SET INDEX TO
         IF Len( cTextCmd ) == 0
            RETURN NIL
         ENDIF
         DO WHILE .T.
            cIndice := ExtractParameter( @cTextCmd, "," )
            IF Len( cIndice ) = 0
               EXIT
            ENDIF
            IF ! "." $ cIndice
               IF ! File( cIndice + ".cdx" )
                  SayScroll( cIndice + " not found" )
               ELSE
                  dbSetIndex( cIndice )
               ENDIF
            ENDIF
         ENDDO
      ENDIF
   CASE cSet $ "printer"
      SET PRINTER TO
   OTHERWISE
      SayScroll( "Invalid configuration" )
   ENDCASE

   RETURN NIL

STATIC FUNCTION cmdDir( cTextCmd )

   LOCAL acTmpFile, nTotalSize, nLin, oElement

   IF Empty( cTextCmd )
      acTmpFile := Directory( "*.dbf" )
      nTotalSize := 0
      nLin := 0
      FOR EACH oElement IN acTmpFile
         USE ( oElement[ F_NAME ] ) ALIAS temp
         SayScroll( Pad( oElement[ F_NAME ], 15 ) + Transform( LastRec(), "999,999,999" ) + " " + ;
            Transform( oElement[ F_SIZE ], "999,999,999,999" ) + " " + Dtoc( oElement[ F_DATE ] ) + " " + oElement[ F_TIME ] )
         nTotalSize += oElement[ F_SIZE ]
         nLin += 1
         USE
         IF nLin > MaxRow() - 7
            SayScroll( "Hit any to continue" )
            IF Inkey(0) == K_ESC
               EXIT
            ENDIF
            nLin := 0
         ENDIF
      NEXT
      SayScroll( "Total " + Str( Len( acTmpFile ) ) + " file(s) " + Transform( nTotalSize, PicVal( 9 ) ) + " byte(s)" )
   ELSE
      acTmpFile := Directory( cTextCmd )
      nTotalSize := 0
      FOR EACH oElement IN acTmpFile
         SayScroll( Pad( oElement[ F_NAME ], 15 ) + Transform( oElement[ F_SIZE ], PicVal( 12 ) ) + " " + Dtoc( oElement[ F_DATE ] ) + " " + oElement[ F_TIME ] )
         nTotalSize += oElement[ F_SIZE ]
      NEXT
      SayScroll( "Total " + Str( Len( acTmpFile ) ) + " file(s) " + Transform( nTotalSize, PicVal( 12 ) ) + " byte(s)" )
   ENDIF

   RETURN NIL

STATIC FUNCTION cmdIndex( cTextCmd )

   LOCAL cKey, cFileName

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Lower( ExtractParameter( @cTextCmd, " " ) ) != "on"
      SayScroll( "Syntax error" )
      RETURN NIL
   ENDIF
   cKey := AllTrim( Substr( cTextCmd, 1, At( " to ", Lower( cTextCmd ) ) - 1 ) )
   IF ! Type( cKey ) $ "NCD"
      SayScroll( "Invalid key" )
      RETURN NIL
   ENDIF
   cFileName := AllTrim( Substr( cTextCmd, At( " to ", Lower( cTextCmd ) ) + 4 ) )
   IF Len( cFileName ) == 0
      SayScroll( "Invalid filename" )
      RETURN NIL
   ENDIF
   INDEX ON &( cKey ) TAG jpa TO ( cFileName )
   SayScroll( Str( LastRec() ) + " record(s) indexed" )

   RETURN NIL

STATIC FUNCTION cmdTotal( cTextCmd )

   LOCAL cKey, cFileName

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Lower( ExtractParameter( @cTextCmd, " " ) )  != "on"
      SayScroll( "Syntax error" )
      RETURN NIL
   ENDIF
   cKey := AllTrim( Substr( cTextCmd, 1, At( " to ", Lower( cTextCmd ) ) - 1 ) )
   IF ! Type( cKey ) $ "NCD"
      SayScroll( "Invalid key" )
      RETURN NIL
   ENDIF
   cFileName := AllTrim( Substr( cTextCmd, At( " to ", Lower( cTextCmd ) ) + 4 ) )
   IF Len( cFileName ) == 0
      SayScroll( "Invalid filename" )
      RETURN NIL
   ENDIF
   TOTAL ON &( cKey ) TO ( cFileName )
   SayScroll( Str( LastRec()) + " record(s) Total" )

   RETURN NIL

STATIC FUNCTION cmdRun( cTextCmd )

   wSave()
   RunCmd( cTextCmd )
   ?
   @ MaxRow(), 0 SAY "Hit ESC to continue"
   DO WHILE Inkey(0) != K_ESC
   ENDDO
   wRestore()

   RETURN NIL

STATIC FUNCTION cmdBrowse()

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   MsgExclamation( "Do not change in browse mode" )
   wSave()
   Mensagem( "Select and ENTER, ESC abort, to change record exit and use EDIT" )
   Browse( 2, 0, MaxRow() - 3, MaxCol() )
   wRestore()
   RecUnlock()

   RETURN NIL

STATIC FUNCTION cmdContinue()

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   CONTINUE
   IF LastKey() == K_ESC
      SayScroll( "Interrupted" )
   ELSEIF Eof()
      SayScroll( "End of file" )
   ENDIF

   RETURN NIL

STATIC FUNCTION cmdPack()

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF ! DBASE_EXCLUSIVE
      SayScroll( "Only available in exclusive mode" )
      RETURN NIL
   ENDIF
   PACK
   SayScroll( Str( LastRec() ) + " record(s) copyed" )

   RETURN NIL

STATIC FUNCTION cmdReindex()

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF ! DBASE_EXCLUSIVE
      SayScroll( "Only available in exclusive mode" )
      RETURN NIL
   ENDIF
   REINDEX
   SayScroll( Str( LastRec() ) + " record(s) reindexed" )

   RETURN NIL

STATIC FUNCTION cmdSeek( cTextCmd )

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Len( Trim( OrdKey() ) ) == 0
      SayScroll( "File not indexed" )
   ELSEIF Type( cTextCmd ) != Type( OrdKey() )
      SayScroll( "Order of file mismatch typed key" )
   ELSE
      SEEK &cTextCmd
      IF Eof()
         SayScroll( "Not found" )
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION cmdSelect( cAlias )

   IF Select( cAlias ) == 0
      SayScroll( "Alias not exist" )
   ELSE
      SELECT ( Select( cAlias ) )
   ENDIF

   RETURN NIL

STATIC FUNCTION cmdSkip( cTextCmd )

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Empty( cTextCmd )
      SKIP
   ELSEIF MacroType( cTextCmd ) != "N"
      SayScroll( "Type mismatch" )
   ELSEIF &( cTextCmd ) < 0 .AND. Bof()
      SayScroll( "Already in begining of file" )
   ELSEIF &( cTextCmd ) > 0 .AND. Eof()
      SayScroll( "Already in end of file" )
   ELSE
      SKIP &( cTextCmd )
   ENDIF

   RETURN NIL

STATIC FUNCTION cmdUnlock( cTextCmd )

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Empty( cTextCmd )
      UNLOCK
   ELSEIF Lower( cTextCmd ) == "all"
      UNLOCK ALL
   ELSE
      ? "Invalid parameter"
   ENDIF

   RETURN NIL

STATIC FUNCTION cmdZap()

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF ! DBASE_EXCLUSIVE
      SayScroll( "Only available in exclusive mode" )
      RETURN NIL
   ENDIF
   ZAP
   SayScroll( "Now file is empty" )

   RETURN NIL

STATIC FUNCTION cmdGoTo( cTextCmd )

   IF ! Used()
      SayScroll( "No file in use" )
      RETURN NIL
   ENDIF
   IF Lower( cTextCmd ) == "top"
      GOTO TOP
   ELSEIF Len( cTextCmd ) > 4 .AND. cTextCmd $ "bottom"
      GOTO BOTTOM
   ELSEIF Type( cTextCmd ) != "N"
      SayScroll( "Invalid parameter" )
   ELSEIF &( cTextCmd ) > LastRec() .OR. &( cTextCmd ) < 1
      SayScroll( "Invalid record number" )
   ELSE
      GOTO &( cTextCmd )
   ENDIF

   RETURN NIL

#define PARAM_NAME     1
#define PARAM_VALUE    2
#define PARAM_START    3
#define PARAM_END      4

STATIC FUNCTION ExtractForWhile( cTextCmd )

   LOCAL oElement, aParameters, nPos, cWord, nCont

   aParameters      := Array( 6 )
   aParameters[ 1 ] := { "for",    "", 0, 0 }
   aParameters[ 2 ] := { "while",  "", 0, 0 }
   aParameters[ 3 ] := { "next",   "", 0, 0 }
   aParameters[ 4 ] := { "record", "", 0, 0 }
   aParameters[ 5 ] := { "all",    "", 0, 0 }
   aParameters[ 6 ] := { Chr(205), "", 0, 0 } // so pra ter o fim

   cTextCmd := " " + cTextCmd + "  "

   FOR EACH oElement IN aParameters
      cWord := oElement[ PARAM_NAME ]
      IF Len( cWord ) <= 4
         nPos := At( " " + cWord + " ", Lower( cTextCmd ) )
      ELSE
         FOR nCont = Len( cWord ) TO 4 STEP -1
            cWord := Substr( cWord, 1, nCont )
            nPos  := At( " " + cWord + " ", Lower( cTextCmd ) )
            IF nPos != 0
               EXIT
            ENDIF
         NEXT
      ENDIF
      nPos := iif( nPos == 0, Len( cTextCmd ), nPos )
      oElement[ PARAM_START ] := nPos
   NEXT
   ASort( aParameters,,, { | x, y | x[ PARAM_START ] < y[ PARAM_START ] } )
   FOR nCont = 1 TO Len( aParameters ) - 1
      aParameters[ nCont, PARAM_END ] := aParameters[ nCont + 1, PARAM_START ]
   NEXT
   aParameters[ 6, PARAM_END ] := Len( cTextCmd )
   FOR EACH oElement IN aParameters
      oElement[ PARAM_VALUE ] := AllTrim( Substr( cTextCmd, oElement[ PARAM_START ] + 1, oElement[ PARAM_END ] - oElement[ PARAM_START ] ) )
      DO CASE
      CASE oElement[ PARAM_NAME ] == "for"    ; DBASE_FOR     := Substr( oElement[ PARAM_VALUE ], At( " ", oElement[ PARAM_VALUE ] ) )
      CASE oElement[ PARAM_NAME ] == "while"  ; DBASE_WHILE   := Substr( oElement[ PARAM_VALUE ], At( " ", oElement[ PARAM_VALUE ] ) )
      CASE oElement[ PARAM_NAME ] == "next"   ; DBASE_NEXT    := Substr( oElement[ PARAM_VALUE ], At( " ", oElement[ PARAM_VALUE ] ) )
      CASE oElement[ PARAM_NAME ] == "record" ; DBASE_RECORD  := Substr( oElement[ PARAM_VALUE ], At( " ", oElement[ PARAM_VALUE ] ) )
      CASE oElement[ PARAM_NAME ] == "all"    ; DBASE_ALL     := iif( Lower( oElement[ PARAM_VALUE ] ) == "all", .T., .F. )
      ENDCASE
   NEXT
   cTextCmd := AllTrim( Substr( cTextCmd, 1, aParameters[ 1, PARAM_START ] - 1 ) )
   IF Empty( DBASE_WHILE )
      DBASE_WHILE := ".T."
   ELSEIF MacroType( DBASE_WHILE ) != "L"
      SayScroll( "WHILE is not a logical expression" )
      RETURN .F.
   ENDIF
   IF Empty( DBASE_NEXT )
      DBASE_NEXT := 0
   ELSEIF MacroType( DBASE_NEXT ) != "N"
      SayScroll( "NEXT is not a numeric expression" )
      RETURN .F.
   ELSE
      DBASE_NEXT := &( DBASE_NEXT )
   ENDIF
   IF Empty( DBASE_RECORD )
      DBASE_RECORD := 0
   ELSEIF MacroType( DBASE_RECORD ) != "N"
      SayScroll( "RECORD is not a numeric expression" )
      RETURN .F.
   ELSE
      DBASE_RECORD := &( DBASE_RECORD )
   ENDIF
   IF Empty( DBASE_FOR )
      DBASE_FOR := ".T."
   ELSEIF MacroType( DBASE_FOR ) != "L"
      SayScroll( "FOR is not a logical expression" )
      RETURN .F.
   ELSE
      DBASE_ALL := .T.
   ENDIF
   IF DBASE_RECORD == 0 .AND. DBASE_NEXT == 0 .AND. DBASE_FOR == ".T." .AND. DBASE_WHILE == ".T." .AND. ! DBASE_ALL
      DBASE_RECORD := RecNo()
   ENDIF

   RETURN .T.
