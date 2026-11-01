# PATHB_4111_ID_SSOT_7BB71_001 — RECEIPT

```
ASOF_UTC=2026-10-29T13:05:00Z
GATE=PATHB_4111_ID_SSOT_7BB71_001
DISPOSITION=SOURCE_WIRED_SSOT_ALIGN
COLLISION_FOUND=1
SOURCE_WIRED=1
PROMOTE=0
TIP_CLIMB=HOLD
```

## Mission

Audit IDM 4111 / CmdDiag / AgentSessionBar / PathB SSOT collision on source vs
candidate `7BB71AB9`. SOURCE_WIRE residual miss. Seal this gate. RELINK
`TIP_CANDIDATE` only. Tip `748B` untouched.

## Return line

| Field | Value |
|-------|-------|
| collision found? | **YES** — historical AgentSessionBar HMENU 4111 (already SOURCE_WIRED) + residual `auto_discovery.cpp` off-by-one Chain=4111/Swarm=4112 |
| SOURCE_WIRED? | **YES** — AgentSessionBar/Compiler/Core prior; `auto_discovery.cpp` aligned this seal to Commands.h SSOT |
| next gate | `PathB_4111_reprove_TIP_CANDIDATE_AFTER_RELINK` |

## Grep disposition

| Surface | Status |
|---------|--------|
| `Win32IDE_Commands.h` | SSOT CHAIN=4110 SWARM=4111 |
| `Full Source/.../Win32IDE.h` | IDM_SUBAGENT_SWARM=4111 OK |
| `AgentSessionBar.cpp` | remapped 48101+ (SOURCE_WIRED) |
| `CompilerIntegration{,_Real}.cpp` | refuse 4110–4119 (SOURCE_WIRED) |
| `Win32IDE_Core.cpp` | SubAgent band → sehCallOnCommand (SOURCE_WIRED; live in 7BB71 crumbs) |
| `auto_discovery.cpp` | **MISS → FIXED** off-by-one → 4110–4114 |
| FeatureManifest / auto_feature_registry / vscode_extension_api | aligned |

## PathB 7BB71 note (not invented PASS)

`CMD_DIAG_id_4111=0` despite PostMessage 4111 + EXIT `C0000409` is
`UI_FAILFAST_BEFORE_4111_DISPATCH` (no id=4111 PRE_COMPILER crumb). Not the
AgentSessionBar HMENU class. N2 headless ≠ PathB.

## Explicit non-claims

- `RUNTIME_REACHED=NOT_RUN` until PathB re-prove on post-relink candidate
- Tip freeze bin untouched · `PROMOTE=0` · `ABSORB=NOT_AUTHORIZED`
