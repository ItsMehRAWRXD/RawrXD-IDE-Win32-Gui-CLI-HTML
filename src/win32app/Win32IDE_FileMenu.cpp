// ============================================================================
// Win32IDE_FileMenu.cpp — Complete File Menu Integration
// Connects all 3,533 source files to Win32 GUI dropdown menus
// ============================================================================

#include "Win32IDE.h"
#include "resource.h"
#include "FileRegistry_Auto.h"
#include "logging/logger.h"
#include <windows.h>
#include <richedit.h>
#include <string>
#include <fstream>
#include <sstream>

static Logger s_logger("FileMenu");

// ============================================================================
// Menu Bar Setup (integrates into main Win32IDE window)
// ============================================================================

// AUDIT_002_OPENISH_OTHER_DRAIN_016:
// Prior: CreateCompleteMenuBar invent "Complete File Menu" + file-count ready as
// product menu PASS without validated tip product menu wire (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
HMENU Win32IDE_CreateCompleteMenuBar() {
    // Was: invent complete File/Edit/View + Browse All Source Files ready PASS.
    OutputDebugStringA(
        "[FileMenu] FEATURE_FICTION=1 FAIL_CLOSED CreateCompleteMenuBar "
        "(no invent complete-file-menu ready PASS)\n");
    s_logger.warn("FEATURE_FICTION=1 FAIL_CLOSED — CreateCompleteMenuBar invent ready held");
    return nullptr;
}

// ============================================================================
// File Opening Handler
// ============================================================================

bool Win32IDE_OpenFileFromMenu(HWND hwnd, UINT commandId) {
    std::string filepath = FileRegistry::getFilePath(commandId);
    
    if (filepath.empty()) {
        s_logger.warn("No file found for command ID: {}", commandId);
        return false;
    }
    
    s_logger.info("Opening file from menu: {}", filepath);
    
    // Read file content
    std::ifstream file(filepath, std::ios::binary);
    if (!file.is_open()) {
        s_logger.error("Failed to open file: {}", filepath);
        MessageBoxA(hwnd, ("Failed to open: " + filepath).c_str(), 
                    "Error", MB_OK | MB_ICONERROR);
        return false;
    }
    
    std::string content((std::istreambuf_iterator<char>(file)),
                        std::istreambuf_iterator<char>());
    file.close();
    
    // Notify Agent of context change if bridge exists
    if (m_ide && m_ide->getAgenticBridge()) {
        std::filesystem::path p(filepath);
        m_ide->getAgenticBridge()->SetWorkspaceRoot(p.parent_path().string());
        m_ide->getAgenticBridge()->SetLanguageContext(p.extension().string(), filepath);
    }

    // Find editor control (assuming RichEdit control)
    HWND hEditor = FindWindowExA(hwnd, NULL, "RICHEDIT50W", NULL);
    if (!hEditor) {
        hEditor = FindWindowExA(hwnd, NULL, "Edit", NULL);
    }
    
    if (!hEditor) {
        s_logger.error("Editor control not found in Win32IDE window");
        return false;
    }
    
    // Set content
    SetWindowTextA(hEditor, content.c_str());
    
    // Update window title
    std::string title = "RawrXD IDE - " + filepath;
    SetWindowTextA(hwnd, title.c_str());
    
    s_logger.info("File loaded successfully: {} ({} bytes)", filepath, content.length());
    
    return true;
}

// ============================================================================
// Search and Filter
// ============================================================================

std::vector<std::string> Win32IDE_SearchFiles(const std::string& query) {
    std::vector<std::string> results;
    auto allFiles = FileRegistry::getAllFiles();
    
    std::string lowerQuery = query;
    std::transform(lowerQuery.begin(), lowerQuery.end(), lowerQuery.begin(), ::tolower);
    
    for (const auto& file : allFiles) {
        std::string lowerPath = file.path;
        std::transform(lowerPath.begin(), lowerPath.end(), lowerPath.begin(), ::tolower);
        
        if (lowerPath.find(lowerQuery) != std::string::npos) {
            results.push_back(file.path);
        }
    }
    
    s_logger.debug("Search '{}': {} results", query, results.size());
    return results;
}

// ============================================================================
// Category Browser
// ============================================================================

HWND Win32IDE_CreateFileBrowser(HWND parent, int x, int y, int width, int height) {
    HWND hListBox = CreateWindowExA(
        WS_EX_CLIENTEDGE,
        "LISTBOX",
        "",
        WS_CHILD | WS_VISIBLE | WS_VSCROLL | LBS_NOTIFY | LBS_HASSTRINGS,
        x, y, width, height,
        parent,
        (HMENU)ID_FILE_BROWSER_LIST,
        GetModuleHandle(NULL),
        NULL
    );
    
    if (!hListBox) {
        s_logger.error("Failed to create file browser list box");
        return NULL;
    }
    
    // Populate with all files
    auto allFiles = FileRegistry::getAllFiles();
    for (const auto& file : allFiles) {
        SendMessageA(hListBox, LB_ADDSTRING, 0, (LPARAM)file.displayName.c_str());
    }
    
    s_logger.info("File browser created with {} entries", allFiles.size());
    
    return hListBox;
}

// ============================================================================
// Quick Open Dialog (Ctrl+P style)
// ============================================================================

INT_PTR CALLBACK QuickOpenDialogProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    static HWND hSearchBox = NULL;
    static HWND hResultsList = NULL;
    
    switch (msg) {
        case WM_INITDIALOG: {
            // Create search box
            hSearchBox = CreateWindowExA(0, "EDIT", "",
                WS_CHILD | WS_VISIBLE | WS_BORDER | ES_AUTOHSCROLL,
                10, 10, 560, 25,
                hwnd, (HMENU)ID_QUICKOPEN_SEARCH, GetModuleHandle(NULL), NULL);
            
            // Create results list
            hResultsList = CreateWindowExA(0, "LISTBOX", "",
                WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_BORDER | LBS_NOTIFY,
                10, 45, 560, 350,
                hwnd, (HMENU)ID_QUICKOPEN_RESULTS, GetModuleHandle(NULL), NULL);
            
            // Populate with all files
            auto files = FileRegistry::getAllFiles();
            for (const auto& f : files) {
                SendMessageA(hResultsList, LB_ADDSTRING, 0, (LPARAM)f.displayName.c_str());
            }
            
            SetFocus(hSearchBox);
            return TRUE;
        }
        
        case WM_COMMAND: {
            if (LOWORD(wParam) == ID_QUICKOPEN_SEARCH && HIWORD(wParam) == EN_CHANGE) {
                // Filter results based on search
                char query[256];
                GetWindowTextA(hSearchBox, query, sizeof(query));
                
                SendMessageA(hResultsList, LB_RESETCONTENT, 0, 0);
                auto results = Win32IDE_SearchFiles(query);
                for (const auto& path : results) {
                    SendMessageA(hResultsList, LB_ADDSTRING, 0, (LPARAM)path.c_str());
                }
            }
            else if (LOWORD(wParam) == ID_QUICKOPEN_RESULTS && HIWORD(wParam) == LBN_DBLCLK) {
                // User double-clicked a file
                int sel = (int)SendMessageA(hResultsList, LB_GETCURSEL, 0, 0);
                if (sel != LB_ERR) {
                    char filepath[512];
                    SendMessageA(hResultsList, LB_GETTEXT, sel, (LPARAM)filepath);
                    
                    // Return filepath to parent
                    EndDialog(hwnd, (INT_PTR)sel);
                }
            }
            else if (LOWORD(wParam) == IDCANCEL) {
                EndDialog(hwnd, IDCANCEL);
            }
            break;
        }
        
        case WM_CLOSE:
            EndDialog(hwnd, IDCANCEL);
            return TRUE;
    }
    
    return FALSE;
}

void Win32IDE_ShowQuickOpen(HWND parent) {
    // Show modal quick-open dialog
    DialogBoxW(GetModuleHandle(NULL),
              MAKEINTRESOURCEW(IDD_QUICKOPEN),
              parent,
              QuickOpenDialogProc);
}

// Menu Command IDs — see resource.h
