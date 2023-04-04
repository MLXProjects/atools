@echo off
set LA_GENERIC_CFLAGS=-Wl,--no-as-needed -D_LARGEFILE64_SOURCE -fPIC -DPIC
set CFG_NAME=config.txt
if not "%~1"=="" set CFG_NAME=config-%~1.txt

for /f "usebackq tokens=1,2 delims==" %%a in ("!CFG_NAME!") do (
	rem get key and value from tokens
	set key=%%a
	set val=%%b
	rem remove spaces before and after the key name
	call :trim key
	rem ignore comment lines
	if not "!key:~0,1!" == "#" (
		rem if vaule is not empty, set the variable
		if not "!val!" == "" (
			call :trim val
			set !key!=!val!
		)
	)
)
rem check for must-have variables
if "%LIBAROMA_SOURCE%"=="" call :fail LIBAROMA_SOURCE && goto :eof
if "%LIBAROMA_PLATFORM%"=="" call :fail LIBAROMA_PLATFORM && goto :eof

rem setup generic flags
if "!LIBAROMA_DEBUG!"=="yes" (
	set LA_GENERIC_CFLAGS=!LA_GENERIC_CFLAGS! -g -ggdb
) else set LA_GENERIC_CFLAGS=!LA_GENERIC_CFLAGS! -s -O3
if "!LIBAROMA_WARNINGS!"=="yes" (
	set LA_GENERIC_CFLAGS=!LA_GENERIC_CFLAGS! -Wall -Wextra
) else set LA_GENERIC_CFLAGS=!LA_GENERIC_CFLAGS! -w
if "!LIBAROMA_CPU!"=="neon" set LA_GENERIC_CFLAGS=!LA_GENERIC_CFLAGS! -mfloat-abi=hard -mfpu=neon -D__ARM_NEON
if "!LIBAROMA_CPU!"=="ssse3" set LA_GENERIC_CFLAGS=!LA_GENERIC_CFLAGS! -mssse3 -D__i386
if "!LIBAROMA_NOWINCONSOLE!"=="yes" set LA_GENERIC_CFLAGS=!LA_GENERIC_CFLAGS! -mwindows
rem setup out folder name
set LIBAROMA_OUT=out-%LIBAROMA_PLATFORM%
rem if custom config in use, replace platform with config name
if not "%~1"=="" set LIBAROMA_OUT=out-%~1
rem append optimization name if set
if not "LIBAROMA_CPU"=="" set LIBAROMA_OUT=%LIBAROMA_OUT%_%LIBAROMA_CPU%
goto :eof

:trim
setlocal enabledelayedexpansion
call :trimhelper %%%1%%
endlocal & set %1=%tempvar:"=%
goto :eof

:trimhelper
set tempvar=%*
goto :eof

:fail
echo %1 not set!
goto :eof