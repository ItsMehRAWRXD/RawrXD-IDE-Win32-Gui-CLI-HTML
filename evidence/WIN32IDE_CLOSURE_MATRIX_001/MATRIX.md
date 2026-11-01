# MATRIX — WIN32IDE_CLOSURE_MATRIX_001

```
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0
TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
TIP_FREEZE=TIP_FREEZE_001
TIP_LIVE_HASH_REVERIFY=MATCH
TIP_SIZE=331702784
PRIOR_TIP_SHA=6832F439100C71AE7923A7736F71784039B7F6A9DE53C895E56E9C7932A9F8B2
ABSORB_SEAL_HISTORICAL=2B9B5A677A4D40C999F3AC4BFA57BD3CA1AAE688D56B93E8033621F1DB1821E2
DRIFT_OBSERVED_HISTORICAL=5540BF183AFC92807FC2581AE0CD8C0657329D1BDE4AA897FE00327DF64D436F
PRIOR_PRIOR_TIP_SHA=C4FC9AE9A6EAC016A78B0C1BB1690B9C47A46A4B47FC51B1B807E10E14EDC43B
ASOF_UTC=2026-10-29T12:49:59Z
REFRESH=REFRESH_20261029_7BB71
WAVE=7BB71AB9
CANDIDATE_SHA=7BB71AB9496DDCE4505046FCAC3333537B47BAC05B0E544DC4FC7AB78D0674DB
CANDIDATE_SIZE=331755520
CANDIDATE_NE_TIP=1
AGENTIC_COMPOSER_RUNTIME_001=SEALED_INVOKED_SURFACE_RUNTIME_NOT_RUN
NO_INVENT_MET=1
NO_INVENT_SHA_TRANSFER=1
N2_HEADLESS_PASS=1
N2_HEADLESS_SHA=7BB71AB9496DDCE4505046FCAC3333537B47BAC05B0E544DC4FC7AB78D0674DB
N2_SEAL=SWARM_ORCH_N2_D11_STABILIZE_001
N2_NEQ_TIP=1
N2_NEQ_PATHB=1
N2_HEADLESS_TRANSFER_PASS=0
DO_NOT_CITE_2F3727A6_AS_THIS_PROOF=1
PRIOR_N2_HISTORICAL=2F3727A6CD8EFF4E934E45C51494B926489FFAD1BC5430B072F3D5BAEE0007C2
PATHB_7BB71_FAIL=1
PATHB_7BB71_SHA=7BB71AB9496DDCE4505046FCAC3333537B47BAC05B0E544DC4FC7AB78D0674DB
PATHB_7BB71_RUNTIME_PASS=0
PATHB_7BB71_DISPOSITION=FAIL_CLOSED_CMD_DIAG_MISS
PATHB_D11_FAIL_HISTORICAL=1
PATHB_D11_SHA=D11AB5B695B46688348CA34131150F0E543191B4524B6E1F6568CA098D2B0862
STUB_FICTION_GATED=17
STUB_FICTION_OPEN=0
STUB_FICTION_RELINK_REQUIRED=1
STUB_FICTION_CITE=WIN32IDE_STUB_FICTION_SWEEP_003
SWARM_ORCH_SOURCE=SWARM_MODEL_ORCH_001
SWARM_IN_TIP=TIP_ABSORB_SWARM_002
HTTPTAGS_LINKED=1
MET_COUNT=4
OPEN_COUNT=37
FAIL_COUNT=1
BLOCKED_COUNT=3
HELD_COUNT=1
```

Statuses: `MET` | `OPEN` | `HELD` | `BLOCKED` | `FAIL` | `SOURCE` | `SOURCE_WIRED` | `RUNTIME_REACHED` | `RUNTIME_PARTIAL`  
Rule: cite required for MET/BLOCKED/HELD/FAIL/RUNTIME_REACHED/RUNTIME_PARTIAL; SOURCE = local wiring/finding only; RUNTIME_REACHED ≠ MET; RUNTIME_PARTIAL ≠ MET; candidate PASS ≠ tip MET; N2 ≠ PathB ≠ CERTIFIED; open=0 stubs ≠ tip RELINK PASS.

## A01–A15 Release-blocking gates

| ID | Gate | Status | Cite / note |
|----|------|--------|-------------|
| A01 | Binary provenance (hash + CMake snapshot/commit + build logs + MAP/PDB) | **OPEN** | `WIN32IDE_BINARY_PROVENANCE_748B_001` sealed `A01_MET=0`: freeze EXE `748B210A…` size 331702784 SHA_MATCH=1; PDB present `86AA0E7C…`; PE RSDS `{D7267FAD-…}` age 1; `TIP_EXE_AUTHORITY` linked. **Gaps:** freeze MAP MISSING; build-live map/EXE `93503F05…` ≠ tip; cmake/ninja/build-log co-seal absent. `PROVENANCE_003` A01=MET historical on `6832F439…` only — no invent transfer. Candidate `7BB71AB9…` ≠ tip provenance MET. NEXT=`A01_748B_MAP_CMAKE_COSEAL`. ≠ CERTIFIED |
| A02 | Camellia `self_test=-8` RFC KAT | **BLOCKED** | `CAMELLIA_SELFTEST_RFC_001` = BLOCKED_DOCUMENTED; HMAC independent PASS; not invent-pass |
| A03 | Post-fix tip seal (LIVE_TETRAD + TOKEN64 + MULTI_FAMILY on EXE SHA) | **MET** | Earned on FROZEN `748B210A…` (`TIP_FREEZE_001`): `LIVE_TETRAD_POST_RECOVER_001` PASS; `TOKEN64_PRODUCT_RUN_006` PASS (`TPS_PRODUCT_SEAL=1`); `MULTI_FAMILY_PRODUCT_006` PASS (gemma3). ≠ PROMOTE ≠ CERTIFIED |
| A04 | Agent bridge + Watchdog product GUI/headless runtime same SHA | **OPEN** | Headless `/api/tool` lifecycle historical on `6832F439…` (`AGENT_LIFECYCLE_TIP_001`); GUI bridge NOT_RUN — full GUI+headless same-SHA breadth not earned on `748B` |
| A05 | No fabricated tool success | **RUNTIME_PARTIAL** | `TOOL_ACTION_STATUS_E2E_002`: /api/tool success+failure PASS; cancel latch PASS; GateStub NEG PASS; Admit consumer SOURCE+unit PASS but tip Admit NOT_LINKED (RELINK_REQUIRED); A05_MET=0 |
| A06 | Safe file writes (atomic/preview/rollback/deny) | **RUNTIME_REACHED** | Tip `748B` deny+inside write: `TIP_FREEZE_748B_HEADLESS_SURFACE_001` (abs/../UNC 403 + inside 200). Prior `SAFE_WRITE_APPROVAL_TIP_001` on `6832F439…` historical. Atomic/preview/rollback: `SAFE_WRITE_ATOMIC_001` SOURCE_WIRED RELINK_REQUIRED RUNTIME NOT_RUN. MET=0 |
| A07 | Tool approval + isolation / injection negatives | **RUNTIME_REACHED** | Tip `748B` `TIP_FREEZE_748B_HEADLESS_SURFACE_001`: no-key 401, evil Origin 403, exec without grant. Injection-parse negatives SOURCE_WIRED / HTTP NOT_RUN. MET=0 |
| A08 | Lifecycle safety (freed IDE / cancel / leaks) | **OPEN** | No tip receipt closing gate |
| A09 | Fatal crash + data loss recovery | **OPEN** | No tip receipt closing gate |
| A10 | CMake-omit legitimacy | **OPEN** | `WIN32IDE_FULL_SOURCE_AUDIT_001` inventories omit/orphan; adjudication incomplete → PERFECT=0 |
| A11 | K2 full product generation | **BLOCKED** | `K2_FULL_PRODUCT_GEN_002` BLOCKED_OOM on CURRENT; GENERATED_TOKENS=0 |
| A12 | Source inventory 100% path/hash/class + win32app reconcile | **OPEN** | Audit landed inventory counts; PERFECT=0 / OPEN list non-empty |
| A13 | Target attribution (every selected TU + map; orphans classified) | **OPEN** | CMake net/orphan counts exist; full object/link-map attribution not MET |
| A14 | Findings adjudication (no unresolved P0/P1) | **OPEN** | S-001 RUNTIME_PARTIAL; S-002 PathB 7BB71 FAIL (+ D11 historical FAIL) + N2 candidate-only; S-003/S-004/S-005 SOURCE_WIRED; FEATURE_FICTION GATED=17 OPEN=0 RELINK_REQUIRED ≠ RUNTIME |
| A15 | Promotion authority | **HELD** | `PROMOTE=0` · `PROMOTE_READY_CONJUNCTION_001` · never manually forced · `CERTIFIED=0` |

## S-001–S-005 Static findings (local presence)

| ID | Finding | Status | Cite |
|----|---------|--------|------|
| S-001 | ToolActionStatus synthetic terminal + FinishedAction(0) | **RUNTIME_PARTIAL** | E2E_002 on tip `6832F439…`; Admit/VSCodeUI/hookToolResult SOURCE_WIRED not tip-absorbed; MET=0 |
| S-002 | Swarm 4 fixed prompts / maxParallel=4 (not 1–16 configurable) | **FAIL** | PathB GUI candidate `7BB71AB9…` **FAIL**: `SWARM_PATH_B_4111_CANDIDATE_7BB71AB9_001` MENU_READY=1 ENTER=0 RETURN=0 COMPLETED=0 CMD_DIAG_4111=0 SEND_TIMED_OUT=1 EXIT≈`0xC0000409` RUNTIME_PASS=0 DISPOSITION=`FAIL_CLOSED_CMD_DIAG_MISS` (`N2_HEADLESS_TRANSFER_PASS=0`). Prior D11 `D11AB5B6…` FAIL historical. Tip `748B` PathB orch NOT_OBSERVED. N2 headless BOTH_COMPLETE on `7BB71AB9…` ≠ GUI PathB ≠ tip MET |
| S-003 | Swarm model enum: one-dir `*.gguf` only | **SOURCE_WIRED** | `SWARM_MODEL_ORCH_001` — multi-root GGUF + `/api/tags`; HttpTags LINKED; product swarm GUI RUNTIME NOT_RUN on tip |
| S-004 | AgenticComposerUX static callbacks / default-model / MessageBox | **SOURCE_WIRED** | Real model bind; `AGENTIC_COMPOSER_RUNTIME_001` INVOKED_SURFACE — RUNTIME_REACHED NOT_RUN |
| S-005 | ShellLayout phase 5 terminal stub | **SOURCE_WIRED** | `SHELLLAYOUT_PHASE5_001` + `CONPTY_STREAM_OWNER_001`; RELINK_REQUIRED; RUNTIME_REACHED=NOT_RUN |

## G01–G20 Agentic functionality

| ID | Feature | Status | Cite / note |
|----|---------|--------|-------------|
| G01 | Ask mode | **RUNTIME_PARTIAL** | `MODE_SWITCH_UI_001` tip `748B` HWND WM_COMMAND 1208 POST=1; chat E2E not MET |
| G02 | Agent mode E2E tool loop | **RUNTIME_PARTIAL** | Mode switch 1207 RUNTIME; `AGENT_RUN_LOOP_TIP_004` tip `748B` POST `/api/agent/run` HTTP 503 `model_not_loaded`; ENTERED=0 FAIL_CLOSED — not MET |
| G03 | Plan mode | **RUNTIME_PARTIAL** | `MODE_SWITCH_UI_001` tip `748B` HWND 1206 POST=1; plan E2E not MET |
| G04 | Debug mode | **SOURCE_WIRED** | Source IDC 5008 + radios; tip HWND NOT_ON_TIP_IDC — not MET |
| G05 | Auto mode routing | **OPEN** | NOT_INVOKED on tip — no `AgenticMode::Auto` |
| G06 | Model registry live list | **SOURCE** | Swarm/Ollama dir scan wiring exists (S-003); live registry E2E OPEN |
| G07 | Model ensemble 1–16 | **RUNTIME_PARTIAL** | **N2 PASS headless** on candidate `7BB71AB9…` (`SWARM_ORCH_N2_D11_STABILIZE_001`: completed=2 timed_out=0 peakParallel=2 RUNTIME_PASS=1) — N2 scope only; ≠ tip; DO_NOT_CITE `2F3727A6` as this proof. **PathB 7BB71 FAIL** (`FAIL_CLOSED_CMD_DIAG_MISS` RUNTIME_PASS=0). Tip `748B` orch NOT_OBSERVED. Full 1–16 + tip GUI MET denied. G07_MET=0 |
| G08 | Execution topology | **RUNTIME_PARTIAL** | N2 candidate `7BB71AB9…` proves maxParallel=2 / peakParallel=2 headless; tip PathB topology NOT_OBSERVED; PathB 7BB71 CMD_DIAG_4111=0 before ENTER — not MET |
| G09 | Concurrency fairness | **OPEN** | No tip receipt |
| G10 | Stop/cancel | **OPEN** | No live tip swarm cancel; PathB 7BB71 never ENTER — cancel NOT_ATTEMPTED |
| G11 | Pause/resume | **OPEN** | No tip receipt |
| G12 | Checkpoint/rollback | **OPEN** | `AGENT_LIFECYCLE_TIP_001` write_file restore ≠ CheckpointManager product API — NOT_RUN |
| G13 | Multi-workspace | **OPEN** | No tip receipt |
| G14 | Tool dispatch schema→callable | **RUNTIME_PARTIAL** | Tip `748B` critical tools RUNTIME (`HEADLESS_API_TOOL_TIP_748B_001`); full schema matrix not MET |
| G15 | Tool errors truthful | **RUNTIME_PARTIAL** | Tip `/api/tool` file_not_found propagates; synthetic consumer absorb pending |
| G16 | Headless `/api/tool` | **MET** | Tip `748B210A…` `HEADLESS_API_TOOL_TIP_748B_001` + corroboration `TIP_FREEZE_748B_HEADLESS_SURFACE_001` (MOTD+list+evil Origin). `TIP_FREEZE_748B_HEADLESS_SURFACE_002` G16_MET=0 held as non-transfer. PROMOTE=0 CERTIFIED=0 |
| G17 | Extension host | **SOURCE** | FeatureManifest / omit gates; runtime OPEN |
| G18 | Browser/OS authority | **OPEN** | No tip receipt |
| G19 | MOTD gate | **SOURCE** | Policy/MOTD rules present; product session E2E OPEN |
| G20 | Agent metrics | **OPEN** | Composer metrics cmds SOURCE; product metrics seal OPEN |

## U01–U18 Polished IDE UI

| ID | Feature | Status | Cite / note |
|----|---------|--------|-------------|
| U01 | Composer modes/chooser | **SOURCE** | Ask/Plan/Agent INVOKED_SURFACE on tip; Debug/Auto NOT_INVOKED; full UI/RUNTIME MET denied |
| U02 | Chain-of-models picker 1–16 | **SOURCE_WIRED** | Tip GUI picker/swarm NOT_RUN; PathB 7BB71 FAIL ≠ picker MET |
| U03 | Real progress timeline | **OPEN** | No tip receipt |
| U04 | Review changes Accept/Reject | **SOURCE** | Composer approve/reject cmds exist; E2E OPEN |
| U05 | Stop control | **OPEN** | No tip receipt |
| U06 | Background terminal / ConPTY | **SOURCE_WIRED** | `SHELLLAYOUT_PHASE5_001`/`CONPTY_STREAM_OWNER_001`; RELINK_REQUIRED; RUNTIME NOT_RUN; ≠ PASS; stub fiction open=0 ≠ ConPTY MET |
| U07 | Dock layout resize/DPI | **SOURCE** | ShellLayout phases 0–5 SOURCE_WIRED; full docking E2E OPEN |
| U08 | Audit/review tab | **OPEN** | No tip receipt |
| U09 | Session/history durable | **OPEN** | No tip receipt |
| U10 | Context management | **OPEN** | No tip receipt |
| U11 | Explorer / quick open | **OPEN** | No tip receipt |
| U12 | Editor core | **OPEN** | No tip receipt as closure |
| U13 | LSP | **OPEN** | No tip receipt |
| U14 | Debugger UI | **OPEN** | No tip receipt |
| U15 | Accessibility | **OPEN** | No tip receipt |
| U16 | Visual consistency | **OPEN** | P2; no tip receipt |
| U17 | Responsive UX | **OPEN** | P2; no tip receipt |
| U18 | Notifications (no invented toasts) | **RUNTIME_PARTIAL** | Tied to A05/`TOOL_ACTION_STATUS_E2E_002`; tip absorb pending |

## I01–I12 Inference and runtime

| ID | Feature | Status | Cite / note |
|----|---------|--------|-------------|
| I01 | GGUF families token production | **MET** | TinyLlama tetrad + gemma3 MULTI_FAMILY_006 on FROZEN `748B210A…`; ≠ full inference matrix |
| I02 | Quantization oracle gates | **OPEN** | No oracle seal on tip |
| I03 | CPU/GPU fallback observable | **OPEN** | Inference SPLIT HOLD |
| I04 | Vulkan GEMV | **OPEN** | No tip repair seal |
| I05 | Vulkan synchronization | **OPEN** | No tip seal |
| I06 | Multi-GPU placement | **OPEN** | No tip seal |
| I07 | Long context vs KV | **OPEN** | No tip seal |
| I08 | MoE scheduler | **OPEN** | No tip seal |
| I09 | Memory protection / admission | **BLOCKED** | K2 OOM path documents refusal; full graceful product admission not MET |
| I10 | Model switching | **OPEN** | No tip seal |
| I11 | Concurrency 1..16 agents | **OPEN** | N2 candidate `7BB71AB9…` headless n=2 PASS ≠ 1..16 tip seal; PathB 7BB71 FAIL |
| I12 | Performance seals per-model TPS | **MET** | `TOKEN64_PRODUCT_RUN_006` TPS_PRODUCT_SEAL=1 on FROZEN `748B210A…`; not universal per-model matrix |

## Counts (honest refresh)

| Bucket | Count | IDs |
|--------|------:|-----|
| **MET** | **4** | A03, G16, I01, I12 |
| **OPEN** | **37** | A01, A04, A08–A10, A12–A14, G05, G09–G13, G18, G20, U03, U05, U08–U17, I02–I08, I10, I11 |
| **FAIL** | **1** | S-002 (PathB 7BB71AB9 controlling FAIL; D11 historical) |
| **BLOCKED** | **3** | A02, A11, I09 |
| **HELD** | **1** | A15 |
| RUNTIME_PARTIAL | 10 | A05, S-001, G01–G03, G07, G08, G14, G15, U18 |
| RUNTIME_REACHED | 2 | A06, A07 |
| SOURCE_WIRED | 6 | S-003–S-005, G04, U02, U06 |
| SOURCE | 6 | G06, G17, G19, U01, U04, U07 |

## Top blockers (priority)

1. **PathB 7BB71 FAIL** — `SWARM_PATH_B_4111_CANDIDATE_7BB71AB9_001` RUNTIME_PASS=0; `FAIL_CLOSED_CMD_DIAG_MISS` CMD_DIAG_4111=0; SendMessageTimeout timed out; ENTER=0; exit ≈`0xC0000409`; NEXT=`PATHB_ACCEPTANCE_CLOSE_GAPS` / CMD_DIAG_4111 owner
2. **Tip CERTIFIED=0 / A15 HELD** — `PROMOTE=0`; N2 headless PASS on `7BB71AB9…` does not certify tip `748B`
3. **G07 tip orch** — tip `748B` PathB orch NOT_OBSERVED; N2 on `7BB71AB9…` ≠ tip absorb (`ABSORB=NOT_AUTHORIZED`); N2_NEQ_PATHB
4. **A01 tip provenance** — OPEN `A01_MET=0` (`WIN32IDE_BINARY_PROVENANCE_748B_001`; MAP/cmake co-seal gaps; 6832 MET historical only)
5. **A02** — Camellia RFC self_test BLOCKED_DOCUMENTED (`self_test=-8`)
6. **A04 / G02** — agent bridge GUI + AgentRunLoop E2E (503 ENTERED=0 on tip)
7. **S-005 / U06 RELINK** — ConPTY SOURCE_WIRED; tip absorb + RUNTIME OPEN
8. **Stub fiction RELINK_REQUIRED** — gated=17 open=0 (`WIN32IDE_STUB_FICTION_SWEEP_003`); candidate RELINK ≠ tip RUNTIME ≠ PERFECT
9. **A05 Admit absorb** — RUNTIME_PARTIAL; MET=0
10. **A06/A07 MET conjunction** — deny RUNTIME_REACHED; atomic/preview/rollback + injection HTTP incomplete
11. **A11 / I09** — K2 full gen BLOCKED_OOM

## Explicit non-claims

```
PERFECT=0
CERTIFIED=0
PROMOTE=0
TIP_CLIMB=HOLD
TIP_748B_LIVE_MATCH=1
G07_MET=0
N2_HEADLESS_PASS=1 on candidate 7BB71AB9 ≠ tip MET ≠ PathB PASS ≠ CERTIFIED
PATHB_7BB71_FAIL=1 RUNTIME_PASS=0 (FAIL_CLOSED_CMD_DIAG_MISS)
PATHB_D11_FAIL_HISTORICAL=1
N2_HEADLESS_TRANSFER_PASS=0
DO_NOT_CITE_2F3727A6_AS_THIS_PROOF=1
STUB_FICTION gated=17 open=0 RELINK_REQUIRED ≠ tip RELINK PASS ≠ PERFECT
A01 OPEN A01_MET=0 on tip 748B (WIN32IDE_BINARY_PROVENANCE_748B_001; PROVENANCE_003 MET historical 6832 only)
A03/G16/I01/I12 MET ≠ PROMOTE ≠ CERTIFIED
ABSORB 2B9B5A67 / GhostText B421 = NOT_AUTHORIZED for tip climb
AGENT_RUN_LOOP tip 748B HTTP 503 ENTERED=0 ≠ G02 MET
PATH_B PostMessage 4111 ≠ RUNTIME_PASS
SOURCE_WIRED != RUNTIME_REACHED != TOKEN_SURVIVED != PERFORMANCE_PASS
NOT_RUN != PASS
```
