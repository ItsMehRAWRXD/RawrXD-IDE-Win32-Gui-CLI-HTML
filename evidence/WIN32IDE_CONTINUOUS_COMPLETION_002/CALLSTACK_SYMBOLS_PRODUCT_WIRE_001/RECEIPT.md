# CALLSTACK_SYMBOLS_PRODUCT_WIRE_001 RECEIPT

```
ASOF_UTC=2026-10-31T03:14:12Z
SEAL=CALLSTACK_SYMBOLS_PRODUCT_WIRE_001
PARENT=WIN32IDE_CONTINUOUS_COMPLETION_002
CAND_SHA_BEFORE=57B9DB259A6E7D58C7E32DF0E423B164E6B02B196524191ADFEDB43A81C8894E
CAND_SHA_AFTER=338ED81546989D731B687DB7FA07BC7C121D8328A4226739DF46254EBFDE801F
TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
tip748B=1
PROMOTE=0
ABSORB=NOT_AUTHORIZED
TIP_CLIMB=HOLD
CERTIFIED=0
SMOKE_PASS=1
PathB=RUNTIME_PASS
N2=G16_A_BOTH_COMPLETE
EXT=PASS_6
synthetic=0
```

## Gap closed

OPENISH DEBUGGER orphan `Win32IDE_CallStackSymbols.cpp` (real SymInitialize /
CaptureStackBackTrace) was unlinked. Linked Tier5Cosmetics held thin invent-ish
callstack dump stubs for the same symbols (LNK2005 if both linked).

### Source wire

| Site | Change |
|------|--------|
| `Win32IDE_Tier5Cosmetics.cpp` | remove `initCallStackSymbols` / `handleCallStackCommand` thin stubs |
| link | add `Win32IDE_CallStackSymbols.cpp.obj` (cand orphans prepend) |

### Build / runtime

| Field | Value |
|------|------|
| Compile | Tier5+CallStackSymbols EXIT=0 |
| Relink | cand only LINK_EXIT=0 |
| Tip | 748B UNTOUCHED |
| Smoke | ACTIVATE/ENABLE EXT API PASS |
| PathB | RUNTIME_PASS |
| N2 | BOTH_COMPLETE |
| EXT | PASS=6 |

## Non-claims

```
SOURCE_WIRED CallStack != GUI menu E2E capture certified
NEW_SHA != 57B9 transfer
PROMOTE=0
```

## NEXT

K2 host residency HOST_BLOCKED (weights ~44152MB > FreeRAM ~30GB; SCOPE_EXCEPTION=0)
OR remaining OPENISH real-partial orphans (DebuggerIntegration / ExtensionHost* / ReferencesPanel)
not invent theater.
