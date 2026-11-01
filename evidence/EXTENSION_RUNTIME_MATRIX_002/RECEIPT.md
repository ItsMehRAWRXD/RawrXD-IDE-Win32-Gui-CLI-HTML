# EXTENSION_RUNTIME_MATRIX_002 — RECEIPT

```
GATE=EXTENSION_RUNTIME_MATRIX_002
ASOF_UTC=2026-10-31T00:56:55Z
EXE_SHA256=FD07CA615E35F04EBFE66EA583ABDE10BFDA56A08656E8B1A8ECA1B1C2851540
CAND_SHA_BEFORE_REPAIR=73368D764EB8B2C632994542D6E2256668F1752F10E3CDBF08546343D793E738
TIP_SHA256=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
HOST_SHA256=CA89BA092BE92F5F5FAD94AE56996736A9CA5A7E5AEDF793F0F3D08FB9A18462
tip748B=1 TIP_REBUILD=0 ABSORB=NOT_AUTHORIZED
PROMOTE=0 CERTIFIED=0
EXTENSION_RUNTIME=PASS
FIRST_FAILURE_BOUNDARY=NONE
NEXT_GATE=POST_SCHEDULER_PROMOTION_REQUIREMENTS
GHOSTTEXT_REOPEN=0
```

## Executable under test

| Binary | SHA256 | Role |
|--------|--------|------|
| `TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe` | `FD07CA615E35F04EBFE66EA583ABDE10BFDA56A08656E8B1A8ECA1B1C2851540` | **ONLY** matrix target (post-repair relink) |
| Prior cand 73368 (historical) | `73368D764EB8B2C632994542D6E2256668F1752F10E3CDBF08546343D793E738` | PathB seal stays; MATRIX_001 FAIL baseline |
| `TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe` | `748B210A…` | tip untouched MATCH |
| `RawrXD-ExtensionHost.exe` (cand bin) | `CA89BA09…` | real child for host_pid |

## What ran

1. Headless LocalServer on `127.0.0.1:19142` — cand `FD07CA61` (`harness_ext_runtime_matrix_002.ps1`).
2. Discovery scanned MATRIX_002 fixtures → real adapter, total≥1.
3. Manifest: good package.json load; malformed + missing.vsix FAIL_CLOSED; IDE alive.
4. Activation spawned ExtensionHost; host_pid real.
5. MOTD via `/api/tool` read_motd (workspace resolve); then `extension.activate` tool PASS.
6. Toggles persisted to disk; host kill + reactivate; IDE survived.

## Cell dispositions

| Cell | Disposition |
|------|-------------|
| DISCOVERY | **PASS** |
| MANIFEST_LOAD | **PASS** |
| ACTIVATION | **PASS** |
| COMMANDS | **PASS** |
| TOGGLES | **PASS** |
| FAILURE_ISOLATION | **PASS** |

```
PASS=6 FAIL=0 NOT_RUN=0 BLOCKED=0
EXTENSION_RUNTIME=PASS
```

## Explicit non-claims

```
SOURCE_WIRED != alone PASS (runtime cells exercised)
PathB RUNTIME_PASS on 73368 stays historical; cand SHA changed → PathB not re-claimed here
PROMOTE=0 ABSORB=NOT_AUTHORIZED CERTIFIED=0
TIP_748B_UNTOUCHED=1
GHOSTTEXT_REOPEN=0
EXTENSION_RUNTIME_PASS != PROMOTE
NEXT_GATE=POST_SCHEDULER_PROMOTION_REQUIREMENTS
```
