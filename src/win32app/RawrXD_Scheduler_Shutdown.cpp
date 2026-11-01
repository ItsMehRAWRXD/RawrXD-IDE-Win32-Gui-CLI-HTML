// ============================================================================
// RawrXD_Scheduler_Shutdown.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_006:
// Prior: Scheduler_Initialize invent running=true without scheduler (empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[Scheduler] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" void Scheduler_Shutdown(void)
{
    GateFiction("Scheduler_Shutdown");
}

extern "C" void Scheduler_Initialize(void)
{
    // Was: invent g_schedulerRunning=true + return (no real task scheduler).
    GateFiction("Scheduler_Initialize");
}

extern "C" bool Scheduler_IsRunning(void)
{
    GateFiction("Scheduler_IsRunning");
    return false;
}

extern "C" void Scheduler_RegisterThread(HANDLE hThread)
{
    (void)hThread;
    GateFiction("Scheduler_RegisterThread");
}
