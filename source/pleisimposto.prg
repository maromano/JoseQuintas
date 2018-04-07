/*
PLEISIMPOSTO - TABELA DE TRIBUTAÇÃO
2009.03 José Quintas
*/

#include "josequintas.ch"
#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE pLeisImposto

   LOCAL oFrm := JPIMPOSClass():New()
   LOCAL mimTransa := "X", mimTriUf := "X", mimTriCad := "X", mimTriPro := "X", mimNumLan

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso", "jpdecret" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpcadas", "jpcidade", "jpclista", "jpcomiss", "jpconfi", "jpempre", ;
         "jpestoq", "jpfinan", "jpforpag", "jpimpos", "jpitem", "jpitped", "jplfisc", "jpnota", "jpnumero", "jppedi", ;
         "jppreco", "jpsenha", "jptabel", "jptransa", "jpuf", "jpveicul", "jpvended" )
      RETURN
   ENDIF
   SELECT jpimpos
   oFrm:Execute()
   SELECT jpimpos
   OrdSetFocus( "regra" )
   GOTO TOP
   DO WHILE ! Eof()
      DO CASE
      CASE Eof()
      CASE jpimpos->imTransa != mimTransa
      CASE jpimpos->imTriUf  != mimTriUf
      CASE jpimpos->imTriCad != mimTriCad
      CASE jpimpos->imTriPro != mimTriPro
      OTHERWISE
         MsgExclamation( "Regra " + jpimpos->imNumLan + " está em duplicidade! Está igual à regra " + mimNumLan )
      ENDCASE
      mimTransa := jpimpos->imTransa
      mimTriUf  := jpimpos->imTriUf
      mimTriCad := jpimpos->imTriCad
      mimTriPro := jpimpos->imTriPro
      mimNumlan := jpimpos->imNumLan
      SKIP
   ENDDO
   CLOSE DATABASES

   RETURN

CREATE CLASS JPIMPOSClass INHERIT frmCadastroClass

   METHOD GridSelection()
   METHOD Especifico( lExiste )
   METHOD TelaDados( lEdit )

   ENDCLASS

METHOD GridSelection() CLASS JPIMPOSClass

   LOCAL nSelect := Select(), oTBrowse

   SELECT jpimpos
   oTBrowse := { ;
      { "N.Lanç",     { || jpimpos->imNumLan } }, ;
      { "Transação",  { || jpimpos->imTransa + iif( Encontra( jpimpos->imTransa, "jptransa", "numlan" ), "", "" ) + " " + Left( jptransa->trDescri, 15 ) } }, ;
      { "Trib.UF",    { || jpimpos->imTriUf + " " + Left( AUXTRIUFClass():Descricao( jpimpos->imTriUf ), 15 ) } }, ;
      { "Trib.Cad",   { || jpimpos->imTriCad + " " + Left( AUXTRICADClass():Descricao( jpimpos->imTriCad ), 15 ) } }, ;
      { "Trib.Prod",  { || jpimpos->imTriPro + " " + Left( AUXTRIPROClass():Descricao( jpimpos->imTriPro ), 15 ) } }, ;
      { "CFOP",       { || jpimpos->imCfOp } }, ;
      { "II.Alíq",    { || jpimpos->imIIAli } }, ;
      { "IPI CST",    { || jpimpos->imIpiCst + " "  + Left( AUXIPICSTClass():Descricao( jpimpos->imIpiCst ), 15 ) } }, ;
      { "IPI Alíq",   { || jpimpos->imIpiAli } }, ;
      { "IPI ICM",    { || jpimpos->imIpiIcm } }, ;
      { "IPI Simp",   { || jpimpos->imIpSAli } }, ;
      { "ICMS CST",   { || jpimpos->imIcmCst + " " + Left( AUXICMCSTClass():Descricao( Pad( Substr( jpimpos->imIcmCst, 2 ), 3 ) ), 15 ) } }, ;
      { "ICMS Red",   { || jpimpos->imIcmRed } }, ;
      { "ICMS Alíq",  { || jpimpos->imIcmAli } }, ;
      { "ICMS Simp",  { || jpimpos->imIcsAli } }, ;
      { "ST IVA",     { || jpimpos->imSubIva } }, ;
      { "ST Red",     { || jpimpos->imSubRed } }, ;
      { "ST Alíq",    { || jpimpos->imSubAli } }, ;
      { "ISS Alíq",   { || jpimpos->imIssAli } }, ;
      { "PIS CST",    { || jpimpos->imPisCst + " " + Left( AUXPISCSTClass():Descricao( jpimpos->imPisCst ),15 ) } }, ;
      { "PIS Alíq",   { || jpimpos->imPisAli } }, ;
      { "PIS Enq",    { || jpimpos->imPisEnq } }, ;
      { "Cofins CST", { || jpimpos->imCofCst + " " + Left( AUXPISCSTClass():Descricao( jpimpos->imCofCst ), 15 ) } }, ;
      { "Cof Alíq",   { || jpimpos->imCofAli } }, ;
      { "Cof Enq",    { || jpimpos->imCofEnq } }, ;
      { "Leis",       { || jpimpos->imLeis } } }
   FazBrowse( oTBrowse )
   IF LastKey() != K_ESC .AND. ! Eof()
      KEYBOARD jpimpos->imNumLan + Chr( K_ENTER )
   ENDIF
   SELECT ( nSelect )

   RETURN NIL

METHOD Especifico( lExiste ) CLASS JPIMPOSClass

   LOCAL GetList := {}
   LOCAL mimNumLan := jpimpos->imNumLan

   IF ::cOpc = "I"
      mimNumLan := "*NOVO*"
   ENDIF
   @  Row()+1, 20 GET mimNumLan PICTURE "@K 999999" VALID NovoMaiorZero( @mimNumLan )
   Mensagem( "Digite código, F9 Pesquisa, ESC Sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. ( Val( mimNumLan ) == 0 .AND. mimNumLan != "*NOVO*" )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK mimNumLan
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { mimNumLan }

   RETURN .T.

METHOD TelaDados( lEdit ) CLASS JPIMPOSClass

   LOCAL GetList := {}
   LOCAL mimNumLan  := jpimpos->imNumLan
   LOCAL mimTransa  := jpimpos->imTransa
   LOCAL mimTriCad  := jpimpos->imTriCad
   LOCAL mimTriPro  := jpimpos->imTriPro
   LOCAL mimTriUf   := jpimpos->imTriUf
   LOCAL mimOriMer  := Substr( jpimpos->imIcmCst, 1, 1 )
   LOCAL mimCfOp    := jpimpos->imCfOp
   LOCAL mimIssAli  := jpimpos->imIssAli
   LOCAL mimIIAli   := jpimpos->imIIAli
   LOCAL mimIpiCst  := jpimpos->imIpiCst
   LOCAL mimIpiAli  := jpimpos->imIpiAli
   LOCAL mimIpiIcm  := jpimpos->imIpiIcm
   LOCAL mimIpiEnq  := jpimpos->imIpiEnq
   LOCAL mimIcmCst  := Substr( jpimpos->imIcmCst, 2 )
   LOCAL mimIcmRed  := jpimpos->imIcmRed
   LOCAL mimIcmAli  := jpimpos->imIcmAli
   LOCAL mimDifCal  := jpimpos->imDifCal
   LOCAL mimDifAlii := jpimpos->imDifAlii
   LOCAL mimDifAliu := jpimpos->imDifAliu
   LOCAL mimDifAlif := jpimpos->imDifAlif
   LOCAL mimSubRed  := jpimpos->imSubRed
   LOCAL mimSubIva  := jpimpos->imSubIva
   LOCAL mimSubAli  := jpimpos->imSubAli
   LOCAL mimPisCst  := Left( jpimpos->imPisCst, 2 )
   LOCAL mimPisAli  := jpimpos->imPisAli
   LOCAL mimPisEnq  := jpimpos->imPisEnq
   LOCAL mimCofCst  := Left( jpimpos->imCofCst, 2 )
   LOCAL mimCofAli  := jpimpos->imCofAli
   LOCAL mimCofEnq  := jpimpos->imCofEnq
   LOCAL mimIcsAli  := jpimpos->imIcsAli
   LOCAL mimLeis    := jpimpos->imLeis
   LOCAL mimInfInc  := jpimpos->imInfInc
   LOCAL mimInfAlt  := jpimpos->imInfALt
   LOCAL mimObs     := jpimpos->imObs
   LOCAL mimLei     := Array(5), nCont
   LOCAL cnJPDECRET := ADOClass():New( AppcnMySqlLocal() )

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      mimNumLan := ::axKeyValue[1]
      mimIpiEnq := "999"
   ENDIF

   mimLei[ 1 ] := Substr( mimLeis, 1, 6 )
   mimLei[ 2 ] := Substr( mimLeis, 8, 6 )
   mimLei[ 3 ] := Substr( mimLeis, 15, 6 )
   mimLei[ 4 ] := Substr( mimLeis, 22, 6 )
   mimLei[ 5 ] := Substr( mimLeis, 29, 6 )
   mimIpiIcm   := IIf( mimIpiIcm $ "SN", mimIpiIcm, "S" )
   mimIpiCst   := iif( Empty( mimIpiCst ), "53", mimIpiCst )
   mimPisCst   := IIf( Empty( mimPisCst ), "08", mimPisCst )
   mimCofCst   := Iif( Empty( mimCofCst ), "08", mimCofCst )

   DO WHILE .T.
      ::ShowTabs()
      @ Row() + 1, 1     SAY "Num.Lançamento...:" GET mimNumLan WHEN .F.
      ::AddF9( lEdit )
      @ Row() + 1, 1     SAY "Transação........:" GET mimTransa PICTURE "@K 999999" VALID JPTRANSAClass():Valida( @mimTransa )
      ::AddF9( lEdit )
      Encontra( mimTransa, "jptransa", "numlan" )
      @ Row(), 32        SAY jptransa->trDescri
      @ Row() + 1, 1     SAY "Tribut.UF........:" GET mimTriUf  PICTURE "@K 999999" VALID AUXTRIUFClass():Valida( @mimTriUf )
      ::AddF9( lEdit )
      @ Row(),  32       SAY AUXTRIUFClass():Descricao( mimTriUf )
      @ Row() + 1, 1     SAY "Tribut.Cli/Forn..:" GET mimTriCad PICTURE "@K 999999" VALID AUXTRICADClass():Valida( @mimTriCad )
      ::AddF9( lEdit )
      @ Row(),  32       SAY AUXTRICADClass():Descricao( mimTriCad )
      @ Row() + 1, 1     SAY "Tribut.Prod/Serv.:" GET mimTriPro PICTURE "@K 999999" VALID AUXTRIPROClass():Valida( @mimTriPro ) .AND. ValidaAquiRepetido( ::cOpc, mimTransa, mimTriUf, mimTriCad, mimTriPro )
      ::AddF9( lEdit )
      @ Row(),  32       SAY AUXTRIPROClass():Descricao( mimTriPro )
      @ Row() + 1, 1     SAY "CFOP.............:" GET mimCfOp   PICTURE "@K 9.999"  VALID AUXCFOPClass():Valida( @mimCfOp )
      ::AddF9( lEdit )
      @ Row(),  32       SAY AUXCFOPClass():Descricao( mimCfOp )
      @ Row() + 1, 1     SAY "ISS..............:" GET mimIssAli PICTURE "999.99"    VALID mimIssAli >= 0 WHEN Substr( mimCfOp, 3, 3 ) == "949"
      @ Row(), Col()+10  SAY "II Imp.Importação:" GET mimIIAli  PICTURE "999.99"    VALID mimIIAli >= 0
      @ Row() + 1, 1     SAY "IPI -------- CST.:" GET mimIpiCst PICTURE "99"        VALID AUXIPICSTClass():Valida( @mimIpiCst, @mimIpiAli )
      ::AddF9( lEdit )
      @ Row(), 32        SAY AUXIPICSTClass():Descricao( mimIpiCst )
      @ Row() + 1, 1     SAY "        Alíquota.:" GET mimIpiAli PICTURE "999.99"    VALID mimIpiAli >= 0 WHEN TemIpi( mimIpiCst, @mimIpiAli )
      @ Row(), Col() + 2 SAY "Incide ICMS:"       GET mimIpiIcm PICTURE "!A"        VALID mimIpiIcm $ "SN" WHEN TemIpi( mimIpiCst, @mimIpiAli )
      @ Row() + 1, 1     SAY "   Enquadramento.:" GET mimIpiEnq PICTURE "@K 999"    VALID AUXIPIENQClass():Valida( @mimIpiEnq ) WHEN mimIpiCst != "52"
      ::AddF9( lEdit )
      @ Row(), 32        SAY AUXIPIENQClass():Descricao( mimIpiEnq )
      @ Row() + 1, 1     SAY "Origem Mercadoria:" GET mimOriMer PICTURE "9"         VALID AUXORIMERClass():Valida( @mimOriMer )
      ::AddF9( lEdit )
      @ Row(),  32       SAY AUXORIMERClass():Descricao( mimOriMer )
      @ Row() + 1, 1     SAY "ICMS - CST/CSOSN.:" GET mimIcmCst PICTURE "@K 999"    VALID AUXICMCSTClass():Valida( @mimIcmCst )
      ::AddF9( lEdit )
      @ Row(), 32        SAY AUXICMCSTClass():Descricao( mimIcmCst )
      @ Row() + 1, 1     SAY "        Alíquota.:" GET mimIcmAli PICTURE "999.99"    VALID mimIcmAli >= 0 WHEN TemIcms( mimIcmCst, @mimIcmAli, @mimIcmRed, @mimSubAli, @mimSubRed, @mimSubIva )
      @ Row(), Col() + 3 SAY "%Reducao.:"         GET mimIcmRed PICTURE "999.99"    VALID mimIcmRed >= 0 WHEN TemIcmRed( mimIcmCst, @mimIcmRed, @mimSubRed )
      @ Row() + 1, 1     SAY "ICMSST Alíquota..:" GET mimSubAli PICTURE "999.99"    VALID mimSubAli >= 0 WHEN TemIcmSub( mimIcmCst, @mimSubRed, @mimSubAli, @mimSubIva )
      @ Row(), Col() + 3 SAY "%Redução.:"         GET mimSubRed PICTURE "999.99"    VALID mimSubRed >= 0 WHEN TemIcmSub( mimIcmCst, @mimSubRed, @mimSubAli, @mimSubIva )
      @ Row(), Col() + 3 SAY "%IVA.:"             GET mimSubIva PICTURE "999.99"    VALID mimSubIva >= 0 WHEN TemIcmSub( mimIcmCst, @mimSubRed, @mimSubAli, @mimSubIva )
      @ Row() + 1, 1     SAY "DIFAL(S/N/Zerado):" GET mimDifCal PICTURE "!A"        VALID mimDifCal $ "SNZ" WHEN TemDifCal( @mimDifCal, @mimDifAlii, @mimDifAliu, @mimDifAlif, mimCfOp )
      @ Row(), Col() + 2 SAY "Interestadual:"     GET mimDifAlii PICTURE "999.99"   VALID mimDifAlii >= 0 WHEN TemDifCal( @mimDifCal, @mimDifAlii, @mimDifAliu, @mimDifAlif, mimCfOp )
      @ Row(), Col() + 2 SAY "UF destino:"        GET mimDifAliu PICTURE "999.99"   VALID mimDifAliu >= 0 WHEN TemDifCal( @mimDifCal, @mimDifAlii, @mimDifAliu, @mimDifAlif, mimCfOp )
      @ Row(), Col() + 2 SAY "FCP:"               GET mimDifAlif PICTURE "999.999"  VALID mimDifAlif >= 0 WHEN TemDifCal( @mimDifCal, @mimDifAlii, @mimDifAliu, @mimDifAlif, mimCfOp )
      @ Row(), Col() + 2 SAY "Int: 4% Exp, 7% sul/sudeste p/nordeste, 12% demais"
      @ Row() + 1, 1     SAY "PIS -------- CST.:" GET mimPisCst PICTURE "@K 99"     VALID AuxPisCstClass():Valida( @mimPisCst )
      ::AddF9( lEdit )
      @ Row(), 32        SAY AUXPISCSTClass():Descricao( mimPisCst )
      @ Row() + 1, 1     SAY "        Aliquota.:" GET mimPisAli PICTURE "999.99"    VALID mimPisAli >= 0 WHEN TemPis( mimPisCst, @mimPisAli )
      @ Row() + 1, 1     SAY "   Enquadramento.:" GET mimPisEnq PICTURE "@K 999"    VALID AUXPISENQClass():Valida( mimPisEnq, mimPisCst )
      ::AddF9( lEdit )
      Encontra( AUX_PISENQ + mimPisCst + "." + mimPisEnq, "jptabel", "numlan" )
      @ Row(), 32        SAY jptabel->axDescri
      @ Row() + 1, 1     SAY "Cofins ----- CST.:" GET mimCofCst PICTURE "@K 99"     VALID AUXPISCSTClass():Valida( @mimCofCst )
      ::AddF9( lEdit )
      @ Row(), 32        SAY AUXPISCSTClass():Descricao( mimCofCst )
      @ Row() + 1, 1     SAY "        Alíquota.:" GET mimCofAli PICTURE "999.99"    VALID mimCofAli >= 0 WHEN TemCofins( mimCofCst, @mimCofAli )
      @ Row() + 1, 1     SAY "   Enquadramento.:" GET mimCofEnq PICTURE "@K 999"    VALID AUXPISENQClass():Valida( mimCofEnq, mimCofCst )
      ::AddF9( lEdit )
      Encontra( AUX_PISENQ + mimCofCst + "." + mimCofEnq, "jptabel", "numlan" )
      @ Row(), 32        SAY jptabel->axDescri
      @ Row() + 1, 1     SAY "Simples Créd.ICMS:" GET mimIcsAli PICTURE "999.99"    VALID mimIcsAli >= 0 WHEN TemCredSimples( mimIcmCst, @mimIcsAli )
      @ Row() + 1, 1     SAY "Lei/Decreto 1....:" GET mimLei[1] PICTURE "@K 999999" VALID JPDECRETClass():Valida( @mimLei[ 1 ] )
      ::AddF9( lEdit )
      IF AppcnMySqlLocal() == NIL
         Encontra( mimLei[ 1 ], "jpdecret", "numlan" )
         @ Row(), 32      SAY jpdecret->deNome
      ELSE
         cnJPDECRET:cSql := "SELECT * FROM JPDECRET WHERE DENUMLAN=" + StringSql( mimLei[ 1 ] )
         cnJPDECRET:Execute()
         IF ! cnJPDECRET:Eof()
            @ Row(), 32 SAY cnJPDECRET:StringSql( "DENOME" )
         ENDIF
         cnJPDECRET:CloseRecordset()
      ENDIF
      @ Row() + 1, 1     SAY "Lei/Decreto 2....:" GET mimLei[2] PICTURE "@K 999999" VALID JPDECRETClass():Valida(  @mimLei[ 2 ] )
      ::AddF9( lEdit )
      IF AppcnMySqlLocal() == NIL
         Encontra( mimLei[ 2 ], "jpdecret", "numlan" )
         @ Row(), 32      SAY jpdecret->deNome
      ELSE
         cnJPDECRET:cSql := "SELECT * FROM JPDECRET WHERE DENUMLAN=" + StringSql( mimLei[ 2 ] )
         cnJPDECRET:Execute()
         IF ! cnJPDECRET:Eof()
            @ Row(), 32 SAY cnJPDECRET:StringSql( "DENOME" )
         ENDIF
         cnJPDECRET:CloseRecordset()
      ENDIF
      @ Row() + 1, 1     SAY "Lei/Decreto 3....:" GET mimLei[3] PICTURE "@K 999999" VALID JPDECRETClass():Valida(  @mimLei[ 3 ] )
      ::AddF9( lEdit )
      IF AppcnMySqlLocal() == NIL
         Encontra( mimLei[ 3 ], "jpdecret", "numlan" )
         @ Row(), 32      SAY jpdecret->deNome
      ELSE
         cnJPDECRET:cSql := "SELECT * FROM JPDECRET WHERE DENUMLAN=" + StringSql( mimLei[ 3 ] )
         cnJPDECRET:Execute()
         IF ! cnJPDECRET:Eof()
            @ Row(), 32 SAY cnJPDECRET:StringSql( "DENOME" )
         ENDIF
         cnJPDECRET:CloseRecordset()
      ENDIF
      @ Row() + 1, 1     SAY "Lei/Decreto 4....:" GET mimLei[4] PICTURE "@K 999999" VALID JPDECRETClass():Valida(  @mimLei[ 4 ] )
      ::AddF9( lEdit )
      IF AppcnMySqlLocal() == NIL
         Encontra( mimLei[ 4 ], "jpdecret", "numlan" )
         @ Row(), 32      SAY jpdecret->deNome
      ELSE
         cnJPDECRET:cSql := "SELECT * FROM JPDECRET WHERE DENUMLAN=" + StringSql( mimLei[ 4 ] )
         cnJPDECRET:Execute()
         IF ! cnJPDECRET:Eof()
            @ Row(), 32 SAY cnJPDECRET:StringSql( "DENOME" )
         ENDIF
         cnJPDECRET:CloseRecordset()
      ENDIF
      @ Row() + 1, 1     SAY "Lei/Decreto 5....:" GET mimLei[5] PICTURE "@K 999999" VALID JPDECRETClass():Valida(  @mimLei[ 5 ] )
      ::AddF9( lEdit )
      IF AppcnMySqlLocal() == NIL
         Encontra( mimLei[ 5 ], "jpdecret", "numlan" )
         @ Row(), 32      SAY jpdecret->deNome
      ELSE
         cnJPDECRET:cSql := "SELECT * FROM JPDECRET WHERE DENUMLAN=" + StringSql( mimLei[ 5 ] )
         cnJPDECRET:Execute()
         IF ! cnJPDECRET:Eof()
            @ Row(), 32 SAY cnJPDECRET:StringSql( "DENOME" )
         ENDIF
         cnJPDECRET:CloseRecordset()
      ENDIF
      @ Row() + 1, 1     SAY "Obs..............:" GET mimObs    PICTURE "@!"
      @ Row() + 1, 1     SAY "Inf. Inclusão....:" GET mimInfInc WHEN .F.
      @ Row() + 1, 1     SAY "Inf. Alteração...:" GET mimInfAlt WHEN .F.
      //SetPaintGetList( GetList )
      IF ! lEdit
         CLEAR GETS
         EXIT
      ENDIF
      Mensagem( "Digite Campos, F9 Pesquisa, ESC Sai" )
      READ
      Mensagem()
      ::F9Destroy()
      DO CASE
      CASE LastKey() == K_ESC
         EXIT
      CASE mimSubRed == 0 .AND. mimIcmCst $ "20, 70 "
         MsgWarning( "Se CST com redução (20 ou 70), necessita % de redução de ST" )
         LOOP
      CASE mimIcmCst $ "101,201" .AND. mimIcsAli == 0
         MsgWarning( "Se CST com direito a crédito (101,201) necessita % de crédito de ICMS" )
         LOOP
      CASE mimIcmCst $ "10 ,30 ,60, 201,202,203" .AND. mimSubAli == 0
         MsgWarning( "Se CST de substituição tributária (10,30,60,201,202,203), necessita % de substituição tributária" )
         LOOP
      CASE Substr( mimCfOp, 1, 1 ) > "4" .AND. mimPisCst >= "50"
         MsgWarning( "CFOP Saída e CST Pis de Entrada" )
         LOOP
      CASE Substr( mimCfOp, 1, 1 ) > "4" .AND. mimCofCst >= "50"
         MsgWarning( "CFOP Saída e CST Cofins de Entrada" )
         LOOP
      CASE Substr( mimCfOp, 1, 1 ) < "5" .AND. mimPisCst < "50"
         MsgWarning( "CFOP Entrada e CST Pis de Saída" )
         LOOP
      CASE Substr( mimCfOp, 1, 1 ) < "5" .AND. mimCofCst < "50"
         MsgWarning( "CFOP Entrada e CST Cofins de Saída" )
         LOOP
      ENDCASE
      IF mimPisCst != "01"
         IF Empty( mimPisEnq )
            mimPisEnq := "999"
            MsgWarning( "Atenção, faltou o enquadramento do PIS, será usado 999 mas confirme com o contador" )
         ENDIF
      ENDIF
      IF mimCofCst != "01"
         IF Empty( mimCofEnq )
            mimCofEnq := "999"
            MsgWarning( "Faltou o enquadramento do Cofins, será usado 999 mas confirme com o contador" )
         ENDIF
      ENDIF
      IF mimIpiCst == "52"
         mimIpiEnq := EmptyValue( mimIpiEnq )
      ELSEIF Empty( mimIpiEnq )
         mimIpiEnq := "999"
         MsgWarning( "Faltou o enquadramento de IPI, será usado 999 mas confirme com o contador" )
      ENDIF
      EXIT
   ENDDO
   IF ! lEdit
      RETURN NIL
   ENDIF
   IF LastKey() == K_ESC
      GOTO ::nUltRec
      RETURN NIL
   ENDIF
   IF ::cOpc == "I"
      IF Encontra( mimTransa + mimTriUf + mimTriCad + mimTriPro, "jpimpos", "regra" )
         MsgExclamation( "Regra já existente!" )
         RETURN NIL
      ENDIF
   ENDIF
   IF ::cOpc == "I"
      mimNumLan := ::axKeyValue[1]
      IF mimNumLan == "*NOVO*"
         mimNumLan := NovoCodigo( "jpimpos->imNumLan" )
      ENDIF
      RecAppend()
      REPLACE ;
         jpimpos->imNumLan WITH mimNumLan, ;
         jpimpos->imInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   mimLeis := ""
   FOR nCont = 1 TO 5
      IF Val( mimLei[ nCont ] ) != 0
         mimLeis += mimLei[ nCont ] + ","
      ENDIF
   NEXT
   mimIcmCst := mimOriMer + mimIcmCst
   RecLock()
   REPLACE ;
      jpimpos->imTransa  WITH mimTransa, ;
      jpimpos->imTriCad  WITH mimTriCad, ;
      jpimpos->imTriPro  WITH mimTriPro, ;
      jpimpos->imTriUf   WITH mimTriUf, ;
      jpimpos->imCfOp    WITH mimCfOp, ;
      jpimpos->imIssAli  WITH mimIssAli, ;
      jpimpos->imIIAli   WITH mimIIAli, ;
      jpimpos->imIpiCst  WITH mimIpiCst, ;
      jpimpos->imIpiAli  WITH mimIpiAli, ;
      jpimpos->imIpiIcm  WITH mimIpiIcm, ;
      jpimpos->imIcmCst  WITH mimIcmCst, ;
      jpimpos->imIcmRed  WITH mimIcmRed, ;
      jpimpos->imIcmAli  WITH mimIcmAli, ;
      jpimpos->imSubRed  WITH mimSubRed, ;
      jpimpos->imSubIva  WITH mimSubIva, ;
      jpimpos->imSubAli  WITH mimSubAli, ;
      jpimpos->imPisCst  WITH mimPisCst, ;
      jpimpos->imPisAli  WITH mimPisAli, ;
      jpimpos->imPisEnq  WITH mimPisEnq, ;
      jpimpos->imCofCst  WITH mimCofCst, ;
      jpimpos->imCofAli  WITH mimCofAli, ;
      jpimpos->imCofEnq  WITH mimCofEnq, ;
      jpimpos->imIcsAli  WITH mimIcsAli, ;
      jpimpos->imLeis    WITH mimLeis,   ;
      jpimpos->imOriMer  WITH mimOriMer, ;
      jpimpos->imIpiEnq  WITH mimIpiEnq, ;
      jpimpos->imObs     WITH mimObs,    ;
      jpimpos->imDifAlii WITH mimDifAlii, ;
      jpimpos->imDifAliu WITH mimDifAliu, ;
      jpimpos->imDifAlif WITH mimDifAlif, ;
      jpimpos->imDifCal  WITH mimDifCal
   IF ::cOpc == "A"
      REPLACE jpimpos->imInfAlt WITH LogInfo()
   ENDIF
   RecUnlock()

   RETURN NIL

STATIC FUNCTION TemIpi( mimIpiCst, mimIpiAli )

   IF ! mimIpiCst $ "00,49,50,56"
      mimIpiAli := 0
      RETURN .F.
   ENDIF

   RETURN .T.

STATIC FUNCTION TemIcms( mimIcmCst, mimIcmAli, mimIcmRed, mimSubAli, mimSubRed, mimSubIva )

   IF ! mimIcmCst $  "00 ,10 ,20 ,70 ,90 ,201,202,203,900"
      mimIcmAli := 0
      mimIcmRed := 0
      mimSubAli := 0
      mimSubRed := 0
      mimSubIva := 0
      RETURN .F.
   ENDIF

   RETURN .T.

STATIC FUNCTION TemIcmSub( mimIcmCst, mimSubRed, mimSubAli, mimSubIva )

   IF ! mimIcmCst $ "10 ,30 ,70 ,90 ,201,202,203,900"
      mimSubRed := 0
      mimSubAli := 0
      mimSubIva := 0
      RETURN .F.
   ENDIF

   RETURN .T.

STATIC FUNCTION TemIcmRed( mimIcmCst, mimIcmRed, mimSubRed )

   IF ! mimIcmCst $ "20 ,70 ,90 ,201,202,203,900"
      mimIcmRed := 0
      mimSubRed := 0
      RETURN .F.
   ENDIF

   RETURN .T.

STATIC FUNCTION TemPis( mimPisCst, mimPisAli )

   IF ! mimPisCst $ "01,02,03,04,49,50,51,52,53,54,55,56,60,61,62,63,64,65,66,67,75,98,99"
      mimPisAli := 0
      RETURN .F.
   ENDIF

   RETURN .T.

STATIC FUNCTION TemCofins( mimCofCst, mimCofAli )

   IF ! mimCofCst $ "01,02,03,04,49,50,51,52,53,54,55,56,60,61,62,63,64,65,66,67,75,98,99"
      mimCofAli := 0
      RETURN .F.
   ENDIF

   RETURN .T.

STATIC FUNCTION TemCredSimples( mimIcmCst, mimIcsAli )

   IF ! mimIcmCst $ "101,201,900"
      mimIcsAli := 0
      RETURN .F.
   ENDIF

   RETURN .T.

STATIC FUNCTION TemDifCal( mimDifCal, mimDifAlii, mimDifAliu, mimDifAlif, mimCfOp )

   IF ! Left( mimCfOp, 1 ) $ "2,3,6,7"
      mimDifCal  := "N"
      mimDifAlii := 0
      mimDifAliu := 0
      mimDifAlif := 0
      RETURN .F.
   ENDIF
   IF mimDifCal == "N"
      IF ReadVar() != "MIMDIFCAL"
         RETURN .F.
      ENDIF
   ENDIF
   IF mimDifCal == "S"
      IF mimDifAlii == 0
         mimDifAlii := 12
      ENDIF
   ENDIF

   RETURN .T.

STATIC FUNCTION ValidaAquiRepetido( cOpc, mimTransa, mimTriUf, mimTriCad, mimTriPro )

   IF cOpc != "I"
      RETURN .T.
   ENDIF
   IF Encontra( mimTransa + mimTriUf + mimTriCad + mimTriPro, "jpimpos", "regra" )
      MsgExclamation( "Regra já existente!" )
      RETURN .F.
   ENDIF

   RETURN .T.
