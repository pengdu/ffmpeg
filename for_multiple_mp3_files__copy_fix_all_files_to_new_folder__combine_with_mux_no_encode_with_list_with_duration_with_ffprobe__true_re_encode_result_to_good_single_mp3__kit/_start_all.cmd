@echo off
echo I am the runner
for %%e in (*.mp3 *.acc *.m4a) do (
  start /low "cmd /c "call _file.cmd "%%e"""
)
