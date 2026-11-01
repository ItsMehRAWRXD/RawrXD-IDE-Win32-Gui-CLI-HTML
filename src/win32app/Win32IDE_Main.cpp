// Win32IDE_Main.cpp — LEGACY ENTRY POINT (NOT INCLUDED IN BUILD)
//
// DO NOT add this file to CMakeLists.txt / WIN32IDE_SOURCES.
// The canonical WinMain is src/win32app/main_win32.cpp (line 1557).
// This file is kept as a reference/diagnostic minimal entry point only.
// H-1: Guard prevents accidental double-WinMain link errors.
#if defined(RAWRXD_BUILD_LEGACY_MAIN)
#include "Win32IDE.h"
#include "../modules/vsix_loader.h"
#include "../modules/memory_manager.h"
#include "../modules/engine_manager.h"
#include "../modules/codex_ultimate.h"
#include "../diagnostics/self_diagnose.hpp"
#include "../diagnostics/pattern_scan.hpp"
#include <commctrl.h>

// AUDIT_002_OPENISH_OTHER_DRAIN_015:
// Prior: legacy WinMain invent VSIX/agentic/EngineManager/Codex ready theater
// as product entry PASS without tip product wire (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR, int nCmdShow) {
    (void)hInstance;
    (void)nCmdShow;
    // Was: invent VSIXLoader/agentic/EngineManager/Codex ready PASS.
    OutputDebugStringA(
        "[Win32IDE_Main] FEATURE_FICTION=1 FAIL_CLOSED legacy WinMain "
        "(no invent legacy-entry ready PASS)\n");
    MessageBoxW(nullptr,
                L"FEATURE_FICTION=1 FAIL_CLOSED — legacy WinMain invent ready held",
                L"RawrXD", MB_OK | MB_ICONWARNING);
    return 1;
}
