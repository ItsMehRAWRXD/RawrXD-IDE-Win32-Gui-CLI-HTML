// Win32IDE_ParityEngine.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_005:
// Prior: Init/Register/Report invent in-memory PASS theater (fake-ready "Production").
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>
#include <cstdint>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[ParityEngine] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" __declspec(dllexport) int Win32IDE_ParityEngine_Init() {
    GateFiction("Win32IDE_ParityEngine_Init");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ParityEngine_Shutdown() {
    GateFiction("Win32IDE_ParityEngine_Shutdown");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ParityEngine_RegisterCheck(const char* name, uint64_t expected, uint32_t* outCheckId) {
    (void)name;
    (void)expected;
    if (outCheckId) *outCheckId = 0;
    GateFiction("Win32IDE_ParityEngine_RegisterCheck");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ParityEngine_ReportActual(uint32_t checkId, uint64_t actual) {
    (void)checkId;
    (void)actual;
    GateFiction("Win32IDE_ParityEngine_ReportActual");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ParityEngine_GetStats(int* passCount, int* failCount) {
    if (passCount) *passCount = 0;
    if (failCount) *failCount = 0;
    GateFiction("Win32IDE_ParityEngine_GetStats");
    return 0;
}
