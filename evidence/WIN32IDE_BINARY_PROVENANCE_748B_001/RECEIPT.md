# RECEIPT — WIN32IDE_BINARY_PROVENANCE_748B_001

```
PROMOTE=0
TIP_CLIMB=HOLD
CERTIFIED=0
NO_REBUILD=1
NO_RELINK=1
NO_INVENT_PASS=1
FAIL_CLOSED=1
WORKSPACE=G:\~dev\rawrxd
MOTD_ACK=1
ASOF_UTC=2026-10-29T12:00:43Z
TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
CITE_AUTHORITY=TIP_FREEZE_001\TIP_EXE_AUTHORITY.txt
A01_MET=0
A01=OPEN
NEXT_GATE=A01_748B_MAP_CMAKE_COSEAL
```

## Verdict

| Gate | Result |
|------|--------|
| Tip EXE SHA on freeze disk | **MATCH** `748B210A…` |
| EXE size documented | **YES** `331702784` |
| PDB present + hashed | **YES** |
| Build id (PE RSDS) documented | **YES** `{D7267FAD-…}` age 1 / stamp `6AE203A0` |
| Link map for tip 748B | **MISSING** (freeze absent; build-live map ≠ 748B) |
| CMake/ninja/build-log co-seal for 748B | **ABSENT** |
| Link to TIP_EXE_AUTHORITY | **YES** |
| Invent transfer from 6832/C4FC | **NOT DONE** |
| A01 reproducible attribution | **OPEN** (`A01_MET=0`) |
| PROMOTE | **0** |

## Tip EXE (authority freeze)

| Field | Value |
|-------|-------|
| Path | `G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe` |
| Size | 331702784 |
| SHA256 | `748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145` |
| MTIME_UTC | 2026-10-28T14:16:01.9600966Z |
| Authority | `TIP_FREEZE_001\TIP_EXE_AUTHORITY.txt` |

## PDB / map / build id

| Artifact | Present | Size | SHA256 / cite |
|----------|---------|------|---------------|
| `RawrXD-Win32IDE.pdb` (freeze) | YES | 102150144 | `86AA0E7C…A9681512` |
| `RawrXD-Win32IDE.map` (freeze) | **NO** | — | MISSING |
| PE RSDS GUID | YES | — | `{D7267FAD-FF44-4E12-B762-7D69C037F0AB}` age 1 |
| PE time date stamp | YES | — | `6AE203A0` (2026-10-28 10:16:00) |
| Build-live map/EXE | observe-only | — | EXE `93503F05…` ≠ 748B — **not citable** |

## Gaps (A01 incomplete)

1. **MAP_MISSING_748B** — no link map frozen beside tip EXE; cannot attribute objs/symbols to 748B.
2. **CMAKE_NINJA_COSEAL_ABSENT** — no 748B-era `build.ninja` / `.ninja_log` / relink log sealed here.
3. **BUILD_LOG_CITE_ABSENT** — no dedicated 748B link log in this pack.
4. **NO_OBJ_INVENTORY** — withheld (would require 748B map; no invent from PROVENANCE_003).

## Explicit non-claims

```
A01_MET=0
NO_INVENT_SHA_TRANSFER_FROM_6832_OR_C4FC=1
WIN32IDE_BINARY_PROVENANCE_003 A01=MET is HISTORICAL to 6832F439… only
BUILD_LIVE map/EXE != tip provenance
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 ABSORB=NOT_AUTHORIZED
```

## Next gate

`A01_748B_MAP_CMAKE_COSEAL` — recover a map contemporaneous with freeze EXE `748B210A…`, or new tip freeze that co-seals EXE+PDB+MAP+cmake/ninja fingerprints; then re-audit. Do not transfer PROVENANCE_003.

## Artifacts

- `evidence/WIN32IDE_BINARY_PROVENANCE_748B_001/LAW.txt`
- `evidence/WIN32IDE_BINARY_PROVENANCE_748B_001/RECEIPT.md`
- `evidence/WIN32IDE_BINARY_PROVENANCE_748B_001/live_observe.txt`
- `evidence/WIN32IDE_BINARY_PROVENANCE_748B_001/pe_rsds.txt`
- `evidence/WIN32IDE_BINARY_PROVENANCE_748B_001/HISTORICAL.txt`
- `evidence/WIN32IDE_BINARY_PROVENANCE_748B_001/GAPS.txt`
- `evidence/WIN32IDE_BINARY_PROVENANCE_748B_001/BUNDLE_SHA256.txt`
