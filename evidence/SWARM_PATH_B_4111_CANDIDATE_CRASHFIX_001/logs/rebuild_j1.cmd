call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=amd64 >nul
cd /d "G:\~dev\rawrxd\build_win32ide_link001"
cmake --build . --target RawrXD-Win32IDE -j 1
echo BUILD_EXIT=%ERRORLEVEL%
