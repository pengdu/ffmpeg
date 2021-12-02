@echo off
chcp 65001          2>nul >nul
mkdir "%~sdp1fixed" 2>nul >nul


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

  set "FILE_INPUT=%~s1"
  set "FILE_OUTPUT=%~sdp1fixed\%~n1.mkv"
  set ARGS=

::program switches
  set ARGS=%ARGS%  -y  -hide_banner  -loglevel "info"  -stats  -threads "16"  -strict "experimental"

::input
  set ARGS=%ARGS% -i "%FILE_INPUT%"

::flags
  set ARGS=%ARGS% -flags              "+low_delay+global_header-unaligned-ilme-cgop-loop-output_corrupt"
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
  set ARGS=%ARGS% -subq       "9"
  set ARGS=%ARGS% -refs       "25"
  set ARGS=%ARGS% -motion-est "esa"
  set ARGS=%ARGS% -me_method  "esa"

::frames logic (I,IDR)
::set ARGS=%ARGS% -g             "2"
  set ARGS=%ARGS% -g               "18"
  set ARGS=%ARGS% -intra-refresh   "0"
  set ARGS=%ARGS% -forced-idr      "1"
::                                          use I-frames (disable adaptive number of B-frames)
  set ARGS=%ARGS% -b_strategy      "0"
  set ARGS=%ARGS% -x264opts        "keyint=4"
::                                          max B frames between reference frames
  set ARGS=%ARGS% -bf              "2"
::                                          increase number of lookahead fragments
  set ARGS=%ARGS% -lookahead_count "4"


::start/finish
  set ARGS=%ARGS% -ss "00:00:00.011"
  set ARGS=%ARGS% -to "00:00:10.000"

::meta data processing
set ARGS=%ARGS% -map_chapters  "-1"
set ARGS=%ARGS% -map_metadata  "-1"

::video processing
set ARGS=%ARGS% -aq-mode      "variance"
::                            (default 8 or -1 ??)   Reduces blocking and blurring in flat and textured areas. (from -1 to FLT_MAX) (default -1)
set ARGS=%ARGS% -aq-strength  "1"
::                            (default -1)           Reduce fluctuations in QP (before curve compression)
set ARGS=%ARGS% -cplxblur     "10"

set ARGS=%ARGS% -crf          "22"
set ARGS=%ARGS% -preset       "veryslow"
set ARGS=%ARGS% -qcomp        "0.60"
set ARGS=%ARGS% -rc-lookahead "25"
set ARGS=%ARGS% -vsync "1"

::align start, deinterlace, chroma fix, frame-rate fix, crop to even screen-size.
set ARGS=%ARGS% -vf "setpts=PTS-STARTPTS,yadif=0:-1:0,dejudder=cycle=20,mpdecimate,format=pix_fmts=yuv420p,fps=fps=25,setpts=N/FRAME_RATE/TB-STARTPTS,crop=trunc(in_w/2)*2:trunc(in_h/2)*2"

::adjust length to total length of shorter video.
set ARGS=%ARGS% -shortest

::audio processing
set ARGS=%ARGS% -af "asetpts=PTS-STARTPTS"


call ffmpeg.exe %ARGS% "%FILE_OUTPUT%"

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
