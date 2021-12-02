@echo off
::-------------------------------------------------------------------------------------------------------------------------------------------
:: drag and drop two files.
:: the program will automatically figure-out
:: the audio and the image files.
::
:: valid options:
::   mp3 + jpg                      (image will be the jpg)
::   jpg + mp3                      (image will be the jpg)
::   mp3 + mp3 with cover IDv3 art  (image will be the cover-art)  - *first file will be the audio source
::   mp3 + mp4 with video           (image will be the video)      - *first file will be the audio source
::   mp4 + mp3 with cover IDv3 art  (image will be the cover-art)  - *first file will be the audio source
::
::   by default, when using two files with audio stream(s),
::   the audio will taken from the first one.
::
::   the best way is to use this program with audio and a still-image.
:: - - - - - - - - - - - - - - - - - - -
:: -   one should be audio, and the    - 
:: -   other should be video.          - 
:: -                                   -
:: -   the order does not matter.      - 
:: -                                   -
:: -   video size === image size.      - 
:: -   (unless image size mod 2 !== 0) - 
:: - - - - - - - - - - - - - - - - - - -

::-------------------------------------------------------------------------------------------------------------------------------------------
chcp 65001 2>nul >nul

::-------------------------------------------------------------------------------------------------------------------------------------------
::                                                                        this part descides which is the audio and which is the video file
set "INPUT_AUDIO=%~s1"
set "INPUT_IMAGE=%~s2"

set /a "BITRATE=0"
set /a "SIZE=0"

echo.
echo Testing....
echo AUDIO SOURCE?: "%INPUT_AUDIO%"
echo IMAGE SOURCE?: "%INPUT_IMAGE%"
echo.

::audio source
for /f "tokens=*" %%a in ('ffprobe -i "%INPUT_AUDIO%" -v "error" -select_streams "a:0" -show_entries "stream=bit_rate" -print_format "default=noprint_wrappers=1:nokey=1"') do ( set /a BITRATE=%%a ) 

if ["%BITRATE%"] == ["0"] ( 
  set "INPUT_AUDIO=%~s2" 
  set "INPUT_IMAGE=%~s1" 
  echo ...Nope. Switching order of arguments.... 
) 

for /f "tokens=*" %%a in ('ffprobe -i "%INPUT_AUDIO%" -v "error" -select_streams "a:0" -show_entries "stream=bit_rate" -print_format "default=noprint_wrappers=1:nokey=1"') do ( set /a BITRATE=%%a ) 

if ["%BITRATE%"] == ["0"] ( 
  goto NOAUDIO
) 

::image source
for /f "tokens=*" %%a in ('ffprobe -i "%INPUT_IMAGE%" -v "error" -select_streams "v:0" -show_entries "stream=width" -print_format "default=noprint_wrappers=1:nokey=1"') do ( set /a SIZE=%%a ) 

if ["%SIZE%"] == ["0"] ( 
  goto NOIMAGE
) 



::success
echo.
echo AUDIO SOURCE: "%INPUT_AUDIO%"
echo IMAGE SOURCE: "%INPUT_IMAGE%"
echo.

set ARGS=

set ARGS=%ARGS% -hide_banner -loglevel "info" -stats -y -threads "16" -strict "experimental"
set ARGS=%ARGS% -i "%INPUT_AUDIO%"
set ARGS=%ARGS% -loop "1" -i "%INPUT_IMAGE%"
::set ARGS=%ARGS% -filter_complex ""
set ARGS=%ARGS% -map "0:a" -map "1:v"
::set ARGS=%ARGS% -to "00:00:05.000"
set ARGS=%ARGS% -shortest

::output file
set "FILE_OUTPUT=%~d1%~p1joined.mkv"

echo ffmpeg %ARGS%  "%FILE_OUTPUT%"
call ffmpeg %ARGS%  "%FILE_OUTPUT%"

::-------------------------------------------------------------------------------------------------------------------------------------------



::-----------------------------------------------------------------

goto EXIT

:NOAUDIO
  echo.
  echo ERROR: could not find a suitable audio source.
  goto EXIT

:NOIMAGE
  echo.
  echo ERROR: could not find a suitable image source.
  goto EXIT

:EXIT
  echo.
  pause

