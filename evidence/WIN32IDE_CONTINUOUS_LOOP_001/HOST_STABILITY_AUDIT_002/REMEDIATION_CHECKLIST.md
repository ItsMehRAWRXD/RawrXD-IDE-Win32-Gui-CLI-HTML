# HOST_STABILITY_AUDIT_002 — Remediation checklist

Prior: `HOST_STABILITY_AUDIT_001` = **UNVERIFIED** (accepted).

## 1. Dump capture repair
- [ ] Choose dump type intentionally (`3` Small recommended until capacity known; `1` Complete only with ~RAM free space / dedicated dump)
- [ ] Configure pagefile **or** `DedicatedDumpFile` with adequate capacity
- [ ] Inspect/clear `volmgr` 45/46 causes (filter load, pagefile, permissions)
- [ ] Confirm MinidumpDir / DumpFile path writable
- [ ] Verify config after reboot (no forced production crash for proof)

## 2. AMD driver normalization
- [ ] Single clean Adrenalin/PRO stack covering R9700 + 7800 XT (record exact versions)
- [ ] Optional: disable unused iGPU for soak window
- [ ] Preserve rollback (restore point / driver package archive)
- [ ] Confirm Vulkan proprietary enum still shows both discrete GPUs

## 3. Reboot baseline
- [ ] Export System: 41, 6008, WHEA, Display/TDR-related
- [ ] Export Application: `atiadlxx` / `atieclxx` / `amdkmdag` / LiveKernel 0x141
- [ ] Record boot timestamp + `volmgr` 45/46 absence/presence

## 4. Defined soak
- [ ] Basic health green first
- [ ] Representative light IDE workload (not dual-GPU stress until P0 PASS)
- [ ] Stop on new Event 41 / TDR / ADL AV
- [ ] Record duration + workload list

## 5. Seal AUDIT_002
- [ ] Config + observations + duration + failures + `HOST_STABILITY=PASS|UNVERIFIED|FAIL`
- [ ] Only then lift `PRODUCT_RUNTIME_E2E=HELD`
