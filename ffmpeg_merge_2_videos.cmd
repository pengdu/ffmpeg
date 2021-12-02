@echo off

set "ARGS="
set  ARGS=%ARGS% -i "1_hyperlapse.mp4" -i "2_raw.mp4"
set  ARGS=%ARGS% -filter_complex
set  ARGS=%ARGS% "[0:v]crop=iw/2:ih:0:0,drawtext=fontfile=courbd.ttf:fontcolor=white:fontsize=40:x=5:y=20:text=hyperlapse[left];
set  ARGS=%ARGS%  [1:v]crop=iw/2:ih:2*\(iw/2\):0,drawtext=fontfile=courbd.ttf:fontcolor=white:fontsize=40:x=5:y=20:text=raw[right];
set  ARGS=%ARGS%  [left][right]hstack=inputs=2:shortest=1"
set  ARGS=%ARGS% -preset ultrafast
call ffmpeg -y %ARGS% "out_merged2.mp4"

pause