@echo off
chcp 65001          2>nul >nul
mkdir "%~sdp1fixed" 2>nul >nul


:LOOP
::has argument ?
if ["%~1"]==[""] (
  echo done.
  goto END;
)
::argument exist ?
if not exist %~s1 (
  echo not exist
  goto NEXT;
)
::file exist ?
echo exist
if exist %~s1\NUL (
  echo is a directory
  goto NEXT;
)
::OK
echo is a file

::--------------------------------------------------------------------------------

  set "FILE_INPUT=%~s1"
  set "FILE_OUTPUT=%~sdp1fixed\%~n1.raw"

  set "ARGS="
  set  ARGS=%ARGS% ffmpeg.exe
  set  ARGS=%ARGS% -y -hide_banner -loglevel "info" -stats -strict "experimental"

  set  ARGS=%ARGS% -flags   "+bitexact"
  set  ARGS=%ARGS% -bitexact

  set  ARGS=%ARGS% -i       "%FILE_INPUT%"
  set  ARGS=%ARGS% -f       "s16le"
  set  ARGS=%ARGS% -vcodec  "rawvideo"
  set  ARGS=%ARGS% -acodec  "pcm_s16le"
::set  ARGS=%ARGS% -ss      "00:00:00.011"
  set  ARGS=%ARGS% -to      "00:00:05.000"
  set  ARGS=%ARGS%          "%FILE_OUTPUT%"

::
:: example on how to encode a raw-A/V stream to MP4 (#1 == must include the size, #2 optional args, default values supplied):
:: ffmpeg -f "rawvideo" -video_size "320x240"                                             -i file.raw
:: ffmpeg -f "rawvideo" -video_size "320x240" -framerate "25" -pixel_format "yuv420p"     -i file.raw
::


  echo %ARGS%
  call %ARGS%
  echo.
  echo.

::--------------------------------------------------------------------------------

:NEXT
shift
goto LOOP

:END
pause
