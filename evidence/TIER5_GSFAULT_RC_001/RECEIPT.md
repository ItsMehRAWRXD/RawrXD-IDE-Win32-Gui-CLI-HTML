# TIER5_GSFAULT_RC_001 — RECEIPT

```
RUN_ID=TIER5GS_20261031T022717
DISPOSITION=TIER5_GSFAULT_RC_RUNTIME_SURVIVAL_PASS
EXIT=0
CAND_SHA=09DB6065B7C32BA2FD8C64A6D575EA7F19228AC1A671ED5F977C6D94F7BBEE37
CAND_PRIOR_1E61=1E61C037…
TIP_SHA=748B210A… tip748B=1
PROMOTE=0 ABSORB=NOT_AUTHORIZED TIP_CLIMB=HOLD CERTIFIED=0
RUNTIME_SURVIVAL_PASS=1
INVENT_WATCH_PASS=0
```

## Dump-backed root cause

| Field | Value |
|-------|-------|
| Dump | `RawrXD-Win32IDE.exe.71412.dmp` |
| SHA256 | `80719AE8D44F4923905B151340BA818690D1D74703DB78B07FCE160C09167DA5` |
| Exception | `0xC0000409` FastFail **P0=7** (`FATAL_APP_EXIT`) |
| Fault | `abort+0x35` |
| Stack owner | `CompilerIntegration::Initialize` detection `std::thread` lambda_3 |
| Not owner | Tier5 ODS / Watch ShowWindow / `__report_gsfailure` (P0≠2) |

## Why BC_TOP was missing on dying runs

Worker-thread `std::terminate`→`abort` killed the process around MenuReady+ping; UI never drained WM_COMMAND, so TOP bypass (SOURCE_WIRED) was never RUNTIME_REACHED.

## Fix

`CompilerIntegration_Real.cpp`: try/catch around detection thread body; progress/error callbacks refuse cross-thread `SendMessage`.

## Survival matrix (post-fix cand 09DB…)

| Cmd | Result | BC_TOP |
|-----|--------|--------|
| 12200 | PASS | PRESENT |
| 12230 | PASS | PRESENT |
| 5170 | PASS | n/a (outside TOP band) |

## Explicit non-claims

```
INVENT_WATCH_PASS=0
INVENT_BP_PANEL_PASS=0
C0000374=HOST_HEAP_INDEPENDENT
PROMOTE=0
```
