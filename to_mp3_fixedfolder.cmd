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
  set "FILE_OUTPUT=%~sdp1fixed\%~n1.mp3"

  set "PROBED_ACODEC="
  for /f "tokens=*" %%a in ('call ffprobe.exe -hide_banner -loglevel error -strict experimental -i %FILE_INPUT% -select_streams "a:0" -show_entries "stream=codec_name" -print_format "default=noprint_wrappers=1:nokey=1"') do (set PROBED_ACODEC=%%a)

  set "ARGS="

::-------------------------------------------------------------------------------flags
  set ARGS=%ARGS% -flags                    "+low_delay+global_header+loop-unaligned-ilme-cgop-output_corrupt"
  set ARGS=%ARGS% -flags2                   "+fast+ignorecrop+showall+export_mvs"
  set ARGS=%ARGS% -fflags                   "+autobsf+igndts+ignidx+genpts+nofillin+discardcorrupt-fastseek"

  set ARGS=%ARGS% -movflags                 "+faststart+disable_chpl"

  set ARGS=%ARGS% -avoid_negative_ts        "make_zero"
  set ARGS=%ARGS% -segment_time_metadata    "1"
  set ARGS=%ARGS% -seek2any                 "1"
  set ARGS=%ARGS% -analyzeduration          "2000000"

  set ARGS=%ARGS% -vn -sn -dn

  set ARGS=%ARGS% -ignore_unknown
  set ARGS=%ARGS% -map_chapters  "-1"
  set ARGS=%ARGS% -map_metadata  "-1"
  set ARGS=%ARGS% -level         "3.0"
  set ARGS=%ARGS% -vsync         "1"

  set ARGS=%ARGS% -b:a           "192k"
  set ARGS=%ARGS% -minrate:a     "192k"
  set ARGS=%ARGS% -maxrate:a     "192k"
  set ARGS=%ARGS% -bufsize:a     "256k"

  set ARGS=%ARGS% -codec:a       "libmp3lame"
  set ARGS=%ARGS% -ar            "48000"
  set ARGS=%ARGS% -af            "afifo,asetpts=PTS-STARTPTS"

  set ARGS=%ARGS% -ss            "00:00:00.001"
::set ARGS=%ARGS% -to            "00:01:00.000"

  set ARGS=%ARGS% -shortest

@echo on
call ffmpeg.exe -y -hide_banner -loglevel "info" -stats -threads "16" -strict "experimental" -i "%FILE_INPUT%" %ARGS% "%FILE_OUTPUT%"

::call exiftool.exe -progress -verbose -trailer:all="" -XMPToolkit="" -all="" "%FILE_OUTPUT%"
@echo off
echo.


::--------------------------------------------------------------------------------

:NEXT
shift
goto LOOP

:END
pause


