// ============================================================================
// RawrXD_Heartbeat_Shutdown.cpp - Heartbeat Monitor Shutdown
// AUDIT_002_OPENISH_OTHER_DRAIN_007:
// Prior: Heartbeat_Initialize invent running=true + LOG-only tick thread (empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[Heartbeat] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" void Heartbeat_Shutdown(void)
{
    GateFiction("Heartbeat_Shutdown");
}

extern "C" void Heartbeat_Initialize(void)
{
    // Was: invent g_heartbeatRunning=true + CreateThread LOG-only ticks.
    GateFiction("Heartbeat_Initialize");
}

extern "C" bool Heartbeat_IsRunning(void)
{
    GateFiction("Heartbeat_IsRunning");
    return false;
}
