/*
ZE_AUXILIARNUMCLASS - CONFIGURACAO DE TABELAS NUMERICAS
2000.04.07 - José Quintas

ATENCAO!!!!!!!!!! A pesquisa F9 depende de axtabela
*/

#include "inkey.ch"
#include "hbclass.ch"

/*
PROCEDURE PAUXILIARNUM

   LOCAL oFrm := AuxiliarNumClass():New()
   MEMVAR m_Prog

   IF ! AbreArquivos( "jptabel" )
      RETURN
   ENDIF
   SELECT jptabel
   oFrm:cTabelaAuxiliar := StrZero( Val( SoNumeros( m_Prog ) ), 6 )
   SET FILTER TO jptabel->axTabela == StrZero( Val( SoNumeros( m_Prog ) ), 6 )
   oFrm:Execute()
   CLOSE DATABASES

   RETURN
*/

CREATE CLASS AuxiliarNumClass INHERIT AuxiliarClass

   VAR    cTabelaAuxiliar INIT "000000"
   METHOD TelaDados( lEdit )
   METHOD Especifico( lExiste )

   ENDCLASS

METHOD TelaDados( lEdit ) CLASS AuxiliarNumClass

   LOCAL GetList := {}
   LOCAL maxCodigo  := jptabel->axCodigo
   LOCAL maxDescri  := jptabel->axDescri
   LOCAL maxParam01 := jptabel->axParam01
   LOCAL maxParam02 := jptabel->axParam02
   LOCAL maxParam03 := jptabel->axParam03
   LOCAL maxParam04 := jptabel->axParam04
   LOCAL maxParam05 := jptabel->axParam05
   MEMVAR m_Prog

   hb_Default( @lEdit, .F. )
   IF ::cOpc == "I" .AND. lEdit
      maxCodigo := ::axKeyValue[ 1 ]
   ENDIF
   ::ShowTabs()
   @ Row()+1, 1 SAY "Código.............:" GET maxCodigo WHEN .F.
   @ Row()+2, 1 SAY "Descrição..........:" GET maxDescri PICTURE "@!" VALID ! Empty( maxDescri )
   SEEK ::cTabelaAuxiliar + maxCodigo // ref uso de DescrTab()
   //SetPaintGetList( GetList )
   IF ! lEdit
      CLEAR GETS
      RETURN NIL
   ENDIF
   Mensagem( "Digite campos, ESC sai" )
   READ
   Mensagem()
   IF LastKey() == K_ESC
      GOTO ::nUltRec
      RETURN NIL
   ENDIF
   IF ::cOpc == "I"
      IF maxCodigo != "*NOVO*"
         IF Encontra( ::cTabelaAuxiliar + maxCodigo, "jptabel", "numlan" )
            maxCodigo := "*NOVO*"
         ENDIF
      ENDIF
      IF maxCodigo == "*NOVO*"
         maxCodigo := "000001"
         DO WHILE Encontra( ::cTabelaAuxiliar + maxCodigo, "jptabel", "numlan" )
            maxCodigo := StrZero( Val( maxCodigo ) + 1, 6 )
         ENDDO
      ENDIF
      RecAppend()
      REPLACE ;
         jptabel->axTabela WITH ::cTabelaAuxiliar, ;
         jptabel->axCodigo WITH maxCodigo, ;
         jptabel->axInfInc WITH LogInfo()
      RecUnlock()
   ENDIF
   RecLock()
   REPLACE ;
      jptabel->axDescri  WITH maxDescri, ;
      jptabel->axParam01 WITH maxParam01, ;
      jptabel->axParam02 WITH maxParam02, ;
      jptabel->axParam03 WITH maxParam03, ;
      jptabel->axParam04 WITH maxParam04, ;
      jptabel->axParam05 WITH maxParam05, ;
      jptabel->axInfAlt  WITH LogInfo()
   RecUnlock()

   RETURN NIL

METHOD Especifico( lExiste ) CLASS AuxiliarNumClass

   LOCAL GetList := {}
   LOCAL maxCodigo := jptabel->axCodigo
   MEMVAR m_Prog

   IF ::cOpc == "I"
      maxCodigo = "*NOVO*"
   ENDIF
   @ Row()+1, 22 GET maxCodigo PICTURE "@K 999999" VALID NovoMaiorZero( @maxCodigo )
   Mensagem( "Digite código para cadastro, F9 pesquisa, ESC volta" )
   READ
   Mensagem()
   IF LastKey() == K_ESC .OR. ( Val( maxCodigo ) == 0 .AND. maxCodigo != "*NOVO*" )
      GOTO ::nUltRec
      RETURN .F.
   ENDIF
   SEEK ::cTabelaAuxiliar + maxCodigo
   IF ! ::EspecificoExiste( lExiste, Eof() )
      RETURN .F.
   ENDIF
   ::axKeyValue := { maxCodigo }

   RETURN .T.

// Usada nos programas para retornar descricao da tabela

FUNCTION DescrTab( mCodigo, mTabela )

   Encontra( StrZero( mTabela, 6 ) + Left( mCodigo, 6 ), "jptabel", "numlan" )

   RETURN Left( jptabel->axDescri, 60 )


* Usada para validar tabelas
* Usada nos programas para pesquisa de tabelas

FUNCTION EscolheTab( mTabela, mLin, mCol, mCodigo )

   LOCAL cOrdSetFocus, mSelect := Select(), mFound
   MEMVAR m_Prog

   hb_Default( @mCodigo, "" )
   hb_Default( @mLin, 0 )
   hb_Default( @mCol, 0 )

   SELECT jptabel
   cOrdSetFocus := OrdSetFocus( "numlan" )
   WSave()
   mFound := Encontra( mTabela + mCodigo, "jptabel", "numlan" )
   OrdSetFocus( "descricao" )
   IF LastKey() == K_F9 .OR. Val( mCodigo ) == 0 .OR. ! mFound
      Encontra( mTabela, "jptabel" )
   ENDIF

   FazBrowse( { { "Descrição", { || jptabel->axDescri } },{ "Código", { || jptabel->axCodigo } } },, mTabela )

   IF LastKey() != K_ESC .AND. ! Eof()
      IF Val( mTabela ) == 4
         KEYBOARD Left( jptabel->axCodigo, 1 ) + Chr( K_ENTER )
      ELSE
         KEYBOARD jptabel->axCodigo + Chr( K_ENTER )
      ENDIF
   ENDIF
   OrdSetFocus( cOrdSetFocus )
   SELECT ( mSelect )
   WRestore()

   RETURN .T.


// 0) Nome das tabelas
// 1) xxxxx Empresas/filiais
// 2) ---
// 3) Grupo de Cliente
// 4) ---
// 5) ---
// 6) ---
// 7) ---
// 8) ---
// 9) -----
// 10) -----
// 11) -----
// 12) -----
// 13) -----
// 14) ---
// 15) -----
// 16) ---
// 17) ---------------
// 18) Status (Cliente)
// 19) Status de OS
// 20) Codigo de Irregularidades (Carta de Correcao)
// 21) Conversao Contabil RM
// 22) ---
// 23) Portador (Cliente)
// 24) -----
// 25) -----
// 26) -----
// 27) Banco
// 28) Centro de Custo
// 29) Operacao (C.Pagar/C.Receber)
// 30 ---- Tipos de Valores (Caixa)
// 31) Status de OS interno
// 32) Modelo de Doc.Fiscal
// 33) -----
// 34) Tipos de Boleto/Duplicata
// 35 ---- Percentuais p/ reajuste de tabelas
// 36 ---- Forma de Pagamento
// 37 ---- Marcas de cartao de credito
// 38) Nomes de financeiras
// 39) -----
// 40) Motivos de cancelamento
// 41 ---- Bancos/Contas da empresa
// 42 ---- Departamentos de estoque
// 43 ---- Contagem Fisica
// 44 ---- Titulo da tabela de precos
// 45) ---
// 46 ---
// 47) ---Cta.Adm.Contabil
// 48) --------
// 49) --------
// 50) CPUID + Serie HD
// 51) Doc.Identificacao (Portaria)
// 52 ----
// 53) Status Tarefas
// 54) ---
// 59) --------
// 60) --------
// 61) --------
// 62) --------
// 63) --------
// 64) --------
// 65) --------
// 66) --------
// 67) --------
// 68) --------
// 69) --------
// 70) --------
// 71 ----------
// 72 ----------
// 73 ----------
// 74 ----------
// 75 ----------
// 76 ----------
// 77 ----------
// 78 ----------
// 80 ---- Bloqueios de pedido-ant.43
// 81) ---
// 82) Moedas
// 83) --------
// 84) --------
// 85) --------
// 86 ----
// 87) Tipos de Servico
// 88) Valores de demonstrativo (Debitos ate 500000 e creditos acima)
// 89) Valores de demonstrativo (Codigo reservado para uso junto com o 88)
// 90) ---------
// 91) Tributacao da Empresa
// 92) -----
// 93) --------
// 94) ------
// 95) ----------
// 96) Configuracao de EDI
// 97) Aparelho pra OS
*----------------------------------------------------------------
