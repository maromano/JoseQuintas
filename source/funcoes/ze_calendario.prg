/*
ZE_CALENDARIO - CALENDARIO
1992.10 - José Quintas
*/

#include "hbgtinfo.ch"
#include "inkey.ch"

PROCEDURE Calendario

   LOCAL mData, nKey, oSetKey, nRow, nCol, cSaveScreen
   MEMVAR m_Prog
   PRIVATE m_Prog

   oSetKey := SaveSetKey( K_F9, K_F10, K_SH_F9, K_SH_F10 )

   m_Prog := "CALEND"
   mData  := Date()
   IF Day( mData ) < 16
      mData -= 16
   ENDIF
   nRow := Int( ( MaxRow() - 10 ) / 2 )
   nCol := Int( ( MaxCol() - 71 ) / 2 )
   AppGuiHide()
   SAVE SCREEN TO cSaveScreen

   DO WHILE .T.
      mData := mData - Day( mData ) + 1
      CalendMes( mData, nRow, nCol )
      CalendMes( mData + 35, nRow, nCol + 36 )
      nKey := Inkey(0)
      DO CASE
      CASE nKey == K_PGUP
         mData -= 5
      CASE nKey == K_PGDN
         mData += 35
      CASE nKey == K_UP
         nRow := Max( 0, nRow - 1 )
      CASE nKey == K_DOWN
         nRow := Min( MaxRow() - 10, nRow + 1 )
      CASE nKey == K_LEFT
         nCol := Max( 0, nCol - 1 )
      CASE nKey == K_RIGHT
         nCol := Min( MaxCol() - 71, nCol + 1 )
      CASE nKey == K_CTRL_UP
         nRow := 0
      CASE nKey == K_CTRL_DOWN
         nRow := MaxRow() - 10
      CASE nKey == K_CTRL_LEFT
         nCol := 0
      CASE nKey == K_CTRL_RIGHT
         nCol := MaxCol() - 71
      CASE nKey == K_ESC
         EXIT
      ENDCASE
      RESTORE SCREEN FROM cSaveScreen
   ENDDO
   RestoreSetKey( oSetKey )
   RESTORE SCREEN FROM cSaveScreen
   AppGuiShow()
   KEYBOARD Chr( 205 )
   Inkey(0)

   RETURN

STATIC FUNCTION CalendMes( mData, mLin, mCol )

   LOCAL cColorOld, mSemana, mDia, mCont

   cColorOld := SetColor()
   mSemana := { "Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab" }
   SetColor( SetColorBox() )
   @ mLin, mCol CLEAR TO mLin + 10, mCol + 35
   @ mLin, mCol       TO mLin + 10, mCol + 35
   SetColor( SetColorTituloBox() )
   @ mLin, mCol + 10 SAY Padc( Trim( NomeMes( mData ) ) + "/" + StrZero( Year( mData ), 4 ), 14 )
   SetColor( SetColorBox() )
   FOR mCont = 1 TO 7
      @ mLin + 2, mCol - 1 + Dow( mData + mCont ) * 4 SAY mSemana[ Dow( mData + mCont ) ]
   NEXT
   @ mLin + 3, mCol SAY ""
   mDia := mData - Day( mData ) + 1
   DO WHILE .T.
      IF Dow( mDia ) == 1 .OR. Day( mDia ) == 1
         @ Row() + 1, mCol SAY ""
      ENDIF
      @ Row(), mCol + Dow( mDia ) * 4 SAY Day( mDia ) PICTURE "99" COLOR iif( mDia == Date(), SetColorAlerta(), SetColor() )
      mDia += 1
      IF Month( mDia ) != Month( mData )
         EXIT
      ENDIF
   ENDDO
   SetColor( cColorOld )

   RETURN .T.
