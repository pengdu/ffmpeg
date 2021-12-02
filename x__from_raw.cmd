@echo off
chcp 65001          2>nul >nul
mkdir "%~sdp1fixed" 2>nul >nul

echo.
echo %~1
echo.

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

  echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  echo Raw-video demuxer. Information needed:
  echo.
  set /p        "WIDTH=Video Size (Width)?:      [320] » "
  set /p       "HEIGHT=Video Size (Height)?:     [240] » "
  set /p    "FRAMERATE=Frame-Rate?:               [25] » "
  set /p "PIXEL_FORMAT=Pixel-Format?:        [yuv420p] » "
  echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  set /p   "OUT_FORMAT=Output Extention?:        [mp4] » "

  if ["%WIDTH%"]        EQU [""] ( set "WIDTH=320"            ) 
  if ["%HEIGHT%"]       EQU [""] ( set "HEIGHT=240"           ) 
  if ["%FRAMERATE%"]    EQU [""] ( set "FRAMERATE=25"         ) 
  if ["%PIXEL_FORMAT%"] EQU [""] ( set "PIXEL_FORMAT=yuv420p" ) 
  if ["%OUT_FORMAT%"]   EQU [""] ( set "OUT_FORMAT=mp4"       ) 

  set "FILE_OUTPUT=%~sdp1fixed\%~n1.%OUT_FORMAT%"
  echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  echo.
  echo to:    %FILE_OUTPUT%
  echo.

  set "ARGS="
  set  ARGS=%ARGS% ffmpeg.exe
  set  ARGS=%ARGS% -y -hide_banner -loglevel "info" -stats -strict "experimental"

  set  ARGS=%ARGS% -f             "rawvideo"
  set  ARGS=%ARGS% -video_size    "%WIDTH%x%HEIGHT%"
::set  ARGS=%ARGS% -framerate     "%FRAMERATE%"
::set  ARGS=%ARGS% -pixel_format  "%PIXEL_FORMAT%"
  set  ARGS=%ARGS% -i             "%FILE_INPUT%"

  set  ARGS=%ARGS% -pix_fmt       "yuv420p"
::set  ARGS=%ARGS% -vf            "fifo,setpts=PTS-STARTPTS,format=pix_fmts=yuv420p"
::set  ARGS=%ARGS% -af            "afifo,asetpts=PTS-STARTPTS"

  set  ARGS=%ARGS%    "%FILE_OUTPUT%"


  echo.
  echo.
  echo %ARGS%
  echo.
  call %ARGS%
  echo.
  echo.

::--------------------------------------------------------------------------------

:NEXT
shift
goto LOOP

:END
pause
