# AUDIT_002_OPENISH_OTHER_DRAIN_015 — MATRIX (sealed)

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
PARENT=AUDIT_002_OPENISH_OTHER_DRAIN_014
PRIOR=AUDIT_002_OPENISH_OTHER_DRAIN_014
ASOF_UTC=2026-10-29T17:40:00Z
WORKSPACE=G:\~dev\rawrxd
RUNTIME_REACHED=NOT_RUN
```

Statuses: **GATED** | PRIOR_GATED | OPEN | OUT_OF_SCOPE

## Carry — prior seals (unchanged)

| Seal | Note |
|------|------|
| OTHER_DRAIN_001..013 | prior chain |
| OTHER_DRAIN_014 OPENISH 144→135 | prior this chain (sealed; not re-touched) |
| Tip 748B TIP_FREEZE_001\bin | **UNTOUCHED** MATCH=1 |
| PathB acceptance | **OPEN** (sibling; ≠ this seal) |

## Empty-true / fake-ready drain — OTHER residual batch

| Rank | Surface | Bucket | Was | Now | Disposition |
|-----:|---------|--------|-----|-----|-------------|
| 1 | `Win32IDE_InitGGUFLoader` (masm) | OTHER | invent Bridge init ready | FAIL_CLOSED | **GATED** |
| 2 | `Win32IDE_InitGGUFLoader` (masm_real) | OTHER | invent Bridge init ready | FAIL_CLOSED | **GATED** |
| 3 | `OptimizeContextBuffer` | OTHER | invent optimize ready true | FAIL_CLOSED | **GATED** |
| 4 | `UnifiedEditorContext::Initialize` | OTHER | invent UECR empty-true | FAIL_CLOSED | **GATED** |
| 5 | `initReferenceGraphPanel` | OTHER | invent RegisterClass ready | FAIL_CLOSED | **GATED** |
| 6 | `IDELogger::initialize` | OTHER | invent spdlog/ofstream ready | FAIL_CLOSED | **GATED** |
| 7 | `TerminalProfileManager` ctor | OTHER | invent shell profiles ready | FAIL_CLOSED | **GATED** |
| 8 | `AgenticBrowser_Show` / Relayout | OTHER | invent empty browser ready | FAIL_CLOSED | **GATED** |
| 9 | legacy `WinMain` (Main.cpp) | OTHER | invent VSIX/agentic/engine ready | FAIL_CLOSED | **GATED** |

## Orphan OPENISH delta

| Metric | Prior (OTHER_DRAIN_014) | After OTHER_DRAIN_015 | Δ |
|--------|------------------------:|----------------------:|--:|
| OPENISH orphan TUs | 135 | **126** | **-9** |
| GATEDISH | 188 | **197** | **+9** |
| OTHER bucket | 71 | **62** | **-9** |
| GATED_FICTION | 144 | **153** | **+9** |
| EXTENSION | 23 | 23 | 0 |
| UI_PANEL | 24 | 24 | 0 |
| Total orphans | 323 | 323 | 0 |

## Counts (strict; no invent PASS)

| Metric | N |
|--------|--:|
| GATED this drain (SOURCE_WIRE sites) | **9** |
| OPENISH residual | **126** |
| OTHER residual | **62** |
| PERFECT | **0** |
| RELINK_REQUIRED (tip) | **NO** |
| RUNTIME_REACHED | **NOT_RUN** |
| GhostText ABSORB | **NOT_AUTHORIZED** |

## Explicit non-claims

```
SOURCE_WIRED != RUNTIME_REACHED != PASS
GATED_FAILCLOSE != TIP_RELINK_PASS
NOT_RUN != PASS
OPENISH_126 != PERFECT
OTHER_DRAIN_15 != OPENISH_EMPTY
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_748B_UNTOUCHED=1
ABSORB=NOT_AUTHORIZED
PathB_ACCEPTANCE != this seal
```

## Next gate

`NEXT_GATE=AUDIT_002_OPENISH_OTHER_DRAIN_016` — continue OTHER≈62 residual empty-true/fake-ready batch fail-closed; tip 748B untouched; `PROMOTE=0`.
Candidate tip relink remains sibling PathB ownership (≠ this seal; no ninja race).
