# BREAKPOINT_MANAGER_PRODUCT_WIRE_001 RECEIPT

```
ASOF_UTC=2026-10-31T03:46:04Z
SEAL=BREAKPOINT_MANAGER_PRODUCT_WIRE_001
PARENT=WIN32IDE_CONTINUOUS_COMPLETION_004
CAND_SHA_BEFORE=0C44110A45FAACCCFDCE31FC307CB8B34D8193B2754BED197C16FDFBED00F993
CAND_SHA_AFTER=7C1622A35BA21F86E95FFB69713F1DBF93793084584E10917942E8A937B0D964
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

OPENISH DEBUGGER orphan `BreakpointManagerPanel.cpp` (real CreateWindow ListView BP panel)
was unlinked. `cmdDbgListBPs` dumped engine JSON only — no panel product surface.

### Source wire

| Site | Change |
|------|--------|
| `BreakpointManagerPanel.cpp` | `SetCallbacks` body (was missing) |
| `Win32IDE_BreakpointManagerUI.cpp` | NEW C bridge: Show/Sync/List from NativeDebuggerEngine |
| `Win32IDE_NativeDebugPanel.cpp` | `cmdDbgListBPs` ? `RawrXD_UI_ListBreakpointsAndShowPanel` |
| link | add BreakpointManagerPanel + PropertiesDialog + BreakpointManagerUI objs |

### Build / runtime

| Field | Value |
|------|------|
| Compile | Panel+PropsDialog+UI+NativeDebugPanel EXIT=0 |
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
| TasksDebugUI | LINKED (COMPLETION_003) |
| BreakpointManagerPanel | LINKED (this seal) |
| DAPIntegrationBridge | needs gated DAPServer — held |
| DebuggerIntegration | DapService/CallStackPanel deps absent — held |
| NativeDebugPanel_impl | MinGW refuse — DO-NOT-LINK |

## Non-claims

```
SOURCE_WIRED BreakpointManagerPanel != GUI E2E BP hit certified
NEW_SHA != 0C44 transfer
BreakpointPropertiesDialog FEATURE_FICTION Show held
PROMOTE=0
K2 HOST_BLOCKED unchanged SCOPE_EXCEPTION=0
```

## NEXT

DebuggerIntegration product orphan (requires CallStackPanel/DapService link graph)
OR IDM_DBGWATCH_SHOW crash (RUNTIME_AUDIT FAIL_CLOSED)
OR K2 host residency / AUTH×4 / CERTIFIED_OPEN
