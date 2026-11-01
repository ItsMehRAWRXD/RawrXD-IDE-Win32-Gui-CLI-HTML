# EXTENSION_RUNTIME_MATRIX_001 — MATRIX

```
EXE_SHA256=73368D764EB8B2C632994542D6E2256668F1752F10E3CDBF08546343D793E738
TIP_SHA256=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
tip748B=1 TIP_REBUILD=0 ABSORB=NOT_AUTHORIZED PROMOTE=0
ASOF_UTC=2026-10-30T17:03:47Z
PATHB_RUNTIME_PASS_NEQ_EXTENSION=1
```

## Cells (runtime against cand 73368 only)

| # | Cell | Surface exercised | Evidence | Disposition |
|---|------|-------------------|----------|-------------|
| 1 | DISCOVERY | GET `/api/extensions/scan\|list\|installed` | `logs/cell_discovery_*` body `adapter=product_thin` total=0 | **FAIL** |
| 2 | MANIFEST_LOAD | POST `/api/extensions/load-vsix` + `/install` | `logs/cell_manifest_*` product_thin acknowledge | **FAIL** |
| 3 | ACTIVATION | POST `/api/extensions/activate` + GET `/host/status` | `host_pid:0` product_thin; no real host | **FAIL** |
| 4 | COMMANDS | HEADLESS `/api/tool`+`/api/command` (403); GUI WM_COMMAND IDM_EXT_11810..11814 | GUI posts delivered + PingNull; FEATURE_FICTION command path | **FAIL** |
| 5 | TOGGLES | POST `/enable`+`/disable`; GUI IDM_EXT_ENABLE/DISABLE | product_thin + fiction posts | **FAIL** |
| 6 | FAILURE_ISOLATION | host/kill + bad activate + process ping | alive=1 but `host_pid:0` — cannot isolate ExtensionHost child | **BLOCKED** |

## Counts

| PASS | FAIL | NOT_RUN | BLOCKED |
|-----:|-----:|--------:|--------:|
| **0** | **5** | **0** | **1** |

## BLOCKED dependency (exact)

```
CELL=FAILURE_ISOLATION
MISSING_DEPENDENCY=ExtensionHost child process (host_pid real)
REASON=product_thin /api/extensions/host/status returns host_pid:0;
       thin-adapter HTTP survival != extension failure isolation
```

## Explicit non-claims

```
NOT_RUN != PASS
product_thin HTTP 200 != EXTENSION_RUNTIME PASS
PathB RUNTIME_PASS != EXTENSION_RUNTIME
EXTENSION_DRAIN_002 invent-empty != runtime cert
GUI IDM_EXT_* PostMessage != handleExtensionCommand product PASS
PROMOTE=0 CERTIFIED=0 tip748B=1
```

## Residual EXTENSION TUs (source; not invent PASS)

From `AUDIT_002_OPENISH_EXTENSION_DRAIN_002/INVENT_ELIGIBLE_ENUM.txt` — 8 real/partial held; this matrix does not upgrade them to RUNTIME PASS.
