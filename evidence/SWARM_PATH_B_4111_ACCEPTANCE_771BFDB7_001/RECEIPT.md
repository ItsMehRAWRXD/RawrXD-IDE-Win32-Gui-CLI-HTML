# SWARM_PATH_B_4111_ACCEPTANCE_771BFDB7_001 — RELAUNCH RECEIPT

```
GATE=SWARM_PATH_B_4111_ACCEPTANCE_771BFDB7_001
RUN=RELAUNCH_SUPERSEDE_58536316
ASOF_UTC=2026-10-29T17:32:30Z
PROMOTE=0 TIP_CLIMB=HOLD ABSORB=NOT_AUTHORIZED
NOT_RUN_NEQ_PASS=1
NO_INVENT_PASS=1
```

## Authority

| Binary | SHA256 | Status |
|--------|--------|--------|
| Tip `TIP_FREEZE_001\bin` | `748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145` | UNTOUCHED tip748B=1 |
| Cand `TIP_CANDIDATE_AGENT_RUN_005\bin` | `771BFDB787BDAFB6581F0AD9FA79AB86F23F576C9E2FB62F784850A5085227F5` | RE-HASH match expected; STABLE post-run |

`TIP_CLIMB=HOLD` · `PROMOTE=0` · `ABSORB=NOT_AUTHORIZED` · tip bin not rewritten.

## Supersedes

- Wedged agent `58536316` (lines=1 for ~14m) — relaunched here; cand SHA was already stable (no solo-relink).
- Prior same-seal GUI prove @ 17:10:53Z (same disposition).

`CMD_DIAG miss / FailFast-before-diag` = NOT this run → solo-relink SKIPPED (SHA frozen).

## PathB no-redirect prove

Env: `RAWRXD_P1_CMD_DIAG=1` `RAWRXD_DISABLE_OLLAMA_FETCH=1` `RAWRXD_GUI=1` `RAWRXD_SWARM_N=2`

```
CMD_DIAG_4111=15
deepest=executeSwarm_BODY_FAIL_CLOSED_EMPTY
path=TIMER→ENTER→light_mgr→resolve_OK→BEFORE_executeSwarm→ASYNC_SPAWN→BODY_ENTER→BODY_RETURN→PROGRESS_SKIP→FAIL_CLOSED_EMPTY
EXIT=0xC0000409
DUMP_CAPTURED=0
COMPLETED=0 taskCount=0
RUNTIME_REACHED=1
RUNTIME_PASS=0
```

Restore ≥ENTER then resolve→executeSwarm: **witnessed**. Acceptance close still OPEN (empty merge + FailFast post-return; no dump).

## Explicit non-claims

```
SOURCE_WIRED != RUNTIME_REACHED != TOKEN_SURVIVED != PERFORMANCE_PASS
NOT_RUN != PASS
N2 != PathB
DUMP_MISSING != invented MiniDump
RUNTIME_PASS=0
```

## Artifacts

- `SUMMARY.txt` — harness disposition (honest FAIL)
- `RUNLOG.txt` — this relaunch
- `logs/CMD_BREADCRUMB.txt` — 15× id=4111 steps
- `FROZEN_CANDIDATE_SHA.txt` / `NEW_CAND_SHA.txt` — 771BFDB7…

## NEXT_GATE

`PATHB_ACCEPTANCE_CLOSE_GAPS` (empty `executeSwarm` + post-return `0xC0000409` without dump; tip untouched).
