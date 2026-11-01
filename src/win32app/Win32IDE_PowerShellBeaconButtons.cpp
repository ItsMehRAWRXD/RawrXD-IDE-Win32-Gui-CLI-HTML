// ============================================================================
// Win32IDE_PowerShellBeaconButtons.cpp — Phase 16: UI Beacon Triggers
// ============================================================================
// AUDIT_002_OPENISH_OTHER_DRAIN_011:
// Prior: BeaconButton_* invent stage success via PowerShell Write-Host theater
// without validated MASM/beacon/mesh wire; BeaconUI_CreateButtons invent
// success=true + "Ready" (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include "BATCH2_CONTEXT.h"
#include <windows.h>
#include <cstdio>
#include <cstring>

namespace {
void GateFiction(const char* name) {
    char buf[256];
    wsprintfA(buf, "[PowerShellBeaconButtons] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

void BeaconButton_Init(HWND hwnd) {
    (void)hwnd;
    GateFiction("BeaconButton_Init");
}
void BeaconButton_LoadMASM(HWND hwnd) {
    (void)hwnd;
    GateFiction("BeaconButton_LoadMASM");
}
void BeaconButton_Hotpatch(HWND hwnd) {
    (void)hwnd;
    GateFiction("BeaconButton_Hotpatch");
}
void BeaconButton_MemoryMap(HWND hwnd) {
    (void)hwnd;
    GateFiction("BeaconButton_MemoryMap");
}
void BeaconButton_WindowCreate(HWND hwnd) {
    (void)hwnd;
    GateFiction("BeaconButton_WindowCreate");
}
void BeaconButton_SidebarInit(HWND hwnd) {
    (void)hwnd;
    GateFiction("BeaconButton_SidebarInit");
}
void BeaconButton_BeaconSync(HWND hwnd) {
    (void)hwnd;
    GateFiction("BeaconButton_BeaconSync");
}
void BeaconButton_CommandWire(HWND hwnd) {
    (void)hwnd;
    GateFiction("BeaconButton_CommandWire");
}
void BeaconButton_UIRender(HWND hwnd) {
    (void)hwnd;
    GateFiction("BeaconButton_UIRender");
}
void BeaconButton_FinalHandshake(HWND hwnd) {
    (void)hwnd;
    GateFiction("BeaconButton_FinalHandshake");
}
void BeaconButton_Complete(HWND hwnd) {
    (void)hwnd;
    GateFiction("BeaconButton_Complete");
}
void BeaconButton_ErrorRecovery(HWND hwnd) {
    (void)hwnd;
    GateFiction("BeaconButton_ErrorRecovery");
}

extern "C" __declspec(dllexport) CommandResult BeaconUI_CreateButtons(HWND hwndParent) {
    (void)hwndParent;
    // Was: invent progress/status/buttons + success=true "Ready" without beacon wire.
    GateFiction("BeaconUI_CreateButtons");
    CommandResult result = { false, "", 0 };
    strcpy_s(result.message, "FEATURE_FICTION=1 FAIL_CLOSED (no invent beacon UI ready PASS)");
    result.success = false;
    return result;
}

extern "C" __declspec(dllexport) void BeaconUI_HandleButtonClick(int buttonId) {
    (void)buttonId;
    GateFiction("BeaconUI_HandleButtonClick");
}

extern "C" __declspec(dllexport) void BeaconUI_DestroyButtons() {
    GateFiction("BeaconUI_DestroyButtons");
}

#pragma comment(linker, "/EXPORT:BeaconUI_CreateButtons")
#pragma comment(linker, "/EXPORT:BeaconUI_HandleButtonClick")
#pragma comment(linker, "/EXPORT:BeaconUI_DestroyButtons")
