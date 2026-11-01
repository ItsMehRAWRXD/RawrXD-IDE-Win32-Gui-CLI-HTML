# AUDIT_002_OPENISH_OTHER_DRAIN_013 — RECEIPT

```
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_SHA256=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
TIP_MATCH=1 TIP_REBUILD=0 ABSORB=NOT_AUTHORIZED
RUNTIME_REACHED=NOT_RUN
PARENT=AUDIT_002_OPENISH_OTHER_DRAIN_012
PRIOR=AUDIT_002_OPENISH_OTHER_DRAIN_012
ASOF_UTC=2026-10-29T13:12:02Z
```

## Verdict

Next OTHER residual empty-true / fake-ready orphans SOURCE_WIRE gated
(9 sites). OPENISH 153→144; GATEDISH 170→179; OTHER 89→80.
Tip 748B untouched. PERFECT=0 — OPENISH residual + NOT_RUN ≠ PASS.
No ninja/RELINK (sibling PathB EXE ownership). GhostText ABSORB=NOT_AUTHORIZED.
DRAIN_008/009/010/011/012 sites not re-touched.

## Files touched (SOURCE_WIRE fail-close)

| Path | Change |
|------|--------|
| `src/win32app/SessionController.cpp` | invent SessionPhase::Ready → FAIL_CLOSED |
| `src/win32app/Win32IDE_TerminalTabs.cpp` | invent terminal-tabs Initialized → FAIL_CLOSED |
| `src/win32app/Win32IDE_Window.cpp` | invent Inference/Ghost ready LOG → FAIL_CLOSED |
| `src/win32app/Win32IDE_SmoothScroll.cpp` | invent smooth-scroll initialized → FAIL_CLOSED |
| `src/win32app/Win32IDE_SignatureHelp.cpp` | invent signature-help Initialized → FAIL_CLOSED |
| `src/win32app/Win32IDE_EditorCommands.cpp` | invent editor-command ready → FAIL_CLOSED |
| `src/win32app/Win32IDE_Core_HEAD.cpp` | invent Speculative/Vulkan/GGUF/Voice ready → FAIL_CLOSED |
| `src/win32app/CompilerIntegration.cpp` | invent compiler-integration ready → FAIL_CLOSED |
| `src/win32app/IDE_Telemetry.cpp` | invent Telemetry/UIWatchdog Initialized → FAIL_CLOSED |

## Return

| OPENISH before | OPENISH after | gated+ | NEXT_GATE |
|---------------:|--------------:|-------:|-----------|
| **153** | **144** | **+9** | `AUDIT_002_OPENISH_OTHER_DRAIN_014` |
