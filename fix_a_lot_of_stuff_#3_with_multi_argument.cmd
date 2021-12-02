@echo off

:LOOP
::-------------------------- has argument ?
if ["%~1"]==[""] (
  echo done.
  goto END;
)
      ::-------------------------- argument exist ?
if not exist %~s1 (
  echo not exist
  goto NEXT;
)

echo exist
if exist %~s1\NUL (
  echo is a directory
  goto NEXT;
)

echo is a file
set FILE_INPUT="%~s1"
set FILE_OUTPUT="%~d1%~p1%~n1_fixed.mp4"
::--------------------------------------------------------------------------------
call ffmpeg.exe -y -hide_banner -fflags "+genpts"                               ^
-pix_fmt "yuv420p"                                                              ^
-i %FILE_INPUT%                                                                 ^
-ss "00:00:00.001"                                                              ^
-rc-lookahead "30" -cbr "true" -forced-idr "true" -g 5                          ^
-filter:v "yadif=0:-1:0,format=yuv420p,mpdecimate,setpts=N/FRAME_RATE/TB"       ^
-preset "veryslow" -crf "21"                                                    ^
-profile:v "baseline" -level "3.0" -tune "zerolatency" -movflags "+faststart"   ^
%FILE_OUTPUT%
::--------------------------------------------------------------------------------
if %errorlevel%==0 (
  goto NEXT;
)
::-------------------------------------------------------------------------------- error ("Option pixel_format not found." ??) , try again with no pix_fmt.
echo trying again without [-pix_fmt "yuv420p"]
call ffmpeg.exe -y -hide_banner -fflags "+genpts"                               ^
-i %FILE_INPUT%                                                                 ^
-ss "00:00:00.001"                                                              ^
-rc-lookahead "30" -cbr "true" -forced-idr "true" -g 5                          ^
-filter:v "yadif=0:-1:0,format=yuv420p,mpdecimate,setpts=N/FRAME_RATE/TB"       ^
-preset "veryslow" -crf "21"                                                    ^
-profile:v "baseline" -level "3.0" -tune "zerolatency" -movflags "+faststart"   ^
-refs "5" -x264opts "scenecut=-1" -flags2 "+bpyramid" -flags "+loop+mv0+naq+low_delay" ^
-deblockalpha "0" -deblockbeta "0" ^
%FILE_OUTPUT%
::--------------------------------------------------------------------------------

:NEXT
shift
goto LOOP


:END

pause
