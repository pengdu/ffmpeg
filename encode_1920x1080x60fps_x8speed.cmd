@echo off
set VIDEO="%~s1"
set OUTPUT="%~d1%~p1%~n1_youtube_1920x1080px60fps.mkv"

call ffmpeg -i %VIDEO% -framerate 60 -g 6 -vsync 2 -async 1 -vf "yadif=0:0:1,setpts=0.125*PTS" -c:v libx264 -preset slow -crf 18 -an -pix_fmt yuv420p %OUTPUT%


pause