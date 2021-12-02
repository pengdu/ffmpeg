@echo off
chcp 65001 2>nul >nul


::-----------------------------------------------  reset
set "EXIT_CODE=0"
set "FFMPEG="
set "FFPROBE="
set "GET_TIMESTAMP_FROM_FILENAME="
set "FONT="
set "FILE_IN="
set "FILE_OUT="
set "TIMECODE_AND_TEXT="
set "FRAMERATE="
set "FRAME_WIDTH="
set "ARGS="
::--------------------------------------------------------------------------------------------------------




::system-PATH 'ffmpeg.exe'.
echo [INFO] looking for ffmpeg.exe in local folder...                                    1>&2
set "FFMPEG=%~sdp0ffmpeg.exe"
if exist %FFMPEG%                                       ( goto LOCAL_FFMPEG     )
echo [INFO] looking for ffmpeg.exe in system-PATH...                                     1>&2
for /f "tokens=*" %%a in ('where ffmpeg.exe 2^>nul') do ( set "FFMPEG=%%a"      )
if ["%ErrorLevel%"] NEQ ["0"]                           ( goto ERROR_NOFFMPEG   )
if ["%FFMPEG%"] EQU [""]                                ( goto ERROR_NOFFMPEG   )
for /f %%a in ("%FFMPEG%")                           do ( set "FFMPEG=%%~fsa"   )
if not exist %FFMPEG%                                   ( goto ERROR_NOFFMPEG   )
:LOCAL_FFMPEG
echo [INFO] %FFMPEG%               1>&2
echo [INFO] Done.                  1>&2
echo.                              1>&2


::system-PATH 'ffprobe.exe'.
echo [INFO] looking for ffprobe.exe in local folder...                                    1>&2
set "FFPROBE=%~sdp0ffprobe.exe"
if exist %FFPROBE%                                       ( goto LOCAL_FFPROBE     )
echo [INFO] looking for ffprobe.exe in system-PATH...                                     1>&2
for /f "tokens=*" %%a in ('where ffprobe.exe 2^>nul') do ( set "FFPROBE=%%a"      )
if ["%ErrorLevel%"] NEQ ["0"]                            ( goto ERROR_NOFFPROBE   )
if ["%FFPROBE%"] EQU [""]                                ( goto ERROR_NOFFPROBE   )
for /f %%a in ("%FFPROBE%")                           do ( set "FFPROBE=%%~fsa"   )
if not exist %FFPROBE%                                   ( goto ERROR_NOFFPROBE   )
:LOCAL_FFPROBE
echo [INFO] %FFPROBE%              1>&2
echo [INFO] Done.                  1>&2
echo.                              1>&2


::another tool ---a NodeJS script to extract FFMPEG-compatible-time-format from video-file-name.
echo [INFO] Getting timestamp starting-time...    1>&2
echo [INFO] %~n1                                  1>&2
set "GET_TIMESTAMP_FROM_FILENAME=%~sdp0get_timestamp_from_filename.cmd"
for /f %%a in ("%GET_TIMESTAMP_FROM_FILENAME%") do (set "GET_TIMESTAMP_FROM_FILENAME=%%~fsa"  )
if ["%GET_TIMESTAMP_FROM_FILENAME%"] EQU [""] ( goto ERROR_GET_TIMESTAMP_FROM_FILENAME )
echo [INFO] %GET_TIMESTAMP_FROM_FILENAME%         1>&2
echo.                                             1>&2


::-----------------------------------------------  VID_20180617_212020.mp4
set "FILE_IN=%~f1"
::-----------------------------------------------  VID_20180617_212020_timestamp.mp4
set "FILE_OUT=%~sdp1%~n1_timestamp%~x1"
::-----------------------------------------------  timecode=\'21\:20\:20\':text=\'17/06/2018. \'
for /f "tokens=*" %%a in ('call "%GET_TIMESTAMP_FROM_FILENAME%" "%FILE_IN%" 2^>nul') do ( set "TIMECODE_AND_TEXT=%%a" )
::-----------------------------------------------  25
for /f "tokens=*" %%a in ('call "%FFPROBE%" -i "%FILE_IN%" -v "error" -select_streams "v:0" -show_entries "stream=avg_frame_rate" -print_format "default=noprint_wrappers=1:nokey=1" 2^>nul')   do ( set /a "FRAMERATE=%%a"      )
for /f "tokens=*" %%a in ('call "%FFPROBE%" -i "%FILE_IN%" -v "error" -select_streams "v:0" -show_entries "stream=width"          -print_format "default=noprint_wrappers=1:nokey=1" 2^>nul')   do ( set /a "FRAME_WIDTH=%%a"    )


set "FONT=%~sdp0courbd.ttf"
set "FONT=%FONT:\=/%"


set  ARGS=%ARGS% -y -hide_banner -strict experimental -i "%FILE_IN%" -preset veryfast -codec:a copy
set  ARGS=%ARGS% -vf "fifo,setpts=PTS-STARTPTS,fps=25
set  ARGS=%ARGS%,drawtext=
::set  ARGS=%ARGS%:fontfile=\'c\:/Windows/Fonts/courbd.ttf\'
set  ARGS=%ARGS%:fontfile=\'%FONT%\'
set  ARGS=%ARGS%:fontcolor=yellow
set  ARGS=%ARGS%:borderw=1
set  ARGS=%ARGS%:alpha=0.7

:: dynamic file-size, relative to screen-width. 22 is a decent ration in few of the trials. (result is a whole-division): 240x240 -> 10p, 320x240 -> 14p. 1280x720 -> 58p.
set /a "FRAME_WIDTH=%FRAME_WIDTH% / 22"
set  ARGS=%ARGS%:fontsize=%FRAME_WIDTH%
::set  ARGS=%ARGS%:fontsize=37

::set  ARGS=%ARGS%:y=(main_h-text_h-line_h)       ------- on bottom left
::set  ARGS=%ARGS%:y=(text_h-line_h)              ------- on top left
::set  ARGS=%ARGS%:y=(text_h-line_h+3)            ------- on top left with ~~''padding-top:3px''
set  ARGS=%ARGS%:y=(text_h-line_h+3)

set  ARGS=%ARGS%:timecode_rate=%FRAMERATE%
set  ARGS=%ARGS%:%TIMECODE_AND_TEXT%
set  ARGS=%ARGS%"
set  ARGS=%ARGS% -pix_fmt "yuv420p"
set  ARGS=%ARGS% "%FILE_OUT%"


echo  "%FFMPEG%" %ARGS%       1>&2
call  "%FFMPEG%" %ARGS%
set "EXIT_CODE=%ErrorLevel%"


goto END


:ERROR_NOFFMPEG
  echo [ERROR] can not find ffmpeg.exe  1>&2
  goto END

:ERROR_NOFFMPEG
  echo [ERROR] can not find ffprobe.exe  1>&2
  goto END

:ERROR_GET_TIMESTAMP_FROM_FILENAME
  echo [ERROR] the file-name can not be parsed to date/time.  1>&2
  goto END


:END
  pause
  exit /b %EXIT_CODE%
