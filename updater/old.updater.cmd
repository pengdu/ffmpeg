@echo off

call aria2c.exe   --allow-overwrite=true              ^
                  --auto-file-renaming=false          ^
                  --check-certificate=false           ^
                  --check-integrity=false             ^
                  --console-log-level=notice          ^
                  --continue=true                     ^
                  --dir="."                           ^
                  --disable-ipv6=true                 ^
                  --enable-http-keep-alive=true       ^
                  --enable-http-pipelining=true       ^
                  --file-allocation=prealloc          ^
                  --http-auth-challenge=false         ^
                  --human-readable=true               ^
                  --max-concurrent-downloads=16       ^
                  --max-connection-per-server=16      ^
                  --min-split-size=1M                 ^
                  --referer="https://zeranoe.com"     ^
                  --rpc-secure=false                  ^
                  --split=10                          ^
                  --user-agent="Mozilla/5.0 Chrome"   ^
                  "https://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-latest-win64-static.zip"
::                "https://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-latest-win32-static.zip"

if not exist ".\ffmpeg-latest-win64-static.zip" goto NODOWNLOAD
unzip -o ".\ffmpeg-latest-win64-static.zip"

move /y  .\ffmpeg-latest-win64-static\bin\*.exe    .\..  2>nul >nul
move /y  .\ffmpeg-latest-win64-static\presets\.    .\..  2>nul >nul


::------------------------------------------------------------------------readme update
call ..\ffmpeg.exe  -version              2>&1  >..\readme_ffmpeg.nfo
echo.>>..\readme_ffmpeg.nfo
echo.---------------------------------------------------------------->>..\readme_ffmpeg.nfo
echo.>>..\readme_ffmpeg.nfo
call ..\ffmpeg.exe  -hide_banner  -h full 2>&1 >>..\readme_ffmpeg.nfo


call ..\ffmpeg.exe  -version              2>&1  >..\readme_ffmpeg__filters.nfo
echo.>>..\readme_ffmpeg__filters.nfo
echo.---------------------------------------------------------------->>..\readme_ffmpeg__filters.nfo
echo.>>..\readme_ffmpeg__filters.nfo
call ..\ffmpeg.exe  -hide_banner  -filters 2>&1 >>..\readme_ffmpeg__filters.nfo


call ..\ffplay.exe  -version              2>&1  >..\readme_ffplay.nfo
echo.>>..\readme_ffplay.nfo
echo.---------------------------------------------------------------->>..\readme_ffplay.nfo
echo.>>..\readme_ffplay.nfo
call ..\ffplay.exe  -hide_banner  -h full 2>&1 >>..\readme_ffplay.nfo


call ..\ffprobe.exe  -version              2>&1  >..\readme_ffprobe.nfo
echo.>>..\readme_ffprobe.nfo
echo.---------------------------------------------------------------->>..\readme_ffprobe.nfo
echo.>>..\readme_ffprobe.nfo
call ..\ffprobe.exe  -hide_banner  -h full 2>&1 >>..\readme_ffprobe.nfo


goto EXIT


:NODOWNLOAD
  echo Error:  could not find ffmpeg-latest-win64-static.zip
  goto EXIT

:EXIT
  pause


::cleanup
del   /f /q  ".\ffmpeg-latest-win64-static.zip" 2>nul >nul
rmdir /s /q  ".\ffmpeg-latest-win64-static\"    2>nul >nul

::  --log=log.txt                      ^
::  --log-level=info                   ^