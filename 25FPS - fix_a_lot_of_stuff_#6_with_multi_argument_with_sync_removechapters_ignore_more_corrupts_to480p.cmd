@echo off
:LOOP
::has argument ?
if ["%~1"]==[""] (
  echo done.
  goto END;
)
::argument exist ?
if not exist %~s1 (
  echo not exist
  goto NEXT;
)
::file exist ?
echo exist
if exist %~s1\NUL (
  echo is a directory
  goto NEXT;
)
::OK
echo is a file

::--------------------------------------------------------------------------------

set FILE_INPUT="%~s1"
set FILE_OUTPUT="%~d1%~p1%~n1_fixed.mkv"
set ARGS=

::program switches
set ARGS=%ARGS%  -y  -hide_banner  -loglevel "info"  -stats  -threads "16"  -strict "experimental"

::input
set ARGS=%ARGS% -i %FILE_INPUT%

::flags
  set ARGS=%ARGS% -flags              "+naq+low_delay+global_header-unaligned-ilme-cgop-loop-output_corrupt"
  set ARGS=%ARGS% -flags2             "+fast+ignorecrop+showall+export_mvs"
  set ARGS=%ARGS% -fflags             "+ignidx+genpts+nofillin+discardcorrupt-fastseek"
  set ARGS=%ARGS% -movflags           "+faststart+disable_chpl"
  set ARGS=%ARGS% -avoid_negative_ts  "make_zero"
  set ARGS=%ARGS% -tune               "zerolatency"

  set ARGS=%ARGS% -profile:v          "high"
  set ARGS=%ARGS% -level              "5.2"
::set ARGS=%ARGS% -profile:v          "baseline"
::set ARGS=%ARGS% -level              "3.0"

::motion-estimation
set ARGS=%ARGS% -subq      "9"
set ARGS=%ARGS% -refs      "25"
set ARGS=%ARGS% -me_method "full"

::frames logic (I,IDR)
set ARGS=%ARGS% -g               "2"
set ARGS=%ARGS% -intra-refresh   "0"
set ARGS=%ARGS% -forced-idr      "1"
::                                          use I-frames (disable adaptive number of B-frames)
set ARGS=%ARGS% -b_strategy      "0"
set ARGS=%ARGS% -x264opts        "keyint=4"
::                                          max B frames between reference frames
set ARGS=%ARGS% -bf              "2"
::                                          increase number of lookahead fragments
set ARGS=%ARGS% -lookahead_count "4"


::frames processing (mostly for WebM)
::set ARGS=%ARGS% -lag-in-frames  "25"
::set ARGS=%ARGS% -frame-parallel "1"
::set ARGS=%ARGS% -tile-columns   "6"
::set ARGS=%ARGS% -tile-rows      "2"
::set ARGS=%ARGS% -auto-alt-ref   "1"

::start/finish
  set ARGS=%ARGS% -ss "00:00:00.001"
  set ARGS=%ARGS% -to "00:10:01.000"

::meta data processing
set ARGS=%ARGS% -map_chapters  "-1"
set ARGS=%ARGS% -map_metadata  "-1"

::video processing
set ARGS=%ARGS% -aq-mode      "variance"
::                            (default 8 or -1 ??)   Reduces blocking and blurring in flat and textured areas. (from -1 to FLT_MAX) (default -1)
set ARGS=%ARGS% -aq-strength  "1"
::                            (default -1)           Reduce fluctuations in QP (before curve compression)
set ARGS=%ARGS% -cplxblur     "10"

set ARGS=%ARGS% -crf          "23"
set ARGS=%ARGS% -preset       "veryslow"
set ARGS=%ARGS% -qcomp        "0.60"
set ARGS=%ARGS% -rc-lookahead "25"
::              align, deinterlace, fix chroma, adjust frames to 16:9 by padding, accurate frame-rate and set video-step-speed according to the frame-rate.
set ARGS=%ARGS% -vf "setpts=PTS-STARTPTS,yadif=0:-1:0,dejudder=cycle=20,mpdecimate,format=pix_fmts=yuv420p,scale=480:-1,fps=fps=25,setpts=N/FRAME_RATE/TB-STARTPTS,format=pix_fmts=yuv420p"
::              same but without padding or screen-size modification.
::set ARGS=%ARGS% -vf "setpts=PTS-STARTPTS,yadif=0:-1:0,dejudder=cycle=20,mpdecimate,format=pix_fmts=yuv420p,fps=fps=25,setpts=N/FRAME_RATE/TB-STARTPTS,format=pix_fmts=yuv420p"

::audio processing
set ARGS=%ARGS% -af "asetpts=PTS-STARTPTS,aresample=async=1:min_hard_comp=0.100000" -vsync "1"

call ffmpeg.exe %ARGS% %FILE_OUTPUT%

echo.

::--------------------------------------------------------------------------------

:NEXT
shift
goto LOOP

:END
pause

::-mpv_flags                "+strict_gop"
::-force_duplicated_matrix  "1"
::-strict_gop               "1"
