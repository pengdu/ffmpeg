::@echo off

::
::
  set "EXIT_CODE=0"
  chcp 65001 1>nul 2>nul

  set "FFMPEG=%~sdp0ffmpeg.exe"
  set "FFPROBE=%~sdp0FFPROBE.exe"

  title [PROCESSING..] %~nx1

  pushd "%~dp1"

  set "INPUT=%~f1"
  set "OUTPUT=%~dpn1_copyfixed.mkv"

  set "PROBED_VCODEC="
  set "PROBED_ACODEC="
  for /f "tokens=*" %%a in ('call "%FFPROBE%" -hide_banner -loglevel error -strict experimental -i "%INPUT%" -select_streams "v:0" -show_entries "stream=codec_name" -print_format "default=noprint_wrappers=1:nokey=1"') do (set PROBED_VCODEC=%%a)
  for /f "tokens=*" %%a in ('call "%FFPROBE%" -hide_banner -loglevel error -strict experimental -i "%INPUT%" -select_streams "a:0" -show_entries "stream=codec_name" -print_format "default=noprint_wrappers=1:nokey=1"') do (set PROBED_ACODEC=%%a)

::==================================================================== fixes that are done without encoding - by muxer

  set "ARGS="
  if /i ["%PROBED_VCODEC%"] EQU ["mpeg4"] (
    set ARGS=%ARGS% -bsf:v   "mpeg4_unpack_bframes,remove_extra=freq=all"
  )

  if /i ["%PROBED_VCODEC%"] EQU ["h264"]  (
    set ARGS=%ARGS% -bsf:v   "h264_redundant_pps,h264_mp4toannexb,remove_extra=freq=all"
  )

  if /i ["%PROBED_VCODEC%"] EQU ["h265"]  (
    set ARGS=%ARGS% -bsf:v   "hevc_mp4toannexb,remove_extra=freq=all"
  )
  if /i ["%PROBED_VCODEC%"] EQU ["hevc"]  (
    set ARGS=%ARGS% -bsf:v   "hevc_mp4toannexb,remove_extra=freq=all"
  )
  
  if /i ["%PROBED_VCODEC%"] EQU ["vp9"]  (
    set ARGS=%ARGS% -bsf:v   "vp9_superframe,remove_extra=freq=all"
  )

  if /i ["%PROBED_VCODEC%"] NEQ ["mpeg4"]  (
    if /i ["%PROBED_VCODEC%"] NEQ ["h264"]  (
      if /i ["%PROBED_VCODEC%"] NEQ ["h265"]  (
        if /i ["%PROBED_VCODEC%"] NEQ ["hevc"]  (
          if /i ["%PROBED_VCODEC%"] NEQ ["vp9"]  (
            set ARGS=%ARGS% -bsf:v "remove_extra=freq=all"
          )
        )
      )
    )
  )
  ::--------------------------------------------------------------- https://ffmpeg.org/ffmpeg-bitstream-filters.html#mp3decomp
  if /i ["%PROBED_ACODEC%"] EQU ["mp3"] (
   set ARGS=%ARGS% -bsf:a    "mp3decomp"
  )
  if /i ["%PROBED_ACODEC%"] EQU ["aac"] (
   set ARGS=%ARGS% -bsf:a    "aac_adtstoasc"
  )

  ::-hwaccel dxva2
  call "%FFMPEG%" -hide_banner -y -loglevel verbose -stats -strict "experimental" -err_detect "ignore_err" -flags "-output_corrupt" -fflags "+autobsf+discardcorrupt+genpts" -i "%INPUT%" -movflags "+faststart" -codec copy %ARGS% -avoid_negative_ts "make_zero" -segment_time_metadata 1 -safe 0 -enc_time_base "-1" "%OUTPUT%"
::===========================================================================================================

  set "EXIT_CODE=%ErrorLevel%"

  pause
  ::del /f /q "%TEMP%" 1>nul 2>nul
  echo [INFO] EXIT_CODE=%EXIT_CODE%"
  popd
  exit /b %EXIT_CODE%
