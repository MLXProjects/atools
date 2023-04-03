@echo off
rem delay variable expansion, set base vars & load settings
setlocal enabledelayedexpansion
set "APP_PATH= "
set "APP_NAME= "
if "%2"=="" (
	set APP_PATH=%~1
	set APP_NAME=%~n1
	call _setldr.cmd
) else (
	set APP_PATH=%~2
	set APP_NAME=%~n2
	call _setldr.cmd %1
)

if not exist !LIBAROMA_OUT!\libaroma.a call abuild.cmd

rem set build dependencies
set LIBAROMA_DEPENDS=-lpthread -lm -lstdc++
if "!LIBAROMA_PLATFORM!"=="sdl" (
	set LIBAROMA_DEPENDS=-lSDL !LIBAROMA_DEPENDS!
) else if "!LIBAROMA_PLATFORM!"=="sdl2" (
	set LIBAROMA_DEPENDS=-lSDL2 !LIBAROMA_DEPENDS!
) else if "!LIBAROMA_PLATFORM!"=="linux" (
	set LIBAROMA_DEPENDS=-lrt !LIBAROMA_DEPENDS!
)
if not "!LIBAROMA_OPENMP!"=="no" set LIBAROMA_DEPENDS=-fopenmp !LIBAROMA_DEPENDS!

echo Building !APP_NAME!
rem build source list
set "app_src= "
for /f "tokens=*" %%F in ('dir /b /a:-d "!APP_PATH!\*.c"') do call set app_src=%%app_src%% "!APP_PATH!\%%F"
if "LIBAROMA_PLATFORM"=="linux" (
rem if building for linux, set static and use .a files as libs
	set LIBAROMA_DEPENDS=-static -laroma -ladeps !LIBAROMA_DEPENDS!
rem otherwise, just use them as regular objects
) else set app_src=!app_src! "!LIBAROMA_OUT!\libaroma.a" "!LIBAROMA_OUT!\libadeps.a"
rem build app
"!LIBAROMA_GCC!" !LA_GENERIC_CFLAGS! ^
	!app_src! ^
	-L"!LIBAROMA_OUT!" ^
	!LIBAROMA_DEPENDS! ^
	-I"!LIBAROMA_SOURCE!\include" ^
	-o "!LIBAROMA_OUT!\!APP_NAME!.exe"
endlocal