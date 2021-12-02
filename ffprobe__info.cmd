@echo off
chcp 65001          2>nul >nul

@echo on
call ffprobe.exe -hide_banner -loglevel "info" -strict "experimental" -i "%~f1"
@echo off

pause