@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=amd64 >nul
cd /d "G:\~dev\rawrxd\build_win32ide_link001"
echo SURGICAL_START %DATE% %TIME%
ninja -j1 CMakeFiles/RawrXD-Win32IDE.dir/src/win32app/Win32IDE_Core.cpp.obj CMakeFiles/RawrXD-Win32IDE.dir/src/win32app/Win32IDE_SubAgent.cpp.obj CMakeFiles/RawrXD-Win32IDE.dir/src/win32app/Win32IDE_Tier3Polish.cpp.obj CMakeFiles/RawrXD-Win32IDE.dir/src/win32app/main_win32.cpp.obj
set RC1=%ERRORLEVEL%
echo SURGICAL_OBJS_EXIT=%RC1%
if not %RC1%==0 exit /b %RC1%
ninja -j1 bin/RawrXD-Win32IDE.exe
set RC2=%ERRORLEVEL%
echo SURGICAL_LINK_EXIT=%RC2%
if exist bin\RawrXD-Win32IDE.exe (
  powershell -NoProfile -Command "Get-FileHash 'G:\~dev\rawrxd\build_win32ide_link001\bin\RawrXD-Win32IDE.exe' -Algorithm SHA256 | %%{ $_.Hash }"
)
exit /b %RC2%
