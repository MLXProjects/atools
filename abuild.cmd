@echo off
rem delay variable expansion & load settings
setlocal enabledelayedexpansion
call _setldr.cmd %1
if "%LIBAROMA_SOURCE%"=="" goto :eof
if "%LIBAROMA_PLATFORM%"=="" goto :eof

if not exist "%LIBAROMA_OUT%\libadeps.a" call alibs.cmd %1
if exist "%LIBAROMA_OUT%\aroma\" rd /s /q "%LIBAROMA_OUT%\aroma"
mkdir "%LIBAROMA_OUT%\aroma"
cd "%LIBAROMA_OUT%\aroma"

rem additional variables for compiling
set LIBAROMA_CFLAGS=-c -Wno-unused-command-line-argument -Wno-ignored-optimization-argument -Wno-unknown-warning-option
rem setup platform flags
if "%LIBAROMA_PLATFORM%"=="sdl" (
	set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -DLIBAROMA_FB_INITHELPER
) else if "%LIBAROMA_PLATFORM%"=="sdl2" (
	rem for SDL2 revert platform to SDL (they're common) and set sdl2 flag
	set LIBAROMA_PLATFORM=sdl
	set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -DLIBAROMA_FB_INITHELPER -DLIBAROMA_PLATFORM_SDL2
)
rem setup main flags
if "%LIBAROMA_SVG%"=="no" set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -DLIBAROMA_CONFIG_NOSVG
if "%LIBAROMA_ZIP%"=="no" set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -DLIBAROMA_CONFIG_NOMINZIP
if "%LIBAROMA_JPEG%"=="no" (
	set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -DLIBAROMA_CONFIG_NOJPEG
) else set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -I..\..\jpeg
if not "%LIBAROMA_OPENMP%"=="no" set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -DLIBAROMA_CONFIG_OPENMP -fopenmp
if "%LIBAROMA_HARFBUZZ%"=="yes" (
	set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -I..\..\harfbuzz\src
) else set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -DLIBAROMA_CONFIG_TEXT_NOHARFBUZZ
rem list source files
set "LIBAROMA_PLATSRC= "
for /f "tokens=*" %%F in ('dir /b /a:-d "%LIBAROMA_SOURCE%\src\plat\!LIBAROMA_PLATFORM!\*.c"') do (
	call set LIBAROMA_PLATSRC=%%LIBAROMA_PLATSRC%% "%LIBAROMA_SOURCE%\src\plat\!LIBAROMA_PLATFORM!\%%F"
)
set "LIBAROMA_CTLSRC= "
for /f "tokens=*" %%F in ('dir /b /a:-d "%LIBAROMA_SOURCE%\src\ctl\*.c"') do (
	call set LIBAROMA_CTLSRC=%%LIBAROMA_CTLSRC%% "%LIBAROMA_SOURCE%\src\ctl\%%F"
)
set "LIBAROMA_LISTSRC= "
for /f "tokens=*" %%F in ('dir /b /a:-d "%LIBAROMA_SOURCE%\src\ctl\list\*.c"') do (
	call set LIBAROMA_LISTSRC=%%LIBAROMA_LISTSRC%% "%LIBAROMA_SOURCE%\src\ctl\list\%%F"
)
set LIBAROMA_DEBUGSRC="%LIBAROMA_SOURCE%\src\debug\buildinfo.c"
if "%LIBAROMA_MEMDEBUG%"=="yes" set LIBAROMA_DEBUGSRC=%LIBAROMA_DEBUGSRC% "%LIBAROMA_SOURCE%\src\debug\memtrack.c"
set "LIBAROMA_GRAPHSRC= "
for /f "tokens=*" %%F in ('dir /b /a:-d "%LIBAROMA_SOURCE%\src\graph\*.c"') do (
	call set LIBAROMA_GRAPHSRC=%%LIBAROMA_GRAPHSRC%% "%LIBAROMA_SOURCE%\src\graph\%%F"
)
set "LIBAROMA_HIDSRC= "
for /f "tokens=*" %%F in ('dir /b /a:-d "%LIBAROMA_SOURCE%\src\hid\*.c"') do (
	call set LIBAROMA_HIDSRC=%%LIBAROMA_HIDSRC%% "%LIBAROMA_SOURCE%\src\hid\%%F"
)
set "LIBAROMA_MINZIPSRC= "
if not "%LIBAROMA_ZIP%"=="no" (
	for /f "tokens=*" %%F in ('dir /b /a:-d "%LIBAROMA_SOURCE%\src\minzip\*.c"') do (
		call set LIBAROMA_MINZIPSRC=%%LIBAROMA_MINZIPSRC%% "%LIBAROMA_SOURCE%\src\minzip\%%F"
	)
	set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -I"%LIBAROMA_SOURCE%\src\minzip"
)
set "LIBAROMA_UISRC= "
for /f "tokens=*" %%F in ('dir /b /a:-d "%LIBAROMA_SOURCE%\src\ui\*.c"') do (
	call set LIBAROMA_UISRC=%%LIBAROMA_UISRC%% "%LIBAROMA_SOURCE%\src\ui\%%F"
)
set "LIBAROMA_UTILSRC= "
for /f "tokens=*" %%F in ('dir /b /a:-d "%LIBAROMA_SOURCE%\src\utils\*.c"') do (
	call set LIBAROMA_UTILSRC=%%LIBAROMA_UTILSRC%% "%LIBAROMA_SOURCE%\src\utils\%%F"
)
set "LIBAROMA_MAINSRC= "
for /f "tokens=*" %%F in ('dir /b /a:-d "%LIBAROMA_SOURCE%\src\*.c"') do (
	call set LIBAROMA_MAINSRC=%%LIBAROMA_MAINSRC%% "%LIBAROMA_SOURCE%\src\%%F"
)
if "%LIBAROMA_LOGLEVEL%"=="" (
	set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -DLIBAROMA_CONFIG_DEBUG=3
) else set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -DLIBAROMA_CONFIG_DEBUG=%LIBAROMA_LOGLEVEL%
if "%LIBAROMA_LOGFILE%"=="" (
	set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -DLIBAROMA_CONFIG_DEBUG_FILE=0
) else set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -DLIBAROMA_CONFIG_DEBUG_FILE=%LIBAROMA_LOGFILE%
if "%LIBAROMA_BUILDINFO%"=="yes" set LIBAROMA_CFLAGS=!LIBAROMA_CFLAGS! -DLIBAROMA_CONFIG_COMPILER_MESSAGE=1

echo Building libaroma
%LIBAROMA_GCC% ^
	%LA_GENERIC_CFLAGS% ^
	!LIBAROMA_CFLAGS! ^
	^
	!LIBAROMA_PLATSRC! ^
	!LIBAROMA_DEBUGSRC! ^
	!LIBAROMA_CTLSRC! ^
	!LIBAROMA_LISTSRC! ^
	!LIBAROMA_GRAPHSRC! ^
	!LIBAROMA_HIDSRC! ^
	!LIBAROMA_MINZIPSRC! ^
	!LIBAROMA_UISRC! ^
	!LIBAROMA_UTILSRC! ^
	!LIBAROMA_MAINSRC! ^
	^
	-I..\..\zlib\src ^
	-I..\..\png ^
	-I..\..\freetype\include ^
	-I"%LIBAROMA_SOURCE%\src" ^
	-I"%LIBAROMA_SOURCE%\src\plat\!LIBAROMA_PLATFORM!" ^
	-I"%LIBAROMA_SOURCE%\include"
set "aroma_objs= "
for /f "tokens=*" %%F in ('dir /b /a:-d "*.o"') do call set aroma_objs=%%aroma_objs%% %%F
%LIBAROMA_AR% -r -c -s ..\libaroma.a !aroma_objs!
cd ..\..

endlocal