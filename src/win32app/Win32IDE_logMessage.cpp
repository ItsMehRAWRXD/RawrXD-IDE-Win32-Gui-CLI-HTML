// =============================================================================
// Win32IDE_logMessage.cpp — Build variant: LogMessage fallback for targets that link
// Win32IDE panel code but not the full GUI (e.g. RawrEngine).
//
// AUDIT_002_OPENISH_OTHER_DRAIN_019:
// Prior: fallback logger invent ide.log / LogMessage ready PASS without
// validated tip product wire (fake-ready / empty-true sibling of
// RawrXD_Win32IDELogMessageStubAnchor DRAIN_016).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// =============================================================================
#include "Win32IDE.h"
#include <windows.h>
#include <shlobj.h>
#include <fstream>
#include <string>
#include <mutex>
#include <chrono>
#include <iomanip>
#include <sstream>
#include <filesystem>

namespace {
    std::mutex s_logMutex;
    std::string s_logPath;
    bool s_logPathResolved = false;

    std::string getLogPath() {
        if (s_logPathResolved) return s_logPath;
        std::lock_guard<std::mutex> lock(s_logMutex);
        if (s_logPathResolved) return s_logPath;
        char appdata[MAX_PATH];
        if (SUCCEEDED(SHGetFolderPathA(nullptr, CSIDL_APPDATA, nullptr, 0, appdata))) {
            s_logPath = std::string(appdata) + "\\RawrXD\\ide.log";
            s_logPathResolved = true;
        }
        return s_logPath;
    }
}

void Win32IDE::logMessage(const std::string& category, const std::string& message) {
    // Was: invent fallback LogMessage / ide.log ready PASS.
    (void)category;
    (void)message;
    OutputDebugStringA(
        "[logMessage] FEATURE_FICTION=1 FAIL_CLOSED logMessage "
        "(no invent fallback logger ready PASS)\n");
    (void)getLogPath;
}
