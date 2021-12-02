call ffmpeg -y -i "%~s1" -vf "select=\'eq\(n\,5\)\'" -vframes "1" "%~sdp1%~n1.png"
