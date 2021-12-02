@echo off
if exist list.txt   ( del /f /q list.txt   >nul );
if exist output.mp3 ( del /f /q output.mp3 >nul );


echo # MP3 LIST(%DATE% %TIME%)>list.txt
for %%e in (*.mp3) do (
  echo file '%%e'>>list.txt

  for /f "tokens=*" %%a in ('ffprobe -i "%%e" -v "error" -select_streams "a:0" -show_entries "stream=duration" -print_format "default=noprint_wrappers=1:nokey=1"') do ( 
    echo duration %%a>>list.txt
  );
  
  echo.>>list.txt
)

call ffmpeg.exe -y -hide_banner -loglevel "info" -stats        ^
-flags             "-loop+naq+low_delay+global_header"         ^
-fflags            "-fastseek+genpts+discardcorrupt+nofillin"  ^
-flags2            "+fast+ignorecrop+showall+export_mvs"       ^
-avoid_negative_ts "make_zero"                                 ^
-analyzeduration   "2000000"                                   ^
-threads 16                                                    ^
-safe "0" -f concat -i "list.txt"                              ^
-movflags          "+rtphint+dash+disable_chpl+faststart"      ^
-map_metadata      "0" -write_id3v2 "1" -id3v2_version "3"     ^
-c:a libmp3lame ^
-c copy  ^
-f mp3 output.mp3

pause