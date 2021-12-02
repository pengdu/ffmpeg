@echo off
chcp 65001          2>nul >nul

set "URL=%~1"

set "TEMP=%~sdp0temp%RANDOM%.ts"
set "OUTPUT=%~sdp0video.mp4"

set "PRE="
set  PRE=%PRE% -y -hide_banner -loglevel "info" -strict "experimental"

set  PRE=%PRE% -flags             "+low_delay+global_header-unaligned-ilme-cgop-loop-output_corrupt"
set  PRE=%PRE% -flags2            "+fast+ignorecrop+showall+export_mvs"
set  PRE=%PRE% -fflags            "+autobsf+genpts+discardcorrupt-fastseek-nofillin-ignidx-igndts"

set  PRE=%PRE% -avoid_negative_ts "make_zero"
set  PRE=%PRE% -copytb            "1"
set  PRE=%PRE% -start_at_zero
set  PRE=%PRE% -copyts

set "POST="
set  POST=%POST% -codec           "copy"
set  POST=%POST% -mpv_flags       "+strict_gop+naq"
set  POST=%POST% -movflags        "+faststart"


set  C=ffmpeg.exe %PRE% -i "%URL%"  %POST% -bsf:v "h264_mp4toannexb,h264_redundant_pps" -f "mpegts" "%TEMP%"
echo.
echo %C%
call %C%

echo.
set  C=ffmpeg.exe %PRE% -f "mpegts" -i "%TEMP%" %POST% -bsf:v "remove_extra=freq=all" -bsf:a "aac_adtstoasc" "%OUTPUT%"
echo %C%
call %C%
if ["%ErrorLevel%"] EQU ["0"] ( goto END ) 

echo.
set  C=ffmpeg.exe %PRE% -f "mpegts" -i "%TEMP%" %POST% -bsf:v "remove_extra=freq=all" -bsf:a "mp3decomp" "%OUTPUT%"
echo %C%
call %C%
if ["%ErrorLevel%"] EQU ["0"] ( goto END ) 

echo.
set  C=ffmpeg.exe %PRE% -f "mpegts" -i "%TEMP%" %POST% -bsf:v "remove_extra=freq=all" "%OUTPUT%"
echo %C%
call %C%


:END
  echo.
  pause
  del /f /q %TEMP%    2>nul >nul
  exit /b %ErrorLevel%
