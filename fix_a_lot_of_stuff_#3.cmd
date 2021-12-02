@echo off
set FILE_INPUT="%~s1"
set FILE_OUTPUT="%~d1%~p1%~n1_fixed.mp4"

::-------------------------------------------------------------------------------- error ("Option pixel_format not found." ??) , try again with no pix_fmt.
call ffmpeg.exe -y -hide_banner -fflags "+genpts"                               ^
-i %FILE_INPUT% -threads 16                                                     ^
-ss "00:00:00.001"                                                              ^
-filter:v "yadif=0:-1:0,format=yuv420p,mpdecimate,setpts=N/FRAME_RATE/TB"       ^
-preset "veryslow" -crf "21"                                                    ^
-profile:v "high" -level "5.0" -tune "zerolatency" -movflags "+faststart"   ^
-rc-lookahead "30" -cbr "true" -forced-idr "true" -g 5                          ^
%FILE_OUTPUT%
::--------------------------------------------------------------------------------

::--------------------------------------------------------------------------------
:DONE_SUCCESS

pause