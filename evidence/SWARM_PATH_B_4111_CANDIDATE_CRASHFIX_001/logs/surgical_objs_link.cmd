@echo off
setlocal EnableExtensions
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=amd64 >nul
cd /d "G:\~dev\rawrxd\build_win32ide_link001"
echo SURGICAL2_START %DATE% %TIME%
REM Compile only the four crashfix TUs — do NOT ask ninja for the .exe (that rebuilds the world).
ninja -j1 ^
  CMakeFiles/RawrXD-Win32IDE.dir/src/win32app/Win32IDE_Core.cpp.obj ^
  CMakeFiles/RawrXD-Win32IDE.dir/src/win32app/Win32IDE_SubAgent.cpp.obj ^
  CMakeFiles/RawrXD-Win32IDE.dir/src/win32app/Win32IDE_Tier3Polish.cpp.obj ^
  CMakeFiles/RawrXD-Win32IDE.dir/src/win32app/main_win32.cpp.obj
if errorlevel 1 (
  echo SURGICAL2_OBJS_FAIL=%ERRORLEVEL%
  exit /b 1
)
echo SURGICAL2_OBJS_OK
echo === LINK start %DATE% %TIME% ===
"C:\Program Files\CMake\bin\cmake.exe" -E rm -f "G:/~dev/rawrxd/build_win32ide_link001/bin/RawrXD-Win32IDE.exe" "G:/~dev/rawrxd/build_win32ide_link001/bin/RawrXD-Win32IDE.pdb"
"C:\Program Files\CMake\bin\cmake.exe" -E vs_link_exe --msvc-ver=1944 --intdir=CMakeFiles\RawrXD-Win32IDE.dir --rc="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\rc.exe" --mt="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\mt.exe" --manifests  -- "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\link.exe" /nologo @CMakeFiles\RawrXD-Win32IDE.rsp  /out:bin\RawrXD-Win32IDE.exe /implib:RawrXD-Win32IDE.lib /pdb:bin\RawrXD-Win32IDE.pdb /version:0.0 /machine:x64 /INCREMENTAL:NO /subsystem:windows /LTCG /LARGEADDRESSAWARE /DEBUG:FULL /MAP:G:/~dev/rawrxd/build_win32ide_link001/bin/RawrXD-Win32IDE.map /MAPINFO:EXPORTS /MANIFEST:NO /FORCE:MULTIPLE /STACK:4194304
set RC=%ERRORLEVEL%
echo === LINK end EXIT=%RC% ===
if exist "bin\RawrXD-Win32IDE.exe" (
  echo EXE_OK
  powershell -NoProfile -Command "(Get-FileHash 'G:\~dev\rawrxd\build_win32ide_link001\bin\RawrXD-Win32IDE.exe' -Algorithm SHA256).Hash"
) else (
  echo EXE_MISSING
)
exit /b %RC%
