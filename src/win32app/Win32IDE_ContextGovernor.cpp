// Win32IDE_ContextGovernor.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_006:
// Prior: Create/Activate invent active_flag=1 theater (fake-ready Production).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>
#include <cstdint>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[ContextGovernor] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" __declspec(dllexport) int Win32IDE_ContextGovernor_Init() {
    GateFiction("Win32IDE_ContextGovernor_Init");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ContextGovernor_Shutdown() {
    GateFiction("Win32IDE_ContextGovernor_Shutdown");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ContextGovernor_CreateContext(const char* name, uint32_t priority, uint32_t* outCtxId) {
    (void)name;
    (void)priority;
    if (outCtxId) *outCtxId = 0;
    // Was: invent active_flag=1 + return 1 (no real context bind).
    GateFiction("Win32IDE_ContextGovernor_CreateContext");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ContextGovernor_ActivateContext(uint32_t ctxId) {
    (void)ctxId;
    GateFiction("Win32IDE_ContextGovernor_ActivateContext");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ContextGovernor_DeactivateContext(uint32_t ctxId) {
    (void)ctxId;
    GateFiction("Win32IDE_ContextGovernor_DeactivateContext");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ContextGovernor_AddRef(uint32_t ctxId) {
    (void)ctxId;
    GateFiction("Win32IDE_ContextGovernor_AddRef");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ContextGovernor_Release(uint32_t ctxId) {
    (void)ctxId;
    GateFiction("Win32IDE_ContextGovernor_Release");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ContextGovernor_GetActiveCount() {
    GateFiction("Win32IDE_ContextGovernor_GetActiveCount");
    return 0;
}
