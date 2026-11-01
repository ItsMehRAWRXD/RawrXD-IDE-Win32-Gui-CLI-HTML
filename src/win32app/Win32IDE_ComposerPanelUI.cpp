// Win32IDE_ComposerPanelUI.cpp — product wire for ComposerPanel UI_PANEL orphan
// Force-link bridge. SOURCE_WIRED != composer E2E certified. PROMOTE=0 INVENT_COMPOSER_PASS=0
#include <windows.h>

extern "C" HWND ComposerPanel_Create(HWND hwndParent, HINSTANCE hInstance);
extern "C" void ComposerPanel_ShowPlan(void);
extern "C" void ComposerPanel_HidePlan(void);
extern "C" void ComposerPanel_Destroy(void);
extern "C" bool ComposerPanel_IsVisible(void);

namespace {

HWND g_panel = nullptr;
bool g_inited = false;

} // namespace

extern "C" {

// Fail-closed: no swarm opinion → Composer local heuristic. ≠ invent APPROVE/REJECT.
int RawrXD_Composer_SwarmReview(const char* taskUtf8, char* outBuf, int outCap) {
    (void)taskUtf8;
    if (outBuf && outCap > 0) outBuf[0] = '\0';
    OutputDebugStringA("RawrXD_Composer_SwarmReview: FAIL_CLOSED no-opinion\n");
    return 0;
}

// /INCLUDE:RawrXD_UI_InitComposerPanel
int RawrXD_UI_InitComposerPanel(HWND hwndParent) {
    if (!hwndParent || !IsWindow(hwndParent)) return 0;
    if (g_inited && g_panel && IsWindow(g_panel)) return 1;
    HINSTANCE hi = (HINSTANCE)GetWindowLongPtrW(hwndParent, GWLP_HINSTANCE);
    if (!hi) hi = GetModuleHandleW(nullptr);
    g_panel = ComposerPanel_Create(hwndParent, hi);
    if (!g_panel) return 0;
    g_inited = true;
    OutputDebugStringA("RawrXD_UI_InitComposerPanel: SOURCE_WIRED ComposerPanel\n");
    return 1;
}

int RawrXD_UI_ShutdownComposerPanel(void) {
    if (g_inited) {
        ComposerPanel_Destroy();
        g_panel = nullptr;
        g_inited = false;
    }
    return 1;
}

int RawrXD_UI_ShowComposerPanel(HWND hwndParent) {
    if (!hwndParent) return 0;
    if (!g_inited) {
        if (!RawrXD_UI_InitComposerPanel(hwndParent)) return 0;
    }
    ComposerPanel_ShowPlan();
    return 1;
}

int RawrXD_UI_HideComposerPanel(void) {
    if (!g_inited) return 0;
    ComposerPanel_HidePlan();
    return 1;
}

} // extern "C"
