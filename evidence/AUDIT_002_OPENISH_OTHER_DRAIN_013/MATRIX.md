# AUDIT_002_OPENISH_OTHER_DRAIN_013 — MATRIX (sealed)

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
PARENT=AUDIT_002_OPENISH_OTHER_DRAIN_012
PRIOR=AUDIT_002_OPENISH_OTHER_DRAIN_012
ASOF_UTC=2026-10-29T13:12:02Z
WORKSPACE=G:\~dev\rawrxd
RUNTIME_REACHED=NOT_RUN
```

Statuses: **GATED** | PRIOR_GATED | OPEN | OUT_OF_SCOPE

## Carry — prior seals (unchanged)

| Seal | Note |
|------|------|
| OTHER_DRAIN_001..011 | prior chain |
| OTHER_DRAIN_012 OPENISH 162→153 | prior this chain (sealed; not re-touched) |
| Tip 748B TIP_FREEZE_001\bin | **UNTOUCHED** MATCH=1 |
| PathB acceptance | **OPEN** (sibling; ≠ this seal) |

## Empty-true / fake-ready drain — OTHER residual batch

| Rank | Surface | Bucket | Was | Now | Disposition |
|-----:|---------|--------|-----|-----|-------------|
| 1 | `SessionController::Start` / `MarkPhaseReady` | OTHER | invent SessionPhase::Ready | FAIL_CLOSED | **GATED** |
| 2 | `initTerminalTabs` | OTHER | invent Initialized empty-true | FAIL_CLOSED | **GATED** |
| 3 | Window deferred bootstrap Inference/Ghost LOG | OTHER | invent ready LOG theater | FAIL_CLOSED | **GATED** |
| 4 | `initSmoothScroll` | OTHER | invent smooth-scroll initialized | FAIL_CLOSED | **GATED** |
| 5 | `initSignatureHelp` | OTHER | invent fonts + Initialized | FAIL_CLOSED | **GATED** |
| 6 | `initEditorCommandSystem` | OTHER | invent command-system ready | FAIL_CLOSED | **GATED** |
| 7 | Core_HEAD Speculative/Vulkan/GGUF/Voice | OTHER | invent ready theater | FAIL_CLOSED | **GATED** |
| 8 | `CompilerIntegration::Initialize` | OTHER | invent initialized_=true | FAIL_CLOSED | **GATED** |
| 9 | TelemetrySink / UIWatchdog Initialize | OTHER | invent Initialized ready | FAIL_CLOSED | **GATED** |

## Orphan OPENISH delta

| Metric | Prior (OTHER_DRAIN_012) | After OTHER_DRAIN_013 | Δ |
|--------|------------------------:|----------------------:|--:|
| OPENISH orphan TUs | 153 | **144** | **-9** |
| GATEDISH | 170 | **179** | **+9** |
| OTHER bucket | 89 | **80** | **-9** |
| GATED_FICTION | 126 | **135** | **+9** |
| EXTENSION | 23 | 23 | 0 |
| UI_PANEL | 24 | 24 | 0 |
| Total orphans | 323 | 323 | 0 |

## Counts (strict; no invent PASS)

| Metric | N |
|--------|--:|
| GATED this drain (SOURCE_WIRE sites) | **9** |
| OPENISH residual | **144** |
| OTHER residual | **80** |
| PERFECT | **0** |
| RELINK_REQUIRED (tip) | **NO** |
| RUNTIME_REACHED | **NOT_RUN** |
| GhostText ABSORB | **NOT_AUTHORIZED** |

## Explicit non-claims

```
SOURCE_WIRED != RUNTIME_REACHED != PASS
GATED_FAILCLOSE != TIP_RELINK_PASS
NOT_RUN != PASS
OPENISH_144 != PERFECT
OTHER_DRAIN_13 != OPENISH_EMPTY
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_748B_UNTOUCHED=1
ABSORB=NOT_AUTHORIZED
PathB_ACCEPTANCE != this seal
```

## Next gate

`NEXT_GATE=AUDIT_002_OPENISH_OTHER_DRAIN_014` — continue OTHER≈80 residual empty-true/fake-ready batch fail-closed; tip 748B untouched; `PROMOTE=0`.
Candidate tip relink remains sibling PathB ownership (≠ this seal; no ninja race).
