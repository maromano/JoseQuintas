/*
WINCTLPANEL - Funções do painel de controle
José Quintas
*/

#include "hbdyn.ch"
#include "hbclass.ch"
#request "hbwin.hbc"

PROCEDURE Main

   ControlPanel():Panel()
   ControlPanel():SysDm()
   ControlPanel():AddRemove()
   ControlPanel():NetworkConn()
   ControlPanel():Power()
   ControlPanel():Regional()
   ControlPanel():SafetyRemove()
   ControlPanel():SoundProperties()
   ControlPanel():SystemComputerName()
   ControlPanel():WindowsFirewall()
   ControlPanel():Odbc()
   ControlPanel():TimeDate()

   Inkey(10)

   RETURN



CREATE CLASS ControlPanel
   METHOD Run( m, d, a )             INLINE hb_DynCall( { m, d, HB_DYN_CALLCONV_STDCALL }, 0, 0, a, WIN_SW_NORMAL )
   METHOD ControlRunDll( cApp )      INLINE ::Run( "Control_RunDLL", "shell32.dll", cApp )
   METHOD Panel()                    INLINE ::ControlRunDll( "" )
   METHOD SysDM()                    INLINE ::ControlRunDll( "sysdm.cpl" )
   METHOD AddRemove()                INLINE ::ControlRunDll( "appwiz.cpl" )
   METHOD NetworkConn()              INLINE ::ControlRunDll( "ncpa.cpl" )
   METHOD Power()                    INLINE ::ControlRunDll( "powercfg.cpl" )
   METHOD Regional()                 INLINE ::ControlRunDll( "intl.cpl,,0")
   METHOD SafetyRemove()             INLINE ::ControlRunDll( "HotPlug.dll" )
   METHOD SoundProperties()          INLINE ::ControlRunDll( "Mmsys.cpl,,0" )
   METHOD SystemComputerName()       INLINE ::ControlRunDll( "Sysdm.cpl,,1" )
   METHOD SystemPropertiesAdvanced() INLINE ::ControlRunDll( "Sysdm.cpl,,3")
   METHOD SystemRemote()             INLINE ::ControlRunDll( "sysdm.cpl,,5" )
   METHOD WindowsSecurityCenter()    INLINE ::ControlRunDll( "wscui.cpl" )
   METHOD WindowsFirewall()          INLINE ::ControlRunDll( "firewall.cpl" )
   METHOD Odbc()                     INLINE ::ControlRunDll( "odbccp32.cpl" )
   METHOD TimeDate()                 INLINE ::ControlRunDll( "timedate.cpl" )

   ENDCLASS
