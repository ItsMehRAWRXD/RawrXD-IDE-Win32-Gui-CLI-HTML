# DBGWATCH_SURVIVAL_RC_67CA_001 — RECEIPT

```
RUN_ID=DBGWATCHRC_20261031T015332
DISPOSITION=DBGWATCH_SURVIVAL_RC_FAIL_CLOSED
EXIT=1
CAND_SHA=1E61C037EE1422B158B788779755D73757E7B2C75DDF54863369AE3D39BA3B02
CAND_PRIOR_67CA=67CA264F…
TIP_SHA=748B210A… tip748B=1
PROMOTE=0 ABSORB=NOT_AUTHORIZED TIP_CLIMB=HOLD CERTIFIED=0
RUNTIME_SURVIVAL_PASS=0
```

## Root cause (executable)

| Claim | Evidence |
|-------|----------|
| Tier5 ODS-only path linked on 67CA | `FEATURE_FICTION=1 FAIL_CLOSED IDM_DBGWATCH` string bind PASS; invent `DEBUG WATCH WINDOW` ABSENT |
| ShowWindow/SetFocus not the live 67CA killer alone | ODS handler has no Show/SetFocus; still C0000409 |
| Broader Tier5/onCommand surface | 12200 (line-ending) also dies after MenuReady+ping |
| D252 ODS survival does not transfer | Sealed D252 PASS vs 67CA/1E61 FAIL_CLOSED |
| TOP bypass SOURCE_WIRED | `12200-12314` / TOP bypass strings in cand 1E61 |
| RUNTIME_SURVIVAL | NOT_PASS — BC_TOP missing on dying runs; EXIT=0xC0000409 |

## C0000374

Independent HOST_HEAP residual (pinned 2F37 launch class). Do not fold into inventing 12230 PASS.

## Explicit non-claims

```
SOURCE_WIRED != RUNTIME_SURVIVAL_PASS
TOP_BYPASS_WIRED != GUI_SURVIVAL_PASS
D252_ODS_PASS != 67CA_TRANSFER
INVENT_WATCH_PASS=0
PROMOTE=0
```
