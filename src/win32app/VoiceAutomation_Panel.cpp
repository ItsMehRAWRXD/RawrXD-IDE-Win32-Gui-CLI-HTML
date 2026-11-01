// ============================================================================
// VoiceAutomation_Panel.cpp - Implementation of Voice Automation UI
// ============================================================================
// Provides TTS (Text-to-Speech) panel and voice automation controls for the
// RawrXD IDE. Phase 44 feature implementation.
//
// History:
//   2026-08-26  Created as part of Batch 1 unresolved external resolution.
//
// AUDIT_002_OPENISH_UI_PANEL_DRAIN_001:
// Prior: invent CreateVoiceAutomationPanel + Enable TTS "Voice: Ready" PASS (no TTS I/O).
// Now: FEATURE_FICTION=1 FAIL_CLOSED - no invent voice-automation ready PASS.
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>
#include <commctrl.h>
#include <string>
#include <atomic>

// ---------------------------------------------------------------------------
// Internal state
// ---------------------------------------------------------------------------
static HWND g_hwndVoicePanel = nullptr;
static HWND g_hwndVoiceSlider = nullptr;
static HWND g_hwndVoiceStatus = nullptr;
static std::atomic_bool g_voiceAutomationEnabled{false};
static int g_voiceVolume = 80;  // 0-100

// ---------------------------------------------------------------------------
// Voice Automation Panel Window Procedure
// ---------------------------------------------------------------------------
static LRESULT CALLBACK VoiceAutomationPanelProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    switch (msg)
    {
        case WM_CREATE:
        {
            // Create volume slider
            g_hwndVoiceSlider = CreateWindowExW(0, TRACKBAR_CLASSW, nullptr,
                                                WS_CHILD | WS_VISIBLE | TBS_HORZ | TBS_AUTOTICKS,
                                                10, 30, 200, 30, hwnd, (HMENU)1, nullptr, nullptr);
            SendMessage(g_hwndVoiceSlider, TBM_SETRANGE, TRUE, MAKELPARAM(0, 100));
            SendMessage(g_hwndVoiceSlider, TBM_SETPOS, TRUE, g_voiceVolume);
            
            // Create status label
            g_hwndVoiceStatus = CreateWindowExW(0, L"STATIC", L"Voice: Ready",
                                               WS_CHILD | WS_VISIBLE | SS_LEFT,
                                               10, 65, 200, 20, hwnd, nullptr, nullptr, nullptr);
            return 0;
        }
        
        case WM_COMMAND:
            if (LOWORD(wParam) == 2)  // Enable/disable toggle
            {
                g_voiceAutomationEnabled.store(!g_voiceAutomationEnabled.load(std::memory_order_acquire),
                                               std::memory_order_release);
            }
            return 0;
            
        case WM_HSCROLL:
            if ((HWND)lParam == g_hwndVoiceSlider)
            {
                g_voiceVolume = (int)SendMessage(g_hwndVoiceSlider, TBM_GETPOS, 0, 0);
            }
            return 0;
            
        case WM_DESTROY:
            g_hwndVoicePanel = nullptr;
            g_hwndVoiceSlider = nullptr;
            g_hwndVoiceStatus = nullptr;
            return 0;
    }
    
    return DefWindowProcW(hwnd, msg, wParam, lParam);
}

// ---------------------------------------------------------------------------
// Exported functions (used by Win32IDE_Core.cpp)
// ---------------------------------------------------------------------------

extern void Win32IDE_CreateVoiceAutomationPanel(HWND parent, int x, int y, int width, int height)
{
    (void)parent; (void)x; (void)y; (void)width; (void)height;
    // Was: CreateWindow + "Voice: Ready" invent TTS panel ready PASS (no TTS engine).
    OutputDebugStringA(
        "[VoiceAutomation] FEATURE_FICTION=1 FAIL_CLOSED CreateVoiceAutomationPanel "
        "— no invent TTS panel ready PASS\n");
    g_voiceAutomationEnabled.store(false, std::memory_order_release);
    g_hwndVoicePanel = nullptr;
}

extern void Win32IDE_DestroyVoiceAutomationPanel()
{
    if (g_hwndVoicePanel && IsWindow(g_hwndVoicePanel))
    {
        DestroyWindow(g_hwndVoicePanel);
    }
    g_hwndVoicePanel = nullptr;
}

extern void Win32IDE_VoiceAutomationTimerTick()
{
    // Periodic timer tick for voice automation status updates
    if (g_hwndVoiceStatus && IsWindow(g_hwndVoiceStatus))
    {
        bool enabled = g_voiceAutomationEnabled.load(std::memory_order_acquire);
        SetWindowTextW(g_hwndVoiceStatus, enabled ? L"Voice: Active" : L"Voice: Ready");
    }
}

extern bool Win32IDE_HandleVoiceAutomationScroll(HWND hwnd, LPARAM lParam)
{
    if (!g_hwndVoiceSlider)
        return false;
    
    HWND hwndSlider = (HWND)lParam;
    if (hwndSlider == g_hwndVoiceSlider)
    {
        g_voiceVolume = (int)SendMessage(g_hwndVoiceSlider, TBM_GETPOS, 0, 0);
        return true;
    }
    
    return false;
}

extern void Win32IDE_AddVoiceAutomationMenu(HMENU hMenu)
{
    if (!hMenu)
        return;
    // Invent Enable-TTS menu claimed product ready; keep visible but unchecked/fail-closed.
    OutputDebugStringA(
        "[VoiceAutomation] FEATURE_FICTION=1 FAIL_CLOSED AddVoiceAutomationMenu "
        "— no invent Enable TTS ready PASS\n");
    g_voiceAutomationEnabled.store(false, std::memory_order_release);
    AppendMenuW(hMenu, MF_STRING | MF_GRAYED, 4401, L"&Voice Automation Panel (FAIL_CLOSED)");
    AppendMenuW(hMenu, MF_SEPARATOR, 0, nullptr);
    AppendMenuW(hMenu, MF_STRING | MF_GRAYED | MF_UNCHECKED, 4402, L"&Enable TTS (FAIL_CLOSED)");
}
