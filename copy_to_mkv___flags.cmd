@echo off
::support Unicode-charset names in command-line.
chcp 65001 2>nul >nul

::file input/output names (8.3 short-names for input and for output's folder. output's filename is normal).
set "FILE_INPUT=%~s1"
set "FILE_OUTPUT=%~sdp1%~n1_fixed.mkv"

::query media. next - will helps bit-stream filters (MUX).
set "PROBED_VCODEC="
for /f "tokens=*" %%a in ('call ffprobe.exe -hide_banner -loglevel error -i %FILE_INPUT% -select_streams "v:0" -show_entries "stream=codec_name" -print_format "default=noprint_wrappers=1:nokey=1"') do (set PROBED_VCODEC=%%a) 

::bit-stream filters (MUX) - video.
set "BIT_FILTERS="
if /i ["%PROBED_VCODEC%"]   EQU ["mpeg4"] (set BIT_FILTERS=%BIT_FILTERS% -bsf:v "mpeg4_unpack_bframes,remove_extra=freq=all") 
if /i ["%PROBED_VCODEC%"]   EQU ["h264"]  (set BIT_FILTERS=%BIT_FILTERS% -bsf:v "h264_redundant_pps,remove_extra=freq=all") 
if /i ["%PROBED_VCODEC%"]   EQU ["h264"]  (set BIT_FILTERS=%BIT_FILTERS% -bsf:v "h264_redundant_pps,remove_extra=freq=all") 
if /i ["%PROBED_VCODEC%"]   NEQ ["mpeg4"] ( 
  if /i ["%PROBED_VCODEC%"] NEQ ["h264"]    (set BIT_FILTERS=%BIT_FILTERS% -bsf:v "remove_extra=freq=all") 
)
::bit-stream filters (MUX) - audio.
set "PROBED_ACODEC="
for /f "tokens=*" %%a in ('call ffprobe.exe -hide_banner -loglevel error -i %FILE_INPUT% -select_streams "a:0" -show_entries "stream=codec_name" -print_format "default=noprint_wrappers=1:nokey=1"') do (set PROBED_ACODEC=%%a) 
if /i ["%PROBED_ACODEC%"] EQU ["mp3"]     (set BIT_FILTERS=%BIT_FILTERS% -bsf:a "mp3decomp") 

set "ARGS="
set ARGS=%ARGS% -hide_banner -threads auto -err_detect ignore_err -y 
set ARGS=%ARGS% -flags "-output_corrupt" -fflags "+discardcorrupt+autobsf"
set ARGS=%ARGS% -i "%FILE_INPUT%"
set ARGS=%ARGS% %BIT_FILTERS%
set ARGS=%ARGS% -codec  copy
::set ARGS=%ARGS% -dcodec copy

echo ffmpeg %ARGS% "%FILE_OUTPUT%"
call ffmpeg %ARGS% "%FILE_OUTPUT%"

pause
