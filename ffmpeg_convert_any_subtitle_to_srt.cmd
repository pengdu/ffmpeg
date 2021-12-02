  @echo off
  chcp 65001          2>nul >nul

:LOOP
  if ["%~1"] EQU [""] ( goto END  )
  if not exist %~s1   ( goto NEXT ) 
  if exist %~s1\NUL   ( goto NEXT )
::---------------------------------------------------------------------------------------------

  set "FILE_INPUT=%~s1"
  set "FILE_OUTPUT=%~sdp1%~n1.srt"

  call ffmpeg.exe -y -hide_banner -loglevel "info" -strict "experimental" -threads "16" -i "%FILE_INPUT%" "%FILE_OUTPUT%"

  echo.
  echo.

::---------------------------------------------------------------------------------------------
:NEXT
  shift
  goto LOOP

:END
  pause
