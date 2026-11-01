# AUDIT_002_OPENISH_DEBUGGER_DRAIN_001 — FILE_EVIDENCE

```
QUALITY_BAR=1
tip748B=1
STOPPED_SUPERSEDED=1
TIP_REBUILD=0
RUNTIME_REACHED=NOT_RUN
PROMOTE=0
TIP_CLIMB=HOLD
CERTIFIED=0
PERFECT=0
SHORT_BATCH=1
DEBUGGER_INVENT_EMPTY=1
DUAL_COUNT_CAVEAT=1
  OPENISH_-3 and DEBUGGER_-3 = same three classifications (not 6)
ASOF_UTC=2026-10-30T16:09:30Z
```

## Selection (invent-eligible after UI_PANEL_002 residual DEBUGGER=9)

Enumerated 9 DEBUGGER residual. Invent-eligible empty-true/fake-ready = **3**
(`SHORT_BATCH=1`; <9). Remaining 6 adjudicated real/partial — invent theater empty.

| # | Path | Prior class | After class | Surface gated | Implementation (actual) | Missing dependency / gap |
|--:|------|-------------|-------------|---------------|-------------------------|--------------------------|
| 1 | `src/win32app/Win32IDE_DebugWatchFormat.cpp` | DEBUGGER | GATED_FICTION | `cmdDbgWatchAdd` | Format visualizers retained; sample seed removed + FAIL_CLOSED log | Real DAP/engine watch add I/O |
| 2 | `src/win32app/BreakpointPropertiesDialog.cpp` | DEBUGGER | GATED_FICTION | `Show` | DialogProc template retained unused; Show returns false + FAIL_CLOSED | Real DialogBox / .rc props dialog |
| 3 | `src/win32app/Win32IDE_DAPServer.cpp` | DEBUGGER | GATED_FICTION | invent DAP handlers | Real TCP `startServer` retained; invent responses FAIL_CLOSED | Real debugger-engine verify/stack/vars/attach |

## Source-gate presence (spot-check)

| Path | `DRAIN_001` mark | `FEATURE_FICTION=1 FAIL_CLOSED` hits |
|------|:----------------:|------------------------------------:|
| Win32IDE_DebugWatchFormat.cpp | 1 | ≥2 |
| BreakpointPropertiesDialog.cpp | 1 | ≥2 |
| Win32IDE_DAPServer.cpp | 1 | ≥11 |

## Regression — OTHER / EXTENSION / UI_PANEL invent gates (not re-touched)

| Path | FAIL_CLOSED / residual | Status |
|------|------------------------|--------|
| Win32IDE_SidebarPanels.cpp (UI_002) | FEATURE_FICTION present | OK |
| Win32IDE_DownloadsPanel.cpp (UI_001) | FEATURE_FICTION present | OK |
| Win32IDE_ExtensionToggles.cpp (EXT_002) | FEATURE_FICTION present | OK |
| ExtensionEngine.asm (EXT_001) | FEATURE_FICTION present | OK |
| OTHER / EXTENSION / UI_PANEL invent-empty | counts 8/8/14 unchanged | OK |
| Residual DEBUGGER 6 | no DRAIN_001 mark | OK |

## Tip authority (no rebuild)

```
EXE=G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe
LIVE_SHA256=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
tip748B=1 MATCH
TIP_REBUILD=0 ABSORB=NOT_AUTHORIZED
STOPPED_SUPERSEDED=1
```

## Ledger reconcile (adjudicated inventory TOTAL=323)

| Bucket | N |
|--------|--:|
| GATED_FICTION | 235 |
| BRIDGE_GATED | 14 |
| OTHER | 8 |
| EXTENSION | 8 |
| UI_PANEL | 14 |
| DEBUGGER | 6 |
| TEST | 22 |
| HEADLESS_ALT | 8 |
| GHOSTTEXT | 3 |
| QUARANTINE | 3 |
| STUB | 2 |
| **TOTAL** | **323** |

OPENISH family sum (OTHER+EXT+UI_PANEL+DEBUGGER+STUB+QUARANTINE+GHOSTTEXT) = **44**.
GATEDISH = 323 − 44 = **279**.

Seal counts (strict drain math; same three files): OPENISH 47→44 (−3); DEBUGGER 9→6 (−3); GATEDISH 276→279 (+3).
`DUAL_COUNT_CAVEAT`: do not count OPENISH Δ and DEBUGGER Δ as six resolutions.

## Explicit non-claims

```
SOURCE_WIRED != RUNTIME_REACHED != PASS
NOT_RUN != PASS
three_file_gate != three_runtime_components
OPENISH_DEBUGGER_dual_delta != six_resolutions
DEBUGGER_INVENT_EMPTY != OPENISH_EMPTY != PERFECT
PROMOTE=0 PERFECT=0 CERTIFIED=0
```
