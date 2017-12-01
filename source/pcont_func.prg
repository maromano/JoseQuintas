/*
PCONT_FUNC FUNCOES DA CONTABILIDADE
José Quintas
*/

#include "inkey.ch"

FUNCTION LenContaContabil( cTipo )

   LOCAL cPicture, cLenCodigo := "", cLenPicture := "", nLenCodigo := 0, nCont, nSelect := Select()

   hb_Default( @cTipo, "C" )
   IF Select( "jpempre" ) == 0
      SELECT 0
      AbreArquivos( "jpempre" )
   ENDIF
   cPicture := Trim( jpempre->emPicture )
   FOR nCont = 1 TO Len( cPicture )
      IF Substr( cPicture, nCont, 1 ) $ " -"
         cLenCodigo  += StrZero( nLenCodigo, 2 )
         cLenPicture += StrZero( nCont, 2 )
         EXIT
      ELSEIF Substr( cPicture, nCont, 1 ) == "."
         cLenCodigo  += StrZero( nLenCodigo, 2 ) + ","
         cLenPicture += StrZero( nCont - 1, 2 ) + ","
      ELSE
         nLenCodigo += 1
      ENDIF
   NEXT
   SELECT ( nSelect )

   RETURN iif( cTipo == "C", cLenCodigo, cLenPicture )

FUNCTION GrupoContabil( cCodigo )

   LOCAL cTxt := "", nPos := 1

   DO WHILE nPos < Len( LenContaContabil( "C" ) )
      cTxt += Pad( Left( cCodigo, Val( Substr( LenContaContabil( "C" ), nPos, 2 ) ) ), 11 ) + ","
      nPos += 3
   ENDDO

   RETURN cTxt

FUNCTION CabecalhoContabil()

   LOCAL nNumMes, nNumAno
   MEMVAR oPDF, m_Livro, nOpcMes, nOpcOficial, mData

   IF Type( "nOpcMes" ) != "N"
      nOpcMes := 1
   ENDIF
   nNumMes := nOpcMes
   nNumAno := jpempre->emAnoBase
   DO WHILE nNumMes > 12
      nNumMes -= 12
      nNumAno += 1
   ENDDO
   mData := UltDia( Stod( StrZero( nNumAno, 4 ) + StrZero( nNumMes, 2 ) + "01" ) )
   IF nOpcOficial == 1 .AND. ( oPDF:nPageNumber + 1 ) == jpempre->emQtdPag
      TermoLivroDiario( "ENCERRAMENTO", jpempre->emQtdPag )
      TermoLivroDiario( "ABERTURA",     jpempre->emQtdPag )
      oPDF:nPageNumber := 1
      m_Livro = m_Livro + 1
   ENDIF
   oPDF:PageHeader()

   RETURN NIL

FUNCTION PicConta( cCodigo )

   LOCAL cTxt, nPos, nCont

   IF "DIVERS" $ cCodigo
      cTxt := cCodigo
   ELSE
      cCodigo := SoNumeros( cCodigo )
      cTxt := Transform( cCodigo, "@R " + jpempre->emPicture )
      FOR nCont = Len( cTxt ) TO 1 STEP -1
         IF ! Right( cTxt, 1 ) $ ".- "
            EXIT
         ENDIF
         cTxt := Substr( cTxt, 1, Len( cTxt ) - 1 )
      NEXT
      IF "-" $ jpempre->emPicture // pra tirar o ultimo ponto
         IF ! "-" $ cTxt
            nPos := Rat( ".", cTxt )
            cTxt := Substr( cTxt, 1, nPos - 1 ) + "-" + Substr( cTxt, nPos + 1 )
         ENDIF
      ENDIF
   ENDIF
   cTxt := Pad( cTxt, 19 )

   RETURN cTxt

FUNCTION CodContabil( cCodigo )

   cCodigo := SoNumeros( cCodigo )
   cCodigo := Pad( Left( cCodigo, Len( cCodigo ) - 1 ), 11 ) + Right( cCodigo, 1 )

   RETURN cCodigo

FUNCTION SelecionaMesContabil( nLini, nColi, nNumMes )

   LOCAL acTxtAno, acTxtMes, nOpcAno, nOpcMes, nCont

   acTxtAno := {}
   FOR nCont = 1 TO 8
      Aadd( acTxtAno, StrZero( jpempre->emAnoBase + nCont - 1 , 4 ) )
   NEXT
   acTxtMes := { "JANEIRO", "FEVEREIRO", "MARCO", "ABRIL", "MAIO", "JUNHO", "JULHO", "AGOSTO", "SETEMBRO", "OUTUBRO", "NOVEMBRO", "DEZEMBRO" }
   nOpcAno := Int( ( nNumMes -1 ) / 12 ) + 1
   nOpcMes := iif( Mod( nNumMes, 12 ) == 0, 12, Mod( nNumMes, 12 ) )
   wOpen( nLini, nColi, nLini + 10, nColi + 40, "Ano" )
   DO WHILE .T.
      FazAchoice( nLini + 2, nColi + 1, nLini + 9, nColi + 39, acTxtAno, @nOpcAno )
      IF LastKey() != K_ESC
         wAchoice( nLini + 1, nColi + 10, acTxtMes, @nOpcMes, "Mes" )
         IF LastKey() == K_ESC
            LOOP
         ENDIF
         nNumMes := ( nOpcAno - 1 ) * 12 + nOpcMes
      ENDIF
      EXIT
   ENDDO
   wClose()

   RETURN NIL

FUNCTION ContabilAnoMes( nMes ) // contabil

   LOCAL nAno

   nAno := jpempre->emAnoBase + Int( ( nMes - 1 ) / 12 )
   nMes := Mod( nMes, 12 )
   nMes := iif( nMes == 0, 12, nMes )

   RETURN StrZero( nAno, 4 ) + StrZero( nMes, 2 )

FUNCTION AtualizaLancto( nSomaTira ) // contabil

   LOCAL mSelect := Select(), mCampo, mValor, mCMes

   hb_Default( @nSomaTira, 1 )
   mCMes   := StrZero( ( Year( ctdiari->diData ) - jpempre->emAnoBase ) * 12 + Month( ctdiari->diData ), 2 )
   IF Val( mCMes ) > 0 .AND. Val( mCMes ) <= 96
      Encontra( ctdiari->diCConta, "ctplano" )
      SELECT ctplano
      RecLock()
      mCampo := iif( ctdiari->diDebCre == "D", "a_deb", "a_cre" ) + mCMes
      mValor := nSomaTira * ctdiari->diValor
      REPLACE &( "ctplano->" + mCampo ) WITH &( "ctplano->" + mCampo ) + mValor, ;
         ctplano->Alterada         WITH "S"
      RecUnlock()
   ENDIF
   SELECT ctlotes
   SEEK StrZero( Year( ctdiari->diData ), 4 ) + StrZero( Month( ctdiari->diData ), 2 ) + ctdiari->diLote
   IF Eof()
      RecAppend()
      REPLACE ctlotes->loLote WITH ctdiari->diLote, ;
         ctlotes->loData WITH ctdiari->diData
   ENDIF
   RecLock()
   REPLACE ctlotes->loQtdCal WITH ctlotes->loQtdCal + nSomaTira
   IF ctdiari->diDebCre == "D"
      REPLACE ctlotes->loDebCal WITH ctlotes->loDebCal + ( nSomaTira * ctdiari->diValor )
   ELSE
      REPLACE ctlotes->loCreCal WITH ctlotes->loCreCal + ( nSomaTira * ctdiari->diValor )
   ENDIF
   RecUnlock()
   SELECT ( mSelect )

   RETURN .T.
