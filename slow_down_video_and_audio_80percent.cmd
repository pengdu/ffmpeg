@echo off
set FILE_INPUT="%~s1"
set FILE_OUTPUT="%~d1%~p1%~n1_fixed.mp4"

::Speed-up 200% (x2 slow)
::VIDEO = 100/200  == 0.5
::AUDIO = 200/100  == 2.0

::Slow-down 80%
::VIDEO = 100/80   == 1.25
::AUDIO = 80/100   == 0.8

::Slow-down 50% (x2 slow)
::VIDEO = 100/50   == 2
::AUDIO = 50/100   == 0.5

set SPEED_VIDEO=1.25
set SPEED_AUDIO=0.8

::------------------------------------------------------------------------------------------------------------
call ffmpeg.exe -y -hide_banner -fflags "+genpts"  -async 1                                               ^
-pix_fmt "yuv420p"                                                                                        ^
-i %FILE_INPUT%                                                                                           ^
-filter_complex "[0:v]setpts=%SPEED_VIDEO%*PTS[v];[0:a]atempo=%SPEED_AUDIO%[a]" -map "[v]" -map "[a]"     ^
-preset "veryslow" -crf "21"                                                                              ^
-profile:v "baseline" -level "3.0" -tune "zerolatency" -movflags "+faststart"                             ^
%FILE_OUTPUT%
::------------------------------------------------------------------------------------------------------------
if %errorlevel%==0 goto DONE_SUCCESS;
::------------------------------------------------------------------------------------------------------------ error ("Option pixel_format not found." ??) , try again with no pix_fmt.
call ffmpeg.exe -y -hide_banner -fflags "+genpts"  -async 1                                               ^
-i %FILE_INPUT%                                                                                           ^
-filter_complex "[0:v]setpts=%SPEED_VIDEO%*PTS[v];[0:a]atempo=%SPEED_AUDIO%[a]" -map "[v]" -map "[a]"     ^
-preset "veryslow" -crf "21"                                                                              ^
-profile:v "baseline" -level "3.0" -tune "zerolatency" -movflags "+faststart"                             ^
%FILE_OUTPUT%
::------------------------------------------------------------------------------------------------------------


::------------------------------------------------------------------------------------------------------------
:DONE_SUCCESS

pause