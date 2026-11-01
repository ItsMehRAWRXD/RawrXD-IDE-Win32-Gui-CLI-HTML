// Win32IDE_ExecutionTruth.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_005:
// Prior: VerifyTruth invent TRUTH_VERIFIED + return 1 without real check (empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>
#include <cstdint>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[ExecutionTruth] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" __declspec(dllexport) int Win32IDE_ExecutionTruth_Init() {
    GateFiction("Win32IDE_ExecutionTruth_Init");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ExecutionTruth_Shutdown() {
    GateFiction("Win32IDE_ExecutionTruth_Shutdown");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ExecutionTruth_RegisterTruth(const char* name, uint32_t* outTruthId) {
    (void)name;
    if (outTruthId) *outTruthId = 0;
    GateFiction("Win32IDE_ExecutionTruth_RegisterTruth");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ExecutionTruth_VerifyTruth(uint32_t truthId, uint32_t checksum) {
    (void)truthId;
    (void)checksum;
    // Was: invent TRUTH_VERIFIED + return 1 (no witness/hash verify).
    GateFiction("Win32IDE_ExecutionTruth_VerifyTruth");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ExecutionTruth_FailTruth(uint32_t truthId) {
    (void)truthId;
    GateFiction("Win32IDE_ExecutionTruth_FailTruth");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ExecutionTruth_GetTruthState(uint32_t truthId, int* outState, uint32_t* outChecksum, uint32_t* outRetryCount) {
    (void)truthId;
    if (outState) *outState = 0;
    if (outChecksum) *outChecksum = 0;
    if (outRetryCount) *outRetryCount = 0;
    GateFiction("Win32IDE_ExecutionTruth_GetTruthState");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ExecutionTruth_GetStats(int* verified, int* failed) {
    if (verified) *verified = 0;
    if (failed) *failed = 0;
    GateFiction("Win32IDE_ExecutionTruth_GetStats");
    return 0;
}
