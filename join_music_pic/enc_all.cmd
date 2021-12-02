@echo off
echo I am the runner

for %%e in (*.mp3) do (
    start /low "cmd /c "call enc.cmd "%%e" "img.png"""
)
