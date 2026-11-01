# BREAKPOINT_FOLLOWON_D252_001 — RECEIPT

```
RUN_ID=BPFOLLOW_20261031T001629
ASOF_UTC=2026-10-31T04:52:00Z
DISPOSITION=BREAKPOINT_FOLLOWON_FAIL_CLOSED
EXIT=1
CAND_SHA_LIVE=8F5E7A1EE74EB4595A847507BBC830CC1DC6344FDD060EFEC698DF6DA9C74F66
CAND_PRIOR_D252=D252A344B5D9ABECF402E2E927A18F2DB06909CE773B587F6B5AABD61BAD25E2
TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
tip748B=1
PROMOTE=0 ABSORB=NOT_AUTHORIZED TIP_CLIMB=HOLD CERTIFIED=0
```

## What was found

| Step | Evidence |
|------|----------|
| TRACE on D252 | `IDM_DBG_LIST_BPS` (5170) → `EXIT=0xC0000409` after MenuReady+ping (`logs` first harness) |
| Pattern | Same class as sealed DBGWATCH_SHOW: debugger UI path without safe HWND / fail-closed gate |
| Product owner | `RawrXD_UI_ListBreakpointsAndShowPanel` / `BreakpointManagerPanel::Create` (legacy `createDebuggerUI` never called) |

## What was fixed (source)

| File | Change |
|------|--------|
| `Win32IDE_BreakpointManagerUI.cpp` | Show/Sync/List fail-closed ODS; no Create/ShowWindow; List returns `"[]"` |
| `Win32IDE_NativeDebugPanel.cpp` | `cmdDbgListBPs` ODS-only (no appendToOutput / panel) |
| `BreakpointManagerPanel.cpp` | Safe `GetClassInfoExW` registration (no clobber before `RegisterClassExW`) |
| `Win32IDE_Commands.cpp` | Temporary Tools-switch intercept **REVERTED** (stub-flag Commands relink poisoned all WM_COMMAND) |

## What ran / disposition

| Cell | Result | Note |
|------|--------|------|
| First D252 LIST_BPS exercise | **KILLER proven** | `C0000409` — real follow-on gap |
| Fail-closed source wire | LANDED | strings present in later cands |
| GUI_SURVIVAL re-prove of fix | **NOT PASS** | cand rebuild churn; Commands.obj poison; host later `C0000374` even on pinned `2F37` pre-post |
| tip748B | PASS / UNTOUCHED | |
| CERTIFIED | unchanged 0 | |

## Explicit non-claims

```
FAIL_CLOSED_SOURCE != GUI_SURVIVAL_PASS
GUI_SURVIVAL_PASS != invent BP panel PRODUCT_PASS
SOURCE_WIRED != RUNTIME_REACHED != PERFORMANCE_PASS
NOT_RUN != PASS
PROMOTE=0
```

## NEXT

`NEXT_PRIORITY=AWAITING_AUTH_OR_CAPABLE_HOST`
(restore capable host + D252-era Commands.obj / clean cand command path, then re-exercise SHOW→LIST)
`NEXT_GATE=POST_SCHEDULER_PROMOTION_REQUIREMENTS`
