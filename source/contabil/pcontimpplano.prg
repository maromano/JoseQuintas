/*
PCONTIMPPLANO - IMPORTA PLANO DE CONTAS
1997.11 José Quintas
*/

#include "inkey.ch"

PROCEDURE pContImpPlano

   LOCAL m_Empresa := Space(20), mImportaPlano := "N", mImportaHist := "N", mImportaLanc := "N", GetList := {}

   IF ! AbreArquivos( "jpempre", "ctplano", "cthisto", "ctlanca" )
      RETURN
   ENDIF
   DO WHILE .T.
      @ 10, 1 SAY "Empresa de Origem..:" GET m_Empresa     PICTURE "@!" VALID OkEmpresa( m_Empresa )
      @ 12, 1 SAY "Importa Contas.....:" GET mImportaPlano PICTURE "!A"
      @ 13, 1 SAY "Importa Históricos.:" GET mImportaHist  PICTURE "!A"
      @ 14, 1 SAY "Importa Lanç.Padrão:" GET mImportaLanc  PICTURE "!A"
      Mensagem( "Digite campos, ESC sai" )
      READ
      Mensagem()
      IF LastKey() == K_ESC
         EXIT
      ENDIF
      SayScroll( "Importando dados" )
      IF mImportaPlano == "S"
         ImportaCTPLANO( m_Empresa )
      ENDIF
      IF mImportaHist == "S"
         ImportaCTHISTO( m_Empresa )
      ENDIF
      IF mImportaLanc == "S"
         ImportaCTLANCA( m_Empresa )
      ENDIF
      EXIT
   ENDDO

   RETURN

STATIC FUNCTION ImportaCTPLANO( m_Empresa )

   LOCAL m_Cont, m_Grau, mPicture, m_LenAnt, m_LenAtu
   MEMVAR m_TxtDeb, m_TxtCre
   PRIVATE m_TxtDeb, m_TxtCre

   SELECT ctplano
   SayScroll( "Eliminando atual..." )
   GOTO TOP
   DO WHILE ! Eof()
      RecDelete()
      SKIP
   ENDDO
   SayScroll( "Importando..." )
   APPEND FROM ( "..\" + Trim(m_Empresa) + "\ctplano" ) FOR GrafProc()
   SayScroll( "Zerando valores..." )
   GOTO TOP
   DO WHILE ! Eof()
      RecLock()
      REPLACE a_SdAnt WITH 0
      FOR m_Cont = 1 TO 96
         m_TxtDeb := "ctplano->a_Deb" + StrZero( m_Cont, 2 )
         m_TxtCre := "ctplano->a_Cre" + StrZero( m_Cont, 2 )
         IF type(m_TxtDeb) == "N"
            REPLACE &m_TxtDeb WITH 0, &m_TxtCre WITH 0
         ENDIF
      NEXT
      RecUnlock()
      SKIP
   ENDDO
   GOTO TOP
   IF ! Eof()
      SayScroll( "Recuperando estrutura das contas..." )
      m_grau   = 1
      mPicture = ""
      m_LenAnt = 0
      DO WHILE .T.
         LOCATE FOR ctplano->a_grau = m_grau
         IF eof()
            EXIT
         ENDIF
         m_lenatu = Len( Trim( left( ctplano->a_codigo, 11 ) ) )
         mPicture = mPicture + iif( m_lenant == 0, "", "." ) + Replicate( "9", m_lenatu - m_lenant )
         m_grau   = m_grau + 1
         m_lenant = m_lenatu
      ENDDO
      mPicture = mPicture + "-9"
   ENDIF
   SELECT jpempre
   RecLock()
   REPLACE jpempre->emPicture WITH  mPicture
   RecUnlock()

   RETURN NIL

STATIC FUNCTION ImportaCTHISTO( m_Empresa )

   SELECT cthisto
   GOTO TOP
   DO WHILE ! Eof()
      RecDelete()
      SKIP
   ENDDO
   APPEND FROM ( "..\" + Trim( m_Empresa ) + "\cthisto" )

   RETURN NIL

STATIC FUNCTION ImportaCTLANCA( m_Empresa )

   SELECT ctlanca
   GOTO TOP
   DO WHILE ! Eof()
      RecDelete()
      SKIP
   ENDDO
   APPEND FROM ( "..\" + Trim( m_Empresa ) + "\ctlanca" )

   RETURN NIL

STATIC FUNCTION OkEmpresa( m_Empresa )

   IF ! File( "..\" + Trim( m_Empresa ) + "\ctplano.dbf" )
      MsgWarning( "Empresa inválida" )
      RETURN .F.
   ENDIF

   RETURN .T.
