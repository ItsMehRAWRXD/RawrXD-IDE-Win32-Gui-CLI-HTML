# AUDIT_002_OPENISH_DEBUGGER_DRAIN_001 — RECEIPT

```
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_SHA256=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
TIP_MATCH=1 TIP_REBUILD=0 ABSORB=NOT_AUTHORIZED
RUNTIME_REACHED=NOT_RUN
PARENT=AUDIT_002_OPENISH_UI_PANEL_DRAIN_002
PRIOR=AUDIT_002_OPENISH_UI_PANEL_DRAIN_002
ASOF_UTC=2026-10-30T16:09:30Z
SHORT_BATCH=1
OTHER_INVENT_EMPTY=1
EXTENSION_INVENT_EMPTY=1
UI_PANEL_INVENT_EMPTY=1
DEBUGGER_INVENT_EMPTY=1
STOPPED_SUPERSEDED=1
DUAL_COUNT_CAVEAT=1
```

## Verdict

Enumerated DEBUGGER residual (9). Gated 3 invent-eligible empty-true/fake-ready
sites SOURCE_WIRE FAIL_CLOSED (`cmdDbgWatchAdd` sample watches;
`BreakpointPropertiesDialog::Show` empty-true/fake EDIT; DAP invent response
handlers). OPENISH 47→44; DEBUGGER 9→6; GATEDISH 276→279; gated+3.
Remaining 6 residual invent-empty (real/partial). Tip 748B untouched MATCH.
PERFECT=0 — OPENISH residual + NOT_RUN ≠ PASS. No ninja/RELINK.
OTHER/EXTENSION/UI_PANEL invent-empty and invent gates not re-touched
(spot-check OK). `DEBUGGER_INVENT_EMPTY=1` ≠ OPENISH empty.
Ledger TOTAL_ORPHANS=323 reconciled (GATED_FICTION=235).

## Files touched (SOURCE_WIRE fail-close)

| Path | Change |
|------|--------|
| `src/win32app/Win32IDE_DebugWatchFormat.cpp` | invent sample watches → FAIL_CLOSED |
| `src/win32app/BreakpointPropertiesDialog.cpp` | invent Show empty-true/fake EDIT → FAIL_CLOSED |
| `src/win32app/Win32IDE_DAPServer.cpp` | invent DAP handlers → FAIL_CLOSED |

## Return

| DEBUGGER before | DEBUGGER after | OPENISH before | OPENISH after | gated+ | tip748B | RUNTIME | NEXT_GATE |
|----------------:|---------------:|---------------:|--------------:|-------:|:-------:|:--------:|-----------|
| **9** | **6** | **47** | **44** | **+3** | **1** | **NOT_RUN** | `DEBUGGER_INVENT_EMPTY` |
