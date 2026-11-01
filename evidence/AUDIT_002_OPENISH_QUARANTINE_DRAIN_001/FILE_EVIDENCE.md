# AUDIT_002_OPENISH_QUARANTINE_DRAIN_001 — FILE_EVIDENCE

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
QUARANTINE_INVENT_EMPTY=1
ABSORB=NOT_AUTHORIZED
DUAL_COUNT_CAVEAT=1
  OPENISH_-1 and QUARANTINE_-1 = same one classification (not 2)
ASOF_UTC=2026-10-30T16:27:53Z
```

## Selection (invent-eligible after GHOSTTEXT residual QUARANTINE=3)

Enumerated 3 QUARANTINE residual. Invent-eligible empty-true/fake-ready = **1**
(`SHORT_BATCH=1`; <9). Remaining 2 — honest fail-closed stubs (no invent theater;
no SOURCE_WIRE edits).

| # | Path | Prior class | After class | Surface gated | Implementation (actual) | Missing dependency / gap |
|--:|------|-------------|-------------|---------------|-------------------------|--------------------------|
| 1 | `src/win32app/HeadlessIDE_quarantine.cpp` | QUARANTINE | GATED_FICTION | `initialize(HeadlessConfig)` | Quarantine TU retained; Initialize→`error` + FEATURE_FICTION mark | Real HeadlessIDE.cpp optional adapter (`OPTIONAL_CLOUD=ON`) |
| 2 | `src/win32app/Win32IDE_ChatPanel_Ollama_quarantine.cpp` | QUARANTINE | QUARANTINE | *(none — already FC)* | Warning LOCAL_ONLY; init no-op; models caller-owned | Real `Win32IDE_ChatPanel_Ollama.cpp` (`OPTIONAL_OLLAMA=ON`) |
| 3 | `src/win32app/Win32IDE_MarketplacePanel_quarantine.cpp` | QUARANTINE | QUARANTINE | *(none — already FC)* | init no-op; handle→false; show empty | Real marketplace panel (`OPTIONAL_CLOUD=ON`) |

## Source-gate presence (spot-check)

| Path | `DRAIN_001` mark | `FEATURE_FICTION=1 FAIL_CLOSED` hits |
|------|:----------------:|------------------------------------:|
| HeadlessIDE_quarantine.cpp | 1 | ≥2 |
| Win32IDE_ChatPanel_Ollama_quarantine.cpp | 0 (no invent) | 0 |
| Win32IDE_MarketplacePanel_quarantine.cpp | 0 (no invent) | 0 |

## Regression — prior invent gates (not re-touched)

| Path | FAIL_CLOSED / residual | Status |
|------|------------------------|--------|
| Win32IDE_SidebarPanels.cpp (UI_002) | FEATURE_FICTION present | OK |
| Win32IDE_DownloadsPanel.cpp (UI_001) | FEATURE_FICTION present | OK |
| Win32IDE_ExtensionToggles.cpp (EXT_002) | FEATURE_FICTION present | OK |
| ExtensionEngine.asm (EXT_001) | FEATURE_FICTION present | OK |
| Win32IDE_DebugWatchFormat.cpp (DBG_001) | FEATURE_FICTION present | OK |
| ghost_completion_parse.cpp (GT_001) | FEATURE_FICTION present | OK |
| GhostTextContextSubscriber.cpp (GT_001) | FEATURE_FICTION present | OK |
| QuickWin_GhostText.asm (GT_001) | FEATURE_FICTION present | OK |
| OTHER / EXTENSION / UI_PANEL / DEBUGGER / GHOSTTEXT invent-empty | counts 8/8/14/6/0 unchanged | OK |

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
| GATED_FICTION | 239 |
| BRIDGE_GATED | 14 |
| OTHER | 8 |
| EXTENSION | 8 |
| UI_PANEL | 14 |
| DEBUGGER | 6 |
| TEST | 22 |
| HEADLESS_ALT | 8 |
| GHOSTTEXT | 0 |
| QUARANTINE | 2 |
| STUB | 2 |
| **TOTAL** | **323** |

OPENISH family sum (OTHER+EXT+UI_PANEL+DEBUGGER+STUB+QUARANTINE+GHOSTTEXT) = **40**.
GATEDISH = 323 − 40 = **283**.

Seal counts (strict drain math; same one file): OPENISH 41→40 (−1); QUARANTINE 3→2 (−1); GATEDISH 282→283 (+1).
