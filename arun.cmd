@echo off
rem delay variable expansion & load settings
setlocal enabledelayedexpansion
rem check if first parameter is library or config name
if exist "config-%~1.txt" set CUSTOM_CFG=yes
if defined CUSTOM_CFG (
	call _setldr.cmd %1
) else call _setldr.cmd
if "%LIBAROMA_SOURCE%"=="" goto :eof
if "%LIBAROMA_PLATFORM%"=="" goto :eof
if defined CUSTOM_CFG shift
set APP_NAME=%~1
if not exist "!LIBAROMA_OUT!\!APP_NAME!" if not exist "!LIBAROMA_OUT!\!APP_NAME!.exe" echo Binary not found for !APP_NAME!
if exist "!LIBAROMA_OUT!\!APP_NAME!.exe" set APP_WIN=yes
rem use 
if defined APP_WIN (
	echo Running !APP_NAME!
	"!LIBAROMA_OUT!\!APP_NAME!.exe" %2
) else (
	echo Pushing !APP_NAME! to device
	adb push "!LIBAROMA_OUT!\!APP_NAME!" /tmp/test
	adb shell chmod 0755 /tmp/test
	adb shell /tmp/test %2
)

endlocal