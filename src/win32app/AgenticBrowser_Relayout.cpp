// ============================================================================
// AgenticBrowser_Relayout.cpp - Implementation of Win32IDE_AgenticBrowser_Relayout
// ============================================================================
// Provides browser-style relayout for the agentic AI panel in the RawrXD IDE.
//
// History:
//   2026-08-26  Created as part of Batch 1 unresolved external resolution.
// ============================================================================

#include <windows.h>
#include <string>

// ---------------------------------------------------------------------------
// Internal state
// ---------------------------------------------------------------------------
static HWND g_hwndAgenticBrowser = nullptr;
static bool g_agenticBrowserVisible = false;
static int g_agenticBrowserWidth = 320;

// ---------------------------------------------------------------------------
// Exported function (used by Win32IDE_Core.cpp)
// ---------------------------------------------------------------------------

// AUDIT_002_OPENISH_OTHER_DRAIN_015:
// Prior: Relayout invent SetWindowPos + "Relayout complete" as agentic-browser
// product ready PASS without validated browser product wire (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
extern void Win32IDE_AgenticBrowser_Relayout()
{
    // Was: invent SetWindowPos + "Relayout complete" ready PASS.
    OutputDebugStringA(
        "[AgenticBrowser] FEATURE_FICTION=1 FAIL_CLOSED Relayout "
        "(no invent agentic-browser ready PASS)\n");
}

// ---------------------------------------------------------------------------
// Additional agentic browser functions
// ---------------------------------------------------------------------------

// AUDIT_002_OPENISH_OTHER_DRAIN_015:
// Prior: Show invent DefWindowProc empty child as agentic-browser product
// ready PASS without validated browser content wire (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
extern void Win32IDE_AgenticBrowser_Show(HWND parent)
{
    (void)parent;
    // Was: invent RegisterClass + CreateWindow DefWindowProc ready PASS.
    g_hwndAgenticBrowser = nullptr;
    g_agenticBrowserVisible = false;
    OutputDebugStringA(
        "[AgenticBrowser] FEATURE_FICTION=1 FAIL_CLOSED Show "
        "(no invent agentic-browser ready PASS)\n");
}

extern void Win32IDE_AgenticBrowser_Hide()
{
    if (g_hwndAgenticBrowser && IsWindow(g_hwndAgenticBrowser))
    {
        ShowWindow(g_hwndAgenticBrowser, SW_HIDE);
    }
    g_agenticBrowserVisible = false;
}

extern bool Win32IDE_AgenticBrowser_IsVisible()
{
    return g_agenticBrowserVisible;
}

extern void Win32IDE_AgenticBrowser_SetWidth(int width)
{
    if (width >= 200 && width <= 600)
    {
        g_agenticBrowserWidth = width;
        Win32IDE_AgenticBrowser_Relayout();
    }
}
