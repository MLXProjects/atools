@echo off
rem delay variable expansion & load config.txt
setlocal enabledelayedexpansion
call _setldr.cmd

rem set build dependencies
set LIBAROMA_DEPENDS=-lpthread -lm -lstdc++
if "%LIBAROMA_PLATFORM%"=="sdl" (
	set LIBAROMA_DEPENDS=-lSDL !LIBAROMA_DEPENDS!
) else if "%LIBAROMA_PLATFORM%"=="sdl2" (
	set LIBAROMA_DEPENDS=-lSDL2 !LIBAROMA_DEPENDS!
) else if "%LIBAROMA_PLATFORM%"=="linux" (
	set LIBAROMA_DEPENDS=-lrt !LIBAROMA_DEPENDS!
)

echo Building %~n1
rem build source list
set "app_src= "
for /f "tokens=*" %%F in ('dir /b /a:-d "%~1\*.c"') do call set app_src=%%app_src%% "%~1\%%F"
if "LIBAROMA_PLATFORM"=="linux" (
rem if building for linux, set static and use .a files as libs
	set LIBAROMA_DEPENDS=-static -laroma -ladeps !LIBAROMA_DEPENDS!
rem otherwise, just use them as regular objects
) else set app_src=!app_src! "%LIBAROMA_OUT%\libaroma.a" "%LIBAROMA_OUT%\libadeps.a"
rem build app
"%LIBAROMA_GCC%" %LA_GENERIC_CFLAGS% ^
	!app_src! ^
	-L"%LIBAROMA_OUT%" ^
	!LIBAROMA_DEPENDS! ^
	-I"%LIBAROMA_SOURCE%\include" ^
	-o "%LIBAROMA_OUT%\%~n1.exe"
endlocal