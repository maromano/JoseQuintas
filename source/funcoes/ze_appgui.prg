/*
ZE_APPGUI
José Quintas
*/

FUNCTION AppForms()

   THREAD STATIC AppForms := {}

   RETURN AppForms

FUNCTION AppGuiHide()

   IF Len( AppForms() ) != 0
      Atail( AppForms() ):GuiHide()
   ENDIF

   RETURN NIL

FUNCTION AppGuiShow()

   IF Len( AppForms() ) != 0
      Atail( AppForms() ):GuiShow()
   ENDIF

   RETURN NIL

