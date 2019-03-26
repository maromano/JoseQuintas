/*
RPESQ - PESQUISAS
1995.04 Jos� Quintas

2018.02.16 Pesquisa ref opera��o em intervalo
*/

/* ***** IMPORTANTE *****
As variaveis mclientei e mforneci das funcoes selcliente e selfornec
nao funcionam, por serem locais
*/

// ? GetActive():Name
// ? GetActive():Buffer
// bBlock := MemVarBlock( GetActive():Name )
// Eval( bBlock, Pad( "teste", Len( eVal(bBlock) ) ) )

#include "josequintas.ch"
#include "inkey.ch"

PROCEDURE Pesquisa

   LOCAL cOrdSetFocus, cVarName, cKeyboard, nSelect, mRow, mCol, mdbFilter, oTBrowse, maxTabela
   LOCAL nCont, oSetKey, mNomeCta, mNumCta, nRecNo

   PARAMETERS Dummy1, Dummy2, Dummy3
   MEMVAR m_Prog, mCTabela, m_Tipo

   cVarName     := Lower( ReadVar() ) // colocado aqui
   cOrdSetFocus := ""
   cKeyboard    := ""
   nSelect      := Select()
   mRow         := Row()
   mCol         := Col()

   IF Empty( cVarName )
      RETURN
   ENDIF

   oSetKey := SaveSetKey( K_F9, K_F10 )
   SET KEY K_F9  TO
   SET KEY K_F10 TO

   DO CASE
   CASE cVarName == "mmcnumlan"
      JPMDFCABClass():GridSelection()

   CASE cVarName $ "maxlic01,maxlic02,maxlic03,maxlic04,maxlic05,maxlic06,maxlic07,maxlic08,maxlic09,maxlic10,maxlic11,maxlic12"
      AUXLICTIPClass():GridSelection()

   CASE cVarName $ "mlcnumlan" .AND. m_Prog == "PJPLICMOV"
      JPLICMOVClass():GridSelection()

   CASE cVarName $ "mlclicobj"
      AUXLICOBJClass():GridSelection()

   CASE cVarName $ "mmcmotori,mmomotori"
      JPMOTORIClass():GridSelection()

   CASE cVarName $ "mmcveiculo,mvenumlan"
      JPVEICULClass():GridSelection()

   CASE cVarName $ "mctreduz" .AND. m_prog == "PCONTCTPLANO"
      // nao tem pesquisa no cadastro do plano de contas para codigo reduzido

   CASE cVarName == "mcbdata"
      JPCOMBUSTIVELClass():GridSelection()

   CASE cVarName $ "mimorimer,mieorimer" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PLEISORIMER" )
      AUXORIMERClass():GridSelection()

   CASE cVarName $ "mcomidia,mcdmidia,mcomidiai"
      AUXMIDIAClass():GridSelection()

   CASE cVarName $ "mnbnumlan"
      JPNFBASEClass():GridSelection()

   CASE cVarName $ "mieunid,mieunicom" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PLEISPROUNI" )
      AUXPROUNIClass():GridSelection()

   CASE cVarName $ "mdenumlan" .OR. Substr( cVarName, 1, 6 ) == "mimlei"
      JPDECRETClass():GridSelection()

   CASE cVarName $ "memquacon,memquatit" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PLEISQUAASS" )
      AUXQUAASSClass():GridSelection()

   CASE cVarName $ "mracodigo"
      AUXCNAEClass():GridSelection()

   CASE cVarName $ "mipicmcst" // aqui com origem de mercadoria
      SELECT jptabel
      FazBrowse(,, AUX_ICMCST )
      cKeyboard := "0" + Trim( jptabel->axCodigo ) // quebra-galho com 0=nacional

   CASE cVarName $ "mimicmcst" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PLEISICMCST" )
      SELECT jptabel
      FazBrowse(,, AUX_ICMCST )
      cKeyboard := Trim( jptabel->axCodigo )

   CASE cVarName $ "mvenumlan"
      JPVEICULClass():GridSelection()

   CASE cVarName $ "mimpiscst,mippiscst,mimcofcst,mipcofcst" ;
      .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PLEISPISCST" )
      SELECT jptabel
      FazBrowse(,, AUX_PISCST )
      cKeyboard := Trim( jptabel->axCodigo )

   CASE cVarName $ "mimipicst,mipipicst" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PLEISIPICST" )
      SELECT jptabel
      FazBrowse(,, AUX_IPICST )
      cKeyBoard := Trim( jptabel->axCodigo )

   CASE cVarName $ "mimipienq" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PLEISIPIENQ" )
      SELECT jptabel
      FazBrowse(,, AUX_IPIENQ )
      cKeyboard := Trim( jptabel->axCodigo )

   CASE cVarName $ "mimpisenq,mimcofenq" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PLEISPISENQ" )
      SELECT jptabel
      FazBrowse(,, AUX_PISENQ )
      cKeyboard := Substr( jptabel->axCodigo, 4, 3 )

   CASE cVarName $ "mctctaadm,mctctaadmi,mctctaadmf"
      ContCtaAdmClass():GridSelection()

   CASE cVarName $ "mcdtricad,mimtricad" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PLEISTRICAD" )
      AUXTRICADClass():GridSelection()

   CASE cVarName $ "mietripro,mimtripro" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PLEISTRIPRO" )
      AUXTRIPROClass():GridSelection()

   CASE cVarName $ "mpcreajuste"
      JPPRECOClass():GridReajuste()

   CASE cVarName $ "muftriuf,mimtriuf,mtutriuf" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PLEISTRIUF" )
      AUXTRIUFClass():GridSelection()

   CASE cVarName $ "mnumlote,mdilote"
      CTLOTESClass():GridSelection()

   CASE cVarName $ "mctconta,mctcontai,mctcontaf,mctcontad,mctcontac,memresacu,mctreduz,mlacconta,matcconta,matccontad"
      SELECT ctplano
      FazBrowse( { { "CONTA", { || PicConta( ctplano->a_Codigo ) } }, ;
         { "DESCRI��O", { || Pad( Space( ctplano->a_Grau - 1 ) + ctplano->a_Nome, 50 ) } } } )
      IF cVarName $ "mctreduz"
         IF ctplano->a_tipo != "A"
            MsgStop( "Conta sint�tica n�o possui c�digo reduzido!")
         ELSE
            cKeyboard = AllTrim( ctplano->a_Reduz )
         ENDIF
      ELSE
         cKeyboard = Trim( Substr( ctplano->a_Codigo, 1, 11 ) ) + Substr( ctplano->a_Codigo, 12, 1 )
      ENDIF

   CASE cVarName $ "mdilanc,mdimov"
      SELECT ctdiari
      FazBrowse( { ;
         { "DATA",  { || ctdiari->diData } }, ;
         { "LOTE",  { || ctdiari->diLote } }, ;
         { "LAN�",  { || ctdiari->diLanc } }, ;
         { "MOV.",  { || ctdiari->diMov } },  ;
         { "CONTA", { || PicConta( ctdiari->diCConta ) } }, ;
         { "VALOR", { || Transform( ctdiari->diValor, "@E 9999999,999,999.99" ) + ctdiari->diDebCre } } } )
      cKeyboard = iif( cVarName == "mctnumlan", "", Chr(5) ) + Chr(5) + Chr(5) + Chr(5) + ;
         StrZero( Month( ctdiari->diData ), 2 ) + Chr( 13 ) + StrZero( Year( ctdiari->diData ), 4 ) + Chr( 13 )+;
         ctdiari->diLote + Chr( 13 ) + ctdiari->diLanc + Chr( 13 ) + ctdiari->diMov

   CASE cVarName $ "mhihispad,mhihispadi,mhihispadf,mlahispad" .OR. ( cVarName == "m_chisto" .AND. m_Prog $ "PCONTLANCINCLUI" )
      SELECT cthisto
      cOrdSetFocus := OrdSetFocus( "descricao" )
      FazBrowse( { { "COD.", { || cthisto->hiHisPad } }, ;
         { "LINHA 1", { || Substr( cthisto->hiDescri, 1, 50 ) } }, ;
         { "LINHA 2", { || Substr( cthisto->hiDescri, 51, 50 ) } } } )
      cKeyboard = cthisto->hihisPad
      OrdSetFocus( cOrdSetFocus )

   CASE cVarName $ "mctlancpi,mctlancpf"
      SELECT ctlanca
      FazBrowse()
      cKeyboard := ctlanca->laCodigo

   CASE cVarName $ "nutabela"
      SELECT jpnumero
      FazBrowse()
      cKeyboard := jpnumero->nutabela

   CASE cVarName $ "mcdgrupo"
      SELECT jptabel
      cOrdSetFocus := OrdSetFocus( "descricao" )
      Fazbrowse(,, AUX_CLIGRU )
      cKeyboard := jptabel->axCodigo
      OrdSetFocus( cOrdSetFocus )

   CASE cVarName $ "mctconta"
      SELECT ctplano
      FazBrowse()
      cKeyboard := SoNumeros( ctplano->a_Codigo )

   CASE cVarName $ "mlei1,mlei2,mlei3,mlei4,mlei5"
      SELECT jpdecret
      FazBrowse()
      cKeyboard := jpdecret->deNumLan

   CASE cVarName $ "memtriemp" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PLEISTRIEMP" )
      EscolheTab( AUX_TRIEMP, mRow, mCol )
      cKeyBoard := jptabel->axCodigo
      SET FILTER TO
      OrdSetFocus( cOrdSetFocus )

   CASE cVarName $ "maxcodigo" .AND. Left( m_Prog, 4 ) == "PAUX"
      IF Val( Substr( m_Prog, 5 ) ) != 0 // todas as tabelas numericas
         maxTabela := StrZero( Val( Substr( m_Prog, 5 ) ), 6 )
         SELECT jptabel
         OrdSetFocus( "numlan" )
         EscolheTab( maxTabela, mRow, mCol )
         cKeyboard := jptabel->axCodigo
      ELSE
         SELECT jptabel
         cOrdSetFocus := OrdSetFocus( "descricao" )
         FazBrowse()
         cKeyboard := Pad( jptabel->axCodigo, Len( GetActive():Buffer ) )
         OrdSetFocus( cOrdSetFocus )
      ENDIF

   CASE cVarName $ "mimnumlan"
      JPIMPOSClass():GridSelection()

   CASE cVarName $ "mlfmodfis,mmfnumlan" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PLEISMODFIS" )
      AUXMODFISClass():GridSelection()

   CASE cVarName $ "mftfilial,mnffilial,mfifilial,mnffilial,mobs2filial"
      AUXFILIALClass():GridSelection()

   CASE cVarName == "mbrnumlan"
      //IF AppcnMySqlLocal() == NIL
      //   SELECT jpbarra
      //   FazBrowse()
      //   cKeyboard := jpbarra->brNumLan
      //ENDIF

   CASE cVarName $ "mieprosec,mprosec" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PESTOSECAO" )
      AUXPROSECClass():GridSelection()

   CASE cVarName $ "mieprogru,mprogru" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PESTOGRUPO" )
      AUXPROGRUClass():GridSelection()

   CASE cVarName $ "mrccodigo"
      SELECT jprefcta
      oTBrowse := { ;
         { "C�DIGO",    { || jprefcta->rcCodigo } }, ;
         { "DESCRI��O", { || Substr( jprefcta->rcDescri, 1, 40 ) } }, ;
         { "Orgao",     { || jprefcta->rcOrgao } } }
      FazBrowse( oTBrowse )
      cKeyboard := jprefcta->rcCodigo

   CASE cVarName $ "mplctasrf"
      SELECT jprefcta
      oTBrowse := { ;
         { "C�DIGO",    { || jprefcta->rcCodigo } }, ;
         { "DESCRI��O", { || Substr( jprefcta->rcDescri, 1, 40 ) } }, ;
         { "�rgao",     { || jprefcta->rcOrgao } } }
      FazBrowse( oTBrowse )
      cKeyboard := jprefcta->rcCodigo

   CASE cVarName $ "mcdforpag,mpdforpag,mosforpag,mpcforpag,mfpnumlan,mforpagi"
      JPFORPAGClass():GridSelection()

   CASE cVarName $ "magenda"
      jpagendaClass():GridSelection()

   CASE cVarName == "mesnumlan"
      EstLancClass():GridSelection()

   CASE cVarName == "mlfnumlan" .AND. m_Prog $ "PFISCSAIDAS,PFISCENTRADAS"
      cOrdSetFocus := OrdSetFocus( "jplfisc6" )
      FazBrowse( ,, iif( m_Prog == "PFISCSAIDAS", "1", "2" ) )
      cKeyboard := jplfisc->lfNumLan
      OrdSetFocus( cOrdSetFocus )

   CASE cVarName $ "mbanco,mpgbanco,mvfbanco"
      SELECT jptabel
      cOrdSetFocus := OrdSetFocus( "descricao" )
      FazBrowse( ,, AUX_BANCO )
      cKeyBoard := jptabel->axCodigo
      OrdSetFocus( cOrdSetFocus )

   CASE cVarName $ "mpdtransa,mimtransa,mtrtransa,mestransa"
      JPTRANSAClass():GridSelection()

   CASE cVarName $ "mccusto,m_ccusto,m_ccustoi,m_ccustof,mficcusto,matccusto"
      AUXCCUSTOClass():GridSelection()

   CASE cVarName $ "mcinumlan,mcinumlani,mcinumlanf"
      JPCIDADEClass():GridSelection()

   CASE cVarName $ "mcdcidade,mcdcidcob,mcdcident,mmocidade,mcidade"
      JPCIDADEClass():GridSelection( "NOME" )

   CASE cVarName $ "cclientei,cclientef,mcliente,mclientei,mclientef,mrevenda,mrevendai,memitente,mdestinat,mclientei,mclientef,mpdcdcli,mtaclient,"+;
         "mdfrevenda,mvfrevenda,mvfcliente,mfisacado,mficlifor,mesclifor,mlfclifor,mpdclifor,mfornec,mforneci,mfornecf,moscliente,mosfornec,mcdcodigo,mpccadas," + ;
         "mcoclicod,mcofor1cod,mcofor2cod,mmdcliente"
      JPCADAS1Class():GridSelection()

   CASE cVarName == "mcodigo" .AND. Left(m_Prog,2) == "P3"
      EscolheTab( mCTabela, mRow, mCol ) // mCTabela vem do progr.

   CASE cVarName $ "mfinumlan" .OR. ( cVarName $ "mdocto" .AND. m_prog $ "PFINANEDPAGAR,PFINANEDPAGARX,PFINANEDRECEBER,PFINANEDRECEERBX" )
      SELECT jpfinan
      oTBrowse := { ;
         { "NUMLAN",   { || jpfinan->fiNumLan } }, ;
         { "DOCTO/P",  { || jpfinan->fiNumDoc + "." + jpfinan->fiParcela } }, ;
         { "PEDIDO",   { || jpfinan->fiPedido } }, ;
         { "CLI/FORN", { || Iif( Encontra( jpfinan->fiCliFor, "jpcadas", "numlan" ), "", "" ) + jpfinan->fiCliFor + " " + Left( jpcadas->cdNome, 15 ) } }, ;
         { "EMISS�O",  { || jpfinan->fiDatEmi } }, ;
         { "VENCTO",   { || jpfinan->fiDatVen } }, ;
         { "VALOR",    { || Str( jpfinan->fiValor, 14, 2 ) } }, ;
         { "PAGTO",    { || jpfinan->fiDatPag } }, ;
         { "OBS",      { || Substr( jpfinan->fiObs, 1, 50 ) } } }
      FOR nCont = 1 TO Len(oTBrowse)
         AAdd( oTBrowse[ nCont ], {|| iif( ! Empty( jpfinan->fiDatPag ) .OR. ! Empty( jpfinan->fiDatCan ), { 1, 2 }, ;
            Iif( jpfinan->fiDatVen < Date(), { 7, 2 }, { 6, 2 } ) ) } )
      NEXT
      mdbFilter := dbFilter()
      IF m_Prog $ "PFINANEDPAGAR"
         SET FILTER TO jpfinan->fiTipLan == "2"
         FazBrowse( oTBrowse,,, 3 )
      ELSE
         SET FILTER TO jpfinan->fiTipLan == "1"
         FazBrowse( oTBrowse,,, 3 )
      ENDIF
      IF cVarName $ "mfinumlan"
         cKeyboard := jpfinan->fiNumLan
      ELSEIF cVarName $ "mdocto" .AND. m_prog $ "PFINANEDRECEBER,PFINANEDRECEBERBX" // P0730
         cKeyboard = jpfinan->fiNumDoc + Chr(13) + jpfinan->fiParcela + Chr(13) + jpfinan->fiCliFor
      ENDIF
      SET FILTER TO &(mdbFilter)

   CASE cVarName $ "mieproloc,mproloc" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PESTOLOCAL" )
      AUXPROLOCClass():GridSelection()

   CASE cVarName $ "mieprodep,mgruest,mcmprodep" .OR. ( cVarName == "maxcodigo" .AND. m_Prog == "PESTODEPTO" )
      AUXPRODEPClass():GridSelection()

   CASE cVarName $ "mmodfiscal"
      AUXMODFISClass():GridSelection()

   CASE cVarName $ "moperacao,mfioperacao,moperacaoi"
      AUXFINOPEClass():GridSelection()

   CASE cVarName $ "mpedido,mpedidoi,mpedidof,mpdpedido,mpedido2,mpedido3,mpedido4,mpedido5,mbrpedcom,mbrpedven,mpdpedrel,mpedidojuntar,mospedido1,mospedido2,mospedido3,mospedido4,mospedido5,cpedidoatual,cpedidooutro"
      JPPEDIClass():GridSelection()

   CASE cVarName $ "mcdportador,mportador.mfiportador,mftnumlan,mportadori"
      AUXFINPORClass():GridSelection()

   CASE cVarName $ "mcdstatus,mcdstatussem,mcsnumlan"
      JPCLISTAClass():GridSelection()

   CASE cVarName $ "mtabauxi,mtabauxf"
      EscolheTab( AUX_TABAUX, mRow, mCol )

   CASE cVarName $ "mtipobolet"
      EscolheTab( StrZero( 34, 6 ), mRow, mCol )

   CASE cVarName $ "mtransp,mpdtransp,mcdtransp,mtranspi,mtranspf,mnfcadtra"
      SELECT jpcadas
      cOrdSetFocus := OrdSetFocus( "jpcadas2" )
      FazBrowse(,,"3")
      cKeyboard = jpcadas->cdCodigo
      OrdSetFocus( cOrdSetFocus )

   CASE cVarName $ "mufuf,muf,mcduf,mcdufcob,mcdufent,memuf,memufcrc,mciuf"
      SELECT jpuf
      cOrdSetFocus := OrdSetFocus( "descricao" )
      FazBrowse()
      cKeyBoard := jpuf->ufUf
      OrdSetFocus( cOrdSetFocus )

   CASE cVarName $ "cvendedori,cvendedorf,mcdvendedor,mvendedor,mfivendedor,mostecnico,mpdvendedor,mvdvendedor,mcmvendedor," + ;
         "mvendedor01,mvendedor02,mvendedor03,mvendedor04,mvendedor05,mvendedor06,mvendedor07,mvendedor08,mvendedor09,mvendedor10," + ;
         "mvendedor11,mvendedor12,mvendedor13,mvendedor14,mvendedor15,mvendedor16,mvendedor17,mvendedor18,mvendedor19,mvendedor20,mcovendedi,mcovended"
      SELECT jpvended
      cOrdSetFocus := OrdSetFocus( "descricao" )
      FazBrowse()
      cKeyBoard := jpvended->vdVendedor
      OrdSetFocus( cOrdSetFocus )

   CASE cVarName $ "mctadeb,mctacre" .AND. m_Prog == "PFISCENTRADAS"
      SELECT ctplano
      cOrdSetFocus := OrdSetFocus()
      FazBrowse( { { "CONTA",  { || PicConta( ctplano->a_Codigo ) } }, ;
         { "DESCRI��O", { || Pad( Space( ctplano->a_Grau - 1 ) + ctplano->a_Nome, 50 ) } } } )
      cKeyboard := ctplano->a_Reduz
      OrdSetFocus( cOrdSetFocus )

   CASE cVarName == "mctconta" .AND. m_Prog $ "PCONTLANCPAD,PCONTLANCINCLUI"
      SELECT ctplano
      cOrdSetFocus := OrdSetFocus( "ctplano3" )
      FazBrowse( { { "CONTA",  { || PicConta( ctplano->a_Codigo ) } }, ;
         { "DESCRI��O", { || Pad( Space( ctplano->a_Grau - 1 ) + ctplano->a_Nome, 50 ) } } } )
      IF m_Tipo == "N"
         cKeyboard := Trim(Left(ctplano->a_Codigo,11))+Right(ctplano->a_Codigo,1)
      ELSE
         cKeyboard := ctplano->a_Reduz
      ENDIF
      OrdSetFocus( cOrdSetFocus )

   CASE cVarName $ "mbaconta,mbuconta"
      SELECT jpbamovi
      nRecNo := RecNo()
      GOTO TOP
      mNomeCta := {}
      GOTO TOP
      DO WHILE ! eof()
         AAdd( mNomeCta, jpbamovi->baConta )
         SEEK jpbamovi->baConta + "ZZZ" SOFTSEEK
      ENDDO
      GOTO TOP
      IF Len( mNomeCta ) != 0
         Atail( AppForms() ):GuiHide()
         WOpen( 2, 9, maxrow()-3, maxcol()-4, "CONTAS DISPON�VEIS" )
         WSave(maxrow()-1, 0, maxrow(), maxcol())
         Mensagem( "Selecione e tecle ENTER, ESC Sai" )
         mNumCta := Achoice( 4, 10, maxrow()-4, maxcol()-5, mNomeCta )
         WRestore()
         WClose()
         Atail( AppForms() ):GuiShow()
         IF mNumCta != 0
            cKeyboard = mNomeCta[ mNumCta ]
         ENDIF
      ENDIF
      GOTO ( nRecNo )

   CASE cVarName $ "mdlnumlan"
      SELECT jpdolar
      FazBrowse( { ;
         { "DATA",  { || jpdolar->dlData } }, ;
         { "VALOR", { || jpdolar->dlValor } } } )
      cKeyboard = jpdolar->dlData

   CASE Left(cVarName,7) $ "m_irreg"
      AUXCARCORClass():GridSelection()

   CASE cVarName $ "mpdcfop,mescfop,mlfcfop,mcfcfopi,mcfcfopf,mcfcfop,mimcfop,mipcfop" ;
      .OR. ( cVarName = "maxcodigo" .AND. m_Prog == "PLEISCFOP" )
      SELECT jptabel
      cOrdSetFocus := OrdSetFocus( "numlan" )
      FazBrowse(,, AUX_CFOP )
      cKeyboard = jptabel->axCodigo
      OrdSetFocus( cOrdSetFocus )

   CASE cVarName $ "citem,citemi,citemf,mbritem,mfsitem,mitem,mieitem,mesitem.mipitem,mitemgeral,mlmitem,mpcitem,mcoprocod"
      IF cVarName == "mitemgeral"
         JPITEMClass():GridSelection( "itemnome" )
      ELSE
         JPITEMClass():GridSelection()
      ENDIF

   CASE cVarName $ "mnfnotfis,mnfnotfisi,mnfnotfisf"
      SELECT jpnota
      oTBrowse := { ;
         { "NOTA",    { || jpnota->nfNotFis } }, ;
         { "PEDIDO",  { || jpnota->nfPedido } }, ;
         { "LANC",    { || jpnota->nfNumLan } }, ;
         { "EMISS�O", { || jpnota->nfDatEmi } }, ;
         { "CLIENTE", { || jpnota->nfCadDes + " " + Iif( Encontra( jpnota->nfCadDes, "jpcadas", "numlan" ), "", "" ) + Substr( jpcadas->cdNome, 1, 20 ) } }, ;
         { "VALOR",   { || Transform( jpnota->nfValNot, "@ZE 999,999,999.99" ) } } }
      FazBrowse( oTBrowse )
      IF m_Prog == "PNOTACADASTRO" .OR. m_Prog == "PDFEEMAIL"
         cKeyboard := Chr( 5 ) + jpnota->nfFilial + Chr( 13 ) + jpnota->nfNotFis
      ELSE
         cKeyboard := jpnota->nfNotFis
      ENDIF

   CASE cVarName $ "m_resumo,m_resumo1,m_resumo2,m_resumo3,mbgresumo"
      SELECT jpbagrup
      FazBrowse( { { "RESUMO", { || jpbagrup->bgResumo } }, { "GRUPO", { || jpbagrup->bgGrupo } } } )
      cKeyboard := jpbagrup->bgResumo

   ENDCASE

   IF Len( cKeyboard ) != 0
      IF Lastkey() != K_ESC // .AND. ! Eof()
         KEYBOARD ( cKeyboard ) + Chr(13)
      ENDIF
   ENDIF
   SELECT ( nSelect )
   RestoreSetKey( oSetKey )

   RETURN
