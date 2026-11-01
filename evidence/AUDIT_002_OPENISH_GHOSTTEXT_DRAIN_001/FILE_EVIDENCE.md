# AUDIT_002_OPENISH_GHOSTTEXT_DRAIN_001 — FILE_EVIDENCE

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
GHOSTTEXT_INVENT_EMPTY=1
ABSORB=NOT_AUTHORIZED
DUAL_COUNT_CAVEAT=1
  OPENISH_-3 and GHOSTTEXT_-3 = same three classifications (not 6)
ASOF_UTC=2026-10-30T16:17:31Z
```

## Selection (invent-eligible after DEBUGGER residual GHOSTTEXT=3)

Enumerated 3 GHOSTTEXT residual. Invent-eligible empty-true/fake-ready = **3**
(`SHORT_BATCH=1`; <9). Remaining 0 — invent theater empty.

| # | Path | Prior class | After class | Surface gated | Implementation (actual) | Missing dependency / gap |
|--:|------|-------------|-------------|---------------|-------------------------|--------------------------|
| 1 | `src/win32app/ghost_completion_parse.cpp` | GHOSTTEXT | GATED_FICTION | `Initialize` / `GhostParser_Create` | Scalar parse body retained unused; Init→false; Create→nullptr + FAIL_CLOSED log | Real GhostParser*.asm + model-scored confidence |
| 2 | `src/win32app/GhostTextContextSubscriber.cpp` | GHOSTTEXT | GATED_FICTION | prefetch invent ShowSuggestion | RequestSuggestion path retained; prefetch invent show FAIL_CLOSED | Real model/completion wire for prefetch show |
| 3 | `src/win32app/QuickWin_GhostText.asm` | GHOSTTEXT | GATED_FICTION | TAB accept / Insert / trigger | Render/Set/Shift retained; invent accept/trigger FAIL_CLOSED | Real piece-table insert + CompletionEngine |

## Source-gate presence (spot-check)

| Path | `DRAIN_001` mark | `FEATURE_FICTION=1 FAIL_CLOSED` hits |
|------|:----------------:|------------------------------------:|
| ghost_completion_parse.cpp | 1 | ≥3 |
| GhostTextContextSubscriber.cpp | 1 | ≥2 |
| QuickWin_GhostText.asm | 1 | ≥3 |

## Regression — OTHER / EXTENSION / UI_PANEL / DEBUGGER invent gates (not re-touched)

| Path | FAIL_CLOSED / residual | Status |
|------|------------------------|--------|
| Win32IDE_SidebarPanels.cpp (UI_002) | FEATURE_FICTION present | OK |
| Win32IDE_DownloadsPanel.cpp (UI_001) | FEATURE_FICTION present | OK |
| Win32IDE_ExtensionToggles.cpp (EXT_002) | FEATURE_FICTION present | OK |
| ExtensionEngine.asm (EXT_001) | FEATURE_FICTION present | OK |
| Win32IDE_DebugWatchFormat.cpp (DBG_001) | FEATURE_FICTION present | OK |
| OTHER / EXTENSION / UI_PANEL / DEBUGGER invent-empty | counts 8/8/14/6 unchanged | OK |
| Residual DEBUGGER 6 | no GHOSTTEXT_DRAIN mark | OK |

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
| GATED_FICTION | 238 |
| BRIDGE_GATED | 14 |
| OTHER | 8 |
| EXTENSION | 8 |
| UI_PANEL | 14 |
| DEBUGGER | 6 |
| TEST | 22 |
| HEADLESS_ALT | 8 |
| GHOSTTEXT | 0 |
| QUARANTINE | 3 |
| STUB | 2 |
| **TOTAL** | **323** |

OPENISH family sum (OTHER+EXT+UI_PANEL+DEBUGGER+STUB+QUARANTINE+GHOSTTEXT) = **41**.
GATEDISH = 323 − 41 = **282**.

Seal counts (strict drain math; same three files): OPENISH 44→41 (−3); GHOSTTEXT 3→0 (−3); GATEDISH 279→282 (+3).
