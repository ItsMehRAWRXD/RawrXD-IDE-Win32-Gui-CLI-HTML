// AUDIT_002_OPENISH_OTHER_DRAIN_018:
// Prior: V280 ghost/link TU invent ghost-active / UI-hook ready PASS without
// validated tip product wire (fake-ready / empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include <cstdint>
#include <cstring>
#include <atomic>
#include <windows.h>
#include "../core/ssot_handlers.h"

namespace {
struct V280LinkFailClosed {
    V280LinkFailClosed() {
        // Was: invent V280 ghost/link ready PASS (orphan ghost-text TU).
        OutputDebugStringA(
            "[v280_link_impl] FEATURE_FICTION=1 FAIL_CLOSED TU "
            "(no invent V280 ghost/link ready PASS)\n");
    }
};
static V280LinkFailClosed g_v280LinkFailClosed;

bool g_v280GhostActive = false;
char g_v280GhostText[1024] = {};
std::atomic<uint32_t> g_v280QuadbufShutdownCount{0};
std::atomic<uint32_t> g_v280SpengineShutdownCount{0};
} // namespace

extern "C" int64_t V280_UI_WndProc_Hook(void* hwnd, uint32_t uMsg, uint64_t wParam, int64_t lParam) {
    (void)hwnd;
    (void)wParam;
    if (!isBeaconFullActive()) {
        return 0;
    }
    if (uMsg == WM_SETTEXT && lParam != 0) {
        const char* text = reinterpret_cast<const char*>(lParam);
        std::strncpy(g_v280GhostText, text, sizeof(g_v280GhostText) - 1);
        g_v280GhostText[sizeof(g_v280GhostText) - 1] = '\0';
        g_v280GhostActive = g_v280GhostText[0] != '\0';
    } else if (uMsg == WM_KILLFOCUS || uMsg == WM_DESTROY) {
        g_v280GhostText[0] = '\0';
        g_v280GhostActive = false;
    }
    return 0;
}

extern "C" int V280_UI_IsGhostActive(void) {
    return g_v280GhostActive ? 1 : 0;
}

extern "C" int V280_UI_GetGhostText(char* buf, int buf_size) {
    if (buf == nullptr || buf_size <= 0) {
        return 0;
    }
    std::strncpy(buf, g_v280GhostText, static_cast<size_t>(buf_size) - 1U);
    buf[buf_size - 1] = '\0';
    return static_cast<int>(std::strlen(buf));
}

extern "C" void asm_quadbuf_shutdown(void) {
    g_v280GhostText[0] = '\0';
    g_v280GhostActive = false;
    g_v280QuadbufShutdownCount.fetch_add(1, std::memory_order_relaxed);
}

extern "C" void asm_spengine_shutdown(void) {
    g_v280SpengineShutdownCount.fetch_add(1, std::memory_order_relaxed);
}
