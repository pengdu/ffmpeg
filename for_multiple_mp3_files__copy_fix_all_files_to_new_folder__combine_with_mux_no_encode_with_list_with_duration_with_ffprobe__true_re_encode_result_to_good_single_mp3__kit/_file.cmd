@echo off

set FILE_INPUT=%~s1
set FOLDER_OUTPUT=%~d1%~p1FIXED
set FILE_OUTPUT=%~n1%~x1

if NOT exist "%FOLDER_OUTPUT%\"    mkdir "%FOLDER_OUTPUT%\"

call ffmpeg.exe -y -hide_banner -loglevel "info" -stats        ^
-flags             "-loop+naq+low_delay+global_header"         ^
-fflags            "-fastseek+genpts+discardcorrupt+nofillin"  ^
-flags2            "+fast+ignorecrop+showall+export_mvs"       ^
-avoid_negative_ts "make_zero"                                 ^
-analyzeduration   "2000000"                                   ^
-threads 16                                                    ^
-i "%FILE_INPUT%"                                              ^
-movflags          "+rtphint+dash+disable_chpl+faststart"      ^
-map_metadata      "0" -write_id3v2 "1" -id3v2_version "3"     ^
-c copy                                                        ^
"%FOLDER_OUTPUT%\%FILE_OUTPUT%"

exit
