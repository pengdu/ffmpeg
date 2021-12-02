@echo off
chcp 65001           2>nul >nul
mkdir "%~sdp1fixed"  2>nul >nul


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

set "FILE_INPUT=%~s1"
set "FILE_OUTPUT=%~sdp1fixed\%~nx1"

call ffmpeg -y -hide_banner -i "%FILE_INPUT%" -codec "copy" "%FILE_OUTPUT%"

:NEXT
shift
goto LOOP

:END
pause

