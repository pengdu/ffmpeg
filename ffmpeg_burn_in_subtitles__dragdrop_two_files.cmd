@echo off
:: **********************************************************************************************************
:: * this batch file takes two arguments (files),                                                           *
:: * and descides which one is a video and which is a subtitle.                                             *
:: * for 'myvideo.mp4' it will generate an output of 'myvideo_burnedinsubtitle.mkv' .                       *
:: * this batch file avoids setting-variables inside an IF-condition brackets due to CMD bug (uses GOTO).   *
:: **********************************************************************************************************

pushd "%~sdp0"

if ["%~1"] EQU [""] ( goto ERROR_NOARGS ) 
if ["%~2"] EQU [""] ( goto ERROR_NOARG2 ) 

set "FILE_VIDEO="
set "FILE_SUBTITLE="

echo."%~x1" | findstr /I /C:".MP4" /C:".MKV" 2>nul 1>nul
if ["%ErrorLevel%"] EQU ["0"] ( goto VIDEO1 )

echo."%~x1" | findstr /I /C:".SRT" /C:".SUB" /C:".VTT" /C:".ASS" 2>nul 1>nul
if ["%ErrorLevel%"] EQU ["0"] ( goto SUBTITLE1 )

:VIDEO1
  set "FILE_VIDEO=%~f1"
  echo FILE_VIDEO    === %FILE_VIDEO%
  echo."%~x2" | findstr /I /C:".SRT" /C:".SUB" /C:".VTT" /C:".ASS" 2>nul 1>nul
  if ["%ErrorLevel%"] NEQ ["0"] ( goto ERROR_NOSUBTITLE ) 
  set "FILE_SUBTITLE=%~f2"
  echo FILE_SUBTITLE === %FILE_SUBTITLE%
  goto PROCESS

:SUBTITLE1
  set "FILE_SUBTITLE=%~f1"
  echo FILE_SUBTITLE === %FILE_SUBTITLE%
  echo."%~x2" | findstr /I /C:".MP4" /C:".MKV" 2>nul 1>nul
  if ["%ErrorLevel%"] NEQ ["0"] ( goto ERROR_NOVIDEO ) 
  set "FILE_VIDEO=%~f2"
  echo FILE_VIDEO    === %FILE_VIDEO%
  goto PROCESS

:PROCESS
  echo.
  set "FILE_OUT="
::for /f %%a in ("%FILE_VIDEO%") do ( set "FILE_OUT=%%~sdpa%%~na_burnedinsubtitle%%~xa" ) 
  for /f %%a in ("%FILE_VIDEO%") do ( set "FILE_OUT=%%~sdpa%%~na_burnedinsubtitle.mkv"  ) 

::set "FILE_SUBTITLE=%FILE_SUBTITLE:\=/%"

  echo ffmpeg.exe -hide_banner -threads auto -err_detect ignore_err -y -flags "-output_corrupt" -fflags "+discardcorrupt+autobsf" -i "%FILE_VIDEO%" -tag:v hvc1 -c:v libx265 -codec:a copy -crf 26 -preset veryslow -vf "fifo,setpts=PTS-STARTPTS,format=pix_fmts=yuv420p,subtitles=filename='%FILE_SUBTITLE%':force_style='Fontname=Tahoma,Fontsize=28,Shadow=1'" "%FILE_OUT%"
  goto END

::---------------------------------------------------

:ERROR_NOARGS
  echo [ERROR] missing arguments.       1>&2
  goto END
  
:ERROR_NOARG2
  echo [ERROR] missing 2nd-argument.    1>&2
  goto END

:ERROR_NOSUBTITLE
  echo [ERROR] missing subtitle.        1>&2
  goto END

:ERROR_NOVIDEO
  echo [ERROR] missing video.           1>&2
  goto END

:END
  pushd                                 1>NUL 2>NUL
  pause
::exit /b 0