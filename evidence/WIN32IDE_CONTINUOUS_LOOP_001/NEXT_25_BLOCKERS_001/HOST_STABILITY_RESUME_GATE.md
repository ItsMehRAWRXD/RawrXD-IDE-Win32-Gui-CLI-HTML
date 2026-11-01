# Host stability resume gate (blockers 5–8)

ASOF_UTC=2026-11-01T08:20:00Z · PROMOTE=0 · tip748B frozen · invent=0

## Intent
Executable **assessment** for NEXT_25 blockers #5–#8 before heavy Win32IDE/K2 dispatch.

## Checklist (operator)

| Step | Action | Pass criterion |
|------|--------|----------------|
| 1 | Clean AMD reinstall (single driver stack) or disable unused GPUs while testing | No new `amdkmdag` 0x141/0x1B0 / `atiadlxx` AV for ≥4h light use |
| 2 | Confirm no dual unexpected boots in short window | Event Log: no Kernel-Power 41 / 6008 during soak |
| 3 | Fix crash dump capture (`volmgr` 45/46) | Minidump or MEMORY.DMP appears after controlled test OR dump driver loads clean at boot |
| 4 | Cap Cursor dual-process memory before long sessions | No Resource Exhaustion 2004 naming Cursor before any reset |

## Status this seal
- Recommendation issued: clean AMD reinstall + multi-GPU simplify while testing
- Host soak: **NOT_RUN** this session (operator action)
- Dump capture repair: **NOT_RUN**
- Blockers 5–8 remain **OPEN** until soak evidence lands

## Fail-closed
`SUSPECT ≠ ROOT_CAUSE` · `NOT_RUN ≠ PASS` · No invent PRODUCT_PASS from host checklist alone.
