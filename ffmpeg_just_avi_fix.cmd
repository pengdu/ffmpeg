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
set FILE_OUTPUT="%~d1%~p1%~n1_fixed.avi"

call ffmpeg.exe -y                               ^
-hide_banner -loglevel "info" -stats             ^
-i         %FILE_INPUT%                          ^
-threads   16                                    ^
-flags     "-loop+naq+low_delay"                 ^
-flags2    "+fast+ignorecrop+showall+export_mvs" ^
-fflags    "+genpts+discardcorrupt+fastseek"     ^
-codec     "copy"                                ^
-bsf:v     "mpeg4_unpack_bframes"                ^
%FILE_OUTPUT%

:NEXT
shift
goto LOOP

:END
pause

@echo off
ffmpeg -i INPUT.avi 