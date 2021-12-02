@echo off
echo I am the runner

for %%e in (*.mp4 *.flv *.flac *.m4a *.mkv) do (
    ::parallel diffrent process. and continue.
    start /low "cmd /c "call _file_encoder.cmd "%%e"""
)