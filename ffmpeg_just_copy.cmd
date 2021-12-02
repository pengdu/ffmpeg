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

set FILE_INPUT="%~s1"
set FILE_OUTPUT="%~d1%~p1%~n1_fixed%~x1"

call ffmpeg -y -hide_banner -loglevel "info" -stats -threads 8 -i %FILE_INPUT% -codec copy %FILE_OUTPUT%

echo.
echo.

:NEXT
shift
goto LOOP

:END
pause
