# AUDIT_002_OPENISH_UI_PANEL_DRAIN_002 — FILE_EVIDENCE

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
UI_PANEL_INVENT_EMPTY=1
DUAL_COUNT_CAVEAT=1
  OPENISH_-1 and UI_PANEL_-1 = same one classification (not 2)
ASOF_UTC=2026-10-29T20:26:22Z
```

## Selection (invent-eligible after DRAIN_001 residual=15)

Enumerated 15 UI_PANEL residual. Invent-eligible empty-true/fake-ready = **1**
(`SHORT_BATCH=1`; <9). Remaining 14 adjudicated real/partial — invent theater empty.

| # | Path | Prior class | After class | Surface gated | Implementation (actual) | Missing dependency / gap |
|--:|------|-------------|-------------|---------------|-------------------------|--------------------------|
| 1 | `src/win32app/Win32IDE_SidebarPanels.cpp` | UI_PANEL | GATED_FICTION | `createExtensionsPanel` Installed/Available | CreateWindow ListView/Git/Search real; extensions lists emptied + FAIL_CLOSED log | Real extension enum / marketplace I/O (not invent names) |

## Source-gate presence (spot-check)

| Path | `DRAIN_002` mark | `FEATURE_FICTION=1 FAIL_CLOSED` hits |
|------|:----------------:|------------------------------------:|
| Win32IDE_SidebarPanels.cpp | 1 | 2 |

## Regression — DRAIN_001 / EXT / OTHER invent gates (not re-touched)

| Path | FAIL_CLOSED / residual | Status |
|------|------------------------|--------|
| Win32IDE_Sidebar.asm (DRAIN_001) | FEATURE_FICTION present | OK |
| Win32IDE_Sidebar_Pure_Simple.asm | FEATURE_FICTION present | OK |
| Win32IDE_Sidebar_Pure_Minimal.asm | FEATURE_FICTION present | OK |
| Win32IDE_VoiceAssistantPanel.cpp | FEATURE_FICTION present | OK |
| VoiceAutomation_Panel.cpp | FEATURE_FICTION present | OK |
| Win32IDE_WelcomePage.cpp | FEATURE_FICTION present | OK |
| win32ide_docking_integration.cpp | FEATURE_FICTION present | OK |
| Win32IDE_SidebarBridge.cpp | FEATURE_FICTION present | OK |
| Win32IDE_DownloadsPanel.cpp | FEATURE_FICTION present | OK |
| ExtensionEngine.asm (EXT_001) | FEATURE_FICTION present | OK |
| Win32IDE_ExtensionToggles.cpp (EXT_002) | FEATURE_FICTION present | OK |
| OTHER / EXTENSION invent-empty | counts 8/8 unchanged | OK |

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
| GATED_FICTION | 232 |
| BRIDGE_GATED | 14 |
| OTHER | 8 |
| EXTENSION | 8 |
| UI_PANEL | 14 |
| DEBUGGER | 9 |
| TEST | 22 |
| HEADLESS_ALT | 8 |
| GHOSTTEXT | 3 |
| QUARANTINE | 3 |
| STUB | 2 |
| **TOTAL** | **323** |

OPENISH family sum (OTHER+EXT+UI_PANEL+DEBUGGER+STUB+QUARANTINE+GHOSTTEXT) = **47**.
GATEDISH = 323 − 47 = **276**.

Seal counts (strict drain math; same one file): OPENISH 48→47 (−1); UI_PANEL 15→14 (−1); GATEDISH 275→276 (+1).
`DUAL_COUNT_CAVEAT`: do not count OPENISH Δ and UI_PANEL Δ as two resolutions.

## Explicit non-claims

```
SOURCE_WIRED != RUNTIME_REACHED != PASS
NOT_RUN != PASS
one_file_gate != one_runtime_component
OPENISH_UI_PANEL_dual_delta != two_resolutions
UI_PANEL_INVENT_EMPTY != OPENISH_EMPTY != PERFECT
PROMOTE=0 PERFECT=0 CERTIFIED=0
```
