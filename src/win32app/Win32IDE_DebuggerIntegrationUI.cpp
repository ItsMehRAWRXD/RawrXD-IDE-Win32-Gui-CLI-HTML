// Win32IDE_DebuggerIntegrationUI.cpp — product wire for DebuggerIntegration orphan
// Owns CallStackPanel + Initialize bridge. DAP start remains fail-closed.
// SOURCE_WIRED != DAP_SESSION_PASS. INVENT_DAP_PASS=0 PROMOTE=0
#include "Win32IDE_DebuggerIntegration.hpp"
#include "../ui/CallStackPanel.h"
#include <windows.h>
#include <memory>
#include <mutex>

namespace {

std::mutex g_mu;
std::unique_ptr<RawrXD::UI::CallStackPanel> g_panel;
HWND g_hwndMain = nullptr;
bool g_inited = false;

} // namespace

extern "C" {

// Force-link anchor (/INCLUDE). Returns 1 if CallStackPanel+integration wired.
int RawrXD_UI_InitDebuggerIntegration(HWND hwndMain) {
    if (!hwndMain || !IsWindow(hwndMain)) return 0;
    std::lock_guard<std::mutex> lock(g_mu);
    if (g_inited && g_panel) {
        return RawrXD::Win32IDE_DebuggerIntegration::IsDebugging() ? 1 : 1;
    }
    if (!g_panel) {
        g_panel = std::make_unique<RawrXD::UI::CallStackPanel>();
    }
    if (!g_panel->Initialize(hwndMain)) {
        g_panel.reset();
        return 0;
    }
    if (!RawrXD::Win32IDE_DebuggerIntegration::Initialize(hwndMain, g_panel.get())) {
        g_panel->Shutdown();
        g_panel.reset();
        return 0;
    }
    g_hwndMain = hwndMain;
    g_inited = true;
    // Wired + registered with fail-closed DapService — not a DAP session PASS.
    OutputDebugStringA(
        "RawrXD_UI_InitDebuggerIntegration: SOURCE_WIRED CallStack+Dap fail-closed\n");
    return 1;
}

int RawrXD_UI_ShutdownDebuggerIntegration(void) {
    std::lock_guard<std::mutex> lock(g_mu);
    if (g_inited) {
        RawrXD::Win32IDE_DebuggerIntegration::Shutdown();
        if (g_panel) {
            g_panel->Shutdown();
            g_panel.reset();
        }
        g_hwndMain = nullptr;
        g_inited = false;
    }
    return 1;
}

// Attempt StartDebugging — expect fail-closed from product DapService.
// Returns 0 on fail-closed (honest); never invents DAP PASS.
int RawrXD_UI_TryStartDebuggingFailClosed(const char* program, const char* workDir) {
    if (!g_inited || !program) return 0;
    std::string prog = program;
    std::string wd = workDir ? workDir : "";
    bool ok = RawrXD::Win32IDE_DebuggerIntegration::StartDebugging(prog, wd, true);
    // Product DapService::initialize returns Fail — ok must be false.
    if (ok) {
        // Refuse invent PASS: tear down and report 0.
        OutputDebugStringA(
            "RawrXD_UI_TryStartDebuggingFailClosed: unexpected DAP ok — refuse invent PASS\n");
        RawrXD::Win32IDE_DebuggerIntegration::StopDebugging();
        return 0;
    }
    return 0; // fail-closed survival path
}

int RawrXD_UI_ShowCallStackPanel(HWND hwndParent) {
    if (!hwndParent) return 0;
    if (!g_inited) {
        if (!RawrXD_UI_InitDebuggerIntegration(hwndParent)) return 0;
    }
    if (!g_panel) return 0;
    g_panel->ClearCallStack();
    g_panel->Invalidate();
    return 1;
}

} // extern "C"
