# AUDIT_002_OPENISH_EXTENSION_DRAIN_001 — RECEIPT

```
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_SHA256=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
TIP_MATCH=1 TIP_REBUILD=0 ABSORB=NOT_AUTHORIZED
RUNTIME_REACHED=NOT_RUN
PARENT=AUDIT_002_OPENISH_OTHER_DRAIN_022
PRIOR=AUDIT_002_OPENISH_OTHER_DRAIN_022
ASOF_UTC=2026-10-29T19:35:00Z
SHORT_BATCH=0
OTHER_INVENT_EMPTY=1
```

## Verdict

Enumerated EXTENSION bucket (23). Gated next 10 invent-eligible empty-true /
fake-ready sites SOURCE_WIRE FAIL_CLOSED. OPENISH 72→62; EXTENSION 23→13;
GATEDISH 251→261; gated+10. Tip 748B untouched MATCH. PERFECT=0 — OPENISH
residual + NOT_RUN ≠ PASS. No ninja/RELINK. OTHER DRAIN_008..022 sites not
re-touched (spot-check OK). OTHER=8 invent-empty residual held.

## Files touched (SOURCE_WIRE fail-close)

| Path | Change |
|------|--------|
| `src/win32app/ExtensionEngine.asm` | invent Init ready → FAIL_CLOSED |
| `src/win32app/ExtensionEngine_bridge.cpp` | invent bridge Init ready → FAIL_CLOSED |
| `src/win32app/ExtensionAPI_VSCode_Dispatcher.cpp` | invent dispatcher ready → FAIL_CLOSED |
| `src/win32app/ExtensionHost.cpp` | invent ActivateExtension active → FAIL_CLOSED |
| `src/win32app/ExtensionManager.cpp` | invent LoadExtension ready → FAIL_CLOSED |
| `src/win32app/ExtensionSecurityCheck.cpp` | invent Security PASSED → FAIL_CLOSED |
| `src/win32app/ExtensionRunnerMock.cpp` | invent mock-runner ready → FAIL_CLOSED |
| `src/win32app/Win32IDE_ExtensionsPanel.cpp` | invent install/enable/update → FAIL_CLOSED |
| `src/win32app/ExtensionAPI_VSCode.cpp` | invent SaveAll ready → FAIL_CLOSED |
| `src/win32app/Win32IDE_ExtensionManager.cpp` | invent listExtensions ready → FAIL_CLOSED |

## Return

| OPENISH before | OPENISH after | EXTENSION before | EXTENSION after | gated+ | tip748B | RUNTIME | NEXT_GATE |
|---------------:|--------------:|-----------------:|----------------:|-------:|:-------:|:--------:|-----------|
| **72** | **62** | **23** | **13** | **+10** | **1** | **NOT_RUN** | `EXTENSION_DRAIN_002` |
