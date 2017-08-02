/*
PSETUPWINDOWS - Setup Windows
José Quintas
*/

FUNCTION pSetupWindows()

   // Politica de controle de conta de usuario para drives mapeados (UAC) que bloqueia acesso a pastas mapeadas
   // Ao que parece, ate mesmo o administrador vira usuario comum para isso
   // [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]"EnableLinkedConnections"=dword:00000001
   IF win_OsNetRegOk()
      MsgExclamation( "Windows já configurado" )
   ELSE
      IF MsgYesNo( "Windows não configurado corretamente para o JPA." + hb_eol() + "Configura agora?" + hb_eol() + ;
         "Obs. Conforme versão do Windows, Só vai ser possivel configurar se JPA executado como administrador" )
         IF win_OsNetRegOk( .T., .T. )
            IF ! MsgYesNo( "Configuração necessária aplicada. Continua?" )
               QUIT
            ENDIF
         ELSE
            MsgStop( "Não foi possivel aplicar configuração." )
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL
