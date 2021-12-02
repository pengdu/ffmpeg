@echo off
chcp 65001   2>nul >nul
mkdir "%~sdp1fixed" 2>nul >nul


@echo off
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

@echo on
set "FILE_INPUT=%~s1"
set "FILE_OUTPUT=%~sdp1fixed\%~nx1"

::remove '.' from extension
set "FORCE_FORMAT=%~x1"
set "FORCE_FORMAT=%FORCE_FORMAT:.=%"

set ARGS=

::program switches

title PASS1- %~nx1
@echo on
call ffmpeg -y -hide_banner -threads "16" -i "%FILE_INPUT%" -pass 1 -f "%FORCE_FORMAT%" -codec "copy" -to "00:00:20.000"   nul
@echo off
title PASS2- %~nx1
@echo on
call ffmpeg -y -hide_banner -threads "16" -i "%FILE_INPUT%" -pass 2                     -codec "copy" -to "00:00:20.000"  "%FILE_OUTPUT%"
@echo off
title Done. see %FILE_OUTPUT%
echo.
echo.


:NEXT
shift
goto LOOP

:END
pause

