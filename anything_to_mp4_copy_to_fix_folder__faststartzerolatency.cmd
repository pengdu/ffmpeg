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
  set "FILE_OUTPUT=%~sdp1fixed\%~n1.mp4"

title Processing...
echo.
@echo on
call ffmpeg.exe -y -hide_banner -strict "experimental" -i "%FILE_INPUT%" -movflags "+faststart" -tune "zerolatency" -codec "copy" "%FILE_OUTPUT%"
@echo off
echo.
title Done.


::--------------------------------------------------------------------------------

:NEXT
shift
goto LOOP

:END
pause


