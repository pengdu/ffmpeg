@echo off

::-----------------------------------
:: a drag&drop *2WebM
::-----------------------------------

set FILE_INPUT="%~s1"
set FILE_OUTPUT="%~d1%~p1%~n1_fixed.webm"

::placeholder
set COMMAND=

::ffmpeg program flags
set COMMAND=%COMMAND% -hide_banner -loglevel "info" -stats -strict "experimental" -y

::input
set COMMAND=%COMMAND% -i %FILE_INPUT%

::flags (generic)
set COMMAND=%COMMAND% -flags              "+naq+low_delay+global_header-unaligned-ilme-cgop-loop-output_corrupt"
set COMMAND=%COMMAND% -flags2             "+fast+ignorecrop+showall+export_mvs"
set COMMAND=%COMMAND% -fflags             "+ignidx+genpts+nofillin+discardcorrupt-fastseek"
set COMMAND=%COMMAND% -movflags           "+faststart+disable_chpl"
set COMMAND=%COMMAND% -avoid_negative_ts  "make_zero"

::cleanup..
set COMMAND=%COMMAND% -map_metadata       "-1"
set COMMAND=%COMMAND% -map_chapters       "-1"


::motion-estimation
set COMMAND=%COMMAND% -subq      "9"
set COMMAND=%COMMAND% -refs      "25"
set COMMAND=%COMMAND% -me_method "full"

::flags (webm specific)
set COMMAND=%COMMAND% -quality            "best"

::multi-threading of VP9
set COMMAND=%COMMAND% -threads            "16"
set COMMAND=%COMMAND% -frame-parallel     "1"
set COMMAND=%COMMAND% -auto-alt-ref       "1"
set COMMAND=%COMMAND% -tile-rows          "2"
set COMMAND=%COMMAND% -tile-columns       "6"
set COMMAND=%COMMAND% -aq-mode            "variance"
set COMMAND=%COMMAND% -lag-in-frames      "25"

::video
set COMMAND=%COMMAND%   -c:v  "libvpx-vp9"
set COMMAND=%COMMAND%   -b:v "500k" -minrate "450k" -maxrate "550k" -crf "23"
set COMMAND=%COMMAND%   -vsync "1"
set COMMAND=%COMMAND%   -filter:v "setpts=PTS-STARTPTS,yadif=0:-1:0,dejudder=cycle=20,mpdecimate,fps=fps=12,setpts=N/FRAME_RATE/TB-STARTPTS,format=pix_fmts=yuv420p"
::set COMMAND=%COMMAND% -filter:v "setpts=PTS-STARTPTS,yadif=0:-1:0,dejudder=cycle=20,mpdecimate,fps=fps=12,setpts=N/FRAME_RATE/TB-STARTPTS,format=pix_fmts=yuv420p,pad=width=ih*16/9:height=ih:x=(ow-iw)/2:y=(oh-ih)/2:color=#00000000,scale=w=640:h=360"


::audio (or '-an' to remove all audio-streams)
set COMMAND=%COMMAND%  -c:a  "libopus"
set COMMAND=%COMMAND%  -b:a  "64k"
set COMMAND=%COMMAND%  -ac "1"
set COMMAND=%COMMAND%  -filter:a "asetpts=PTS-STARTPTS,aresample=async=1:min_hard_comp=0.100000"
set COMMAND=%COMMAND%  -metadata:s:a:0 "language=eng"


::subtitles (remove it)
set COMMAND=%COMMAND%   -sn


::From(-ss)/To(-to) - if you don't have specific need "-ss", keep it at "00:00:00.001", it is a trick to force-rebuild the index.
set COMMAND=%COMMAND%    -ss "00:00:00.001"
::set COMMAND=%COMMAND%  -to "00:00:05.000"

::force the output format (keep it although it is unnneeded for second-pass...)
set COMMAND=%COMMAND%    -f "webm"


::------------------------------------------------------------------------


echo.
echo.
call ffmpeg.exe %COMMAND% -pass "1" -speed "4" nul
if not ErrorLevel == 0( goto NOFIRSTPASS  )

echo.
echo.
call ffmpeg.exe %COMMAND% -pass "2" -speed "-5" nul %FILE_OUTPUT%
if not ErrorLevel == 0( goto NOSECONDPASS )

del /f /q "ffmpeg2pass*.log"  2>nul >nul

goto EXIT


:NOFIRSTPASS
  echo.
  echo first-pass failed.
  goto EXIT


:NOSECONDPASS
  echo.
  echo second-pass failed.
  goto EXIT


:EXIT
  echo.
  echo DONE.
  pause

