# AMD clean-stack normalization (AUDIT_002 next)

Current mixed inventory (pre-normalize):

| Adapter | DriverVersion |
|---------|---------------|
| AMD Radeon(TM) Graphics (iGPU) | 32.0.21042.62 |
| AMD Radeon AI PRO R9700 | 32.0.31044.16 |
| AMD Radeon RX 7800 XT | 32.0.31041.1004 |

## Operator sequence
1. Create a restore point / note rollback package.
2. Prefer **AMD Cleanup Utility** (Safe Mode if stacked installs).
3. Install **one** current package intended to cover both discrete GPUs (or OEM-matched stack). Avoid leaving mismatched Adrenalin vs PRO builds.
4. Optional soak aid: disable iGPU in Device Manager while testing (re-enable after).
5. After install: reboot (combines with dump pagefile reboot).
6. Record exact `DriverVersion` for R9700 + 7800 XT into `AMD_DRIVERS_AFTER.json`.

Do **not** start product E2E or dual-GPU stress until `HOST_STABILITY_AUDIT_002` seals PASS/FAIL/UNVERIFIED after soak.
