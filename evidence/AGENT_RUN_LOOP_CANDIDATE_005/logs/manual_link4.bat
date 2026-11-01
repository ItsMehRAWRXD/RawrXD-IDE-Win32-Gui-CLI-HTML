@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul
cd /d "G:\~dev\rawrxd\build_win32ide_link001"
if exist bin\RawrXD-Win32IDE.exe del /f /q bin\RawrXD-Win32IDE.exe
if exist bin\RawrXD-Win32IDE.pdb del /f /q bin\RawrXD-Win32IDE.pdb
echo LINKING_DEBUG_NONE
link.exe /nologo @CMakeFiles\RawrXD-Win32IDE.rsp /out:bin\RawrXD-Win32IDE.exe /implib:RawrXD-Win32IDE.lib /version:0.0 /machine:x64 /INCREMENTAL:NO /subsystem:windows /LARGEADDRESSAWARE /DEBUG:NONE /MANIFEST:NO /FORCE:MULTIPLE /STACK:4194304
echo LINK_EXIT=%ERRORLEVEL%
exit /b %ERRORLEVEL%

