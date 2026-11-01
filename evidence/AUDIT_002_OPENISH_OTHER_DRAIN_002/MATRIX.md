# AUDIT_002_OPENISH_OTHER_DRAIN_002 — MATRIX (sealed)

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
PARENT=AUDIT_002_OPENISH_OTHER_DRAIN_001
PRIOR=AUDIT_002_OPENISH_OTHER_DRAIN_001
ASOF_UTC=2026-10-29T13:32:43Z
WORKSPACE=G:\~dev\rawrxd
RUNTIME_REACHED=NOT_RUN
```

Statuses: **GATED** | PRIOR_GATED | OPEN | OUT_OF_SCOPE

## Carry — prior seals (unchanged)

| Seal | Note |
|------|------|
| SWEEP_003 / SWEEP_004 fiction inventory | **PRIOR_GATED** (sites) |
| AUDIT_002_DRAIN OPENISH 294→261 | baseline |
| OTHER_DRAIN_001 OPENISH 261→252 | prior this chain |
| Tip 748B TIP_FREEZE_001\bin | **UNTOUCHED** MATCH=1 |

## Empty-true / fake-ready drain — OTHER residual batch

| Rank | Surface | Bucket | Was | Now | Disposition |
|-----:|---------|--------|-----|-----|-------------|
| 1 | `RefactoringEngine` Apply/Undo/txn | OTHER | simulate patch / invent undo | FAIL_CLOSED | **GATED** |
| 2 | `AdvancedLSPClient` Query/Rename | OTHER | Mock symbols / simulate edit | FAIL_CLOSED empty | **GATED** |
| 3 | `SpeculativeOptimizer::Predict` | OTHER | mock token IDs + conf 0.9 | FAIL_CLOSED | **GATED** |
| 4 | `NotebookLSPManager::GetSemanticTokens` | OTHER | hard-coded Mock tokens | FAIL_CLOSED empty | **GATED** |
| 5 | `D2DTextRenderer` Create* | OTHER | empty-true factories/target/formats | FAIL_CLOSED | **GATED** |
| 6 | `BrowserSurface` navigate/executeScript | OTHER | invent navigated/dispatched | FAIL_CLOSED error | **GATED** |
| 7 | `sovereign_gpu_impl` (engines=0) | OTHER | synthetic GPU version/alloc invent | FAIL_CLOSED 0/false | **GATED** |
| 8 | `rtp_protocol_impl::RTP_DispatchPacket` | OTHER | invent ok with handler_rva=0 | FAIL_CLOSED | **GATED** |
| 9 | `FileManager::initialize` | OTHER | empty-true fake-ready | FAIL_CLOSED | **GATED** |

## Orphan OPENISH delta

| Metric | Prior (OTHER_DRAIN_001) | After OTHER_DRAIN_002 | Δ |
|--------|------------------------:|----------------------:|--:|
| OPENISH orphan TUs | 252 | **243** | **-9** |
| GATEDISH | 71 | **80** | **+9** |
| OTHER bucket | 188 | **179** | **-9** |
| GATED_FICTION | 27 | **36** | **+9** |
| EXTENSION | 23 | 23 | 0 |
| UI_PANEL | 24 | 24 | 0 |
| Total orphans | 323 | 323 | 0 |

## Counts (strict; no invent PASS)

| Metric | N |
|--------|--:|
| GATED this drain (SOURCE_WIRE sites) | **9** |
| OPENISH residual | **243** |
| OTHER residual | **179** |
| PERFECT | **0** |
| RELINK_REQUIRED (tip) | **NO** |
| RUNTIME_REACHED | **NOT_RUN** |
| GhostText ABSORB | **NOT_AUTHORIZED** |

## Explicit non-claims

```
SOURCE_WIRED != RUNTIME_REACHED != PASS
GATED_FAILCLOSE != TIP_RELINK_PASS
NOT_RUN != PASS
OPENISH_243 != PERFECT
OTHER_DRAIN_9 != OPENISH_EMPTY
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_748B_UNTOUCHED=1
ABSORB=NOT_AUTHORIZED
```

## Next gate

`NEXT_GATE=AUDIT_002_OPENISH_OTHER_DRAIN_003` — continue OTHER≈179 residual empty-true/fake-ready batch fail-closed; tip 748B untouched; `PROMOTE=0`.
Candidate tip relink remains sibling PathB ownership (≠ this seal; no ninja race).
