/*
PTXT0010 - ALTERA TXT OBSERVACOES
2013 - José Quintas

...
*/

#include "inkey.ch"

PROCEDURE PTXT0010

   EditaSalva( "msg_pedido.txt" )

   RETURN

PROCEDURE PTXT0020

   EditaSalva( "msg_os_cliente.txt" )

   RETURN

PROCEDURE PTXT0030

   EditaSalva( "msg_os_fornecedor.txt" )

   RETURN

PROCEDURE PTXT0040

   EditaSalva( "msg_cupom.txt" )

   RETURN

STATIC FUNCTION EditaSalva( cFileName )

   LOCAL cTxt

   cTxt := MemoRead( cFileName )
   cTxt := MemoEdit( cTxt, 2, 0, MaxRow() - 3, MaxCol() )
   hb_MemoWrit( cFileName, cTxt )

   RETURN NIL
