// ============================================================================
// AICompletion_Shutdown.cpp - FAIL_CLOSED (VAL-063)
// AUDIT_002_OPENISH_OTHER_DRAIN_007:
// Prior: invent AICompletion running/shutdown theater without completion subsystem (empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[AICompletion] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" void ShutdownAICompletion()
{
    // Was: invent shutdown-complete after flag wait (no completion threads).
    GateFiction("ShutdownAICompletion");
}

extern "C" void AICompletion_SetRunning(bool running)
{
    (void)running;
    // Was: invent g_aiCompletionRunning theater.
    GateFiction("AICompletion_SetRunning");
}

extern "C" bool AICompletion_IsShutdownRequested()
{
    GateFiction("AICompletion_IsShutdownRequested");
    return true; // fail-closed: treat as not runnable
}
