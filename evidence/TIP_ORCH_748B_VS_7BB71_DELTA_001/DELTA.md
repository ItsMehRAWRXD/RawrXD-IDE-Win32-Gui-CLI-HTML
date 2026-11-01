# TIP_ORCH_748B_VS_7BB71_DELTA_001

Gap analysis only. Tip bin untouched. `G07_MET=0`. `TIP_CLIMB=HOLD`.

## Behavior

| Surface | Tip 748B | Cand 7BB71 |
|---------|----------|------------|
| LOAD | 200 | 200 |
| `/api/swarm/orch` n=2 | HTTP=0 / 0 bytes / reset | HTTP=200 / BOTH_COMPLETE |
| orchMgr lifetime | stack / per-request ~join before HTTP write | `static SubAgentManager` |
| tokCap | hard 2048 path (no `maxTokensPerWorker` string) | `maxTokensPerWorker=64` |
| ENGINE_BIND / ProductRun chat | absent in tip EXE strings | present |
| Disposition | `FAIL_CLOSED_NO_ORCH_BODY` (G07) | `G16_A_BOTH_COMPLETE` (N2 seals) |

## Absorb owners (next authorized tip freeze)

Primary empty-body: `HeadlessIDE_SwarmOrch.cpp` L212 static `orchMgr` + L216–217 drain + L160 tok64  
Supporting BOTH_COMPLETE: L176–208 ENGINE_BIND + ProductRun chat  
Core: `subagent_core.h` L142/L230/L297 · `subagent_core.cpp` L50–61 / L273–281 / L520

## Next authorized action

`AUTHORIZED_TIP_FREEZE_ABSORB_ORCH_STATIC_MGR_TOKCAP64_ENGINE_BIND_THEN_REPROBE_G07_N2_ON_NEW_TIP_SHA`
