@echo off
setlocal
call "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul
if not defined VULKAN_SDK set VULKAN_SDK=C:\VulkanSDK\1.4.357.0
set ROOT=G:\~dev\rawrxd
set OUT=%ROOT%\evidence\RAWRXD_PERFORMANCE_001\DUAL_GPU_CONCURRENT_AUTH_001
if not exist "%OUT%\obj" mkdir "%OUT%\obj"
cl /nologo /EHsc /std:c++17 /O2 /MD /I"%VULKAN_SDK%\Include" /I"%ROOT%\tools" ^
  /Fo"%OUT%\obj\\" /Fe"%OUT%\dual_gpu_concurrent_auth.exe" ^
  "%ROOT%\tools\dual_gpu_concurrent_auth.cpp" ^
  "%ROOT%\tools\dual_gpu_concurrent_lane.cpp" ^
  "%ROOT%\tools\dual_vk_probe_device.cpp" ^
  "%ROOT%\tools\dual_vk_probe_emit.cpp" ^
  /link /LIBPATH:"%VULKAN_SDK%\Lib" vulkan-1.lib
exit /b %ERRORLEVEL%
