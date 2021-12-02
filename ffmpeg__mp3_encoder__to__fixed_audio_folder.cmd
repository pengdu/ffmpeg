::@echo off
::---------------------
:: "to mp3" encoder
:: fixes timestamps.
:: keep meta-data and album art.
:: normalize: two channels (joint stereo), 192kbps, 44.1kHz.
:: writes file to "fixed_audio" (same file name).
::---------------------------------------------------------------


set "EXIT_CODE=0"
chcp 65001 1>nul 2>nul

set "FFMPEG=ffmpeg.exe"
set "FFPROBE=ffprobe.exe"

title [PROCESSING..] %~nx1

pushd "%~dp1"

set "INPUT=%~f1"
mkdir "fixed_audio"
set "OUTPUT=fixed_audio\%~n1.mp3"

set "ARGS="
set  ARGS=%ARGS% -hide_banner -y -loglevel verbose -stats -strict "experimental" -err_detect "ignore_err" -nostdin
set  ARGS=%ARGS% -flags  "+cgop+loop-unaligned-output_corrupt"
set  ARGS=%ARGS% -fflags "+autobsf+genpts+nofillin+discardcorrupt-fastseek-igndts-ignidx"
set  ARGS=%ARGS% -flags2 "+ignorecrop"

set  ARGS=%ARGS% -i "%INPUT%"

::set  ARGS=%ARGS% -use_wallclock_as_timestamps 1
::set  ARGS=%ARGS% -force_duplicated_matrix  "1"
set  ARGS=%ARGS% -avoid_negative_ts "make_zero"
set  ARGS=%ARGS% -segment_time_metadata 1
set  ARGS=%ARGS% -enc_time_base "-1"
set  ARGS=%ARGS% -safe 0

set  ARGS=%ARGS% -probesize         "10000000"
set  ARGS=%ARGS% -analyzeduration   "2000000"



set  ARGS=%ARGS% -c:a           "libmp3lame"
set  ARGS=%ARGS% -ac            "2"
set  ARGS=%ARGS% -joint_stereo  "1"
set  ARGS=%ARGS% -abr           "0"
set  ARGS=%ARGS% -b:a           "192k"
set  ARGS=%ARGS% -minrate:a     "192k"
set  ARGS=%ARGS% -maxrate:a     "192k"
set  ARGS=%ARGS% -bufsize:a     "256k"
set  ARGS=%ARGS% -ar            "44100"
::set  ARGS=%ARGS% -ar            "48000"

::set  ARGS=%ARGS% -af
::set  ARGS=%ARGS% "afifo
::set  ARGS=%ARGS%,asetpts=PTS-STARTPTS
::set  ARGS=%ARGS%,aselect=concatdec_select
::set  ARGS=%ARGS%,aresample=async=1:min_hard_comp=0.100000:first_pts=0
::set  ARGS=%ARGS%"

::---------------------------------------------- no metadata
::set  ARGS=%ARGS% -movflags "+faststart-use_metadata_tags"
::set  ARGS=%ARGS% -map_chapters   "-1"
::set  ARGS=%ARGS% -map_metadata   "-1"
::set  ARGS=%ARGS% -write_id3v1   "0"
::set  ARGS=%ARGS% -write_id3v2   "0"
::set  ARGS=%ARGS% -write_xing    "0"
::set  ARGS=%ARGS% -vn
::set  ARGS=%ARGS% -sn
::set  ARGS=%ARGS% -dn

::---------------------------------------------- with metadata
set  ARGS=%ARGS% -movflags "+faststart+use_metadata_tags"
set  ARGS=%ARGS% -copy_unknown
set  ARGS=%ARGS% -map_metadata  "0"
set  ARGS=%ARGS% -metadata "ENCODERSETTINGS="
set  ARGS=%ARGS% -write_id3v1   "0"
set  ARGS=%ARGS% -write_id3v2   "1"
set  ARGS=%ARGS% -id3v2_version "3"
set  ARGS=%ARGS% -write_xing    "0"
set  ARGS=%ARGS% -c:v copy
set  ARGS=%ARGS% -c:s copy
set  ARGS=%ARGS% -c:d copy



call "%FFMPEG%" %ARGS% "%OUTPUT%"
set "EXIT_CODE=%ErrorLevel%"
if ["%EXIT_CODE%"] NEQ ["0"] (
  echo [ERROR] could not encode.
  pause
  goto END
)

echo [INFO] succesfull encoding.


goto END

:END
echo [INFO] EXIT_CODE=%EXIT_CODE%"
popd
exit /b %EXIT_CODE%



