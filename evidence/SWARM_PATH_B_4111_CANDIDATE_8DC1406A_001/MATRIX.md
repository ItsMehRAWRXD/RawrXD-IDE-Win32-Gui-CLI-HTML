# SWARM_PATH_B_4111_CANDIDATE_8DC1406A_001 — matrix

```
PROMOTE=0
TIP_CLIMB=HOLD
CERTIFIED=0
ABSORB=NOT_AUTHORIZED
RUNTIME_REACHED=1
RUNTIME_PASS=0
```

| ID | Surface | Disposition | Notes |
|----|---------|-------------|-------|
| V01 | Tip SHA 748B | MATCH / UNTOUCHED | Never overwrite |
| V02 | Candidate SHA 8DC1406A | MATCH | Sole PathB EXE |
| R01 | createWindow | OK_RETURN_TRUE | Then crash |
| R02 | CMD_DIAG id=4111 | HIT (6) | Closes tip-748B CmdDiag miss |
| R03 | onSubAgentSwarm | NOT_OBSERVED | Crash race |
| R04 | RUNTIME_REACHED | 1 | CmdDiag/onCommand only |
| R05 | RUNTIME_PASS | 0 | Fail-closed |
| A01 | Tip absorb | NOT_AUTHORIZED | |
| A02 | GhostText | NOT_AUTHORIZED | |

## Verdict

PathB CmdDiag RUNTIME_REACHED on candidate. Orch / PASS still OPEN.
PROMOTE=0.
