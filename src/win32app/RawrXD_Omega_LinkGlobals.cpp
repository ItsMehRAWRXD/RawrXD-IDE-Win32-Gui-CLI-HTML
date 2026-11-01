#include <cstdint>

extern "C" {

// Assembly-side Omega telemetry/fence globals for Win32IDE link lane.
// AUDIT_002_OPENISH_OTHER_DRAIN_016:
// Prior: g_rawrxd_omega_probe_early_return=1 invent Omega probe early-return as
// product ready PASS without validated Omega product wire (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — force 0; no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
volatile long g_rawrxd_completion_fence = 0;
volatile unsigned long long g_rawrxd_last_doorbell_addr = 0;
volatile unsigned long long g_rawrxd_last_doorbell_value = 0;
volatile unsigned long long g_rawrxd_last_doorbell_emit_seq = 0;
// Was: invent early_return=1 ready PASS.
volatile long g_rawrxd_omega_probe_early_return = 0;

}
