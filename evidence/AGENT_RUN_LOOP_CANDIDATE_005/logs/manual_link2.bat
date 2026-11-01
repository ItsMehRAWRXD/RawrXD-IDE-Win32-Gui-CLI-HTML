@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul
cd /d "G:\~dev\rawrxd\build_win32ide_link001"
echo LINKING
link.exe /nologo @CMakeFiles\RawrXD-Win32IDE.rsp /out:bin\RawrXD-Win32IDE.exe /implib:RawrXD-Win32IDE.lib /pdb:bin\RawrXD-Win32IDE.pdb /version:0.0 /machine:x64 /INCREMENTAL:NO /subsystem:windows /LTCG /LARGEADDRESSAWARE /DEBUG:FULL /MAP:G:/~dev/rawrxd/build_win32ide_link001/bin/RawrXD-Win32IDE.map /MAPINFO:EXPORTS /MANIFEST:NO /FORCE:MULTIPLE /STACK:4194304
set LC=%ERRORLEVEL%
echo LINK_EXIT=%LC%
if exist bin\RawrXD-Win32IDE.map cmake.exe -E copy_if_different G:/~dev/rawrxd/build_win32ide_link001/bin/RawrXD-Win32IDE.map G:/~dev/rawrxd/build_win32ide_link001/RawrXD-Win32IDE.map
exit /b %LC%
