@echo off

set /a KBPS=128
set /a HZ=48000

set FILE_INPUT="%~s1"
set FILE_OUTPUT="%~d1%~p1%~n1.mp3"

ffmpeg -i %FILE_INPUT% -b:a %KBPS%k  -ar %HZ%  %FILE_OUTPUT%

::------------------------------------------------------------------------
exit

:: #######################################################################
:: # KBPS            # [2|40|48|56|64|80|96|112|128|160|192|224|256|320] #
:: # HZ              # [32000|44100|48000]                               #
:: # FILE_INPUT      # don't change                                      #
:: # FILE_OUTPUT     # don't change                                      #
:: #######################################################################
:: ###################################### Elad Karako May 28, 2016 00:53 #
:: #######################################################################

:: 4 CPU-cores -> 8 threads - better leave ffmpeg set it's own number.
::set /a THREADS=%NUMBER_OF_PROCESSORS% * 2
::ffmpeg -threads:0 %THREADS%  -i %FILE_INPUT% -b:a %KBPS%k  -ar %HZ%  %FILE_OUTPUT%