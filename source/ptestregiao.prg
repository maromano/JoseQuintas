/*
PTESTREGIAO
José Quintas
*/

PROCEDURE PTESTREGIAO

   LOCAL cRegiao, cTmpFile

   IF ! AbreArquivos( "jpfinan", "jpcadas" )
      RETURN
   ENDIF
   cTmpFile := { MyTempFile( "cdx" ), MyTempFile( "csv" ) }
   SELECT jpfinan
   OrdSetFocus( "cliente" )
   SET FILTER TO Year( jpfinan->fiDatEmi ) > 2012
   SELECT jpcadas
   INDEX ON pTesCodigoRegiao( jpcadas->cdCep ) + jpcadas->cdCep TO ( cTmpFile[ 1 ] )
   SET FILTER TO TemMovimento()
   GOTO TOP
   SET ALTERNATE TO ( cTmpFile[ 2] )
   SET ALTERNATE ON
   DO WHILE ! Eof()
      cRegiao := pTesCodigoRegiao( jpcadas->cdCep )
      DO WHILE cRegiao == pTesCodigoRegiao( jpcadas->cdCep ) .AND. ! Eof()
         ?? Substr( cRegiao, 1, 2 ) + Chr(9)
         ?? Substr( cRegiao, 6 ) + Chr(9)
         ?? jpcadas->cdCodigo + Chr(9)
         ?? jpcadas->cdNome + Chr(9)
         ?? jpcadas->cdCep + Chr(9)
         ?? jpcadas->cdEndereco + Chr(9)
         ?? jpcadas->cdBairro + Chr(9)
         ?? jpcadas->cdCidade + Chr(9)
         ?
         SKIP
      ENDDO
   ENDDO
   SET ALTERNATE OFF
   SET ALTERNATE TO
   CLOSE DATABASES
   ShellExecuteOpen( cTmpFile[ 2 ] )
   fErase( cTmpFile[ 1 ] )

   RETURN

FUNCTION pTesCodigoRegiao( cCep )

   LOCAL oRegioes := {}, cRegiao := "XX", oElement

   AAdd( oRegioes, { "B2", "010", "CENTRO (SE E REPUBLICA)" } )
   AAdd( oRegioes, { "B2", "011", "BOM RETIRO" } )
   AAdd( oRegioes, { "B2", "012", "VILA BUARQUE E SUMARE" } )
   AAdd( oRegioes, { "A1", "013", "CONSOLACAO" } )
   AAdd( oRegioes, { "B2", "014", "JARDINS" } )
   AAdd( oRegioes, { "B2", "015", "LIBERDADE" } )
   AAdd( oRegioes, { "B1", "020", "SANTANA E VILA GUILHERME" } )
   AAdd( oRegioes, { "B1", "021", "VILA MARIA" } )
   AAdd( oRegioes, { "B1", "022", "JACANA E TUCURUVI" } )
   AAdd( oRegioes, { "B1", "023", "TREMEMBE" } )
   AAdd( oRegioes, { "B1", "024", "MANDAQUI" } )
   AAdd( oRegioes, { "B1", "025", "CASA VERDE" } )
   AAdd( oRegioes, { "B1", "026", "CACHOEIRINHA" } )
   AAdd( oRegioes, { "B1", "027", "LIMAO" } )
   AAdd( oRegioes, { "B1", "028", "BRASILANDIA" } )
   AAdd( oRegioes, { "B1", "029", "FREGUESIA DO O" } )
   AAdd( oRegioes, { "B1", "030", "BRAS E PQ S JORGE" } )
   AAdd( oRegioes, { "B2", "031", "MOOCA E V PRUDENTE" } )
   AAdd( oRegioes, { "B2", "032", "SAO LUCAS" } )
   AAdd( oRegioes, { "B2", "033", "ANALIA FRANCO E V FORMOSA" } )
   AAdd( oRegioes, { "B2", "034", "CARRAO E ARICANDUVA" } )
   AAdd( oRegioes, { "B2", "035", "VILA MATILDE" } )
   AAdd( oRegioes, { "B1", "036", "PENHA" } )
   AAdd( oRegioes, { "B1", "037", "CANGAIBA" } )
   AAdd( oRegioes, { "B1", "038", "ERMELINO MATARAZZO" } )
   AAdd( oRegioes, { "B2", "039", "SAO MATEUS" } )
   AAdd( oRegioes, { "D2", "040", "V MARIANA (OESTE) E MOEMA" } )
   AAdd( oRegioes, { "B2", "041", "V MARIANA (LESTE) E SAUDE" } )
   AAdd( oRegioes, { "B2", "042", "IPIRANGA" } )
   AAdd( oRegioes, { "B2", "043", "JABAQUARA" } )
   AAdd( oRegioes, { "B2", "044", "CIDADE ADEMAR" } )
   AAdd( oRegioes, { "B2", "045", "ITAIM BIBI" } )
   AAdd( oRegioes, { "B2", "046", "CAMPO BELO" } )
   AAdd( oRegioes, { "B2", "047", "SANTO AMARO" } )
   AAdd( oRegioes, { "B3", "048", "CIDADE DUTRA, GRAJAU E PARELHEIROS" } )
   AAdd( oRegioes, { "B3", "049", "GUARAPIRANGA" } )
   AAdd( oRegioes, { "B1", "050", "LAPA E PERDIZES"} )
   AAdd( oRegioes, { "B1", "051", "PIRITUBA E JARAGUA" } )
   AAdd( oRegioes, { "B1", "052", "PERUS" } )
   AAdd( oRegioes, { "B2", "053", "JAGUARE E LEOPOLDINA" } )
   AAdd( oRegioes, { "B2", "054", "PINHEIROS" } )
   AAdd( oRegioes, { "B1", "055", "BUTANTA (RAPOSO TAVARES" } )
   AAdd( oRegioes, { "B1", "056", "MORUMBI" } )
   AAdd( oRegioes, { "A2", "057", "CAMPO LIMPO" } )
   AAdd( oRegioes, { "B2", "058", "CAPAO REDONDO" } )
   AAdd( oRegioes, { "A2", "060", "OSASCO" } )
   AAdd( oRegioes, { "B2", "061", "OSASCO" } )
   AAdd( oRegioes, { "A1", "062", "OSASCO" } )
   AAdd( oRegioes, { "A2", "063", "CARAPICUIBA" } )
   AAdd( oRegioes, { "A1", "064", "BARUERI" } )
   AAdd( oRegioes, { "A1", "065", "SANTANA DO PARNAIBA" } )
   AAdd( oRegioes, { "A2", "066", "JANDIRA, ITAPEVI" } )
   AAdd( oRegioes, { "A2", "067", "TABOAO DA SERRA, COTIA, VARGEM GRANDE" } )
   AAdd( oRegioes, { "A2", "068", "ITAPECERICA DA SERRA, EMBU" } )
   AAdd( oRegioes, { "A3", "069", "EMBU-GUACU" } )
   AAdd( oRegioes, { "B1", "070", "GUARULHOS" } )
   AAdd( oRegioes, { "D1", "071", "GUARULHOS" } )
   AAdd( oRegioes, { "D1", "072", "GUARULHOS" } )
   AAdd( oRegioes, { "D1", "073", "GUARULHOS" } )
   AAdd( oRegioes, { "D1", "074", "ARUJA" } )
   AAdd( oRegioes, { "D1", "075", "SANTA ISABEL" } )
   AAdd( oRegioes, { "B1", "076", "MARIPORA" } )
   AAdd( oRegioes, { "A1", "077", "CAIEIRAS, CAJAMAR, POLVINHO, JORDANESIA" } )
   AAdd( oRegioes, { "B1", "078", "FRANCO DA ROCHA" } )
   AAdd( oRegioes, { "B1", "079", "FRANCISCO MORATO" } )
   AAdd( oRegioes, { "B1", "080", "SAO MIGUEL" } )
   AAdd( oRegioes, { "D1", "081", "ITAIM PAULISTA" } )
   AAdd( oRegioes, { "B2", "082", "ITAQUERA" } )
   AAdd( oRegioes, { "B2", "083", "SAO RAFAEL" } )
   AAdd( oRegioes, { "D2", "084", "GUAIANASES" } )
   AAdd( oRegioes, { "D1", "085", "FERRAZ DE VASCONCELOS, POA, ITAQUAQUECETUBA" } )
   AAdd( oRegioes, { "D2", "086", "SUZANO" } )
   AAdd( oRegioes, { "D2", "087", "MOGI DAS CRUZES" } )
   AAdd( oRegioes, { "D2", "088", "MOGI DAS CRUZES" } )
   AAdd( oRegioes, { "D2", "089", "GUARAREMA" } )
   AAdd( oRegioes, { "B2", "090", "SANTO ANDRE" } )
   AAdd( oRegioes, { "B2", "091", "SANTO ANDRE" } )
   AAdd( oRegioes, { "B2", "092", "SANTO ANDRE" } )
   AAdd( oRegioes, { "C2", "093", "MAUA" } )
   AAdd( oRegioes, { "D2", "094", "RIBEIRAO PIRES, RIO GRANDE DA SERRA" } )
   AAdd( oRegioes, { "B2", "095", "SAO CAETANO DO SUL" } )
   AAdd( oRegioes, { "C2", "096", "SAO BERNARDO DO CAMPO" } )
   AAdd( oRegioes, { "C3", "097", "SAO BERNARDO DO CAMPO" } )
   AAdd( oRegioes, { "C3", "098", "SAO BERNARDO DO CAMPO" } )
   AAdd( oRegioes, { "OUT", "099", "DIADEMA" } )
   FOR EACH oElement IN oRegioes
      IF Substr( cCep, 1, 3 ) == oElement[ 2 ]
         cRegiao := Pad( oElement[ 1 ] + " - " + oElement[ 3 ], 50 )
         EXIT
      ENDIF
   NEXT

   RETURN cRegiao

STATIC FUNCTION TemMovimento()

   LOCAL nSelect, lReturn

   nSelect := Select()
   SELECT jpfinan
   SEEK jpcadas->cdCodigo
   lReturn := ( ! "***" $ jpcadas->cdNome .AND. ! Eof() )
   SELECT ( nSelect )

   RETURN lReturn
