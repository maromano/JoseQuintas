/*
PBAR0010 - CODIGOS DE BARRA
2003.04 José Quintas
*/

#include "inkey.ch"
#include "hbclass.ch"

PROCEDURE PBAR0010

   LOCAL oFrm := PBAR0010Class():New()
   MEMVAR  mFiltroBarra, mFiltroPedido, m_Prog
   PRIVATE mFiltroBarra, mFiltroPedido

   IF .T.
      MsgExclamation( "Módulo incompleto pra MySQL" )
      RETURN
   ENDIF
   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso", "jpbarra", "jpdecret" )
         RETURN
      ENDIF
   ENDIF
   IF ! AbreArquivos( "jpcadas", "jpcidade", "jpclista", "jpcomiss", "jpconfi", "jpempre", ;
      "jpestoq", "jpfinan", "jpforpag", "jpimpos", "jpitem", "jpitped", "jplfisc", "jpnota", "jpnumero", "jppedi", "jppretab", ;
      "jppreco", "jpsenha", "jptabel", "jptransa", "jpuf", "jpveicul", "jpvended" )
      RETURN
   ENDIF
   SELECT jpbarra
   mFiltroBarra  := Space(22)
   mFiltroPedido := Space(22)
   AAdd( oFrm:acMenuOptions, "<Z>Limpar" )
   AAdd( oFrm:acMenuOptions, "<T>Filtro" )
   AAdd( oFrm:acMenuOptions, "<O>Ocorrencias" )
   IF m_Prog == "PBAR0010"
      oFrm:cOptions := "IAE"
   ELSE
      oFrm:cOptions := "C"
   ENDIF
   oFrm:Execute()
   CLOSE DATABASES

   RETURN

STATIC FUNCTION OkAqui( mCodigo )
   LOCAL mVar

   mVar := Lower( ReadVar() )
   DO CASE
   CASE Val( mCodigo ) == 0
      mCodigo := EmptyValue( mCodigo )
   CASE mVar == "mbrpedcom"
      RETURN OkPedCom( @mCodigo )
   CASE mVar == "mbrpedven"
      RETURN OkPedVen( @mCodigo )
   CASE mVar == "mbritem"
      RETURN JPITEMClass():Valida( @mCodigo )
   ENDCASE

   RETURN .T.

STATIC FUNCTION OkPedCom( mPedido ) // usado em outro programa

   IF ! JPPEDIClass():Valida( @mPedido )
      RETURN .F.
   ENDIF
   IF jppedi->pdStatus $ "C"
      MsgWarning( "Pedido cancelado!" )
      RETURN .F.
   ENDIF
   IF Substr( jppedi->pdTransa, 1, 3 ) > "500"
      MsgStop( "Não é pedido de entrada!" )
      RETURN .F.
   ENDIF

   RETURN .T.

STATIC FUNCTION OkPedVen( mPedido )

   IF Val( mPedido ) == 0
      mPedido := Space(6)
      RETURN .T.
   ENDIF
   IF ! JPPEDIClass():Valida( @mPedido )
      RETURN .F.
   ENDIF
   IF jppedi->pdStatus $ "C"
      MsgWarning( "Pedido cancelado!" )
      RETURN .F.
   ENDIF
   IF Substr( jppedi->pdTransa, 1, 3 ) < "500"
      MsgStop( "Não é pedido de saída!" )
      RETURN .F.
   ENDIF

   RETURN .T.

CREATE CLASS PBAR0010Class INHERIT frmCadastroClass

   METHOD UserFunction( lProcessou )
   METHOD LimpaBarra()
   METHOD FiltroBarra()
   METHOD TelaDados( lEdit )
   METHOD Especifico( lExiste )

   ENDCLASS

METHOD UserFunction( lProcessou ) CLASS PBAR0010Class

   DO CASE
   CASE ::cOpc == "X"
      ::AnulaBarra()
   CASE ::cOpc == "Z"
      ::LimpaBarra()
   CASE ::cOpc == "T"
      ::FiltroBarra()
   CASE ::cOpc == "O"
      PJPREGUSO( "JPBARRA", StrZero( Val( jpbarra->brNumLan ), 9 ) )
   OTHERWISE
      lProcessou := .F.
   ENDCASE

   RETURN lProcessou

METHOD LimpaBarra() CLASS PBAR0010Class

   IF ! MsgYesNo( "Confirma limpar dados do código de barras?" )
      RETURN .T.
   ENDIF
   ::cnMySql:cSql := "UPDATE JPBARRA SET BRPEDCOM='',BRPEDVEN='',BRCODBAR2='',BRITEM='' WHERE BRNUMLAN=" + "???????????"
   ::cnMySql:ExecuteCmd()

   RETURN NIL

METHOD FiltroBarra() CLASS PBAR0010Class

   LOCAL GetList := {}
   MEMVAR mFiltroBarra, mFiltroPedido

   mFiltroBarra  := Space(22)
   mFiltroPedido := Space(22)
   WSave()
   @ 9, 0 CLEAR TO 15, MaxCol()
   @ 9, 0 TO 15, MaxCol()
   @ 11, 5 SAY "Cód.Barras Próprio " GET mFiltroBarra PICTURE "@K 9999999999999999999999"
   @ 13, 5 SAY "Numero do Pedido   " GET mFiltroPedido PICTURE "@K 999999"
   Mensagem( "Digite cód. barras ou pedido, ESC Sai" )
   READ
   IF LastKey() == K_ESC
      SET FILTER TO
      RETURN .T.
   ENDIF
   IF Val( mFiltroBarra ) != 0
      mFiltroBarra := StrZero( Val( mFiltroBarra ), 7 )
      SET FILTER TO jpbarra->brCodBar == mFiltroBarra
   ELSEIF Val( mFiltroPedido ) != 0
      mFiltroPedido := StrZero( Val( mFiltroPedido ), 6 )
      SET FILTER TO jpbarra->brPedCom == mFiltroPedido .OR. jpbarra->brPedVen == mFiltroPedido
   ENDIF

   RETURN NIL

METHOD TelaDados( lEdit ) CLASS PBAR0010Class

   LOCAL GetList := {}
   LOCAL mbrNumLan, mbrCodBar, mbrCodBar2, mbrItem, mbrGarCom, mbrGarVen, mbrPedCom, mbrPedVen
   LOCAL mbrInfCom, mbrInfVen, mbrinfInc, mbrInfAlt, mQtdOcorr

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      mbrNumLan := ::axKeyValue[1]
   ENDIF
   WITH OBJECT ::cnMySql
      :cSql := "SELECT * FROM JPBARRA WHERE BRNUMLAN=" + StringSql( mbrNumLan )
      :Execute()
      mbrCodBar  := Pad( :StringSql( "BRCODBAR" ), 22 )
      mbrCodBar2 := Pad( :StringSql( "BRCODBAR2" ), 22 )
      mbrItem    := Pad( :StringSql( "BRITEM" ), 6 )
      mbrGarCom  := :DateSql( "BRGARCOM" )
      mbrGarVen  := :DateSql( "BRGARVEN" )
      mbrPedCom  := Pad( :StringSql( "BRPEDCOM" ), 6 )
      mbrPedVen  := Pad( :StringSql( "BRPEDVEN" ), 6 )
      mbrInfCom  := Pad( :StringSql( "BRINFCOM" ), 60 )
      mbrInfVen  := Pad( :StringSql( "BRINFVEN" ), 60 )
      mbrInfInc  := Pad( :StringSql( "BRINFINC" ), 80 )
      mbrInfAlt  := Pad( :StringSql( "BRINFALT" ), 80 )
   ENDWITH
   ::ShowTabs()
   @ Row() + 1, 0 SAY "Num. Lançto.........:" GET mbrNumLan WHEN .F.
   @ Row() + 2, 0 SAY "Cod.Barras Próprio..:" GET mbrCodBar
   @ Row() + 1, 0 SAY "Cod.Barras Forneced.:" GET mbrCodBar2
   @ Row() + 1, 0 SAY "Produto.............:" GET mbrItem PICTURE "@K 999999" VALID OkAqui( @mbrItem ) .AND. ReturnValue( .T., mbrGarCom := Date() + jpitem->ieGarCom )
   Encontra( mbrItem, "jpitem", "item" )
   @ Row(), 32 SAY jpitem->ieDescri
   @ Row()+1, 0 SAY "Pedido de Compra....:" GET mbrPedCom PICTURE "@K 999999" VALID OkAqui( @mbrPedCom )
   Encontra( mbrPedCom, "jppedi", "pedido" )
   @ Row(), Col()+2 SAY jppedi->pdDatEmi
   @ Row()+1, 0 SAY "Fornecedor..........: " + jppedi->pdCliFor
   Encontra( jppedi->pdCliFor, "jpcadas", "numlan" )
   @ Row(), 32 SAY jpcadas->cdNome
   @ Row() + 1, 0 SAY "Garantia de Compra..:" GET mbrGarCom
   @ Row() + 1, 0 SAY "Garantia de Venda...:" GET mbrGarVen
   @ Row() + 1, 0 SAY "Pedido de Venda.....:" GET mbrPedVen PICTURE "@K 999999" VALID OkAqui( @mbrPedVen )
   Encontra( mbrPedVen, "jppedi", "pedido" )
   @ Row(), Col() + 2 SAY jppedi->pdDatEmi
   Encontra( jppedi->pdPedido, "jpnota", "pedido" )
   @ Row() + 1, 0 SAY "Nota Fiscal de Venda: " + jpnota->nfNotFis
   Encontra( jppedi->pdPedido, "jpnota", "pedido" )
   @ Row(), Col() + 2 SAY jpnota->nfDatEmi
   @ Row() + 1, 0 SAY "Cliente.............: " + jppedi->pdCliFor
   Encontra( jppedi->pdCliFor, "jpcadas", "numlan" )
   @ Row(), 32 SAY jpcadas->cdNome
   @ Row() + 1, 0 SAY "Inf. Compra.........:" GET mbrInfCom WHEN .F.
   @ Row() + 1, 0 SAY "Inf. Venda..........:" GET mbrInfVen WHEN .F.
   @ Row() + 2, 0 SAY "Inf. Inclusão.......:" GET mbrInfInc WHEN .F.
   @ Row() + 1, 0 SAY "Inf. Alteração......:" GET mbrInfAlt WHEN .F.
   mQtdOcorr := QtdOcorrencias( "JPBARRA",jpbarra->brNumLan)
   @ Row() + 1, 0 SAY "Qtd.Ocorrências.....: " + StrZero( mQtdOcorr, 3 ) COLOR Iif( mQtdOcorr < 1, SetColor(), SetColorAlerta() )

   //SetPaintGetList( GetList )
   IF ! lEdit
      CLEAR GETS
   ELSE
      Mensagem("Digite campos, ESC sai")
      READ
      Mensagem()
      IF LastKey() != K_ESC
         WITH OBJECT ::cnMySql
            IF ::cOpc == "I"
               mbrNumLan := ::axKeyValue[1]
               IF mbrNumLan == "*NOVO*"
                  mbrNumLan := NovoCodigo( "jpbarra->brNumLan" )
               ENDIF
               :QueryAdd( "BRNUMLAN", mbrNumLan )
               :QueryAdd( "BRINFINC", mbrInfInc )
            ENDIF
            :QueryAdd( "BRPEDCOM", mbrPedCom )
            :QueryAdd( "BRITEM", mbrItem )
            :QueryAdd( "BRPEDVEN", mbrPedVen )
            :QueryAdd( "BRGARCOM", mbrGarCom )
            :QueryAdd( "BRGARVEN", mbrGarVen )
            :QueryAdd( "BRCODBAR", mbrCodBar )
            :QueryAdd( "BRCODBAR2", mbrCodBar2 )
            IF ::cOpc == "A"
               :QueryAdd( "BRINFALT", mbrInfAlt )
            ENDIF
            IF ::cOpc == "I"
               :QueryExecuteInsert( "JPBARRA" )
            ELSE
               :QueryExecuteUpdate( "JPBARRA", "BRNUMLAN=" + StringSql( mbrNumLan ) )
            ENDIF
         ENDWITH
      ENDIF
   ENDIF

   RETURN NIL

METHOD Especifico( lExiste ) CLASS PBAR0010Class

   LOCAL GetList := {}
   LOCAL mbrNumLan := jpbarra->brNumLan

   hb_Default( @lExiste, .F. )
   IF ::cOpc == "I"
      mbrNumLan := "*NOVO*"
   ENDIF
   @ Row()+1, 22 GET mbrNumLan PICTURE "@K 999999" VALID NovoMaiorZero( @mbrNumLan )
   Mensagem( "Digite campo, F9 Pesquisa, ESC Sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. ( mbrNumLan != "*NOVO*" .AND. Val( mbrNumLan ) < 1 )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK mbrNumLan
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue[1] := mbrNumLan

   RETURN .T.
