set "FFMPEG=%~sdp0ffmpeg.exe"

pushd "%~dp1"

%FFMPEG% -y -i "%~1" -preset ultrafast -an -vf "setpts=PTS-STARTPTS,vidstabdetect=result=%~sn1_stabilizer_data.trf"   -f null  nul
%FFMPEG% -y -i "%~1" -preset ultrafast     -vf "setpts=PTS-STARTPTS,vidstabtransform=input=%~sn1_stabilizer_data.trf" "%~dpn1__stabilized%~x1"

::---------------------------------------------------------------------------------------
::advance features (slower), in additional, the use of the 'unsharp' filter.
::  https://ffmpeg.org/ffmpeg-filters.html#toc-vidstabdetect-1
::  https://ffmpeg.org/ffmpeg-filters.html#toc-vidstabtransform-1
::ffmpeg -y -i "%~1" -to "00:10:00.000" -an -vf "setpts=PTS-STARTPTS,vidstabdetect=result=transforms.trf:shakiness=3:accuracy=10:stepsize=12:mincontrast=0.5:show=0"   -f null  nul
::ffmpeg -y -i "%~1" -to "00:10:00.000" -an -vf "setpts=PTS-STARTPTS,vidstabtransform=input=transforms.trf:smoothing=20:optalgo=gauss:maxshift=-1:maxangle=-1:crop=black:interpol=bicubic:zoom=5,unsharp=5:5:0.8:3:3:0.4" out.mkv


pause
popd
exit /b 0