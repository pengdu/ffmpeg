@echo off
ffmpeg -i "%~1" -map 0:s:0 "%~d1%~p1%~n1_subtitle.srt"