# SHELL_MODE_PERSIST_001

## Gap
Work Mode did not survive restart — createCommandSurface unconditionally called `enterCommandMode()`.

## Fix
1. `saveSession` writes `shellMode` = `work` | `command`
2. `restoreSession` sets `m_shellMode` before deferred children (unknown → Command)
3. `createCommandSurface` end: Work → `enterWorkMode()` else `enterCommandMode()`
4. Mode enters call `persistShellModeOnly()` (lightweight JSON key write)
5. After deferred UI: unconditional `applyShellModeChrome()`
6. IRC: stop blanket `tick()` on every `WM_TIMER` (PathB EXIT=1 root on AC46)

## Evidence
- Relink cand-only → `4E4345C2…` tip748B=1
- PathB RUNTIME_PASS · N2 G16_A_BOTH_COMPLETE · EXT PASS_6
- `INVENT_SHELL_MODE_PASS=0` · `PROMOTE=0`
