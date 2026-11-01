@echo off
setlocal
cd /d "G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin"
set LOCAL_ONLY=1
set RAWRXD_HEADLESS=1
echo START_UTC=%DATE% %TIME%> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_FD07_001\TETRAD\run_meta_partial.txt"
echo EXPECTED_EXE_SHA=FD07CA615E35F04EBFE66EA583ABDE10BFDA56A08656E8B1A8ECA1B1C2851540>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_FD07_001\TETRAD\run_meta_partial.txt"
echo MODEL=G:\~dev\rawrxd\models\tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_FD07_001\TETRAD\run_meta_partial.txt"
echo MAX_TOKENS_CLI=16>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_FD07_001\TETRAD\run_meta_partial.txt"
echo PROVENANCE=TIP_CANDIDATE_AGENT_RUN_005>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_FD07_001\TETRAD\run_meta_partial.txt"
echo EXE=G:\~dev\rawrxd\evidence\TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_FD07_001\TETRAD\run_meta_partial.txt"
echo TIP_ABSORB=0>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_FD07_001\TETRAD\run_meta_partial.txt"
echo COPY_INTO_TIP=0>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_FD07_001\TETRAD\run_meta_partial.txt"

RawrXD-Win32IDE.exe --headless --local --no-server --model G:\~dev\rawrxd\models\tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf --prompt "Say hi in one word." --max-tokens 16 --backend local --verbose > "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_FD07_001\TETRAD\raw_stdout.log" 2> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_FD07_001\TETRAD\raw_stderr.log"
echo EXITLEVEL=%ERRORLEVEL%>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_FD07_001\TETRAD\run_meta_partial.txt"
echo END_UTC=%DATE% %TIME%>> "G:\~dev\rawrxd\evidence\PROMOTION_READINESS_FD07_001\TETRAD\run_meta_partial.txt"
echo DONE
endlocal
