/*
ZE_WINAPI - FUNCOES API WINDOWS
2015 -  José Quintas
*/

#include "hbdyn.ch"

FUNCTION mywin_GetComputerName()

   LOCAL cComputerName := Space(255), nSize := 250

   hb_DynCall( { "GetComputerNameA", "kernel32.dll", HB_DYN_CALLCONV_STDCALL }, @cComputerName, @nSize )
   cComputerName := TrimStringApi( cComputerName )

   RETURN cComputerName

FUNCTION mywin_GetModuleFileName()

   LOCAL cFileName := Space(100), nSize := 100

   hb_DynCall( { "GetModuleFileNameA", "kernel32.dll", HB_DYN_CALLCONV_STDCALL }, /* hModule */, @cFileName, nSize )

   RETURN TrimStringApi( cFileName )

FUNCTION mywin_GetParent( hWnd )

   LOCAL hWndParent

   hWndParent := hb_DynCall( { "GetParent", "user32.dll", HB_DYN_CALLCONV_STDCALL }, hWnd )

   RETURN hWndParent

FUNCTION mywin_GetUserName()

   LOCAL cUserName := Space(255), nSize := 250

   hb_DynCall( { "GetUserNameA", "adv32api.dll", HB_DYN_CALLCONV_STDCALL }, @cUserName, @nSize )

   RETURN TrimStringApi( cUserName )

// http://msdn.microsoft.com/en-us/library/ie/ms775123(v=vs.85).aspx
FUNCTION mywin_UrlDownloadToFile( cUrl, cFileName )

   LOCAL nErrorCode, pCaller := 0, lpIndStatusCallBack := 0 // for progress

   nErrorCode := hb_DynCall( { "URLDownloadToFileA", "urlmon.dll", HB_DYN_CALLCONV_STDCALL }, pCaller, cURL, cFileName, 0, lpIndStatusCallBack )

   RETURN nErrorCode == 0

FUNCTION TrimStringApi( cString )

   cString := AllTrim( StrTran( cString, Chr(0), "" ) )

   RETURN cString

FUNCTION Windows_ControlPanel()

   hb_DynCall( { "Control_RunDLL", "shell32.dll", HB_DYN_CALLCONV_STDCALL }, 0 )

   RETURN NIL


// Add/Remove Programs
// RunDll32.exe shell32.dll,Control_RunDLL appwiz.cpl,,0

// Clear Internet Explorer Title
// RunDll32.EXE IEdkcs32.dll,Clear

// Content Advisor
// RunDll32.exe msrating.dll,RatingSetupUI

// Control Panel
// RunDll32.exe shell32.dll,Control_RunDLL

// Device Manager
// RunDll32.exe devmgr.dll DeviceManager_Execute

// Folder Options - General
// RunDll32.exe shell32.dll,Options_RunDLL 0

// Folder Options - File Types
// RunDll32.exe shell32.dll,Control_Options 2

// Folder Options - Search
// RunDll32.exe shell32.dll,Options_RunDLL 2

// Folder Options - View
// RunDll32.exe shell32.dll,Options_RunDLL 7

// Forgotten Password Wizard
// RunDll32.exe keymgr.dll,PRShowSaveWizardExW

// Vista Flip 3D
// RunDll32.exe DwmApi #105

// Hibernate
// RunDll32.exe powrprof.dll,SetSuspendState

// Internet Explorer's Internet Properties dialog box
// RunDll32 Shell32.dll,ConBring up trol_RunDLL Inetcpl.cpl,,6

// Keyboard Properties
// RunDll32.exe shell32.dll,Control_RunDLL main.cpl @1

// Lock Screen
// RunDll32.exe user32.dll,LockWorkStation

// Mouse Button - Swap left button to function as right
// RunDll32 User32.dll,SwapMouseButton (Para resolver, usar: RunDll32.EXE SHELL32.dll,Control_RunDLL main.cpl @0,0)

// Mouse Properties Dialog Box
// RunDll32 Shell32.dll,Control_RunDLL main.cpl @0,0

// Map Network Drive Wizard
// RunDll32 Shell32.dll,SHHelpShortcuts_RunDLL Connect

// Network Connections
// RunDll32.exe shell32.dll,Control_RunDLL ncpa.cpl

// Organize IE Favorites
// RunDll32.exe shdocvw.dll,DoOrganizeFavDlg

// Open With Dialog Box
// RunDll32 Shell32.dll,OpenAs_RunDLL Any_File-name.ext

// Printer User Interface
// RunDll32 Printui.dll,PrintUIEntry /?

// Printer Management Folder
// RunDll32 Shell32.dll,SHHelpShortcuts_RunDLL PrintersFolder

// Power Options
// RunDll32.exe Shell32.dll,Control_RunDLL powercfg.cpl

// Process Idle Tasks
// RunDll32.exe advapi32.dll,ProcessIdleTasks

// Regional and Language Options
// RunDll32 Shell32.dll,Control_RunDLL Intl.cpl,,0

// Stored Usernames and Passwords
// RunDll32.exe keymgr.dll,KRShowKeyMgr

// Safely Remove Hardware Dialog Box
// RunDll32 Shell32.dll,Control_RunDLL HotPlug.dll

// Sound Properties Dialog Box
// RunDll32 Shell32.dll,Control_RunDLL Mmsys.cpl,,0

// System Properties Box
// RunDll32 Shell32.dll,Control_RunDLL Sysdm.cpl,,3

// System Properties - Advanced
// RunDll32.exe shell32.dll,Control_RunDLL sysdm.cpl,,4

// System Properties: Automatic Updates
// RunDll32.exe shell32.dll,Control_RunDLL sysdm.cpl,,5

// System Properties, Computer Name Tab
// RunDll32.exe shell32.dll,Control_RunDLL sysdm.cpl,,1

// System Properties, Hardware Tab
// RunDll32.exe shell32.dll,Control_RunDLL sysdm.cpl,,2

// System Properties, Advanced Tab
// RunDll32.exe shell32.dll,Control_RunDLL sysdm.cpl,,3

// System Properties, System Protection Tab
// RunDll32.exe shell32.dll,Control_RunDLL sysdm.cpl,,4

// System Properties, Remote Tab
// RunDll32.exe shell32.dll,Control_RunDLL sysdm.cpl,,5

// System Properties, Performance, Visual Effects
// RunDll32.exe shell32.dll,Control_RunDLL sysdm.cpl,,-1

// Taskbar Properties
// RunDll32.exe shell32.dll,Options_RunDLL 1

// User Accounts
// RunDll32.exe shell32.dll,Control_RunDLL nusrmgr.cpl

// Unplug//Eject Hardware
// RunDll32.exe shell32.dll,Control_RunDLL hotplug.dll

// Windows Security Center
// RunDll32.exe shell32.dll,Control_RunDLL wscui.cpl

// Windows - About
// RunDll32.exe SHELL32.DLL,ShellAboutW

// Windows Fonts Installation Folder
// RunDll32 Shell32.dll,SHHelpShortcuts_RunDLL FontsFolder

// Windows Firewall
// RunDll32.exe shell32.dll,Control_RunDLL firewall.cpl

// Wireless Network Setup
// RunDll32.exe shell32.dll,Control_RunDLL NetSetup.cpl,@0,WNSW

// God Mode - criar pasta em desktop ou outro local
// God Mode.{ED7BA470-8E54-465E-825C-99712043E01C}
