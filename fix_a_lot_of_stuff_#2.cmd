@echo off
set FILE_INPUT="%~1"
set FILE_OUTPUT="%~d1%~p1%~n1_fixed.mp4"

for /f "tokens=*" %%a in ('ffprobe -i %FILE_INPUT% -v "error" -select_streams "v:0" -show_entries "stream=avg_frame_rate" -print_format "default=noprint_wrappers=1:nokey=1"') do (
  set /a FRAMERATE=%%a
);
set /a GROUP_OF_PICTURE=2*%FRAMERATE%
set /a KEYINT=2*%FRAMERATE%
for /f "tokens=*" %%a in ('ffprobe -i %FILE_INPUT% -v "error" -select_streams "v:0" -show_entries "stream=bit_rate"       -print_format "default=noprint_wrappers=1:nokey=1"') do (
  set /a BITRATE=%%a
);
set /a BUFSIZE=%BITRATE%/3

::================================================== [optional] reformat (to use KB instead of bits, will loose-precision).
set /a BITRATE=%BITRATE%/1000
set /a BUFSIZE=%BUFSIZE%/1000

set BITRATE=%BITRATE%k
set BUFSIZE=%BUFSIZE%k
::==============================================================================================

::================================================== [optional] OVERRIDE GOP: simulate INFRA mode (num of frames per key-frames).
::GOP is number of frames between keyframes.  Smaller number === more keyframes === streaming will recover faster on packets drop. will increase file size, and lower the overall ability to compress data, thus (much) bigger file-size (could be x3 times)
set /a GROUP_OF_PICTURE=1
::==============================================================================================

::================================================== [optional] preset (slow=smaller file).
::ultrafast|veryslow 
set PRESET=ultrafast
::==============================================================================================

::================================================== [optional] stuff you can add at the end
:: limit the output to 5 seconds total (good for reviewing the overall quality)
set ADDITIONAL=-t "5"
::==============================================================================================

::================================================== [optional] on-screen information.
echo FRAMERATE        =%FRAMERATE%
echo GROUP_OF_PICTURE =%GROUP_OF_PICTURE%
echo KEYINT           =%KEYINT%
echo BITRATE          =%BITRATE%
echo BUFSIZE          =%BUFSIZE%
pause
::==============================================================================================

ffmpeg.exe -y -hide_banner -r "%FRAMERATE%" -ss "00:00:00.000" -i %FILE_INPUT% -pass 1 -f "mp4"   -ss "00:00:00.001" -c:v libx264 -r "%FRAMERATE%" -g "%GROUP_OF_PICTURE%" -keyint_min %KEYINT% -x264opts "keyint=%KEYINT%:min-keyint=%KEYINT%:no-scenecut" -fflags "+genpts" -async "1" -vsync "2" -preset "%PRESET%" -crf "21" -profile:v "baseline" -level "3.0" -tune "zerolatency" -pix_fmt "yuv420p" -movflags "+faststart" -bt "5M" -b:v "%BITRATE%" -maxrate "%BITRATE%" -bufsize "%BUFSIZE%"  %ADDITIONAL%   -filter_complex "[0:v]setpts=PTS-STARTPTS[TAG]; [TAG]yadif=0:-1:0[TAG]; [TAG]setpts=PTS-STARTPTS[TAG]; [TAG]mpdecimate,setpts=N/FRAME_RATE/TB[TAG]; [TAG]setpts=PTS-STARTPTS[TAG]" -map "[TAG]"             NUL  && ^
ffmpeg.exe    -hide_banner -r "%FRAMERATE%" -ss "00:00:00.000" -i %FILE_INPUT% -pass 2 -f "mp4"   -ss "00:00:00.001" -c:v libx264 -r "%FRAMERATE%" -g "%GROUP_OF_PICTURE%" -keyint_min %KEYINT% -x264opts "keyint=%KEYINT%:min-keyint=%KEYINT%:no-scenecut" -fflags "+genpts" -async "1" -vsync "2" -preset "%PRESET%" -crf "21" -profile:v "baseline" -level "3.0" -tune "zerolatency" -pix_fmt "yuv420p" -movflags "+faststart" -bt "5M" -b:v "%BITRATE%" -maxrate "%BITRATE%" -bufsize "%BUFSIZE%"  %ADDITIONAL%   -filter_complex "[0:v]setpts=PTS-STARTPTS[TAG]; [TAG]yadif=0:-1:0[TAG]; [TAG]setpts=PTS-STARTPTS[TAG]; [TAG]mpdecimate,setpts=N/FRAME_RATE/TB[TAG]; [TAG]setpts=PTS-STARTPTS[TAG]" -map "[TAG]"   %FILE_OUTPUT%


pause

::================================================== [optional] cleanup
del /f /q ffmpeg2pass-*.log >nul
::==============================================================================================
exit

::                  -bt 10M   -b:v %BITRATE%k -maxrate %BITRATE%k -minrate %BITRATE%k -bufsize %BUFSIZE%k 
::"no-scenecut" - do not generate a key frame when there is a scene cut in the video. keep key frames rate consistant.
::The "-flags +genpts -async 1" is necessary to ensure that the concatenated audio segments will switch over at the same time as the video segment.

