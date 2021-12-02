@echo off

:loop
      ::-------------------------- has argument ?
      if ["%~1"]==[""] (
        echo done.
        goto end
      )
      ::-------------------------- argument exist ?
      if not exist %~s1 (
        echo not exist
      ) else (
        echo exist
        if exist %~s1\NUL (
          echo is a directory
        ) else (
          echo is a file
          set VIDEO="%~s1"
          set OUTPUT="%~d1%~p1%~n1_fixed.mp4"
          call D:\Software\ffmpeg\ffmpeg.exe -y -hide_banner -i "%VIDEO%" -profile:v "baseline" -level "3.0" -bt 50M -vf "mpdecimate,setpts=N/FRAME_RATE/TB" -preset veryslow -crf 21 -vsync 2 -async 1 -tune zerolatency -movflags "+faststart" -pix_fmt yuv420p "%OUTPUT%"
        )
      )
      ::--------------------------
      shift
      goto loop
      
      
:end

pause

::@echo off
::version #1 - single file
::set VIDEO="%~s1"
::set OUTPUT="%~d1%~p1%~n1_fixed.mp4"
::call D:\Software\ffmpeg\ffmpeg.exe -y -hide_banner -i "%VIDEO%" -profile:v "baseline" -level "3.0" -bt 50M -vf "mpdecimate,setpts=N/FRAME_RATE/TB" -preset veryslow -crf 21 -vsync 2 -async 1 -tune zerolatency -movflags "+faststart" -pix_fmt yuv420p "%OUTPUT%"