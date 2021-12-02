@echo off
::take an image using the integrated-camera (webcam) of lenovo/IBM PC, save the image to the desktop.
::https://trac.ffmpeg.org/wiki/DirectShow


set "D=%DATE%"
set "T=%TIME%"
set "YEAR=%D:~-4,4%"
set "MONTH=%D:~-10,2%"
set "DAY=%D:~-7,2%"
set "HOURS=%T:~0,2%"
set "MINUTES=%T:~3,2%"
set "SECONDS=%T:~6,2%"
set "TIMESTEMP=%YEAR%%MONTH%%DAY%_%HOURS%%MINUTES%%SECONDS%"

::set "FILENAME=.\IMG_%TIMESTEMP%.jpg"
set "FILENAME=%UserProfile%\Desktop\IMG_%TIMESTEMP%.png"


ffmpeg -y -hide_banner -loglevel "info" -strict "experimental" -f dshow -video_size "1280x720" -framerate "1.0" -pixel_format "bgr24" -i video="Integrated Camera" -pixel_format "yuv420p" "%FILENAME%"

