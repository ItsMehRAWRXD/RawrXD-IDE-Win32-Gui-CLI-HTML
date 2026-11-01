# COMMAND_PALETTE_DAP_SPAWN_PRODUCT_WIRE_001

| Field | Value |
|-------|-------|
| Parent | WIN32IDE_CONTINUOUS_COMPLETION_007 |
| BEFORE | `09DB6065B7C32BA2FD8C64A6D575EA7F19228AC1A671ED5F977C6D94F7BBEE37` |
| AFTER | `5BBF7A0909A830CAB64118D8A472DDD706029E84E556B80C134E6CFBABA35EE8` |
| tip748B | 1 (748B MATCH UNTOUCHED) |
| LINK_EXIT | 0 |
| PROMOTE | 0 |
| INVENT_DAP_PASS | 0 |
| WEDGED_PRIOR | 04eaa4e4 |

## Wired

- `Win32IDE_DapAdapterSpawn.cpp` — adapter path resolve + fail-closed CreateProcess probe
- `Win32IDE_DapServiceProduct.cpp` — product path calls spawn helpers

## Held (honest)

- `Win32IDE_CommandPalette.cpp` — namespace/class `Win32IDE` clash (C2825); not FEATURE_FICTION
