@echo off
setlocal EnableExtensions
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=amd64 >nul
cd /d "G:\~dev\rawrxd\build_win32ide_link001"
set LOG=G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\logs

REM Strip /showIncludes from saved cl lines to avoid pipe wedge
powershell -NoProfile -Command "(Get-Content '%LOG%\cl_deep2.txt' -Raw) -replace '/showIncludes','' | Set-Content '%LOG%\cl_deep2_noshow.txt' -NoNewline"
powershell -NoProfile -Command "(Get-Content '%LOG%\cl_win32ide.txt' -Raw) -replace '/showIncludes','' | Set-Content '%LOG%\cl_win32ide_noshow.txt' -NoNewline"

echo === CL Deep2Engine (noshow) ===
call "%LOG%\cl_deep2_noshow.txt"
if errorlevel 1 (
  REM file is one long command line; execute via cmd /c
  for /f "usebackq delims=" %%L in ("%LOG%\cl_deep2_noshow.txt") do cmd /c %%L
)
if errorlevel 1 exit /b 1

echo === CL Win32IDE (noshow) ===
for /f "usebackq delims=" %%L in ("%LOG%\cl_win32ide_noshow.txt") do cmd /c %%L
if errorlevel 1 exit /b 2

echo === LINK ===
for /f "usebackq delims=" %%L in ("%LOG%\link_exe.txt") do cmd /c %%L
if errorlevel 1 exit /b 3

echo SURGICAL_OK
powershell -NoProfile -Command "Get-FileHash 'G:\~dev\rawrxd\build_win32ide_link001\bin\RawrXD-Win32IDE.exe' -Algorithm SHA256 | %%{ $_.Hash }"
exit /b 0
