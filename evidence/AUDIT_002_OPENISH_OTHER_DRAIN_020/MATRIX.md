# AUDIT_002_OPENISH_OTHER_DRAIN_020 — MATRIX (sealed)

```
PROMOTE=0
TIP_CLIMB=HOLD
CERTIFIED=0
PERFECT=0
NO_INVENT_PASS=1
TIP_REBUILD=0
TIP_SHA256=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
TIP_MATCH=1
ABSORB=NOT_AUTHORIZED
PARENT=AUDIT_002_OPENISH_OTHER_DRAIN_019
PRIOR=AUDIT_002_OPENISH_OTHER_DRAIN_019
ASOF_UTC=2026-10-29T19:05:00Z
WORKSPACE=G:\~dev\rawrxd
RUNTIME_REACHED=NOT_RUN
```

Statuses: **GATED** | PRIOR_GATED | OPEN | OUT_OF_SCOPE

## Carry — prior seals (unchanged)

| Seal | Note |
|------|------|
| OTHER_DRAIN_001..018 | prior chain |
| OTHER_DRAIN_019 OPENISH 99→90 | prior this chain (sealed; not re-touched) |
| Tip 748B TIP_FREEZE_001\bin | **UNTOUCHED** MATCH=1 |
| PathB acceptance | **OPEN** (sibling; ≠ this seal) |

## Empty-true / fake-ready drain — OTHER residual batch

| Rank | Surface | Bucket | Was | Now | Disposition |
|-----:|---------|--------|-----|-----|-------------|
| 1 | `lspRangeFormatting` / LSP 100% claim | OTHER | invent LSP 100% completion ready | FAIL_CLOSED | **GATED** |
| 2 | `cmdShowCallHierarchy` / TypeHierarchy | OTHER | invent hierarchy ready | FAIL_CLOSED | **GATED** |
| 3 | `cmdRefreshSemanticTokens` | OTHER | invent semantic tokens ready | FAIL_CLOSED | **GATED** |
| 4 | `showCodeActions` / `cmdFixAllDiagnostics` | OTHER | invent code actions ready | FAIL_CLOSED | **GATED** |
| 5 | `ModelManagerDialog::Show` / Model ready | OTHER | invent Model Manager ready | FAIL_CLOSED | **GATED** |
| 6 | `showCompletionPopup` HybridCompletion | OTHER | invent IntelliSense ready | FAIL_CLOSED | **GATED** |
| 7 | `showQuickOpenPicker` | OTHER | invent Quick Open ready | FAIL_CLOSED | **GATED** |
| 8 | `showGoToSymbolPicker` / workspace | OTHER | invent GoToSymbol ready | FAIL_CLOSED | **GATED** |
| 9 | `ChatAutocomplete_Attach` / key handlers | OTHER | invent chat autocomplete ready | FAIL_CLOSED | **GATED** |

## Orphan OPENISH delta

| Metric | Prior (OTHER_DRAIN_019) | After OTHER_DRAIN_020 | Δ |
|--------|------------------------:|----------------------:|--:|
| OPENISH orphan TUs | 90 | **81** | **-9** |
| GATEDISH | 233 | **242** | **+9** |
| OTHER bucket | 26 | **17** | **-9** |
| GATED_FICTION | 189 | **198** | **+9** |
| EXTENSION | 23 | 23 | 0 |
| UI_PANEL | 24 | 24 | 0 |
| Total orphans | 323 | 323 | 0 |

## Counts (strict; no invent PASS)

| Metric | N |
|--------|--:|
| GATED this drain (SOURCE_WIRE sites) | **9** |
| OPENISH residual | **81** |
| OTHER residual | **17** |
| PERFECT | **0** |
| RELINK_REQUIRED (tip) | **NO** |
| RUNTIME_REACHED | **NOT_RUN** |
| GhostText ABSORB | **NOT_AUTHORIZED** |

## Explicit non-claims

```
SOURCE_WIRED != RUNTIME_REACHED != PASS
GATED_FAILCLOSE != TIP_RELINK_PASS
NOT_RUN != PASS
OPENISH_81 != PERFECT
OTHER_DRAIN_20 != OPENISH_EMPTY
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_748B_UNTOUCHED=1
ABSORB=NOT_AUTHORIZED
PathB_ACCEPTANCE != this seal
```

## Next gate

`NEXT_GATE=AUDIT_002_OPENISH_OTHER_DRAIN_021` — continue OTHER≈17 residual empty-true/fake-ready batch fail-closed; tip 748B untouched; `PROMOTE=0`.
Candidate tip relink remains sibling PathB ownership (≠ this seal; no ninja race).
