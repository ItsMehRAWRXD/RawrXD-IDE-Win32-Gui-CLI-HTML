# CONPTY_ASM_CANDIDATE_D11_001 — RECEIPT

```
ASOF_UTC=2026-10-29T11:43:30Z
DISPOSITION=CONPTY_ASM_MAP_CITE_SEALED_ON_D11_RUNTIME_NOT_RUN
CONPTY_CAND_MAP_HIT=1
RUNTIME_REACHED=0
RUNTIME_PASS=0
PROMOTE=0
TIP_CLIMB=HOLD
ABSORB=NOT_AUTHORIZED
CERTIFIED=0
NO_INVENT_PASS=1
TIP_UNTOUCHED=1
```

## SHA confirm

| Role | SHA256 | Status |
|------|--------|--------|
| Tip `TIP_FREEZE_001\bin` | `748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145` | MATCH UNTOUCHED |
| Candidate `TIP_CANDIDATE_AGENT_RUN_005\bin` | `D11AB5B695B46688348CA34131150F0E543191B4524B6E1F6568CA098D2B0862` | MATCH STABLE |

## Map cite (n2both.map)

| Symbol | RVA / VA | Obj |
|--------|----------|-----|
| `RawrXD_TUI_RenderThinkingBlock` | `0001:01d45a50` → `0000000141d46a50` | `RawrXD_ConPTY_Renderer.asm.obj` |
| `RawrXD_TUI_UpdateProgressBar` | `0001:01d45a80` → `0000000141d46a80` | `RawrXD_ConPTY_Renderer.asm.obj` |
| `GateConPtyStream` | `0001:00888e80` → `0000000140889e80` | `Win32TerminalManager.cpp.obj` |
| `ResolveConPtyApis` | `0001:00888f40` → `0000000140889f40` | `Win32TerminalManager.cpp.obj` |
| `g_CreatePseudoConsole` | `0003:114aa020` → `0000000153c1e020` | `Win32TerminalManager.cpp.obj` |

Authority file: `MAP_CITE.txt` · full extract: `logs/conpty_asm_map_cite.txt`

## Fail-closed

`MAP_CITE=1` closes GOLD_LINK `CONPTY_CAND_MAP_HIT=PENDING_RELINK` and SWARM_ORCH_N2_RESET item 3 for D11.

`NOT_RUN != PASS` — no ConPTY HWND / CreatePseudoConsole runtime witness this seal. `RUNTIME_REACHED=0` `RUNTIME_PASS=0`.

## Next gate

`CONPTY_RUNTIME_WITNESS_D11_CreatePseudoConsole_HWND_PS_PANEL` on candidate D11 only. Tip 748B remains frozen. `PROMOTE=0` `TIP_CLIMB=HOLD`.
