@echo off

echo # MP3 LIST(%DATE% %TIME%) >list.txt
for %%e in (*.mp3 *.m4a *.oga *.flac) do (
  echo file '%%e' >>list.txt
)

call ffmpeg.exe -y -hide_banner -loglevel "info" -stats     ^
-threads 16                                                 ^
-flags     "+loop+global_header+naq+low_delay"              ^
-fflags    "+genpts+discardcorrupt+fastseek"                ^
-flags2    "+fast+ignorecrop+showall+export_mvs"            ^
-avoid_negative_ts make_zero                                ^
 ^
-safe "0"  -f concat  -i "list.txt"                         ^
-r 1       -loop 1    -i "cover.jpg"                        ^
-movflags  "+rtphint+dash+disable_chpl+faststart"           ^
 ^
-ss        "00:00:00.001"                                   ^
-to        "00:00:10.000"                                   ^
 ^
-s "1280x720"                                               ^
-ignore_chapters   1                                        ^
-profile:v "high" -level "5.0"                              ^
-pix_fmt   "yuv420p"                                        ^
-tune      "stillimage"                                     ^
-preset    "veryslow" -crf "23" -subq "9" -qcomp "0.60"     ^
 ^
-af        "asetpts=PTS-STARTPTS,aresample=async=1:min_hard_comp=0.100000"  ^
-vf        "setpts=PTS-STARTPTS" -vsync "1"                                 ^
 ^
-c:a  aac      -b:a 128k -ar 44100                          ^
-c:v  libx264  -b:v 1k -minrate 1k -maxrate 1k              ^
 ^
output.mkv


del /f /q list.txt >nul

::http://icompile.eladkarako.com/ffmpeg-merge-multiple-audio-files-to-a-single-video/#more-7102
pause