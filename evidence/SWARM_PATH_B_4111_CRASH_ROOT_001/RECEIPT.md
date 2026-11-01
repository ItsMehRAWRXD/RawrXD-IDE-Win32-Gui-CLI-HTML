# SWARM_PATH_B_4111_CRASH_ROOT_001 — RECEIPT

```
ASOF_UTC=2026-10-29T10:45:00Z
DISPOSITION=DUMP_CAPTURED_ROOT_PARTIAL_SOURCE_WIRE_PATHB_PASS_0
DUMP_CAPTURED=1
PATHB_4111_RUNTIME_PASS=0
READY_FOR_PATHB_REPROVE=1
PROMOTE=0
TIP_CLIMB=HOLD
ABSORB=NOT_AUTHORIZED
CERTIFIED=0
NO_INVENT_PASS=1
REBUILD_TIP=0
```

## SHA confirm

| Role | SHA256 | Status |
|------|--------|--------|
| Tip `TIP_FREEZE_001\bin` | `748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145` | MATCH UNTOUCHED |
| Historical pin PathB crash | `2F3727A6CD8EFF4E934E45C51494B926489FFAD1BC5430B072F3D5BAEE0007C2` | PRESERVED `bin_pinned_2F3727A6\` |
| Live repair candidate | `D11AB5B695B46688348CA34131150F0E543191B4524B6E1F6568CA098D2B0862` | NEW (≠748B ≠2F3727A6) |
| Interim VEH-unwind candidate | `283D2CF6704B3D138B9196FED082D47EDD4A3949106C3AA81E01789617E94621` | SUPERSEDED (mis-unwind) |

## Four required evidence fields (controlling pin 2F3727A6)

From `dumps/FIRST_CHANCE_WM_COMMAND_2F3727A6_repro.txt` + `dumps/RawrXD-Win32IDE_2F3727A6_PathB4111.dmp` + MAP:

1. **EXCEPTION_ADDRESS** = `0x00007FFD6974097D` (first-chance `0xC0000005`); dump terminal stream also recorded `0xC0000374` @ `0x00007FFD7A6E2FC5` (ntdll heap FailFast, TID matched VEH)
2. **FAULTING_INSTRUCTION** = `atiadlxx.dll+0x7097D` bytes `49 89 06 4C 63 03 4D 69 C0 24 06 00 00 48 8B 53` (`dumps/FAULTING_INSTRUCTION_BYTES.txt`)
3. **CALL_STACK** (top) = ntdll KiUserException → **atiadlxx+0x7097D** → RawrXD+`0x18FD6DB` → +`0x18FD829` → +`0x18FD8FF` → +`0x4A1C51` → … → USER32 → RawrXD message loop
4. **SOURCE_LINE** = `atiadlxx.dll+0x7097D` ; caller MAP-near `ProbeAmdGpuPowerBackend` (`AmdGpuPowerBackend.cpp`, preferred `0x1418FD840`) / ProbeAdl2 path. PDB line numbers UNRESOLVED (SymType deferred). Classification: **UI_THREAD_ADL_CALLBACK ≠ executeSwarm body** (body is detached `std::thread`)

## Root cause

`ROOT_CAUSE=UI_THREAD_AMD_ADL_AV` (`atiadlxx+0x7097D`, dual-GPU stack) concurrent with PathB 4111 after `BEFORE_executeSwarm`; secondary heap FailFast `0xC0000374`. N2 headless PASS does not transfer.

## SOURCE_WIRE

| Item | Value |
|------|-------|
| SOURCE_WIRED | 1 (narrow) |
| Change | `AmdGpuPowerBackend.cpp`: always IAT-block `atiadlxx` loads + skip GPU power probe in `InitGpuPowerProbeMainThread` (no VEH unwind — 283D mis-unwind left heap RIP) |
| Also | `Win32IDE_SubAgent.cpp` async breadcrumbs (`ASYNC_SPAWN` / `BODY_ENTER` / `BODY_RETURN`) |
| Note | `P1PRA_ProcessState.cpp` ADL VEH **not in** `RawrXD-Win32IDE.rsp` (unlinked) |

## PathB status

| Candidate | MenuReady | ENTER | RETURN | EXIT | RUNTIME_PASS |
|-----------|-----------|-------|--------|------|--------------|
| 2F3727A6 (pin) | 1 | 1 | 0 | 0xC0000005 | 0 |
| 283D2CF6 | 0 | 0 | 0 | 0xC0000005 early | 0 |
| D11AB5B6 (live) | 1 | NOT_OBSERVED in crumb | 0 | 0xC0000374 | 0 |

`COMPLETED≠2` · `GUI_RESPONSIVE` not held through exit · **NOT_RUN≠PASS** · **READY_FOR_PATHB_REPROVE=1**

## Artifacts

- `dumps/RawrXD-Win32IDE_2F3727A6_PathB4111.dmp` (~493MB)
- `dumps/FOUR_FIELD_EVIDENCE.txt`
- `dumps/DUMP_EXCEPTION_STREAM.txt`
- `dumps/FAULTING_INSTRUCTION_BYTES.txt`
- `reprove_D11AB5B6/` (smoke)
- Solo link: `build_win32ide_link001` only

## Next gate

`NEXT_GATE=PathB_4111_reprove_D11AB5B6` with dump on `0xC0000374` after ADL load-block (heap root still OPEN; ADL first-chance on pin CLOSED as UI-ADL). `PROMOTE=0` `TIP_CLIMB=HOLD`
