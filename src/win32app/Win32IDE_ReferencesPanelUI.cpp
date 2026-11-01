// Win32IDE_ReferencesPanelUI.cpp — product wire for ReferencesPanel orphan
// HEADER_API_RESURFACE COMPLETION_011. SOURCE_WIRED != invent Find-Refs PASS.
// tip748B untouched. PROMOTE=0 INVENT_REFERENCES_PASS=0
#include <windows.h>

// Defined in Win32IDE_ReferencesPanel.cpp — address-taken keep under /OPT:REF
extern "C" void RawrXD_UI_ReferencesPanel_ForceKeep(void);

extern "C" {

// /INCLUDE:RawrXD_UI_InitReferencesPanel
// Fail-closed force-link anchor. No invent product Find-All-References PASS.
int RawrXD_UI_InitReferencesPanel(HWND hwndParent) {
    (void)hwndParent;
    RawrXD_UI_ReferencesPanel_ForceKeep();
    OutputDebugStringA(
        "RawrXD_UI_InitReferencesPanel: SOURCE_WIRED ReferencesPanel "
        "FAIL_CLOSED no invent Find-Refs PASS\n");
    return 0;
}

int RawrXD_UI_ShutdownReferencesPanel(void) {
    OutputDebugStringA("RawrXD_UI_ShutdownReferencesPanel: FAIL_CLOSED\n");
    return 0;
}

} // extern "C"
