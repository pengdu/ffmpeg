@echo off

:LOOP
  if ["%~1"] EQU [""] ( goto END )

  pushd "%~dp1"
  mkdir "%~dp1\fixed" 1>nul 2>nul

  set "ARGS="
  set  ARGS=%ARGS% -hide_banner -nostdin -err_detect "ignore_err" -y
  set  ARGS=%ARGS% -flags  "+cgop+loop-unaligned-output_corrupt"
  set  ARGS=%ARGS% -fflags "+autobsf+genpts"
  set  ARGS=%ARGS% -i "%~1"
  set  ARGS=%ARGS% -avoid_negative_ts "make_zero"
  set  ARGS=%ARGS% -segment_time_metadata 1
  set  ARGS=%ARGS% -enc_time_base "-1"
  set  ARGS=%ARGS% -use_wallclock_as_timestamps "1"
  set  ARGS=%ARGS% -safe 0
  set  ARGS=%ARGS% -copyinkf
  set  ARGS=%ARGS% -bsf:v "mpeg4_unpack_bframes,remove_extra=freq=all"
  set  ARGS=%ARGS% -codec copy
  set  ARGS=%ARGS% -probesize "10000000"
  set  ARGS=%ARGS% -analyzeduration "2000000"
  set  ARGS=%ARGS% "%~dp1\fixed\%~n1_tmp.mkv"

  title [unpack %~nx1]
  call ffmpeg %ARGS%

  echo.
  echo.
  echo.
  echo.

  set "ARGS="
  set  ARGS=%ARGS% -hide_banner -nostdin -err_detect "ignore_err" -y
  set  ARGS=%ARGS% -flags  "+cgop+loop-unaligned-output_corrupt"
  set  ARGS=%ARGS% -fflags "+autobsf+genpts+nofillin+discardcorrupt-fastseek-igndts-ignidx"
  set  ARGS=%ARGS% -i "%~dp1\fixed\%~n1_tmp.mkv"
  set  ARGS=%ARGS% -avoid_negative_ts "make_zero"
  set  ARGS=%ARGS% -segment_time_metadata 1
  set  ARGS=%ARGS% -enc_time_base "-1"
  set  ARGS=%ARGS% -use_wallclock_as_timestamps "1"
  set  ARGS=%ARGS% -safe 0
  set  ARGS=%ARGS% -copyinkf

  ::----------------------------------h.264
  set  ARGS=%ARGS% -c:v libx264
  ::----------------------------------h.265
  ::set  ARGS=%ARGS% -tag:v hvc1
  ::set  ARGS=%ARGS% -c:v libx265
  ::----------------------------------av1(libaom-av1|libsvtav1|librav1e)
  ::set  ARGS=%ARGS% -cpu-used 4 -row-mt 1 -tiles "2x2"
  ::set  ARGS=%ARGS% -c:v libaom-av1
  ::set  ARGS=%ARGS% -c:v libsvtav1
  ::set  ARGS=%ARGS% -c:v librav1e

  set  ARGS=%ARGS% -b:v 0
  set  ARGS=%ARGS% -crf 28
  set  ARGS=%ARGS% -preset veryslow
  ::set  ARGS=%ARGS% -profile:v baseline -level:v "3.0"
  set  ARGS=%ARGS% -vf "fifo,setpts=PTS-STARTPTS,format=pix_fmts=yuv420p"
  set  ARGS=%ARGS% -g 100
  set  ARGS=%ARGS% -bf 4
  set  ARGS=%ARGS% -coder 1
  set  ARGS=%ARGS% -c:a aac
  set  ARGS=%ARGS% -b:a 96k
  set  ARGS=%ARGS% -shortest
  set  ARGS=%ARGS% -movflags "+faststart"
  ::set  ARGS=%ARGS% -to "00:00:05.000"
  set  ARGS=%ARGS% -probesize "10000000"
  set  ARGS=%ARGS% -analyzeduration "2000000"
  set  ARGS=%ARGS% "%~dp1\fixed\%~n1.mkv"


  title [encode mp4 %~n1]
  start "ffmpeg" /wait /low /b ffmpeg %ARGS%
  set "EXIT_CODE=%ErrorLevel%

  if ["%EXIT_CODE%"] NEQ ["0"] ( goto END )

  del /f /q "%~dp1\fixed\%~n1_tmp.mkv" 1>nul 2>nul
  popd
  set "ARGS="
  goto NEXT


:NEXT
  shift
  goto LOOP


:END
  ::pause
  echo EXIT_CODE: %EXIT_CODE%
  exit /b %EXIT_CODE%
