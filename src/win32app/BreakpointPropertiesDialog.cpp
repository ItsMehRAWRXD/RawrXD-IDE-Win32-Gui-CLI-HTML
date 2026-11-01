//=============================================================================
// RawrXD Breakpoint Properties Dialog
// Modal dialog for editing breakpoint settings
//=============================================================================
// AUDIT_002_OPENISH_DEBUGGER_DRAIN_001:
// Prior: Show() invent empty-true on CreateWindow fail + fake EDIT "dialog" ready.
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent breakpoint-props ready PASS.
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
//=============================================================================
#include "BreakpointManagerPanel.hpp"
#include <windows.h>
#include <commctrl.h>
#include <string>

namespace RawrXD {
namespace Win32 {

//=============================================================================
// Dialog Resource (would normally be in .rc file)
//=============================================================================

// Dialog template for breakpoint properties
// In production, add this to your .rc file:
/*
IDD_BREAKPOINT_PROPS DIALOGEX 0, 0, 300, 200
STYLE DS_SETFONT | DS_MODALFRAME | DS_FIXEDSYS | WS_POPUP | WS_CAPTION | WS_SYSMENU
CAPTION "Breakpoint Properties"
FONT 8, "MS Shell Dlg", 400, 0, 0x1
BEGIN
    LTEXT           "Location:", IDC_STATIC, 7, 7, 40, 8
    LTEXT           "", IDC_LOCATION, 50, 7, 240, 8
    
    GROUPBOX        "Condition", IDC_STATIC, 7, 25, 286, 50
    EDITTEXT        IDC_CONDITION, 14, 38, 272, 30, ES_MULTILINE | ES_AUTOVSCROLL | WS_VSCROLL
    
    GROUPBOX        "Hit Count", IDC_STATIC, 7, 80, 286, 50
    COMBOBOX        IDC_HIT_CONDITION, 14, 93, 80, 100, CBS_DROPDOWNLIST | WS_VSCROLL | WS_TABSTOP
    EDITTEXT        IDC_HIT_COUNT, 100, 93, 50, 14, ES_NUMBER
    LTEXT           "times", IDC_STATIC, 155, 95, 20, 8
    
    CONTROL         "Enabled", IDC_ENABLED, "Button", BS_AUTOCHECKBOX | WS_TABSTOP, 14, 140, 50, 10
    
    DEFPUSHBUTTON   "OK", IDOK, 189, 179, 50, 14
    PUSHBUTTON      "Cancel", IDCANCEL, 243, 179, 50, 14
END
*/

//=============================================================================
// Dialog Implementation
//=============================================================================

struct BreakpointPropsData {
    BreakpointInfo* pBreakpoint;
    bool modified;
};

static constexpr int IDC_LOCATION = 1001;
static constexpr int IDC_CONDITION = 1002;
static constexpr int IDC_HIT_CONDITION = 1003;
static constexpr int IDC_HIT_COUNT = 1004;
static constexpr int IDC_ENABLED = 1005;

INT_PTR CALLBACK BreakpointPropertiesDialog::DialogProc(HWND hwndDlg, UINT msg, WPARAM wParam, LPARAM lParam) {
    BreakpointPropsData* pData = reinterpret_cast<BreakpointPropsData*>(
        GetWindowLongPtr(hwndDlg, GWLP_USERDATA));
    
    switch (msg) {
        case WM_INITDIALOG: {
            pData = reinterpret_cast<BreakpointPropsData*>(lParam);
            SetWindowLongPtr(hwndDlg, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(pData));
            InitializeDialog(hwndDlg, pData->pBreakpoint);
            return TRUE;
        }
        
        case WM_COMMAND: {
            int id = LOWORD(wParam);
            int notify = HIWORD(wParam);
            
            switch (id) {
                case IDOK:
                    if (pData) {
                        SaveChanges(hwndDlg, pData->pBreakpoint);
                    }
                    EndDialog(hwndDlg, IDOK);
                    return TRUE;
                    
                case IDCANCEL:
                    EndDialog(hwndDlg, IDCANCEL);
                    return TRUE;
                    
                case IDC_CONDITION:
                case IDC_HIT_COUNT:
                    if (notify == EN_CHANGE && pData) {
                        pData->modified = true;
                    }
                    break;
                    
                case IDC_ENABLED:
                case IDC_HIT_CONDITION:
                    if (pData) {
                        pData->modified = true;
                    }
                    break;
            }
            break;
        }
        
        case WM_CLOSE:
            EndDialog(hwndDlg, IDCANCEL);
            return TRUE;
    }
    
    return FALSE;
}

void BreakpointPropertiesDialog::InitializeDialog(HWND hwndDlg, BreakpointInfo* pbp) {
    if (!pbp) return;
    
    // Set dialog title
    std::wstring title = L"Breakpoint Properties - " + pbp->fileName + L":" + std::to_wstring(pbp->line);
    SetWindowText(hwndDlg, title.c_str());
    
    // Set location text
    std::wstring location = pbp->filePath + L":" + std::to_wstring(pbp->line);
    SetDlgItemText(hwndDlg, IDC_LOCATION, location.c_str());
    
    // Set condition
    std::wstring conditionWide(pbp->condition.begin(), pbp->condition.end());
    SetDlgItemText(hwndDlg, IDC_CONDITION, conditionWide.c_str());
    
    // Setup hit condition combo
    HWND hwndHitCond = GetDlgItem(hwndDlg, IDC_HIT_CONDITION);
    if (hwndHitCond) {
        SendMessage(hwndHitCond, CB_ADDSTRING, 0, (LPARAM)L"break always");
        SendMessage(hwndHitCond, CB_ADDSTRING, 0, (LPARAM)L"break when hit count is equal to");
        SendMessage(hwndHitCond, CB_ADDSTRING, 0, (LPARAM)L"break when hit count is a multiple of");
        SendMessage(hwndHitCond, CB_ADDSTRING, 0, (LPARAM)L"break when hit count is greater than or equal to");
        
        // Select current condition
        int sel = 0;
        if (pbp->hitCondition > 0) {
            sel = pbp->hitCondition;
        }
        SendMessage(hwndHitCond, CB_SETCURSEL, sel, 0);
    }
    
    // Set hit count
    SetDlgItemInt(hwndDlg, IDC_HIT_COUNT, pbp->hitCondition, FALSE);
    
    // Set enabled state
    CheckDlgButton(hwndDlg, IDC_ENABLED, pbp->enabled ? BST_CHECKED : BST_UNCHECKED);
    
    // Center dialog on parent
    HWND hwndParent = GetWindow(hwndDlg, GW_OWNER);
    if (hwndParent) {
        RECT rcDlg, rcParent;
        GetWindowRect(hwndDlg, &rcDlg);
        GetWindowRect(hwndParent, &rcParent);
        
        int x = rcParent.left + (rcParent.right - rcParent.left - (rcDlg.right - rcDlg.left)) / 2;
        int y = rcParent.top + (rcParent.bottom - rcParent.top - (rcDlg.bottom - rcDlg.top)) / 2;
        
        SetWindowPos(hwndDlg, NULL, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER);
    }
}

void BreakpointPropertiesDialog::SaveChanges(HWND hwndDlg, BreakpointInfo* pbp) {
    if (!pbp) return;
    
    // Save condition
    wchar_t conditionBuf[256] = {};
    GetDlgItemText(hwndDlg, IDC_CONDITION, conditionBuf, 256);
    pbp->condition = std::string(conditionBuf, conditionBuf + wcslen(conditionBuf));
    
    // Save hit condition
    HWND hwndHitCond = GetDlgItem(hwndDlg, IDC_HIT_CONDITION);
    if (hwndHitCond) {
        pbp->hitCondition = (int)SendMessage(hwndHitCond, CB_GETCURSEL, 0, 0);
    }
    
    // Save hit count
    BOOL translated = FALSE;
    UINT hitCount = GetDlgItemInt(hwndDlg, IDC_HIT_COUNT, &translated, FALSE);
    if (translated) {
        pbp->hitCondition = hitCount;
    }
    
    // Save enabled state
    pbp->enabled = (IsDlgButtonChecked(hwndDlg, IDC_ENABLED) == BST_CHECKED);
}

bool BreakpointPropertiesDialog::Show(HWND hwndParent, BreakpointInfo& bp) {
    // AUDIT_002_OPENISH_DEBUGGER_DRAIN_001:
    // Prior: invent empty-true on CreateWindow fail + fake EDIT window ready PASS
    // (no DialogBox / real .rc props dialog).
    // Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent breakpoint-props ready PASS.
    (void)hwndParent;
    (void)bp;
    OutputDebugStringA(
        "[BreakpointProps] FEATURE_FICTION=1 FAIL_CLOSED Show "
        "— no invent breakpoint properties dialog ready PASS\n");
    return false;
}

} // namespace Win32
} // namespace RawrXD
