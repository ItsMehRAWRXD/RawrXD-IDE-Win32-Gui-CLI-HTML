// ============================================================================
// RawrXD_Infinity_Shutdown.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_006:
// Prior: INFINITY_Initialize invent running=true without context (empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[INFINITY] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" void INFINITY_Shutdown(void)
{
    GateFiction("INFINITY_Shutdown");
}

extern "C" void INFINITY_Initialize(void)
{
    // Was: invent g_infinityRunning=true (no infinite-context / session wire).
    GateFiction("INFINITY_Initialize");
}

extern "C" bool INFINITY_IsRunning(void)
{
    GateFiction("INFINITY_IsRunning");
    return false;
}
