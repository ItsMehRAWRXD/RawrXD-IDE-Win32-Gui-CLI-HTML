// Win32IDE_CompilerPanel.cpp — product-adapt fail-closed (COMPLETION_020)
// Orphan fiction used CppCompilerImpl + m_hwndTerminal (ABSENT on product).
// Real compile UI path = CompilerIntegration_Real (already linked).
// INVENT_COMPILER_PASS=0 — SOURCE_WIRED ≠ invent compiler panel PASS.

#include "Win32IDE.h"
#include "CompilerIntegration_Native.h"

#include <string>

using RawrXD::Win32App::CompilerIntegration_CompileCurrentFile;
using RawrXD::Win32App::CompilerIntegration_OnFileOpened;
using RawrXD::Win32App::CompilerIntegration_ShowOutput;

void Win32IDE::ShowCompilerOutput()
{
    // CppCompilerImpl is file-local in compiler_cpp_real.cpp (NOT in Win32IDE
    // link). Do not invent a public CppCompilerImpl surface.
    OutputDebugStringA(
        "[CompilerPanel] ShowCompilerOutput FAIL_CLOSED "
        "adapt→CompilerIntegration INVENT_COMPILER_PASS=0 "
        "CppCompilerImpl=ABSENT_FROM_WIN32IDE_LINK\n");

    if (!m_currentFile.empty()) {
        CompilerIntegration_OnFileOpened(m_currentFile.c_str());
    }
    CompilerIntegration_ShowOutput();
    CompilerIntegration_CompileCurrentFile();
}

void Win32IDE::ShowDumpbinOutput()
{
    // m_hwndTerminal / AppendTerminalText / parse_pe_headers_internal panel
    // path ABSENT from live Win32IDE.h and Win32IDE_temp.h — WHY_HELD.
    // Do not invent a terminal HWND or claim PE analyzer product PASS.
    OutputDebugStringA(
        "[CompilerPanel] ShowDumpbinOutput WHY_HELD "
        "m_hwndTerminal=ABSENT PE_PANEL=NOT_CLAIMED INVENT_COMPILER_PASS=0\n");
    CompilerIntegration_ShowOutput();
}

// Cite force — /INCLUDE:RawrXD_UI_InitCompilerPanel
extern "C" void RawrXD_UI_CompilerPanel_ForceKeep(void)
{
    volatile auto p0 = &Win32IDE::ShowCompilerOutput;
    volatile auto p1 = &Win32IDE::ShowDumpbinOutput;
    (void)p0;
    (void)p1;
}

extern "C" int RawrXD_UI_InitCompilerPanel(HWND hwndParent)
{
    (void)hwndParent;
    RawrXD_UI_CompilerPanel_ForceKeep();
    OutputDebugStringA(
        "RawrXD_UI_InitCompilerPanel: SOURCE_WIRED CompilerPanel "
        "adapt CompilerIntegration FAIL_CLOSED INVENT_COMPILER_PASS=0 "
        "CppCompilerImpl=ABSENT DUMPBIN_TERMINAL=WHY_HELD\n");
    return 0;
}

extern "C" int RawrXD_UI_ShutdownCompilerPanel(void)
{
    OutputDebugStringA("RawrXD_UI_ShutdownCompilerPanel: FAIL_CLOSED\n");
    return 0;
}
