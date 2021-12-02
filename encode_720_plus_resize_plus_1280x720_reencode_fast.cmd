@echo off
set VIDEO="%~s1"
set OUTPUT="%~d1%~p1%~n1_youtube_720p.mkv"

::call ffmpeg -threads 8 -i %VIDEO% -g 6 -vsync 2 -async 1 -vf "yadif=0:0:1,crop=in_h*16/9:in_h,scale=1280:720" -c:v libx264 -preset slow -crf 18 -c:a libvorbis -q:a 5 -pix_fmt yuv420p %OUTPUT%
call ffmpeg -threads 8 -i %VIDEO% -bt 50M -vf "yadif=0:0:1,crop=in_h*16/9:in_h,scale=1280:720" -vsync 2 -async 1 -c:v libx264 -preset ultrafast -crf 18 -c:a libvorbis -pix_fmt yuv420p %OUTPUT%


pause