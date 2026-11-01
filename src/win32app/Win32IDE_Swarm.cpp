// Win32IDE_Swarm.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_005:
// Prior: RegisterNode invent NODE_ONLINE + return 1 without real swarm (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>
#include <cstdint>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[Swarm] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" __declspec(dllexport) int Win32IDE_Swarm_Init() {
    GateFiction("Win32IDE_Swarm_Init");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_Swarm_Shutdown() {
    GateFiction("Win32IDE_Swarm_Shutdown");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_Swarm_RegisterNode(const char* name, uint32_t capacity, uint32_t* outNodeId) {
    (void)name;
    (void)capacity;
    if (outNodeId) *outNodeId = 0;
    // Was: invent NODE_ONLINE + return 1 (no mesh join).
    GateFiction("Win32IDE_Swarm_RegisterNode");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_Swarm_UpdateNodeState(uint32_t nodeId, int state) {
    (void)nodeId;
    (void)state;
    GateFiction("Win32IDE_Swarm_UpdateNodeState");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_Swarm_UpdateNodeLoad(uint32_t nodeId, uint32_t load) {
    (void)nodeId;
    (void)load;
    GateFiction("Win32IDE_Swarm_UpdateNodeLoad");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_Swarm_GetNodeInfo(uint32_t nodeId, char* outName, uint32_t maxLen, int* outState, uint32_t* outCapacity, uint32_t* outLoad) {
    (void)nodeId;
    if (outName && maxLen) outName[0] = 0;
    if (outState) *outState = 0;
    if (outCapacity) *outCapacity = 0;
    if (outLoad) *outLoad = 0;
    GateFiction("Win32IDE_Swarm_GetNodeInfo");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_Swarm_GetOnlineCount() {
    GateFiction("Win32IDE_Swarm_GetOnlineCount");
    return 0;
}
