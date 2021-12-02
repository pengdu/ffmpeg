@echo off
::---------------------------------------------------------
:: Scale the video to 1920x1080 (1080p), and do a quick   -
:: noise-reduction afterwards.                            -
:: This batch-file works best for videos with quality     -
:: that is "almost near HD" such as 960x540.              -
::                                                        -
:: For smaller resolutions, scale will result with a      -
:: "too blurry result", you might want to use after       -
:: something like 'Topaz Video Enhance AI' or your own    -
:: custom AI solution (developers).                       -
::---------------------------------------------------------
:: Video-Filters:                                         -
::  fifo   - increase buffer, ease up the CPU.            -
::  pad    - 16/9 ratio, centering, keeping prespective.  -
::  scale  - dumb resize.                                 -
::  hqdn3d - noise-reduction that keeps the details.      -
::---------------------------------------------------------
::---------------------------------------------------------
:: filters (MUX):                                         -
:: output_corrupt, err_detect:                            -
:: https://ffmpeg.org/ffmpeg-all.html#toc-Codec-Options   -
:: discardcorrupt, err_detect:                            -
:: https://ffmpeg.org/ffmpeg-all.html#toc-Format-Options  -
::---------------------------------------------------------
:: filters (encoding):                                    -
:: http://ffmpeg.org/ffmpeg-filters.html#fifo_002c-afifo  -
:: http://ffmpeg.org/ffmpeg-filters.html#pad-1            -
:: http://ffmpeg.org/ffmpeg-filters.html#hqdn3d-1         -
:: http://ffmpeg.org/ffmpeg-filters.html#scale-1          -
:: https://trac.ffmpeg.org/wiki/Encode/H.265              -
::---------------------------------------------------------
:: I don't use GPU-encoding, but might try it...          -
:: See: https://trac.ffmpeg.org/wiki/HWAccelIntro         -
::---------------------------------------------------------
:: quality: CRF 28 (h.265) === CRF 23 (h.264), 1/2 size.  -
::---------------------------------------------------------

set "EXIT_CODE=0"
chcp 65001 2>nul >nul

title [PROCESSING..] %~nx1

pushd "%~dp1"

set "INPUT=%~f1"
set "OUTPUT=%~dpn1_hd.mkv"

::call ffmpeg -hide_banner -y -i "%INPUT%" -crf 25 -preset ultrafast -c:a copy -vf "fifo,pad=width=ih*16/9:height=ih:x=(ow-iw)/2:y=(oh-ih)/2:color=#00000000,scale=-2:1080,hqdn3d" "%OUTPUT%" 
::call ffmpeg -hide_banner -y -i "%INPUT%" -c:v libx265 -crf 26 -preset ultrafast -c:a copy -vf "fifo,pad=width=ih*16/9:height=ih:x=(ow-iw)/2:y=(oh-ih)/2:color=#00000000,scale=-2:1080,hqdn3d" "%OUTPUT%" 
::-strict "experimental" 
::-threads 16 
::-err_detect ignore_err    -----error DETECTION FLAG.
::-movflags "+faststart"    -----only needed for '.MP4' output-files.

call ffmpeg -hide_banner -y -flags "-output_corrupt" -fflags "+discardcorrupt" -flags2 "+ignorecrop" -i "%INPUT%" -tag:v hvc1 -c:v libx265 -c:a copy -crf 26 -preset ultrafast -vf "fifo,setpts=PTS-STARTPTS,format=yuv420p,crop=trunc(in_w/2)*2:trunc(in_h/2)*2,setdar=16/9,scale=1920:1080,nlmeans=s=20.0" "%OUTPUT%"

set "EXIT_CODE=%ErrorLevel%"

title [DONE] %~nx1

pause

popd 

exit /b %EXIT_CODE%
