@echo off

echo # MP3 LIST(%DATE% %TIME%) >list.txt
for %%e in (*.mp3) do (
  echo file '%%e' >>list.txt
)

call ffmpeg.exe -y -hide_banner -loglevel "info" -stats                     ^
-safe "0" -f concat -i "list.txt" -vn -sn                                   ^
-threads 16                                                                 ^
-flags     "-loop+naq+low_delay"                                            ^
-flags2    "+fast+ignorecrop+showall+export_mvs"                            ^
-fflags    "+genpts+discardcorrupt+fastseek"                                ^
-movflags  "+faststart+disable_chpl"                                        ^
-ignore_unknown                                                             ^
-ignore_chapters                                                            ^
-ignore_editlist                                                            ^
-map_metadata "-1"                                                          ^
-af        "asetpts=PTS-STARTPTS,aresample=async=1:min_hard_comp=0.100000"  ^
-c:a libmp3lame -b:a 128k -ar 44100                                         ^
output.mp3


pause