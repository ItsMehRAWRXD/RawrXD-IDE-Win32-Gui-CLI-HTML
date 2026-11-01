#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>
#include <string>

/**
 * @file Win32IDE_TaskEvents.cpp
 * @brief Batch 2 (16/118): Task/Queue UI to Agent Event Handlers.
 * Routes UI task list modifications to the agentic scheduler bridge.
 *
 * AUDIT_002_OPENISH_OTHER_DRAIN_003:
 * Prior: Tasks_OnTaskRequested LOG-only return true (empty-true; no Synthesizer/Nous).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

namespace RawrXD::UI::Tasks {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[TaskEvents] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

// Resolves: Tasks_OnTaskRequested
extern "C" bool Tasks_OnTaskRequested(const char* task_id, const char* content) {
    (void)task_id; (void)content;
    // Was: LOG + invent true (no planner execute).
    GateFiction("Tasks_OnTaskRequested");
    return false;
}

// Resolves: Tasks_OnComplete
extern "C" void Tasks_OnComplete(const char* task_id) {
    (void)task_id;
    GateFiction("Tasks_OnComplete");
}

} // namespace RawrXD::UI::Tasks
