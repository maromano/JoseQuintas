PROCEDURE PTESValidaXml

   LOCAL cRetorno, cFileXsd, cXml

   cFileXsd := "D:\cdrom\FONTES\INTEGRA\schemmas\PL_MDFe_300_NT032017\" + ;
               "mdfe_v3.00.xsd"
   cXml     := MemoRead( "d:\temp\mdfe.xml" )

   cRetorno := SefazClass():ValidaXml( cXml, cFileXsd )
   ? cRetorno
   Inkey(0)

   RETURN

