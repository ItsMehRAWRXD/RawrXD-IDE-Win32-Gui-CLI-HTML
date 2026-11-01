# RECEIPT — SWARM_16_RUNTIME_004_PATH_B

```
ASOF_UTC=2026-10-28T17:30:00Z
WORKSPACE=G:\~dev\rawrxd
WORKSTREAM=G07_PATH_B_SWARM_RUNTIME
TOP10=#3
PATH=B_GUI
AUTHORITY=TIP_FREEZE_001\bin SHA=748B210A…
REBUILD_TIP=0 ABSORB=NOT_AUTHORIZED PROMOTE=0
```

## Result

**FAIL_CLOSED** — `RUNTIME_REACHED=0` `RUNTIME_PASS=0` on tip PathB.

| Gate | Result |
|------|--------|
| Tip SHA 748B | MATCH |
| MAIN_HWND ≠ 0 | 1 |
| MENU_READY | 1 |
| WM_COMMAND 4111 Post/Send | intermittent 1 (not sufficient) |
| CMD_DIAG `id=4111` | **0** |
| onSubAgentSwarm | NOT_OBSERVED |
| resolveSwarmModelOrchPlan | NOT_OBSERVED |
| executeSwarm | NOT_OBSERVED |
| RUNTIME_REACHED | **0** |
| PROMOTE | **0** |

## Root cause

`IDM_SUBAGENT_SWARM` (4111) never enters `CmdDiag`/`sehCallOnCommand` on frozen tip 748B while `id=1001` earns crumbs under the same `RAWRXD_P1_CMD_DIAG=1`. Orch handlers therefore remain NOT_OBSERVED. Secondary UI hang after File New / editor seed blocks later 411x delivery. See `ROOT_CAUSE.txt`.

## Explicit non-claims

- PathA `SWARM_16_RUNTIME_003` orch JSON ≠ PathB GUI orch
- B421 / build-tree not attributed
- No tip rebuild / absorb / promote
