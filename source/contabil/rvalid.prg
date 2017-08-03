/*
RVALID - VALIDACOES DO SISTEMA
1995.04.07

...
*/

#include "josequintas.ch"
#include "inkey.ch"

MEMVAR m_Prog

FUNCTION OkContabil( mContVar )

   LOCAL lReturn, nRow, nSelect, cKeyboard, cReadVar, cCodigo, cDigito, cContac

   nSelect   := Select()
   cKeyboard := ""
   cReadVar  := Lower( ReadVar() )
   lReturn   := .T.
   nRow      := row()
   DO CASE
   CASE LastKey() == K_CTRL_R .OR. LastKey() == K_CTRL_C .OR. LastKey() == K_CTRL_W
      lReturn = .F.

   CASE LastKey() == K_UP
      lReturn = .T.

   CASE cReadVar $ "m_uf,m_ufcrc,m_cnpj"
      lReturn = ! ( " " $ mContVar )

   CASE cReadVar $ "m_ccusto,m_ccustoi,m_ccustof"
      IF cReadVar == "m_ccusto" .AND. m_Prog != "PCONTREL0530"
         @ nRow, 35 SAY Space(40)
      ENDIF
      FillZeros( @mContVar )
      IF Val(mContVar) == 999999
         lReturn := ( m_prog $ "PCONTCTPLANO,PCONTLANCPAD" )
      ELSEIF Val(mContVar) == 0
         IF m_prog == "PCONTCTPLANO"
            lReturn := .T.
         ELSEIF m_prog $ "PCONTLANCPAD,PCONTLANCINCLUI,PCONTLANCALTERA"
            lReturn := MsgYesNo("Deixar lançamento sem centro de custo?")
         ELSE
            lReturn := .F.
         ENDIF
      ELSE
         IF ! Encontra( AUX_CCUSTO + mContVar, "jptabel", "numlan" )
            MsgWarning( "Centro de custo não cadastrado!")
            lReturn = .F.
         ENDIF
         IF cReadVar == "m_ccusto" .AND. m_Prog != "PCONTREL0530"
            @ nRow, 35 SAY AUXCCUSTOClass():Descricao( mContVar )
         ENDIF
      ENDIF

   CASE cReadVar $ "mctconta,mctcontad,mctcontac"
      nRow = row()
      @ nRow, 40 SAY Space(35)
      IF lastkey() == K_UP
         lReturn = .T.
      ELSEIF empty( mContVar )
         lReturn = .F.
      ELSE
         cCodigo = Substr( mContVar, 1, Len( Trim( mContVar ) ) - 1 )
         cDigito = Substr( mContVar, Len( Trim( mContVar ) ), 1 )
         cContac = pad( cCodigo, 11 ) + cDigito
         IF ! encontra( cContac, "ctplano" )
            MsgWarning( "Conta contábil não cadastrada!")
            lReturn = .F.
         ELSEIF ctplano->a_tipo != "A" .AND. m_prog != "PCONTSALDO"
            MsgWarning( "Conta não é analítica!")
            lReturn = .F.
         ENDIF
         @ nRow, 40 SAY ctplano->a_nome
         IF ! m_prog $ "PCONTSALDO"
            @ nRow-1, 22 SAY StrZero( Val( ctplano->a_reduz ), 6 )
         ENDIF
      ENDIF

   CASE cReadVar $ "mmeslote"
      FillZeros(@mContVar)
      IF Val(mContVar) < 1 .OR. Val(mContVar) > 12
         MsgWarning( "Mês inválido!")
         lReturn := .F.
      ENDIF

   CASE cReadVar $ "manolote"
      FillZeros(@mContVar)
      IF (Val(mContVar) < jpempre->emAnoBase) .OR. (Val(mContVar)-jpempre->emAnoBase)*12 > 96
         MsgWarning( "Período inválido!")
         lReturn := .F.
      ENDIF

   CASE cReadVar == "mctreduz"
      IF empty( mContVar )
         lReturn = .F.
      ELSEIF " " $ mContVar
         cKeyboard = StrZero( Val( mContVar ), Len( mContVar ) )
         lReturn = .F.
      ELSEIF ! encontra( str( Val( mContVar ), 6 ), "ctplano", "ctplano2")
         MsgWarning( "Conta não cadastrada!")
         lReturn = .F.
      ENDIF

   OTHERWISE
      lReturn = ! Empty( mContVar )
   ENDCASE
   SELECT ( nSelect )
   IF Len( cKeyboard ) != 0
      KEYBOARD cKeyboard + Chr(13)
   ENDIF

   RETURN ( lReturn )
