
REQUEST RunModule

#include "hbclass.ch"

FUNCTION  AppVersaoExe(); RETURN "1"
FUNCTION  AppVersaoDbf(); RETURN Val( Dtos( Date() ) )
FUNCTION  AppOdbcMysql(); RETURN 3
FUNCTION  MyUser();       RETURN ""
FUNCTION  MyPassword();   RETURN ""
FUNCTION  IsMySerialHd(); RETURN .F.
FUNCTION  pw_Criptografa( cText ) ;   RETURN cText
FUNCTION  pw_Descriptografa( cText ); RETURN cText
FUNCTION  ProximaNota(); RETURN "1"
PROCEDURE AppcnMysqlLocal
PROCEDURE CriaZip
PROCEDURE AppcnServerJpa
PROCEDURE JpegLogotipo
PROCEDURE ctplanoclass
PROCEDURE jpcadas1class
PROCEDURE jpmdfcabclass
PROCEDURE jpmotoriclass
PROCEDURE jpveiculclass
PROCEDURE jpnfbaseclass
PROCEDURE ctloteslass
PROCEDURE jpforpagclass
PROCEDURE jpagendaclass
PROCEDURE jppediclass
PROCEDURE jpitemclass
PROCEDURE AppcnJoseQuintas
PROCEDURE jpvendedclass
PROCEDURE NomeCertificado
PROCEDURE jpalogerro
PROCEDURE etcmaio
PROCEDURE pUpdateExeDown
PROCEDURE MenuAcessos
PROCEDURE EnviaEmail
PROCEDURE ctlancaclass
PROCEDURE RecalculaSinteticas
PROCEDURE estlancclass
PROCEDURE pDfeServer
PROCEDURE pedixml
PROCEDURE pedixml2
PROCEDURE jpsite
PROCEDURE pNotaVendas
PROCEDURE ctlotesclass
PROCEDURE pNotaConsProd
PROCEDURE pcontimpexcel
PROCEDURE pNotaChecagem
PROCEDURE pNotaProximas
PROCEDURE pupdateexeup
PROCEDURE pedi0260
PROCEDURE psetupempresa
PROCEDURE pSiteJPA
PROCEDURE pjpforpag
PROCEDURE pjpnfbase
PROCEDURE pDfeSalva
PROCEDURE pDfeEmail
PROCEDURE pDfeImporta
PROCEDURE pedi0150
PROCEDURE pEdiExpClarcon
PROCEDURE pretitau
PROCEDURE pedi0010
PROCEDURE pedi0040
PROCEDURE pedi0270
PROCEDURE pcontimpsped
PROCEDURE pfiscsintegra
PROCEDURE pjpagenda
PROCEDURE pjpcadas1
PROCEDURE pjpcadas1b
PROCEDURE pjpempre
PROCEDURE pcontlancpad
PROCEDURE pjplicmov
PROCEDURE ljplicmov
PROCEDURE pcontcontas
PROCEDURE pjpitem
PROCEDURE pjpitemb
PROCEDURE pjpcadas3
PROCEDURE pjpvended
PROCEDURE pjppromix
PROCEDURE pjpveicul
PROCEDURE pjpmotori
PROCEDURE pedi0060
PROCEDURE pfiscrel0030
PROCEDURE pfiscrel0010
PROCEDURE pfiscrel0040
PROCEDURE pfiscrel0100
PROCEDURE pfiscrel0110
PROCEDURE pfiscrel0120
PROCEDURE pfiscrel0050
PROCEDURE ljpforpag
PROCEDURE ljpcadas
PROCEDURE pjpanpmov
PROCEDURE pcontsped
PROCEDURE ljpcadas3
PROCEDURE pcontrel0520
PROCEDURE pcontrel0210
PROCEDURE pcontrel0010
PROCEDURE pcontrel0310
PROCEDURE pcontrel0320
PROCEDURE pcontrel0550
PROCEDURE pcontrel0530
PROCEDURE pcontrel0385
PROCEDURE pcontrel0470
PROCEDURE pcontrel0140
PROCEDURE pcontrel0080
PROCEDURE ljpitem
PROCEDURE ljpestoqb
PROCEDURE ljpestoqc
PROCEDURE pEstoRelAnalise
PROCEDURE pjpfisicab
PROCEDURE pFinanRelReceber
PROCEDURE pFinanRelMaiCli
PROCEDURE pFInanRelPagar
PROCEDURE pFinanRelMaiFor
PROCEDURE pfinanRelFluxo
PROCEDURE pcontrel0360
PROCEDURE pcontrel0270
PROCEDURE pcontrel0380
PROCEDURE pcontrel0300
PROCEDURE pcontrel0330
PROCEDURE pfiscrel0140
PROCEDURE pfiscrel0130
PROCEDURE pfiscrel0080
PROCEDURE pNotaRelRentab
PROCEDURE pNotaFicCliVen
PROCEDURE pNotaRelNotas
PROCEDURE pNotaPlanilhaG
PROCEDURE pNotaPlanilhaCV
PROCEDURE pNotaPlanilhaC
PROCEDURE pNotaRelCliVend
PROCEDURE pNotaRelPedRel
PROCEDURE pNotaRelMapa
PROCEDURE pNotaRelCompMes
PROCEDURE pNotaRelCompCli
PROCEDURE pNotaRelVendCli
PROCEDURE ljpestoqa
PROCEDURE pFinanEdReceber
PROCEDURE pfin0035
PROCEDURE pFinanBaixaPort
PROCEDURE pcontlancinclui
PROCEDURE pcontlanclote
PROCEDURE pContLancaEdit
PROCEDURE pcontfecha
PROCEDURE pcontsintetica
PROCEDURE pcontrecalculo
PROCEDURE pfiscentradas
PROCEDURE pfiscsaidas
PROCEDURE ljppedi
PROCEDURE jpacfg
PROCEDURE pestolanca2
PROCEDURE pestolanca1
PROCEDURE pEstoEntFor
PROCEDURE pjpfisicaa
PROCEDURE pEstoValEst
PROCEDURE pEstoTotArmazem
PROCEDURE pfin0045
PROCEDURE pNotaGeraNfe
PROCEDURE pPreTabComb
PROCEDURE pPreRelTabComb
PROCEDURE pPreTabCombReaj
PROCEDURE pPreRelTabGeral
PROCEDURE pPreValPercA
PROCEDURE pPreValPercC
PROCEDURE pPreRelTabMulti
PROCEDURE PFINANEDPAGAR
PROCEDURE pSetupLibera
PROCEDURE p0600ped
PROCEDURE pNotaCadastro
PROCEDURE pNotPedRetira
PROCEDURE pnotaRomaneio
PROCEDURE pjpmdf
PROCEDURE pNotaVerVendas
PROCEDURE ze_NetIoOpen
PROCEDURE ze_NetIoClose
PROCEDURE jpnotaclass
PROCEDURE jpegBancoItau
PROCEDURE UltimaEntradaItem
PROCEDURE UltimaSaidaItem
PROCEDURE CustoContabilItem
PROCEDURE pNotaPedRetira

CREATE CLASS jplicmovclass
   METHOD ShowVencidas() INLINE NIL
   ENDCLASS

CREATE CLASS Pedido
   ENDCLASS
