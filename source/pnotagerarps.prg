/*
PNOTAGERARPS - GERA ARQUIVOS RPS/NFS-E
2011.08 José Quintas
*/

#include "inkey.ch"

PROCEDURE pNotaGeraRps

   LOCAL mnfNotFisi, mnfNotFisf, mTxtFile, nVlTotal, GetList := {}, mDatEmi, nQtTotal

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
   SELECT jpnota
   OrdSetFocus( "notas1" )
   GOTO BOTTOM
   mnfNotFisF := jpnota->nfNotFis
   mnfNotFisI := jpnota->nfNotFis
   mDatEmi    := jpnota->nfDatEmi
   DO WHILE jpnota->nfDatEmi == mDatEmi .AND. ! Bof()
      mnfNotFisI := jpnota->nfNotFis
      SKIP -1
   ENDDO
   DO WHILE .T.
      @ 1, 1 SAY ""
      @ Row() + 1, 1 SAY "Número Inicial......:" GET mnfNotFisI PICTURE "@K 999999999" VALID FillZeros( @mnfNotFisI )
      @ Row() + 1, 1 SAY "Número Final........:" GET mnfNotFisF PICTURE "@K 999999999" VALID FillZeros( @mnfNotFisF )
      Mensagem("Digite numeração, ESC Sai")
      READ

      IF LastKey() == K_ESC
         RETURN
      ENDIF

      IF ! MsgYesNo( "Confirma" )
         RETURN
      ENDIF

      Mensagem( "Aguarde... em processamento" )

      SELECT jpnota
      OrdSetFocus( "notas1" )
      SEEK StrZero( 2, 6 ) + mnfNotFisI
      IF Eof()
         MsgWarning( "Número inicial inválido" )
         LOOP
      ENDIF

      mTxtFile := "EXPORTA\NF" + Substr( Dtos( Date() ), 3 ) + ".TXT"
      SET ALTERNATE TO ( mTxtFile )
      SET ALTERNATE ON
      SET CONSOLE OFF
      // -----Cabecalho-----
      ?? "1" // Cabecalho
      ?? "001" // Layout
      ?? SoNumeros( jpempre->emInsMun ) // CCM 8 digitos
      ?? Dtos( jpnota->nfDatEmi ) // Data Inicial
      ?? Dtos( jpnota->nfDatEmi ) // Data Final
      ?? hb_eol()
      // ----- -----

      nQtTotal := 0
      nVlTotal := 0
      DO WHILE jpnota->nfFilial == StrZero( 2, 6 ) .AND. jpnota->nfNotFis <= mnfNotFisF .AND. ! Eof()

         // ----- Detalhe -----
         Encontra( jpnota->nfCadDes, "jpcadas", "numlan" )
         ?? "2" // Detalhe
         ?? Pad( "RPS", 5 ) // Recibo Provisorio de Servicos
         ?? Pad( "A", 5 ) // Serie
         ?? StrZero( Val( jpnota->nfNotFis ), 12 ) // Numero RPS
         ?? Dtos( jpnota->nfDatEmi ) // Emissao
         ?? "T" // operacao normal
         ?? StrZero( jpnota->nfValNot * 100, 15 ) // Valor da nota
         ?? StrZero( 0, 15 ) // Deducoes
         ?? "02692"  // Proc Dados e Congeneres - Codigo do Servico Prestado
         ?? "0500" // Aliquota
         ?? "2" // Sem ISS Retido
         ?? "2" // PJ/CNPJ
         ?? SoNumeros( jpcadas->cdCnpj ) // Cnpj
         ?? StrZero( 0, 8 ) // CCM
         ?? StrZero( Val( SoNumeros( jpcadas->cdInsEst ) ), 12 ) // Insc.Est.
         ?? Pad( jpcadas->cdNome, 75 )
         ?? Pad( ".", 3 )
         ?? pad( jpcadas->cdEndereco, 50 )
         ?? Pad( ".", 10 ) // Numero
         ?? Pad( "", 30 ) // Complemento
         ?? Pad( jpcadas->cdBairro, 30 )
         ?? Pad( jpcadas->cdCidade, 50 )
         ?? jpcadas->cdUf // Uf com 2
         ?? SoNumeros( jpcadas->cdCep ) // CEP com 8
         ?? Pad( "", 75 ) // Email
         ?? "SERVICOS PRESTADOS"
         ?? hb_eol()
         // ----- -----
         nQtTotal += 1
         nVlTotal += jpnota->nfValNot
         SKIP
      ENDDO

      // ----- Rodape -----
      ?? "9" // Rodape
      ?? StrZero( nQtTotal, 7 ) // Qtde registros
      ?? StrZero( nVlTotal * 100, 15 ) // Valor Total
      ?? StrZero( 0, 15 ) // Total Deducoes
      ?? hb_eol()
      SET ALTERNATE OFF
      SET CONSOLE ON
      SET ALTERNATE TO
      MsgExclamation( "Gerada(s) " + LTrim( Str( nQtTotal ) ) + " NF(s) em " + mTxtFile )

   ENDDO

   RETURN
