# TIP_CANDIDATE_AGENT_RUN_005 / RECEIPT

```
ASOF_UTC=2026-10-28T20:15:00Z
DISPOSITION=CANDIDATE_FROZEN_PLUS_RUNTIME_PROVE
NEW_SHA=99EB54F2B876E59D9DC054530FFEDDDF2875EF308EE8A937CA1DECE6A5B481CA
SUPERSEDES=8DC1406A0118AC6A2F6A1E991378A2730AAC07D5593BA3C9BF5E8852E468235B
PROMOTE=0
TIP_CLIMB=HOLD
ABSORB_GHOSTTEXT=NOT_AUTHORIZED
PRODUCT_CERTIFIED=0
REBUILD_TIP=0
NO_INVENT_PASS=1
```

## Candidate

| Field | Value |
|------|--------|
| EXE | `evidence/TIP_CANDIDATE_AGENT_RUN_005/bin/RawrXD-Win32IDE.exe` |
| SHA256 | `99EB54F2B876E59D9DC054530FFEDDDF2875EF308EE8A937CA1DECE6A5B481CA` |
| Size | 331753984 |
| PDB | present |
| Map | `bin/RawrXD-Win32IDE_n2reset.map` (alt path; stale `.map` was locked) |
| Build source | `build_win32ide_link001/bin` (non-authoritative for tip cert) |
| Hash re-verify | MATCH |
| ≠ tip 748B | 1 |
| ≠ GhostText B421 | 1 |
| ≠ prior 8DC1406A | 1 |

## Tip (unchanged)

| Field | Value |
|------|--------|
| EXE | `evidence/TIP_FREEZE_001/bin/RawrXD-Win32IDE.exe` |
| SHA256 | `748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145` |
| Hash re-verify | MATCH (untouched) |

## Relink

- Solo `link.exe` + regenerated `CMakeFiles\RawrXD-Win32IDE.rsp` (889 objs + 110 libs)
- `ninja -j1` aborted: corrupted `.ninja_deps` forced 744-TU rebuild
- Absorbed PathB crashfix objs (7b18e8fe) + ConPTY ASM obj in link
- SOURCE_WIRE: spawnSubAgent mutex/thread_local UUID + SwarmOrch setChatProvider

## Runtime prove (this SHA only)

| Check | Result |
|------|--------|
| RUNTIME_READY | 1 |
| LOAD_HTTP | 200 |
| n=1 orch | HTTP 200; WORKER_MODEL_LOADED=1 |
| n=2 orch | HTTP 200; ALIVE=1; measuredPeakParallel=2 |
| N2 disposition | `G16_A_INVOKED_PARTIAL_OR_FAIL` (RUNTIME_PASS=0; 1 completed / 1 timed_out) |
| Prior 8DC1406A n=2 | FAIL_CLOSED_HTTP_000 (historical; not invented PASS post-fix) |
| AgentRun max_tokens≤64 | HTTP 200 |
| PROMOTE | 0 |

Evidence: `evidence/SWARM_ORCH_N2_RESET_001/logs/prove_meta.txt`, `n2.body.txt`

## Next gate

Close partial orch (both workers complete) → PathB re-prove on 99EB54F2 → keep PROMOTE=0.
