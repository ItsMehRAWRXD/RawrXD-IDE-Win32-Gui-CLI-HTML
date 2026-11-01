@echo off
setlocal
cd /d "G:\~dev\rawrxd\build_win32ide_link001\bin"
set LOCAL_ONLY=1
set RAWRXD_HEADLESS=1
echo START_UTC=%DATE% %TIME%> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_D41BB_001\TOKEN64\run_meta_partial.txt"
echo EXPECTED_EXE_SHA=D41BB1DBAAFC7B6AC9135EEA848F757EB0E3474B479DABED832296F69DE19F98>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_D41BB_001\TOKEN64\run_meta_partial.txt"
echo MODEL=G:\~dev\rawrxd\models\tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_D41BB_001\TOKEN64\run_meta_partial.txt"
echo MAX_TOKENS_CLI=64>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_D41BB_001\TOKEN64\run_meta_partial.txt"
echo PROVENANCE=build_win32ide_link001>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_D41BB_001\TOKEN64\run_meta_partial.txt"
echo EXE=G:\~dev\rawrxd\build_win32ide_link001\bin\RawrXD-Win32IDE.exe>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_D41BB_001\TOKEN64\run_meta_partial.txt"
echo TIP_ABSORB=0 >> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_D41BB_001\TOKEN64\run_meta_partial.txt"

RawrXD-Win32IDE.exe --headless --local --no-server --model G:\~dev\rawrxd\models\tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf --prompt "Write a short paragraph about why clear writing matters. Keep going until you have enough text." --max-tokens 64 --backend local --verbose > "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_D41BB_001\TOKEN64\raw_stdout.log" 2> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_D41BB_001\TOKEN64\raw_stderr.log"
echo EXITLEVEL=%ERRORLEVEL% >> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_D41BB_001\TOKEN64\run_meta_partial.txt"
echo END_UTC=%DATE% %TIME%>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_D41BB_001\TOKEN64\run_meta_partial.txt"
echo DONE
endlocal
