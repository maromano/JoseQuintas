/*
PCONTTOTAIS - TOTAL DIGITADO DE LANCAMENTOS
1993.01 José Quintas
*/

#include "inkey.ch"

PROCEDURE pContTotais

   LOCAL m_SubCre, m_SubDeb, m_Texto, m_TotLot, m_SubLot, m_SubMov, m_TotMov, nKey, m_TotDeb, m_TotCre, mMes

   IF ! AbreArquivos( "ctlotes" )
      RETURN
   ENDIF
   SELECT ctlotes

   m_totdeb = 0
   m_totcre = 0
   m_totmov = 0
   m_totlot = 0

   m_texto = "Meses  "
   m_texto = m_texto + "  Lotes"
   m_texto = m_texto + " Movimentos"
   m_texto = m_texto + Space( 3 ) + "Vlr. Débito"
   m_texto = m_texto + Space( 11 ) + "Vlr. Crédito"
   SayScroll( m_texto )
   SayScroll()

   GOTO TOP
   DO WHILE ! Eof()

      Mensagem( "Tecle algo para pausa, ESC sai" )

      m_subdeb = 0
      m_subcre = 0
      m_submov = 0
      m_sublot = 0

      mMes := Left( DToS( ctlotes->loData ), 6 )
      DO WHILE mMes == Left( DToS( ctlotes->loData ), 6 ) .AND. ! Eof()
         m_subdeb = Round( m_subdeb + ctlotes->loDebCal, 2 )
         m_subcre = Round( m_subcre + ctlotes->loCreCal, 2 )
         m_submov = Round( m_submov + ctlotes->loQtdCal, 0 )
         m_sublot = Round( m_sublot + 1,        0 )
         SKIP
      ENDDO

      m_texto = SubStr( mMes, 5, 2 ) + "/" + SubStr( mMes, 1, 4 )
      m_texto = m_texto + " " + Transform( m_sublot, "99999" )
      m_texto = m_texto + " " + Transform( m_submov, PicVal( 9, 0 ) )
      m_texto = m_texto + " " + Transform( m_subdeb, PicVal( 14, 2 ) )
      m_texto = m_texto + " " + Transform( m_subcre, PicVal( 14, 2 ) )
      IF m_subdeb != m_subcre
         m_texto = m_texto + " " + "***"
      ENDIF
      SayScroll( m_texto )

      m_totlot = Round( m_totlot + m_sublot, 0 )
      m_totmov = Round( m_totmov + m_submov, 0 )
      m_totdeb = Round( m_totdeb + m_subdeb, 2 )
      m_totcre = Round( m_totcre + m_subcre, 2 )

      IF ( nKey := Inkey( 0.3 ) ) == K_ESC
         EXIT
      ELSEIF nKey != 0
         MSGEXCLAMATION( "Prosseguir" )
      ENDIF

   ENDDO

   m_texto = "Totais "
   m_texto = m_texto + " " + Transform( m_totlot, "99999" )
   m_texto = m_texto + " " + Transform( m_totmov, PicVal( 9, 0 ) )
   m_texto = m_texto + " " + Transform( m_totdeb, PicVal( 14, 2 ) )
   m_texto = m_texto + " " + Transform( m_totcre, PicVal( 14, 2 ) )

   SayScroll()
   SayScroll( m_texto )
   CLOSE DATABASES

   MSGEXCLAMATION( "Prosseguir" )

   RETURN
