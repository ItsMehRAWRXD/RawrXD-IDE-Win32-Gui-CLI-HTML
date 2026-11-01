@echo off
setlocal
mkdir "G:\~dev\rawrxd\evidence\WIN32IDE_CONTINUOUS_COMPLETION_002\K2_338E_OR_SCOPE_EXCEPTION_001\logs" 2>nul
cd /d "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin"
set LOCAL_ONLY=1
set RAWRXD_HEADLESS=1
set RAWRXD_DEEP2_ALLOW_ELASTIC=1
set K2_MODEL=F:\OllamaModels\Kimi-K2-Instruct-0905-GGUF\Q4_K_M\Kimi-K2-Instruct-0905-Q4_K_M-00001-of-00013.gguf
set SEAL=G:\~dev\rawrxd\evidence\WIN32IDE_CONTINUOUS_COMPLETION_002\K2_338E_OR_SCOPE_EXCEPTION_001
echo START_UTC=%DATE% %TIME%> "%SEAL%\run_meta_partial.txt"
echo RUN_ID=K2_338E_001>> "%SEAL%\run_meta_partial.txt"
echo MODEL=%K2_MODEL%>> "%SEAL%\run_meta_partial.txt"
echo MAX_TOKENS_CLI=64>> "%SEAL%\run_meta_partial.txt"
echo EXPECTED_EXE_SHA=338ED81546989D731B687DB7FA07BC7C121D8328A4226739DF46254EBFDE801F>> "%SEAL%\run_meta_partial.txt"
echo FAMILY=kimi_k2_instruct_0905>> "%SEAL%\run_meta_partial.txt"
echo QUANT=Q4_K_M>> "%SEAL%\run_meta_partial.txt"
echo SMALLER_QUANT_AVAILABLE=0>> "%SEAL%\run_meta_partial.txt"
echo ELASTIC=RAWRXD_DEEP2_ALLOW_ELASTIC>> "%SEAL%\run_meta_partial.txt"
echo PROVENANCE=TIP_CANDIDATE_AGENT_RUN_005>> "%SEAL%\run_meta_partial.txt"
echo TIP_ABSORB=0>> "%SEAL%\run_meta_partial.txt"
echo PROMOTE=0>> "%SEAL%\run_meta_partial.txt"
echo SCOPE_EXCEPTION_AUTHORIZED=0>> "%SEAL%\run_meta_partial.txt"
RawrXD-Win32IDE.exe --headless --local --no-server --model "%K2_MODEL%" --prompt "Say hi in one word." --max-tokens 64 --backend local --verbose > "%SEAL%\logs\raw_stdout.log" 2> "%SEAL%\logs\raw_stderr.log"
echo EXITLEVEL=%ERRORLEVEL%>> "%SEAL%\run_meta_partial.txt"
echo END_UTC=%DATE% %TIME%>> "%SEAL%\run_meta_partial.txt"
echo DONE
endlocal
