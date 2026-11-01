# K2_FD07_OR_SCOPE_EXCEPTION_001 RECEIPT

```
ASOF_UTC=2026-10-31T02:22:16Z
SEAL=K2_FD07_OR_SCOPE_EXCEPTION_001
PARENT=WIN32IDE_CONTINUOUS_COMPLETION_001
GATE=K2_FULL_PRODUCT_GENERATION
CAND_SHA=FD07CA615E35F04EBFE66EA583ABDE10BFDA56A08656E8B1A8ECA1B1C2851540
TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
tip748B=1
CAND_UNCHANGED=1
TIP_UNTOUCHED=1
PROMOTE=0
CERTIFIED=0
ABSORB=NOT_AUTHORIZED
TIP_CLIMB=HOLD
SCOPE_EXCEPTION_AUTHORIZED=0
synthetic=0
```

## What was closed

Prior readiness proof #3 cited K2 on FD07 as `BLOCKED_SCOPE` / **NOT_RUN**
(lineage only from `K2_FULL_PRODUCT_GEN_002` on SHA `866E9D1B…`).

This seal **exercises** the same K2 product harness on live cand **FD07CA61…**:

| Field | Value |
|------|------|
| EXE | `TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe` |
| Pre/Post SHA | FD07CA61… MATCH (untouched) |
| Model | `F:\OllamaModels\...\Q4_K_M\...-00001-of-00013.gguf` |
| Quant | Q4_K_M only (sibling dirs 0 GGUF) |
| Index | 13/13 shards · 1096 tensors · arch=deepseek2 |
| PRODUCT_OPEN_PASS (early index) | 1 (index arm; ≠ generation) |
| SESSION_ENTER_PASS (early) | 1 |
| AUTO_BACKEND weights | 44152 MB |
| AUTO_BACKEND host RAM | 32836 MB |
| AUTO_BACKEND commit | 19569 MB |
| Host TotalVisibleMemory | 63093 MB (≠ AUTO_BACKEND host RAM) |
| decision | Reject · Insufficient host memory |
| FAILED_STAGE | BACKEND_SELECT |
| FAILED_OWNER | NO_FEASIBLE_BACKEND |
| GENERATED_TOKENS | **0** |
| TOKEN_COMMIT_PASS | 0 |
| PRODUCT_PASS | 0 |
| CLEAN_EXIT | 1 (`TD=11`) |

## Disposition

| Gate | Result | Note |
|------|--------|------|
| FD07_K2_HARNESS_EXERCISED | **1** | Path to BACKEND_SELECT on FD07 |
| K2_FULL_PRODUCT_GENERATION | **BLOCKED_OOM** | ≠ PASS |
| NOT_RUN | **0** (cleared) | Was NOT_RUN on FD07; now exercised |
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
K2_FD07_EXERCISED != K2_blocker_cleared
PROMOTE_READY_CONJUNCTION=1 != PROMOTE=1
```

## Artifacts

- `run_k2_fd07.bat`
- `HASHES_PRE.txt` / `HASHES_POST.txt`
- `run_meta_partial.txt`
- `logs/raw_stdout.log` / `logs/raw_stderr.log`
- Prior lineage: `evidence/K2_FULL_PRODUCT_GEN_002/` (866E9D1B… BLOCKED_OOM)
