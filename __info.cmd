@echo off
set FILE_INPUT="%~1"
set FILE_OUTPUT="%~d1%~p1%~n1_fixed.mp4"

:: BITRATE
for /f "tokens=*" %%a in ('ffprobe -i %FILE_INPUT% -v "error" -select_streams "v:0" -show_entries "stream=bit_rate"       -print_format "default=noprint_wrappers=1:nokey=1"') do (
  set /a BITRATE=%%a
);
:: BUFSIZE
set /a BUFSIZE=%FRAMERATE%/2
:: FRAMERATE
for /f "tokens=*" %%a in ('ffprobe -i %FILE_INPUT% -v "error" -select_streams "v:0" -show_entries "stream=avg_frame_rate" -print_format "default=noprint_wrappers=1:nokey=1"') do (
  set /a FRAMERATE=%%a
);
:: GROUP OF PICTURE (GOP)
set /a GROUP_OF_PICTURE=2*%FRAMERATE%
:: KEYINT's minimum interval between IDR-frames (so one I-frame every two seconds)
set /a KEYINT=2*%FRAMERATE%

::================================================== reformat (ffmpeg uses KB instead of bits).
set /a BITRATE=%BITRATE%/1000
set /a BUFSIZE=%BUFSIZE%/1000
::==============================================================================================================================================


call .\ffmpeg.exe -threads 8 -y -hide_banner                                                  ^
                  -i %FILE_INPUT%                                                             ^
                  -pix_fmt "yuv420p"                                                          ^
                  -tune "zerolatency"                                                         ^
                  -keyint_min %KEYINT%                                                        ^
                  -g %GROUP_OF_PICTURE%                                                       ^
                  -crf 21 -preset "veryslow"                                                  ^
                  -profile:v "baseline" -level "3.0"                                          ^
                  -vf "mpdecimate,setpts=N/FRAME_RATE/TB"                                     ^
                  -b:v %BITRATE%k -maxrate %BITRATE%k -bufsize %BUFSIZE%                      ^
                  -x264opts "keyint=%KEYINT%:min-keyint=%KEYINT%:no-scenecut"                 ^
                  -force_fps  -r %FRAMERATE% -framerate %FRAMERATE% -subfps "%FRAMERATE%/1"   ^
                  -movflags "+faststart+global_sidx"                                          ^
                  %FILE_OUTPUT%

pause


:: -vsync 2 -async 1 -bt 50M
::"no-scenecut" - do not generate a key frame when there is a scene cut in the video. keep key frames rate consistant.