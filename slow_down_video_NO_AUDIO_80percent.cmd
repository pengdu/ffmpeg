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

set SPEED_VIDEO=2.0

call ffmpeg.exe -y -hide_banner -i %FILE_INPUT% -preset "veryslow" -crf "21" -filter:v "setpts=%SPEED_VIDEO%*PTS" -an %FILE_OUTPUT%

pause