// Win32IDE_GGUFManifold.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_006:
// Prior: CreateManifold invent loaded=1 without GGUF map (fake-ready Production).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>
#include <cstdint>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[GGUFManifold] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" __declspec(dllexport) int Win32IDE_GGUFManifold_Init() {
    GateFiction("Win32IDE_GGUFManifold_Init");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_GGUFManifold_Shutdown() {
    GateFiction("Win32IDE_GGUFManifold_Shutdown");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_GGUFManifold_CreateManifold(const char* name, uint64_t tensorCount, uint64_t totalSize, uint32_t* outManifoldId) {
    (void)name;
    (void)tensorCount;
    (void)totalSize;
    if (outManifoldId) *outManifoldId = 0;
    // Was: invent loaded=1 + return 1 (no GGUF map/magic).
    GateFiction("Win32IDE_GGUFManifold_CreateManifold");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_GGUFManifold_GetManifoldInfo(uint32_t manifoldId, char* outName, uint32_t maxLen, uint64_t* outTensorCount, uint64_t* outTotalSize) {
    (void)manifoldId;
    if (outName && maxLen) outName[0] = 0;
    if (outTensorCount) *outTensorCount = 0;
    if (outTotalSize) *outTotalSize = 0;
    GateFiction("Win32IDE_GGUFManifold_GetManifoldInfo");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_GGUFManifold_UnloadManifold(uint32_t manifoldId) {
    (void)manifoldId;
    GateFiction("Win32IDE_GGUFManifold_UnloadManifold");
    return 0;
}
