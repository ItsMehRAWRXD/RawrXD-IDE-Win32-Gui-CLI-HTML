// Win32IDE_BuildProvenance.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_005:
// Prior: Init/RecordBuild invent in-memory provenance PASS theater (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>
#include <cstdint>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[BuildProvenance] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" __declspec(dllexport) int Win32IDE_BuildProvenance_Init() {
    GateFiction("Win32IDE_BuildProvenance_Init");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_BuildProvenance_Shutdown() {
    GateFiction("Win32IDE_BuildProvenance_Shutdown");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_BuildProvenance_RecordBuild(const char* buildTag, const char* sourcePath, uint32_t success, uint32_t durationMs, uint64_t outputHash, uint32_t* outBuildId) {
    (void)buildTag;
    (void)sourcePath;
    (void)success;
    (void)durationMs;
    (void)outputHash;
    if (outBuildId) *outBuildId = 0;
    GateFiction("Win32IDE_BuildProvenance_RecordBuild");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_BuildProvenance_GetBuildInfo(uint32_t buildId, char* outTag, uint32_t tagMaxLen, char* outSource, uint32_t sourceMaxLen, uint32_t* outSuccess, uint32_t* outDuration) {
    (void)buildId;
    if (outTag && tagMaxLen) outTag[0] = 0;
    if (outSource && sourceMaxLen) outSource[0] = 0;
    if (outSuccess) *outSuccess = 0;
    if (outDuration) *outDuration = 0;
    GateFiction("Win32IDE_BuildProvenance_GetBuildInfo");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_BuildProvenance_GetLatestBuild(uint32_t* outBuildId) {
    if (outBuildId) *outBuildId = 0;
    GateFiction("Win32IDE_BuildProvenance_GetLatestBuild");
    return 0;
}
