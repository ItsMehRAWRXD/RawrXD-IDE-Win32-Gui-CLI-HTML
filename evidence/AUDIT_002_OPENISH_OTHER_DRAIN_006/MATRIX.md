# AUDIT_002_OPENISH_OTHER_DRAIN_006 — MATRIX (sealed)

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
PARENT=AUDIT_002_OPENISH_OTHER_DRAIN_005
PRIOR=AUDIT_002_OPENISH_OTHER_DRAIN_005
ASOF_UTC=2026-10-29T14:45:32Z
WORKSPACE=G:\~dev\rawrxd
RUNTIME_REACHED=NOT_RUN
```

Statuses: **GATED** | PRIOR_GATED | OPEN | OUT_OF_SCOPE

## Carry — prior seals (unchanged)

| Seal | Note |
|------|------|
| SWEEP_003 / SWEEP_004 fiction inventory | **PRIOR_GATED** (sites) |
| AUDIT_002_DRAIN OPENISH 294→261 | baseline |
| OTHER_DRAIN_001..004 | prior chain |
| OTHER_DRAIN_005 OPENISH 225→216 | prior this chain |
| Tip 748B TIP_FREEZE_001\bin | **UNTOUCHED** MATCH=1 |

## Empty-true / fake-ready drain — OTHER residual batch

| Rank | Surface | Bucket | Was | Now | Disposition |
|-----:|---------|--------|-----|-----|-------------|
| 1 | `GGUFManifold_CreateManifold` | OTHER | invent loaded=1 without GGUF | FAIL_CLOSED 0 | **GATED** |
| 2 | `AgentCursorOverlay_CreateOverlay` | OTHER | invent visible=1 without HWND | FAIL_CLOSED 0 | **GATED** |
| 3 | `TBA_LinkGraph_CreateLink` | OTHER | invent active_flag=1 theater | FAIL_CLOSED 0 | **GATED** |
| 4 | `ContextGovernor_CreateContext` | OTHER | invent active_flag=1 theater | FAIL_CLOSED 0 | **GATED** |
| 5 | `AgentKernel_StartAgent` | OTHER | invent AGENT_RUNNING return 1 | FAIL_CLOSED 0 | **GATED** |
| 6 | `Hermes_ActivateGate_Internal` | OTHER | invent peer mesh + handshake gap | FAIL_CLOSED | **GATED** |
| 7 | `initQuantumOrchestrator` | OTHER | invent Online/Active feature list | FAIL_CLOSED | **GATED** |
| 8 | `Scheduler_Initialize` | OTHER | invent running=true empty-true | FAIL_CLOSED | **GATED** |
| 9 | `INFINITY_Initialize` | OTHER | invent running=true empty-true | FAIL_CLOSED | **GATED** |

## Orphan OPENISH delta

| Metric | Prior (OTHER_DRAIN_005) | After OTHER_DRAIN_006 | Δ |
|--------|------------------------:|----------------------:|--:|
| OPENISH orphan TUs | 216 | **207** | **-9** |
| GATEDISH | 107 | **116** | **+9** |
| OTHER bucket | 152 | **143** | **-9** |
| GATED_FICTION | 63 | **72** | **+9** |
| EXTENSION | 23 | 23 | 0 |
| UI_PANEL | 24 | 24 | 0 |
| Total orphans | 323 | 323 | 0 |

## Counts (strict; no invent PASS)

| Metric | N |
|--------|--:|
| GATED this drain (SOURCE_WIRE sites) | **9** |
| OPENISH residual | **207** |
| OTHER residual | **143** |
| PERFECT | **0** |
| RELINK_REQUIRED (tip) | **NO** |
| RUNTIME_REACHED | **NOT_RUN** |
| GhostText ABSORB | **NOT_AUTHORIZED** |

## Explicit non-claims

```
SOURCE_WIRED != RUNTIME_REACHED != PASS
GATED_FAILCLOSE != TIP_RELINK_PASS
NOT_RUN != PASS
OPENISH_207 != PERFECT
OTHER_DRAIN_9 != OPENISH_EMPTY
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_748B_UNTOUCHED=1
ABSORB=NOT_AUTHORIZED
```

## Next gate

`NEXT_GATE=AUDIT_002_OPENISH_OTHER_DRAIN_007` — continue OTHER≈143 residual empty-true/fake-ready batch fail-closed; tip 748B untouched; `PROMOTE=0`.
Candidate tip relink remains sibling PathB / stub+FailFast ownership (≠ this seal; no ninja race).
