@echo off
set "ARGS="
set  ARGS=%ARGS% ffmpeg.exe -y -hide_banner -loglevel "info" -strict "experimental" -threads "16" -stats
set  ARGS=%ARGS% -i "%~1"
set  ARGS=%ARGS% -filter:a
set  ARGS=%ARGS% "
set  ARGS=%ARGS% atempo=tempo=0.5,
set  ARGS=%ARGS% asetrate=sample_rate=44100*1.3,
set  ARGS=%ARGS% aresample=sample_rate=44100:async=100
set  ARGS=%ARGS% "
set  ARGS=%ARGS% -sn -vn 
set  ARGS=%ARGS% "%~dpn1%_speedpitch.m4a"

echo %ARGS%
call %ARGS%
pause
exit /b 0