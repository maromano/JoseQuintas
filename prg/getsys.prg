/*
GETSYS                                                         *
Modified  José Quintas

Standard Clipper 5.2 GET/READ Subsystem
Copyright (c) 1991-1993, Computer Associates International, Inc.
All rights reserved.

This version adds the following PUBLIC FUNCTIONs:

ReadKill( [<lKill>] )       --> lKill
ReadUpdated( [<lUpdated>] ) --> lUpdated
ReadFormat( [<bFormat>] )   --> bFormat | NIL

NOTE: compile WITH /m /n /w

*/

#include "inkey.ch"
#include "getEXIT.ch"
#include "set.ch"
#define JPA_IDLE 600

/***
*  Nation Message Constants
*  These constants are used WITH the NationMsg(<msg>) FUNCTION.
*  The <msg> parameter can range from 1-12 and RETURNs the national
*  version of the system message.
*/
#define _GET_INSERT_ON   7     // "Ins"
#define _GET_INSERT_OFF  8     // "   "
#define _GET_INVD_DATE   9     // "Invalid Date"
#define _GET_RANGE_FROM  10    // "Range: "
#define _GET_RANGE_TO    11    // " - "

#define K_UNDO          K_CTRL_U

// State variables for active READ
THREAD STATIC sbFormat
THREAD STATIC slUpdated := .F.
THREAD STATIC slKillRead
THREAD STATIC slBumpTop
THREAD STATIC slBumpBot
THREAD STATIC snLastEXITState
THREAD STATIC snLastPos
THREAD STATIC soActiveGet
THREAD STATIC scReadProcName
THREAD STATIC snReadProcLine

// Format of array used to preserve state variables
#define GSV_KILLREAD       1
#define GSV_BUMPTOP        2
#define GSV_BUMPBOT        3
#define GSV_LASTEXIT       4
#define GSV_LASTPOS        5
#define GSV_ACTIVEGET      6
#define GSV_READVAR        7
#define GSV_READPROCNAME   8
#define GSV_READPROCLINE   9

#define GSV_COUNT          9

/***
*  ReadModal()
*  Standard modal READ on an array of GETs
*/

FUNCTION ReadModal( GetList, nPos, lIsMouse )

   LOCAL oGet
   LOCAL aSavGetSysVars
   LOCAL aVarGet, oElement // alteração JPA

   nPos := iif( nPos == NIL, 0, nPos ) // by JPA, ref /z no 2000

   IF ( VALTYPE( sbFormat ) == "B" )
      EVAL( sbFormat )
   ENDIF

   IF ( EMPTY( GetList ) )

      // S'87 compatibility
      SETPOS( MAXROW() - 1, 0 )
      RETURN (.F.)                  // NOTE

   ENDIF

   // Preserve state variables
   aSavGetSysVars := ClearGetSysVars()

   // Set these for use in SET KEYs
   scReadProcName := PROCNAME( 1 )
   snReadProcLine := PROCLINE( 1 )

   // Set initial GET to be read
   IF ! nPos > 0
      nPos := Settle( Getlist, 0 )
   ENDIF

   DO WHILE ! nPos == 0
      aVarGet := Array( Len( GetList ) )
      FOR EACH oElement IN GetList // by JPA to otimize screen update
         aVarGet[ oElement:__EnumIndex ] := oElement:VarGet()
      NEXT

      // GET NEXT GET from list and post it as the active GET
      PostActiveGet( oGet := GetList[ nPos ] )

      // Read the GET
      IF ( VALTYPE( oGet:reader ) == "B" )
         EVAL( oGet:reader, oGet )    // Use custom reader block
      ELSE
         GetReader( oGet, lIsMouse )            // Use standard reader
      ENDIF

      FOR EACH oElement IN GetList // by JPA to otimize screen update
         IF aVarGet[ oElement:__EnumIndex ] != oElement:VarGet()
            oElement:Display()
         ENDIF
      NEXT
      // Move to NEXT GET based on EXIT condition
      nPos := Settle( GetList, nPos )

   ENDDO

   // Restore state variables
   RestoreGetSysVars( aSavGetSysVars )

   // S'87 compatibility
   SETPOS( MAXROW() - 1, 0 )

   RETURN ( slUpdated )

   /***
   *  GetReader()
   *  Standard modal read of a single GET
   */

PROCEDURE GetReader( oGet, lIsMouse )

   LOCAL nKey

   //--------------------------------- changed here
   oGet:Display()

   // Read the GET IF the WHEN condition is satisfied

   IF ( GetPreValidate( oGet ) )

      // Activate the GET for reading
      oGet:setFocus()

      WHILE ( oGet:EXITState == GE_NOEXIT )

         // Check for initial typeout (no editable positions)
         IF ( oGet:typeOut )
            oGet:EXITState := GE_ENTER
         ENDIF
         // Apply keystrokes until EXIT
         WHILE ( oGet:EXITState == GE_NOEXIT )
            nKey := Inkey( JPA_IDLE, INKEY_ALL - INKEY_MOVE + HB_INKEY_GTEVENT ) // Mouse
            nKey := iif( nKey == 0, K_ESC, nKey )
            //nKey := WaitKey()
            GetApplyKey( oGet, nKey, lIsMouse)
         ENDDO

         // Disallow EXIT IF the VALID condition is not satisfied
         IF ! GetPostValidate( oGet )
            oGet:EXITState := GE_NOEXIT
         ENDIF
         IF ValType( oGet:Cargo ) == "B"
            Eval( oGet:Cargo )
         ENDIF
      ENDDO

      // De-activate the GET
      oGet:killFocus()
   ENDIF

   RETURN

   /***
   *  GetApplyKey()
   *  Apply a single INKEY() keystroke to a GET
   *  NOTE: GET must have focus.
   */

PROCEDURE GetApplyKey( oGet, nKey, lIsMouse )

   LOCAL cKey
   LOCAL bKeyBlock
   LOCAL nMRow, nMCol // by JPA, adicionado para mouse
   LOCAL nCont

   lIsMouse := iif(lIsMouse==NIL,.F.,.T.)

   IF nKey == K_RBUTTONDOWN
      KEYBOARD ( K_ESC )
      Inkey(0)
      nKey := K_ESC
   ENDIF

   // Check for SET KEY first
   IF ! ( ( bKeyBlock := setkey( nKey ) ) == NIL )
      GetDoSetKey( bKeyBlock, oGet )
      RETURN                           // NOTE
   ENDIF

   DO CASE
   CASE ( nKey == K_UP )
      oGet:EXITState := GE_UP

   CASE ( nKey == K_SH_TAB )
      oGet:EXITState := GE_UP

   CASE ( nKey == K_DOWN )
      oGet:EXITState := GE_DOWN

   CASE ( nKey == K_TAB )
      oGet:EXITState := GE_DOWN

   CASE ( nKey == K_ENTER )
      oGet:EXITState := GE_ENTER

   CASE ( nKey == K_ESC )
      IF ( SET( _SET_ESCAPE ) )

         oGet:undo()
         oGet:EXITState := GE_ESCAPE

      ENDIF

   CASE ( nKey == K_PGUP .OR. nKey == K_MWBACKWARD)
      oGet:EXITState := GE_WRITE

   CASE ( nKey == K_PGDN .OR. nKey == K_MWFORWARD)
      oGet:EXITState := GE_WRITE

   CASE ( nKey == K_CTRL_HOME )
      oGet:EXITState := GE_TOP

   CASE ( nkey == K_LBUTTONDOWN )  // Limita mouse na linha
      nMRow := MROW()
      NMCol := MCOL()
      IF nMRow == oGet:row .AND. nMCol >= oGet:col .AND. nMCol <= oGet:col + GetLen( oGet )
         oGet:home()
         FOR nCont = 1 to nMCol - oGet:col
            oGet:right()
         NEXT
         //ELSEIF lIsMouse
         //   oGet:EXITstate := GE_MOUSEHIT // by JPA, Saida pelo Mouse
      ENDIF

#ifdef CTRL_END_SPECIAL

      // Both ^W and ^End go to the last GET
   CASE ( nKey == K_CTRL_END )
      oGet:EXITState := GE_BOTTOM

#else

      // Both ^W and ^End terminate the READ (the default)
   CASE ( nKey == K_CTRL_W )
      oGet:EXITState := GE_WRITE

#endif

   CASE ( nKey == K_INS )
      Set( _SET_INSERT, ! Set( _SET_INSERT ) )
      ShowScoreboard()

   CASE ( nKey == K_UNDO )
      oGet:undo()

   CASE ( nKey == K_HOME )
      oGet:home()

   CASE ( nKey == K_END )
      oGet:end()

   CASE ( nKey == K_RIGHT )
      oGet:right()

   CASE ( nKey == K_LEFT )
      oGet:left()

   CASE ( nKey == K_CTRL_RIGHT )
      oGet:wordRight()

   CASE ( nKey == K_CTRL_LEFT )
      oGet:wordLeft()

   CASE ( nKey == K_BS )
      oGet:backSpace()

   CASE ( nKey == K_DEL )
      oGet:delete()

   CASE ( nKey == K_CTRL_T )
      oGet:delWordRight()

   CASE ( nKey == K_CTRL_Y )
      oGet:delEnd()

   CASE ( nKey == K_CTRL_BS )
      oGet:delWordLeft()

   OTHERWISE

      // Alterado aqui pra não aceitar caracteres especiais

      IF ! ( nKey >= 32 .AND. nKey <= 123 )
         IF nKey < 1000 // não mouse
            wapi_MessageBeep()
         ENDIF
      ELSE

         cKey := Chr( nKey )

         IF ( oGet:type == "N" .AND. ( cKey == "." .OR. cKey == "," ) )
            oGet:toDecPos()
         ELSE

            IF ( Set( _SET_INSERT ) )
               oGet:insert( cKey )
            ELSE
               oGet:overstrike( cKey )
            ENDIF

            IF ( oGet:typeOut )
               IF ( Set( _SET_BELL ) )
                  wapi_MessageBeep()
               ENDIF

               IF ! Set( _SET_CONFIRM )
                  oGet:EXITState := GE_ENTER
               ENDIF
            ENDIF

         ENDIF
      ENDIF

   ENDCASE

   RETURN

   /***
   *  GetPreValidate()
   *  Test entry condition (WHEN clause) for a GET
   */

FUNCTION GetPreValidate( oGet )

   LOCAL lSavUpdated
   LOCAL lWhen := .T.

   IF ! ( oGet:preBlock == NIL )

      lSavUpdated := slUpdated

      lWhen := EVAL( oGet:preBlock, oGet )

      oGet:display()

      ShowScoreBoard()
      slUpdated := lSavUpdated

   ENDIF

   IF ( slKillRead )

      lWhen := .F.
      oGet:EXITState := GE_ESCAPE       // Provokes ReadModal() EXIT

   ELSEIF ! lWhen

      oGet:EXITState := GE_WHEN         // Indicates failure

   ELSE

      oGet:EXITState := GE_NOEXIT       // Prepares for editing

   END

   RETURN ( lWhen )

   /***
   *  GetPostValidate()
   *  Test EXIT condition (VALID clause) for a GET
   *  NOTE: Bad dates are rejected in such a way as to preserve edit buffer
   */

FUNCTION GetPostValidate( oGet )

   LOCAL lSavUpdated
   LOCAL lValid := .T.

   IF ( oGet:EXITState == GE_ESCAPE )
      RETURN ( .T. )                   // NOTE
   ENDIF

   IF ( oGet:badDate() )
      oGet:home()
      DateMsg()
      ShowScoreboard()
      RETURN ( .F. )                   // NOTE
   ENDIF

   // IF editing occurred, assign the new value to the variable
   IF ( oGet:changed )
      oGet:assign()
      slUpdated := .T.
   ENDIF

   // Reform edit buffer, set cursor to home position, redisplay
   oGet:reset()

   // Check VALID condition IF specified
   IF ! ( oGet:postBlock == NIL )

      lSavUpdated := slUpdated

      // S'87 compatibility
      SETPOS( oGet:row, oGet:col + LEN( oGet:buffer ) )

      lValid := EVAL( oGet:postBlock, oGet )

      // Reset S'87 compatibility cursor position
      SETPOS( oGet:row, oGet:col )

      ShowScoreBoard()
      oGet:updateBuffer()

      slUpdated := lSavUpdated

      IF ( slKillRead )
         oGet:EXITState := GE_ESCAPE      // Provokes ReadModal() EXIT
         lValid := .T.

      ENDIF
   ENDIF

   RETURN ( lValid )

   /***
   *  GetDoSetKey()
   *  Process SET KEY during editing
   */

PROCEDURE GetDoSetKey( keyBlock, oGet )

   LOCAL lSavUpdated

   // IF editing has occurred, assign variable
   IF ( oGet:changed )
      oGet:assign()
      slUpdated := .T.
   ENDIF

   lSavUpdated := slUpdated

   EVAL( keyBlock, scReadProcName, snReadProcLine, ReadVar() )

   ShowScoreboard()
   oGet:updateBuffer()

   slUpdated := lSavUpdated

   IF ( slKillRead )
      oGet:EXITState := GE_ESCAPE      // provokes ReadModal() EXIT
   ENDIF

   RETURN

   /***
   *              READ services
   */

   /***
   *  Settle()
   *  RETURNs new position in array of GET objects, based on:
   *     - current position
   *     - EXITState of GET object at current position
   *  NOTES: RETURN value of 0 indicates termination of READ
   *         EXITState of old GET is transferred to new Get
   */

STATIC FUNCTION Settle( GetList, nPos )

   LOCAL nEXITState
   LOCAL nMRow, nMCol, oElement // by JPA, Variaveis para Mouse

   IF ( nPos == 0 )
      nEXITState := GE_DOWN
   ELSE
      nEXITState := GetList[ nPos ]:EXITState
   ENDIF

   // Adicionado este trecho para mouse

   IF ( nEXITState == GE_MOUSEHIT )
      nMRow := MROW()
      nMCol := MCOL()
      FOR EACH oElement IN GetList
         IF nMRow == oElement:Row .AND. nMCol >= oElement:Col .AND. nMCol <= ( oElement:Col + GetLen( oElement ) )
            IF GetPreValidate( oElement )
               nPos       := oElement:__EnumIndex
               nEXITState := GE_MOUSEHIT
               EXIT
            ENDIF
         ENDIF
      NEXT
   ENDIF

   IF ( nEXITState == GE_ESCAPE .OR. nEXITState == GE_WRITE )
      RETURN ( 0 )               // NOTE
   ENDIF

   IF ! ( nEXITState == GE_WHEN )
      // Reset state info
      snLastPos := nPos
      slBumpTop := .F.
      slBumpBot := .F.
   ELSE
      // Re-use last EXITState, do not disturb state info
      nEXITState := snLastEXITState
   ENDIF

   // Move
   DO CASE
   CASE ( nEXITState == GE_UP )
      nPos--

   CASE ( nEXITState == GE_DOWN )
      nPos++

   CASE ( nEXITState == GE_TOP )
      nPos       := 1
      slBumpTop  := .T.
      nEXITState := GE_DOWN

   CASE ( nEXITState == GE_BOTTOM )
      nPos       := LEN( GetList )
      slBumpBot  := .T.
      nEXITState := GE_UP

   CASE ( nEXITState == GE_ENTER )
      nPos++

   ENDCASE

   // Bounce
   IF ( nPos == 0 )                       // Bumped top
      IF ! ReadExit() .AND. ! slBumpBot
         slBumpTop  := .T.
         nPos       := snLastPos
         nEXITState := GE_DOWN
      ENDIF

   ELSEIF ( nPos == Len( GetList ) + 1 )  // Bumped bottom
      IF ! ReadExit() .AND. ! nExitState == GE_ENTER .AND. ! slBumpTop
         slBumpBot  := .T.
         nPos       := snLastPos
         nEXITState := GE_UP
      ELSE
         nPos := 0
      ENDIF
   ENDIF

   // Record EXIT state
   snLastEXITState := nEXITState

   IF ! ( nPos == 0 )
      GetList[ nPos ]:EXITState := nEXITState
   ENDIF

   RETURN ( nPos )

   /***
   *  PostActiveGet()
   *  Post active GET for ReadVar(), GetActive()
   */

STATIC PROCEDURE PostActiveGet( oGet )

   GetActive( oGet )
   ReadVar( GetReadVar( oGet ) )

   ShowScoreBoard()

   RETURN

   /***
   *  ClearGetSysVars()
   *  Save and clear READ state variables. RETURN array of saved values
   *  NOTE: 'Updated' status is cleared but not saved (S'87 compatibility)
   */

STATIC FUNCTION ClearGetSysVars()

   LOCAL aSavSysVars[ GSV_COUNT ]

   // Save current sys vars
   aSavSysVars[ GSV_KILLREAD ]     := slKillRead
   aSavSysVars[ GSV_BUMPTOP ]      := slBumpTop
   aSavSysVars[ GSV_BUMPBOT ]      := slBumpBot
   aSavSysVars[ GSV_LASTEXIT ]     := snLastEXITState
   aSavSysVars[ GSV_LASTPOS ]      := snLastPos
   aSavSysVars[ GSV_ACTIVEGET ]    := GetActive( NIL )
   aSavSysVars[ GSV_READVAR ]      := ReadVar( "" )
   aSavSysVars[ GSV_READPROCNAME ] := scReadProcName
   aSavSysVars[ GSV_READPROCLINE ] := snReadProcLine

   // Re-init old ones
   slKillRead      := .F.
   slBumpTop       := .F.
   slBumpBot       := .F.
   snLastEXITState := 0
   snLastPos       := 0
   scReadProcName  := ""
   snReadProcLine  := 0
   slUpdated       := .F.

   RETURN ( aSavSysVars )

   /***
   *  RestoreGetSysVars()
   *  Restore READ state variables from array of saved values
   *  NOTE: 'Updated' status is not restored (S'87 compatibility)
   */

STATIC PROCEDURE RestoreGetSysVars( aSavSysVars )

   slKillRead      := aSavSysVars[ GSV_KILLREAD ]
   slBumpTop       := aSavSysVars[ GSV_BUMPTOP ]
   slBumpBot       := aSavSysVars[ GSV_BUMPBOT ]
   snLastEXITState := aSavSysVars[ GSV_LASTEXIT ]
   snLastPos       := aSavSysVars[ GSV_LASTPOS ]

   GetActive( aSavSysVars[ GSV_ACTIVEGET ] )

   ReadVar( aSavSysVars[ GSV_READVAR ] )

   scReadProcName  := aSavSysVars[ GSV_READPROCNAME ]
   snReadProcLine  := aSavSysVars[ GSV_READPROCLINE ]

   RETURN

   /***
   *  GetReadVar()
   *  Set READVAR() value from a GET
   */

STATIC FUNCTION GetReadVar( oGet )

   LOCAL cName := UPPER( oGet:name )
   LOCAL oElement

   // The following code includes subscripts in the name RETURNed by
   // this FUNCTIONtion, IF the GET variable is an array element
   // Subscripts are retrieved from the oGet:subscript instance variable
   // NOTE: Incompatible WITH Summer 87
   IF ! ( oGet:subscript == NIL )
      FOR EACH oElement IN oGet:subscript
         cName += "[" + LTRIM( Str( oElement ) ) + "]"
      NEXT
   END

   RETURN ( cName )

   /***
   *              System Services
   */

   /***
   *  __SetFormat()
   *  SET FORMAT service
   */

PROCEDURE __SetFormat( b )

   sbFormat := IF( VALTYPE( b ) == "B", b, NIL )

   RETURN

   /***
   *  __KillRead()
   *  CLEAR GETS service
   */

PROCEDURE __KillRead()

   slKillRead := .T.

   RETURN

   /***
   *  GetActive()
   *  Retrieves currently active GET object
   */

FUNCTION GetActive( g )

   LOCAL oldActive := soActiveGet

   IF ( PCOUNT() > 0 )
      soActiveGet := g
   ENDIF

   RETURN ( oldActive )

   /***
   *  Updated()
   */

FUNCTION Updated()

   RETURN slUpdated

   /***
   *  ReadEXIT()
   */

FUNCTION ReadEXIT( lNew )

   RETURN ( SET( _SET_EXIT, lNew ) )

   /***
   *  ReadInsert()
   */

FUNCTION ReadInsert( lNew )

   RETURN ( SET( _SET_INSERT, lNew ) )

   /***
   *              Wacky Compatibility Services
   */

   // Display coordinates for SCOREBOARD
#define SCORE_ROW      0
#define SCORE_COL      60

   /***
   *  ShowScoreboard()
   */

STATIC PROCEDURE ShowScoreboard()

   LOCAL nRow
   LOCAL nCol

   IF ( SET( _SET_SCOREBOARD ) )
      nRow := ROW()
      nCol := COL()

      SETPOS( SCORE_ROW, SCORE_COL )
      DISPOUT( IF( SET( _SET_INSERT ), NationMsg(_GET_INSERT_ON),;
         NationMsg(_GET_INSERT_OFF)) )
      SETPOS( nRow, nCol )
   ENDIF

   RETURN

   /***
   *  DateMsg()
   */

STATIC PROCEDURE DateMsg()

   LOCAL nRow
   LOCAL nCol

   IF ( SET( _SET_SCOREBOARD ) )

      nRow := ROW()
      nCol := COL()

      SETPOS( SCORE_ROW, SCORE_COL )
      DISPOUT( NationMsg(_GET_INVD_DATE) )
      SETPOS( nRow, nCol )

      WHILE ( NEXTKEY() == 0 )
      END

      SETPOS( SCORE_ROW, SCORE_COL )
      DISPOUT( SPACE( LEN( NationMsg(_GET_INVD_DATE) ) ) )
      SETPOS( nRow, nCol )

   ENDIF

   RETURN

   /***
   *  RangeCheck()
   *  NOTE: Unused second param for 5.00 compatibility.
   */

FUNCTION RangeCheck( oGet, junk, lo, hi )

   LOCAL cMsg, nRow, nCol
   LOCAL xValue

   IF ! oGet:changed
      RETURN ( .T. )          // NOTE
   ENDIF

   xValue := oGet:varGet()
   JUNK   := NIL // por causa do W3

   IF ( xValue >= lo .AND. xValue <= hi )
      RETURN ( .T. )          // NOTE
   ENDIF

   IF ( SET(_SET_SCOREBOARD) )

      cMsg := NationMsg(_GET_RANGE_FROM) + LTRIM( TRANSFORM( lo, "" ) ) + ;
         NationMsg(_GET_RANGE_TO) + LTRIM( TRANSFORM( hi, "" ) )

      IF ( LEN( cMsg ) > MAXCOL() )
         cMsg := SUBSTR( cMsg, 1, MAXCOL() )
      ENDIF

      nRow := ROW()
      nCol := COL()

      SETPOS( SCORE_ROW, MIN( 60, MAXCOL() - LEN( cMsg ) ) )
      DISPOUT( cMsg )
      SETPOS( nRow, nCol )

      WHILE ( NEXTKEY() == 0 )
      END

      SETPOS( SCORE_ROW, MIN( 60, MAXCOL() - LEN( cMsg ) ) )
      DISPOUT( SPACE( LEN( cMsg ) ) )
      SETPOS( nRow, nCol )

   ENDIF

   RETURN ( .F. )

   /***
   *  ReadKill()
   */

FUNCTION ReadKill( lKill )

   LOCAL lSavKill := slKillRead

   IF ( PCOUNT() > 0 )
      slKillRead := lKill
   ENDIF

   RETURN ( lSavKill )

   /***
   *  ReadUpdated()
   */

FUNCTION ReadUpdated( lUpdated )

   LOCAL lSavUpdated := slUpdated

   IF ( PCOUNT() > 0 )
      slUpdated := lUpdated
   ENDIF

   RETURN ( lSavUpdated )

   /***
   *  ReadFormat()
   */

FUNCTION ReadFormat( b )

   LOCAL bSavFormat := sbFormat

   IF ( PCOUNT() > 0 )
      sbFormat := b
   ENDIF

   RETURN ( bSavFormat )

   /*
   *   GetLen()
   *   by JPA, Retorna tamanho. Adicionado para mouse
   */

STATIC FUNCTION GetLen( oGet )

   LOCAL rval := 1

   DO CASE
   CASE oGet:type == "C"
      rval := Len( oGet:varGet() )
   CASE oGet:type == "D"
      rval := 8
   CASE oGet:type == "L"
      rval := 3
   CASE oGet:type == "N"
      IF EMPTY( oGet:picture )
         rval := Len( LTrim( Str( oGet:varGet() ) ) )
      ELSE
         rval := Len( oGet:picture )
      ENDIF
   ENDCASE

   RETURN rVal
