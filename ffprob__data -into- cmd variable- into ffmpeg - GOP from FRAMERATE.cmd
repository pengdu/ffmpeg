::@echo off

set FILE_INPUT="%~1"
::set FILE_OUTPUT="%~d1%~p1%~n1.mp3"

::FRAMERATE
for /f "tokens=*" %%a in ('ffprobe -i %FILE_INPUT% -v "error" -select_streams "v:0" -show_entries "stream=avg_frame_rate" -print_format "default=noprint_wrappers=1:nokey=1"') do (
  set /a FRAMERATE=%%a
);
set /a GROUP_OF_PICTURES=2*%FRAMERATE%

echo %GROUP_OF_PICTURES%

pause
::ffmpeg -i input -c:v libx264 -crf 23 output.mp4

:: 
:: 
:: ffmpeg -y -hide_banner -i "20160629_012932.mp4" -maxrate 4000k -g "2*FRAME_RATE" -preset veryslow -crf 21 aaaa.mp4
:: 
:: ffmpeg -y -hide_banner -i "input.mp4" -bt 50M -vf "mpdecimate,setpts=N/FRAME_RATE/TB" -preset veryslow -crf 21 -vsync 2 -async 1 -tune zerolatency -movflags "+faststart" -pix_fmt yuv420p "output.mp4"
:: 
:: +make it play well on Android devices.
:: ffmpeg -y -hide_banner -i "input.mp4" -profile:v "baseline" -level "3.0" -bt 50M -vf "mpdecimate,setpts=N/FRAME_RATE/TB" -preset veryslow -crf 21 -vsync 2 -async 1 -tune zerolatency -movflags "+faststart" -pix_fmt yuv420p "output.mp4"
:: 
:: +makes FFMPEG parse correctly 60 frames-per-second on Samsung and Canon's "1080i AVHCD" HD videos
:: 
:: ffmpeg -y -hide_banner -r 60 -i "input.mp4" -profile:v "baseline" -level "3.0" -bt 50M -vf "mpdecimate,setpts=N/FRAME_RATE/TB" -preset veryslow -crf 21 -vsync 2 -async 1 --force-cfr --fps 60 -tune zerolatency -movflags "+faststart" -pix_fmt yuv420p "output.mp4"
:: 
:: 
:: 
:: 
::  (force input FPS using "-r" and output FPS using "--fps")
:: 
:: ffmpeg -y -hide_banner -framerate 60 -r 60 --fps 60 -force_fps --force-cfr -i "input.mp4" -framerate 60 -r 60 --fps 60 -force_fps --force-cfr -profile:v "baseline" -level "3.0" -bt 50M -vf "mpdecimate,setpts=N/FRAME_RATE/TB" -preset veryslow -crf 21 -vsync 2 -async 1 -tune zerolatency -movflags "+faststart" -pix_fmt yuv420p "output.mp4"