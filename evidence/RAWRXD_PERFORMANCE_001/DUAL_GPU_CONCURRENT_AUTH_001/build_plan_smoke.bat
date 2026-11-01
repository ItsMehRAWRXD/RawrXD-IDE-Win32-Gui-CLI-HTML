@echo off
setlocal
call "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul
set ROOT=G:\~dev\rawrxd
set OUT=%ROOT%\evidence\RAWRXD_PERFORMANCE_001\DUAL_GPU_CONCURRENT_AUTH_001
set ML64=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\ml64.exe
if not exist "%OUT%\obj" mkdir "%OUT%\obj"
"%ML64%" /nologo /c /Fo"%OUT%\obj\Deep2Device_Score.obj" "%ROOT%\src\asm\Deep2Device_Score.asm"
"%ML64%" /nologo /c /Fo"%OUT%\obj\Deep2Device_Pick.obj" "%ROOT%\src\asm\Deep2Device_Pick.asm"
cl /nologo /EHsc /std:c++17 /O2 /MD /I"%ROOT%\src\deep2" /Fo"%OUT%\obj\\" ^
  /Fe"%OUT%\dual_lane_plan_smoke.exe" ^
  "%OUT%\dual_lane_plan_smoke.cpp" ^
  "%ROOT%\src\deep2\Deep2DeviceManager.cpp" ^
  "%OUT%\obj\Deep2Device_Score.obj" "%OUT%\obj\Deep2Device_Pick.obj" ^
  /link dxgi.lib
exit /b %ERRORLEVEL%
