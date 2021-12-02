@echo off

  chcp 65001          2>nul >nul
  mkdir "%~sdp1fixed" 2>nul >nul

:LOOP
  if ["%~1"]==[""]  ( echo Done.           &  goto END   )
  if not exist %~s1 ( echo Not exist.      &  goto NEXT  )
  if exist %~s1\NUL ( echo Is a directory. &  goto NEXT  )
::---------------------------------------------------------------------------------------------

  set "EXIT_CODE=0"

  title %~nx1

  set "FILE_INPUT=%~s1"
  set "FILE_OUTPUT=%~sdp1fixed\%~nx1"

  set "ARGS="

::MUX flags
  set ARGS=%ARGS% -flags                    "-output_corrupt"
  set ARGS=%ARGS% -fflags                   "+genpts-autobsf-discardcorrupt-fastseek-nofillin-ignidx-igndts"

::~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  set ARGS=%ARGS% -i                        "%FILE_INPUT%"
::~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  set ARGS=%ARGS% -c:v "copy"
  set ARGS=%ARGS% -c:a "copy"
  set ARGS=%ARGS% -sn

  set ARGS=%ARGS% -map_chapters "-1"
  set ARGS=%ARGS% -map_metadata "-1"

  echo.
  echo.
  @echo on
  call ffmpeg.exe -y -hide_banner -loglevel "info" -strict "experimental" -threads "16" %ARGS% "%FILE_OUTPUT%"
  set "EXIT_CODE=%ErrorLevel%"
  @echo off
  echo.
  echo.

::---------------------------------------------------------------------------------------------
:NEXT
  shift
  goto LOOP

:END
  pause
  exit /b %EXIT_CODE%
