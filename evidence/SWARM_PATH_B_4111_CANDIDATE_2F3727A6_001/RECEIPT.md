# RECEIPT — SWARM_PATH_B_4111_CANDIDATE_2F3727A6_001

```
ASOF_UTC=2026-10-29T10:04:50Z
RUNTIME_PASS=0
RUNTIME_REACHED=1
PROMOTE=0 TIP_CLIMB=HOLD ABSORB=NOT_AUTHORIZED CERTIFIED=0
```

## Authority

| Item | Value |
|------|-------|
| Tip EXE | `TIP_FREEZE_001\bin` SHA `748B210A…3145` pre+post MATCH UNTOUCHED |
| Prove EXE | `TIP_CANDIDATE_AGENT_RUN_005\bin` SHA `2F3727A6…07C2` pre+post MATCH STABLE |
| Handoff | `SWARM_PATH_B_4111_CRASH_ROOT_001/HANDOFF_ALIGNMENT_CONFIRMED.txt` |
| N2 headless | `SWARM_ORCH_N2_BOTH_COMPLETE_001` PASS — does **not** transfer PathB PASS |
| 99EB54F2 | forensic only (historical PathB C0000409) |

## Controlling run (rerun, no pipe redirect)

| Field | Result |
|-------|--------|
| createWindow | OK_RETURN_TRUE |
| CMD_DIAG_id_4111 | **14** OBSERVED |
| onSubAgentSwarm | OBSERVED |
| EXECUTE_SWARM_ENTER | **1** (`BEFORE_executeSwarm`) |
| EXECUTE_SWARM_RETURN | **0** |
| COMPLETED | **0** |
| TIMED_OUT | **0** (unreached; crash first) |
| EXIT | **-1073741819 / 0xC0000005** |
| GUI_RESPONSIVE | **0** |
| VEH_FATAL | 1 @ ~6s after BEFORE_executeSwarm |
| RUNTIME_PASS | **0** |

## Acceptance (conjunction — FAIL)

| Gate | Met? |
|------|------|
| CANDIDATE_SHA_MATCH | 1 |
| TIP_UNTOUCHED | 1 |
| CMD_DIAG_4111_OBSERVED | 1 |
| EXECUTE_SWARM_ENTER | 1 |
| EXECUTE_SWARM_RETURN | **0** |
| COMPLETED=2 | **0** |
| EXIT_CODE=0 | **0** (C0000005) |
| GUI_RESPONSIVE | **0** |

## Interim run1 (superseded)

RedirectStandardError/Output → `FAIL_CLOSED_CMD_DIAG_MISS`, EXIT empty, CMD_DIAG_4111=0. Not controlling.

## Dump standby

`DUMP_STANDBY=1` → `evidence/SWARM_PATH_B_4111_CRASH_ROOT_001/dumps/STANDBY_REQUEST_2F3727A6.txt`  
Crash-root: dump/stack on **2F3727A6** only. No tip rebuild. No competing ninja.

## Next gate

Crash-root dump/stack on candidate `2F3727A6` (`0xC0000005` after `BEFORE_executeSwarm`); re-prove PathB only after RETURN+COMPLETED=2+EXIT0. Keep `PROMOTE=0`.
