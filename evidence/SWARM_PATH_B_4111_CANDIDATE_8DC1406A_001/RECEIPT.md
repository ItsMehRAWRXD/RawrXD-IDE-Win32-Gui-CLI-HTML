# RECEIPT — SWARM_PATH_B_4111_CANDIDATE_8DC1406A_001

```
ASOF_UTC=2026-10-28T18:34:12Z
CANDIDATE_SHA=8DC1406A0118AC6A2F6A1E991378A2730AAC07D5593BA3C9BF5E8852E468235B
TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
TIP_UNTOUCHED=1
PROMOTE=0
ABSORB=NOT_AUTHORIZED
```

## Mission

PathB GUI CmdDiag 4111 RUNTIME prove on **frozen candidate only**.
Do not overwrite tip freeze. Do not invent PASS. Do not absorb GhostText.

## Results (controlling = RETRY2 immediate Post)

| Probe | Result |
|-------|--------|
| Tip SHA | MATCH / UNTOUCHED |
| Candidate SHA | MATCH |
| createWindow | **OK_RETURN_TRUE** (`win32ide_trace`) |
| MAIN_HWND | `0x37E0118` |
| MENU_READY | 0 (crash before prop) |
| PostMessage WM_COMMAND 4111 | 1 |
| CMD_DIAG_id_4111 | **6** |
| Steps | PRE_COMPILER → ENTER → onCommand_ENTER → BEFORE_FLIGHT → BEFORE_routeCommand → AFTER_routeCommand_OK |
| onSubAgentSwarm | **NOT_OBSERVED** |
| RUNTIME_REACHED | **1** |
| RUNTIME_PASS | **0** |
| Exit | `0xC0000005` |

## Explicit non-claims

- Not RUNTIME_PASS / PERFORMANCE_PASS / CERTIFIED
- Not tip absorb / GhostText absorb
- PathA HTTP orch ≠ PathB GUI orch PASS
- `AFTER_routeCommand_OK` ≠ `onSubAgentSwarm` observed

## Next gate

Stabilize candidate GUI crash; witness `onSubAgentSwarm`; keep `PROMOTE=0`.
