@echo off
rem delay variable expansion & load settings
setlocal enabledelayedexpansion
rem check if first parameter is library or config name
if exist "config-%~1.txt" set CUSTOM_CFG=yes
if defined CUSTOM_CFG (
	call _setldr.cmd %1
) else call _setldr.cmd
if "!LIBAROMA_SOURCE!"=="" goto :eof
if "!LIBAROMA_PLATFORM!"=="" goto :eof
if defined CUSTOM_CFG shift
set APP_NAME=%~1
set APP_WIN=
set USE_GDB=
if not exist "!LIBAROMA_OUT!\!APP_NAME!" if not exist "!LIBAROMA_OUT!\!APP_NAME!.exe" echo Binary not found for !APP_NAME! && goto :eof
if exist "!LIBAROMA_OUT!\!APP_NAME!.exe" set APP_WIN=yes
rem push & run app depending on platform
if defined APP_WIN (
	echo Running !APP_NAME!
	if "%LIBAROMA_DEBUG%"=="yes" if defined LIBAROMA_GDB set USE_GDB=yes
	if defined USE_GDB (
		!LIBAROMA_GDB! -ex run --args "!LIBAROMA_OUT!\!APP_NAME!.exe" %2
	) else "!LIBAROMA_OUT!\!APP_NAME!.exe" %2
) else (
	if "%LIBAROMA_DEBUG%"=="yes" if defined LIBAROMA_GDB if exist !LIBAROMA_GDB! set USE_GDB=yes
	if defined USE_GDB (
		echo Pushing GDB to device...
		adb push !LIBAROMA_GDB! /tmp/gdb
		adb shell chmod 0755 /tmp/gdb
	)
	echo Pushing !APP_NAME! to device
	adb push "!LIBAROMA_OUT!\!APP_NAME!" /tmp/test
	adb shell chmod 0755 /tmp/test
	if defined USE_GDB (
		adb shell /tmp/gdb -ex run --args /tmp/test %2
	) else adb shell /tmp/test %2
)

endlocal