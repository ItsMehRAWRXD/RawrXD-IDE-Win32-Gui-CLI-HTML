#include "Win32IDE.h"
#include "../core/shared_feature_dispatch.h"
#include <windows.h>

/**
 * AUDIT_002_OPENISH_OTHER_DRAIN_004:
 * Prior: invent "Hardware Synthesizer Active" + FPGA/ASIC list (fake-ready).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

CommandResult HandleHardwareSynthesizer(const CommandContext& ctx) {
    (void)ctx;
    OutputDebugStringA(
        "[HardwareSynthesizer] FEATURE_FICTION=1 FAIL_CLOSED HandleHardwareSynthesizer\n");
    return CommandResult::error(
        "FEATURE_FICTION=1 FAIL_CLOSED HardwareSynthesizer (no invent Active PASS)", -1);
}
