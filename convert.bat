FOR %%A IN (.\*.mp3) DO "C:\Program Files\ffmpeg\bin\ffmpeg.exe" -i "%%A" "%%~nA.ogg"

pause