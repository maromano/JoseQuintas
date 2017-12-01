/*
PGAMEFORCA - JOGO DE FORCA
2000.09.16 José Quintas
*/

#include "inkey.ch"

PROCEDURE pGameForca

   LOCAL nKey, cLetra, nPlacarOk, nPlacarErr, cPalavra, nErros, nCont, nQtOk, nMRow, nMCol, cLetrasJa

   // Inicia()
   nPlacarOk := 0
   nPlacarErr:= 0
   DO WHILE .T.
      Cls()
      Mensagem()
      cPalavra  := SorteiaPalavra()
      cLetrasJa := ""
      nErros    := 0
      nQtOk     := 0
      ShowPlacar( nPlacarOk, nPlacarErr )
      ShowLetras( cLetrasJa )
      ShowDesenho(0)
      ShowPalavra( cPalavra, cLetrasJa, @nQtOk ) // mOk=Pular letras que não digita
      @ 28, 27 SAY "Palavra e/ou Frase Secreta"
      DO WHILE .T.
         nKey := Inkey(0)
         IF nKey == K_ESC .OR. nKey == K_RBUTTONDOWN
            EXIT
         ENDIF
         IF nKey == K_LBUTTONDOWN
            nKey := 0
            nMRow  := MROW()
            nMCol  := MCOL()
            IF nMRow != 16
               LOOP
            ENDIF
            FOR nCont = 1 TO 26
               IF nMCol == ( 24 + nCont * 2 )
                  nKey := 64 + nCont
                  EXIT
               ENDIF
            NEXT
            IF nKey == 0
               LOOP
            ENDIF
         ENDIF
         cLetra := Upper( Chr( nKey ) )
         IF Asc( cLetra ) < 65 .OR. Asc( cLetra ) > 90 // Letras
            Mensagem( cLetra + " não é letra, tente novamente" )
            IF ( nKey := Inkey(5) ) > 0
               KEYBOARD Chr( nKey )
            ENDIF
            Mensagem()
            LOOP
         ENDIF
         IF cLetra $ cLetrasJa
            Mensagem( cLetra + " já foi, tente novamente" )
            IF ( nKey := Inkey(5) ) > 0
               KEYBOARD Chr( nKey )
            ENDIF
            Mensagem()
            LOOP
         ENDIF
         cLetrasJa += cLetra
         ShowLetras( cLetrasJa )
         IF cLetra $ cPalavra
            ShowPalavra( cPalavra, cLetrasJa, @nQtOk )
            Mensagem( "Digite a letra" )
            IF nQtOk >= Len( cPalavra )
               nPlacarOk += 1
               ShowPlacar( nPlacarOk, nPlacarErr )
               Mensagem( "Acertou! Tecle algo para jogar novamente, ESC para Sair!" )
               Inkey(50)
               Mensagem()
               EXIT
            ENDIF
         ELSE
            nErros += 1
            ShowDesenho( nErros )
            IF nErros > 8
               nPlacarErr += 1
               ShowPlacar( nPlacarOk, nPlacarErr )
               ShowPalavra( cPalavra, cPalavra )
               IF ! MsgYesNo( "Enforcado! Continua" )
                  nKey := K_ESC
               ENDIF
               EXIT
            ENDIF
            Mensagem( cLetra + " não tem, digite outra letra" )
            IF ( nKey := Inkey(5) ) > 0
               KEYBOARD Chr( nKey )
            ENDIF
         ENDIF
      ENDDO
      IF nKey == K_ESC .OR. nKey == K_RBUTTONDOWN
         EXIT
      ENDIF
   ENDDO

   RETURN

STATIC FUNCTION SorteiaPalavra()

   LOCAL nQtSorteio, oElement

   THREAD STATIC mTexto := {}, mNum   := 0

   IF mNum == 0
      CarregaPalavras( mTexto )
   ENDIF
   nQtSorteio := 0
   DO WHILE .T.
      mNum := Mod( ( Seconds() * 100 ), Len( mTexto ) ) + 1 // Sorteia
      nQtSorteio += 1
      IF mTexto[ mNum, 2 ]
         IF nQtSorteio <= 10
            LOOP
         ENDIF
         FOR EACH oElement IN mTexto
            IF ! oElement[ 2 ]
               EXIT
            ENDIF
         NEXT
         IF mNum > Len( mTexto )
            FOR EACH oElement IN mTexto
               oElement[ 2 ] := .F.
            NEXT
         ENDIF
      ENDIF
      EXIT
   ENDDO
   IF mNum > Len( mTexto )
      mNum := 1
   ENDIF
   mTexto[ mNum, 2 ] := .T.

   RETURN mTexto[ mNum, 1 ]

STATIC FUNCTION ShowPalavra( cPalavra, cLetrasJa, nQtOk )

   LOCAL nEspaco, nColuna, oElement

   nQtOk := 0
   nEspaco := iif( Len( cPalavra ) > 38, 1, 2 )
   nColuna := Int( ( MaxCol() - ( Len( cPalavra ) * nEspaco ) ) / 2 )
   FOR EACH oElement IN cPalavra
      IF oElement $ " ,'"
         nQtOk += 1
         @ 30, nColuna + oElement:__EnumIndex * nEspaco SAY oElement
      ELSEIF oElement $ cLetrasJa
         nQtOk += 1
         @ 30, nColuna + oElement:__EnumIndex * nEspaco SAY oElement
      ELSE
         @ 30, nColuna + oElement:__EnumIndex * nEspaco SAY "-"
      ENDIF
   NEXT

   RETURN NIL

   // Se mudar aqui, mudar tambem rotina do Mouse

STATIC FUNCTION ShowLetras( cLetrasJa )

   LOCAL nCont

   FOR nCont = 1 To 26 // A a Z
      @ 27, 24 + nCont * 2 SAY Chr( 64 + nCont ) COLOR iif( Chr( 64 + nCont ) $ cLetrasJa, "N/W", SetColor() )
   NEXT

   RETURN NIL

STATIC FUNCTION ShowPlacar( nQtOk, nErros )

   @ 5, 70 SAY "   PLACAR"
   @ 6, 70 SAY "OK...:" + Str( nQtOk, 5 )
   @ 7, 70 SAY "ERROS:" + Str( nErros, 5 )

   RETURN NIL

STATIC FUNCTION ShowDesenho( mDesenho )

   IF mDesenho > -1 // Barra da Forca
      @ 3, 9 TO 3, 29 DOUBLE COLOR "GR+/B"
      @ 4, 9 TO 23, 9 DOUBLE COLOR "GR+/B"
   ENDIF
   IF mDesenho > 0 // Cabeca
      @ 4, 27 TO 6, 31
   ENDIF
   IF mDesenho > 1 // Cabelo
      @ 4, 27 SAY "@@@@@" COLOR "GR+/B"
   ENDIF
   IF mDesenho > 2 // tronco
      @ 7, 29 TO 9, 29
   ENDIF
   IF mDesenho > 3 // perna 1
      @ 10, 28 TO 12, 28
      @ 13, 27 TO 13, 27 DOUBLE
   ENDIF
   IF mDesenho > 4 // perna 2
      @ 10, 30 TO 12, 30
      @ 13, 31 TO 13, 31 DOUBLE
   ENDIF
   IF mDesenho > 5 // braço 1
      @ 7, 26 TO 7, 28
      @ 7, 25 TO 7, 25 DOUBLE
   ENDIF
   IF mDesenho > 6 // braço 2
      @ 7, 30 TO 7, 32
      @ 7, 33 TO 7, 33 double
   ENDIF
   IF mDesenho > 7 // olhos nariz e boca
      @ 5, 28 SAY "o.o"
      @ 5, 28 SAY "o"
      @ 5, 30 SAY "o"
   ENDIF
   IF mDesenho > 8 // olhos nariz e boca
      @ 5, 28 SAY "-.-"
      @ 6, 29 SAY  "U"
      @ 15, 23 SAY "ENFORCADO!"
   ENDIF

   RETURN NIL

STATIC FUNCTION CarregaPalavras( acPalavras )

   LOCAL acLista, oElement

   acLista := { ;
      "AUTOMOVEL", "AMIGO", "AMIZADE", "AGULHA", "AZUL", "AVISO", "AMOR", ;
      "BAIXINHA", "BRINQUEDO", "BRINCO", "BRINCADEIRA", "BANCO", "BLUSA", "BILHETE", "BEIJO", ;
      "CABELO", "CONTRATO", "CALENDARIO", "CARINHO", "CAMINHAO", "CACHORRO", "CADERNO", "CAMISA", "CONSTITUCIONAL", "COR", "CONHECIMENTO", "CHATO", "CHAVE", ;
      "DIVERTIDO", "DISQUETE", "DOCUMENTO", ;
      "EQUIPAMENTO", "ESPELHO", "ESCOLA", "ESCRITORIO", "ESTOQUE", "ELETRODOMESTICO", ;
      "FECHADURA", "FELICIDADE", "FEITICEIRA", "FINANCEIRO", "FIO", "FOTO", "FORCA", ;
      "GRAMPEADOR", "GAROTO", ;
      "HIDRAULICOS", ;
      "IMPRESSORA", "INFORMATICA", ;
      "JOSE", ;
      "LAZER", "LAPIS", "LINDA", ;
      "MOTOCICLETA", "MARAVILHOSO", "MINHOCA", "MATEMATICA", "MICROCOMPUTADOR", "MICROFONE", "MONITOR", "MESA", "MOTOR", "MOLEQUE", "MUSICA", ;
      "NARIZ", "NOTA FISCAL", ;
      "OCULOS", "OLHO", "ORELHA", ;
      "PAPEL", "PESQUISA", "POLICIA", "PREGO", "PNEU", "PENTE", "PRODUTOS", ;
      "QUADRO", "QUEIJO", ;
      "REFRIGERANTE", "RELOGIO", "REGISTRO", "ROCK", "ROSQUINHA", ;
      "SISTEMA", "SOM", "SECRETARIA", "SHOW", ;
      "TOALHA", "TRANSPORTES", "TELEFONE", "TRABALHO", "TATU", "TIJOLO", "TESOURA", "TIAZINHA", "TECLADO", "TOMADA", "TELEVISAO", "TOUCA", "TRINCO", ;
      "VOCE", "VISITANTE", "VERDADE", ;
      ;
      "EU TE AMO (PORTUGUES) I LOVE YOU (INGLES) JE T'AIME (FRANCES)", ;
      "EU TE AMO (PORTUGUES) TI AMO (ITALIA) TE AMO (ESPANHOL)", ;
      "EU TE AMO (PORTUGUES) ICH LIEBE DICH (ALEMAO) UATASHI-UANATA-UACHINTE (JAPONES)", ;
      "JPA TECNOLOGIA", "JOGANDO DE NOVO", ;
      "NAO SE ESQUECA DE TRABALHAR", ;
      "O SOM DO AMOR RECLAMA UM ECO", ;
      "QUEM TEM AMIGOS TEM TUDO", ;
      "SEU CHEFE ESTA' TE OLHANDO", ;
      "TODO HOMEM E' CULPADO DO QUE NAO FEZ", ;
      "VAMOS TRABALHAR" ;
      }

   FOR EACH oElement IN acLista
      AAdd( acPalavras, { oElement, .F.} )
   NEXT

   RETURN NIL
