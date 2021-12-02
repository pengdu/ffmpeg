@echo off
chcp 65001          2>nul >nul

  set "ARGS="
  set ARGS=%ARGS% -hide_banner -loglevel "error" -strict "experimental"
  set ARGS=%ARGS% -i "%~f1"

  set ARGS=%ARGS% -show_entries "stream=codec_name"
  set ARGS=%ARGS% -print_format "default=noprint_wrappers=1"


@echo on
call ffprobe.exe %ARGS%
@echo off

pause