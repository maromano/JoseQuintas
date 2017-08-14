/*
PBANCOLANCA - MOVIMENTACAO BANCARIA
1989.09 José Quintas
*/

#include "tbrowse.ch"
#include "inkey.ch"

PROCEDURE pBancoLanca

   LOCAL oElement, GetList := {}, cTempFile, oTbrowse, oFrm := frmGuiClass():New() // m_Texto
   MEMVAR mRecalcAuto, m_Filtro, mDataIni

   IF ! AbreArquivos( "jpempre", "jptabel", "jpconfi", "jpbaauto", "jpbagrup", "jpbamovi" )
      RETURN
   ENDIF
   SELECT jpbamovi

   mRecalcAuto := .T.

   mDataIni := Date() - 20
   @ 12, 3 SAY "Data inicial: " GET mDataIni
   Mensagem( "Digite data inicial a visualizar, ESC sai" )
   READ
   Mensagem()

   IF LastKey() == K_ESC
      CLOSE DATABASES
      RETURN
   ENDIF

   SELECT jpbagrup
   SET FILTER TO jpbagrup->bgResumo != "-"
   GOTO TOP
   SELECT jpbamovi
   cTempFile := MyTempFile( "CDX" )
   INDEX ON jpbamovi->baConta + jpbamovi->baAplic + Dtos( jpbamovi->baDatBan ) + Dtos( jpbamovi->baDatEmi ) + ;
      iif( jpbamovi->baValor > 0, "1", "2" ) + StrZero( jpbamovi->( RecNo() ), 6 ) TAG TEMP TO ( cTempFile ) ;
      FOR Dtos( jpbamovi->baDatBan ) >= dtos( mDataIni ) .OR. ( jpbamovi->baValor == 0 )
   SET INDEX TO ( PathAndFile( "jpbamovi" ) ), ( cTempFile )
   OrdSetFocus( "temp" )

   m_Filtro := {}
   SET FILTER TO Filtro()
   SEEK jpbamovi->baConta + jpbamovi->baAplic + Dtos( Date() ) SOFTSEEK
   SKIP -1

   oTBrowse := { ;
      { "BANCO",         { || iif( jpbamovi->baValor == 0, Replicate( "-", 8 ), iif( jpbamovi->baDatBan == Stod( "29991231" ), Space(8), Dtoc( jpbamovi->baDatBan ) ) ) } }, ;
      { "EMISSÃO",       { || iif( jpbamovi->baValor == 0, Replicate( "-", 8 ), iif( jpbamovi->baDatEmi == Stod( "29991231" ), Space(8), Dtoc( jpbamovi->baDatEmi ) ) ) } }, ;
      { "RESUMO",        { || iif( jpbamovi->baValor == 0, Replicate( "-", Len( jpbamovi->baResumo ) ), jpbamovi->baResumo ) } }, ;
      { "HISTÓRICO",     { || iif( jpbamovi->baValor == 0, Pad( jpbamovi->baConta + iif( jpbamovi->baAplic == "S", "(Aplicação)", "" ), Len( jpbamovi->bahist ) ), jpbamovi->baHist ) } }, ;
      { "ENTRADA",       { || iif( jpbamovi->baValor > 0, Transform( Abs( jpbamovi->baValor ), PicVal(14,2) ), Space( Len( Transform( 0, PicVal(14,2) ) ) ) ) } }, ;
      { "SAÍDA",         { || iif( jpbamovi->baValor < 0, Transform( Abs( jpbamovi->baValor ), PicVal(14,2) ), Space( Len( Transform( 0, PicVal(14,2) ) ) ) ) } }, ;
      { "SALDO",         { || iif( jpbamovi->baImpSld == "S", Transform( jpbamovi->baSaldo, PicVal(14,2) ), Space( Len( Transform( jpbamovi->baSaldo, PicVal(14,2) ) ) ) ) } }, ;
      { " ",             { || ReturnValue( " ", vSay( 2, 0, "CONTA " + jpbamovi->baConta ) ) } } }
   FOR EACH oElement IN oTbrowse
      AAdd( oElement, { || Iif( jpbamovi->baValor == 0, { 5, 2 }, { 1, 2 } ) } )
   NEXT
   oFrm:cOptions := "CIAE"
   AAdd( oFrm:acMoreOptions, "<P>Aplicacao" )
   AAdd( oFrm:acMoreOptions, "<C>Contas" )
   AAdd( oFrm:acMoreOptions, "<F>Filtro" )
   AAdd( oFrm:acMoreOptions, "<R>Recalculo" )
   AAdd( oFrm:acMoreOptions, "<T>TrocaConta" )
   AAdd( oFrm:acMoreOptions, "<N>NovaConta" )
   AAdd( oFrm:acMoreOptions, "<D>DesligaRecalculo" )
   AAdd( oFrm:acMoreOptions, "<S>SomaLancamentos" )
   // oFrm:FormBegin( .F. )
   DO WHILE .T.
      @ 1, 0 CLEAR TO 3, MaxCol()
      Mensagem( "I Inclui, A Altera, E Exclui, C-L Pesquisa, P Aplicação, C Contas, N Nova_conta, F Filtro,  R Recálculo, T Troca_conta, X Extras, ESC sai" )
      KEYBOARD Chr( 205 )
      Inkey(0)
      dbView( 3, 0, MaxRow() - 3, MaxCol(), oTBrowse, { | b, k | DigBancoLanca( b, k ) } )
      Mensagem()
      IF LastKey() == K_ESC
         EXIT
      ENDIF
   ENDDO
   CLOSE DATABASES
   oFrm:FormEnd()
   fErase( cTempFile )

   RETURN

FUNCTION DigBancoLanca( ... ) // NAO STATIC usada em pBancoConsolida

   LOCAL nRecNo, m_Aplic, mbaConta
   MEMVAR m_Alterou

   IF Lastkey() == K_ESC
      RETURN 0
   ENDIF
   m_Alterou = .F.
   DO CASE
   CASE Chr( LastKey() ) $ "Xx" .AND. m_Prog == "PBANCOLANCA"
      OpcExtras()

   CASE Chr( LastKey() ) $ "Tt" .AND. m_Prog == "PBANCOLANCA"
      TrocaConta()

   CASE Chr( lastkey() ) $ "Rr"
      RecalculoBancario()

   CASE Chr( LastKey() ) $ "Nn" .AND. m_Prog == "PBANCOLANCA"
      NovaConta()

   CASE Chr( lastkey() ) $ "Pp" .AND. m_Prog == "PBANCOLANCA"
      mbaConta = jpbamovi->baConta
      m_Aplic = iif( jpbamovi->baAplic == "S", "N", "S" )
      ve_Conta( mbaConta, m_Aplic )

   CASE Chr( lastkey() ) $ "Ff"
      do DigFiltro

   CASE Chr( lastkey() ) $ "Cc" .AND. m_Prog == "PBANCOLANCA"
      do DigConta

   CASE lastkey() == K_CTRL_L .AND. m_Prog == "PBANCOLANCA"
      pBancoLancaLocaliza()
      RETURN TBR_EXIT

   CASE lastkey() == 50
      KEYBOARD Chr( K_DOWN )
      RETURN TBR_CONTINUE

   CASE lastkey() == 56
      KEYBOARD Chr( K_UP )
      RETURN TBR_CONTINUE

   CASE lastkey() == K_HOME .OR. lastkey() == 55
      KEYBOARD Chr( K_CTRL_PGUP )
      RETURN TBR_CONTINUE

   CASE lastkey() == K_CTRL_PGDN .OR. lastkey() == 49
      KEYBOARD Chr( K_CTRL_PGDN )
      RETURN TBR_CONTINUE

   CASE lastkey() == K_INS .OR. lastkey() == 48 .OR. Chr( lastkey() ) $ "Ii"
      cadlanc( "INCLUSAO" )
      RETURN TBR_CONTINUE

   CASE lastkey() == K_DEL .OR. lastkey() == 46 .OR. Chr( lastkey() ) $ "Ee"
      cadlanc( "EXCLUSAO" )
      RETURN TBR_CONTINUE

   CASE lastkey() == K_ENTER .OR. Chr( lastkey() ) $ "Aa"
      IF jpbamovi->baValor != 0
         nRecNo := RecNo()
         cadlanc( "ALTERACAO" )
         IF nRecNo != RecNo() .OR. m_Alterou .OR. ! Filtro()
            RETURN TBR_EXIT
         ENDIF
      ENDIF
      RETURN TBR_CONTINUE

   ENDCASE
   //ENDIF

   RETURN TBR_CONTINUE

STATIC PROCEDURE TrocaConta

   LOCAL GetList := {}, mbaConta, mbaConta1, mbaConta2, m_Aplic1, m_DtBco1, m_Aplic2, m_DtBco2, m_RecNo

   mbaConta := jpbamovi->baConta
   m_RecNo := recno()
   WOpen( 5, 5, 9, 75, "Troca para Conta" )
   @ 7, 15 SAY "Conta..:" GET mbaConta PICTURE "@!" VALID ValidBancarioConta( @mbaConta )
   Mensagem( "Digite Conta, F9 pesquisa, ESC Sai" )
   READ
   Mensagem()
   GOTO ( m_RecNo )
   IF jpbamovi->baConta != mbaConta .AND. lastkey() != K_ESC
      IF MsgYesNo( "Confirme transferência para esta Conta?" )
         mbaConta1 := jpbamovi->baConta
         m_Aplic1  := jpbamovi->baAplic
         m_DtBco1  := jpbamovi->baDatBan
         RecLock()
         REPLACE jpbamovi->baConta WITH mbaConta
         RecUnlock()
         mbaConta2 := jpbamovi->baConta
         m_Aplic2  := jpbamovi->baAplic
         m_DtBco2  := jpbamovi->baDatBan
         BARecalcula( mbaConta1, m_Aplic1, m_DtBco1 )
         BARecalcula( mbaConta2, m_Aplic2, m_DtBco2 )
      ENDIF
   ENDIF
   WClose()

   RETURN

STATIC FUNCTION Filtro()

   LOCAL oElement, mReturn
   MEMVAR m_Filtro, mDataIni

   mReturn := .T.
   IF jpbamovi->baValor != 0
      FOR EACH oElement IN m_Filtro
         DO CASE
         CASE oElement $ jpbamovi->baResumo
         CASE oElement $ jpbamovi->baHist
         CASE oElement $ dtoc( jpbamovi->baDatEmi )
         CASE oElement $ dtoc( jpbamovi->baDatBan )
         CASE oElement $ jpbamovi->baConta
         CASE Val( oElement ) != 0 .AND. Val( oElement ) == Abs( jpbamovi->baValor )
         OTHERWISE
            mReturn := .F.
            EXIT
         ENDCASE
      NEXT
      IF Type( "mDataIni" ) == "D"
         IF Dtos( mDataIni ) > dtos( jpbamovi->baDatBan )
            mReturn := .F.
         ENDIF
      ENDIF
   ENDIF
   GrafProc()

   RETURN mReturn

STATIC FUNCTION NovaConta()

   LOCAL cTxt := Space(15), GetList := {}

   Mensagem( "Digite nova Conta, ESC Sai" )
   @ Row(), Col() + 2 GET cTxt PICTURE "@!"
   READ
   Mensagem()
   IF lastkey() != K_ESC
      RecAppend()
      REPLACE ;
         jpbamovi->baConta WITH cTxt, ;
         jpbamovi->baAplic WITH "N"
      RecUnlock()
   ENDIF

   RETURN NIL

STATIC FUNCTION ve_Conta

   LOCAL m_RecNo
   PARAMETERS mbaConta, m_Aplic, m_Confirma
   MEMVAR mbaConta, m_Aplic, m_Confirma

   IF pcount() < 3
      PRIVATE m_Confirma
      m_Confirma := .T.
   ENDIF
   m_RecNo := recno()
   SEEK mbaConta + m_Aplic
   IF Eof()
      IF m_Confirma
         IF ! MsgYesNo( "Conta e/ou Aplicação não cadastrada! Cadastra?" )
            GOTO m_RecNo
            RETURN .F.
         ENDIF
      ENDIF
      RecAppend()
      REPLACE ;
         jpbamovi->baConta WITH mbaConta, ;
         jpbamovi->baAplic WITH m_Aplic
      RecAppend()
      REPLACE ;
         jpbamovi->baConta  WITH mbaConta, ;
         jpbamovi->baAplic  WITH m_Aplic, ;
         jpbamovi->baDatBan WITH Stod( "29991231" ), ;
         jpbamovi->baDatEmi WITH Stod( "29991231" ), ;
         jpbamovi->baValor  WITH 0
      RecUnlock()
   ELSE
      SEEK mbaConta + m_Aplic
      SEEK mbaConta + m_Aplic + Dtos( Date() ) SOFTSEEK
      SKIP -1
   ENDIF

   RETURN .T.

STATIC FUNCTION CadLanc( m_Tipo )

   LOCAL GetList := {}, m_MinDtBco, m_Aplic, mbaConta, m_Lin, m_DtEmi, m_DtBco, m_VlEnt, m_VlSai, m_Hist, m_Resumo
   MEMVAR mDataIni, m_Alterou

   SET CURSOR ON
   WSave()
   m_Alterou  := .F.
   m_Lin      := Row()
   m_MinDtBco := Stod( "29991231" )
   mbaConta   := jpbamovi->baConta
   m_Aplic    := jpbamovi->baAplic
   mDataIni   := iif( Type( "mDataIni" ) != "D", Date() - 60, mDataIni )
   DO CASE
   CASE m_Tipo == "EXCLUSAO"
      IF MsgYesNo( "Confirma exclusão?" )
         GravaOcorrencia( ,,"Exclusao BANCARIO de " + dtoc( jpbamovi->baDatEmi ) + ", " + dtoc( jpbamovi->baDatBan ) )
         m_DtEmi := jpbamovi->baDatEmi
         m_DtBco := jpbamovi->baDatBan
         RecDelete()
         SEEK mbaConta + m_Aplic + dtos( m_DtBco ) + dtos( m_DtEmi ) SOFTSEEK
         SKIP -1
         IF mbaConta != jpbamovi->baConta .OR. m_Aplic != jpbamovi->baAplic
            SEEK mbaConta + m_Aplic SOFTSEEK
         ENDIF
         m_MinDtBco := m_DtBco
         m_Alterou  := .T.
      ENDIF
   CASE m_Tipo $ "ALTERACAO,INCLUSAO"
      DO WHILE .T.
         IF m_Tipo == "ALTERACAO"
            m_DtBco   := iif( jpbamovi->baDatBan == Stod( "29991231" ), Ctod( "" ), jpbamovi->baDatBan )
            m_DtEmi   := jpbamovi->baDatEmi
            m_Resumo  := jpbamovi->baResumo
            m_Hist    := jpbamovi->baHist
            m_VlEnt   := iif( jpbamovi->baValor < 0, 0, jpbamovi->baValor  )
            m_VlSai   := iif( jpbamovi->baValor > 0, 0, -jpbamovi->baValor )
         ELSE
            scroll( 5, 0, m_Lin, maxcol(), 1 )
            m_DtBco   := ctod("")
            m_DtEmi   := ctod("")
            m_Resumo  := EmptyValue( jpbamovi->baResumo )
            m_Hist    := EmptyValue( jpbamovi->baHist)
            m_VlEnt   := 0
            m_VlSai   := 0
         ENDIF
         wOpen( 10, 5, 20, 100, m_Tipo )
         @ 12, 12 SAY "Data do Banco"
         @ 12, 50 SAY "Data de Emissão"
         @ 13, 12 GET m_DtBco VALID OkData( @m_DtBco, mDataIni )
         @ 13, 50 GET m_DtEmi VALID OkData( @m_DtEmi, mDataIni )
         @ 15, 12 SAY "Resumo"
         @ 15, 30 SAY "Histórico"
         @ 16, 12 GET m_Resumo PICTURE "@K!" VALID ValidBancarioResumo( @m_Resumo )
         @ 16, 30 GET m_Hist PICTURE "@K!" VALID ! Empty( m_Hist )
         @ 18, 12 SAY "Entrada"
         @ 18, 50 SAY "Saída"
         @ 19, 12 GET m_VlEnt PICTURE PicVal(14,2) VALID m_VlEnt >= 0 .AND. ReturnValue( .T., iif( m_VlEnt != 0, m_VlSai := 0, NIL ) )
         @ 19, 50 GET m_VlSai PICTURE PicVal(14,2) VALID m_VlSai >= 0 WHEN m_VlEnt == 0
         Mensagem( "Digite campos, F9 Pesquisa, ESC abandona" )
         READ
         wClose()
         IF lastkey() == K_ESC
            EXIT
         ELSE
            m_DtBco = iif( Empty( m_DtBco ), Stod( "29991231" ), m_DtBco )
            IF m_Tipo == "INCLUSAO"
               IF m_Aplic != "S" .AND. m_Resumo = "APLIC"
                  ve_Conta( mbaConta, "S", .F. )
                  RecAppend()
                  REPLACE ;
                     jpbamovi->baConta   WITH mbaConta, ;
                     jpbamovi->baAplic   WITH "S", ;
                     jpbamovi->baDatBan  WITH m_DtBco, ;
                     jpbamovi->baDatEmi  WITH m_DtEmi, ;
                     jpbamovi->baResumo  WITH m_Resumo, ;
                     jpbamovi->baHist    WITH  m_Hist, ;
                     jpbamovi->baValor   WITH m_VlSai - m_VlEnt, ;
                     jpbamovi->baInfInc  WITH LogInfo()
                  RecUnlock()
                  BARecalcula( mbaConta, "S", m_DtBco )
               ENDIF
               RecAppend()
               REPLACE ;
                  jpbamovi->baConta WITH mbaConta, ;
                  jpbamovi->baAplic WITH m_Aplic, ;
                  jpbamovi->baDatBan WITH m_DtBco
               RecUnlock()
               m_Alterou  := .T.
               m_MinDtBco := iif( m_MinDtBco < m_DtBco, m_MinDtBco, m_DtBco )
            ELSE
               m_MinDtBco := iif( m_MinDtBco < jpbamovi->baDatBan, m_MinDtBco, jpbamovi->baDatBan )
            ENDIF
            RecLock()
            IF jpbamovi->baDatBan!= m_DtBco
               REPLACE jpbamovi->baDatBan WITH m_DtBco
               m_MinDtBco = iif( m_MinDtBco < jpbamovi->baDatBan, m_MinDtBco, jpbamovi->baDatBan )
               m_Alterou  := .T.
            ENDIF
            IF jpbamovi->baDatEmi != m_DtEmi
               REPLACE jpbamovi->baDatEmi WITH m_DtEmi
               m_Alterou := .T.
            ENDIF
            IF jpbamovi->baResumo != m_Resumo
               REPLACE jpbamovi->baResumo WITH m_Resumo
               m_Alterou := .T.
            ENDIF
            IF jpbamovi->baHist != m_Hist
               REPLACE jpbamovi->baHist WITH m_Hist
               m_Alterou := .T.
            ENDIF
            IF jpbamovi->baValor != ( m_VlEnt - m_VlSai )
               REPLACE jpbamovi->baValor WITH m_VlEnt - m_VlSai
               m_Alterou := .T.
            ENDIF
            IF m_Alterou
               REPLACE jpbamovi->baInfAlt WITH LogInfo()
            ENDIF
            RecUnlock()
         ENDIF
         IF m_Tipo == "ALTERACAO"
            EXIT
         ELSEIF lastkey() == 23
            KEYBOARD Chr( 205 )
            Inkey(0)
         ENDIF
      ENDDO
      IF Lastkey() == K_ESC
         KEYBOARD Chr( 205 )
         Inkey(0)
      ENDIF
   ENDCASE
   IF m_Alterou
      BARecalcula( mbaConta, m_Aplic, m_MinDtBco )
   ENDIF
   IF lastkey() == K_ESC
      KEYBOARD CHR(215)
      Inkey(0)
   ENDIF
   WRestore()

   RETURN .T.

FUNCTION RecalculoBancario()

   LOCAL m_RecNo := RecNo(), mbaConta, m_Aplic

   OrdSetFocus( "jpbamovi1" )
   GOTO TOP
   DO WHILE ! eof()
      GrafProc()
      mbaConta := jpbamovi->baConta
      m_Aplic  := jpbamovi->baAplic
      BARecalcula( mbaConta, m_Aplic, ctod(""), .T. )
      SEEK mbaConta + m_Aplic + "X" SOFTSEEK
   ENDDO
   OrdSetFocus( "jpbamovi1" )
   GOTO m_RecNo

   RETURN .T.

STATIC PROCEDURE DigFiltro

   LOCAL oElement, m_Texto, m_Posi, GetList := {}
   MEMVAR m_Filtro

   m_Texto := ""
   FOR EACH oElement IN m_Filtro
      m_Texto += oElement + " "
   NEXT
   m_Texto = Pad( m_Texto, 200 )
   scroll( 10, 0, 14, MaxCol(), 0 )
   @ 10, 0 to 14, MaxCol()
   @ 12, 1 to 12, MaxCol()-1
   @ 11, 1 SAY "Trechos de texto para filtro na apresentação dos dados"
   @ 13, 1 GET m_Texto PICTURE "@K!S75"
   READ
   IF lastkey() != K_ESC
      m_Filtro := {}
      m_Texto = Trim( m_Texto )
      DO WHILE Len( m_Texto ) != 0
         m_posi := At(" ",m_Texto+" ")
         AAdd( m_Filtro, Trim( substr( m_Texto, 1, m_posi ) ) )
         m_Texto := lTrim( substr( m_Texto, m_posi ) )
      ENDDO
      IF ! Filtro()
         GOTO TOP
      ENDIF
   ENDIF

   RETURN

STATIC PROCEDURE SomaFiltro

   LOCAL m_RecNo := RecNo(), m_SomaEnt := 0, m_SomaSai := 0

   IF ! MsgYesNo( "Confirma a soma dos valores?" )
      RETURN
   ENDIF
   GOTO TOP
   DO WHILE ! Eof()
      grafproc()
      IF ! Filtro()
         SKIP
         LOOP
      ENDIF
      IF jpbamovi->baValor > 0
         m_SomaEnt += jpbamovi->baValor
      ELSE
         m_SomaSai += jpbamovi->baValor
      ENDIF
      SKIP
   ENDDO
   GOTO m_RecNo
   MsgExclamation( "Entradas:" + LTrim( Transform( m_SomaEnt, PicVal(14,2) ) ) + " Saídas:" + LTrim( Transform( m_SomaSai, PicVal(14,2) ) ) + ;
     " Dif:" + LTrim( Transform( m_SomaEnt + m_SomaSai, PicVal(14,2) ) ) )

   RETURN

STATIC PROCEDURE DigConta

   LOCAL mbaConta := jpbamovi->baConta, m_RecNo := recno(), m_NumConta := 1, m_NomeCta := {}, nCont

   GOTO TOP
   DO WHILE ! Eof()
      AAdd( m_NomeCta, jpbamovi->baConta )
      SEEK jpbamovi->baConta + "ZZZ" SOFTSEEK
   ENDDO
   IF Len( m_NomeCta ) == 0
      GOTO m_RecNo
   ELSE
      m_NumConta := ascan( m_NomeCta, mbaConta )
      FOR nCont = 1 TO Len( m_NomeCta )
          m_NomeCta[ nCont ] := " " + Chr( 64 + nCont ) + " - " + m_NomeCta[ nCont ]
      NEXT
      WAchoice( 2, 9, m_NomeCta, @m_NumConta, "POSICIONAMENTO DE CONTA" )
      mbaConta = Substr( m_NomeCta[ m_NumConta ], 6 )
      SEEK mbaConta + "N" + Dtos( Date() ) SOFTSEEK
      SKIP -1
   ENDIF

   RETURN

STATIC FUNCTION pBancoLancaLocaliza()

   LOCAL nCont, GetList := {}, m_RecNo := RecNo(), m_Struct, m_Sai
   THREAD STATIC m_Texto := " "

   wOpen( 5, 5, 10, MaxCol() - 1, "Texto a localizar" )
   m_Texto := pad( m_Texto, 50 )
   // WSave( maxrow()-1, 0, maxrow(), maxcol() )
   // mensagem( "Digite texto para localização afrente, ESC sai" )
   SET CURSOR ON
   @ 7, 7 GET m_Texto PICTURE "@K!"
   READ
   SET CURSOR OFF
   wClose()
   mensagem()
   IF lastkey() != K_ESC
      Mensagem( "Aguarde... localizando texto afrente... ESC interrompe" )
      m_Texto = Trim(m_Texto)
      IF ! eof()
         SKIP
      ENDIF
      m_Struct := dbstruct()
      m_Sai    := .F.
      DO WHILE ! m_Sai .AND. ! eof()
         grafproc()
         FOR nCont = 1 TO fcount()
            m_Sai = ( Inkey() == K_ESC )
            DO CASE
            CASE m_Sai
            CASE m_Struct[ nCont, 2 ] == "N" ; m_Sai = ( m_Texto $ Str( FieldGet( nCont ) ) )
            CASE m_Struct[ nCont, 2 ] == "D" ; m_Sai = ( m_Texto $ Dtoc( FieldGet( nCont ) ) )
            CASE m_Struct[ nCont, 2 ] $ "CM" ; m_Sai = ( m_Texto $ Upper( FieldGet( nCont ) ) )
            OTHERWISE                        ; m_Sai = ( m_Texto $ Transform( FieldGet( nCont ), "" ) )
            ENDCASE
            IF m_Sai
               EXIT
            ENDIF
         NEXT
         IF m_Sai
            EXIT
         ENDIF
         SKIP
      ENDDO
      IF Eof()
         MsgWarning( "Nada foi localizado afrente!" )
         GOTO m_RecNo
      ENDIF
   ENDIF
   KEYBOARD Chr( 205 )
   Inkey(0)

   RETURN NIL

STATIC FUNCTION BARecalcula( mbaConta, m_Aplic, m_DataIni, m_RecGeral )

   LOCAL m_RecNo := recno(), m_Saldo, m_DtBco, m_DtEmi, cOrdSetFocus
   MEMVAR mRecalcAuto, m_Prog

   hb_Default( @m_RecGeral, .F. )
   IF ! mRecalcAuto .AND. ! m_RecGeral
      RETURN NIL
   ENDIF

   IF Val( Dtos( m_DataIni ) ) != 0
      m_DataIni := m_DataIni -1
   ENDIF
   mensagem( "Aguarde, Recalculando Conta " + Trim( jpbamovi->baConta ) + "..." )
   SET FILTER TO
   cOrdSetFocus := OrdSetFocus( "jpbamovi1" )
   SEEK mbaConta + m_Aplic + dtos( m_DataIni ) SOFTSEEK
   SKIP -1
   IF jpbamovi->baConta != mbaConta .OR. jpbamovi->baAplic != m_Aplic .OR. bof()
      SEEK mbaConta + m_Aplic
      IF jpbamovi->baSaldo != jpbamovi->baValor
         RecLock()
         REPLACE ;
            jpbamovi->baSaldo WITH jpbamovi->baValor, ;
            jpbamovi->baImpSld WITH  "S"
         RecUnlock()
      ENDIF
   ENDIF
   IF ( jpbamovi->baConta != mbaConta .OR. jpbamovi->baAplic != m_Aplic )
      OrdSetFocus( cOrdSetFocus )
      RETURN .F.
   ENDIF
   m_Saldo = jpbamovi->baSaldo
   SKIP
   DO WHILE jpbamovi->baConta == mbaConta .AND. jpbamovi->baAplic == m_Aplic .AND. ! eof()
      GrafProc()
      m_Saldo += jpbamovi->baValor
      IF jpbamovi->baSaldo == m_Saldo .AND. m_Saldo != 0 .AND. ! m_RecGeral
         // Alterada logica o primeiro-1 ao inves do segundo+1
         IF Dtos( jpbamovi->baDatBan - 1 ) > Dtos( m_dataini ) .AND. Dtos( jpbamovi->baDatEmi - 1 ) > Dtos( m_DataIni )
            EXIT
         ENDIF
      ENDIF
      RecLock()
      REPLACE jpbamovi->baSaldo WITH m_Saldo
      RecUnlock()
      SKIP
   ENDDO
   SKIP -1
   IF jpbamovi->baConta == mbaConta .AND. jpbamovi->baAplic == m_Aplic
      RecLock()
      REPLACE jpbamovi->baImpSld WITH "S"
      RecUnlock()
      SKIP -1
   ENDIF
   m_DtBco = ctod("")
   m_DtEmi = ctod("")
   * Alterado DO WHILE para DtBco ao invez de m_DtBco
   DO WHILE jpbamovi->baConta == mbaConta .AND. jpbamovi->baAplic == m_Aplic .AND. dtos( jpbamovi->baDatBan ) > dtos( m_DataIni ) .AND. ! bof()
      GrafProc()
      IF jpbamovi->baDatBan != m_DtBco
         IF jpbamovi->baImpSld != "S"
            RecLock()
            REPLACE jpbamovi->baImpSld WITH "S"
            RecUnlock()
         ENDIF
      ELSEIF jpbamovi->baDatBan == Stod( "29991231" ) .AND. jpbamovi->baDatEmi != m_DtEmi
         IF jpbamovi->baImpSld != "S"
            RecLock()
            REPLACE jpbamovi->baImpSld WITH "S"
            RecUnlock()
         ENDIF
      ELSEIF jpbamovi->baImpSld == "S"
         RecLock()
         REPLACE jpbamovi->baImpSld WITH "N"
         RecUnlock()
      ENDIF
      m_DtBco := jpbamovi->baDatBan
      m_DtEmi := jpbamovi->baDatEmi
      SKIP -1
   ENDDO
   OrdSetFocus( cOrdSetFocus )
   GOTO m_RecNo
   IF deleted()
      SKIP
   ENDIF
   IF m_Prog == "PBANCOLANCA"
      SET FILTER TO Filtro()
      IF ! Filtro()
         SKIP -1
      ENDIF
   ENDIF

   RETURN .T.

STATIC FUNCTION OpcExtras()

   LOCAL acMenuTxt, nOpc
   MEMVAR mRecalcAuto

   acMenuTxt := {}
   AAdd( acMenuTxt, "Nova Conta" )
   AAdd( acMenuTxt, "Desliga Recálculo" )
   AAdd( acMenuTxt, "Soma Lançamentos" )
   nOpc := 1
   WAchoice( 5, 20, acMenuTxt, @nOpc )
   DO CASE
   CASE LastKey() == K_ESC .OR. nOpc == 0
      RETURN NIL
   CASE nOpc == 1
      NovaConta()
   CASE nOpc == 2
      mRecalcAuto := .F.
   CASE nOpc == 3
      DO SomaFiltro
   ENDCASE

   RETURN NIL

STATIC FUNCTION OkData( dData, dDataInicial )

   IF Empty( dData ) .OR. dData > dDataInicial
      RETURN .T.
   ENDIF

   RETURN MsgYesNo( "Data menor que limite! Aceita?" )

FUNCTION ValidBancarioConta( cConta )

   LOCAL lOk := .T.

   IF ! Encontra( cConta, "jpbamovi" )
      MsgWarning( "Conta bancária não cadastrada no movimento atual" )
      lOk := .F.
   ENDIF

   RETURN lOk
