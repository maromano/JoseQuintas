/*
PADMINLOG - Consulta ao log do sistema
1994 - José Quintas
*/

PROCEDURE pAdminLog

   LOCAL cDbf, cnMySql := ADOClass():New( AppcnMySqlLocal() )

   IF AppcnMySqlLocal() == NIL
      IF ! AbreArquivos( "jpreguso" )
         RETURN
      ENDIF
   ELSE
      cnMySql:cSql := "SELECT * FROM JPREGUSO ORDER BY RUINFINC DESC LIMIT 5000"
      cDbf := cnMySql:SqlToDbf()
      USE ( cDbf ) ALIAS jpreguso
   ENDIF
   SELECT jpreguso
   SET ORDER TO 0
   GOTO TOP
   SKIP -15
   FazBrowse( { ;
      { "HORÁRIO",   { || Substr( jpreguso->ruInfInc, 1, 26 ) } }, ;
      { "DESCRIÇÃO", { || jpreguso->ruTexto } }, ;
      { "ARQUIVO",   { || jpreguso->ruArquivo } }, ;
      { "CÓDIGO",    { || jpreguso->ruCodigo } }, ;
      { "INFINC",    { || jpreguso->ruInfInc } } } )
   CLOSE DATABASES

   RETURN
