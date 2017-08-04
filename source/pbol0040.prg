
* PROGRAMA...: PBOL0040 - GERA TXT PRA BOLETOS ITAU AVULSO      *
* CRIACAO....: 10.04.12 - JOSE                                  *


* ...
* 2014.09.25.1055 - Carteira default Maringa 157
* 2014.11.27.1000 - Default Itaú voltou pra 109 Maringá


#include "josequintas.ch"
#include "inkey.ch"

PROCEDURE PBOL0040

   LOCAL GetList := {}, mDir, mDirItau, nCont, mIdade, mFileTxt, mPrimeira, mLetra, mFilial, mCliente
   MEMVAR mAgencia, mConta, mCarteira, mTaxaBoleto, mtxJuros, mDocBanco, mQtRegs, mValor, mDatVen

   IF ! AbreArquivos( "jpconfi", "jptabel", "jpempre", "jpcadas", "jpfinan", "jpnota" )
      RETURN
   ENDIF
SELECT jpcadas

mDirItau := "ITAU\"
// Apaga arquivos antigos
mDir := Directory(mDirItau+"I*.TXT")
FOR nCont = 1 TO Len(mDir)
   mIdade := ( Date() - mDir[nCont,3] )
   IF mIdade > 60
      fErase(mDirItau+mDir[nCont,1])
   ENDIF
NEXT

mFileTxt := "I" + Substr(Dtos(Date()),3)
mLetra := 65 // "A"
DO WHILE File( mDirItau+mFileTxt + Chr( mLetra ) + ".txt" )
   mLetra += 1
ENDDO
mFileTxt := mFileTxt + Chr(mLetra) + ".txt"

SET ALTERNATE TO (mDirItau+mFileTxt)

mQtRegs   := 1 // Qtde. Registros
mDocBanco := Pad(LeCnf("BOLETO NOSSO"),6)
mTxJuros  := Val(LeCnf("BOLETO JUROS"))
mAgencia  := Pad(LeCnf("BOLETO AGENCIA"),4)
mConta    := Pad(LeCNf("BOLETO CONTA"),6)
mCarteira := "109"
IF AppEmpresaApelido() == "CORDEIRO"
   mFilial := StrZero(3,6)
ELSEIF AppEmpresaApelido() == "JPA"
   mFilial := StrZero(2,6)
ELSE
   IF AppEmpresaApelido() == "MARINGA"
      //mCarteira := "157"
   ENDIF
   mFilial := StrZero(1,6)
ENDIF

mPrimeira := .T.
mTaxaBoleto := 0
mDatVen := Ctod("")

mDocBanco := StrZero(Val(LeCnf("BOLETO NOSSO"))+1,6)
DO WHILE .T.
   mCliente := Space(6)
   mValor   := 0
   SELECT jpfinan
   @ 20, 1 SAY "SENDO GRAVADO EM " + mFileTxt
   @ 6, 1  SAY "Agência.........:" GET mAgencia  PICTURE "@K 9999" WHEN mPrimeira
   @ 7, 1  SAY "Conta...........:" GET mConta    PICTURE "@K 999999" WHEN mPrimeira
   @ 8, 1  SAY "Nosso Número....:" GET mDocBanco PICTURE "@K 999999" VALID FillZeros( @mDocBanco ) WHEN mPrimeira
   @ 9, 1  SAY "Juros Mensais(%):" GET mTxJuros  PICTURE "999.99" VALID mTxJuros > 0 WHEN mPrimeira
   @ 10, 1 SAY "Carteira........:" GET mCarteira PICTURE "999" VALID FillZeros(@mCarteira) WHEN mPrimeira
   @ 11, 1 SAY "Filial..........:" GET mFilial   PICTURE "@K 999999" VALID AuxFilialClass():Valida( @mFilial ) WHEN mPrimeira
   IF "MARINGA" $ AppEmpresaApelido()
      @ 12, 1 SAY "Taxa de Boleto..:" GET mTaxaBoleto PICTURE "99999999.99" VALID mTaxaBoleto >= 0 WHEN mPrimeira
   ENDIF
   @ 12, 1 SAY "Cliente.........:" GET mCliente PICTURE "@K 999999" VALID JPCADAS1Class():Valida( @mCliente )
   @ 13, 1 SAY "Valor...........:" GET mValor   PICTURE PicVal(14,2)
   @ 14, 1 SAY "Vencimento......:" GET mDatVen
   READ
   IF LastKey() == K_ESC
      EXIT
   ENDIF
   IF Encontra(mDocBanco,"jpfinan","numbanco")
      MsgWarning( "ATENCAO! Num.Bancario ja utilizado, ou emissao em duas maquinas, somando 10 ao num.bancario!" )
      IF Val(mDocBanco) > 999900
         mDocBanco := StrZero(1,6)
      ELSE
         mDocBanco := StrZero(Val(mDocBanco)+10,6)
      ENDIF
      OrdSetFocus("numlan")
      mPrimeira := .T.
      LOOP
   ENDIF
   mPrimeira := .F.
   Encontra( AUX_FINPOR + jpcadas->cdPortador, "jptabel", "numlan" )
   IF ! "ITAU" $ jptabel->axDescri .OR. "DEPOSITO" $ "ITAU"
      IF ! MsgYesNo("Portador e' " + Trim( jptabel->axDescri ) + ". Continua?")
         LOOP
      ENDIF
   ENDIF
   IF mQtRegs == 1
      TxtItau("I")
   ENDIF
   TxtItau("D")
   mDocBanco := StrZero(Val(mDocBanco)+1,6)
   GravaCnf("BOLETO NOSSO",StrZero(Val(mDocBanco)-1,6)) // Corrigido
ENDDO
TxtItau("F")
SET ALTERNATE TO
fDelEof(mDirItau+mFileTxt)
IF mQtRegs < 4 // Não tem conteudo
   fErase(mDirItau+mFileTxt)
   MsgWarning("Arquivo sem conteudo")
ELSE
   GravaCnf("BOLETO JUROS",LTrim(Str(mTxJuros)))
   GravaCnf("BOLETO AGENCIA",mAgencia)
   GravaCnf("BOLETO CONTA",mConta)
   MsgExclamation("Gerado arquivo " + mFileTxt)
ENDIF
CLOSE DATABASES
RETURN



STATIC FUNCTION TxtItau(mTipoReg)
   LOCAL mTxtDocto, mCnpj
   MEMVAR mAgencia, mConta, mCarteira, mTaxaBoleto, mtxJuros, mDocBanco, mQtRegs, mValor, mDatVen

mTxtDocto := "SERVICOS"

SET ALTERNATE ON
SET CONSOLE OFF

DO CASE
CASE mTipoReg == "I" // Inicial
   ?? "0"
   ?? "1"
   ?? "REMESSA"
   ?? "01"
   ?? Pad("COBRANCA",15)
   ?? mAgencia
   ?? "00"
   ?? Substr(mConta,1,Len(mConta)-1)
   ?? Substr(mConta,Len(mConta),1)
   ?? Space(8)
   ?? Pad(AppEmpresaNome(),30)
   ?? "341"
   ?? Pad("BANCO ITAU S/A",15)
   ?? StrZero(Day(Date()),2)+StrZero(Month(Date()),2)+StrZero(Year(Date())-2000,2)
   ?? Space(294)
   ?? StrZero(mQtRegs,6)
   ?
CASE mTipoReg == "F" // Final
   ?? "9"
   ?? Space(393)
   ?? StrZero(mQtRegs,6)
   ?
CASE mTipoReg == "D"
   mValor := mValor + mTaxaBoleto
   ?? "1"
   ?? "02" // 04=CNPJ EMPRESA
   ?? StrZero(Val(SoNumeros(jpempre->emCnpj)),14)
   ?? mAgencia
   ?? "00"
   ?? Substr(mConta,1,Len(mConta)-1)
   ?? Substr(mConta,Len(mConta),1)
   ?? Space(4)
   ?? Space(4) // Nota 27
   ?? Pad("SUPORTE",25)
   // ?? Space(25) // Titulo na empresa
   IF mCarteira == "112"
      ?? Space(8) // Escritural, o Itau ira' preencher
   ELSE
      ?? StrZero(Val(mDocBanco),8) // Direta, sequencial
   ENDIF
   ?? StrZero(0,13) // Outra moeda
   ?? mCarteira // "109"
   ?? Space(21)
   ?? "I" // Nota 5
   ?? "01" // Remessa - Nota 6
   ?? Right(mTxtDocto,10) // Nota 18
   ?? StrZero(Day(mDatVen),2)+StrZero(Month(mDatVen),2)+StrZero(Year(mDatVen)-2000,2)
   ?? StrZero(mValor*100,13)
   ?? "341"
   ?? StrZero(0,5) // Nota 9 - Agencia cobradora
   ?? "01" // Cordeiro - Duplicata Mercantil
   ?? "N"  // Aceite
   ?? StrZero(Day(Date()),2)+StrZero(Month(Date()),2)+StrZero(Year(Date())-2000,2)
   ?? "  " // Instrucao Nota 11 - mensagens
   ?? "  " // Instrucao Nota 11 - mensagens
   ?? StrZero(mValor*mTxJuros/30,13)
   ?? "      " // Data limite pra desconto
   ?? StrZero(0,13) // Desconto a ser concedido - nota 13
   ?? StrZero(0,13) // IOF recolhido - nota 14
   ?? StrZero(0,13) // Abatimento concedido - nota 13
   mCnpj := SoNumeros(jpcadas->cdCnpj)
   IF Len(mCnpj) <= 11
      ?? "01"
   ELSE
      ?? "02" // 01=CPF 02=CNPJ
   ENDIF
   ?? StrZero(Val(mCnpj),14)
   ?? Pad(jpcadas->cdNome,30)
   ?? Space(10) // Nota 15
   ?? Pad(Trim(jpcadas->cdEndCob)+" "+Trim(jpcadas->cdNumCob)+" "+Trim(jpcadas->cdComCob),40)
   ?? Pad(jpcadas->cdBaiCob,12)
   ?? StrZero(Val(SoNumeros(jpcadas->cdCepCob)),8)
   ?? Pad(jpcadas->cdCidCob,15)
   ?? jpcadas->cdUfCob
   ?? Space(30)
   ?? Space(4)
   ?? StrZero(Day(mDatVen),2) + StrZero(Month(mDatVen),2) + StrZero(Year(mDatVen)-2000,2) // Data de mora
   ?? StrZero(0,2) // Qtd.Dias - nota 11
   ?? Space(1)
   ?? StrZero(mQtRegs,6)
   ?

   // Mensagens adicionais

//   mQtRegs += 1
//   ?? "5"
//   ?? Space(350)
//   ?? Pad("Apos vencto, www.itau.com.br/boletos",40) // maximo 40
//   ?? Space(3)
//   ?? StrZero(mQtRegs,6)
//   ?

ENDCASE
mQtRegs += 1
SET ALTERNATE OFF
SET CONSOLE   ON

RETURN NIL

