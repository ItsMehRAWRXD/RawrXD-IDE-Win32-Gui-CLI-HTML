# WIN32IDE_UI_PHASE7_RUNTIME_D11_001 — RECEIPT

```
ASOF_UTC=2026-10-29T11:45:56Z
DISPOSITION=BLOCKED_HEAP
UI_ACCEPTANCE_PASS=0
RUNTIME_REACHED=0
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

## Phase7 exercise

| Gate | Value |
|------|-------|
| MENU_READY | 1 |
| POST 5199 / 5016 / 502 / 12040 | 1 / 1 / 1 / 1 (queued) |
| CMD crumb ids observed | **0** (no 5199/5016/502/12040) |
| TaskRunner HWND | 0 |
| Settings HWND | 0 |
| VEH | `VEH_HEAP_CORRUPT` `0xC0000374` |
| GUI_RESPONSIVE | 0 |
| UI_ACCEPTANCE_PASS | **0** |
| RUNTIME_REACHED | **0** |

`NOT_RUN != PASS` — handlers never reached; heap first-chance at MENU_READY exercise window (`logs/FIRST_CHANCE_WM_COMMAND.txt`, crumb `VEH_HEAP_CORRUPT`).

## Prior retained

`WIN32IDE_UI_PHASE7_SETTINGS_TASKRUNNER_SOURCE_001` SOURCE_WIRED=1 remains; this seal does not invent RUNTIME on tip or candidate.

## Next gate

`HEAP_OWNER_SITE_WindowProc_free_caller_DUMP_THEN_SOURCE_WIRE` then new-freeze ≠748B then Phase7 HWND re-prove. `PROMOTE=0` `TIP_CLIMB=HOLD`
