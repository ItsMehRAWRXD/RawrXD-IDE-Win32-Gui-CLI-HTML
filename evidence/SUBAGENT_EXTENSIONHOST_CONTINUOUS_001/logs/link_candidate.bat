@echo off
cd /d G:\~dev\rawrxd\build_win32ide_link001
echo START=%DATE% %TIME%> "g:\~dev\rawrxd\evidence\SUBAGENT_EXTENSIONHOST_CONTINUOUS_001\logs\candidate_link_unblock.txt"
ninja -j2 RawrXD-Win32IDE >> "g:\~dev\rawrxd\evidence\SUBAGENT_EXTENSIONHOST_CONTINUOUS_001\logs\candidate_link_unblock.txt" 2>&1
echo EXIT=%ERRORLEVEL%>> "g:\~dev\rawrxd\evidence\SUBAGENT_EXTENSIONHOST_CONTINUOUS_001\logs\candidate_link_unblock.txt"
exit /b %ERRORLEVEL%
