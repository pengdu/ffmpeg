::@echo off
chcp 65001 1>nul 2>nul

pushd "%~sdp0"

for %%x in (
  ".\windows ffmpeg builds - github nanake - ffmpeg-tinderbox - with nonfree"
  ".\windows ffmpeg builds - github yt-dlp - FFmpeg-Builds - last with nonfree"
  ".\x windows ffmpeg builds - archive of ffmpeg.zeranoe.com - old but good"
  ".\x windows ffmpeg builds - github AnimMouse - ffmpeg-autobuild - with few nonfree"
  ".\x windows ffmpeg builds - github BtbN FFmpeg-Builds - limited to free libs only"
  ".\x windows ffmpeg builds - gyan.dev"
  ".\.."
) do (
  call :METHOD__ACTION %%x
)

goto END
::======================================================================================================

:METHOD__ACTION
  pushd "%~1"
  title %CD%
  echo [INFO] Current Folder Changed To: [%CD%]

::===================================================================================================== FFMPEG VERSION / -H FULL
  call "ffmpeg.exe" -version               2>&1  1>readme_ffmpeg.nfo
  echo.>>readme_ffmpeg.nfo
  echo.---------------------------------------------------------------->>readme_ffmpeg.nfo
  call "ffmpeg.exe" -hide_banner -h full   2>&1  1>>readme_ffmpeg.nfo

::===================================================================================================== FFMPEG FILTERS
  call "ffmpeg.exe" -version               2>&1  1>readme_ffmpeg_filters.nfo
  echo.>>readme_ffmpeg_filters.nfo
  echo.---------------------------------------------------------------->>readme_ffmpeg_filters.nfo
  call "ffmpeg.exe" -hide_banner -filters  2>&1  1>>readme_ffmpeg_filters.nfo

::===================================================================================================== FFMPEG FORMATS
  call "ffmpeg.exe" -version               2>&1  1>readme_ffmpeg_formats.nfo
  echo.>>readme_ffmpeg_formats.nfo
  echo.---------------------------------------------------------------->>readme_ffmpeg_formats.nfo
  call "ffmpeg.exe" -hide_banner -formats  2>&1  1>>readme_ffmpeg_formats.nfo

::===================================================================================================== FFMPEG CODECS
  call "ffmpeg.exe" -version               2>&1  1>readme_ffmpeg_codecs.nfo
  echo.>>readme_ffmpeg_codecs.nfo
  echo.---------------------------------------------------------------->>readme_ffmpeg_codecs.nfo
  call "ffmpeg.exe" -hide_banner -codecs   2>&1  1>>readme_ffmpeg_codecs.nfo


::=====================================================================================================
::=====================================================================================================

::===================================================================================================== FFPLAY
  call "ffplay.exe" -version               2>&1   1>readme_ffplay.nfo
  echo.>>readme_ffplay.nfo
  echo.---------------------------------------------------------------->>readme_ffplay.nfo
  call "ffplay.exe" -hide_banner -h full   2>&1  1>>readme_ffplay.nfo

::===================================================================================================== FFPROBE
  call "ffprobe.exe" -version               2>&1   1>readme_ffprobe.nfo
  echo.>>readme_ffprobe.nfo
  echo.---------------------------------------------------------------->>readme_ffprobe.nfo
  call "ffprobe.exe" -hide_banner -h full   2>&1  1>>readme_ffprobe.nfo

  echo.
  popd
  goto :EOF

::======================================================================================================
:END
  pause
  popd
  exit /b 0
