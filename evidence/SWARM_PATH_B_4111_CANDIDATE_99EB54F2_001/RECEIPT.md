# RECEIPT — SWARM_PATH_B_4111_CANDIDATE_99EB54F2_001

```
ASOF_UTC=2026-10-29T09:43:59Z
CANDIDATE_SHA=99EB54F2B876E59D9DC054530FFEDDDF2875EF308EE8A937CA1DECE6A5B481CA
TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
TIP_UNTOUCHED=1
PROMOTE=0
ABSORB=NOT_AUTHORIZED
```

## Mission

PathB GUI CmdDiag 4111 RUNTIME prove on **candidate 99EB54F2 only**.
Re-prove after claimed crash-fix absorb. Do not overwrite tip freeze.
Do not invent PASS. Do not absorb GhostText.

## SHA gate

| Binary | Expected | Live | Result |
|--------|----------|------|--------|
| Tip freeze | `748B210A…1345` | match | UNTOUCHED=1 |
| Candidate | `99EB54F2…81CA` | match | SHA_MATCH=1 |

## Results (controlling = RETRY2 immediate Post)

| Probe | Result |
|-------|--------|
| createWindow | **OK_RETURN_TRUE** (`win32ide_trace`) |
| MAIN_HWND | `0x50400` |
| MENU_READY | 1 |
| PostMessage WM_COMMAND 4111 | 1 |
| CMD_DIAG_id_4111 | **14** |
| Steps | PRE_COMPILER → DEFER → FLUSH → ENTER → onCommand_ENTER → BEFORE_FLIGHT → BEFORE_routeCommand → **onSubAgentSwarm_ENTER** → resolveSwarmModelOrchPlan_OK → SEED_EMPTY_EDITOR → BEFORE_executeSwarm → AFTER_routeCommand_OK → EXIT_OK |
| onSubAgentSwarm | **OBSERVED** |
| executeSwarm complete | **NOT_OBSERVED** (BEFORE_ only) |
| RUNTIME_REACHED | **1** |
| RUNTIME_PASS | **0** |
| Exit | `0xC0000409` |

## Run1 (non-controlling)

Immediate Post delayed (~7s, seeded): `VEH_FATAL` before Post; `CMD_DIAG_id_4111=0`; exit `0xC0000374`; `RUNTIME_REACHED=0`.

## Explicit non-claims

- Not RUNTIME_PASS / PERFORMANCE_PASS / CERTIFIED / PRODUCT_CERTIFIED
- Not tip absorb / GhostText absorb
- Crash-fix claimed absorbed ≠ proven (still C0000409 / C0000374)
- PathA HTTP orch ≠ PathB GUI orch PASS
- `BEFORE_executeSwarm` ≠ executeSwarm / swarm workers complete

## Next gate

Stabilize candidate GUI crash; witness executeSwarm completion; keep `PROMOTE=0` · `TIP_CLIMB=HOLD`.
