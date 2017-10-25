@echo off
rem auxiliar batch
rem
rem HG_ROOT, HG_HRB, LIB_GUI, LIB_HRB, BIN_HRB, HBMK2_WORKDIR
rem HG_CCOMP (HG_BCC, HG_VC, HG_PC, HG_MINGW)

:COMPILE_HBMK2

   rem   hbmk2 %* oohg.hbc
   goto :END

:OPTIONS

   if "%1"=="RESET"       goto :RESET
   if "%1"=="COMPILE"     goto :COMPILE
   if "%1"=="COMPILE_PRG" goto :COMPILE_PRG %2
   if "%1"=="COMPILE_C"   goto :COMPILE_C %2
   if "%1"=="COMPILE_RC"  goto :COMPILE_RC %2
   if "%1"=="LINK_LIB"    goto :LINK_LIB
   if "%1"=="LINK_EXE"    goto :LINK_EXE
   if "%1"=="ADDPRG"      set  %HG_PRG_LIST%=%HG_PRG_LIST% %2 %3 %4 %5 %6 %7 %8 %9
   if "%1"=="ADDC"        set  %HG_C_LIST%=%HG_C_LIST% %2 %3 %4 %5 %6 %7 %8 %9

:HELP
   echo use the following variables
   echo.
   echo HG_PATH        = root path for oohg
   echo HG_PATH_HB     = root path for Harbour/xHarbour
   echo HG_PATH_C      = root path for C Compiler
   echo HG_COMP        = C compiler ( mingw, bcc, msvc, pocc )
   echo HG_PRG_LIST    = PRG source list without extension
   echo HG_PRG_FLAGS   = additional flags to compile PRG source
   echo HG_C_LIST      = C source list without extension
   echo HG_C_FLAGS     = additional flags to compile C source
   echo HG_OUTOUT_NAME = name of EXE or LIB without extension
   echo HG_OUTPUT_TYPE = exe or lib
   echo HG_TEMPPATH    = temporary working path
   echo.
   echo You can use sub-routines of this batch
   echo RESET          = clear variables
   echo COMPILE        = compile *.prg, compile *.c, compile *.rc and link all
   echo COMPILE_PRG    = compile *.prg only, and add c output file to HG_C_LIST
   echo COMPILE_C      = compile *.c only
   echo COMPILE_RC     = compile *.rc only
   echo LINK_LIB       = link to a lib file
   echo LINK_EXE       = link to a exe file
   echo ADDPRG         = add prg files to list
   echo ADDC           = add c files to list

   goto :END

:TEST_ONLY

   rem set HG_PATH_HB=d:\habour
   rem set HG_PATH_C=d:\harbour\comp\mingw\mingw64
   rem set HG_PATH=d:\github\oohg
   rem set HG_COMP=mingw
   rem set HG_PRG_LIST=miniprint
   rem set HG_PRG_FLAGS=
   rem set HG_C_LIST=
   rem set HG_C_FLAGS=
   rem set HG_OUTPUT_NAME=miniprint
   rem set HG_OUTPUT_TYPE=lib
   rem set HG_TEMPPATH=c:\temp
   goto :END

:RESET

   set HG_PRG_LIST=
   set HG_PRG_FLAGS=
   set HG_C_LIST=
   set HG_C_FLAGS=
   set HG_RC_LIST=
   set HG_OUTPUT_NAME=
   set HG_OUTPUT_TYPE=
   set HG_TEMPPATH=
   goto :END

:COMPILE

   rem to do not change environment variables (list of c source)
   SETLOCAL

   if not "%HG_PRG_LIST%"==""  for %%a in ( HG_PRG_LIST ) call :COMPILE_PRG %%a
   if not "%HG_C_LIST%"==""    for %%a in ( HG_C_LIST )   call :COMPILE_C %%a
   if not "%HG_RC_LIST%"==""   call :COMPILE_RC
   if "%HG_PRG_LIST%"=="" if "%HG_C_LIST%"=="" if "%HG_RC_LIST%"=="" goto :END
   if "%HG_OUTPUT_TYPE%"="lib" call :LINK_LIB
   if "%HG_OUTPUT_TYPE%"="exe" call :LINK_EXE
   goto :END

:COMPILE_PRG

   %HG_PATH_HB%\harbour.exe %1.prg %HG_PRG_FLAGS% ^
       -i"%HG_PATH%\include;%HG_PATH_HB%\include" ^
       -n1 -w2 -gc0 -es2 %2

   rem --- add name to C source list
   set HG_C_LIST=%HG_C_LIST% %1
   goto :END

:COMPILE_C

   if "%hg_comp%"=="bcc"   ^
      %HG_PATH_C%\bin\bcc32.exe %1.c %HG_C_FLAGS% ^
                -c -O2 -tW -tWM -d -a8 -OS -5 -6 -w -D__XHARBOUR__ ^
                -I%HG_PATH_HB%\include;%HG_PATH_C%\include;%HG_PATH%\include; ^
                -L%%HG_PATH_HB%\lib;%HG_PATH_C%\lib;

   if "%hg_comp%"=="msvc"  ^
      %HG_PATH_C%\bin\cl.exe %1.c %HG_C_FLAGS% ^
             /O2 /c /W3 /nologo /D_CRT_SECURE_NO_WARNINGS ^
             /I"%HG_PATH%\include" ^
             /I"%HG_PATH_HB%\include" ^
             /I"%HG_PATH_C%\include"

   if "%hg_comp%"=="pocc"   ^
      %HG_PATH_C%\bin\pocc.exe  %1.c %HG_C_FLAGS% ^
                /Ze /Zx /Go /Tx86-coff /D__WIN32__
                /I%HG_PATH%\include ^
                /I%HG_PATH_HB%\include ^
                /I%HG_PATH_C%\include ^
                /I%HG_PATH_C%\include\win

   if "%hg_comp%"=="mingw" ^
      %HG_PATH_C%\bin\gcc.exe   %1.c %HG_C_FLAGS% ^
                -W -Wall -O3 -c ^
                -I%HG_PATH%\include ^
                -I%HG_PATH_HB%\include ^
                -I%HG_PATH_C%\include ^
                -L%HB_PATH%\lib ^
                -L%HB_PATH_HB%\lib ^
                -L%HG_PATH_C%\lib

   rem --- compile c
   goto :END

:COMPILE_RC

   goto :END

:LINK_LIB

   rem --- uses list of prg, c and resource

   if exist %HG_TEMPPATH%\link.def del %HG_TEMPPATH%\link.def
   for %%a in ( HG_C_LIST ) echo %%a.obj >> %HG_TEMPPATH%\link.def

   if "%hg_comp%"=="bcc"   ^
      %HG_PATH_C%\bin\tlink ^
         %HG_OUTPUT_NAME% @%HG_TEMPPATH%\link.def ^
         -L%HG_PATH%;%HG_PATH_HB%\lib;%HG_PATH_C%\lib;

   if "%hg_comp%"=="pocc"  ^
      %HG_PATH_C%\bin\polib ^
         /out:%HG_OUTPUT_NAME%.lib ^
         @%HG_TEMPPATH%\link.def ^
         /L%HG_PATH%\lib ^
         /L%HG_PATH_HB%\lib ^
         /L%HG_PATH_C%\lib

   if "%hg_comp%"=="mingw" ^
      %HG_PATH_C%\bin\ar rc ^
         %HG_OUTPUT_NAME%.a ^
         @%HG_TEMPPATH%\link.def ^
         -L%HG_PATH%\lib ^
         -L%HG_PATH_HB%\lib ^
         -L%HG_PATH_C%\lib

   if "%hg_comp%"=="msvc"  ^
      %HG_PATH_C%\bin\lib ^
         /out:%HB_OUTPUT_NAME%.lib ^
         @%HG_TEMPPATH%\link.def ^
         /L%HG_PATH%\lib ^
         /L%HG_PATH_HB%\lib ^
         /L%HG_PATH_C%\lib

   rem --- delete temporary files
   del %HG_TEMPPATH%\link.def
   rem for %%a in ( HG_PRG_LIST ) do del %%a.c
   rem for %%a in ( HG_C_LIST )   do del %%a.obj
   goto :END

:LINK_EXE

   goto :END

:END
