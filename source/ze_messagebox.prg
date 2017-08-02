/*
ZE_MESSAGEBOX
José Quintas
*/

FUNCTION MsgYesNo( cText )

   LOCAL lValue

   hb_ThreadStart( { || PlayText( cText ) } )
   wSave( MaxRow() - 1, 0, MaxRow(), MaxCol() )
   Mensagem()
   lValue := wapi_MessageBox( wvgSetAppWindow():hWnd, cText, "Confirmação", WIN_MB_YESNO + WIN_MB_ICONQUESTION + WIN_MB_DEFBUTTON2 ) == WIN_IDYES
   wRestore()

   RETURN lValue

FUNCTION MsgExclamation( cText )

   hb_ThreadStart( { || PlayText( cText ) } )
   wSave( MaxRow() - 1, 0, MaxRow(), MaxCol() )
   Mensagem()
   wapi_MessageBox( wvgSetAppWindow():hWnd, cText, "Atenção", WIN_MB_ICONASTERISK )
   wRestore()

   RETURN NIL

FUNCTION MsgWarning( cText )

   hb_ThreadStart( { || PlayText( cText ) } )
   wSave( MaxRow() - 1, 0, MaxRow(), MaxCol() )
   Mensagem()
   wapi_MessageBox( wvgSetAppWindow():hWnd, cText, "Atenção", WIN_MB_ICONEXCLAMATION )
   wRestore()

   RETURN NIL

FUNCTION MsgStop( cText )

   hb_ThreadStart( { || PlayText( cText ) } )
   wSave( MaxRow() - 1, 0, MaxRow(), MaxCol() )
   Mensagem()
   wapi_MessageBox( wvgSetAppWindow():hWnd, cText, "Atenção", WIN_MB_ICONHAND )
   wRestore()

   RETURN NIL
