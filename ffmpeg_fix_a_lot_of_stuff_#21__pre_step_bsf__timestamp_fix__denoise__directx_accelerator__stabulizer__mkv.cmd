::@echo off
::-----------------------
:: Hardware acceleration methods:
::   dxva2
::   vulkan
::   cuda
::   qsv
::   d3d11va
::   opencl
::
::
  set "EXIT_CODE=0"
  chcp 65001 1>nul 2>nul

  set "FFMPEG=%~sdp0ffmpeg.exe"
  set "FFPROBE=%~sdp0FFPROBE.exe"

  title [PROCESSING..] %~nx1

  pushd "%~dp1"

  set "INPUT=%~f1"
  set "OUTPUT=%~dpn1_fixed.mkv"

  set "PROBED_VCODEC="
  set "PROBED_ACODEC="
  for /f "tokens=*" %%a in ('call "%FFPROBE%" -hide_banner -loglevel error -strict experimental -i "%INPUT%" -select_streams "v:0" -show_entries "stream=codec_name" -print_format "default=noprint_wrappers=1:nokey=1"') do (set PROBED_VCODEC=%%a)
  for /f "tokens=*" %%a in ('call "%FFPROBE%" -hide_banner -loglevel error -strict experimental -i "%INPUT%" -select_streams "a:0" -show_entries "stream=codec_name" -print_format "default=noprint_wrappers=1:nokey=1"') do (set PROBED_ACODEC=%%a)

::==================================================================== fixes that are done without encoding - by muxer
  set "TEMP=%~dpn1_temp.mkv"
  del /f /q "%TEMP%" 1>nul 2>nul

  set "ARGS="
  if /i ["%PROBED_VCODEC%"] EQU ["mpeg4"] (
    set ARGS=%ARGS% -bsf:v   "mpeg4_unpack_bframes,remove_extra=freq=all"
  )
  if /i ["%PROBED_VCODEC%"] EQU ["h264"]  (
    set ARGS=%ARGS% -bsf:v   "h264_redundant_pps,remove_extra=freq=all"
  )
  if /i ["%PROBED_VCODEC%"] NEQ ["mpeg4"]  (
    if /i ["%PROBED_VCODEC%"] NEQ ["h264"]  (
      set ARGS=%ARGS% -bsf:v "remove_extra=freq=all"
    )
  )

  if /i ["%PROBED_ACODEC%"] EQU ["mp3"] (
   set ARGS=%ARGS% -bsf:a    "mp3decomp"
  )
  if /i ["%PROBED_ACODEC%"] EQU ["aac"] (
   set ARGS=%ARGS% -bsf:a    "aac_adtstoasc"
  )

  ::-hwaccel d3d11va
  call "%FFMPEG%" -hide_banner -y -loglevel verbose -stats -strict "experimental" -err_detect "ignore_err" -flags "-output_corrupt" -fflags "+autobsf+discardcorrupt+genpts" -i "%INPUT%" -movflags "+faststart" -codec copy %ARGS% -avoid_negative_ts "make_zero" -segment_time_metadata 1 -safe 0 -enc_time_base "-1" "%TEMP%"
::===========================================================================================================



  set "ARGS="
  set  ARGS=%ARGS% -hide_banner
  set  ARGS=%ARGS% -y
  set  ARGS=%ARGS% -loglevel verbose -stats
  set  ARGS=%ARGS% -strict "experimental"
  set  ARGS=%ARGS% -err_detect "ignore_err"

  set  ARGS=%ARGS% -flags  "+cgop+loop-unaligned-output_corrupt"
  set  ARGS=%ARGS% -fflags "+autobsf+genpts+nofillin+discardcorrupt-fastseek-igndts-ignidx"
  set  ARGS=%ARGS% -flags2 "+ignorecrop"

  ::set  ARGS=%ARGS% -threads 1
  ::set  ARGS=%ARGS% -hwaccel d3d11va
  ::set  ARGS=%ARGS% -hwaccel cuda
  ::set  ARGS=%ARGS% -hwaccel_output_format cuda

  set  ARGS=%ARGS% -i "%TEMP%"
  set  ARGS=%ARGS% -movflags "+faststart"

::set  ARGS=%ARGS% -use_wallclock_as_timestamps 1
::set  ARGS=%ARGS% -force_duplicated_matrix  "1"
  set  ARGS=%ARGS% -avoid_negative_ts "make_zero"
  set  ARGS=%ARGS% -segment_time_metadata 1
  set  ARGS=%ARGS% -enc_time_base "-1"  
  set  ARGS=%ARGS% -safe 0

  set  ARGS=%ARGS% -vf
  set  ARGS=%ARGS% "fifo
  set  ARGS=%ARGS%,setpts=PTS-STARTPTS
  set  ARGS=%ARGS%,select=concatdec_select
  ::=================================================================== deinterlace
  set  ARGS=%ARGS%,yadif=0:-1:0
  set  ARGS=%ARGS%,pullup
  set  ARGS=%ARGS%,dejudder=cycle=20
  set  ARGS=%ARGS%,mpdecimate=hi=128*12:lo=128*5:frac=0.10
  set  ARGS=%ARGS%,mpdecimate=hi=8*12:lo=8*5:frac=0.10
::---------------------------------------if input was 29.97fps use this
::set  ARGS=%ARGS%,fps=24000/1001
::---------------------------------------if input was 30fps use this
::set  ARGS=%ARGS%,fps=24
::---------------------------------------just set it to 25fps.
  set  ARGS=%ARGS%,fps=25
  ::===================================================================================

  set  ARGS=%ARGS%,format=pix_fmts=yuv420p
  ::=================================================================================== trim video to make it even
  set  ARGS=%ARGS%,crop=trunc(in_w/2)*2:trunc(in_h/2)*2
::set  ARGS=%ARGS%,scale=-2:720
  ::=================================================================================== slightly improve dark pixels and color
::set  ARGS=%ARGS%,eq=gamma=1.2:saturation=1.1
  ::===================================================================================
::set  ARGS=%ARGS%,hqdn3d=luma_spatial=4
  set  ARGS=%ARGS%,nlmeans=s=2.0:p=7:pc=0:r=15:rc=0
  set  ARGS=%ARGS%"

  set  ARGS=%ARGS% -af
  set  ARGS=%ARGS% "afifo
  set  ARGS=%ARGS%,asetpts=PTS-STARTPTS
  set  ARGS=%ARGS%,aselect=concatdec_select
  set  ARGS=%ARGS%,aresample=async=1:min_hard_comp=0.100000:first_pts=0
  set  ARGS=%ARGS%"

::set  ARGS=%ARGS% -preset "ultrafast"
set  ARGS=%ARGS% -preset "veryslow"

::====================================================================================
::------------------------------------------ H.264                          (https://trac.ffmpeg.org/wiki/Encode/H.264)
set  ARGS=%ARGS% -c:v libx264     -crf 23
::------------------------------------------ H.264 with nVidia hardware     (https://trac.ffmpeg.org/wiki/Encode/H.264)
::set  ARGS=%ARGS% -c:v h264_nvenc   -crf 23 -profile high444p -pixel_format yuv444p -preset default
::------------------------------------------ H.265 HEVC                     (https://trac.ffmpeg.org/wiki/Encode/H.265)
::set  ARGS=%ARGS% -tag:v hvc1
::set  ARGS=%ARGS% -c:v libx265    -crf 28
::------------------------------------------ AOMedia video encoder for ​AV1  (https://trac.ffmpeg.org/wiki/Encode/AV1)
::set  ARGS=%ARGS% -c:v libaom-av1 -crf 30
::set  ARGS=%ARGS% -c:v libaom-av1 -crf 30 -b:v 0
::====================================================================================

set  ARGS=%ARGS% -c:a aac

::----------------------------------- normally half of fps (15 for 30fps). smaller values means more iframe, less compression.
::set  ARGS=%ARGS% -sc_threshold 0
  set  ARGS=%ARGS% -g 10
  set  ARGS=%ARGS% -keyint_min 10
::set  ARGS=%ARGS% -b_strategy 0
  set  ARGS=%ARGS% -bf 4
  ::-----------------------------cabac
  set  ARGS=%ARGS% -coder 1
  
:::::::::::::::set  ARGS=%ARGS% -to "00:00:10.000"
  set  ARGS=%ARGS% "%OUTPUT%"
  ::set  ARGS=%ARGS% -hwaccel d3d11va

  call "%FFMPEG%" -hwaccel d3d11va %ARGS%
  set "EXIT_CODE=%ErrorLevel%"
  if ["%EXIT_CODE%"] EQU ["0"] ( 
    echo [INFO] success encoding with Windows-DirectX middle-man, possibly with GPU support.
    goto END
  ) 
  
  echo [ERROR] trying again without Windows-DirectX middle-man.
  call "%FFMPEG%" %ARGS%
  set "EXIT_CODE=%ErrorLevel%"
  if ["%EXIT_CODE%"] NEQ ["0"] ( 
    echo [ERROR] could not encode.
    goto END
  ) 
  
  echo [INFO] succesfull encoding without Windows-DirectX middle-man.
  got END

:END
  pause
  ::del /f /q "%TEMP%" 1>nul 2>nul
  echo [INFO] EXIT_CODE=%EXIT_CODE%"
  popd
  exit /b %EXIT_CODE%
