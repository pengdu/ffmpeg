@echo off
  chcp 65001          2>nul >nul
  mkdir "%~sdp1fixed" 2>nul >nul

:LOOP
  if ["%~1"]==[""]  ( echo Done.           &  goto END   )
  if not exist %~s1 ( echo Not exist.      &  goto NEXT  )
  if exist %~s1\NUL ( echo Is a directory. &  goto NEXT  )
::---------------------------------------------------------------------------------------------
  set "FILE_INPUT=%~s1"
  set "FILE_OUTPUT=%~sdp1fixed\%~nx1"

  set "ARGS="

::MUX flags
  set ARGS=%ARGS% -flags                    "+low_delay+global_header-unaligned-ilme-cgop-loop-output_corrupt"
  set ARGS=%ARGS% -flags2                   "+fast+ignorecrop+showall+export_mvs"
  set ARGS=%ARGS% -fflags                   "+autobsf+genpts+discardcorrupt-fastseek-nofillin-ignidx-igndts"

  set ARGS=%ARGS% -thread_queue_size        "500"

::~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  set ARGS=%ARGS% -i                        "%FILE_INPUT%"
::~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::ENC flags
  set ARGS=%ARGS% -mpv_flags                "+strict_gop+naq"
  set ARGS=%ARGS% -movflags                 "+faststart+disable_chpl"
  set ARGS=%ARGS% -reorder_queue_size       "120"
  set ARGS=%ARGS% -queue_size               "120"
  set ARGS=%ARGS% -max_muxing_queue_size    "600"


::only codec_type=mpeg4 supports this
  if /i ["%~x1"] EQU [".avi"] ( 
    set ARGS=%ARGS% -bsf:v                  "mpeg4_unpack_bframes,remove_extra=freq=all"
  ) else ( 
    set ARGS=%ARGS% -bsf:v                  "remove_extra=freq=all"
  ) 


  set ARGS=%ARGS% -codec                    "copy"
  set ARGS=%ARGS% -dcodec                   "copy"

  set ARGS=%ARGS% -start_at_zero
  set ARGS=%ARGS% -avoid_negative_ts        "make_zero"
  set ARGS=%ARGS% -segment_time_metadata    "1"
  set ARGS=%ARGS% -force_duplicated_matrix  "1"

  set ARGS=%ARGS% -zerolatency              "1"
  set ARGS=%ARGS% -tune                     "zerolatency"

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
