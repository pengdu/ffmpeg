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
set "FILE_OUTPUT=%~sdp1fixed\%~n1.mkv"

@echo on
call ffmpeg -y -hide_banner -i "%FILE_INPUT%" "%FILE_OUTPUT%"
@echo off
title Done. see %FILE_OUTPUT%
echo.
echo.


:NEXT
shift
goto LOOP

:END
pause

