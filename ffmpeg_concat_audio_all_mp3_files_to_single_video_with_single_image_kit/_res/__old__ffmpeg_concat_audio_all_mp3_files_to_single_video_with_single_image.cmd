@echo off

echo # MP3 LIST(%DATE% %TIME%) >list.txt
for %%e in (*.mp3) do (
  echo file '%%e' >>list.txt
)

call ffmpeg.exe -y -hide_banner -loglevel "info" -stats                     ^
-safe "0" -f concat -i "list.txt"                                           ^
-i cover.jpg                                                                ^
-loop 1                                                                     ^
-threads 1                                                                  ^
-r 1                                                                        ^
-s "1280x720"                                                               ^
-profile:v "high" -level "5.0"                                              ^
-pix_fmt   "yuv420p"                                                        ^
-flags     "+loop+naq+low_delay"                                            ^
-flags2    "+fast+ignorecrop+showall+export_mvs"                            ^
-fflags    "+genpts+discardcorrupt+fastseek"                                ^
-movflags  "+faststart+disable_chpl"                                        ^
-tune      "stillimage"                                                     ^
-ignore_unknown                                                             ^
-ignore_chapters                                                            ^
-ignore_editlist                                                            ^
-map_metadata "-1"                                                          ^
-ss        "00:00:00.001"                                                   ^
-to        "00:00:30.000"                                                   ^
-preset    "veryslow" -crf "23" -subq "9" -qcomp "0.60"                     ^
-af        "asetpts=PTS-STARTPTS,aresample=async=1:min_hard_comp=0.100000"  ^
-c:a libmp3lame -b:a 128k -ar 44100                                         ^
output.mp4


del /f /q list.txt >nul
::-c:a aac   -b:a 128k -ar 44100                                              ^
::-tune      "zerolatency"                                                    ^
::-profile:v "baseline" -level "3.0"                                                     ^
::  ffmpeg -y -hide_banner -loglevel "info" -stats -safe "0" -f concat -i "list.txt" -threads 16 -vn -sn -c:a copy audio.mp3

::http://icompile.eladkarako.com/ffmpeg-merge-multiple-audio-files-to-a-single-video/#more-7102
pause