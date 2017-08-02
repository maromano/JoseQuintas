/*
ZE_FUNC - FUNCOES DE USO GERAL
1992.12.13

...
2015.11.22.0810 - Validação e picture do CEST
2015.01.05.1140 - Aceita preencher IE com NAOCONTRIBUINTE
2016.08.29.1722 - Mais precaução em DelTempFiles()
2016.11.07:0800 - Somar tempo à hora
2016.11.14.1030 - Correção do cálculo de somar tempo
2017.04.20.1800 - RangeDefault()
*/

#include "inkey.ch"
#include "set.ch"
#include "fileio.ch"
#include "hbgtinfo.ch"
#include "hbclass.ch"
#include "directry.ch"

PROCEDURE ClearGets // * Atencao: Usado no contábil

   MEMVAR GetList

   CLEAR GETS

   RETURN

FUNCTION FDelEof( mFile )

   LOCAL nHandle

   nHandle = fOpen( mFile, 2 )
   fSeek( nHandle, -1, 2 )
   Fwrite( nHandle, "" )
   fClose( nHandle )

   RETURN NIL

FUNCTION MyDescend( cText )

   LOCAL cResult, acAscii := {}, nCont
   STATIC cFrom, cTo

   IF cFrom == NIL .OR. cTo == NIL
      FOR nCont = 1 TO 255
         Aadd( acAscii, Chr( nCont ) )
      NEXT
      ASort( acAscii )
      cFrom := cTo := ""
      FOR nCont = 1 TO 255
         cFrom += acAscii[ nCont ]
         cTo   += acAscii[ 256 - nCont ]
      NEXT
   ENDIF
   cResult := hb_StrReplace( cText, cFrom, cTo )

   RETURN cResult

FUNCTION PlayHappyBirthDay()

   // Compile and run this only on your brithday!
   // e-mail: cautere@innet.be  (Jos Cautereels)
   LOCAL oElement
   LOCAL aNotas := { { 392, 3 }, { 392, 1 }, { 440, 4 }, { 392, 4 }, ;
                { 523.3, 4 }, { 493.9, 8 }, { 392, 3 }, { 392, 1 }, ;
                { 440, 4 }, { 392, 4 }, { 523.3, 4 }, { 493.9, 8 }, ;
                { 393, 3 }, { 392, 1 }, { 784, 4 }, { 659.2, 4 }, ;
                { 523.3, 4 }, { 493, 4 }, { 440, 4 }, { 698.4, 3 }, ;
                { 698.4, 1 }, { 659.2, 4 }, { 523.3, 4 }, { 587.4, 4 }, ;
                { 523.4, 8 } }

   FOR EACH oElement IN aNotas
      Tone( oElement[ 1 ], oElement[ 2 ] * 2 )
      IF Inkey() == K_ESC
         EXIT
      ENDIF
   NEXT

   RETURN NIL

FUNCTION GetValidIE( cInscricao, cUF )

   LOCAL lOk := .T.

   IF cInscricao == Pad( "ISENTO", Len( cInscricao ) )
      RETURN .T.
   ELSEIF cInscricao == Pad( "NAOCONTRIBUINTE", Len( cInscricao ) )
      RETURN .T.
   ELSEIF Val( SoNumeros( cInscricao ) ) == 0
      MsgWarning( "Digite ISENTO, NAOCONTRIBUINTE ou o número da inscrição estadual!" )
      lOk := .F.
   ELSEIF ! ValidIE( @cInscricao, cUf )
      IF ! MsgYesNo( "Inscrição estadual inválida! Aceita?" )
         lOk := .F.
      ENDIF
   ENDIF

   RETURN lOk

FUNCTION ValidNCM( mNCM )

   LOCAL lOk := .T.

   IF Len( Trim( mNCM ) ) != 8
      MsgWarning( "NCM Inválido. Obrigatório com 8 dígitos" )
      lOk := .F.
   ENDIF

   RETURN lOk

FUNCTION PicNCM()

   RETURN "@R 9999.99.99"

FUNCTION ValidCEST( mCEST )

   IF Empty( mCEST ) .OR. Len( SoNumeros( mCEST ) ) == 7
      RETURN .T.
   ENDIF
   MsgWarning( "CEST Inválido. Aceito código em branco ou com 7 dígitos" )

   RETURN .F.

FUNCTION PicCEST()

   RETURN "@R 99.999.99"

FUNCTION GetValidCnpjCpf( cCnpj, lAceitaErrado )

   LOCAL lOk := .T.

   hb_Default( @lAceitaErrado, .T. )
   cCnpj         := SoNumeros( cCnpj )
   IF LastKey() != K_UP
      IF Len( cCnpj ) != 11 .AND. Len( cCnpj ) != 14
         lOk := .F.
      ELSEIF ! ValidCnpjCpf( cCnpj )
         lOk := .F.
      ENDIF
      IF ! lOk
         IF lAceitaErrado
            IF MsgYesNo( "Número não e CNPJ nem CPF. Aceita?" )
               lOk := .T.
            ENDIF
         ELSE
            MsgStop( "CNPJ ou CPF inválido!" )
         ENDIF
      ENDIF
   ENDIF
   cCnpj := Pad( FormatCnpj( cCnpj ), 18 )

   RETURN lOk

FUNCTION TrechoJust( mTexto, mColunas )

   LOCAL nPos, mTexto2

   nPos = Rat( " ", Left( mTexto + " ", mColunas+1 ) )
   IF nPos == 0
      nPos = mColunas + 1
   ENDIF
   mTexto2 = Left( mTexto, nPos - 1 )
   mTexto  = LTrim( Substr( mTexto, nPos ) )
   IF Len( mTexto ) != 0 // Se ainda tem mais linhas
      Justifica( @mTexto2, mColunas )
   ENDIF

   RETURN mTexto2

FUNCTION TextToArray( cTexto, nLargura, lAjusta )

   LOCAL cLinha, nPos, acTextList := {}

   hb_Default( @lAjusta, .T. )
   cTexto := AllTrim( cTexto )
   DO WHILE Len( cTexto ) > nLargura
      nPos := Rat( " ", Left( cTexto + " ", nLargura ) )
      IF nPos == 0
         nPos := nLargura
      ENDIF
      cLinha   := Left( cTexto, nPos - 1 )
      cTexto   := AllTrim( Substr( cTexto, nPos ) )
      nPos     := At( " ", cLinha )
      IF lAjusta .AND. nPos != 0
         DO WHILE Len( cLinha ) < nLargura
            cLinha := Stuff( cLinha, nPos, 0, " " )
            DO WHILE Substr( cLinha, nPos, 1 ) == " " .AND. nPos <= Len( cLinha )
               nPos += 1
            ENDDO
            DO WHILE Substr( cLinha, nPos, 1 ) != " " .AND. nPos <= Len( cLinha )
               nPos += 1
            ENDDO
            IF nPos >= Len( cLinha )
               nPos := At( " ", cLinha )
            ENDIF
         ENDDO
      ENDIF
      Aadd( acTextList, cLinha )
   ENDDO
   IF Len( cTexto ) != 0
      AAdd( acTextList, cTexto )
   ENDIF
   IF Len( acTextList ) == 0
      acTextList := { "" }
   ENDIF

   RETURN acTextList

FUNCTION Justifica( mTexto, mColunas )

   LOCAL mEspaco := at( " ", mTexto )

   IF mEspaco != 0
      DO WHILE Len( mTexto ) < mColunas
         mTexto = Stuff( mTexto, mEspaco, 0, " " )
         DO WHILE Substr( mTexto, mEspaco, 1 ) == " " .AND. mEspaco <= Len( mTexto )
            mEspaco += 1
         ENDDO
         DO WHILE Substr( mTexto, mEspaco, 1 ) != " " .AND. mEspaco <= Len( mTexto )
            mEspaco += 1
         ENDDO
         IF mEspaco >= Len( mTexto )
            mEspaco = At( " ", mTexto )
         ENDIF
      ENDDO
   ENDIF

   RETURN mTexto

FUNCTION RangeValue( xValue, xMin, xMax )

   DO CASE
   CASE ValType( xValue ) != ValType( xMin ) ; xValue := xMin
   CASE xValue < xMin                        ; xValue := xMin
   CASE xValue > xMax                        ; xValue := xMax
   ENDCASE

   RETURN xValue


/*
// SaveResource( cResourceName, cFileName )

#pragma BEGINDUMP
#include <Windows.h>
#include <hbApi.h>

HB_FUNC( SAVERESOURCE )
{
 static HRSRC hr;
 static HGLOBAL hg;
 static HANDLE hFile;
 static DWORD bytesWritten;

 hr = FindResource( NULL, (LPSTR) hb_parc( 1 ), RT_RCDATA );
 if( ! ( hr == 0 ) )
   {
    int size = SizeofResource( NULL, hr );
    hg = LoadResource( NULL, hr );
    if( ! ( hg == 0 ) )
      {
       char *lpRcData=( char *)LockResource( hg );
       hFile = CreateFile( (LPSTR) hb_parc( 2 ),GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL );
       WriteFile( hFile, lpRcData, size, &bytesWritten, NULL );
       CloseHandle( hFile );
      }
   }
}

#pragma ENDDUMP
*/

// hb_waEval() -> Executa codeblock pra cada área em uso
// hb_wEval( { || nCont++ } ) -> Pra retornar quantidade

// #include "fileio.ch"
// ? Transform( hb_DiskSpace( "E:" ), "999,999,999,999,999,999" )
// ? Transform( hb_DiskSpace( "E:", HB_DISK_AVAIL ), "999,999,999,999,999,999" )
// ? Transform( hb_DiskSpace( "E:", HB_DISK_FREE ), "999,999,999,999,999,999" )
// ? Transform( hb_DiskSpace( "E:", HB_DISK_USED ), "999,999,999,999,999,999" )
// ? Transform( hb_DiskSpace( "E:", HB_DISK_TOTAL ), "999,999,999,999,999,999" )


// Anotado
// Hb_ThreadStart( @OutroRun(), cComando )
// Hb_ThreadStart( {| cVar |OutroRun(cVar)}, cComando )

//FUNCTION Disca( mPorta, mNumero )

//   LOCAL mFile := fCREATE( "COM" + Str( mPorta, 1 ) ) // Abre COMx

//   fWrite( mFile, "ATDT" + mNumero + Chr(13) + Chr(10)) // Disca
//   fClose( mFile )

//   RETURN NIL

/*
// Erro se mapear já existente "Z:", "\\server\any"
FUNCTION MapNetworkDrive( cDrive, cNetworkName )

   LOCAL oNetwork

   oNetwork := win_OleCreateObject( "WScript.Network" )
   oNetwork:MapNetworkDrive( cDrive, cNetworkName )

   RETURN NIL

// Erro se tentar remover não existente "Z:"
FUNCTION RemoveNetworkDrive( cDrive )

   LOCAL oNetwork

   oNetwork := win_OleCreateObject( "WScript.Network" )
   oNetwork:RemoveNetworkDrive( cDrive, .T., .T. )

   RETURN NIL


FUNCTION NetworkDrives()

   LOCAL aMapList := {}, oNetwork, oMap, nCont

   oNetwork := win_OleCreateObject( "WScript.Network" )
   oMap     := oNetwork:EnumNetworkDrives()
   IF oMap:Count > 0
      FOR nCont = 0 TO oMap:Count - 1 STEP 2
         AAdd( aMapList, { oMap:Item( nCont ), oMap:Item( nCont + 1 ) } )
      NEXT
   ENDIF

   RETURN aMapList
*/
