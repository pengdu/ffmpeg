::@echo off
chcp 65001 2>nul >nul

ffmpeg -y  -hide_banner -loglevel "info"  -stats  -threads "1"  -strict "experimental" -i "%~s1" -af "volumedetect" -f "null"   nul

echo.
echo look above for the max volume, and double the value with -1.
echo for example if it is -5.3 your value should be 5.3  .
echo to normalize the volume to zero, run the command:
echo ffmpeg -i "%~1" -af "volume=5.3dB" "%~dpn1%_fixed%~x1%
echo.

set /p "VOLUME_LEVEL=Change Volume-Level (for example 2.0 for 200% or 5.3dB for specific-level)?  "

pause

if ["%VOLUME_LEVEL%"] EQU [""] ( goto EMPTY )


ffmpeg -y -hide_banner -i "%~s1" -filter:a "afifo,asetpts=PTS-STARTPTS,volume=%VOLUME_LEVEL%" -vn -sn volumechage.ogg


:EMPTY
  echo you need to enter a volume level.
  goto END

:END
  pause



::@echo.%FILE_INPUT%