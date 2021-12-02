@echo off
call ffmpeg.exe -y                                                                     ^
-hide_banner -loglevel "info" -stats                                                   ^
-ss 00:01:05.0                                                                         ^
-i  "input.mp4"                                                                        ^
-threads 16                                                                            ^
-flags     "-loop+naq+low_delay"                                                       ^
-flags2    "+fast+ignorecrop+showall+export_mvs"                                       ^
-fflags    "+genpts+discardcorrupt-fastseek"                                           ^
-movflags  "+faststart"                                                                ^
-tune      "zerolatency"                                                               ^
-pix_fmt   "yuv420p"                                                                   ^
-profile:v "high" -level "5.0"                                                         ^
 ^
-x264opts  "keyint=4" -g "2" -forced-idr "true" -refs "25" -rc-lookahead "25"          ^
-preset    "veryslow" -crf "23" -subq "9" -qcomp "0.60"                                ^
 ^
-af        "asetpts=PTS-STARTPTS,aresample=async=1:min_hard_comp=0.100000" -vsync "1"  ^
-vf        "setpts=PTS-STARTPTS,yadif=0:-1:0,dejudder=cycle=20,mpdecimate,fps=fps=25,setpts=N/FRAME_RATE/TB-STARTPTS,format=pix_fmts=yuv420p"   ^
-map_metadata "-1"                                                                     ^
-sn -ss 00:00:00.376 -t 00:00:08.572                                                   ^
out.mp4


ffmpeg -y -hide_banner -loglevel "info" -stats -safe "0" -f concat -i "streams_1hour.txt" -threads 16 -vcodec copy -acodec copy  "out_repeat.mp4"


call ffmpeg.exe -y                                                                     ^
-hide_banner -loglevel "info" -stats                                                   ^
-i  "out_repeat.mp4"                                                                   ^
-threads 16                                                                            ^
-flags     "-loop+naq+low_delay"                                                       ^
-flags2    "+fast+ignorecrop+showall+export_mvs"                                       ^
-fflags    "+genpts+discardcorrupt-fastseek"                                           ^
-movflags  "+faststart"                                                                ^
-tune      "zerolatency"                                                               ^
-pix_fmt   "yuv420p"                                                                   ^
-profile:v "high" -level "5.0"                                                         ^
 ^
-ss 00:00:00.005                                                                       ^
-x264opts  "keyint=4" -g "2" -forced-idr "true" -refs "25" -rc-lookahead "25"          ^
-preset    "veryslow" -crf "23" -subq "9" -qcomp "0.60"                                ^
 ^
-af        "asetpts=PTS-STARTPTS,aresample=async=1:min_hard_comp=0.100000" -vsync "1"  ^
-vf        "setpts=PTS-STARTPTS,yadif=0:-1:0,dejudder=cycle=20,mpdecimate,fps=fps=25,setpts=N/FRAME_RATE/TB-STARTPTS,format=pix_fmts=yuv420p"   ^
-map_metadata "-1"                                                                     ^
out_repeat_1hour.mp4

pause
pause