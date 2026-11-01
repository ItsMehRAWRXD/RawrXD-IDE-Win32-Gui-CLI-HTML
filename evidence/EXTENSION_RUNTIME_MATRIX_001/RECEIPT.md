# EXTENSION_RUNTIME_MATRIX_001 — RECEIPT

```
GATE=EXTENSION_RUNTIME_MATRIX_001
ASOF_UTC=2026-10-30T17:03:47Z
EXE_SHA256=73368D764EB8B2C632994542D6E2256668F1752F10E3CDBF08546343D793E738
TIP_SHA256=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
tip748B=1 TIP_REBUILD=0 ABSORB=NOT_AUTHORIZED
PROMOTE=0 CERTIFIED=0
EXTENSION_RUNTIME=FAIL
NEXT_GATE=POST_PATHB_PASS_PROMOTION_HELD
```

## Context read (preconditions)

| Cite | Result |
|------|--------|
| `AUDIT_002_OPENISH_EXTENSION_DRAIN_002/RECEIPT.md` | invent-empty sealed; RUNTIME_REACHED=NOT_RUN; residual EXTENSION=8 |
| `AUDIT_002_OPENISH_EXTENSION_DRAIN_002/INVENT_ELIGIBLE_ENUM.txt` | 5 gated invent; 8 real/partial held |
| `WIN32IDE_CONTINUOUS_LOOP_001/ACTIVE_NOW.md` | item 4 dispatched; cand live=73368; PathB PASS ≠ extension |
| `SWARM_PATH_B_4111_ACCEPTANCE_CLOSE_001/RECEIPT.md` | PathB RUNTIME_PASS=1 on 73368; tip untouched |
| `VEH_MSFTEDIT_FIRST_CHANCE_DUMP_001` | MINIDUMP=PRESENT CLASS=BENIGN_SURVIVED VEH_FATAL=0 (≠ this matrix) |

## Executable under test

| Binary | SHA256 | Role |
|--------|--------|------|
| `TIP_CANDIDATE_AGENT_RUN_005\bin\RawrXD-Win32IDE.exe` | `73368D764EB8B2C632994542D6E2256668F1752F10E3CDBF08546343D793E738` | **ONLY** matrix target |
| `TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe` | `748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145` | tip untouched MATCH |

## What ran

1. Headless LocalServer on `127.0.0.1:19140` — EXE 73368 (`harness_ext_runtime_73368.ps1`).
2. Exercised `/api/extensions/*` discovery/manifest/activation/toggles/host — all returned `adapter=product_thin` HTTP 200.
3. `/api/tool` + `/api/command` extension.activate → HTTP 403 (no extension tool grant/surface).
4. GUI launch: `RawrXD_IDE_MainWindow` + `MainMenuReady`; PostMessage WM_COMMAND IDM_EXT_11810..11814; PingNull OK; process alive.
5. Tip/cand SHA re-hash after run — tip748B=1 candMatch=1.

## Cell dispositions

| Cell | Disposition | Why |
|------|-------------|-----|
| DISCOVERY | **FAIL** | product_thin empty total=0 |
| MANIFEST_LOAD | **FAIL** | product_thin acknowledge ≠ ManifestLoader::Load |
| ACTIVATION | **FAIL** | product_thin; host_pid=0 |
| COMMANDS | **FAIL** | headless 403; GUI IDM_EXT_* posted but FEATURE_FICTION command path |
| TOGGLES | **FAIL** | product_thin enable/disable; GUI fiction posts |
| FAILURE_ISOLATION | **BLOCKED** | MISSING_DEPENDENCY=ExtensionHost child (host_pid real) |

```
PASS=0 FAIL=5 NOT_RUN=0 BLOCKED=1
EXTENSION_RUNTIME=FAIL
```

## Artifacts

- `harness_ext_runtime_73368.ps1`
- `LAW.txt` `MATRIX.md` `COUNTS.txt` `SUMMARY.txt` `RECEIPT.md`
- `logs/` — RUNLOG, per-cell meta/body/hdr, exe_sha, tip_sha, COUNTS_RUNTIME.txt

## Explicit non-claims

```
SOURCE_WIRED != RUNTIME_REACHED != PASS
PathB RUNTIME_PASS != EXTENSION_RUNTIME
EXTENSION_INVENT_EMPTY != EXTENSION_RUNTIME PASS
product_thin != real extension host
NOT_RUN != PASS
PROMOTE=0 ABSORB=NOT_AUTHORIZED CERTIFIED=0
TIP_748B_UNTOUCHED=1
```
