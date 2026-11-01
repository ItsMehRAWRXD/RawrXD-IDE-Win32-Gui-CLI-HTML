#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>
#include <string>

/**
 * @file Win32IDE_FileSystemEvents.cpp
 * @brief Batch 2 (15/118): File Explorer UI to Agent Event Handlers.
 * Routes file/folder structural changes to the autonomous agentic context.
 *
 * AUDIT_002_OPENISH_OTHER_DRAIN_003:
 * Prior: Explorer_OnFileOpened LOG-only return true (empty-true; no Nous inject).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

namespace RawrXD::UI::FileSystem {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[FileSystemEvents] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

// Resolves: Explorer_OnFileOpened
extern "C" bool Explorer_OnFileOpened(const char* path) {
    (void)path;
    // Was: LOG + invent true (no Nous goal-context inject).
    GateFiction("Explorer_OnFileOpened");
    return false;
}

// Resolves: Explorer_OnFolderScanRequested
extern "C" void Explorer_OnFolderScanRequested(const char* root) {
    (void)root;
    GateFiction("Explorer_OnFolderScanRequested");
}

} // namespace RawrXD::UI::FileSystem
