/*
PADMESTATISTICA - ESTATISTICA DE USO
2001 José Quintas
*/

#include "inkey.ch"

PROCEDURE pAdmEstatistica

   LOCAL mDatai, mDataf, GetList := {}

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso" )
         RETURN
      ENDIF
   ENDIF
   SELECT jpreguso
   mDatai := mDataf := Date()

   DO WHILE .T.
      @ 2, 0 SAY "Data Inicial:" GET mDatai
      @ 3, 0 SAY "Data Final..:" GET mDataf
      READ
      Mensagem()
      IF LastKey()==K_ESC
         EXIT
      ENDIF
      WSave()
      FazCalculo( mDatai, mDataf )
      WRestore()
   ENDDO
   CLOSE DATABASES

   RETURN

STATIC FUNCTION FazCalculo( mDatai, mDataf )

   LOCAL oLstUsuario := {}, olstModulo  := {}, oLstTerminal  := {}, oLstUsuarioTerminal := {}, nResumo
   LOCAL mData, cUsuario, mInforma, mModulo, mTerminal, mTempo, oElement

   GrafTempo( "Processando informações" )
   GOTO TOP
   DO WHILE ! Eof()
      GrafTempo( RecNo(), LastRec() )
      IF "MODULO" $ jpreguso->ruTexto
         mData := Ctod( Substr( jpreguso->ruInfInc, 9, 2 ) + "/" + Substr( jpreguso->ruInfInc, 6, 2 ) + "/" + Substr( jpreguso->ruInfInc, 1, 4 ) )
         IF mData >= mDatai .AND. mData <= mDataf
            cUsuario := mModulo := mTerminal := mTempo := ""
            mInforma := hb_RegExSplit( " ", jpreguso->ruInfInc )
            IF Len( mInforma ) > 2
               cUsuario := mInforma[ 3 ]
               IF Len( mInforma ) > 5
                  mTerminal := mInforma[ 6 ]
               ENDIF
            ENDIF
            mInforma := hb_RegExSplit( " ", jpreguso->ruTexto )
            IF Len( mInforma ) > 1
               mModulo := mInforma[ 2 ]
               mModulo := Substr( mModulo, 1, Len( mModulo ) - 1 ) // Retira virgula
               IF Len( mInforma ) > 3
                  mTempo := mInforma[ 4 ]
               ENDIF
            ENDIF
            mTempo := Val( Substr( mTempo, 1, Len( mTempo ) - 1 ) )
            SomaTempo( mModulo, mTempo, cUsuario, mTerminal, oLstUsuario, olstModulo, oLstTerminal, oLstUsuarioTerminal )
         ENDIF
      ENDIF
      SKIP
   ENDDO
   Mensagem()

   SayScroll( "Efetuando cálculos" )

   ASort( oLstModulo,,,          { | a, b | a[ 2 ] < b[ 2 ] } )
   ASort( oLstUsuario,,,         { | a, b | a[ 2 ] < b[ 2 ] } )
   ASort( oLstTerminal,,,        { | a, b | a[ 2 ] < b[ 2 ] } )
   ASort( oLstUsuarioTerminal,,, { | a, b | a[ 2 ] < b[ 2 ] } )

   nResumo := 0
   DO WHILE .T.
      Cls()
      nResumo += 1
      IF nResumo > 4
         nResumo := 1
      ENDIF
      SayScroll( "Ranking " + Dtoc( mDatai ) + " a " + Dtoc( mDataf ) )
      SayScroll()
      DO CASE
      CASE nResumo == 1
         SayScroll( "Ranking Módulos (Máximo 15)" )
         FOR EACH oElement IN oLstModulo
            SayScroll( MtoH( oElement[ 2 ], 9 ) + " = " + oElement[ 1 ] )
         NEXT
      CASE nResumo == 2
         SayScroll( "Ranking Usuário (Máximo 15)" )
         FOR EACH oElement IN oLstUsuario
            SayScroll( MtoH( oElement[ 2 ], 9 ) + " = " + oElement[ 1 ] )
         NEXT
      CASE nResumo == 3
         SayScroll( "Ranking Terminal (Máximo 15)" )
         FOR EACH oElement IN oLstTerminal
            SayScroll( MtoH( oElement[ 2 ], 9 ) + " = " + oElement[ 1 ] )
         NEXT
      CASE nResumo == 4
         SayScroll( "Ranking Usuário/Terminal (Máximo 15)" )
         FOR EACH oElement IN oLstUsuarioTerminal
            SayScroll( MtoH( oElement[ 2 ], 9 ) + " = " + oElement[ 1 ] )
         NEXT
      ENDCASE
      IF ! MsgYesNo( "Continua" )
         EXIT
      ENDIF
   ENDDO

   RETURN NIL

STATIC FUNCTION SomaTempo( mModulo, mTempo, cUsuario, mTerminal, oLstUsuario, olstModulo, oLstTerminal, oLstUsuarioTerminal )

   Acumula( oLstModulo,   mModulo,  mTempo )
   Acumula( oLstUsuario,  cUsuario, mTempo )
   Acumula( oLstTerminal, mTerminal, mTempo )
   Acumula( oLstUsuarioTerminal, cUsuario + " (" + mTerminal + ")", mTempo )

   RETURN NIL

STATIC FUNCTION MtoH( mMinutos )

   LOCAL mQtSeg, mQtHor, mQtMin

   mQtSeg := mMinutos * 60
   mQtHor := Int( mQtSeg / 3600 )
   mQtSeg := mQtSeg - ( mQtHor * 3600 )
   mQtMin := Int( mQtSeg / 60 )
   mQtSeg := mQtSeg - ( mQtMin * 60 )

   RETURN StrZero( mQtHor, 4 ) + ":" + StrZero( mQtMin, 2 ) // +":"+StrZero(mQtSeg,2)

STATIC FUNCTION Acumula( oList, cName, nTempo )

   LOCAL nNum

   nNum := AScan( oList, { | a | a[ 1 ] == cName } )
   IF nNum == 0
      AAdd( oList, { cName, 0 } )
      nNum := Len( oList )
   ENDIF
   oList[ nNum, 2 ] += nTempo

   RETURN nNum
