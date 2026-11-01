// Win32IDE_WiringHandlers.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_005:
// Prior: TriggerHandler invent success + return 1 without dispatch (empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>
#include <cstdint>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[WiringHandlers] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" __declspec(dllexport) int Win32IDE_WiringHandlers_Init() {
    GateFiction("Win32IDE_WiringHandlers_Init");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_WiringHandlers_Shutdown() {
    GateFiction("Win32IDE_WiringHandlers_Shutdown");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_WiringHandlers_RegisterHandler(const char* name, int type, uint32_t* outHandlerId) {
    (void)name;
    (void)type;
    if (outHandlerId) *outHandlerId = 0;
    GateFiction("Win32IDE_WiringHandlers_RegisterHandler");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_WiringHandlers_EnableHandler(uint32_t handlerId, uint32_t enabled) {
    (void)handlerId;
    (void)enabled;
    GateFiction("Win32IDE_WiringHandlers_EnableHandler");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_WiringHandlers_TriggerHandler(uint32_t handlerId) {
    (void)handlerId;
    // Was: invent triggerCount++ + return 1 (no real handler dispatch).
    GateFiction("Win32IDE_WiringHandlers_TriggerHandler");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_WiringHandlers_GetHandlerInfo(uint32_t handlerId, char* outName, uint32_t maxLen, int* outType, uint32_t* outEnabled, uint64_t* outTriggerCount) {
    (void)handlerId;
    if (outName && maxLen) outName[0] = 0;
    if (outType) *outType = 0;
    if (outEnabled) *outEnabled = 0;
    if (outTriggerCount) *outTriggerCount = 0;
    GateFiction("Win32IDE_WiringHandlers_GetHandlerInfo");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_WiringHandlers_GetEnabledCount() {
    GateFiction("Win32IDE_WiringHandlers_GetEnabledCount");
    return 0;
}
