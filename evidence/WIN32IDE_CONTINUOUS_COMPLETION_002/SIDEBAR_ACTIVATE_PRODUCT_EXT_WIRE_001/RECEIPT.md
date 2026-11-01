# SIDEBAR_ACTIVATE_PRODUCT_EXT_WIRE_001 RECEIPT

```
ASOF_UTC=2026-10-31T03:05:10Z
SEAL=SIDEBAR_ACTIVATE_PRODUCT_EXT_WIRE_001
PARENT=WIN32IDE_CONTINUOUS_COMPLETION_002
CAND_SHA_BEFORE=D41BB1DBAAFC7B6AC9135EEA848F757EB0E3474B479DABED832296F69DE19F98
CAND_SHA_AFTER=57B9DB259A6E7D58C7E32DF0E423B164E6B02B196524191ADFEDB43A81C8894E
TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
tip748B=1
PROMOTE=0
ABSORB=NOT_AUTHORIZED
TIP_CLIMB=HOLD
CERTIFIED=0
SMOKE_PASS=1
ACTIVATE_API_OK=1
synthetic=0
```

## Gap closed

Live cand Extensions toolbar Install/dblclick called `installExtension` (VSIXLoader path)
instead of ProductExtensionRuntime host Activate. Enable/Disable toolbar buttons absent.

### Source wire

| Site | Change |
|------|--------|
| `Win32IDE.h` | declare `activateExtension` |
| `Win32IDE_Sidebar.cpp` | `activateExtension` → `ProductExtensionRuntime::Activate`; Install→Activate; Enable/Disable buttons; installExtension prefers ListRecords→Activate |
| `Win32IDE_HandleExtensionCommand.cpp` | Install/Enable/Disable → activate/enable/disable product path |

### Build / runtime

| Field | Value |
|------|------|
| Compile | Sidebar+HandleExt EXIT=0 |
| Relink | cand only · LINK_EXIT=0 · orphans ProductExt+PathB prepended |
| Tip | 748B UNTOUCHED |
| Smoke | SCAN/ENABLE/DISABLE/ACTIVATE HTTP200 ADAPTER=product_extension_runtime |
| PathB | RUNTIME_PASS (fresh 57B9) |
| N2 | G16_A_BOTH_COMPLETE (fresh 57B9) |
| EXT | PASS=6 (fresh 57B9) |

## Non-claims

```
SMOKE_PASS != PROMOTE
NEW_SHA != D41B transfer
SOURCE_WIRED UI Activate != invent marketplace Available list
PROMOTE=0
```

## NEXT

OPENISH orphan CallStackSymbols (real Sym*) blocked by Tier5Cosmetics thin dup —
OR K2 residency with memory available (prior BLOCKED_OOM; SCOPE_EXCEPTION=0).
