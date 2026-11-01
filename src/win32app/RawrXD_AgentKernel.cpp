// RawrXD_AgentKernel.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_006:
// Prior: StartAgent invent AGENT_RUNNING without real agent (fake-ready Production).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>
#include <cstdint>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[AgentKernel] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" __declspec(dllexport) int RawrXD_AgentKernel_Init() {
    GateFiction("RawrXD_AgentKernel_Init");
    return 0;
}

extern "C" __declspec(dllexport) int RawrXD_AgentKernel_Shutdown() {
    GateFiction("RawrXD_AgentKernel_Shutdown");
    return 0;
}

extern "C" __declspec(dllexport) int RawrXD_AgentKernel_CreateAgent(const char* name, uint32_t* outAgentId) {
    (void)name;
    if (outAgentId) *outAgentId = 0;
    GateFiction("RawrXD_AgentKernel_CreateAgent");
    return 0;
}

extern "C" __declspec(dllexport) int RawrXD_AgentKernel_StartAgent(uint32_t agentId) {
    (void)agentId;
    // Was: invent AGENT_RUNNING + return 1 (no real agent thread/work).
    GateFiction("RawrXD_AgentKernel_StartAgent");
    return 0;
}

extern "C" __declspec(dllexport) int RawrXD_AgentKernel_StopAgent(uint32_t agentId) {
    (void)agentId;
    GateFiction("RawrXD_AgentKernel_StopAgent");
    return 0;
}

extern "C" __declspec(dllexport) int RawrXD_AgentKernel_GetAgentState(uint32_t agentId, int* outState, uint32_t* outTaskCount, uint32_t* outCompleted) {
    (void)agentId;
    if (outState) *outState = 0;
    if (outTaskCount) *outTaskCount = 0;
    if (outCompleted) *outCompleted = 0;
    GateFiction("RawrXD_AgentKernel_GetAgentState");
    return 0;
}

extern "C" __declspec(dllexport) int RawrXD_AgentKernel_GetActiveAgentCount() {
    GateFiction("RawrXD_AgentKernel_GetActiveAgentCount");
    return 0;
}
