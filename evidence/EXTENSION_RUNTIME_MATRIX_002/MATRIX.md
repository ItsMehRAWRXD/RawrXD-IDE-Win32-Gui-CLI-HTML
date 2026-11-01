# EXTENSION_RUNTIME_MATRIX_002

| Cell | Disposition | Evidence |
|------|-------------|----------|
| DISCOVERY | **PASS** | `/api/extensions/scan` adapter=`product_extension_runtime` total≥1 |
| MANIFEST_LOAD | **PASS** | good fixture load + bad/missing FAIL_CLOSED; IDE alive |
| ACTIVATION | **PASS** | activate success; `host_pid` real (≥1) |
| COMMANDS | **PASS** | MOTD ack then `/api/tool` `extension.activate` HTTP 200 |
| TOGGLES | **PASS** | enable/disable `persisted:true` real adapter |
| FAILURE_ISOLATION | **PASS** | host kill + reactivate; IDE survives; ping OK |

```
PASS=6 FAIL=0 NOT_RUN=0 BLOCKED=0
EXTENSION_RUNTIME=PASS
PROMOTE=0 tip748B=1
```
