# FULL_SHELL_PERSIST_CYCLE_001

## Gate
Prove FULL user shellMode persistence cycle WITHOUT manual session seed of work:
UI enter Work Mode → clean exit → full kill → same-cand relaunch restores Work Mode.

## Method (unseeded)
1. Baseline session.json `shellMode=command` (explicit anti-seed; NOT work)
2. Launch cand `4A10F3F4…` TIP_CANDIDATE_AGENT_RUN_005/bin
3. Wait MainMenuReady; confirm NOT already Work
4. UI `WM_COMMAND IDM_CMD_ENTER_WORK=12520` (Ctrl+Shift+W product path)
5. Wait Work chrome/title; session shellMode=work via persistShellModeOnly
6. Clean WM_CLOSE; confirm process dead; session remains work
7. Relaunch SAME EXE with NO session rewrite
8. Prove Work Mode restored (title/chrome + session=work)
9. Optional reverse: IDM_CMD_ENTER_COMMAND → save → kill → relaunch → Command/Desktop

## Result
- DISPOSITION=RUNTIME_PASS_WITH_REVERSE
- FULL_PERSISTENCE_CYCLE=1
- RESTORE_PASS=1
- REVERSE_PASS=1 (RUNTIME_PASS)
- PHASE1_PRE_TITLE=RawrXD ScreenPilot â€” Desktop Preview
- PHASE1_POST_WORK_TITLE=RawrXD IDE â€” Work Mode
- PHASE2_RESTORE_TITLE=RawrXD IDE â€” Work Mode
- PHASE2_CHROME_WORK=True
- PHASE2_TITLE_SAW_WORK=True
- PHASE3_TITLE=RawrXD ScreenPilot â€” Desktop Preview
- PHASE3_CHROME_WORK=False
- PHASE3_SAW_DESKTOP=True
- SESSION_UNSEED=command
- SESSION_AFTER_UI_WORK=work
- SESSION_AFTER_EXIT=work
- SESSION_POST_RELAUNCH=work
- SESSION_REVERSE_FINAL=command
- CAND_SHA=4A10F3F40D3A5FF08E475671C8BF87AA8E5C79D68E405CA3027DA5FCCB53104B
- TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
- tip748B=1
- PROMOTE=0
- CERTIFIED=0
- INVENT_SHELL_MODE_PASS=0
- SEEDED_WORK=0
- AUTHORIZE_CANDIDATE_ONLY=1

## Fail-closed
SOURCE_WIRED != RUNTIME != PASS. NOT_RUN != PASS. Invent PASS forbidden.
