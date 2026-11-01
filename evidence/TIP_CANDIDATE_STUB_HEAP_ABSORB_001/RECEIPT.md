# TIP_CANDIDATE_STUB_HEAP_ABSORB_001

```
ASOF_UTC=2026-10-29T12:50:45Z
ABSORB_4E8B=0
LIVE_SHA=7BB71AB9496DDCE4505046FCAC3333537B47BAC05B0E544DC4FC7AB78D0674DB
TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
PROMOTE=0
TIP_CLIMB=HOLD
DISPOSITION=ARCHIVE_4E8B_7BB71_SUFFICIENT
NEXT_GATE=PATHB_ACCEPTANCE_CLOSE_GAPS
```

## Decision

`ABSORB_4E8B=0`. Live auth candidate `7BB71AB9` already inherits heap WindowProc fix `93503F05` (WM_APP+310 sole-owner delete). Solo stub+heap SHA `4E8B4812` remains SUPERSEDED_NOT_LIVE / archive-only — no unique heap WindowProc delta, no freeze under TIP_CANDIDATE_AGENT_RUN_005, no tip-748B overwrite, no PathB EXE race.

## Authority chain

| SHA | Role | Heap WindowProc |
|-----|------|-----------------|
| 748B210A | Tip freeze (NEVER overwrite) | NE tip |
| 93503F05 | Heap fix origin | SOURCE_WIRE double-free remove |
| 7BB71AB9 | Live auth cand; N2 PASS | Inherits 93503 |
| 4E8B4812 | RELINK_STUB_HEAP solo | Superseded; not live; binary absent |

## Explicit non-claims

```
ABSORB_4E8B=0 != PathB PASS
N2_PASS != PATHB_PASS != TIP_CERTIFIED != PROMOTE
4E8B ARCHIVE != deleted seals (RELINK_STUB_HEAP_001 receipt retained)
```

## Cites

- TIP_CANDIDATE_AGENT_RUN_005/RELINK_STUB_HEAP_001/RECEIPT.md
- SWARM_ORCH_N2_D11_STABILIZE_001/SEAL.txt
- TIP_CANDIDATE_AGENT_RUN_005/NEW_CANDIDATE_SHA_N2STAB.txt
- SWARM_PATH_B_4111_CANDIDATE_7BB71AB9_001/SUMMARY.txt
- logs/sha_reverify.txt
