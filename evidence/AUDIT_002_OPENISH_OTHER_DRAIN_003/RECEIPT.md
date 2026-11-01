# AUDIT_002_OPENISH_OTHER_DRAIN_003 — RECEIPT

```
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_SHA256=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
TIP_MATCH=1 TIP_REBUILD=0 ABSORB=NOT_AUTHORIZED
RUNTIME_REACHED=NOT_RUN
PARENT=AUDIT_002_OPENISH_OTHER_DRAIN_002
PRIOR=AUDIT_002_OPENISH_OTHER_DRAIN_002
ASOF_UTC=2026-10-29T13:49:50Z
```

## Verdict

Next OTHER residual empty-true / fake-ready orphans SOURCE_WIRE gated
(9 sites). OPENISH 243→234; GATEDISH 80→89; OTHER 179→170.
Tip 748B untouched. PERFECT=0 — OPENISH residual + NOT_RUN ≠ PASS.
No ninja/RELINK (sibling EXE ownership). GhostText ABSORB=NOT_AUTHORIZED.

## Files touched (SOURCE_WIRE fail-close)

| Path | Change |
|------|--------|
| `src/win32app/Win32IDE_SpeciatorEvents.cpp` | OnModelSelected invent true → FAIL_CLOSED |
| `src/win32app/Win32IDE_MeshBrainEvents.cpp` | OnClusterRequested invent true → FAIL_CLOSED |
| `src/win32app/Win32IDE_ArchVerifier.cpp` | invent true / 0xDEADBEEF → FAIL_CLOSED false/0 |
| `src/win32app/Win32IDE_TaskEvents.cpp` | OnTaskRequested invent true → FAIL_CLOSED |
| `src/win32app/Win32IDE_ChatEvents.cpp` | OnSendMessage invent true → FAIL_CLOSED |
| `src/win32app/Win32IDE_FileSystemEvents.cpp` | OnFileOpened invent true → FAIL_CLOSED |
| `src/win32app/Win32IDE_ActionGraph.cpp` | Simulate COMPLETED invent → FAIL_CLOSED FAILED |
| `src/win32app/Win32IDE_TensorMetadata.cpp` | invent true / 0x0800 → FAIL_CLOSED false/0 |
| `src/win32app/Win32IDE_GGUF_Reader.cpp` | invent true / fake meta → FAIL_CLOSED false/null |

## Return

| OPENISH before | OPENISH after | gated+ | NEXT_GATE |
|---------------:|--------------:|-------:|-----------|
| **243** | **234** | **+9** | `AUDIT_002_OPENISH_OTHER_DRAIN_004` |
