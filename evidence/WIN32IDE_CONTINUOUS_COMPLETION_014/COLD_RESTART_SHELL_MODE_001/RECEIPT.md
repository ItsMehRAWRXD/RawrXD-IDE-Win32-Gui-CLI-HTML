# COLD_RESTART_SHELL_MODE_001

## Gate
Prove session `shellMode=work` survives full process kill + same-candidate relaunch
(title/chrome = Work Mode, not Desktop Preview).

## Method
1. Seed `%APPDATA%\RawrXD\session.json` `shellMode=work`
2. Confirm no RawrXD-Win32IDE process
3. Launch cand `4E4345C2…` from TIP_CANDIDATE_AGENT_RUN_005/bin
4. Wait MainMenuReady; dump HWND title + children
5. Classify: TITLE_AT_MENU Work Mode and/or work chrome (Toolbar+Sidebar+Editor);
   session post=work; Desktop Preview after menu without work signal = FAIL

## Result
- DISPOSITION=RUNTIME_PASS
- COLD_RESTART_PASS=1
- TITLE_AT_MENU=RawrXD IDE â€” Work Mode
- TITLE_FINAL=RawrXD IDE
- TITLE_SAW_WORK=True
- CHROME_WORK=True (toolbar=True sidebar=True editor=True)
- MENU_READY=True
- SESSION_SEED=work
- SESSION_POST_LAUNCH=work
- CAND_SHA=4E4345C2F41F2A3FF34877EB68DE37257C0C0CFFCA0364CB0F4481643BC76106
- TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
- tip748B=1
- PROMOTE=0
- CERTIFIED=0
- INVENT_SHELL_MODE_PASS=0
- NOTE=updateSaveStatusIndicator may strip Work Mode suffix after chrome apply
- PATHB_N2_EXT=NOT_REQUISITE_FOR_THIS_GATE (prior COMPLETION_013 sealed)

## Fail-closed
SOURCE_WIRED != RUNTIME != PASS. NOT_RUN != PASS.
