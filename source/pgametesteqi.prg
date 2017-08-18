/*
PGAMETESTEQI - Passatempo Teste de QI
José Quintas
*/

#require "gtwvg.hbc"
#include "inkey.ch"
#include "hbclass.ch"

#define CASA_COR            1
#define CASA_NACIONALIDADE  2
#define CASA_BEBIDA         3
#define CASA_CIGARRO        4
#define CASA_ANIMAL         5

STATIC acCasa := {}

PROCEDURE PGameTesteQi

   LOCAL nKey, acOpcao, lConcluido := .F., acButtons := {}, nRow, nCol := 11, oElement

   acCasa := Array(5)
   acOpcao := Array( 15 )
   aFill( acOpcao, " " )
   FOR EACH oElement IN acCasa
      oElement := { "N/A", "N/A", "N/A", "N/A", "N/A" }
   NEXT
   DO WHILE .T.
      ChecaOpcoes( acOpcao, lConcluido )

      ButtonsCreate( acButtons )

      nRow := 16
      IF acOpcao[ 1 ] != "X"
         ButtonCreate( acButtons,  nRow++, nCol, 1, 50, "(" + acOpcao[ 1 ]  + ") O inglês vive na casa Vermelha" )
      ENDIF
      IF acOpcao[ 2 ] != "X"
         ButtonCreate( acButtons,  nRow++, nCol, 1, 50, "(" + acOpcao[ 2 ]  + ") O sueco tem Cachorros como animais de estimação" )
      ENDIF
      IF acOpcao[ 3 ] != "X"
         ButtonCreate( acButtons, nRow++, nCol, 1, 50, "(" + acOpcao[ 3 ]  + ") O dinamarquês bebe chá" )
      ENDIF
      IF acOpcao[ 4 ] != "X"
         ButtonCreate( acButtons, nRow++, nCol, 1, 50, "(" + acOpcao[ 4 ]  + ") A casa verde fica ao lado esquerdo da casa branca" )
      ENDIF
      IF acOpcao[ 5 ] != "X"
         ButtonCreate( acButtons, nRow++, nCol, 1, 50, "(" + acOpcao[ 5 ]  + ") O homem que vive na casa verde bebe café" )
      ENDIF
      IF acOpcao[ 6 ] != "X"
         ButtonCreate( acButtons, nRow++, nCol, 1, 50, "(" + acOpcao[ 6 ]  + ") O homem que fuma Pall Mall cria pássaros" )
      ENDIF
      IF acOpcao[ 7 ] != "X"
         ButtonCreate( acButtons, nRow++, nCol, 1, 50, "(" + acOpcao[ 7 ]  + ") O homem que vive na casa amarela fuma drunhil" )
      ENDIF
      IF acOpcao[ 8 ] != "X"
         ButtonCreate( acButtons, nRow++, nCol, 1, 50, "(" + acOpcao[ 8 ]  + ") O homem que vive na casa do meio bebe leite" )
      ENDIF
      IF acOpcao[ 9 ] != "X"
         ButtonCreate( acButtons, nRow++, nCol, 1, 50, "(" + acOpcao[ 9 ]  + ") O norueguês vive na primeira casa" )
      ENDIF
      IF acOpcao[ 10 ] != "X"
         ButtonCreate( acButtons, nRow++, nCol, 1, 50, "(" + acOpcao[ 10 ] + ") O homem que fuma Blends vive ao lado do que tem gatos" )
      ENDIF
      IF acOpcao[ 11 ] != "X"
         ButtonCreate( acButtons, nRow++, nCol, 1, 50, "(" + acOpcao[ 11 ] + ") O homem que cria cavalos vive ao lado do que fuma Drunhil" )
      ENDIF
      IF acOpcao[ 12 ] != "X"
         ButtonCreate( acButtons, nRow++, nCol, 1, 50, "(" + acOpcao[ 12 ] + ") O homem que fuma bluemaster bebe cerveja" )
      ENDIF
      IF acOpcao[ 13 ] != "X"
         ButtonCreate( acButtons, nRow++, nCol, 1, 50, "(" + acOpcao[ 13 ] + ") O alemão fuma Prince" )
      ENDIF
      IF acOpcao[ 14 ] != "X"
         ButtonCreate( acButtons, nRow++, nCol, 1, 50, "(" + acOpcao[ 14 ] + ") O norueguês vive ao lado da casa azul" )
      ENDIF
      IF acOpcao[ 15 ] != "X"
         ButtonCreate( acButtons, nRow++, nCol, 1, 50, "(" + acOpcao[ 15 ] + ") O homem que fuma Blends é vizinho do que bebe água" )
      ENDIF
      nRow += 2
      ButtonCreate( acButtons, nRow, nCol, 1, 50, "Siga as pistas e descubra quem cria peixes" )
      wvgSetAppWindow():Refresh()
      nKey := Inkey(0)
      IF nKey == K_ESC
         EXIT
      ENDIF
      ButtonsDestroy( acButtons )
   ENDDO

   RETURN

STATIC FUNCTION ChecaOpcoes( acOpcao )

   LOCAL oCasa, nNumCasa

   Afill( acOpcao, " " )
   FOR EACH oCasa IN acCasa
      IF oCasa[ CASA_NACIONALIDADE ] == "Inglês" .AND. oCasa[ CASA_COR ] == "Vermelha"
         acOpcao[ 1 ] := "X"
      ENDIF
      IF oCasa[ CASA_NACIONALIDADE ] == "Sueco" .AND. oCasa[ CASA_ANIMAL ] == "Cachorros"
         acOpcao[ 2 ] := "X"
      ENDIF
      IF oCasa[ CASA_NACIONALIDADE ] == "Dinamarquês" .AND. oCasa[ CASA_BEBIDA ] == "Chá"
         acOpcao[ 3 ] := "X"
      ENDIF
      IF oCasa[ CASA_COR ] == "Verde" .AND. oCasa[ CASA_BEBIDA ] == "Café"
         acOpcao[ 5 ] := "X"
      ENDIF
      IF oCasa[ CASA_CIGARRO ] == "Pall Mall" .AND. oCasa[ CASA_ANIMAL ] == "Pássaros"
         acOpcao[ 6 ] := "X"
      ENDIF
      IF oCasa[ CASA_COR ] == "Amarela" .AND. oCasa[ CASA_CIGARRO ] == "Drunhil"
         acOpcao[ 7 ] := "X"
      ENDIF
      IF oCasa[ CASA_CIGARRO ] == "Bluemaster" .AND. oCasa[ CASA_BEBIDA ] == "Cerveja"
         acOpcao[ 12 ] := "X"
      ENDIF
      IF oCasa[ CASA_NACIONALIDADE ] == "Alemão" .AND. oCasa[ CASA_CIGARRO ] == "Prince"
         acOpcao[ 13 ] := "X"
      ENDIF
   NEXT
   IF acCasa[ 3, CASA_BEBIDA ] == "Leite"
      acOpcao[ 8 ] := "X"
   ENDIF
   IF acCasa[ 1, CASA_NACIONALIDADE ] == "Norueguês"
      acOpcao[ 9 ] := "X"
   ENDIF
   FOR nNumCasa = 1 TO 4
      IF ( acCasa[ nNumCasa, CASA_ANIMAL ] == "Cavalos" .AND. acCasa[ nNumCasa + 1, CASA_CIGARRO ] == "Drunhil" ) .OR. ;
         ( acCasa[ nNumCasa + 1, CASA_ANIMAL ] == "Cavalos" .AND. acCasa[ nNumCasa, CASA_CIGARRO ] == "Drunhil" )
         acOpcao[ 11 ] := "X"
      ENDIF
      IF acCasa[ nNumCasa, CASA_COR ] == "Verde" .AND. acCasa[ nNumCasa + 1, CASA_COR ] == "Branca"
         acOpcao[ 4 ] := "X"
      ENDIF
      IF ( acCasa[ nNumCasa, CASA_CIGARRO ] == "Blends" .AND. acCasa[ nNumCasa + 1, CASA_ANIMAL ] == "Gatos" ) .OR. ;
         ( acCasa[ nNumCasa + 1, CASA_CIGARRO ] == "Blends" .AND. acCasa[ nNumCasa, CASA_ANIMAL ] == "Gatos" )
         acOpcao[ 10 ] := "X"
      ENDIF
      IF ( acCasa[ nNumCasa, CASA_CIGARRO ] == "Blends" .AND. acCasa[ nNumCasa + 1, CASA_BEBIDA ] == "Água" ) .OR. ;
         ( acCasa[ nNumCasa + 1, CASA_CIGARRO ] == "Blends" .AND. acCasa[ nNumCasa, CASA_BEBIDA ] == "Água" )
         acOpcao[ 15 ] := "X"
      ENDIF
      IF ( acCasa[ nNumCasa, CASA_NACIONALIDADE ] == "Norueguês" .AND. acCasa[ nNumCasa + 1, CASA_COR ] == "Azul" ) .OR. ;
         ( acCasa[ nNumCasa + 1, CASA_NACIONALIDADE ] == "Norueguês" .AND. acCasa[ nNumCasa, CASA_COR ] == "Azul" )
         acOpcao[ 14 ] := "X"
      ENDIF
   NEXT

   RETURN NIL

STATIC FUNCTION ClickMouse( nRow, nCol, lConcluido )

   LOCAL nOpcao, acOpcoes, nNumCasa, nCategoria, oElement

   IF nRow == 0 .OR. nCol == 0
      RETURN NIL
   ENDIF
   nCategoria := nRow
   nNumCasa   := nCol
   DO CASE
   CASE nCategoria == CASA_COR ;           acOpcoes := { "N/A", "Amarela", "Azul", "Branca", "Verde", "Vermelha" }
   CASE nCategoria == CASA_NACIONALIDADE ; acOpcoes := { "N/A", "Alemão", "Dinamarquês", "Inglês", "Norueguês", "Sueco" }
   CASE nCategoria == CASA_BEBIDA ;        acOpcoes := { "N/A", "Água", "Café", "Cerveja", "Chá", "Leite" }
   CASE nCategoria == CASA_CIGARRO ;       acOpcoes := { "N/A", "Blends", "Bluemaster", "Drunhil", "Pall Mall", "Prince" }
   CASE nCategoria == CASA_ANIMAL ;        acOpcoes := { "N/A", "Cachorros", "Cavalos", "Gatos", "Pássaros", "Peixes" }
   OTHERWISE
      RETURN NIL
   ENDCASE
   FOR EACH oElement IN acOpcoes
      oElement := Pad( oElement, 18 )
   NEXT
   wSave()
   nRow := 20
   nCol := 67
   @ nRow, nCol CLEAR TO nRow + 10, nCol + 24
   @ nRow, nCol TO nRow + 10, nCol + 24
   nOpcao := Achoice( nRow + 1, nCol + 1, nRow + 9, nCol + 23, acOpcoes, .T., , nOpcao )
   IF LastKey() != K_ESC
      acCasa[ nNumCasa, nCategoria ] := Trim( acOpcoes[ nOpcao ] )
   ENDIF
   lConcluido := .T.
   FOR EACH oElement IN acOpcoes
      IF oElement != "X"
         lConcluido := .F.
      ENDIF
   NEXT
   wRestore()

   RETURN NIL

STATIC FUNCTION ButtonsCreate( acButtons )

   LOCAL nNumCasa

   ButtonCreate( acButtons,  3, 11, 1.2, 10, "" )
   ButtonCreate( acButtons,  5, 11, 1.2, 10, "Cor" )
   ButtonCreate( acButtons,  7, 11, 1.2, 10, "Nacionalidade" )
   ButtonCreate( acButtons,  9, 11, 1.2, 10, "Bebida" )
   ButtonCreate( acButtons, 11, 11, 1.2, 10, "Cigarro" )
   ButtonCreate( acButtons, 13, 11, 1.2, 10, "Animal" )
   FOR nNumCasa = 1 TO 5
      ButtonCreate( acButtons,  3, nNumCasa * 11 + 11, 1.2, 10, "Casa" + Str( nNumCasa, 1 ) )
      ButtonCreate( acButtons,  5, nNumCasa * 11 + 11, 1.2, 10, acCasa[ nNumCasa, CASA_COR ],           BuildBlock( CASA_COR,           nNumCasa ) )
      ButtonCreate( acButtons,  7, nNumCasa * 11 + 11, 1.2, 10, acCasa[ nNumCasa, CASA_NACIONALIDADE ], BuildBlock( CASA_NACIONALIDADE, nNumCasa ) )
      ButtonCreate( acButtons,  9, nNumCasa * 11 + 11, 1.2, 10, acCasa[ nNumCasa, CASA_BEBIDA ],        BuildBlock( CASA_BEBIDA,        nNumCasa ) )
      ButtonCreate( acButtons, 11, nNumCasa * 11 + 11, 1.2, 10, acCasa[ nNumCasa, CASA_CIGARRO ],       BuildBlock( CASA_CIGARRO,       nNumCasa ) )
      ButtonCreate( acButtons, 13, nNumCasa * 11 + 11, 1.2, 10, acCasa[ nNumCasa, CASA_ANIMAL ],        BuildBlock( CASA_ANIMAL,        nNumCasa ) )
   NEXT

   RETURN NIL

STATIC FUNCTION ButtonCreate( acButtons, nTop, nLeft, nHeight, nWidth, cTexto, bBlock )

   LOCAL oThisButton

   oThisButton := wvgtstPushButton():New()
   oThisButton:PointerFocus := .F.
   oThisButton:Caption := cTexto
   oThisButton:Create( , , { -nTop, -nLeft }, { -nHeight, -nWidth } )
   oThisButton:ToolTipText( cTexto )
   oThisButton:Activate := bBlock
   AAdd( acButtons, oThisButton )

   RETURN NIL

STATIC FUNCTION ButtonsDestroy( acButtons )

   LOCAL oThisButton

   FOR EACH oThisButton IN acButtons
      oThisButton:Destroy()
   NEXT
   acButtons := {}

   RETURN NIL

STATIC FUNCTION BuildBlock( nLinha, nColuna )

   LOCAL bBlock

   bBlock := { || ClickMouse( nLinha, nColuna ) }

   RETURN bBlock
