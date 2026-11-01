# K2_D41B_OR_SCOPE_EXCEPTION_001 RECEIPT

```
ASOF_UTC=2026-10-31T02:59:26Z
SEAL=K2_D41B_OR_SCOPE_EXCEPTION_001
PARENT=WIN32IDE_CONTINUOUS_COMPLETION_001
GATE=K2_FULL_PRODUCT_GENERATION
RUN_ID=K2_D41B_001
CAND_SHA=D41BB1DBAAFC7B6AC9135EEA848F757EB0E3474B479DABED832296F69DE19F98
TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
tip748B=1
CAND_UNCHANGED=1
TIP_UNTOUCHED=1
PROMOTE=0
CERTIFIED=0
ABSORB=NOT_AUTHORIZED
TIP_CLIMB=HOLD
SCOPE_EXCEPTION_AUTHORIZED=0
SMALLER_QUANT_AVAILABLE=0
synthetic=0
EXITLEVEL=0
TD=11
CLEAN_EXIT=1
```

## What was closed

Prior continuous loop listed `NEXT_PRIORITY=K2_BLOCKED_OOM_OR_OPENISH_ORPHANS`
after PathB+N2+EXT sealed on live cand **D41B**. FD07-era K2
(`K2_FD07_OR_SCOPE_EXCEPTION_001`) does **not** transfer to D41B.

This seal **exercises** the same K2 product harness on live cand **D41BB1DB…**:

| Field | Value |
|------|------|
| EXE | `TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe` |
| Pre/Post SHA | D41BB1DB… MATCH (untouched) |
| Tip SHA | 748B210A… MATCH UNTOUCHED |
| Model | `F:\OllamaModels\...\Q4_K_M\...-00001-of-00013.gguf` |
| Quant | Q4_K_M only (sibling dirs 0 GGUF) |
| Index | 13/13 shards · 1096 tensors · arch=deepseek2 |
| PRODUCT_OPEN_PASS (early index) | 1 (index arm; ≠ generation) |
| SESSION_ENTER_PASS (early) | 1 |
| AUTO_BACKEND weights | 44152 MB |
| AUTO_BACKEND host RAM | 31216 MB |
| AUTO_BACKEND commit | 17953 MB |
| decision | Reject · Insufficient host memory |
| FAILED_STAGE | BACKEND_SELECT |
| FAILED_OWNER | NO_FEASIBLE_BACKEND |
| GENERATED_TOKENS | **0** |
| TOKEN_COMMIT_PASS | 0 |
| PRODUCT_PASS | 0 |
| CLEAN_EXIT | 1 (`TD=11`, EXITLEVEL=0) |

## Stubs (honest residual; invent-empty)

| Path | Disposition this seal |
|------|------------------------|
| `src/win32app/Win32IDE_private_stubs.cpp` | `#if 0` DO-NOT-LINK — WHY held; not product path |
| `src/win32app/digestion_engine_stub.cpp` | real-I/O orphan — WHY held; not invent theater; wire would require new cand SHA ≠ D41B |

No invent-empty drains reopened. No tip absorb. No PROMOTE flip.

## Disposition

| Gate | Result | Note |
|------|--------|------|
| D41B_K2_HARNESS_EXERCISED | **1** | Path to BACKEND_SELECT on D41B |
| K2_FULL_PRODUCT_GENERATION | **BLOCKED_OOM** | ≠ PASS |
| NOT_RUN | **0** (cleared on D41B) | Was unexercised on live cand |
| SCOPE_EXCEPTION | **NOT_AUTHORIZED** | Do not invent |
| K2_FULL_BLOCKED_SCOPE blocker | **REMAINS** | Still blocks PromoteReady emit / PROMOTE |
| PROMOTE | **0** | Unchanged |
| AUTH_BLOCKERS | **UNCHANGED** | ABSORB / R28 / CERTIFIED / EMIT / TIP_CLIMB |

## Non-claims

```
BLOCKED_OOM != PASS
INDEX_OPEN != GENERATION_PASS
PRODUCT_OPEN_PASS(early) != PRODUCT_PASS
SCOPE_EXCEPTION_NAME != SCOPE_EXCEPTION_AUTHORIZED
K2_D41B_EXERCISED != K2_blocker_cleared
FD07_K2_SEAL != D41B_transfer
PROMOTE_READY_CONJUNCTION=1 != PROMOTE=1
```

## Next (honest)

```
NEXT_PRIORITY=AUTH_X4_OR_CERTIFIED_OPEN_OR_SCHEDULER_MET_SCOPE
NEXT_GATE=POST_SCHEDULER_PROMOTION_REQUIREMENTS
```

K2 technical exercise on D41B is closed as BLOCKED_OOM. Remaining blockers are
process/auth (ABSORB×R28×CERTIFIED×PromoteReady_EMIT), CERTIFIED_OPEN, and
SCHEDULER_MET=BLOCKED_SCOPE — do not invent authorization or promotion.

## Artifacts

- `run_k2_d41b.bat`
- `HASHES_PRE.txt` / `HASHES_POST.txt`
- `run_meta_partial.txt`
- `logs/raw_stdout.log` / `logs/raw_stderr.log`
- Prior lineage: `K2_FD07_OR_SCOPE_EXCEPTION_001` (FD07; HISTORICAL vs D41B)
- Prior lineage: `K2_FULL_PRODUCT_GEN_002` (866E9D1B… BLOCKED_OOM)
