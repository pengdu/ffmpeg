@echo off
::take an image using the integrated-camera (webcam) of lenovo/IBM PC, save the image to the desktop.
::https://trac.ffmpeg.org/wiki/DirectShow

::modifications to the initial-example:
::   framerate tricks for faster writing (1/1 framerate/second limits).
::   timestamp written on-to the image (default font-family).


set "D=%DATE%"
set "T=%TIME%"
set "YEAR=%D:~-4,4%"
set "MONTH=%D:~-10,2%"
set "DAY=%D:~-7,2%"
set "HOURS=%T:~0,2%"
set "MINUTES=%T:~3,2%"
set "SECONDS=%T:~6,2%"
set "TIMESTAMP=%YEAR%%MONTH%%DAY%_%HOURS%%MINUTES%%SECONDS%"

set "FILENAME=%~sdp0IMG_%TIMESTAMP%.jpg"
::set "FILENAME=%UserProfile%\Desktop\IMG_%TIMESTAMP%.jpg"

set "FONT=%~sdp0resources\courbd.ttf"
set "FONT=%FONT:\=/%"


set "ARGS="
set  ARGS=%ARGS% -y -hide_banner -loglevel "info" -strict "experimental"
::video source arguments
set  ARGS=%ARGS% -f dshow -video_size "1280x720" -r "1" -framerate "1.0" -pixel_format "bgr24" 
::limit length
set  ARGS=%ARGS% -to "00:00:01.000" 
::video source
set  ARGS=%ARGS% -i video="Integrated Camera"
::write text on image
::set  ARGS=%ARGS% -vf "fps=fps=1,drawtext=fontsize=40:text=%TIMESTAMP%"
::write text on image (better date/time format)
set  ARGS=%ARGS% -vf "fps=fps=1,drawtext=fontsize=40:fontfile=\'%FONT%\':text=\'%DAY%/%MONTH%/%YEAR% %HOURS%\:%MINUTES%\:%SECONDS%\'"
::write understandable color-format
set  ARGS=%ARGS% -pixel_format "yuv420p" 
::explicitly disable other streams
set  ARGS=%ARGS% -an -sn
::output
set  ARGS=%ARGS%  "%FILENAME%"


echo ffmpeg %ARGS%
call ffmpeg %ARGS%


exit /b %ErrorLevel%
