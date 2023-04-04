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

rem shift params if needed
if defined CUSTOM_CFG shift && set CUSTOM_CFG=

rem check for out\libs folders
if not exist "%LIBAROMA_OUT%\libs\" mkdir "%LIBAROMA_OUT%\libs"
cd "%LIBAROMA_OUT%\libs"
rem setup libraries to be built
set TARGET_LIBS=zlib png freetype
if "%1"=="" (
	if "%LIBAROMA_PLATFORM%"=="linux" if "%LIBAROMA_DRM%"=="yes" set TARGET_LIBS=!TARGET_LIBS! drm
	if "%LIBAROMA_JPEG%"=="yes" set TARGET_LIBS=!TARGET_LIBS! jpeg
	if "%LIBAROMA_HARFBUZZ%"=="yes" set TARGET_LIBS=!TARGET_LIBS! harfbuzz
	rem cannot use %* because of param shifting ignored by it
) else set TARGET_LIBS=%1 %2 %3 %4 %5 %6

rem build libraries from list
for %%i in (!TARGET_LIBS!) do (
	rem fail on invalid name
	if not exist ..\..\%%i\ echo Invalid library name ^(%%i^) && goto end
	echo Building %%i
	if exist %%i\ rd /s /q %%i
	mkdir %%i
	cd %%i
	call :%%i
	set "lib_objs= "
	for /f "tokens=*" %%F in ('dir /b /a:-d ".\*.o"') do call set lib_objs=%%lib_objs%% %%F
	%LIBAROMA_AR% -r -c -s ..\..\libadeps.a !lib_objs!
	cd ..
)
goto end

:zlib
if "%LIBAROMA_PLATFORM%"=="linux" (
	set ZLIB_CFLAGS=-DUSE_MMAP
) else set "ZLIB_CFLAGS= "
%LIBAROMA_GCC% -c ^
	%LA_GENERIC_CFLAGS% ^
	!ZLIB_CFLAGS! ^
	..\..\..\zlib\src\adler32.c ^
	..\..\..\zlib\src\compress.c ^
	..\..\..\zlib\src\crc32.c ^
	..\..\..\zlib\src\deflate.c ^
	..\..\..\zlib\src\gzclose.c ^
	..\..\..\zlib\src\gzlib.c ^
	..\..\..\zlib\src\gzread.c ^
	..\..\..\zlib\src\gzwrite.c ^
	..\..\..\zlib\src\infback.c ^
	..\..\..\zlib\src\inflate.c ^
	..\..\..\zlib\src\inftrees.c ^
	..\..\..\zlib\src\inffast.c ^
	..\..\..\zlib\src\trees.c ^
	..\..\..\zlib\src\uncompr.c ^
	..\..\..\zlib\src\zutil.c ^
  -I..\..\..\zlib\src
goto :eof
:png
set "PNG_OPTIMIZATIONS= "
if "%LIBAROMA_CPU%"=="neon" set PNG_OPTIMIZATIONS= ^
	..\..\..\png\arm\arm_init.c ^
	..\..\..\png\arm\filter_neon.S ^
	..\..\..\png\arm\filter_neon_intrinsics.c ^
	..\..\..\png\arm\palette_neon_intrinsics.c
%LIBAROMA_GCC% -c ^
	%LA_GENERIC_CFLAGS% ^
	!PNG_OPTIMIZATIONS! ^
	..\..\..\png\png.c ^
	..\..\..\png\pngerror.c ^
	..\..\..\png\pngget.c ^
	..\..\..\png\pngmem.c ^
	..\..\..\png\pngpread.c ^
	..\..\..\png\pngread.c ^
	..\..\..\png\pngrio.c ^
	..\..\..\png\pngrtran.c ^
	..\..\..\png\pngrutil.c ^
	..\..\..\png\pngset.c ^
	..\..\..\png\pngtrans.c ^
	..\..\..\png\pngwio.c ^
	..\..\..\png\pngwrite.c ^
	..\..\..\png\pngwtran.c ^
	..\..\..\png\pngwutil.c ^
  -I..\..\..\png ^
  -I..\..\..\zlib\src
goto :eof
:freetype
set FREETYPE_CFLAGS= -DFT2_BUILD_LIBRARY -DFT_CONFIG_OPTION_SUBPIXEL_RENDERING -DDARWIN_NO_CARBON
if "%LIBAROMA_HARFBUZZ%"=="yes" set FREETYPE_CFLAGS=%FREETYPE_CFLAGS% -DFT_CONFIG_OPTION_USE_HARFBUZZ -I..\..\..\harfbuzz\src
%LIBAROMA_GCC% -c ^
	%LA_GENERIC_CFLAGS% ^
	!FREETYPE_CFLAGS! ^
	..\..\..\freetype\src\base\ftbbox.c ^
	..\..\..\freetype\src\base\ftbitmap.c ^
	..\..\..\freetype\src\base\ftdebug.c ^
	..\..\..\freetype\src\base\ftfstype.c ^
	..\..\..\freetype\src\base\ftglyph.c ^
	..\..\..\freetype\src\base\ftlcdfil.c ^
	..\..\..\freetype\src\base\ftstroke.c ^
	..\..\..\freetype\src\base\fttype1.c ^
	..\..\..\freetype\src\base\ftbase.c ^
	..\..\..\freetype\src\base\ftsystem.c ^
	..\..\..\freetype\src\base\ftinit.c ^
	..\..\..\freetype\src\base\ftgasp.c ^
	..\..\..\freetype\src\raster\raster.c ^
	..\..\..\freetype\src\sfnt\sfnt.c ^
	..\..\..\freetype\src\smooth\smooth.c ^
	..\..\..\freetype\src\autofit\autofit.c ^
	..\..\..\freetype\src\truetype\truetype.c ^
	..\..\..\freetype\src\cff\cff.c ^
	..\..\..\freetype\src\cid\type1cid.c ^
	..\..\..\freetype\src\bdf\bdf.c ^
	..\..\..\freetype\src\type1\type1.c ^
	..\..\..\freetype\src\type42\type42.c ^
	..\..\..\freetype\src\winfonts\winfnt.c ^
	..\..\..\freetype\src\pcf\pcf.c ^
	..\..\..\freetype\src\pfr\pfr.c ^
	..\..\..\freetype\src\psaux\psaux.c ^
	..\..\..\freetype\src\psnames\psnames.c ^
	..\..\..\freetype\src\pshinter\pshinter.c ^
	..\..\..\freetype\src\sdf\ftsdf.c ^
	..\..\..\freetype\src\sdf\ftbsdf.c ^
	..\..\..\freetype\src\sdf\ftsdfrend.c ^
	..\..\..\freetype\src\gzip\ftgzip.c ^
	..\..\..\freetype\src\lzw\ftlzw.c ^
  -I..\..\..\zlib ^
  -I..\..\..\freetype\builds ^
  -I..\..\..\freetype\include ^
  -I..\..\..\freetype\src\sdf
goto :eof
:jpeg
set JPEG_CFLAGS=-DAVOID_TABLES
set "JPEG_OPTIMIZATIONS= "
if "%LIBAROMA_CPU%"=="neon" (
	set JPEG_OPTIMIZATIONS= ^
		..\..\..\jpeg\jsimd_arm_neon.S ^
		..\..\..\jpeg\jsimd_neon.c ^
		..\..\..\jpeg\jmem-android.c
	set JPEG_CFLAGS=%JPEG_CFLAGS% -DNV_ARM_NEON -DANDROID_TILE_BASED_DECODE
) else set JPEG_OPTIMIZATIONS=..\..\..\jpeg\jmemnobs.c
%LIBAROMA_GCC% -c ^
	%LA_GENERIC_CFLAGS% ^
	!JPEG_CFLAGS! ^
	!JPEG_OPTIMIZATIONS! ^
	..\..\..\jpeg\jcapimin.c ^
	..\..\..\jpeg\jcapistd.c ^
	..\..\..\jpeg\jccoefct.c ^
	..\..\..\jpeg\jccolor.c ^
	..\..\..\jpeg\jcdctmgr.c ^
	..\..\..\jpeg\jchuff.c ^
	..\..\..\jpeg\jcinit.c ^
	..\..\..\jpeg\jcmainct.c ^
	..\..\..\jpeg\jcmarker.c ^
	..\..\..\jpeg\jcmaster.c ^
	..\..\..\jpeg\jcomapi.c ^
	..\..\..\jpeg\jcparam.c ^
	..\..\..\jpeg\jcphuff.c ^
	..\..\..\jpeg\jcprepct.c ^
	..\..\..\jpeg\jcsample.c ^
	..\..\..\jpeg\jctrans.c ^
	..\..\..\jpeg\jdapimin.c ^
	..\..\..\jpeg\jdapistd.c ^
	..\..\..\jpeg\jdatadst.c ^
	..\..\..\jpeg\jdatasrc.c ^
	..\..\..\jpeg\jdcoefct.c ^
	..\..\..\jpeg\jdcolor.c ^
	..\..\..\jpeg\jddctmgr.c ^
	..\..\..\jpeg\jdhuff.c ^
	..\..\..\jpeg\jdinput.c ^
	..\..\..\jpeg\jdmainct.c ^
	..\..\..\jpeg\jdmarker.c ^
	..\..\..\jpeg\jdmaster.c ^
	..\..\..\jpeg\jdmerge.c ^
	..\..\..\jpeg\jdphuff.c ^
	..\..\..\jpeg\jdpostct.c ^
	..\..\..\jpeg\jdsample.c ^
	..\..\..\jpeg\jdtrans.c ^
	..\..\..\jpeg\jerror.c ^
	..\..\..\jpeg\jfdctflt.c ^
	..\..\..\jpeg\jfdctfst.c ^
	..\..\..\jpeg\jfdctint.c ^
	..\..\..\jpeg\jidctflt.c ^
	..\..\..\jpeg\jidctfst.c ^
	..\..\..\jpeg\jidctint.c ^
	..\..\..\jpeg\jidctred.c ^
	..\..\..\jpeg\jquant1.c ^
	..\..\..\jpeg\jquant2.c ^
	..\..\..\jpeg\jutils.c ^
	..\..\..\jpeg\jmemmgr.c ^
  -I..\..\..\jpeg
goto :eof
:harfbuzz
set HARFBUZZ_CFLAGS=-DHB_NO_MT -DHAVE_OT -DHAVE_UCDN -DHAVE_FREETYPE
%LIBAROMA_GCC% -c ^
	%LA_GENERIC_CFLAGS% ^
	!HARFBUZZ_CFLAGS! ^
	..\..\..\harfbuzz\src\hb-ot-font.cc ^
	..\..\..\harfbuzz\src\hb-ot-face.cc ^
	..\..\..\harfbuzz\src\hb-ot-math.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape-complex-default.cc ^
	..\..\..\harfbuzz\src\hb-subset-input.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape-complex-hangul.cc ^
	..\..\..\harfbuzz\src\hb-gobject-structs.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape-complex-khmer.cc ^
	..\..\..\harfbuzz\src\hb-map.cc ^
	..\..\..\harfbuzz\src\hb-ot-metrics.cc ^
	..\..\..\harfbuzz\src\hb-font.cc ^
	..\..\..\harfbuzz\src\hb-aat-map.cc ^
	..\..\..\harfbuzz\src\hb-buffer-serialize.cc ^
	..\..\..\harfbuzz\src\hb-directwrite.cc ^
	..\..\..\harfbuzz\src\hb-number.cc ^
	..\..\..\harfbuzz\src\hb-face.cc ^
	..\..\..\harfbuzz\src\hb-shape-plan.cc ^
	..\..\..\harfbuzz\src\hb-uniscribe.cc ^
	..\..\..\harfbuzz\src\hb-ot-cff2-table.cc ^
	..\..\..\harfbuzz\src\hb-ucd.cc ^
	..\..\..\harfbuzz\src\hb-style.cc ^
	..\..\..\harfbuzz\src\hb-static.cc ^
	..\..\..\harfbuzz\src\hb-coretext.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape-complex-syllabic.cc ^
	..\..\..\harfbuzz\src\hb-shaper.cc ^
	..\..\..\harfbuzz\src\hb-ot-var.cc ^
	..\..\..\harfbuzz\src\hb-aat-layout.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape-complex-indic.cc ^
	..\..\..\harfbuzz\src\hb-glib.cc ^
	..\..\..\harfbuzz\src\hb-ft.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape-complex-myanmar.cc ^
	..\..\..\harfbuzz\src\hb-ot-meta.cc ^
	..\..\..\harfbuzz\src\hb-ot-tag.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape-normalize.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape-complex-indic-table.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape-fallback.cc ^
	..\..\..\harfbuzz\src\hb-buffer.cc ^
	..\..\..\harfbuzz\src\hb-ot-cff1-table.cc ^
	..\..\..\harfbuzz\src\hb-set.cc ^
	..\..\..\harfbuzz\src\hb-icu.cc ^
	..\..\..\harfbuzz\src\hb-subset-cff1.cc ^
	..\..\..\harfbuzz\src\hb-subset-plan.cc ^
	..\..\..\harfbuzz\src\hb-common.cc ^
	..\..\..\harfbuzz\src\hb-subset-cff-common.cc ^
	..\..\..\harfbuzz\src\hb-ot-color.cc ^
	..\..\..\harfbuzz\src\hb-graphite2.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape-complex-thai.cc ^
	..\..\..\harfbuzz\src\hb-subset-cff2.cc ^
	..\..\..\harfbuzz\src\hb-subset.cc ^
	..\..\..\harfbuzz\src\hb-shape.cc ^
	..\..\..\harfbuzz\src\hb-gdi.cc ^
	..\..\..\harfbuzz\src\hb-fallback-shape.cc ^
	..\..\..\harfbuzz\src\hb-blob.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape-complex-hebrew.cc ^
	..\..\..\harfbuzz\src\hb-draw.cc ^
	..\..\..\harfbuzz\src\hb-unicode.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape-complex-arabic.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape-complex-vowel-constraints.cc ^
	..\..\..\harfbuzz\src\hb-ot-layout.cc ^
	..\..\..\harfbuzz\src\hb-ot-shape-complex-use.cc ^
	..\..\..\harfbuzz\src\hb-ot-map.cc ^
	..\..\..\harfbuzz\src\hb-ot-name.cc ^
  -I..\..\..\freetype\builds ^
  -I..\..\..\freetype\include ^
  -I..\..\..\harfbuzz\src
goto :eof
:drm
rem Skip drm if incompatible/disabled
if not "%LIBAROMA_PLATFORM%"=="linux" echo DRM library not needed && goto :eof
if not "%LIBAROMA_DRM%"=="yes" echo DRM library not needed && goto :eof
set DRM_CFLAGS=-DUSE_MMAP -D_GNU_SOURCE -DMAJOR_IN_SYSMACROS
%LIBAROMA_GCC% -c ^
	%LA_GENERIC_CFLAGS% ^
	!DRM_CFLAGS! ^
	..\..\..\drm\xf86drm.c ^
	..\..\..\drm\xf86drmMode.c ^
	..\..\..\drm\xf86drmHash.c ^
	..\..\..\drm\xf86drmRandom.c ^
  -I..\..\..\drm
goto :eof

:end
cd ..\..
endlocal