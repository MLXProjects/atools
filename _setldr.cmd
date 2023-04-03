@echo off

set LA_GENERIC_CFLAGS=-Wl,--no-as-needed -D_LARGEFILE64_SOURCE -fPIC -DPIC

for /f "tokens=1,2 delims==" %%a in (config.txt) do (
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

if "!LIBAROMA_DEBUG!"=="yes" (
	set LA_GENERIC_CFLAGS=!LA_GENERIC_CFLAGS! -g -ggdb
) else set LA_GENERIC_CFLAGS=!LA_GENERIC_CFLAGS! -s -O3
if "!LIBAROMA_WARNINGS!"=="yes" (
	set LA_GENERIC_CFLAGS=!LA_GENERIC_CFLAGS! -Wall -Wextra
) else set LA_GENERIC_CFLAGS=!LA_GENERIC_CFLAGS! -w
if "!LIBAROMA_CPU!"=="neon" set LA_GENERIC_CFLAGS=!LA_GENERIC_CFLAGS! -mfloat-abi=hard -mfpu=neon -D__ARM_NEON
if "!LIBAROMA_CPU!"=="ssse3" set LA_GENERIC_CFLAGS=!LA_GENERIC_CFLAGS! -mssse3 -D__i386
set LIBAROMA_OUT=out-%LIBAROMA_PLATFORM%
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
