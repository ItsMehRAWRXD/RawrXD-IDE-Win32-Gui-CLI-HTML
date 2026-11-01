// C-linkage Titan pressure for Swarm/AgentKernel (Win32IDE does not load RawrXD_Titan.dll at link time).
// AUDIT_002_OPENISH_OTHER_DRAIN_007:
// Prior: Titan_GetMemoryPressure invent return 0.0 empty-true (fake-ready healthy pressure).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include <windows.h>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[TitanPressure] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" double Titan_GetMemoryPressure()
{
    // Was: invent return 0.0 (no Titan.dll / aperture wire).
    GateFiction("Titan_GetMemoryPressure");
    return -1.0;
}
