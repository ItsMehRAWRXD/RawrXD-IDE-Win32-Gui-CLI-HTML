# AUDIT_002_OPENISH_OTHER_DRAIN_006 — RECEIPT

```
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_SHA256=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
TIP_MATCH=1 TIP_REBUILD=0 ABSORB=NOT_AUTHORIZED
RUNTIME_REACHED=NOT_RUN
PARENT=AUDIT_002_OPENISH_OTHER_DRAIN_005
PRIOR=AUDIT_002_OPENISH_OTHER_DRAIN_005
ASOF_UTC=2026-10-29T14:45:32Z
```

## Verdict

Next OTHER residual empty-true / fake-ready orphans SOURCE_WIRE gated
(9 sites). OPENISH 216→207; GATEDISH 107→116; OTHER 152→143.
Tip 748B untouched. PERFECT=0 — OPENISH residual + NOT_RUN ≠ PASS.
No ninja/RELINK (sibling EXE ownership). GhostText ABSORB=NOT_AUTHORIZED.

## Files touched (SOURCE_WIRE fail-close)

| Path | Change |
|------|--------|
| `src/win32app/Win32IDE_GGUFManifold.cpp` | invent loaded=1 → FAIL_CLOSED 0 |
| `src/win32app/Win32IDE_AgentCursorOverlay.cpp` | invent visible overlay → FAIL_CLOSED 0 |
| `src/win32app/Win32IDE_TBA_LinkGraph.cpp` | invent link active theater → FAIL_CLOSED 0 |
| `src/win32app/Win32IDE_ContextGovernor.cpp` | invent context active → FAIL_CLOSED 0 |
| `src/win32app/RawrXD_AgentKernel.cpp` | invent AGENT_RUNNING → FAIL_CLOSED 0 |
| `src/win32app/Win32IDE_Hermes.cpp` | invent peer mesh handshake → FAIL_CLOSED |
| `src/win32app/Win32IDE_Quantum.cpp` | invent Online/Active list → FAIL_CLOSED |
| `src/win32app/RawrXD_Scheduler_Shutdown.cpp` | invent running=true → FAIL_CLOSED |
| `src/win32app/RawrXD_Infinity_Shutdown.cpp` | invent running=true → FAIL_CLOSED |

## Return

| OPENISH before | OPENISH after | gated+ | NEXT_GATE |
|---------------:|--------------:|-------:|-----------|
| **216** | **207** | **+9** | `AUDIT_002_OPENISH_OTHER_DRAIN_007` |
