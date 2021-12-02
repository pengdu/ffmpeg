@echo off

call ffmpeg.exe -y -hide_banner -loglevel "info" -stats        ^
-flags             "-loop+naq+low_delay+global_header"         ^
-fflags            "-fastseek+genpts+discardcorrupt+nofillin"  ^
-flags2            "+fast+ignorecrop+showall+export_mvs"       ^
-avoid_negative_ts "make_zero"                                 ^
-analyzeduration   "2000000"                                   ^
-threads 16                                                    ^
-i "output.mp3"                                                ^
-movflags          "+rtphint+dash+disable_chpl+faststart"      ^
-map_metadata      "0" -write_id3v2 "1" -id3v2_version "3"     ^
 ^
-af "asetpts=PTS-STARTPTS,aresample=async=1:min_hard_comp=0.100000"  ^
-c:a libmp3lame -b:a 128k -ar 44100                                  ^
output_fixed.mp3

pause