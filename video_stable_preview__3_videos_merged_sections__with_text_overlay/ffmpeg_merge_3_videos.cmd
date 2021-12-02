@echo off

set "ARGS="
set  ARGS=%ARGS% -i "1_raw.mp4" -i "2_ffmpeg_vidstabtransform.mp4" -i "3_ffmpeg_and_hyperlapse.mp4"
set  ARGS=%ARGS% -filter_complex
set  ARGS=%ARGS% "[0:v]crop=iw/3:ih:0:0,drawtext=fontfile=courbd.ttf:fontcolor=white:fontsize=110:x=5:y=20:text=raw[left];
set  ARGS=%ARGS%  [1:v]crop=iw/3:ih:iw/3:0,drawtext=fontfile=courbd.ttf:fontcolor=white:fontsize=80:x=5:y=20:text=ffmpeg[middle];
set  ARGS=%ARGS%  [2:v]crop=iw/3:ih:2*\(iw/3\):0,drawtext=fontfile=courbd.ttf:fontcolor=white:fontsize=40:x=5:y=20:text=ffmpeg+hyperlapse[right];

set  ARGS=%ARGS%  [left][middle][right]hstack=inputs=3:shortest=1"
call ffmpeg -y %ARGS% "out_merged3.mp4"

pause