@echo off
setlocal EnableExtensions
set EVID=G:\~dev\rawrxd\evidence\PHASE3_FAMILY_QWEN_001
set FREEZE=%~1
if "%FREEZE%"=="" set FREEZE=G:\~dev\rawrxd\evidence\TIP_FREEZE_PHASE3_001
if not exist "%FREEZE%\resolve_tip_exe.ps1" (
  echo DISPOSITION=FAIL_CLOSED_NO_FREEZE_DIR> "%EVID%\RECEIPT.txt"
  exit /b 2
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%FREEZE%\resolve_tip_exe.ps1" > "%EVID%\resolve.txt" 2>&1
if errorlevel 1 (echo DISPOSITION=FAIL_CLOSED_SHA> "%EVID%\RECEIPT.txt" & exit /b 3)
cd /d "%FREEZE%\bin"
set LOCAL_ONLY=1
set RAWRXD_HEADLESS=1
set MODEL=F:\models\gguf\library__qwen2.5-coder__1.5b-base.gguf
if not exist "%MODEL%" (
  echo DISPOSITION=FAIL_CLOSED_MISSING> "%EVID%\RECEIPT.txt"
  echo MODEL_MISSING=%MODEL%>> "%EVID%\RECEIPT.txt"
  exit /b 4
)
echo START_UTC=%DATE% %TIME%> "%EVID%\run_meta.txt"
echo MODEL=%MODEL%>> "%EVID%\run_meta.txt"
echo FAMILY=qwen25_coder_1p5b_dense>> "%EVID%\run_meta.txt"
echo MAX_TOKENS=16>> "%EVID%\run_meta.txt"
RawrXD-Win32IDE.exe --headless --local --no-server --model "%MODEL%" --prompt "Say hi in one word." --max-tokens 16 --backend local --verbose > "%EVID%\raw_stdout.log" 2> "%EVID%\raw_stderr.log"
echo EXITLEVEL=%ERRORLEVEL%>> "%EVID%\run_meta.txt"
powershell -NoProfile -ExecutionPolicy Bypass -File "%FREEZE%\resolve_tip_exe.ps1" >> "%EVID%\resolve.txt" 2>&1
echo END_UTC=%DATE% %TIME%>> "%EVID%\run_meta.txt"
echo DONE
endlocal
