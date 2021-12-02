::https://en.wikipedia.org/wiki/16:9_aspect_ratio
::https://ffmpeg.org/ffmpeg-all.html#pad-1
::https://ffmpeg.org/ffmpeg-all.html#scale-1

::padding based on width, will reduce width!
::with respect to anamorphic videos, normal video will have sar 1 so it is fine.

set "FFMPEG=%~sdp0ffmpeg.exe"

pushd "%~dp1"

set "EXIT_CODE=0"

set "ARGS="
set  ARGS=%ARGS% -hide_banner
set  ARGS=%ARGS% -y
set  ARGS=%ARGS% -loglevel verbose -stats
set  ARGS=%ARGS% -strict "experimental"

::------------------------------------- one of those might be supported in your GPU.
::set  ARGS=%ARGS% -hwaccel dxva2
::set  ARGS=%ARGS% -hwaccel vulkan
::set  ARGS=%ARGS% -hwaccel cuda
::set  ARGS=%ARGS% -hwaccel qsv
::set  ARGS=%ARGS% -hwaccel d3d11va
::set  ARGS=%ARGS% -hwaccel opencl

set  ARGS=%ARGS% -i "%~1"

set  ARGS=%ARGS% -vf
set  ARGS=%ARGS% "fifo

::------------------------------------- when used before pad or scale it improves performances.
::set  ARGS=%ARGS%,crop=trunc(in_w/2)*2:trunc(in_h/2)*2


::------------------------------------- this is scaling of width (can reduce size of width!), with same height (result is centered)
::set  ARGS=%ARGS%,pad=width=in_h*16/9/sar:height=in_h:x=(out_w-in_w)/2:y=(out_h-in_h)/2:color=#00000000

::------------------------------------- this is scaling of height (can reduce size of height!), with same width (result is centered)
::set  ARGS=%ARGS%,pad=width=in_w:height=in_w*16/9/sar:x=(out_w-in_w)/2:y=(out_h-in_h)/2:color=#00000000


::------------------------------------- just pad to exact size. can reduce size of height and width! (result is centered)
::-------------------------------------    the best results are when using nearest value of https://en.wikipedia.org/wiki/16:9_aspect_ratio  of your existing video
::-------------------------------------    original video was width:320 height:240 pixels.
set  ARGS=%ARGS%,pad=width=426:height=240:x=(out_w-in_w)/2:y=(out_h-in_h)/2:color=#00000000


::=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
::instead of padding, scale might be better.
::=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

::set  ARGS=%ARGS%,scale=width=426:height=240:eval=init:interl=0:force_original_aspect_ratio=disable:force_divisible_by=2

::------------------------------------- this is scale filters for specific GPU. some has different syntax from 'scale' so see ffmpeg filters page if needed.
::set  ARGS=%ARGS%,scale_cuda=w=426:h=240:passthrough=1:force_original_aspect_ratio=disable:force_divisible_by=2
::set  ARGS=%ARGS%,scale_npp=width=426:height=240:eval=init:interl=0:force_original_aspect_ratio=disable:force_divisible_by=2

set  ARGS=%ARGS%"

set  ARGS=%ARGS% "%~dpn1__padded_to_16_9%~x1"
::set  ARGS=%ARGS% "%~dpn1__scaled_to_16_9%~x1"

call "%FFMPEG%" %ARGS%
set "EXIT_CODE=%ErrorLevel%"

pause
popd
exit /b %EXIT_CODE%
