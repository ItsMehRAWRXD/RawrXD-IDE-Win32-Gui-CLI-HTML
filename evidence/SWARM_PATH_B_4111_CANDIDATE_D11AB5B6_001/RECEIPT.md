# SWARM_PATH_B_4111_CANDIDATE_D11AB5B6_001 — RECEIPT

```
ASOF_UTC=2026-10-29T10:59:05Z
DISPOSITION=PATH_B_MENU_READY_THEN_HEAP_FAILFAST_BEFORE_4111_ENTER
RUNTIME_PASS=0
DUMP_CAPTURED=0
VEH_STACK_CAPTURED=1
PROMOTE=0
TIP_CLIMB=HOLD
ABSORB=NOT_AUTHORIZED
CERTIFIED=0
NO_INVENT_PASS=1
```

## SHA confirm

| Role | SHA256 | Status |
|------|--------|--------|
| Tip `TIP_FREEZE_001\bin` | `748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145` | MATCH UNTOUCHED |
| Live candidate | `D11AB5B695B46688348CA34131150F0E543191B4524B6E1F6568CA098D2B0862` | MATCH STABLE |
| Pin 2F3727A6 | preserved | not overwritten |

## PathB acceptance

| Gate | Value |
|------|-------|
| MENU_READY | 1 |
| ENTER | 0 |
| RETURN | 0 |
| COMPLETED | 0 |
| TIMED_OUT | 0 |
| EXIT | `0xC0000409` (process); VEH first-chance `0xC0000374` |
| GUI_RESPONSIVE | 0 |
| SHA stable | 1 |
| RUNTIME_PASS | **0** |

`NOT_RUN != PASS` — swarm body never entered (no CMD_DIAG id=4111 steps; Post/Send of 4111 observed but deferred path died in UI heap before crumb).

## Heap root (partial)

- VEH: `KIND=VEH_HEAP_CORRUPT` `EXCEPTION_CODE=0xC0000374` `@ ntdll+0x112FC5`
- FRAME[10] = `Win32IDE::WindowProc+0xC8` (`Win32IDE_Core.cpp`)
- FRAME[8] = UCRT `_free_base` / `select_heap` region (`libucrt`)
- `LAST_SB_GETTEXT` nested on statusbar during crash window
- ADL pin root (`atiadlxx+0x7097D`) **not** present on D11 (IAT block held)
- `SOURCE_WIRE_HEAP=0` — owner free-caller site **UNKNOWN** (FRAME[9] unresolved; no unique product free site)
- `NEW_FREEZE=0` (no clear SOURCE_WIRE → no new candidate ≠748B)

## Dump

`DUMP_CAPTURED=0` — FailFast/`0xC0000409` skipped in-process MiniDump; WER LocalDumps (HKCU) produced no new `.dmp` in window; procdump download hung. Stack authority = VEH first-chance file under CRASH_ROOT dumps/.

## Next gate

`HEAP_OWNER_SITE_WindowProc_free_caller_DUMP_THEN_SOURCE_WIRE` then PathB re-prove. `PROMOTE=0` `TIP_CLIMB=HOLD`
