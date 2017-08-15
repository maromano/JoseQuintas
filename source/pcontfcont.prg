/*
PCONTFCONT - SPED FCONT
2011.10 José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#define SEPARADOR "|"

PROCEDURE pContFcont

   LOCAL GetList := {}, mErro
   MEMVAR mTotais, mNumMes, mFechaAtu, mFechaAnt, mNumMesIni, mNumMesFim, mDatIni, mDatFim, mRefIni, mRefFim, mQualiPJ, mFormTribut, nKey, mFileSped

   IF ! AbreArquivos( "jprefcta", "jpempre", "jpcidade", "jptabel", "ctplano", "ctlotes", "ctdiari" )
      RETURN
   ENDIF
   SELECT ctdiari

   mFileSped := "EXPORTA\SPEDFCONT"

   mRefIni     := CToD( "01/01/" + StrZero( Year( Date() ) - 1, 4 ) )
   mRefFim     := CToD( "31/12/" + StrZero( Year( Date() ) - 1, 4 ) )
   mQualiPj    := "10"
   mFormTribut := "1"
   @ 4, 5 SAY ""
   @ Row() + 1, 5 SAY "Data Inicial:" GET mRefIni
   @ Row() + 1, 5 SAY "Data Final..:" GET mRefFim
   // @ Row()+1, 5 SAY "Tipo PJ.....:" GET mQualiPj PICTURE "99" VALID mQualiPj $ "00,10,20"
   // @ Row(), Col()+2 SAY "00=Seguradora,Capitalização ou Previdência, 10=PJ em Geral, 20=Financeira"
   // @ Row()+1, 5 SAY "Tributação..:" GET mFormTribut PICTURE "9" VALID mFormTribut $ "1234"
   // @ Row(), Col()+2 SAY "1=Real, 2=Real Arbitrado, 3=Real Presumido, 4=Real Presumido Arbitrado (Trim)"
   Mensagem( "Digite campos, ESC Sai" )
   READ
   Mensagem()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   IF ! MsgYesNo( "Confirma geração" )
      RETURN
   ENDIF

   FErase( mFileSped )

   IF Day( mRefIni ) <> 1 .OR. Day( mRefFim ) <> Day( UltDia( mRefFim ) ) .OR. Year( mRefIni ) <> Year( mRefFim )
      MsgWarning( "Máximo um ano, e data final como último dia do ano" )
      RETURN
   ENDIF

   mNumMesIni := ( Year( mRefIni ) - jpempre->emAnoBase ) * 12 + Month( mRefIni )
   mNumMesFim := ( Year( mRefFim ) - jpempre->emAnoBase ) * 12 + Month( mRefFim )

   IF mNumMesIni < 1 .OR. mNumMesFim > 96
      MsgWarning( "Período selecionado não existe" )
      RETURN
   ENDIF

   mErro := .F.

   IF ! ValidCnpjCpf( jpempre->emCpfTit )
      SayScroll( "CPF Inválido do Titular" )
      mErro := .T.
   ENDIF
   IF ! ValidCnpjCpf( jpempre->emCpfCon )
      SayScroll( "CPF Inválido do Contador" )
      mErro := .T.
   ENDIF
   IF ! Encontra( AUX_QUAASS + jpempre->emQuaTit, "jptabel", "numlan" )
      SayScroll( "Qualificação do titular, no cadastro da empresa, inválido" )
      mErro := .T.
   ENDIF
   IF ! Encontra( AUX_QUAASS + jpempre->emQuaCon, "jptabel", "numlan" )
      SayScroll( "Qualificação do contador, no cadastro da empresa, inválido" )
      mErro := .T.
   ENDIF
   IF Empty( jpempre->emUfCrc )
      SayScroll( "UF em branco ref CRC do Contador" )
      mErro := .T.
   ENDIF
   IF Val( jpempre->emCrcCon ) = 0
      SayScroll( "CRC Do Contador não informado" )
      mErro := .T.
   ENDIF
   SayScroll( "Verificando plano de contas" )
   SELECT ctplano
   GOTO TOP
   DO WHILE ! Eof()
      IF ctplano->a_Grau < 4 .AND. ctplano->a_Tipo == "A"
         SayScroll( "Conta analítica de nível menor que 4 -> " + PicConta( ctplano->a_Codigo ) + ":" + ctplano->a_Nome )
         mErro := .T.
      ENDIF
      SKIP
   ENDDO

   IF mErro
      MsgWarning( "Será gerado como teste devido aos erros acima" )
   ENDIF

   SELECT ctplano
   SayScroll( "Início da geração do Sped Contábil" )
   mTotais := {}

   SET ALTERNATE TO ( mFileSped )
   SET ALTERNATE ON
   SET CONSOLE OFF

   nKey := 0
   Sped0000()
   Sped0001()
   Sped0150()
   Sped0990()

   SpedI001()
   SayScroll( "Plano de Contas" )
   SpedI050() // Plano de Contas // Este Chama 051 e 052

   mDatIni := mDatFim := CToD( "" )
   mFechaAtu := 0
   mFechaAnt := 0
   SayScroll( "Saldos Periódicos" )
   FOR mNumMes = mNumMesIni TO mNumMesFim
      SetaContabil( mNumMes, @mDatIni, @mDatFim, @mFechaAtu, @mFechaAnt )
      IF mNumMes == mFechaAtu
         SpedI150() // Saldos periodicos (Chama o SpedI155)
      ENDIF
   NEXT

   SayScroll( "Saldos antes do encerramento" )
   FOR mNumMes = mNumMesIni TO mNumMesFim
      SetaContabil( mNumMes, @mDatIni, @mDatFim, @mFechaAtu, @mFechaAnt )
      IF mNumMes == mFechaAtu
         // So Usa a data final, senao teria que alterar a inicial
         SpedI350() // Saldos antes do encerramento (chama o I355)
      ENDIF
   NEXT

   SpedI990()
   SpedJ001()
   SpedJ930()
   SpedJ990()

   SpedM001()
   SpedM020()
   SpedM025()
   SpedM030()
   SpedM990()

   Sped9001()
   Sped9900()
   Sped9990()
   Sped9999()

   SayScroll( "Ajustando informacao de total" )
   SET CONSOLE ON
   SET ALTERNATE OFF
   SET ALTERNATE TO
   fDelEof( mFileSped )
   SayScroll( "Fim da Geração" )
   MsgExclamation( "Gerado arquivo " + mFileSped )

   RETURN

// Abertura do arquivo digital e identificacao do empresario/empresa
STATIC FUNCTION Sped0000()

   MEMVAR mRefIni, mRefFim

   Acumula( "0000" )
   ?? SEPARADOR
   ?? "0000" + SEPARADOR // REG
   ?? "LALU" + SEPARADOR //
   ?? FormatoData( mRefIni ) + SEPARADOR // DT_INI
   ?? FormatoData( mRefFim ) + SEPARADOR // DT_FIN
   ?? Trim( jpempre->emNome ) + SEPARADOR // NOME
   ?? SoNumeros( jpempre->emCnpj ) + SEPARADOR // CNPJ
   ?? jpempre->emUf + SEPARADOR // UF
   ?? jpempre->emInsEst + SEPARADOR // IE
   ?? CidadeIbge( jpempre->emCidade, jpempre->emUf ) + SEPARADOR // COD_MUN
   ?? "" + SEPARADOR // Opcional - Inscricao Municipal // IM
   ?? "" + SEPARADOR // Opcional - Indicador de Situacao Especial // IND_SIT_ESP
   ?? "0" + SEPARADOR // Indicador de inicio de periodo 1=inicio do ano
   ?? hb_eol()

   RETURN NIL

// Abertura do bloco 0
STATIC FUNCTION Sped0001()

   IF .F.
      Acumula( "0001" )
      ?? SEPARADOR
      ?? "0001" + SEPARADOR // REG
      ?? "0" + SEPARADOR // 0=Tem movimento no bloco // IND_DAD
      ?? hb_eol()
   ENDIF

   RETURN NIL

// Tabela de cadastro do participante
STATIC FUNCTION Sped0150()

   IF .F.
      Acumula( "0150" )
      ?? SEPARADOR
      ?? "0150" + SEPARADOR
      ?? "001" + SEPARADOR // Cod. Identificacao do Participante
      ?? Trim( jpempre->emNome ) + SEPARADOR // Nome do Participante
      ?? "01058" + SEPARADOR // Codigo do Pais
      ?? SoNumeros( jpempre->emCnpj ) + SEPARADOR // Cnpj participante
      ?? "" + SEPARADOR // CPF do Participante
      ?? "" + SEPARADOR // Numero Id. Trabalhador (Pis, Pasep, SUS)
      ?? jpempre->emUf + SEPARADOR
      ?? jpempre->emInsEst + SEPARADOR // Inscricao Estadual
      ?? "" + SEPARADOR // IE do Participante como Substituto
      ?? CidadeIbge( jpempre->emCidade, jpempre->emUf ) + SEPARADOR
      ?? "" + SEPARADOR // Inscr. Municipal
      ?? "" + SEPARADOR // Suframa
      ?? hb_eol()
   ENDIF

   RETURN NIL

// Encerramento do bloco 0
STATIC FUNCTION Sped0990()

   Acumula( "0990" )
   ?? SEPARADOR
   ?? "0990" + SEPARADOR // REG
   ?? Totais( "0" ) + SEPARADOR // Qtde. total de bloco 0 // QTD_LIN_0
   ?? hb_eol()

   RETURN NIL

// Abertura do bloco I
STATIC FUNCTION SpedI001()

   Acumula( "I001" )
   ?? SEPARADOR
   ?? "I001" + SEPARADOR // REG
   ?? "0" + SEPARADOR // 0=Tem movimento no bloco // IND_DAD
   ?? hb_eol()

   RETURN NIL

// Plano de Contas
STATIC FUNCTION SpedI050()

   LOCAL nAtual, nTotal, nKey
   MEMVAR mRefIni, mContas

   SELECT ctplano
   GOTO TOP
   DECLARE mContas[ 20 ]
   AFill( mContas, "" )
   nAtual := 0
   nTotal := LastRec()
   GrafTempo( "I050 Plano de Contas" )
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey := Inkey()
      GrafTempo( nAtual, nTotal )
      nAtual += 1
      IF Empty( ctplano->a_Codigo )
         SKIP
         LOOP
      ENDIF
      Acumula( "I050" )
      ?? SEPARADOR
      ?? "I050" + SEPARADOR // REG
      ?? FormatoData( mRefIni ) + SEPARADOR // Inclusão/Alteração // DT_ALT
      ?? "0" + SubStr( "1234", At( ctplano->a_Grupo, "APLR" ), 1 ) + SEPARADOR // Natureza // COD_NAT
      ?? ctplano->a_Tipo + SEPARADOR // Analítica/Sintética // IND_CTA
      ?? LTrim( Str( ctplano->a_Grau ) ) + SEPARADOR // Nivel da conta // NIVEL
      ?? Trim( PicConta( ctplano->a_Codigo ) ) + SEPARADOR // Codigo da conta // COD_CTA
      IF ctplano->a_Grau == 1
         ?? "" + SEPARADOR // Codigo da conta superior // COD_CTA_SUP
      ELSE
         ?? Trim( PicConta( mContas[ ctplano->a_Grau - 1 ] ) ) + SEPARADOR // Codigo da conta superior
      ENDIF
      ?? Trim( ctplano->a_Nome ) + SEPARADOR // Nome da conta // CTA
      ?? hb_eol()
      SpedI051() // Plano de Contas Referencial
      mContas[ ctplano->a_Grau ] := ctplano->a_Codigo
      SKIP
   ENDDO

   RETURN NIL

// Plano de contas referencial
STATIC FUNCTION SpedI051()

   IF ! Empty( ctplano->plCtaSrf )
      Acumula( "I051" )
      ?? SEPARADOR
      ?? "I051" + SEPARADOR                    // REG
      ?? "10" + SEPARADOR                      // Fazenda Nacional // COD_ENT_REF
      ?? "" + SEPARADOR // Centro de Custo     // COD_CCUS
      ?? Trim( ctplano->plCtaSrf ) + SEPARADOR // COD_CTA_REF
      ?? hb_eol()
   ENDIF

   RETURN NIL

// Saldos Periodicos - identificacao do periodo
STATIC FUNCTION SpedI150()

   MEMVAR mDatIni, mDatFim

   Acumula( "I150" )
   ?? SEPARADOR
   ?? "I150" + SEPARADOR // REG
   ?? FormatoData( mDatIni ) + SEPARADOR // DT_INI
   ?? FormatoData( mDatFim ) + SEPARADOR // DT_FIN
   ?? hb_eol()
   SpedI155()

   RETURN NIL

// Detalhe dos saldos periodicos
STATIC FUNCTION SpedI155()

   LOCAL mCont, mTotDeb, mTotCre, nAtual, nTotal, mCreMes, mDebMes, mSaldoFim, mSaldoAnt, /* mSaldo, */ nKey
   MEMVAR mNumMes

   SELECT ctplano
   GOTO TOP
   nAtual := 0
   nTotal := LastRec()
   GrafTempo( "I155 Saldos" )
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey := Inkey()
      GrafTempo( nAtual, nTotal )
      nAtual += 1
      IF ctplano->a_Tipo != "A"
         SKIP
         LOOP
      ENDIF
      IF ctplano->a_Grupo == "R"
         SKIP
         LOOP
      ENDIF
      mSaldoAnt := mTotDeb := mTotCre := mDebMes := mCreMes := 0
      /* mSaldo := */ SaldoConta( @mSaldoAnt, 0, 0, ( mNumMes - jpempre->emFecha + 1 ), .T. ) // saldo inicial do periodo
      FOR mCont = ( mNumMes - jpempre->emFecha + 1 ) TO mNumMes
         /* mSaldo := */ SaldoConta( 0, @mDebMes, @mCreMes, mCont, .T. )
         mTotDeb := Val( Str( mTotDeb + mDebMes, 16, 2 ) )
         mTotCre := Val( Str( mTotCre + mCreMes, 16, 2 ) )
      NEXT
      mSaldoFim := SaldoConta( 0, 0, 0, mNumMes, .T. )
      // IF mSaldoAnt == 0 .AND. mDebMes == 0 .AND. mCreMes == 0
      // SKIP
      // LOOP
      // ENDIF
      Acumula( "I155" )
      ?? SEPARADOR
      ?? "I155" + SEPARADOR // REG
      ?? Trim( PicConta( ctplano->a_Codigo ) ) + SEPARADOR // COD_CTA
      ?? "" + SEPARADOR // COD_CCUS
      ?? FormatoValor( Abs( mSaldoAnt ) ) + SEPARADOR // Saldo Inicial // VL_SLD_INI
      ?? iif( mSaldoAnt < 0, "C", "D" ) + SEPARADOR // Saldo Inicial deb/cred // IND_DC_INI
      ?? FormatoValor( mTotDeb ) + SEPARADOR // Movimentacao debito // VL_DEB
      ?? FormatoValor( mTotCre ) + SEPARADOR // Movimentacao credito // VL_CRED
      ?? FormatoValor( Abs( mSaldoFim ) ) + SEPARADOR // Saldo Final // VL_SLD_FIN
      ?? iif( mSaldoFim < 0, "C", "D" ) + SEPARADOR // Saldo Final deb/cred // IND_DC_FIN
      ?? hb_eol()
      SKIP
   ENDDO

   RETURN NIL

// Saldos das contas de resultado antes do encerramento - id da data
STATIC FUNCTION SpedI350()

   MEMVAR mDatFim

   Acumula( "I350" )
   ?? SEPARADOR
   ?? "I350" + SEPARADOR // REG
   ?? FormatoData( mDatFim ) + SEPARADOR // DT_RES
   ?? hb_eol()
   SpedI355() // Saldos antes do encerramento

   RETURN NIL

// Detalhe dos saldos das contas de resultado antes do encerramento
STATIC FUNCTION SpedI355()

   LOCAL mCont, mSaldo, nAtual, nTotal, /* mTotDeb, mTotCre, */ mTotAnt, mMovDeb, mMovCre, nKey
   MEMVAR mNumMes

   SELECT ctplano
   GOTO TOP
   GrafTempo( "I355 Saldos antes do encerramento" )
   nAtual := 0
   nTotal := LastRec()
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey := Inkey()
      GrafTempo( nAtual, nTotal )
      nAtual += 1
      IF ctplano->a_Tipo != "A" .OR. ctplano->a_Grupo != "R"
         SKIP
         LOOP
      ENDIF
      /* mTotDeb := mTotCre := */ mTotAnt := 0
      mMovDeb := mMovCre := 0
      mSaldo := SaldoConta( mTotAnt, 0, 0, ( mNumMes - jpempre->emFecha + 1 ) )
      FOR mCont = ( mNumMes - jpempre->emFecha + 1 ) TO mNumMes
         mSaldo := SaldoConta( 0, @mMovDeb, @mMovCre, mCont )
         // mTotDeb += mMovDeb
         // mTotCre += mMovCre
      NEXT
      // IF mSaldo == 0
      // SKIP
      // LOOP
      // ENDIF
      Acumula( "I355" )
      ?? SEPARADOR
      ?? "I355" + SEPARADOR // REG
      ?? Trim( PicConta( ctplano->a_Codigo ) ) + SEPARADOR // Conta // COD_CTA
      ?? "" + SEPARADOR // CCusto // COD_CCUS
      ?? FormatoValor( Abs( mSaldo ) ) + SEPARADOR // Saldo antes do encerramento // VL_CTA
      ?? iif( mSaldo < 0, "C", "D" ) + SEPARADOR // Debito ou Credito do saldo // IND_DC
      ?? hb_eol()
      SKIP
   ENDDO

   RETURN NIL

// Encerramento do bloco I
STATIC FUNCTION SpedI990()

   Acumula( "I990" )
   ?? SEPARADOR
   ?? "I990" + SEPARADOR // REG
   ?? Totais( "I" ) + SEPARADOR // Qtde linhas no bloco I // QTD_LIN_I
   ?? hb_eol()

   RETURN NIL

// Abertura do bloco J
STATIC FUNCTION SpedJ001()

   Acumula( "J001" )
   ?? SEPARADOR
   ?? "J001" + SEPARADOR // REG
   ?? "0" + SEPARADOR // 0=Tem informacoes no J // IND_DAD
   ?? hb_eol()

   RETURN NIL

// Identificacao dos signatarios da escrituracao
STATIC FUNCTION SpedJ930()

   Acumula( "J930" )
   ?? SEPARADOR
   ?? "J930" + SEPARADOR                               // REG
   ?? Trim( jpempre->emTitular ) + SEPARADOR           // IDENT_NOM
   ?? SoNumeros( jpempre->emCpfTit ) + SEPARADOR       // CPF do titular // IDENT_CPF
   ?? Trim( jpempre->emCarTit ) + SEPARADOR            // Cargo // IDENT_QUALIF
   ?? jpempre->emQuaTit + SEPARADOR                    // Codigo da qualificacao conf. DNRC // COD_ASSIN
   ?? "" + SEPARADOR                                   // CRC do contador // IND_CRC
   ?? hb_eol()

   Acumula( "J930" )
   ?? SEPARADOR
   ?? "J930" + SEPARADOR                               // REG
   ?? Trim( jpempre->emContador ) + SEPARADOR          // IDENT_NOM
   ?? SoNumeros( jpempre->emCpfCon ) + SEPARADOR       // CPF do contador // IDENT_CPF
   ?? Trim( jpempre->emCarCon ) + SEPARADOR            // Cargo contador // IDENT_QUALIF
   ?? jpempre->emQuaCon + SEPARADOR                    // Cod. Qualificacao conf. DNRC // COD_ASSIN
   ?? jpempre->emUFCrc + jpempre->emCrcCon + SEPARADOR // CRC Contador // IND_CRC
   ?? hb_eol()

   RETURN NIL

// Encerramento do bloco J
STATIC FUNCTION SpedJ990()

   Acumula( "J990" )
   ?? SEPARADOR
   ?? "J990" + SEPARADOR // REG
   ?? Totais( "J" ) + SEPARADOR // Qtde linhas no bloco J // QTD_LIN_J
   ?? hb_eol()

   RETURN NIL

STATIC FUNCTION SpedM001()

   Acumula( "M001" )
   ?? SEPARADOR
   ?? "M001" + SEPARADOR // REG
   ?? "0" + SEPARADOR // IND_DAD 0=com inf 1=sem inf
   ?? hb_eol()

   RETURN NIL

STATIC FUNCTION SpedM990()

   ?? SEPARADOR
   ?? "M990" + SEPARADOR // REG
   ?? Totais( "M" ) + SEPARADOR // Qtde M
   ?? hb_eol()

   RETURN NIL

STATIC FUNCTION SpedM020()

   Acumula( "M020" )
   ?? SEPARADOR
   ?? "M020" + SEPARADOR // REG
   ?? "10" + SEPARADOR // QUALI_PJ  10=PJ em geral
   ?? "0" + SEPARADOR // TIPO_ESCRIT 0=original 1=retificadora
   ?? SEPARADOR // NRO_REC_ANTERIOR Numero do recibo anterior
   ?? SEPARADOR // ID_ESCR_PER_ANT Calculado pelo sistema
   ?? "I" + SEPARADOR // SIT_SLD_PER_ANT I=Importado
   ?? "1" + SEPARADOR // IND_LCTO_INI_SLD 1=Saldos iniciais podem ser ajustados
   ?? iif( jpempre->emFecha == 12, "A", "T" ) + SEPARADOR // FORM_APUR A=Anual T=Trimestral
   ?? "1" + SEPARADOR // FORM_TRIBUT 1=Real 2=Real Arbritrado trimestral, 3=Real Presumido Trim, 4=Real Presum.Arbitr.Trim
   ?? "    " + SEPARADOR // TRIM_LUC_ARB Trimestre de lucro arbritado 0=nao 1=sim
   IF jpempre->emFecha == 3
      ?? "1111" + SEPARADOR // FORM_TRIB_TRI 0=fora do periodo 1=real 2=arbitrado 3=presumido 4=inativo
   ELSE
      ?? "    " + SEPARADOR // se anual, nao tem isso
   ENDIF
   ?? hb_eol()

   RETURN NIL

STATIC FUNCTION SpedM025()

   LOCAL /* mSaldo, */ mSaldoAnterior, nAtual, nTotal, nKey
   MEMVAR mNumMesIni

   SELECT ctplano
   GOTO TOP
   GrafTempo( "M025 Saldos Iniciais das contas patrimoniais" )
   nAtual := 0
   nTotal := LastRec()
   DO WHILE nKey != K_ESC .AND. ! Eof()
      nKey := Inkey()
      GrafTempo( nAtual, nTotal )
      nAtual += 1
      IF ctplano->a_Tipo != "A" .OR. ! ctplano->a_Grupo $ "AP"
         SKIP
         LOOP
      ENDIF
      mSaldoAnterior := 0
      /* mSaldo := */ SaldoConta( @mSaldoAnterior, 0, 0, mNumMesIni, .F. ) // Pra pegar saldo anterior
      // IF mSaldo == 0
      // SKIP
      // LOOP
      // ENDIF
      Acumula( "M025" )
      ?? SEPARADOR
      ?? "M025" + SEPARADOR // REG
      ?? Trim( PicConta( ctplano->a_Codigo ) ) + SEPARADOR // COD_CTA
      ?? "" + SEPARADOR // COD_CCUS
      ?? Trim( ctplano->plCtaSrf ) + SEPARADOR // COD_CTA_REF
      ?? FormatoValor( Abs( mSaldoAnterior ), 19, 2 ) + SEPARADOR // VL_SLD_FIN_FC
      ?? iif( mSaldoAnterior < 0, "C", "D" ) + SEPARADOR // IND_DC_FIN_FC
      ?? FormatoValor( Abs( mSaldoAnterior ), 19, 2 ) + SEPARADOR // VL_SLD_FIN_SOC
      ?? iif( mSaldoAnterior < 0, "C", "D" ) + SEPARADOR // IND_DC_FIN_SOC
      ?? hb_eol()
      SKIP
   ENDDO

   RETURN NIL

STATIC FUNCTION SpedM030()

   LOCAL nCont, mValLuc
   MEMVAR mNumMes

   Encontra( CodContabil( jpempre->emResAcu ), "ctplano", "ctplano1" ) // estava codacu
   FOR nCont = jpempre->emFecha TO 12 STEP jpempre->emFecha
      mValLuc := SaldoConta( 0, 0, 0, mNumMes, .T. )
      Acumula( "M030" )
      ?? SEPARADOR
      ?? "M030" + SEPARADOR // REG
      ?? iif( jpempre->emFecha == 12, "A00", "T" + StrZero( nCont / jpempre->emFecha, 2 ) ) + SEPARADOR // IND_PER A00=Anual, T0n=Trimestres 1 a 4
      ?? FormatoValor( Abs( mValLuc ), 2 ) + SEPARADOR // VL_LUC_LIQ Resultado do periodo
      ?? iif( mValLuc < 0, "C", "D" ) + SEPARADOR // IND_LUC_LIQ Debito/Credito
      ?? hb_eol()
   NEXT

   RETURN NIL

// Abertura do bloco 9
STATIC FUNCTION Sped9001()

   Acumula( "9001" )
   ?? SEPARADOR
   ?? "9001" + SEPARADOR // REG
   ?? "0" + SEPARADOR // 0=bloco com dados // IND_DAD
   ?? hb_eol()

   RETURN NIL

// Registros do arquivo
STATIC FUNCTION Sped9900()

   LOCAL mCont
   MEMVAR mTotais

   Acumula( "9990" )
   Acumula( "9999" )
   FOR mCont = 1 TO Len( mTotais )
      Acumula( "9900" )
      ?? SEPARADOR
      ?? "9900" + SEPARADOR // REG
      ?? mTotais[ mCont, 1 ] + SEPARADOR // Registro que sera totalizado // NAOESPECIFICADO
      ?? LTrim( Str( mTotais[ mCont, 2 ] ) ) + SEPARADOR // Total de registros do codigo acima // QTD_LIN_9
      ?? hb_eol()
   NEXT

   RETURN NIL

// Encerramento do bloco 9
STATIC FUNCTION Sped9990()

   // Ja somado Acumula( "9990" )
   ?? SEPARADOR
   ?? "9990" + SEPARADOR // REG
   ?? Totais( "9" ) + SEPARADOR // Qtde de linhas do bloco 9 // QTD_LIN
   ?? hb_eol()

   RETURN NIL

// Encerramento do arquivo digital
STATIC FUNCTION Sped9999()

   // Ja somado Acumula( "9999" )
   ?? SEPARADOR
   ?? "9999" + SEPARADOR
   ?? Totais() + SEPARADOR // Qtde de linhas total
   ?? hb_eol()

   RETURN NIL

STATIC FUNCTION Acumula( cNumero )

   LOCAL mPosicao, mCont
   MEMVAR mTotais

   mPosicao := 0
   FOR mCont = 1 TO Len( mTotais )
      IF mTotais[ mCont, 1 ] == cNumero
         mPosicao := mCont
      ENDIF
   NEXT
   IF mPosicao == 0
      AAdd( mTotais, { cNumero, 0 } )
      mPosicao := Len( mTotais )
   ENDIF
   mTotais[ mPosicao, 2 ] += 1

   RETURN NIL

STATIC FUNCTION Totais( cNumero )

   LOCAL mTotal, mCont
   MEMVAR mTotais

   mTotal := 0
   hb_Default( @cNumero, "T" )
   FOR mCont = 1 TO Len( mTotais )
      IF cNumero == "T" .OR. cNumero == SubStr( mTotais[ mCont, 1 ], 1, 1 )
         mTotal := mTotal + mTotais[ mCont, 2 ]
      ENDIF
   NEXT

   RETURN LTrim( Str( mTotal ) )

STATIC FUNCTION FormatoData( mData )

   RETURN hb_Dtoc( mData, "DDMMYYYY" )

STATIC FUNCTION FormatoValor( mValor )

   LOCAL cTexto

   cTexto := LTrim( Transform( mValor, "@E 999999999999.99" ) )

   RETURN cTexto

STATIC FUNCTION SetaContabil( mNumMes, mDatIni, mDatFim, mFechaAtu, mFechaAnt )

   LOCAL mMes, mAno

   mMes := mNumMes
   mAno := jpempre->emAnoBase
   DO WHILE mMes > 12
      mMes := mMes - 12
      mAno += 1
   ENDDO
   mDatIni := CToD( "01/" + StrZero( mMes, 2 ) + "/" + StrZero( mAno, 4 ) )
   mDatFim := UltDia( mDatIni )
   mDatIni := CToD( "01/" + StrZero( mMes - jpempre->emFecha + 1, 2 ) + "/" + Str( mAno, 4 ) )
   mFechaAnt := Int( ( mNumMes - 1 ) / jpempre->emFecha ) * jpempre->emFecha
   mFechaAtu := mFechaAnt + jpempre->emFecha

   RETURN NIL

STATIC FUNCTION SaldoConta( mSaldoAnt, mDebMes, mCreMes, mNumMes, mFechado )

   LOCAL mCont, mMovMes, mFechaAnt, mFechaAtu, mSaldoAtual, cCont

   hb_Default( @mFechado, .F. )

   mFechaAnt := Int( ( mNumMes - 1 ) / jpempre->emFecha ) * jpempre->emFecha
   mFechaAtu := mFechaAnt + jpempre->emFecha

   // Parte Generica para saldos anteriores
   mSaldoAnt := ctplano->a_SdAnt
   mDebMes := 0
   mCreMes := 0
   FOR mCont = 1 TO mNumMes
      cCont := StrZero( mCont, 2 )
      IF mCont < mNumMes
         IF ctplano->a_Grupo == "R" .AND. mCont <= mFechaAnt
            mSaldoAnt := 0
         ELSE
            mSaldoAnt := mSaldoAnt + &( "ctplano->a_Deb" + cCont ) - &( "ctplano->a_Cre" + cCont )
         ENDIF
      ELSE
         mDebMes := &( "ctplano->a_Deb" + cCont )
         mCreMes := &( "ctplano->a_Cre" + cCont )
      ENDIF
   NEXT
   // Verifica se mes atual de fechamento
   IF ctplano->a_Grupo == "R" .AND. mNumMes == mFechaAtu .AND. mFechado
      mSaldoAtual := mSaldoAnt + mDebMes - mCreMes
      IF mSaldoAtual < 0
         mDebMes += Abs( mSaldoAtual )
      ELSE
         mCreMes += mSaldoAtual
      ENDIF
   ENDIF
   // Apuracao de lucro geral
   IF SubStr( ctplano->a_Codigo, 1, 11 ) $ jpempre->emCodAcu
      FOR mCont = 1 TO mFechaAnt
         mSaldoAnt := mSaldoAnt + AppLucroDebito()[ mCont ] - AppLucroCredito()[ mCont ]
      NEXT
      IF mNumMes == mFechaAtu .AND. mFechado
         mMovMes := 0
         FOR mCont = mFechaAnt + 1 TO mNumMes
            mMovMes := mMovMes + AppLucroDebito()[ mCont ] - AppLucroCredito()[ mCont ]
         NEXT
         IF mMovMes > 0
            mDebMes += mMovMes
         ELSE
            mCreMes += Abs( mMovMes )
         ENDIF
      ENDIF
   ENDIF
   // Saldo Atual
   mSaldoAnt := Val( Str( mSaldoAnt ) )
   mDebMes   := Val( Str( mDebMes ) )
   mCreMes   := Val( Str( mCreMes ) )
   mSaldoAtual := mSaldoAnt + mDebMes - mCreMes
   mSaldoAtual := Val( Str( mSaldoAtual ) )

   RETURN mSaldoAtual
