# RECEIPT — TIP_FREEZE_748B_HEADLESS_SURFACE_001

```
ASOF_UTC=2026-10-28T17:12:41Z
TIP_SHA=748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145
PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0
NO_INVENT_PASS=1 REBUILD=0
GHOSTTEXT_B421_ABSORB=NOT_AUTHORIZED
```

## Tip EXE

| Field | Value |
|-------|-------|
| Path | `G:\~dev\rawrxd\evidence\TIP_FREEZE_001\bin\RawrXD-Win32IDE.exe` |
| SHA256 | `748B210A8F17C6C47685BE1E2718CB0113C070E47881AD3A76B2EBB013934145` |
| SHA_MATCH | **1** |

## Primary surface (port 18991, `logs/F_*.*`)

| Probe | HTTP | Disposition |
|-------|------|-------------|
| no-key `read_motd` | **401** unauthorized | A07 |
| evil Origin | **403** `origin_denied` | G16/A07 |
| `read_motd` (in-workspace) | **200** MOTD content | G16 |
| `list_directory` | **200** entries | G16 |
| `write_file` inside sandbox | **200** `atomic:true previewed:true rollback_id:1` | A06 |
| deny abs / `..` / UNC | **403** forbidden; FS outside absent | A06 |
| `execute_command` no grant | **403** `execution_not_granted` | A07 |

## Exec grant (port 18992, `logs/F2_*.*`)

| Probe | HTTP | Disposition |
|-------|------|-------------|
| MOTD then `execute_command` with `RAWRXD_IDE_EXEC_GRANT=1` | **200** `exitCode:0` `exec_ok_748b` | additive earn |

Also corroborated earlier same-SHA: `logs/SEAL_exec_grant.body.txt`, `logs/R2_exec_grant.body.txt`.

## Matrix claims (fail-closed)

| Gate | Result | Note |
|------|--------|------|
| **G16** | **MET** | Same-SHA tip freeze proof; supersedes 6832-only cite |
| **A06** | **RUNTIME_REACHED** | Deny + atomic write fields on tip; full MET denied (safety rollback API / injection still open) |
| **A07** | **RUNTIME_REACHED** | Auth/origin/exec-no-grant earned; injection-parse HTTP NOT_RUN → MET=0 |
| EXEC grant | EARNED | Additive; ≠ A07 MET |
| PROMOTE | **0** | |

## Explicit non-claims

```
NOT_RUN != PASS
A06 RUNTIME_REACHED != MET
A07 RUNTIME_REACHED != MET
G16 MET != PROMOTE
GHOSTTEXT B421 ABSORB=NOT_AUTHORIZED
AGENT_RUN_LOOP_TIP_003 HTTP 503 remains FAIL_CLOSED for G02
SWARM PATH_B RUNTIME_PASS=0 remains for G07
SAFE_WRITE_ATOMIC_001 RELINK note historical for 6832 — tip 748B write body shows atomic fields (no invent full A06 MET)
```
