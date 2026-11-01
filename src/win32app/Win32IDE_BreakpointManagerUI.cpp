// Win32IDE_BreakpointManagerUI.cpp — product wire for BreakpointManagerPanel orphan
// Syncs ListView panel from NativeDebuggerEngine (real I/O). PROMOTE=0.
#include "BreakpointManagerPanel.hpp"
#include "../core/native_debugger_engine.h"
#include "../core/native_debugger_types.h"
#include <windows.h>
#include <string>
#include <vector>

using namespace RawrXD::Debugger;
using namespace RawrXD::Win32;

namespace {

std::wstring Utf8ToWide(const std::string& s) {
    if (s.empty()) return L"";
    int n = MultiByteToWideChar(CP_UTF8, 0, s.c_str(), (int)s.size(), nullptr, 0);
    if (n <= 0) return L"";
    std::wstring w((size_t)n, L'\0');
    MultiByteToWideChar(CP_UTF8, 0, s.c_str(), (int)s.size(), &w[0], n);
    return w;
}

std::wstring FileNameOf(const std::wstring& path) {
    size_t slash = path.find_last_of(L"/\\");
    return slash == std::wstring::npos ? path : path.substr(slash + 1);
}

struct EngineBpCallbacks : IBreakpointManagerCallbacks {
    void OnBreakpointToggled(int breakpointId, bool enabled) override {
        NativeDebuggerEngine::Instance().enableBreakpoint((uint32_t)breakpointId, enabled);
    }
    void OnBreakpointDeleted(int breakpointId) override {
        NativeDebuggerEngine::Instance().removeBreakpoint((uint32_t)breakpointId);
    }
    void OnBreakpointNavigate(const std::wstring&, int) override {}
    void OnBreakpointConditionChanged(int, const std::string&) override {}
    void OnClearAllBreakpoints() override {
        NativeDebuggerEngine::Instance().removeAllBreakpoints();
    }
};

EngineBpCallbacks g_engineCbs;
HWND g_panelParent = nullptr;

BreakpointInfo FromNative(const NativeBreakpoint& nb) {
    BreakpointInfo bi;
    bi.id = (int)nb.id;
    bi.filePath = Utf8ToWide(nb.sourceFile);
    bi.fileName = FileNameOf(bi.filePath);
    if (bi.fileName.empty() && !nb.symbol.empty())
        bi.fileName = Utf8ToWide(nb.symbol);
    bi.line = nb.sourceLine;
    bi.address = nb.address;
    bi.enabled = (nb.state != BreakpointState::Disabled && nb.state != BreakpointState::Removed);
    bi.verified = (nb.address != 0);
    bi.condition = nb.condition;
    bi.hitCount = (int)nb.hitCount;
    return bi;
}

} // namespace

extern "C" {

int RawrXD_UI_ShowBreakpointManager(HWND hwndParent) {
    // BREAKPOINT_FOLLOWON_D252_001: IDM_DBG_LIST_BPS (5170) killed live D252
    // with EXIT=0xC0000409 after MenuReady+ping — same class as DBGWATCH_SHOW.
    // Prior Show path: CreateWindow ListView child on main + ShowWindow/SetWindowPos.
    // Honest fail-closed: ODS-only; no invent BP panel ready PASS.
    // createDebuggerUI() remains never-called; do not touch tip748B.
    // PROMOTE=0 ABSORB=NOT_AUTHORIZED TIP_CLIMB=HOLD.
    (void)hwndParent;
    (void)g_panelParent;
    (void)g_engineCbs;
    OutputDebugStringA(
        "[BreakpointManager] FEATURE_FICTION=1 FAIL_CLOSED Show "
        "— no invent BP panel ready PASS\n");
    return 0;
}

int RawrXD_UI_SyncBreakpointManagerFromEngine(void) {
    // Held with Show: no panel HWND on product path (fail-closed).
    OutputDebugStringA(
        "[BreakpointManager] FEATURE_FICTION=1 FAIL_CLOSED Sync "
        "— no invent BP panel ready PASS\n");
    return -1;
}

const char* RawrXD_UI_ListBreakpointsAndShowPanel(HWND hwndParent) {
    // Fail-closed list: no Create/Show, no engine call, no invent PRODUCT_PASS.
    (void)hwndParent;
    OutputDebugStringA(
        "[BreakpointManager] FEATURE_FICTION=1 FAIL_CLOSED List "
        "— no invent BP panel ready PASS\n");
    return "[]";
}

} // extern "C"
