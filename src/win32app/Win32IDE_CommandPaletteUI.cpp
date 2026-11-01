// Win32IDE_CommandPaletteUI.cpp — product wire for CommandPalette UI_PANEL orphan
// Force-link bridge. SOURCE_WIRED != palette E2E certified. PROMOTE=0
#include "Win32IDE_CommandPalette.hpp"
#include <windows.h>
#include <memory>
#include <mutex>

namespace {

std::mutex g_mu;
std::unique_ptr<Win32IDE::CommandPalette> g_palette;
bool g_inited = false;

} // namespace

extern "C" {

// /INCLUDE:RawrXD_UI_InitCommandPalette
int RawrXD_UI_InitCommandPalette(HWND hwndParent) {
    if (!hwndParent || !IsWindow(hwndParent)) return 0;
    std::lock_guard<std::mutex> lock(g_mu);
    if (g_inited && g_palette) return 1;
    auto p = std::make_unique<Win32IDE::CommandPalette>();
    HINSTANCE hi = (HINSTANCE)GetWindowLongPtrW(hwndParent, GWLP_HINSTANCE);
    if (!hi) hi = GetModuleHandleW(nullptr);
    if (!p->Initialize(hi, hwndParent)) return 0;
    g_palette = std::move(p);
    g_inited = true;
    OutputDebugStringA("RawrXD_UI_InitCommandPalette: SOURCE_WIRED CommandPalette\n");
    return 1;
}

int RawrXD_UI_ShutdownCommandPalette(void) {
    std::lock_guard<std::mutex> lock(g_mu);
    if (g_palette) {
        g_palette->Shutdown();
        g_palette.reset();
    }
    g_inited = false;
    return 1;
}

int RawrXD_UI_ShowCommandPalette(HWND hwndParent) {
    if (!hwndParent) return 0;
    if (!g_inited) {
        if (!RawrXD_UI_InitCommandPalette(hwndParent)) return 0;
    }
    if (!g_palette) return 0;
    g_palette->ShowCommands();
    return 1;
}

int RawrXD_UI_ShowQuickOpen(HWND hwndParent) {
    if (!hwndParent) return 0;
    if (!g_inited) {
        if (!RawrXD_UI_InitCommandPalette(hwndParent)) return 0;
    }
    if (!g_palette) return 0;
    g_palette->ShowFiles();
    return 1;
}

} // extern "C"
