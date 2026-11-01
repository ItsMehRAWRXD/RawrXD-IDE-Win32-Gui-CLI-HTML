# TASKS_DEBUG_UI_PRODUCT_WIRE_001 RECEIPT

```
ASOF_UTC=2026-10-31T03:30:17Z
SEAL=TASKS_DEBUG_UI_PRODUCT_WIRE_001
PARENT=WIN32IDE_CONTINUOUS_COMPLETION_003
CAND_SHA_BEFORE=338ED81546989D731B687DB7FA07BC7C121D8328A4226739DF46254EBFDE801F
CAND_SHA_AFTER=0C44110A45FAACCCFDCE31FC307CB8B34D8193B2754BED197C16FDFBED00F993
TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
tip748B=1
PROMOTE=0
ABSORB=NOT_AUTHORIZED
TIP_CLIMB=HOLD
CERTIFIED=0
SMOKE_PASS=1
PathB=RUNTIME_PASS
N2=G16_A_BOTH_COMPLETE
EXT=PASS_6
synthetic=0
```

## Gap closed

OPENISH DEBUGGER orphan `Win32IDE_TasksDebugUI.cpp` (real TaskManager_* launch/task
binding) was unlinked; forward decls had no C surface. VSCode task/launch commands
(5929–5932) used ad-hoc CreateProcess/runBuild paths instead of TaskManager.

### Source wire

| Site | Change |
|------|--------|
| `Win32IDE_Tasks.cpp` | `getAttachedPid` + `TaskManager_listTasks/listLaunchConfigs/runTask/executeLaunchConfig` C bridge |
| `Win32IDE_Commands.cpp` | 5929–5932 → `RawrXD_UI_List*/RunTask/StartDebugging` |
| link | add `Win32IDE_TasksDebugUI.cpp.obj` (cand orphans prepend; CallStackSymbols retained) |

### Build / runtime

| Field | Value |
|------|------|
| Compile | Tasks+TasksDebugUI+Commands EXIT=0 |
| Relink | cand only LINK_EXIT=0 |
| Tip | 748B UNTOUCHED |
| Smoke | ACTIVATE/ENABLE EXT API PASS |
| PathB | RUNTIME_PASS |
| N2 | BOTH_COMPLETE |
| EXT | PASS=6 |

## Residual DEBUGGER (post-wire)

| Orphan | Disposition |
|--------|-------------|
| CallStackSymbols | LINKED (COMPLETION_002) |
| TasksDebugUI | LINKED (this seal) |
| BreakpointManagerPanel | real CreateWindow ListView — still unlinked |
| DAPIntegrationBridge | needs gated DAPServer — held |
| DebuggerIntegration | DapService/CallStackPanel deps — still unlinked |
| NativeDebugPanel_impl | MinGW refuse — DO-NOT-LINK |

## Non-claims

```
SOURCE_WIRED TasksDebugUI != GUI TaskRunner invent ungated
NEW_SHA != 338E transfer
OTHER TaskRunner FEATURE_FICTION untouched
PROMOTE=0
K2 HOST_BLOCKED unchanged SCOPE_EXCEPTION=0
```

## NEXT

BreakpointManagerPanel / DebuggerIntegration product orphan wire
OR K2 host residency (weights ~44GiB > free ~30GiB; SCOPE_EXCEPTION=0)
OR AUTH×4 / CERTIFIED_OPEN (auth blockers unchanged).
