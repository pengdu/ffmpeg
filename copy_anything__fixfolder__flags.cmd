@echo off
  chcp 65001          2>nul >nul
  mkdir "%~sdp1fixed" 2>nul >nul

:LOOP
  if ["%~1"]==[""]  ( echo Done.           &  goto END   )
  if not exist %~s1 ( echo Not exist.      &  goto NEXT  )
  if exist %~s1\NUL ( echo Is a directory. &  goto NEXT  )
::---------------------------------------------------------------------------------------------

  title %~sdp1%~nx1

  set "FILE_INPUT=%~s1"
  set "FILE_OUTPUT=%~sdp1fixed\%~nx1"

  set "PROBED_VCODEC="
  set "PROBED_ACODEC="
  for /f "tokens=*" %%a in ('call ffprobe.exe -hide_banner -loglevel error -strict experimental -i %FILE_INPUT% -select_streams "v:0" -show_entries "stream=codec_name" -print_format "default=noprint_wrappers=1:nokey=1"') do (set PROBED_VCODEC=%%a)
  for /f "tokens=*" %%a in ('call ffprobe.exe -hide_banner -loglevel error -strict experimental -i %FILE_INPUT% -select_streams "a:0" -show_entries "stream=codec_name" -print_format "default=noprint_wrappers=1:nokey=1"') do (set PROBED_ACODEC=%%a)


  set "ARGS="

::MUX flags
  set ARGS=%ARGS% -flags                    "+low_delay+global_header+loop-unaligned-ilme-cgop-output_corrupt"
  set ARGS=%ARGS% -flags2                   "+fast+ignorecrop+showall+export_mvs"
  set ARGS=%ARGS% -fflags                   "+autobsf+genpts+discardcorrupt-fastseek-nofillin-ignidx-igndts"

  set ARGS=%ARGS% -thread_queue_size        "500"

::~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  set ARGS=%ARGS% -i                        "%FILE_INPUT%"
::~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::ENC flags
  set ARGS=%ARGS% -mpv_flags                "+strict_gop+naq"
  set ARGS=%ARGS% -movflags                 "-faststart+disable_chpl"
  set ARGS=%ARGS% -reorder_queue_size       "120"
  set ARGS=%ARGS% -queue_size               "120"
  set ARGS=%ARGS% -max_muxing_queue_size    "600"


::only codec_type=mpeg4 supports this
  if /i ["%PROBED_VCODEC%"] EQU ["mpeg4"] (
    set ARGS=%ARGS% -bsf:v                  "mpeg4_unpack_bframes,remove_extra=freq=all"
  )
  if /i ["%PROBED_VCODEC%"] EQU ["h264"]  (
    set ARGS=%ARGS% -bsf:v                  "h264_redundant_pps,remove_extra=freq=all"
  )
  
  if /i ["%PROBED_VCODEC%"] NEQ ["mpeg4"]  (
    if /i ["%PROBED_VCODEC%"] NEQ ["h264"]  (
      set ARGS=%ARGS% -bsf:v                "remove_extra=freq=all"
    )
  )

  if /i ["%PROBED_ACODEC%"] EQU ["mp3"] (
    set ARGS=%ARGS% -bsf:a                  "mp3decomp"
  ) 


  set ARGS=%ARGS% -codec                    "copy"
  set ARGS=%ARGS% -dcodec                   "copy"

  set ARGS=%ARGS% -start_at_zero
  set ARGS=%ARGS% -avoid_negative_ts        "make_zero"
  set ARGS=%ARGS% -segment_time_metadata    "1"
  set ARGS=%ARGS% -force_duplicated_matrix  "1"

::set ARGS=%ARGS% -zerolatency              "1"
::set ARGS=%ARGS% -tune                     "zerolatency"

  set ARGS=%ARGS% -map_chapters             "-1"
  set ARGS=%ARGS% -map_metadata             "-1"

  echo.
  echo.
  @echo on
  call ffmpeg.exe -y -hide_banner -loglevel "info" -strict "experimental" -threads "16" %ARGS% "%FILE_OUTPUT%"
  @echo off
  echo.
  echo.

::---------------------------------------------------------------------------------------------
:NEXT
  shift
  goto LOOP

:END
  pause
