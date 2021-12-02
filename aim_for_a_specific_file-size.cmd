@echo off
chcp 65001          2>nul >nul
mkdir "%~sdp1fixed" 2>nul >nul

if ["%~1"] EQU [""] ( goto NOARG )
if not exist %~s1   ( goto NOARG )


::---------------------------cleanup
set "FILE_INPUT="
set "FILE_OUTPUT="
set "DURATION="
set "SIZE="
set "BITRATE="
::---------------------------

set "FILE_INPUT=%~s1"

::---------------------------get duration in seconds
for /f "tokens=*" %%a in ('call ffprobe -hide_banner -v "error" -i %FILE_INPUT% -select_streams "v:0" -show_entries "stream=duration" -print_format "default=noprint_wrappers=1:nokey=1" ') do ( 
  set /a "DURATION=%%a * 1" 
) 
::---------------------------


::---------------------------get desired size from user-input
set /p "SIZE=Enter Desired Size (MB): "           1>&2
if ["%SIZE%"] EQU [""] ( goto END ) 
set /a "SIZE=%SIZE% * 1"
::to kBit
set /a "SIZE=%SIZE% * 8192"
::---------------------------


set /a "BITRATE=%SIZE% / %DURATION%"

echo  duration:       [%DURATION%] seconds        1>&2
echo  size:           [%SIZE%] kBit               1>&2
echo  bitrate:        [%BITRATE%] kBit/s          1>&2

::loose last-digit-precision, round up.
set /a "BITRATE=(%BITRATE% / 10) * 10"
set /a "BITRATE=%BITRATE% + 10"

echo  bitrate (aim):  [%BITRATE%] kBit/s          1>&2


set "FILE_OUTPUT=%~sdp1fixed\%~n1_%BITRATE%kbps.mp4"

echo.                                             1>&2
echo.                                             1>&2

echo input:     %~1                               1>&2
echo output:    %FILE_OUTPUT%                     1>&2
echo press any key to start encoding...           1>&2
pause >nul

echo.                                             1>&2
echo.                                             1>&2


ffmpeg -y -hide_banner -i "%FILE_INPUT%" -movflags "+faststart" -tune "zerolatency" -b:v "%BITRATE%k" -pass 1 -f mp4  nul
ffmpeg -y -hide_banner -i "%FILE_INPUT%" -movflags "+faststart" -tune "zerolatency" -b:v "%BITRATE%k" -pass 2         "%FILE_OUTPUT%"


goto END


:NOARG
  echo ERROR: missing argument.                   1>&2
  goto END

:END
  pause
