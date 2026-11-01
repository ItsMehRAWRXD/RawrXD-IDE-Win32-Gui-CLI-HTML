# SIDEBAR_PRODUCT_EXT_WIRE_001 RECEIPT

```
ASOF_UTC=2026-10-31T02:35:45Z
SEAL=SIDEBAR_PRODUCT_EXT_WIRE_001
PARENT=WIN32IDE_CONTINUOUS_COMPLETION_001
CAND_SHA_BEFORE=FD07CA615E35F04EBFE66EA583ABDE10BFDA56A08656E8B1A8ECA1B1C2851540
CAND_SHA_AFTER=919593F89D4CC9BA32E79875FC314A20FBE1C8105D5B4D705DEC7073544E1990
TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
tip748B=1
PROMOTE=0
ABSORB=NOT_AUTHORIZED
TIP_CLIMB=HOLD
CERTIFIED=0
MATRIX_002_TRANSFER=0
PATHB_TRANSFER=0
N2_TRANSFER=0
SMOKE_PASS=1
synthetic=0
```

## Gap closed

Live cand UI path `Win32IDE_Sidebar.cpp` (linked) had enable/disable as
in-memory toggles only — not ProductExtensionRuntime. Orphan
`Win32IDE_ExtensionsPanel.cpp` / `Win32IDE_SidebarPanels.cpp` remain
FEATURE_FICTION / unlinked (not reopened invent theater).

### Source wire

| Site | Change |
|------|--------|
| `ProductExtensionRuntime.hpp` | `ListRecords()` |
| `ProductExtensionRuntime_Scan.cpp` | implement `ListRecords()` |
| `Win32IDE_Sidebar.cpp` | `#include ProductExtensionRuntime.hpp` |
| `enableExtension` / `disableExtension` | call `ProductExtensionRuntime::Enable` + SetRoots |
| `loadInstalledExtensions` | merge `ListRecords()` into `m_extensions` |

### Build / runtime

| Field | Value |
|------|------|
| Compile | Scan.cpp EXIT=0 · Sidebar.cpp EXIT=0 |
| Relink | cand only · LINK_EXIT=0 |
| Tip | 748B UNTOUCHED |
| Smoke | `smoke_ext_api_9195.ps1` SCAN_HTTP=200 ADAPTER=product_extension_runtime ENABLE/DISABLE HTTP=200 |
| PRODUCT_THIN | 0 |

## Non-claims

```
SMOKE_PASS != MATRIX_002 PASS (full 6/6 not re-run this seal)
SMOKE_PASS != PathB/N2 PASS
NEW_SHA != FD07 transfer
SOURCE_WIRED UI enable != GUI click E2E (API path exercised; Sidebar symbols relinked)
PROMOTE=0
```

## NEXT

`PATHB_N2_REPROVE_ON_9195` (prior FD07 PathB/N2 do not transfer)
+ residual OPENISH real-partial (UI_PANEL orphan createExtensionsPanel still fiction)
