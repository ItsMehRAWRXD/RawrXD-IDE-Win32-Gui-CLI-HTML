@echo off
setlocal EnableExtensions
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul
if errorlevel 1 exit /b 91

set ROOT=G:\~dev\rawrxd
set BLD=%ROOT%\build_win32ide_link001
set SEAL=%ROOT%\evidence\TIP_CANDIDATE_RELINK_STUB_FAILFAST_001
set OBJDIR=%BLD%\CMakeFiles\RawrXD-Win32IDE.dir
set CL=cl.exe
set LOG=%SEAL%\logs\solo_compile_link.txt
if not exist "%SEAL%\logs" mkdir "%SEAL%\logs"

set /p DEFINES=<%SEAL%\cl_DEFINES.txt
set /p FLAGS=<%SEAL%\cl_FLAGS.txt
set /p INCLUDES=<%SEAL%\cl_INCLUDES.txt

cd /d "%BLD%"

echo === SOLO COMPILE START %DATE% %TIME% > "%LOG%"

REM --- FailFast heap + existing Win32IDE TUs ---
for %%F in (
  Win32IDE_Core.cpp
  Win32IDE_ChatPanel_Ollama.cpp
  Win32IDE_CommandSurface.cpp
  Win32IDE_FeatureManifest.cpp
  Win32IDE_TabManager.cpp
  Win32IDE_IRCBridge.cpp
  Win32IDE_VoiceChat.cpp
  ASM_Bridge_Implementation.cpp
  Win32IDE_FabricBridge.cpp
  Win32IDE_Phase17_AgenticProfiler.cpp
  Win32IDE_StubFictionCiteForce.cpp
) do (
  echo COMPILE win32app\%%F
  echo COMPILE win32app\%%F >> "%LOG%"
  if not exist "%OBJDIR%\src\win32app" mkdir "%OBJDIR%\src\win32app"
  %CL% /nologo /TP /c %FLAGS% %DEFINES% %INCLUDES% /Fo"%OBJDIR%\src\win32app\%%F.obj" "%ROOT%\src\win32app\%%F" >> "%LOG%" 2>&1
  if errorlevel 1 (
    echo FAIL %%F >> "%LOG%"
    echo FAIL %%F
    exit /b 1
  )
)

REM --- agentic orphans ---
if not exist "%OBJDIR%\src\agentic\vulkan" mkdir "%OBJDIR%\src\agentic\vulkan"
echo COMPILE VulkanManager.cpp
%CL% /nologo /TP /c %FLAGS% %DEFINES% %INCLUDES% /Fo"%OBJDIR%\src\agentic\vulkan\VulkanManager.cpp.obj" "%ROOT%\src\agentic\vulkan\VulkanManager.cpp" >> "%LOG%" 2>&1
if errorlevel 1 ( echo FAIL VulkanManager >> "%LOG%" & exit /b 2 )

if not exist "%OBJDIR%\src\agentic" mkdir "%OBJDIR%\src\agentic"
echo COMPILE agentic_tool_executor.cpp
%CL% /nologo /TP /c %FLAGS% %DEFINES% %INCLUDES% /I"%ROOT%\src\agentic" /Fo"%OBJDIR%\src\agentic\agentic_tool_executor.cpp.obj" "%ROOT%\src\agentic\agentic_tool_executor.cpp" >> "%LOG%" 2>&1
if errorlevel 1 ( echo FAIL tool_executor >> "%LOG%" & exit /b 3 )

echo COMPILE voice_chat.cpp
%CL% /nologo /TP /c %FLAGS% %DEFINES% %INCLUDES% /Fo"%OBJDIR%\src\core\voice_chat.cpp.obj" "%ROOT%\src\core\voice_chat.cpp" >> "%LOG%" 2>&1
if errorlevel 1 ( echo FAIL voice_chat >> "%LOG%" & exit /b 4 )

REM --- AgentHost (InferenceEngine lane flags) for G04/G05 header emit ---
set /p IE_DEFINES=<%SEAL%\cl_IE_DEFINES.txt
set /p IE_FLAGS=<%SEAL%\cl_IE_FLAGS.txt
set /p IE_INCLUDES=<%SEAL%\cl_IE_INCLUDES.txt
if not exist "%BLD%\CMakeFiles\InferenceEngine.dir\src\agentic" mkdir "%BLD%\CMakeFiles\InferenceEngine.dir\src\agentic"
echo COMPILE RawrXD_AgentHost.cpp
%CL% /nologo /TP /c %IE_FLAGS% %IE_DEFINES% %IE_INCLUDES% /I"%ROOT%\src\agentic" /Fo"%BLD%\CMakeFiles\InferenceEngine.dir\src\agentic\RawrXD_AgentHost.cpp.obj" "%ROOT%\src\agentic\RawrXD_AgentHost.cpp" >> "%LOG%" 2>&1
if errorlevel 1 ( echo FAIL AgentHost >> "%LOG%" & exit /b 5 )

REM --- Build rsp with orphan objs prepended ---
set RSP=%SEAL%\RawrXD-Win32IDE_relink.rsp
copy /Y "%BLD%\CMakeFiles\RawrXD-Win32IDE.rsp" "%RSP%" >nul
(
  echo CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\ASM_Bridge_Implementation.cpp.obj
  echo CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_FabricBridge.cpp.obj
  echo CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_Phase17_AgenticProfiler.cpp.obj
  echo CMakeFiles\RawrXD-Win32IDE.dir\src\win32app\Win32IDE_StubFictionCiteForce.cpp.obj
  echo CMakeFiles\RawrXD-Win32IDE.dir\src\agentic\vulkan\VulkanManager.cpp.obj
  echo CMakeFiles\RawrXD-Win32IDE.dir\src\agentic\agentic_tool_executor.cpp.obj
  echo CMakeFiles\InferenceEngine.dir\src\agentic\RawrXD_AgentHost.cpp.obj
) > "%SEAL%\orphan_objs.rsp"
copy /Y "%SEAL%\orphan_objs.rsp"+"%RSP%" "%SEAL%\RawrXD-Win32IDE_relink_merged.rsp" >nul

echo === SOLO LINK ===
echo === SOLO LINK === >> "%LOG%"
"C:\Program Files\CMake\bin\cmake.exe" -E vs_link_exe --msvc-ver=1944 --intdir=CMakeFiles\RawrXD-Win32IDE.dir --rc="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\rc.exe" --mt="C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\mt.exe" --manifests -- "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\link.exe" /nologo @"%SEAL%\RawrXD-Win32IDE_relink_merged.rsp" /out:bin\RawrXD-Win32IDE.exe /implib:RawrXD-Win32IDE.lib /pdb:bin\RawrXD-Win32IDE.pdb /version:0.0 /machine:x64 /INCREMENTAL:NO /subsystem:windows /LTCG /LARGEADDRESSAWARE /DEBUG:FULL /MAP:bin\RawrXD-Win32IDE_stubff.map /MAPINFO:EXPORTS /MANIFEST:NO /FORCE:MULTIPLE /STACK:4194304 >> "%LOG%" 2>&1
set RC=%ERRORLEVEL%
echo LINK_EXIT=%RC% >> "%LOG%"
echo LINK_EXIT=%RC%
exit /b %RC%
