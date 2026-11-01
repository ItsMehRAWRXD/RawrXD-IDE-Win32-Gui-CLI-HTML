# HOST_HEAP_C0000374_REPRO_001

## Disposition

`HOST_HEAP_C0000374_CLEARED_ON_LIVE_CAND` — dump-backed race fix landed; live cand survival PASS; `PROMOTE=0`.

## Repro (pre-fix, independent of Tier5 survival cmds)

| Field | Value |
|-------|-------|
| Cand | `09DB6065…` (TIER5 freeze) |
| Method | MenuReady → idle settle (no 12200/12230/5170) |
| Hit | A3 `IDLE_DEATH` `0xC0000374` (~5s after ready) |
| Dump | `RawrXD-Win32IDE.exe.71756.dmp` SHA `AD92BBBF…` |
| Stack | `_free_base` ← `AutoClosingPair` tidy ← `LanguageDescriptor` dtor ← `initLanguageRegistry` ← `deferredHeavyInitBody` |
| Race | `CompilerIntegration` `detection_thread` / `RegisterDefaultCompilers` concurrent heap |

## Fix

- `CompilerIntegration_WaitForDetection(120000)` before `initAllFeatureModules`
- Avoid `GetAllLanguages()` copy at language-registry init log
- Rebuild cand `D0A6A65C…`; tip748B untouched

## Post-fix verify

| Check | Result |
|-------|--------|
| Idle stress ×5 on D0A6 | `C0000374_HITS=0` `NEW_DUMPS=0` |
| Survival 12200/12230/5170 | `PASS` `RUNTIME_SURVIVAL_PASS=1` |
| BC_TOP 12200/12230 | PRESENT (fail-closed ODS) |
| INVENT_WATCH_PASS | `0` |
| Pinned 2F37 | still `C0000374` (historical; ≠ live) |

## Authority

```
PROMOTE=0
ABSORB=NOT_AUTHORIZED
TIP_CLIMB=HOLD
CERTIFIED=0
NEXT_PRIORITY=AWAITING_AUTH
NEXT_GATE=POST_SCHEDULER_PROMOTION_REQUIREMENTS
AGENTIC_ENGINEERING=CLOSED_FOR_THIS_RESIDUAL
```
