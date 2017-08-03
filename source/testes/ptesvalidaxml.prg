PROCEDURE PTESValidaXml

   LOCAL cRetorno, cFileXsd, cXml

   cFileXsd := hb_Cwd() + "schemmas\"
   cFileXsd += "pl_008i2_cfop_externo\nfe_v3.10.xsd"
   //cFileXsd += "pl_cte_200a_nt2015.004\cte_v2.00.xsd"
   //cFileXsd += "pl_mdfe_100a\mdfe_v1.00.xsd"
   //cFileXsd += "pl_mdfe_300\mdfe_v3.00.xsd"

   cXml     := MemoRead( "d:\jpa\cordeiro\nfe\tmp\nf000094053-02-assinado.xml" )

   cRetorno := SefazClass():ValidaXml( cXml, cFileXsd )
   ? cRetorno
   Inkey(0)

   RETURN

