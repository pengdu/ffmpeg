@echo off
chcp 65001          2>nul >nul

  set "ARGS="
  set ARGS=%ARGS% -hide_banner -loglevel "error" -strict "experimental"
  set ARGS=%ARGS% -i "%~f1"

::limit to VIDEO (for example on WEBM it will return "vp9")
  set ARGS=%ARGS% -select_streams "v:0"

::limit to AUDIO (for example on WEBM it will return "opus")
::set ARGS=%ARGS% -select_streams "a:0"

  set ARGS=%ARGS% -show_entries "stream=codec_name"
  set ARGS=%ARGS% -print_format "default=noprint_wrappers=1:nokey=1"


@echo on
call ffprobe.exe %ARGS%
@echo off

exit /b %ErrorLevel%