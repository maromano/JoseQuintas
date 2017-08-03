/*
ZE_CHART - Gráfico de barras simples
2016.055.13.2013 - José Quintas
*/

#include "hbclass.ch"

CREATE CLASS BarChartClass

   VAR    cTxtTitle            INIT ""
   VAR    aTxtBarList          INIT {}
   VAR    aTxtSubList          INIT {}
   VAR    aValues              INIT {}
   VAR    nTop                 INIT 0
   VAR    nLeft                INIT 0
   VAR    nBottom              INIT MaxRow()
   VAR    nRight               INIT MaxCol()
   METHOD Show()

   VAR    nMaxValue            INIT 10
   VAR    nIncrement           INIT 1
   VAR    nGradeCount          INIT 5
   METHOD CalcMaxValue()
   METHOD ShowEmpty()
   METHOD ShowColBar()
   METHOD ShowColSub( nNumBar, nColuna, nLarguraColuna )
   METHOD BarColor( nNumColor )

   ENDCLASS

METHOD BarchartClass:Show()

   ::CalcMaxValue()
   Scroll( ::nTop, ::nLeft, ::nBottom, ::nRight, 0 )
   ::ShowEmpty()
   ::ShowColBar()

   RETURN NIL

METHOD BarchartClass:CalcMaxValue()

   LOCAL oBarElement, oSubElement

   FOR EACH oBarElement IN ::aValues
      FOR EACH oSubElement IN oBarElement
         ::nMaxValue := Max( ::nMaxValue, oSubElement )
      NEXT
   NEXT
   DO WHILE .t.
      ::nIncrement *= 10
      IF ::nIncrement * ::nGradeCount > ::nMaxValue
         EXIT
      ENDIF
   ENDDO
   IF ( ::nIncrement * ::nGradeCount / 2 ) > ::nMaxValue
      ::nIncrement := ::nIncrement / 2
   ENDIF
   IF ( ::nIncrement * ::nGradeCount / 2 ) > ::nMaxValue
      ::nIncrement := ::nIncrement / 2
   ENDIF
   ::nMaxValue  := ::nIncrement * ::nGradeCount

   RETURN NIL

METHOD BarchartClass:ShowEmpty()

   LOCAL nCont

   // Título
   @ ::nTop, Int( ( ::nRight - ::nLeft - 1 - Len( ::cTxtTitle ) ) / 2 ) SAY " " + ::cTxtTitle + " " COLOR "N/W"

   // Linhas horizontal/vertical
   @ ::nTop + 2, ::nLeft + 12 TO ::nBottom - 3, ::nLeft + 12
   @ ::nBottom - 3, ::nLeft + 12 TO ::nBottom - 3, ::nRight - 2

   // Valores da barra vertical
   FOR nCont = 1 TO ::nGradeCount
      @ ::nBottom - 3 - ( ( ::nBottom - ::nTop - 6 ) / ::nGradeCount * nCont ), ::nLeft SAY nCont * ::nIncrement PICTURE "9999999999"
      @ Row(), ::nLeft + 13 TO Row(), ::nRight - 3
   NEXT

   // Legenda
   @ ::nBottom - 1, ::nLeft SAY ""
   FOR nCont = 1 TO Len( ::aTxtSubList )
      @ Row(), Col() + 2 SAY Space(2) COLOR ::BarColor( nCont )
      @ Row(), Col() + 2 SAY ::aTxtSubList[ nCont ]
   NEXT

   RETURN NIL

METHOD BarchartClass:ShowColBar()

   LOCAL nCont, nLarguraColuna

   nLarguraColuna := Int( ( ::nRight - ::nLeft - 11 ) / ( Len( ::aValues[ 1 ] ) + 1 ) )

   // cada grupo do gráfico
   FOR nCont = 1 TO Len( ::aTxtBarList )
      ::ShowColSub( nCont, 13 + ( ( nCont - 1 ) * nLarguraColuna ), nLarguraColuna )
   NEXT

   RETURN NIL

METHOD BarchartClass:ShowColSub( nNumBar, nColuna, nLarguraColuna )

   LOCAL nCont, cColorOld, nRow

   cColorOld := SetColor()

   // barras de comparação
   FOR nCont = 1 TO Len( ::aTxtSubList )
      nRow := ::nBottom - ( ( ::nBottom - ::nTop - 2 ) * ::aValues[ nCont, nNumbar ] / ::nMaxValue )
      SetColor( ::BarColor( nCont ) )
      @ nRow, nColuna + nCont CLEAR TO ::nBottom - 4, nColuna + nCont
   NEXT
   SetColor( cColorOld )
   // legenda de cada coluna do gráfico
   @ ::nBottom - 2, nColuna + 1 SAY Pad( ::aTxtBarList[ nNumBar ], nLarguraColuna - 1 )

   RETURN NIL

METHOD BarchartClass:BarColor( nNumColor )

   DO CASE
   CASE nNumColor == 1 ; RETURN "9/9"
   CASE nNumColor == 2 ; RETURN "14/14"
   CASE nNumColor == 3 ; RETURN "15/15"
   CASE nNumColor == 4 ; RETURN "11/11"
   CASE nNumColor == 5 ; RETURN "12/12"
   ENDCASE

   RETURN "N/W"

FUNCTION GPizzaHorizontal( cTitulo, acLabel, anValue, nOrder )

   LOCAL lUpdated, nCont, nMaxLabel, cTmpText, nTmpValue, nValueTotal, nValueMax, nColorNumber, acColorTable

   hb_Default( @nOrder, 0 )
   nMaxLabel := ( MaxRow() - 6 )
   IF nOrder != 0
      lUpdated := .T.
      DO WHILE lUpdated
         lUpdated := .F.
         FOR nCont = 2 TO Len( acLabel ) // each Label
            GrafProc()
            IF ( acLabel[ nCont ] < acLabel[ nCont - 1 ] .AND. nOrder == 1 ) .OR. ( anValue[ nCont ] > anValue[ nCont - 1 ] .AND. nOrder == 2 )
               cTmpText             := acLabel[ nCont ]
               nTmpValue            := anValue[ nCont ]
               acLabel[ nCont ]     := acLabel[ nCont - 1 ]
               anValue[ nCont ]     := anValue[ nCont - 1 ]
               acLabel[ nCont - 1 ] := cTmpText
               anValue[ nCont - 1 ] := nTmpValue
               lUpdated := .T.
            ENDIF
         NEXT
      ENDDO
   ENDIF
   IF Len( acLabel ) > nMaxLabel
      acLabel[ nMaxLabel ] := Pad( "**OUTROS**", Len( acLabel[ 1 ] ) )
   ENDIF
   DO WHILE Len( acLabel ) > nMaxLabel
      anValue[ nMaxLabel ] += anValue[ Len( acLabel ) ]
      ASize( anValue, Len( anValue ) - 1 )
   ENDDO

   nValueTotal := 0
   nValueMax := 0
   FOR nCont = 1 TO Len( acLabel )
      nValueMax := Max( nValueMax, anValue[ nCont ] )
      nValueTotal += anValue[ nCont ]
   NEXT

   // acColorTable := { "G", "BG", "R", "RB", "GR", "W", "N+", "GR+" } // "B" nao
   acColorTable := { "G/G", "BG/BG", "GR+/GR+" }
   Cls()
   @ 2, 0 SAY Padc( cTitulo, 80 )
   nColorNumber := 1
   FOR nCont = 1 TO Len( acLabel )
      @ 3 + nCont, 0 SAY acLabel[ nCont ]
      @ 3 + nCont, Col() + 2 SAY Str( anValue[ nCont ] * 100 / nValueTotal, 3 )
      @ 3 + nCont, Col() SAY "%"
      nColorNumber := iif( nColorNumber == Len( acColorTable ), 1, nColorNumber + 1 )
      @ 3 + nCont, Col() + 2 SAY Replicate( Chr(219), anValue[ nCont ] * 60 / nValueMax ) COLOR ( acColorTable[ nColorNumber ] )
   NEXT

   RETURN NIL

