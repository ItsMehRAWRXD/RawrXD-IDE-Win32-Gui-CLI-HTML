# REFRESH — WIN32IDE_CLOSURE_MATRIX_001

```
ASOF_UTC=2026-10-29T11:38:00Z
TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
TIP_LIVE_HASH_REVERIFY=MATCH
TIP_SIZE=331702784
PROMOTE=0
TIP_CLIMB=HOLD
CERTIFIED=0
PERFECT=0
NO_INVENT_PASS=1
NO_INVENT_MET=1
MOTD_ACK=1
```

## Authority inputs (this refresh)

| Input | Disposition | Cite |
|-------|-------------|------|
| Tip 748B | LIVE MATCH; CERTIFIED=0 | `TIP_FREEZE_001\bin` SHA reverify |
| PathB D11 | **FAIL** RUNTIME_PASS=0 | `SWARM_PATH_B_4111_CANDIDATE_D11AB5B6_001` |
| N2 headless | **PASS** RUNTIME_PASS=1 | `SWARM_ORCH_N2_BOTH_COMPLETE_001` on candidate `2F3727A6…` |
| N2→PathB/tip | TRANSFER_PASS=0 | D11 SUMMARY + ASSESSMENT_ACK |
| PROMOTE | 0 / HELD | A15 |

## Count delta

| Bucket | Prior (driver 748B) | After refresh |
|--------|--------------------:|--------------:|
| MET | 5 | **4** |
| OPEN | (unscoped) | **37** |
| FAIL | 0 (S-002 was SOURCE_WIRED) | **1** (S-002 PathB D11) |
| BLOCKED | 3 | 3 |
| HELD | 1 | 1 |

MET demotion: **A01** → OPEN (PROVENANCE_003 MET historical on `6832F439…` only; no invent transfer to tip `748B`). Remaining MET: A03, G16, I01, I12.

## Status moves

| ID | Was | Now | Why |
|----|-----|-----|-----|
| A01 | MET | OPEN | tip-748B provenance bundle absent; 6832 MET historical only |
| S-002 | SOURCE_WIRED | **FAIL** | PathB D11 controlling FAIL |
| G07 | SOURCE_WIRED | RUNTIME_PARTIAL | N2 headless PASS (candidate) + PathB D11 FAIL; tip orch not MET |
| G08 | SOURCE_WIRED | RUNTIME_PARTIAL | N2 topology candidate-only; PathB ENTER=0 |

## Blockers (return)

1. PathB D11 FAIL — heap FailFast before 4111 ENTER; SOURCE_WIRE_HEAP=0
2. CERTIFIED=0 / PROMOTE=0 — tip climb held; N2 ≠ certify
3. G07 tip orch NOT_OBSERVED; absorb NOT_AUTHORIZED
4. A01 tip provenance OPEN
5. A02 Camellia self_test=-8 BLOCKED
6. A04/G02 agent bridge + AgentRunLoop
7. S-005/U06 ConPTY RELINK+RUNTIME
8. A05 Admit absorb
9. A06/A07 MET conjunction incomplete
10. A11/I09 K2 OOM BLOCKED

```
SOURCE_WIRED != RUNTIME_REACHED != TOKEN_SURVIVED != PERFORMANCE_PASS
NOT_RUN != PASS
N2_HEADLESS_PASS != PATHB_PASS != TIP_CERTIFIED != PROMOTE
```
