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

set FILE_INPUT="%~s1"
set FILE_OUTPUT="%~d1%~p1%~n1_fixed.mkv"

call ffmpeg.exe -y                                                                     ^
-hide_banner -loglevel "info" -stats                                                   ^
-i %FILE_INPUT%                                                                        ^
-threads 16                                                                            ^
-flags     "-loop+naq+low_delay"                                                       ^
-flags2    "+fast+ignorecrop+showall+export_mvs"                                       ^
-fflags    "+genpts+discardcorrupt+fastseek"                                           ^
-movflags  "+faststart"                                                                ^
-tune      "zerolatency"                                                               ^
-pix_fmt   "yuv420p"                                                                   ^
-profile:v "high" -level "5.0"                                                         ^
 ^
-x264opts  "keyint=4" -g "2" -forced-idr "true" -refs "60" -rc-lookahead "60"          ^
-preset    "veryslow" -crf "23" -subq "9" -qcomp "0.60"                                ^
 ^
-ss        "00:00:00.001"                                                              ^
-af        "aresample=async=1:min_hard_comp=0.100000" -vsync "1"                       ^
-vf        "yadif=0:-1:0,dejudder=cycle=20,mpdecimate,fps=fps=60,setpts=N/FRAME_RATE/TB-STARTPTS,format=pix_fmts=yuv420p"   ^
-map_metadata "-1"                                                                     ^
%FILE_OUTPUT%

:NEXT
shift
goto LOOP

:END
pause
