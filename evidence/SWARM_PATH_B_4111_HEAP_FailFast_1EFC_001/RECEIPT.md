# SWARM_PATH_B_4111_HEAP_FailFast_1EFC_001

```
GATE=SWARM_PATH_B_4111_HEAP_FailFast_1EFC_001
ASOF_UTC=2026-10-29T15:21:00Z
DISPOSITION=PATH_B_FAIL_CLOSED_AFTER_SOURCE_WIRE
PROMOTE=0 TIP_CLIMB=HOLD ABSORB=NOT_AUTHORIZED
NOT_RUN_NEQ_PASS=1
```

## 1) Re-hash tip+cand (1EFC baseline)

| Binary | SHA256 | Match |
|--------|--------|-------|
| Tip `TIP_FREEZE_001\bin` | `748B210A…3145` | MATCH UNTOUCHED |
| Cand prior | `1EFC517B…0BDD` | MATCH (pre-fix) |

## 2) Dump + four fields

`DUMP_CAPTURED=0` (FailFast skips MiniDump; debug attach hung on bad EXCEPTION_DEBUG_EVENT parse).

`VEH_STACK_CAPTURED=1` — authority `dumps/FIRST_CHANCE_JOURNAL_1EFC517B_PRE_FIX.txt`.

See `FOUR_FIELD_C0000409.txt`:

1. **EXCEPTION_ADDRESS** — KERNELBASE RaiseException (C++ EH first-chance)
2. **FAULTING_INSTRUCTION** — `std::_Xlength_error` → `_CxxThrowException`
3. **CALL_STACK** — WindowProc → handleMessage → refreshCommandModelHub → scanOllamaCli
4. **SOURCE_LINE** — ModelHub ollama scan + VEH journal amplify of `0xE06D7363`

## 3) SOURCE_WIRE + solo freeze

Linked into authority `TIP_CANDIDATE_AGENT_RUN_005\bin` (tip never overwritten):

- VEH: do not journal caught MSVC C++ EH
- Skip ollama CLI / hub scan / WinHTTP tags under PathB CMD_DIAG env
- SubAgent bridge/resolve breadcrumbs

`NEW_SHA=60473CFA8C51AF973C4A4AC531FBBC9ED1025FC9FEA73E937A388C23000B03AC` ≠748B ≠1EFC

Intermediate prove freeze: `2F22CF84…` reached `CMD_DIAG_4111=6` / `onSubAgentSwarm_ENTER` then still `EXIT=0xC0000409`.

## 4) PathB re-prove

`RUNTIME_PASS=0` honest FAIL. Tip untouched. `PROMOTE=0`.

## 5) Explicit non-claims

```
SOURCE_WIRED != RUNTIME_REACHED != TOKEN_SURVIVED != PASS
DUMP_CAPTURED=0 != invented MiniDump
NOT_RUN != PASS
```

## Next gate

`NEXT_GATE=HEAP_OWNER_SITE_onSubAgentSwarm_AFTER_ENTER_BEFORE_resolve_DUMP_THEN_CLOSE`
