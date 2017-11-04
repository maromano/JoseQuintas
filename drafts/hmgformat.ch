
// caution about pre-processor
#define FMT_COMMENT_OPEN  "/" + "*"
#define FMT_COMMENT_CLOSE "*" + "/"

#define FMT_TO_UPPER { ;
      "ACCEPT", ;
      "ACTIVATE WINDOW", ;
      "ANNOUNCE", ;
      "APPEND", ;
      "AVERAGE", ;
      "BEGIN", ;
      "CASE ", ;
      "CATCH", ;
      "CENTER WINDOW", ;
      "CLASS ", ;
      "CLASSVAR ", ;
      "CLEAR", ;
      "CLOSE", ;
      "COMMIT", ;
      "CONTINUE", ;
      "COPY ", ;
      "COUNT", ;
      "CREATE ", ;
      "CREATE CLASS ", ;
      "DATA ", ;
      "DECLARE ", ;
      "DEFAULT", ;
      "DEFINE ACTIVEX", ;
      "DEFINE BROWSE", ;
      "DEFINE BUTTON", ;
      "DEFINE CHECKBOX", ;
      "DEFINE CHECKLIST", ;
      "DEFINE COMBOBOX", ;
      "DEFINE CONTEXT", ;
      "DEFINE DATEPICKER", ;
      "DEFINE EDITBOX", ;
      "DEFINE FRAME", ;
      "DEFINE GRID", ;
      "DEFINE IMAGE", ;
      "DEFINE INTERNAL", ;
      "DEFINE LABEL", ;
      "DEFINE LISTBOX", ;
      "DEFINE MAIN MENU", ;
      "DEFINE MENU", ;
      "DEFINE PAGE", ;
      "DEFINE POPUP", ;
      "DEFINE RADIOGROUP", ;
      "DEFINE SLIDER", ;
      "DEFINE SPINNER", ;
      "DEFINE SPLITBOX", ;
      "DEFINE STATUSBAR", ;
      "DEFINE TAB", ;
      "DEFINE TEXTBOX", ;
      "DEFINE TREE", ;
      "DEFINE TOOLBAR", ;
      "DEFINE WINDOW", ;
      "DELETE", ;
      "DISPLAY", ;
      "DO CASE", ;
      "DO WHILE", ;
      "DYNAMIC", ;
      "EJECT", ;
      "ELSE", ;
      "ELSEIF", ;
      "END CLASS", ;
      "END CASE", ;
      "END IF", ;
      "END SEQUENCE", ;
      "END SWITCH", ;
      "END WINDOW", ;
      "ENDCASE", ;
      "ENDCLASS", ;
      "ENDDO", ;
      "ENDIF", ;
      "ENDSEQUENCE", ;
      "ENDSWITCH", ;
      "ENDTEXT", ;
      "ERASE", ;
      "EXIT", ;
      "EXTERNAL", ;
      "FOR ", ;
      "FOR EACH", ;
      "FUNCTION ", ;
      "IF ", ;
      "GOTO ", ;
      "INDEX ", ;
      "INIT ", ;
      "INPUT ", ;
      "JOIN ", ;
      "KEYBOARD ", ;
      "LABEL ", ;
      "LIST ", ;
      "LOCAL ", ;
      "LOCATE ", ;
      "LOOP", ;
      "MEMVAR ", ;
      "MENU ", ;
      "METHOD ", ;
      "NEXT", ;
      "OTHERWISE", ;
      "PACK", ;
      "PARAMETERS ", ;
      "PRINT ", ;
      "PRIVATE ", ;
      "PROCEDURE ", ;
      "PUBLIC ", ;
      "QUIT", ;
      "READ", ;
      "RECALL", ;
      "RECOVER", ;
      "REINDEX", ;
      "RELEASE ", ;
      "RENAME ", ;
      "REPLACE ", ;
      "REQUEST ", ;
      "RESTORE ", ;
      "RETURN", ;
      "RETURN NIL", ;
      "RUN ", ;
      "SAVE ", ;
      "SEEK ", ;
      "SELECT ", ;
      "SET ", ;
      "SET ALTERNATE ON", ;
      "SET ALTERNATE OFF", ;
      "SET CENTURY ON", ;
      "SET CENTURY OFF", ;
      "SET CONFIRM ON", ;
      "SET CONFIRM OFF", ;
      "SET CONSOLE ON", ;
      "SET CONSOLE OFF", ;
      "SET DATE ANSI", ;
      "SET DATE BRITISH", ;
      "SET EPOCH TO", ;
      "SKIP", ;
      "SORT", ;
      "STATIC", + ;
      "STATIC FUNCTION ", ;
      "STATIC PROCEDURE ", ;
      "STORE ", ;
      "SUM ", ;
      "SWITCH", ;
      "SWITCH CASE", ;
      "TEXT", ;
      "THEAD STATIC", ;
      "TOTAL ", ;
      "UNLOCK ", ;
      "UPDATE ", ;
      "USE", ;
      "VAR ", ;
      "WAIT", ;
      "WHILE ", ;
      "WITH OBJECT", ;
      "ZAP" }

#define FMT_TO_LOWER { ;
      "#" + "command" , ;
      "#" + "else", ;
      "#" + "endif", ;
      "#" + "ifdef", ;
      "#" + "ifndef", ;
      "#" + "pragma", ;
      "#" + "include", ;
      "#" + "pragma begindump", ;
      "#" + "pragma enddump", ;
      "#" + "translate" }

#define FMT_GO_AHEAD { ;
      "begin", ;
      "case ", ;
      "catch", ;
      "class", ;
      "create class", ;
      "define activex", ;
      "define button", ;
      "define browse", ;
      "define checkbox", ;
      "define checklist", ;
      "define combobox", ;
      "define context", ;
      "define datepicker", ;
      "define editbox", ;
      "define frame", ;
      "define grid", ;
      "define image", ;
      "define internal", ;
      "define label", ;
      "define listbox", ;
      "define main menu", ;
      "define menu", ;
      "define page", ;
      "define popup", ;
      "define radiogroup", ;
      "define slider", ;
      "define spinner", ;
      "define splitbox", ;
      "define statusbar", ;
      "define tab", ;
      "define textbox", ;
      "define toolbar", ;
      "define tree", ;
      "define window", ;
      "do case", ;
      "do while ", ;
      "else", ;
      "for ", ;
      "func ", ;
      "function", ;
      "if ", ;
      "method", ;
      "node ", ;
      "page ", ;
      "popup ", ;
      "proc ", ;
      "procedure", ;
      "recover", ;
      "static proc", ;
      "static func", ;
      "switch", ;
      "try", ;
      "while ", ;
      "with object" }

#define FMT_GO_BACK { ;
      "catch", ;
      "case ", ;
      "else", ;
      "end", ;
      "endcase", ;
      "endclass", ;
      "endif", ;
      "enddo", ;
      "method", ;
      "next", ;
      "recover" }

#define FMT_SELF_BACK { ;
      "case ", ;
      "catch", ;
      "else", ;
      "elseif ", ;
      "function", ;
      "method", ;
      "procedure", ;
      "recover", ;
      "static function", ;
      "static procedure" }

#define FMT_BLANK_LINE { ;
      "class ", ;
      "create class ", ;
      "end class", ;
      "endclass", ;
      "function ", ;
      "method ", ;
      "procedure ", ;
      "static function ", ;
      "static procedure " }

#define FMT_DECLARE_VAR { ;
      "field ", ;
      "local ", ;
      "memvar ", ;
      "private ", ;
      "public " }