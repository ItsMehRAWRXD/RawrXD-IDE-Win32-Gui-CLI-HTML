// Win32IDE_TBA_LinkGraph.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_006:
// Prior: CreateLink invent active_flag=1 in-memory theater (fake-ready Production).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>
#include <cstdint>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[TBA_LinkGraph] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" __declspec(dllexport) int Win32IDE_TBA_LinkGraph_Init() {
    GateFiction("Win32IDE_TBA_LinkGraph_Init");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_TBA_LinkGraph_Shutdown() {
    GateFiction("Win32IDE_TBA_LinkGraph_Shutdown");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_TBA_LinkGraph_CreateLink(const char* name, uint32_t sourceId, uint32_t weight, uint32_t* outLinkId) {
    (void)name;
    (void)sourceId;
    (void)weight;
    if (outLinkId) *outLinkId = 0;
    // Was: invent active_flag=1 + return 1 (no real TBA graph).
    GateFiction("Win32IDE_TBA_LinkGraph_CreateLink");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_TBA_LinkGraph_AddTarget(uint32_t linkId, uint32_t targetId) {
    (void)linkId;
    (void)targetId;
    GateFiction("Win32IDE_TBA_LinkGraph_AddTarget");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_TBA_LinkGraph_GetLinkInfo(uint32_t linkId, char* outName, uint32_t maxLen, uint32_t* outSourceId, uint32_t* outWeight, uint32_t* outTargetCount) {
    (void)linkId;
    if (outName && maxLen) outName[0] = 0;
    if (outSourceId) *outSourceId = 0;
    if (outWeight) *outWeight = 0;
    if (outTargetCount) *outTargetCount = 0;
    GateFiction("Win32IDE_TBA_LinkGraph_GetLinkInfo");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_TBA_LinkGraph_SetActive(uint32_t linkId, uint32_t active) {
    (void)linkId;
    (void)active;
    GateFiction("Win32IDE_TBA_LinkGraph_SetActive");
    return 0;
}
