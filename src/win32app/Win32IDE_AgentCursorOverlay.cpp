// Win32IDE_AgentCursorOverlay.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_006:
// Prior: CreateOverlay invent visible=1 without HWND paint (fake-ready Production).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>
#include <cstdint>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[AgentCursorOverlay] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" __declspec(dllexport) int Win32IDE_AgentCursorOverlay_Init() {
    GateFiction("Win32IDE_AgentCursorOverlay_Init");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_AgentCursorOverlay_Shutdown() {
    GateFiction("Win32IDE_AgentCursorOverlay_Shutdown");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_AgentCursorOverlay_CreateOverlay(const char* label, uint32_t color, uint32_t* outOverlayId) {
    (void)label;
    (void)color;
    if (outOverlayId) *outOverlayId = 0;
    // Was: invent visible=1 + return 1 (no HWND/GDI overlay).
    GateFiction("Win32IDE_AgentCursorOverlay_CreateOverlay");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_AgentCursorOverlay_MoveOverlay(uint32_t overlayId, int32_t x, int32_t y) {
    (void)overlayId;
    (void)x;
    (void)y;
    GateFiction("Win32IDE_AgentCursorOverlay_MoveOverlay");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_AgentCursorOverlay_SetVisibility(uint32_t overlayId, uint32_t visible) {
    (void)overlayId;
    (void)visible;
    GateFiction("Win32IDE_AgentCursorOverlay_SetVisibility");
    return 0;
}

extern "C" __declspec(dllexport) int Win32IDE_AgentCursorOverlay_GetOverlayPos(uint32_t overlayId, int32_t* outX, int32_t* outY) {
    (void)overlayId;
    if (outX) *outX = 0;
    if (outY) *outY = 0;
    GateFiction("Win32IDE_AgentCursorOverlay_GetOverlayPos");
    return 0;
}
