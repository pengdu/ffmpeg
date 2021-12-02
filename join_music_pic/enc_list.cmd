@echo off
::                      Enable Unicode support.
chcp 65001 2>nul >nul

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

call enc.cmd *%

::--------------------------------------------------------------------------------

:NEXT
shift
goto LOOP

:END
pause

::-mpv_flags                "+strict_gop"
::-force_duplicated_matrix  "1"
::-strict_gop               "1"
