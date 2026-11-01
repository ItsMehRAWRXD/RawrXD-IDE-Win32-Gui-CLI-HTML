# AUDIT_002_OPENISH_GHOSTTEXT_DRAIN_001 — RECEIPT

```
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_SHA256=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
TIP_MATCH=1 TIP_REBUILD=0 ABSORB=NOT_AUTHORIZED
RUNTIME_REACHED=NOT_RUN
PARENT=AUDIT_002_OPENISH_DEBUGGER_DRAIN_001
PRIOR=AUDIT_002_OPENISH_DEBUGGER_DRAIN_001
ASOF_UTC=2026-10-30T16:17:31Z
SHORT_BATCH=1
OTHER_INVENT_EMPTY=1
EXTENSION_INVENT_EMPTY=1
UI_PANEL_INVENT_EMPTY=1
DEBUGGER_INVENT_EMPTY=1
GHOSTTEXT_INVENT_EMPTY=1
STOPPED_SUPERSEDED=1
DUAL_COUNT_CAVEAT=1
```

## Verdict

Enumerated GHOSTTEXT residual (3). Gated 3 invent-eligible empty-true/fake-ready
sites SOURCE_WIRE FAIL_CLOSED (`GhostParser` Initialize/Create; prefetch invent
ShowSuggestion; QuickWin TAB accept / Insert / CompletionEngine trigger).
OPENISH 44→41; GHOSTTEXT 3→0; GATEDISH 279→282; gated+3.
Remaining 0 residual invent-empty. Tip 748B untouched MATCH.
PERFECT=0 — OPENISH residual + NOT_RUN ≠ PASS. No ninja/RELINK.
OTHER/EXTENSION/UI_PANEL/DEBUGGER invent-empty and invent gates not re-touched
(spot-check OK). `GHOSTTEXT_INVENT_EMPTY=1` ≠ OPENISH empty.
Ledger TOTAL_ORPHANS=323 reconciled (GATED_FICTION=238).

## Files touched (SOURCE_WIRE fail-close)

| Path | Change |
|------|--------|
| `src/win32app/ghost_completion_parse.cpp` | invent Init/Create → FAIL_CLOSED |
| `src/win32app/GhostTextContextSubscriber.cpp` | invent prefetch ShowSuggestion → FAIL_CLOSED |
| `src/win32app/QuickWin_GhostText.asm` | invent TAB accept/Insert/trigger → FAIL_CLOSED |

## Return

| GHOSTTEXT before | GHOSTTEXT after | OPENISH before | OPENISH after | gated+ | tip748B | RUNTIME | NEXT_GATE |
|-----------------:|----------------:|---------------:|--------------:|-------:|:-------:|:--------:|-----------|
| **3** | **0** | **44** | **41** | **+3** | **1** | **NOT_RUN** | `GHOSTTEXT_INVENT_EMPTY` |
