/*
ZE_SENDMAILCLASS
José Quintas
*/

#include "hbclass.ch"

#define SEND_USING_HARBOUR 1
#define SEND_USING_BLAT    2
#define SEND_USING_CDO     3

CREATE CLASS ze_SendMailClass

   VAR  nHowToSend    INIT   SEND_USING_HARBOUR
   VAR  nPort         INIT   587
   VAR  nPriority     INIT   3
   VAR  lConfirm      INIT   .F.
   VAR  lTrace        INIT   .F.
   VAR  lTLS          INIT   .F.
   VAR  nTimeOut      INIT   20000 // milliseconds
   VAR  cServer       INIT   ""
   VAR  cFrom         INIT   ""
   VAR  acTo          INIT   {}
   VAR  acCC          INIT   {}
   VAR  acBCC         INIT   {}
   VAR  cFileBody     INIT   ""
   VAR  cSubject      INIT   ""
   VAR  cUser         INIT   ""
   VAR  cPassword     INIT   ""
   VAR  cServerPop    INIT   ""
   VAR  acAttachment  INIT   {}
   VAR  acDeleteFile  INIT   {}
   VAR  lNoAuth

   METHOD AddTo( xTxtMailList )
   METHOD AddCc( xTxtMailList )
   METHOD AddBcc( xTxtMailList )
   METHOD AddAttachment( xFileName )
   METHOD AddDelete( xFile )
   METHOD AddMailToArray( xTxtMailList, aMailList )
   METHOD Send()
   METHOD SendUsingBlatEXE()
   METHOD SendUsingCDO()
   METHOD SendUsingHarbour()

   ENDCLASS

METHOD AddTo( xTxtMailList ) CLASS ze_SendMailClass

   ::AddMailToArray( xTxtMailList, ::acTo )

   RETURN NIL

METHOD AddCc( xTxtMailList ) CLASS ze_SendMailClass

   ::AddMailToArray( xTxtMailList, ::acCC )

   RETURN NIL

METHOD AddBcc( xTxtMailList ) CLASS ze_SendMailClass

   ::AddMailToArray( xTxtMailList, ::acBCC )

   RETURN NIL

METHOD AddDelete( xFile ) CLASS ze_SendMailClass

   LOCAL oElement

   IF ValType( xFile ) == "A"
      FOR EACH oElement IN xFile
         Aadd( ::acDeleteFile, oElement )
      NEXT
   ELSE
      Aadd( ::acDeleteFile, xFile )
   ENDIF

   RETURN NIL

METHOD AddMailToArray( xTxtMailList, aMailList ) CLASS ze_SendMailClass

   LOCAL cText, cMail, nPos, oElement

   IF ValType( xTxtMailList ) == "C"
      xTxtMailList := { AllTrim( xTxtMailList ) }
   ENDIF
   FOR EACH oElement IN xTxtMailList
      cText := oElement
      cText := StrTran( AllTrim( cText ), ";", "," )
      DO WHILE Len( cText ) > 0
         nPos := At( ",", cText + "," )
         cMail := AllTrim( Substr( cText, 1, nPos - 1 ) )
         IF Len( cMail ) != 0
            IF aScan( aMailList, Lower( cMail ) ) == 0
               AAdd( aMailList, Lower( cMail ) )
            ENDIF
         ENDIF
         cText := AllTrim( Substr( cText, nPos + 1 ) )
      ENDDO
   NEXT

   RETURN NIL

METHOD AddAttachment( xFileName ) CLASS ze_SendMailClass

   LOCAL oElement

   IF ValType( xFileName ) == "C"
      xFileName := { xFileName }
   ENDIF
   FOR EACH oElement IN xFileName
      Aadd( ::acAttachment, oElement )
   NEXT

   RETURN NIL

METHOD Send() CLASS ze_SendMailClass

   LOCAL oElement, lOk := .F.

   IF ::nHowToSend == SEND_USING_HARBOUR
      lOk := ::SendUsingHarbour()
   ELSEIF ::nHowToSend == SEND_USING_BLAT
      lOk := ::SendUsingBlatEXE()
   ELSEIF ::nHowToSend == SEND_USING_CDO
      lOk := ::SendUsingCDO()
   ENDIF
   FOR EACH oElement IN ::acDeleteFile
      fErase( oElement )
   NEXT

   RETURN lOk

METHOD SendUsingHarbour() CLASS ze_SendMailClass

   RETURN tip_MailSend( ::cServer, ::nPort, ::cFrom, ::acTo, ::acCc, ::acBcc, ::cFileBody, ::cSubject, ::acAttachment, ::cUser, ::cPassword, ;
      iif( Empty( ::cServerPop ), NIL, ::cServerPop ), ::nPriority, ::lConfirm, ::lTrace, ! Empty( ::cServerPop ), ;
      ::lNoAuth, ::nTimeOut, /* cReplyTo */, ::lTLS )

#define CDO_SEND_USING_PICKUP           1 // email client program
#define CDO_SEND_USING_PORT             2 // direct to internet
#define CDO_ANONYMOUS                   0
#define CDO_BASIC                       1 // clear text
#define CDO_NTLM                        2
#define CDO_DSN_DEFAULT                 0 // none
#define CDO_DSN_NEVER                   1 // none
#define CDO_DSN_FAILURE                 2 // failure
#define CDO_DSN_SUCCESS                 4 // success
#define CDO_DSN_DELAY                   8 // delay
#define CDO_DSN_SUCCESS_FAIL_OR_DELAY   14 // none + success + failure + delay

METHOD SendUsingCDO() CLASS ze_SendMailClass

   LOCAL oMessage, oConfiguration, oElement, lOk

   oMessage       := win_OleCreateObject( "CDO:Message" )
   oConfiguration := win_OleCreateObject( "CDO:Configuration" )
   oConfiguration:Fields( "http://schemas.microsoft.com/cdo/configuration/sendusing" ):Value             := CDO_SEND_USING_PORT
   oConfiguration:Fields( "http://schemas.microsoft.com/cdo/configuration/smtpserver" ):Value            := ::cServer
   oConfiguration:Fields( "http://schemas.microsoft.com/cdo/configuration/smtpauthenticate" ):Value      := CDO_BASIC
   oConfiguration:Fields( "http://schemas.microsoft.com/cdo/configuration/smtpserverport" ):Value        := ::nPort
   oConfiguration:Fields( "http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout" ):Value := 30
   oConfiguration:Fields( "http://schemas.microsoft.com/cdo/configuration/smtpusessl" ):Value            := .F.
   oConfiguration:Fields( "http://schemas.microsoft.com/cdo/configuration/sendusername" ):Value          := ::cFrom
   oConfiguration:Fields( "http://schemas.microsoft.com/cdo/configuration/sendpassword" ):Value          := ::cPassword
   // oConfiguration:Fields( "http://schemas.microsoft.com/cdo/configuration/smtpusessl" )               := .F.
   oConfiguration:Fields:Update()

   oMessage:Configuration := oConfiguration
   oMessage:To            := ::acTo
   oMessage:From          := ::cFrom
   oMessage:Subject       := ::cSubject
   IF File( ::cFileBody )
      oMessage:TextHtml := MemoRead( ::cFileBody )
   ELSE
      oMessage:TextHtml := ::cFileBody
   ENDIF
   FOR EACH oElement IN ::acAttachment
      oMessage:AddAttachment( oElement )
   NEXT
   oMessage:Fields( "urn:schemas:mailheader:disposition-notification-to" ):Value := ::cFrom
   oMessage:Fields:Update()
   lOk := .F.
   BEGIN SEQUENCE WITH __BreakBlock()

      oMessage:Send()
      lOk := .T.

   END SEQUENCE

   RETURN lOk

METHOD SendUsingBlatEXE() CLASS ze_SendMailClass

   LOCAL cTxt, nCont, cCmd, cBlatCfg, oElement

   cTxt := ""
   cTxt += "-server " + ::cServer + hb_eol()
   cTxt += "-f " + ::cFrom + hb_eol()
   cTxt += [-subject "] + ::cSubject + ["] + hb_eol()
   cTxt += [-to ] + ::acTo[ 1 ]
   IF Len( ::acTo ) > 1
      FOR nCont = 2 TO Len( ::acTo )
         cTxt += [,] + ::acTo[ nCont ]
      NEXT
   ENDIF
   cTxt += hb_eol()
   IF Len( ::acCC ) > 0
      cTxt += [-cc ] + ::acCC[ 1 ] + hb_eol()
      IF Len( ::acCC ) > 1
         FOR nCont = 2 TO Len( ::acCC )
            cTxt += [,] + ::acCC[ nCont ]
         NEXT
      ENDIF
      cTxt += hb_eol()
   ENDIF
   IF Len( ::acBCC ) > 0
      cTxt += [-bcc ] + ::acBCC[ 1 ]
      IF Len( ::acBCC ) > 1
         FOR nCont = 2 TO Len( ::acBCC )
            cTxt += [,] + ::acBCC[ nCont ]
         NEXT
      ENDIF
      cTxt += hb_eol()
   ENDIF
   cTxt += "-u " + ::cUser + hb_eol()
   cTxt += "-pw " + ::cPassword + hb_eol()
   IF ! Empty( ::cServerPop )
      cTxt += "-pu " + ::cUser + hb_eol()
      cTxt += "-ppw " + ::cPassword + hb_eol()
   ENDIF
   cTxt += "-port " + LTrim( Str( ::nPort ) ) + hb_eol()
   FOR EACH oElement IN ::acAttachment
      cTxt += "-attach " + oElement + hb_eol()
   NEXT
   cTxt += [-x "X-JPAID: ] + DriveSerial() + ["] + hb_eol()
   cTxt += "-html" + hb_eol()
   cBlatCfg := MyTempFile( "bla" )
   Aadd( ::acDeleteFile, cBlatCfg )
   HB_MemoWrit( cBlatCfg, cTxt )
   cCmd := hb_DirBase() + "Blat " + ::cFileBody + " -of " + cBlatCfg
   RUN ( cCmd )

   RETURN .T.

FUNCTION HtmlEncodeJPEG( cFileContent )

   THREAD STATIC cName := Chr(64)
   LOCAL cTxt, oEncoder := TipEncoderBase64():New()

   cName := Chr( Asc( cName ) + 1 )
   IF cName > "Z"
      cName := Chr(64)
   ENDIF
   cTxt := ["] + "data:" + hb_MimeFName( "any.jpg", cName ) + ";base64," + oEncoder:Encode( cFileContent ) + ["]

   RETURN cTxt

FUNCTION HtmlEncodeFile( cFileName )

   THREAD STATIC cName := Chr(64)
   LOCAL cTxt, oEncoder := TipEncoderBase64():New()

   cName := Chr( Asc( cName ) + 1 )
   IF cName > "Z"
      cName := Chr(64)
   ENDIF
   cTxt := ["] + "data:" + hb_MimeFName( cFileName, cName ) + ";base64," + oEncoder:Encode( MemoRead( cFileName ) ) + ["]

   RETURN cTxt
