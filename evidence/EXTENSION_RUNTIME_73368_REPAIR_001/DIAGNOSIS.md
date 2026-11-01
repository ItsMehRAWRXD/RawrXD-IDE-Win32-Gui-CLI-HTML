# EXTENSION_RUNTIME_73368_REPAIR_001 — DIAGNOSIS

## Prior FAIL (MATRIX_001)

- Cand EXE `73368D76…` returned `adapter=product_thin` for all `/api/extensions/*`.
- `host_pid:0` invent-empty; no ExtensionHost child.
- COMMANDS: `/api/tool` extension.activate → 403 (no tool + MOTD) / FEATURE_FICTION GUI IDs.
- Prior worker `ec09bdd5` ended unavailable mid-flight after landing partial `ProductExtensionRuntime*`.

## Root cause

1. **LocalServer / Headless still routed through `ProductGuiRoutes::extensionsJson` (product_thin).**
2. **ProductExtensionRuntime TUs existed on disk but were not linked into cand EXE.**
3. **`RawrXD-ExtensionHost.exe` absent beside cand bin → spawn fail-closed host_pid=0.**
4. **Scan/Enable/Activate double-locked `Mu()` (would deadlock once wired) — fixed to ScanUnlocked.**

## Repair (cand only; tip untouched)

| Step | Result |
|------|--------|
| Wire `HandleRoute` into HeadlessIDE_GuiRoutes + Win32IDE_LocalServer | DONE |
| Wire `extension.activate` into Headless + LocalServer `/api/tool` | DONE |
| Compile 8 ProductExtensionRuntime TUs + 3 wire TUs; solo relink cand | DONE |
| Build `RawrXD-ExtensionHost.exe` beside cand bin | DONE |
| Fixtures + MATRIX_002 harness; run cells | PASS=6 |

## SHA

```
CAND_SHA_BEFORE=73368D764EB8B2C632994542D6E2256668F1752F10E3CDBF08546343D793E738
CAND_SHA_AFTER=FD07CA615E35F04EBFE66EA583ABDE10BFDA56A08656E8B1A8ECA1B1C2851540
TIP=748B210A… tip748B=1 TIP_REBUILD=0
HOST_SHA=CA89BA092BE92F5F5FAD94AE56996736A9CA5A7E5AEDF793F0F3D08FB9A18462
```

## Authority preserved

```
PROMOTE=0 ABSORB=NOT_AUTHORIZED
PATHB_73368_HISTORICAL_SEAL_STAYS=1
GHOSTTEXT_REOPEN=0
NEXT_GATE=POST_SCHEDULER_PROMOTION_REQUIREMENTS
```
