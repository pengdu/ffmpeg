@echo off

echo.
echo anlz audio:
ffmpeg -y  -hide_banner -loglevel "info"  -stats  -threads "1"  -strict "experimental" -i "%~1" -af "volumedetect" -f "null"   nul

echo.
echo look above for the max volume, and double the value with -1.
echo for example if it is -5.3 your value should be 5.3  .
echo to normalize the volume to zero, run the command:
echo ffmpeg -i "%~1" -af "volume=5.3dB" "%~dpn1%_fixed%~x1%
echo.



pause