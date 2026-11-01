#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>

/**
 * @file Win32IDE_PageFaultHandler.cpp
 * @brief Batch 3 (23/118): Custom Page Fault & Exception Interceptor.
 *
 * AUDIT_002_OPENISH_OTHER_DRAIN_005:
 * Prior: Trap_InitializeHandler / Trap_RestoreState LOG-only empty body (empty-true VEH claim).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

namespace RawrXD::Safety::Exceptions {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[Trap] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

// Resolves: Trap_InitializeHandler
extern "C" void Trap_InitializeHandler() {
    // Was: LOG-only invent VEH ready (no AddVectoredExceptionHandler).
    GateFiction("Trap_InitializeHandler");
    LOG_ERROR("[Trap] FEATURE_FICTION=1 FAIL_CLOSED VEH (no handler wired)");
}

// Resolves: Trap_RestoreState
extern "C" void Trap_RestoreState() {
    // Was: LOG_SUCCESS invent restore complete (no state restore).
    GateFiction("Trap_RestoreState");
    LOG_ERROR("[Trap] FEATURE_FICTION=1 FAIL_CLOSED restore (no kernel state)");
}

} // namespace RawrXD::Safety::Exceptions
