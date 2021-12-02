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

set TARGET_FPS=25

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
-x264opts  "keyint=4" -g "2" -forced-idr "true" -refs "25" -rc-lookahead "25"          ^
-preset    "veryslow" -crf "23" -subq "9" -qcomp "0.60"                                ^
 ^
-ss        "00:00:00.001"                                                              ^
-af        "aresample=async=1:min_hard_comp=0.100000" -vsync "1"                       ^
-vf        "yadif=0:-1:0,dejudder=cycle=20,mpdecimate,fps=fps=%TARGET_FPS%,setpts=N/FRAME_RATE/TB-STARTPTS,format=pix_fmts=yuv420p"   ^
-map_metadata "-1"                                                                     ^
%FILE_OUTPUT%

:NEXT
shift
goto LOOP

:END
pause

::-fflags    "+genpts+discardcorrupt+fastseek"                                           ^
::-x264opts "no-deblock:keyint=4:min-keyint=4:scenecut=-1" -keyint_min "4" -g "4" -refs "4" -rc-lookahead "4" -forced-idr "true" -sc_threshold "80" ^
::-profile:v "baseline" -level "3.0"        ^
::-filter:v "fieldmatch=order=tff:combmatch=full,yadif=deint=interlaced,decimate,dejudder,format=pix_fmts=yuv420p,setpts=N/FRAME_RATE/TB"       ^
::-filter:v "format=pix_fmts=yuv420p,fps=25,fieldmatch=order=tff:combmatch=full,yadif=deint=interlaced,decimate,dejudder,setpts=N/FRAME_RATE/TB"       ^
::mpdecimate
::fps=60,
::-report 
::-x264opts   "scenecut=-1"                                                                       ^
::-filter:v "setpts=PTS-STARTPTS,fieldmatch=order=tff:combmatch=full,yadif=mode=send_frame:parity=tff:deint=all,decimate,dejudder,format=pix_fmts=yuv420p,setpts=N/FRAME_RATE/TB"       ^
::-loglevel "info" -stats                            ^
::-flags2     "+fast+local_header"                                                                ^
::-fflags     "+flush_packets+ignidx+genpts+nofillin+igndts+discardcorrupt+bitexact+fastseek"     ^
::-movflags   "+rtphint+frag_keyframe+separate_moof+isml+omit_tfhd_offset+faststart"              ^
::,format=yuv420p
::-async "1" -shortest                                                          ^
::-preset "veryslow" -crf "23"                                                                                    ^
::-filter:v "setpts=PTS-STARTPTS,mpdecimate,setpts=N/FRAME_RATE/TB"                    ^
::yadif=0:-1:0
::-x264opts "no-deblock:keyint=4:scenecut=-1" -g "4" -refs "4" -rc-lookahead "4" -forced-idr "true" ^
::-pix_fmt "yuv420p" -flags "+loop+mv0+naq+low_delay+global_header" -fflags "+genpts+discardcorrupt+ignidx+igndts+nofillin" -movflags "+isml+omit_tfhd_offset+faststart"  ^
::-g "4" -forced-idr "true" ^
::-filter:v "setpts=PTS-STARTPTS,fieldmatch=order=tff:combmatch=full,yadif=mode=send_frame:parity=tff:deint=all,decimate,dejudder,setpts=PTS-STARTPTS,yadif=0:-1:0,mpdecimate,setpts=N/FRAME_RATE/TB,format=pix_fmts=yuv420p"       ^

::-profile:v "baseline" -level "3.0"                                                     ^