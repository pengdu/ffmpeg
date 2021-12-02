::@echo off

set "FILE_IN=%~sdp1%~nx1"
set "FILE_OUT=%~sdp1%~n1_streched%~x1"

set "ARGS="
set  ARGS=%ARGS% -hide_banner -y -flags "-output_corrupt-unaligned" -flags2 "+ignorecrop" -fflags "+discardcorrupt"
set  ARGS=%ARGS% -i "%FILE_IN%"
set  ARGS=%ARGS% -ss "00:00:10.000"
set  ARGS=%ARGS% -tag:v hvc1 -c:v libx265 -c:a copy -crf 26 -preset ultrafast -tune "animation"

set "VFILTERS="
set  VFILTERS=%VFILTERS% fifo,
set  VFILTERS=%VFILTERS% setpts=PTS-STARTPTS,
set  VFILTERS=%VFILTERS% yadif=0:-1:0,
set  VFILTERS=%VFILTERS% dejudder=cycle=20,
set  VFILTERS=%VFILTERS% mpdecimate=hi=128*12:lo=128*5:frac=0.10,
set  VFILTERS=%VFILTERS% mpdecimate=hi=8*12:lo=8*5:frac=0.10,
set  VFILTERS=%VFILTERS% format=yuv420p,
set  VFILTERS=%VFILTERS% crop=(in_w-80):(in_h-50):keep_aspect=0
::set  VFILTERS=%VFILTERS% scale=1920:1080:force_original_aspect_ratio=disable,
::set  VFILTERS=%VFILTERS% smartblur=lr=2.00:ls=-0.90:lt=-5.0:cr=0.5:cs=1.0:ct=1.5

::        disable   Scale the video as specified and disable this feature.
::        decrease  The output video dimensions will automatically be decreased if needed.
::        increase  The output video dimensions will automatically be increased if needed.

set  ARGS=%ARGS% -vf "%VFILTERS%"

call ffmpeg.exe %ARGS% "%FILE_OUT%"





::set  VFILTERS=%VFILTERS% setdar=16/9
::most split to two command, otherwised you'll get 'data is not aligned'.

::call ffmpeg.exe -hide_banner -y -flags "-output_corrupt-unaligned" -flags2 "+ignorecrop" -fflags "+discardcorrupt" -i "060---Long-Haired-Hare_tmp.mkv" -c:v libx265 -c:a copy -crf 26 -preset ultrafast -tune "animation" -vf "fifo,setpts=PTS-STARTPTS,format=yuv420p,scale=1920:1080,nlmeans=s=20.0" "060---Long-Haired-Hare.mkv"



::nlmeans=s=20.0                                                אפקטיבי  https://ffmpeg.org/ffmpeg-filters.html#nlmeans
::bm3d=sigma=200                                                איטי יותר ואיכות סבירה
::fftdnoiz=sigma=30                                             איכות פחות טובה איטי בערך שני פריימים לשנייה
::owdenoise=depth=8:luma_strength=10.0:chroma_strength=10.0   מאוד איטי ומוריד פוקוס
::hqdn3d
::vaguedenoiser=threshold=16                                    מהיר אבל לא עושה כלום
::atadenoise
::removegrain,removegrain,removegrain,removegrain                 מהיר אבל לא עושה הרבה אם בכלל
::dctdnoiz=sigma=1                                              איטי והופך הכול לסגול
::nlmeans_opencl=s=20.0                                         פילטר לא קיים
::del /f /q "060---Long-Haired-Hare_tmp.mkv"

pause

::https://x265.readthedocs.io/en/default/presets.html