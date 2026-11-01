// Win32IDE_ActionGraph.cpp - Production Implementation
// Provides action graph for Win32IDE
// ============================================================================
// AUDIT_002_OPENISH_OTHER_DRAIN_003:
// Prior: ExecuteAction "Simulate execution" invent ACTION_COMPLETED + resultCode=0.
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include <windows.h>
#include <cstdint>
#include <cstring>

#define MAX_ACTIONS     128
#define MAX_ACTION_NAME 64
#define MAX_DEPS        8

enum ActionStatus {
    ACTION_PENDING = 0,
    ACTION_RUNNING,
    ACTION_COMPLETED,
    ACTION_FAILED
};

struct ActionEntry {
    volatile LONG active;
    uint32_t actionId;
    char name[MAX_ACTION_NAME];
    ActionStatus status;
    uint32_t deps[MAX_DEPS];
    uint32_t depCount;
    uint64_t startTime;
    uint64_t endTime;
    uint32_t resultCode;
};

static volatile LONG g_initialized = 0;
static ActionEntry g_actions[MAX_ACTIONS];
static volatile LONG g_nextActionId = 1;

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[ActionGraph] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" __declspec(dllexport) int Win32IDE_ActionGraph_Init() {
    LONG was = InterlockedCompareExchange(&g_initialized, 1, 0);
    if (was != 0) return 1;
    InterlockedExchange(&g_nextActionId, 1);
    memset(g_actions, 0, sizeof(g_actions));
    return 1;
}

extern "C" __declspec(dllexport) int Win32IDE_ActionGraph_Shutdown() {
    InterlockedExchange(&g_initialized, 0);
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ActionGraph_CreateAction(const char* name, uint32_t* outActionId) {
    if (InterlockedCompareExchange(&g_initialized, 0, 0) == 0) return 0;
    if (!name || !outActionId) return 0;
    int slot = -1;
    for (int i = 0; i < MAX_ACTIONS; ++i) {
        if (InterlockedCompareExchange(&g_actions[i].active, 0, 0) == 0) { slot = i; break; }
    }
    if (slot < 0) return 0;
    ActionEntry* act = &g_actions[slot];
    act->actionId = InterlockedIncrement(&g_nextActionId);
    size_t len = strlen(name);
    if (len >= MAX_ACTION_NAME) len = MAX_ACTION_NAME - 1;
    memcpy(act->name, name, len);
    act->name[len] = 0;
    act->status = ACTION_PENDING;
    act->depCount = 0;
    act->startTime = 0;
    act->endTime = 0;
    act->resultCode = 0;
    InterlockedExchange(&act->active, 1);
    *outActionId = act->actionId;
    return 1;
}

extern "C" __declspec(dllexport) int Win32IDE_ActionGraph_AddDependency(uint32_t actionId, uint32_t depId) {
    if (InterlockedCompareExchange(&g_initialized, 0, 0) == 0) return 0;
    for (int i = 0; i < MAX_ACTIONS; ++i) {
        if (InterlockedCompareExchange(&g_actions[i].active, 0, 0) == 1 && g_actions[i].actionId == actionId) {
            if (g_actions[i].depCount < MAX_DEPS) {
                g_actions[i].deps[g_actions[i].depCount++] = depId;
                return 1;
            }
            return 0;
        }
    }
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ActionGraph_ExecuteAction(uint32_t actionId) {
    if (InterlockedCompareExchange(&g_initialized, 0, 0) == 0) return 0;
    for (int i = 0; i < MAX_ACTIONS; ++i) {
        if (InterlockedCompareExchange(&g_actions[i].active, 0, 0) == 1 && g_actions[i].actionId == actionId) {
            // Was: "Simulate execution" → invent ACTION_COMPLETED + resultCode=0.
            GateFiction("ExecuteAction");
            g_actions[i].status = ACTION_FAILED;
            g_actions[i].startTime = GetTickCount64();
            g_actions[i].endTime = g_actions[i].startTime;
            g_actions[i].resultCode = 1; // FEATURE_FICTION fail-closed
            return 0;
        }
    }
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_ActionGraph_GetActionStatus(uint32_t actionId, int* outStatus, uint32_t* outResultCode) {
    if (InterlockedCompareExchange(&g_initialized, 0, 0) == 0) return 0;
    for (int i = 0; i < MAX_ACTIONS; ++i) {
        if (InterlockedCompareExchange(&g_actions[i].active, 0, 0) == 1 && g_actions[i].actionId == actionId) {
            if (outStatus) *outStatus = static_cast<int>(g_actions[i].status);
            if (outResultCode) *outResultCode = g_actions[i].resultCode;
            return 1;
        }
    }
    return 0;
}
