@echo off
chcp 65001 2>nul >nul

::reset
set "FILE_INPUT="
set "FILE_OUTPUT="
set "ACTION="
set "FILTER="
set "VERBOSE="


set "FILE_INPUT=%~sdp1%~nx1"
for /f %%a in ("%FILE_INPUT%")do (set "FILE_INPUT=%%~fsa"  )


echo.
echo Rotate 90
echo [0] cclock_flip90  --- 90 degrees left + vertical-flip (default).
echo [1] clock90        --- 90 degrees right.
echo [2] cclock90       --- 90 degrees left.
echo [3] clock_flip90   --- 90 degrees right + vertical-flip (up-down).
echo.
echo Rotate 180
echo [00] cclock_flip180 --- 180 degrees left + vertical-flip (up-down).
echo [11] clock180       --- 180 degrees right.
echo [22] cclock180      --- 180 degrees left.
echo [33] clock_flip180  --- 180 degrees right + vertical-flip (up-down).
echo.
set /p "ACTION=Enter Your Choice: [0] "


::90
if ["%ACTION%"] EQU ["0"] ( set "FILTER=transpose=cclock_flip"
                            set "VERBOSE=0_cclock_flip90"        )
if ["%ACTION%"] EQU ["1"] ( set "FILTER=transpose=clock"
                            set "VERBOSE=1_clock90"              )
if ["%ACTION%"] EQU ["2"] ( set "FILTER=transpose=cclock"
                            set "VERBOSE=2_cclock90"             )
if ["%ACTION%"] EQU ["3"] ( set "FILTER=transpose=clock_flip"
                            set "VERBOSE=3_clock_flip90"         )

::180
if ["%ACTION%"] EQU ["00"] ( set "FILTER=transpose=cclock_flip,transpose=cclock_flip"
                             set "VERBOSE=00_clock_flip180"                              )
if ["%ACTION%"] EQU ["11"] ( set "FILTER=transpose=clock,transpose=clock"
                             set "VERBOSE=11_clock180"                                   )
if ["%ACTION%"] EQU ["22"] ( set "FILTER=transpose=cclock,transpose=cclock"
                             set "VERBOSE=22_cclock180"                                  )
if ["%ACTION%"] EQU ["33"] ( set "FILTER=transpose=clock_flip,transpose=clock_flip"
                             set "VERBOSE=33_clock_flip180"                              )

::default
if ["%FILTER%"] EQU [""]  ( set "FILTER=transpose=cclock_flip"
                            set "VERBOSE=0_cclock_flip90"        )

set "FILE_OUTPUT=%~sdp1%~n1__rotated__%VERBOSE%_%~x1"


call "ffmpeg.exe" -hide_banner -y -i "%FILE_INPUT%" -vf "%FILTER%" "%FILE_OUTPUT%"

pause

::@echo.%FILE_INPUT%