/*
ZE_SETCOLOR
José Quintas
*/

FUNCTION SetColorSay()

   RETURN "7/1"

FUNCTION SetColorGet() // no focus

   RETURN "7/10"

FUNCTION SetColorNormal()

   RETURN SetColorSay() + "," + SetColorFocus() + ",,," + SetColorGet()

FUNCTION SetColorMensagem()

   RETURN "7/0," + SetColorFocus() + ",,," + SetColorGet()

FUNCTION SetColorBox()

   RETURN "0/7," + SetColorFocus() + ",,," + SetColorGet()

FUNCTION SetColorBorda() // menu, relatorios, etc.

   RETURN "0/7," + SetColorFocus() + ",,," + SetColorGet()

FUNCTION SetColorTitulo()

   RETURN "15/9,15/9"

FUNCTION SetColorAlerta()

   RETURN "15/12"

FUNCTION SetColorFocus()

   RETURN "15/9"

FUNCTION SetColorTituloBox()

   RETURN "0/14,0/14"

FUNCTION SetColorToolbar() // toolbar

   RETURN "0/7,0/7"

FUNCTION SetColorTbrowse()

   RETURN SetColorSay() + "," + SetColorFocus() + ",15/3" + ",7/2,7/4,7/5,7/10,7/13"

FUNCTION SetColorTraco() // barra superior/inferior das telas e abas dos cadastros

   RETURN "14" + Substr( SetColorSay(), At( SetColorSay(), "/" ) )
