*----------------------------------------------------------------
* PROGRAMA...: LJPTABEL - LISTAGEM DAS TABELAS DO SISTEMA       *
* CRIACAO....: 23.10.96 - JOSE                                  *
*----------------------------------------------------------------

* ...
* 2014.08.28.1740 - Pergunta estava invertida Sim/Não
* 2014.08.28.1740 - Aceita código/texto no intervalo
* 2014.08.31.1202 - Cadastra tabelas no zero
*----------------------------------------------------------------

#include "josequintas.ch"
#include "hbclass.ch"
#include "inkey.ch"

PROCEDURE LJPTABEL

   LOCAL nOpctemp, mDefault, nOpcGeral, acTxtGeral, GetList := {}, acTxtTabAux, acTxtOrdem, acLstTabelas, oElement
   MEMVAR nOpcTabAux, nOpcOrdem, mTabAuxi, mTabAuxf, nOpcPrinterType
   PRIVATE nOpcTabAux, nOpcOrdem, mTabAuxi, mTabAuxf

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpconfi", "jpempre", "jpsenha", "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   acLstTabelas := {}
   GOTO TOP
   DO WHILE ! Eof()
      IF aScan( acLstTabelas, jptabel->axTabela ) == 0
         AAdd( acLstTabelas, jptabel->axTabela )
      ENDIF
      SKIP
   ENDDO
   FOR EACH oElement IN acLstTabelas
      SEEK AUX_TABAUX + oElement
      IF Eof()
         RecAppend()
         REPLACE jptabel->axTabela WITH AUX_TABAUX, ;
                 jptabel->axCodigo WITH oElement
         RecUnlock()
      ENDIF
   NEXT

   mDefault := LeCnfRel()

   nOpcTabAux  = 1
   mTabAuxi = Space(6)
   mTabAuxf = Space(6)
      acTxtTabAux := { "Todas", "Intervalo" }

   nOpcOrdem := iif( mDefault[1] > 2, 2, mDefault[1] )
      acTxtOrdem := { "Código", "Alfabética" }

   nOpcPrinterType := AppPrinterType()

   nOpcGeral = 1
      acTxtGeral := Array(5)

   WOpen( 5, 4, 7 + len( acTxtGeral ), 45, "Opções disponíveis" )

   DO WHILE .T.
      acTxtGeral := { ;
         TxtImprime(), ;
         TxtSalva(), ;
         "Intervalo.: " + iif(nOpcTabAux==1,acTxtTabAux[ 1 ], ;
            mTabAuxi + " a " + mTabAuxf ), ;
         "Ordem.....: " + acTxtOrdem[ nOpcOrdem ], ;
         "Saída.....: " + TxtSaida()[ nOpcPrinterType ] }

      FazAchoice( 7, 5, 6+len(acTxtGeral), 44, acTxtGeral, @nOpcGeral )

      nOpctemp := 1
      DO CASE
      CASE LastKey() == K_ESC
         EXIT

      CASE nOpcGeral == nOpctemp++
         IF ConfirmaImpressao()
            Imprime()
         ENDIF

      CASE nOpcGeral == nOpctemp++

      CASE nOpcGeral == nOpctemp++
         WOpen( nOpcGeral+6, 25, nOpcGeral+10, 65, "Intervalo" )
         DO WHILE .T.
            FazAchoice( nOpcGeral+8, 26, nOpcGeral+9, 64, acTxtTabAux, @nOpcTabAux )
            IF LastKey() != K_ESC .AND. nOpcTabAux == 2
               WOpen( nOpcGeral+9, 45, nOpcGeral+13, 65, "Tabelas" )
               @ nOpcGeral+11, 47 GET mTabAuxi PICTURE "@!"
               @ nOpcGeral+12, 47 GET mTabAuxf PICTURE "@!"
               Mensagem( "Digite Tabelas, F9 Pesquisa, ESC Sai" )
               READ
               WClose()
               IF LastKey() == K_ESC
                  LOOP
               ENDIF
            ENDIF
            EXIT
         ENDDO
         WClose()

      CASE nOpcGeral == nOpctemp++
         WAchoice( nOpcGeral+6, 25, acTxtOrdem, @nOpcOrdem, "Ordem" )

      CASE nOpcGeral == nOpctemp
         WAchoice( nOpcGeral+6,25, TxtSaida(), @nOpcPrinterType, "Saída" )
         AppPrinterType( nOpcPrinterType )

      ENDCASE
   ENDDO
   WClose()

   RETURN

STATIC FUNCTION Imprime()

   LOCAL oPDF, nKey, mTabela, mRecNo
   MEMVAR nOpcOrdem, nOpcTabAux, mTabAuxi, mTabAuxf, nOpcPrinterType

   OrdSetFocus( iif( nOpcOrdem == 1, "numlan", "descricao" ) )

   oPDF := PDFClass():New()
   oPDF:SetType( nOpcPrinterType )
   oPDF:Begin()
   oPDF:acHeader := { "", "" }
   oPDF:acHeader[1] := "LISTAGEM DOS CADASTROS AUXILIARES"
   IF nOpcTabAux == 1
      GOTO TOP
   ELSE
      oPDF:acHeader[2] := "de " + mTabAuxi + " ate " + mTabAuxf
      SEEK mTabAuxi
   ENDIF

   nKey := 0
   DO WHILE nKey != K_ESC .AND. ! Eof()
      GrafProc()
      nKey = Inkey()
      DO CASE
      CASE jptabel->axTabela > mTabAuxf .AND. nOpcTabAux == 2
         EXIT
      ENDCASE
      oPDF:MaxRowTest()
      mRecNo := RecNo()
      mTabela := jptabel->axTabela
      Encontra(StrZero(0,6) + mTabela, "jptabel", "numlan" )
      oPDF:nRow++
      oPDF:DrawText( oPDF:nRow++, 0, Padc( mTabela + " - " + Trim( jptabel->axDescri ), oPDF:MaxCol(), "-" ) )
      oPDF:nRow++
      GOTO ( mRecNo )
      DO WHILE jptabel->axTabela == mTabela .AND. ! Eof()
         oPDF:MaxRowTest()
         oPDF:DrawText( oPDF:nRow, 0, jptabel->axCodigo + " - " + jptabel->axDescri )
         oPDF:nRow += 1
         SKIP
      ENDDO
   ENDDO
   oPDF:End()

   RETURN .T.
