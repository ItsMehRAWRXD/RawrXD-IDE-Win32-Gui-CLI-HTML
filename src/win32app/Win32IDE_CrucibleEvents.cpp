#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>

/**
 * @file Win32IDE_CrucibleEvents.cpp
 * @brief Batch 2 (9/118): Crucible Panel to Agent Event Handlers.
 *
 * AUDIT_002_OPENISH_OTHER_DRAIN_008:
 * Prior: Crucible_OnRequestInference / OnCancelInference LOG+Post invent Cortex wire (empty-true).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

namespace RawrXD::UI::Crucible {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[Crucible] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" void Crucible_OnRequestInference(const char* prompt, int priority) {
    (void)prompt;
    (void)priority;
    GateFiction("Crucible_OnRequestInference");
}

extern "C" void Crucible_OnCancelInference(const char* request_id) {
    (void)request_id;
    GateFiction("Crucible_OnCancelInference");
}

} // namespace RawrXD::UI::Crucible
