# RECEIPT — VEH_MSFTEDIT_FIRST_CHANCE_DUMP_001

```
GATE=VEH_MSFTEDIT_FIRST_CHANCE_DUMP_001
ASOF_UTC=2026-10-30T16:44:00Z
DUMP=1 MINIDUMP=PRESENT STACK=1
CLASS=BENIGN_SURVIVED
tip748B=1 TIP_UNTOUCHED=1
VEH_FATAL_73368=0
PROMOTE=0 TIP_CLIMB=HOLD ABSORB=NOT_AUTHORIZED
CERTIFIED=0 PATHB_CERTIFIED=0 IDE_CERTIFIED=0
NEXT_GATE=POST_PATHB_PASS_PROMOTION_HELD
```

## Return fields

| Field | Value |
|-------|--------|
| DUMP | `dumps/msftedit_fc.dmp` (+3 siblings) |
| STACK | `1` (VEH FRAME_COUNT=32; cdb ABSENT) |
| CLASS | `BENIGN_SURVIVED` |
| tip748B | `1` |
| VEH_FATAL_73368 | `0` |
| PROMOTE | `0` |
| NEXT_GATE | `POST_PATHB_PASS_PROMOTION_HELD` |

## FOUR_FIELD

```
EXCEPTION_CODE=0xC0000005
FAULT_MODULE=msftedit.dll
SURVIVED=1
DUMP=1
```

## Capture method

1. Started `procdump64 -e 1 -f *C0000005* -n 4 -mm -w RawrXD-Win32IDE.exe` → dumps dir.
2. Ran `harness_pathb_4111_73368d76.ps1` on cand `73368` (tip `748B` untouched).
3. ProcDump attached PID=19664; wrote **4** MiniDumps on first-chance `C0000005.ACCESS_VIOLATION`.
4. PathB completed: BOTH_COMPLETE, EXIT=0x00000000, GUI_RESPONSIVE=1, VEH_FATAL_COUNT=0.
5. VEH journal: FC_JOURNAL_COUNT=4, msftedit RVA `0x212222`, FRAME_COUNT=32.

`cdb.exe` not installed (Windows Kits Debuggers ABSENT). Stack authority = VEH journal frames correlated to dump trigger time. MiniDump bytes are real on disk — **not invented**.

## Primary dump

| Artifact | SHA256 | Size |
|----------|--------|------|
| `dumps/msftedit_fc.dmp` | `9003181B600073BBAA68455EEF0F4BCC819BCE17E1969E8F7164F8B63935892B` | 297126247 |
| `dumps/msftedit_fc-1.dmp` | `43403A899E029227EC705F553708B938C0990B528C2AF39503FF6A516D475814` | 297211281 |
| `dumps/msftedit_fc-2.dmp` | `0F8399F90CBDD5845C605B47A0D88560DFD17847DB07C7894B441700580E6B14` | 297206489 |
| `dumps/msftedit_fc-3.dmp` | `7792019325608DEBD67030E5A7DE551D6E1175B3392B192ED143D6A04169782F` | 297206489 |

Hashes: `dumps/DUMP_SHA256.txt`. ProcDump log: `dumps/procdump_stdout_decoded.txt`.

## Classification evidence

**CLASS=BENIGN_SURVIVED** because:

- First-chance AV dumped ×4 and process continued.
- EXIT=0x00000000, FORCED_STOP=0, GUI_RESPONSIVE=1.
- VEH_FATAL_COUNT=0 (matches prior `VEH_MSFTEDIT_RELINK_PATHB_73368_001`).
- PathB RUNTIME_PASS=1 re-observed this run.

Not claimed: tip absorb, PROMOTE, IDE/PathB certification, or msftedit root-cause closed. Underlying AV at RVA `0x212222` remains real.

## Priors (unchanged authority)

- ABE4 PathB witness immutable; live cand=`73368`.
- `VEH_MSFTEDIT_FIRST_CHANCE_ABE4_001`: MINIDUMP=ABSENT DUMP=0 SURVIVED=1 (superseded for dump presence only).
- `VEH_MSFTEDIT_RELINK_PATHB_73368_001`: VEH_FATAL=0 SOURCE_WIRE linked.
- Tip freeze bin **not** overwritten (`748B210A…`).

## Explicit non-claims

```
SOURCE_WIRED != RUNTIME_REACHED != TOKEN_SURVIVED != PERFORMANCE_PASS
RUNTIME_PASS != PROMOTE != TIP_CERTIFIED
DUMP_PRESENT != PATHB_CERTIFIED != IDE_CERTIFIED
PROMOTE=0 ABSORB=NOT_AUTHORIZED
```
