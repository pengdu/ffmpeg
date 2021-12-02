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
set ARGS=

::program switches
set ARGS=%ARGS%  -y  -hide_banner  -loglevel "info"  -stats  -threads "16"  -strict "experimental"

::input
set ARGS=%ARGS% -i %FILE_INPUT%

::flags
  set ARGS=%ARGS% -flags              "+low_delay+global_header-unaligned-ilme-cgop-loop-output_corrupt"
  set ARGS=%ARGS% -flags2             "+fast+ignorecrop+showall+export_mvs"
  set ARGS=%ARGS% -fflags             "+genpts+nofillin+discardcorrupt-fastseek-ignidx"
  set ARGS=%ARGS% -movflags           "+faststart+disable_chpl"
  set ARGS=%ARGS% -avoid_negative_ts  "make_zero"

::ignore invalid data
  set ARGS=%ARGS% -ignore_unknown

set ARGS=%ARGS% -vsync "1"

::adjust length to total length of shorter video.
set ARGS=%ARGS% -shortest

::copy
set ARGS=%ARGS% -codec "copy"
set ARGS=%ARGS% -bsf:v "mpeg4_unpack_bframes,remove_extra=freq=all"

echo.
@echo on
call ffmpeg.exe %ARGS% "%FILE_OUTPUT%"
@echo off
echo.
echo.


:NEXT
shift
goto LOOP

:END
pause

