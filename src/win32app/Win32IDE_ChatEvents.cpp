#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>
#include <string>

/**
 * @file Win32IDE_ChatEvents.cpp
 * @brief Batch 2 (10/118): Chat UI to Agent Event Handlers.
 * Manages message delivery from the human to the Hermes bridge.
 *
 * AUDIT_002_OPENISH_OTHER_DRAIN_003:
 * Prior: Chat_OnSendMessage LOG-only return true (empty-true; no Hermes persist).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

namespace RawrXD::UI::Chat {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[ChatEvents] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

// Resolves: Chat_OnSendMessage
extern "C" bool Chat_OnSendMessage(const char* message_json) {
    (void)message_json;
    // Was: LOG + invent true (Hermes link claimed, not wired).
    GateFiction("Chat_OnSendMessage");
    return false;
}

// Resolves: Chat_OnSelectionChange
extern "C" void Chat_OnSelectionChange(int start, int end) {
    (void)start; (void)end;
    GateFiction("Chat_OnSelectionChange");
}

} // namespace RawrXD::UI::Chat
