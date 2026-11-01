# AUDIT_002_OPENISH_OTHER_DRAIN_001 — MATRIX (sealed)

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
PARENT=AUDIT_002_DRAIN
PRIOR=WIN32IDE_STUB_FICTION_SWEEP_004
ASOF_UTC=2026-10-29T13:18:03Z
WORKSPACE=G:\~dev\rawrxd
RUNTIME_REACHED=NOT_RUN
```

Statuses: **GATED** | PRIOR_GATED | OPEN | OUT_OF_SCOPE

## Carry — prior seals (unchanged)

| Seal | Note |
|------|------|
| SWEEP_003 / SWEEP_004 fiction inventory | **PRIOR_GATED** (sites) |
| AUDIT_002_DRAIN OPENISH 294→261 | baseline for this drain |
| Tip 748B TIP_FREEZE_001\bin | **UNTOUCHED** MATCH=1 |

## Empty-true / fake-ready drain — OTHER + EXTENSION + UI

| Rank | Surface | Bucket | Was | Now | Disposition |
|-----:|---------|--------|-----|-----|-------------|
| 1 | `Win32IDE_AgentExecutor` Initialize/ExecuteAgentTask | OTHER | comment-only `return true` | FEATURE_FICTION FAIL_CLOSED `return false` | **GATED** |
| 2 | `bulk_fix_orchestrator_production` Init/Queue/Process | OTHER | flag-only / empty-true "Provides real" | FAIL_CLOSED | **GATED** |
| 3 | `sovereign_gpu_link_production` Init/Submit/Wait/DeviceInfo | OTHER | invent GPU success / device string | FAIL_CLOSED | **GATED** |
| 4 | `collab_cursor_production` Initialize | OTHER | local-flag "Provides real" (impl sibling PRIOR_GATED) | FAIL_CLOSED | **GATED** |
| 5 | `FeatureRegistry::IsAgentBridgeEnabled` | OTHER | default `return true` "enabled for now" | FAIL_CLOSED default false (env opt-in) | **GATED** |
| 6 | `DockingPaneManager::deserializeLayout` | UI_PANEL | stub "for the concept" `return true` | FAIL_CLOSED | **GATED** |
| 7 | `ExtensionHost::InstallExtensionFromMarketplace` | EXTENSION | download+mkdir then `return true` (no VSIX extract) | FAIL_CLOSED | **GATED** |
| 8 | `IDEDiagnosticAutoHealer::OpenFileInEditor` | OTHER | PostMessage 'O' + Sleep → `return true` | FAIL_CLOSED | **GATED** |
| 9 | `ChatCommands` IDC_CHAT_PREVIEW_EXECUTE | OTHER | click handler `return true` without execute | FAIL_CLOSED | **GATED** |

## Orphan OPENISH delta

| Metric | Prior (AUDIT_002_DRAIN) | After OTHER_DRAIN_001 | Δ |
|--------|------------------------:|----------------------:|--:|
| OPENISH orphan TUs | 261 | **252** | **-9** |
| GATEDISH | 62 | **71** | **+9** |
| OTHER bucket | 195 | **188** | **-7** |
| EXTENSION | 24 | **23** | **-1** |
| UI_PANEL | 25 | **24** | **-1** |
| GATED_FICTION | 18 | **27** | **+9** |
| Total orphans | 323 | 323 | 0 |

## Counts (strict; no invent PASS)

| Metric | N |
|--------|--:|
| GATED this drain (SOURCE_WIRE sites) | **9** |
| OPENISH residual | **252** |
| PERFECT | **0** |
| RELINK_REQUIRED (tip) | **NO** |
| RUNTIME_REACHED | **NOT_RUN** |
| GhostText ABSORB | **NOT_AUTHORIZED** |

## Explicit non-claims

```
SOURCE_WIRED != RUNTIME_REACHED != PASS
GATED_FAILCLOSE != TIP_RELINK_PASS
NOT_RUN != PASS
OPENISH_252 != PERFECT
OTHER_DRAIN_9 != OPENISH_EMPTY
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_748B_UNTOUCHED=1
```

## Next gate

`NEXT_GATE=AUDIT_002_OPENISH_OTHER_DRAIN_002` — continue OTHER≈188 residual empty-true/fake-ready batch fail-closed; tip 748B untouched; `PROMOTE=0`.
Candidate tip relink remains PathB sibling: `TIP_CANDIDATE_AGENT_RUN_005_RELINK` (≠ this seal; EXE ownership P0).
