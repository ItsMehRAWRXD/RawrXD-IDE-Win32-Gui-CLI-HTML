# DEBUGGER_SHOW_CRASH_FIX_0C44_001 — RECEIPT

```
RUN_ID=DBGSHOW_20261031T000102
ASOF_UTC=2026-10-31T04:01:14Z
CAND_SHA=D252A344B5D9ABECF402E2E927A18F2DB06909CE773B587F6B5AABD61BAD25E2
CAND_PRIOR_7C16=7C1622A3…
CAND_PRIOR_0C44=0C44110A…
TIP_SHA=748B210A… tip748B=1
DISPOSITION=DBGWATCH_SHOW_FIX_PASS
EXIT=0
PROMOTE=0 ABSORB=NOT_AUTHORIZED TIP_CLIMB=HOLD CERTIFIED=0
```

## Root cause

`Win32IDE::handleDebugWatchCommand` (Tier5, IDM_DBGWATCH_SHOW=12230) previously
`ShowWindow`+`SetFocus` on `m_hwndDebuggerWatch` and/or `appendToOutput` with
`std::string`. `createDebuggerUI()` is never called on the product path, so the
watch HWND stayed null/stale. Live 0C44 repro after MenuReady+baseline ping:
process death with `EXIT=0xC0000409` (STATUS_STACK_BUFFER_OVERRUN).

## Fix

Fail-closed ODS-only path in `Win32IDE_Tier5Cosmetics.cpp` (no ShowWindow/SetFocus,
no appendToOutput, no invent Watch panel ready PASS). Relinked cand with 7C16
orphan set (TasksDebugUI + BreakpointManager + CallStack) + Tier5Cosmetics.obj.

## What ran

| Cell | Result | Note |
|------|--------|------|
| HASH_BIND | PASS | tip748B=1; new cand D252… |
| GUI_LAUNCH | PASS | MainWindow + MenuReady |
| GUI_BASELINE | PASS | ping OK before post |
| GUI_SURVIVAL | **PASS** | post 12230 ok=1 alive_after=1 ping=1 KILLER=NONE |
| TIP_UNTOUCHED | PASS | tip freeze intact |
| CERTIFIED_UNCHANGED | PASS | CERTIFIED stays 0 |

## Explicit non-claims

```
GUI_SURVIVAL_PASS != Watch panel PRODUCT_PASS
FEATURE_FICTION_FAIL_CLOSED != invent ready Watch UI
SOURCE_WIRED_FIX != CERTIFIED
PROMOTE=0
```

## Artifacts

- `solo_compile_relink.ps1` / `NEW_CAND_SHA.txt` / `PRE_HASH.txt`
- `harness_dbgwatch_show_fix.ps1`
- `SUMMARY.txt` / `LAW.txt` / `RETURN_LINE.txt`
- `logs/` (RUNLOG, fiction_cmd_posts, gui_meta, exe_sha)
