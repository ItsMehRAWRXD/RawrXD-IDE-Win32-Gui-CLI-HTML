# K2_338E_OR_SCOPE_EXCEPTION_001 RECEIPT

```
ASOF_UTC=2026-10-31T03:16:49Z
SEAL=K2_338E_OR_SCOPE_EXCEPTION_001
PARENT=WIN32IDE_CONTINUOUS_COMPLETION_002
GATE=K2_FULL_PRODUCT_GENERATION
RUN_ID=K2_338E_001
CAND_SHA=338ED81546989D731B687DB7FA07BC7C121D8328A4226739DF46254EBFDE801F
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

Callstack wire minted live cand **338ED815…** (BEFORE=57B9). Prior K2 seals
(`K2_FD07_*`, `K2_D41B_*`) do **not** transfer. This seal exercises the same
K2 product harness on live cand **338ED**:

| Field | Value |
|------|------|
| EXE | `TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe` |
| Pre/Post SHA | 338ED815… MATCH (untouched) |
| Tip SHA | 748B210A… MATCH UNTOUCHED |
| Model | `F:\OllamaModels\...\Q4_K_M\...-00001-of-00013.gguf` |
| Quant | Q4_K_M only |
| Index | 13/13 shards · 1096 tensors · arch=deepseek2 |
| AUTO_BACKEND weights | 44152 MB |
| AUTO_BACKEND host RAM | 30953 MB |
| AUTO_BACKEND commit | 18082 MB |
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
| 338E_K2_HARNESS_EXERCISED | **1** | Path to BACKEND_SELECT on 338ED |
| K2_FULL_PRODUCT_GENERATION | **BLOCKED_OOM** | ≠ PASS |
| NOT_RUN | **0** (cleared on 338ED) | |
| SCOPE_EXCEPTION | **NOT_AUTHORIZED** | Do not invent |
| K2_FULL_BLOCKED_SCOPE blocker | **REMAINS** | Still blocks PromoteReady emit / PROMOTE |
| PROMOTE | **0** | Unchanged |
| AUTH_BLOCKERS | **UNCHANGED** | ABSORB / R28 / CERTIFIED / EMIT / TIP_CLIMB |

## Non-claims

```
BLOCKED_OOM != PASS
INDEX_OPEN != GENERATION_PASS
SCOPE_EXCEPTION_NAME != SCOPE_EXCEPTION_AUTHORIZED
K2_338E_EXERCISED != K2_blocker_cleared
K2_D41B_SEAL != 338E_transfer
PROMOTE=0
```

## NEXT

```
NEXT_PRIORITY=AUTH_X4_OR_CERTIFIED_OPEN_OR_SCHEDULER_MET_SCOPE
NEXT_GATE=POST_SCHEDULER_PROMOTION_REQUIREMENTS
```

## Artifacts

- `HASHES_PRE.txt` / `HASHES_POST.txt`
- `run_k2_338e.bat` / `run_meta_partial.txt`
- `logs/raw_stdout.log` / `logs/raw_stderr.log`
- `SUMMARY.txt` / `RETURN_LINE.txt` / `LAW.txt`
