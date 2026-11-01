# Next 25 residual blockers

ASOF: 2026-11-01 · tip748B frozen · cand D958 era · PROMOTE=0 · invent=0

Classes: `AUTH` · `HOST` · `K2` · `WHY_HELD` · `PRODUCT_E2E` · `OPEN` · `DUMP`

Executable under `AUTHORIZE_CANDIDATE_ONLY` without invent tip absorb: **Assess/source only** unless noted.

| # | Blocker | Class | Status | Cite / owner | Executable now? |
|---|---------|-------|--------|--------------|-----------------|
| 1 | Tip absorb `748B←cand` | AUTH | `NOT_AUTHORIZED` | `USER_DISPOSITION_PROMOTE_HELD_001` · AUTH×4 #1 | No — process AUTH |
| 2 | R28 APPLY | AUTH | `HELD` | AUTH×4 #2 · Deep2 R28 witness-only | No — process AUTH |
| 3 | `PromoteReady` EMIT | AUTH | `0` | AUTH×4 #3 · `Deep2ProductGate.hpp` | No — process AUTH |
| 4 | Tip climb | AUTH | `HOLD` | AUTH×4 #4 · `TIP_CLIMB=HOLD` | No — process AUTH |
| 5 | Host unexpected resets | HOST | `UNVERIFIED` | Kernel-Power 41 BugcheckCode=0; boots 11-01 02:35+02:50 | Assess only — no GPU stress |
| 6 | AMD `amdkmdag` TDR/start faults | HOST | `SUSPECT` | LiveKernel 0x141 / 0x1B0; `atiadlxx` AV | Assess/driver path — not IDE invent |
| 7 | Mixed AMD driver builds | HOST | `CONCERN` | iGPU 21042.62 / R9700 31044.16 / 7800XT 31041.1004 | Host ops — not product invent |
| 8 | Crash dump init failure | DUMP | `FAILED` | `volmgr` 45/46; no MEMORY.DMP on hard resets | Host fix — improves forensics |
| 9 | K2 full product generation | K2 | `HOST_BLOCKED` lineage | SCORECARD K2 OOM; RAM now ~44GB free ≠ PASS | Held — need controlled proof, not invent |
| 10 | PDH / Advapi32 fatal AV | HOST/PRODUCT | `ROOT_CAUSE_OPEN` | `PDH_ADVAPI32_CRASH_001` | Source/trace when host stable |
| 11 | `digestion_engine_stub` / `#if0` private stubs | WHY_HELD | `REAFFIRM` | `STUB_RESIDUAL_ENUM_001` COMPLETION_020 | No invent un-stub |
| 12 | DAP `requestScopes` absent | WHY_HELD | `FAIL_CLOSED` | COMPLETION_017 DAP bridge | No invent scopes API |
| 13 | Sidebar GitHub login (URL+ODS) | WHY_HELD | `HELD` | COMPLETION_018 SidebarRuntime | No invent OAuth product PASS |
| 14 | Sidebar LayoutProfile IDM absent | WHY_HELD | `FALLBACK` | COMPLETION_018 settings fallback | No invent IDM |
| 15 | Heatmap `deviceOrdinal` absent | WHY_HELD | `HELD` | COMPLETION_019 planSpanOrdinal only | No invent GPU affinity |
| 16 | Compiler dumpbin terminal absent | WHY_HELD | `HELD` | COMPLETION_020 DUMPBIN_TERMINAL | No invent terminal |
| 17 | `CppCompilerImpl` absent from Win32IDE link | WHY_HELD | `ABSENT` | COMPLETION_020 adapt→CompilerIntegration | No invent second compiler |
| 18 | Sidebar feature-specific product E2E | PRODUCT_E2E | `NOT_PROVEN` | SOURCE_WIRED ≠ E2E (018) | Runtime only when host stable |
| 19 | ExpertHeatmap product E2E | PRODUCT_E2E | `NOT_PROVEN` | SOURCE_WIRED (019) | Runtime when host stable |
| 20 | CompilerPanel product E2E beyond adapt | PRODUCT_E2E | `NOT_PROVEN` | SOURCE_WIRED (020) | Runtime when host stable |
| 21 | DAP full session lifecycle product PASS | PRODUCT_E2E | `INVENT=0` | 006–007/017 survival≠product | No invent DAP PASS |
| 22 | Watch / BP invent product PASS | PRODUCT_E2E | `INVENT=0` | TIER5/DBGWATCH fail-closed | No invent Watch PASS |
| 23 | Remote steering / EGRESS | OPEN | `OPEN` | Command-home EGRESS_001 | Planning/source — not tip absorb |
| 24 | STATIC_DEP / public landing | OPEN | `OPEN` | SCORECARD §3 | Planning — not tip absorb |
| 25 | Finished-product conjunction (AUTH×4∧K2∧CERT∧feature E2E) | AUTH/PRODUCT | `0` | SCORECARD §4–5 · PRODUCT_PASS=0 | Blocked on 1–4 + 9 + E2E |

## Batch disposition

| Bucket | Count | Action |
|--------|------:|--------|
| AUTH held | 4 | Await process AUTH — do not invent |
| HOST / DUMP / PDH | 5 | Stabilize host + dumps before heavy IDE/K2 |
| K2 | 1 | Controlled capacity proof later; ≠ PASS tonight |
| WHY_HELD residuals | 7 | Documented; invent un-stub forbidden |
| PRODUCT_E2E / invent=0 | 5 | Runtime proofs only under stable host |
| OPEN planning | 2 | Non-promote planning tracks |
| Conjunction PRODUCT_PASS | 1 | Remains 0 |

`CLOSED_THIS_SEAL=0` (inventory only) · `INVENT_PASS=0` · `PROMOTE=0`
