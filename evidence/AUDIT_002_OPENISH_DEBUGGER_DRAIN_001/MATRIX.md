# AUDIT_002_OPENISH_DEBUGGER_DRAIN_001 — MATRIX (sealed)

```
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_SHA256=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
TIP_MATCH=1 TIP_REBUILD=0 ABSORB=NOT_AUTHORIZED
RUNTIME_REACHED=NOT_RUN
PARENT=AUDIT_002_OPENISH_UI_PANEL_DRAIN_002
SHORT_BATCH=1
OTHER_INVENT_EMPTY=1
EXTENSION_INVENT_EMPTY=1
UI_PANEL_INVENT_EMPTY=1
DEBUGGER_INVENT_EMPTY=1
STOPPED_SUPERSEDED=1
DUAL_COUNT_CAVEAT=1
```

## Chain

| Seal | Note |
|------|------|
| OTHER_DRAIN_001..022 | OTHER invent empty sealed |
| EXTENSION_DRAIN_001 | OPENISH 72→62 EXTENSION 23→13 gated+10 |
| EXTENSION_DRAIN_002 | OPENISH 62→57 EXTENSION 13→8 gated+5; EXTENSION_INVENT_EMPTY=1 |
| UI_PANEL_DRAIN_001 | OPENISH 57→48 UI_PANEL 24→15 gated+9 |
| UI_PANEL_DRAIN_002 | OPENISH 48→47 UI_PANEL 15→14 gated+1; UI_PANEL_INVENT_EMPTY=1 |
| DEBUGGER_DRAIN_001 | **this seal** OPENISH 47→44 DEBUGGER 9→6 gated+3; DEBUGGER_INVENT_EMPTY=1 |

## Empty-true / fake-ready drain — DEBUGGER batch 001

| # | Surface | Bucket | Prior | Disposition | Status |
|---|---------|--------|-------|-------------|--------|
| 1 | `DebugWatchFormat` cmdDbgWatchAdd | DEBUGGER | invent 5 sample watches | FAIL_CLOSED | **GATED** |
| 2 | `BreakpointPropertiesDialog` Show | DEBUGGER | empty-true + fake EDIT | FAIL_CLOSED | **GATED** |
| 3 | `DAPServer` invent handlers | DEBUGGER | invent DAP success/verified/fake frames | FAIL_CLOSED | **GATED** |

## Deltas

| Metric | Prior (UI_PANEL_DRAIN_002) | After DEBUGGER_DRAIN_001 | Δ |
|--------|---------------------------:|-------------------------:|--:|
| OPENISH | 47 | **44** | **-3** |
| DEBUGGER bucket | 9 | **6** | **-3** |
| GATEDISH | 276 | **279** | **+3** |
| UI_PANEL | 14 | **14** | **0** |
| EXTENSION | 8 | **8** | **0** |
| OTHER | 8 | **8** | **0** |

## Counts (strict; no invent PASS)

| Key | Value |
|-----|------:|
| INVENT_ELIGIBLE_DEBUGGER_GATED | **3** |
| DEBUGGER residual | **6** |
| DEBUGGER_INVENT_EMPTY | **1** |
| OTHER_INVENT_EMPTY | **1** |
| EXTENSION_INVENT_EMPTY | **1** |
| UI_PANEL_INVENT_EMPTY | **1** |
| RUNTIME_REACHED | NOT_RUN |
| tip748B | **1** |
| SHORT_BATCH | **1** |

## Spot-check — no regression

| Prior site | FAIL_CLOSED / residual present |
|------------|--------------------------------|
| `Win32IDE_SidebarPanels.cpp` (UI_002) | YES FAIL_CLOSED |
| `Win32IDE_DownloadsPanel.cpp` (UI_001) | YES FAIL_CLOSED |
| `Win32IDE_ExtensionToggles.cpp` (EXT_002) | YES FAIL_CLOSED |
| `ExtensionEngine.asm` (EXT_001) | YES FAIL_CLOSED |
| OTHER / EXTENSION / UI_PANEL counts | **8 / 8 / 14** unchanged |
| Residual DEBUGGER (6) | **UNTOUCHED** (no DRAIN_001 mark) |

## Explicit non-claims

```
SOURCE_WIRED != RUNTIME_REACHED != PASS
GATED_FAILCLOSE != TIP_RELINK_PASS
NOT_RUN != PASS
OPENISH_44 != PERFECT
DEBUGGER_6_RESIDUAL != DEBUGGER_PRODUCT_EMPTY
DEBUGGER_INVENT_EMPTY != OPENISH_EMPTY
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_748B_UNTOUCHED=1
ABSORB=NOT_AUTHORIZED
PathB_ACCEPTANCE != this seal
```

## Next gate

`NEXT_GATE=DEBUGGER_INVENT_EMPTY` — DEBUGGER invent theater drained;
residual 6 are real/partial (≠ invent-eligible). Next family =
remaining OPENISH (STUB / QUARANTINE / GHOSTTEXT / …) under separate seal.
Tip 748B untouched; `PROMOTE=0`.
