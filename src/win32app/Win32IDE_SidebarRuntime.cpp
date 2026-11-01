// Win32IDE_SidebarRuntime.cpp — COMPLETION_018 product wire
// Resurface SidebarView::GitHub/GitHubPullRelease/Accounts/Manage.
// Do NOT redefine ActivityBarProc/SidebarProc/SidebarContentProc/createExplorerView/
// refreshFileTree/updateDebugVariables (live in Win32IDE_Sidebar.cpp).
// INVENT_SIDEBAR_PASS=0 — no fake GitHub auth / LayoutProfile PASS.
// tip748B untouched. PROMOTE=0 AUTHORIZE_CANDIDATE_ONLY=1
#include "Win32IDE.h"
#include "Win32IDE_Commands.h"

#include <shellapi.h>

namespace
{
constexpr int IDC_GITHUB_OPEN_REPO = 6060;
constexpr int IDC_GITHUB_OPEN_ISSUES = 6061;
constexpr int IDC_GITHUB_OPEN_PULLS = 6062;
constexpr int IDC_GITHUB_OPEN_RELEASES = 6063;
constexpr int IDC_ACCOUNTS_OPEN_SETTINGS = 6064;
constexpr int IDC_ACCOUNTS_OPEN_GITHUB_LOGIN = 6065;
constexpr int IDC_MANAGE_OPEN_EXTENSIONS = 6066;
constexpr int IDC_MANAGE_OPEN_SETTINGS = 6067;
constexpr int IDC_MANAGE_OPEN_LAYOUTS = 6068;
constexpr int IDC_SIDEBAR_RUNTIME_TITLE = 6058;
constexpr int IDC_SIDEBAR_RUNTIME_SUBTITLE = 6059;

void createSidebarHeaderText(HWND parent, const char* title, const char* subtitle)
{
    if (!parent)
        return;
    CreateWindowExA(0, "STATIC", title, WS_CHILD | WS_VISIBLE | SS_LEFT, 8, 8, 220, 20, parent,
                    reinterpret_cast<HMENU>(static_cast<INT_PTR>(IDC_SIDEBAR_RUNTIME_TITLE)), nullptr, nullptr);
    CreateWindowExA(0, "STATIC", subtitle, WS_CHILD | WS_VISIBLE | SS_LEFT, 8, 30, 230, 40, parent,
                    reinterpret_cast<HMENU>(static_cast<INT_PTR>(IDC_SIDEBAR_RUNTIME_SUBTITLE)), nullptr, nullptr);
}

void createSidebarActionButton(HWND parent, int id, const char* label, int y)
{
    if (!parent)
        return;
    CreateWindowExA(0, "BUTTON", label, WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON, 8, y, 220, 28, parent,
                    reinterpret_cast<HMENU>(static_cast<INT_PTR>(id)), nullptr, nullptr);
}
}  // namespace

void Win32IDE::destroySidebarRuntimeChildren(HWND hwndParent)
{
    if (!hwndParent || !IsWindow(hwndParent))
        return;
    for (int id = IDC_SIDEBAR_RUNTIME_TITLE; id <= IDC_MANAGE_OPEN_LAYOUTS; ++id)
    {
        if (HWND child = GetDlgItem(hwndParent, id))
            DestroyWindow(child);
    }
}

void Win32IDE::createGitHubView(HWND hwndParent)
{
    HWND parent = hwndParent ? hwndParent : m_hwndSidebarContent;
    destroySidebarRuntimeChildren(parent);
    createSidebarHeaderText(parent, "GitHub",
                            "Open repo surfaces (URL only). No invent auth PASS.");
    createSidebarActionButton(parent, IDC_GITHUB_OPEN_REPO, "Open Repository", 80);
    createSidebarActionButton(parent, IDC_GITHUB_OPEN_ISSUES, "Open Issues", 114);
    createSidebarActionButton(parent, IDC_GITHUB_OPEN_PULLS, "Open Pull Requests", 148);
    OutputDebugStringA("[SidebarRuntime] createGitHubView SOURCE_WIRED INVENT_SIDEBAR_PASS=0\n");
}

void Win32IDE::createGitHubPullReleaseView(HWND hwndParent)
{
    HWND parent = hwndParent ? hwndParent : m_hwndSidebarContent;
    destroySidebarRuntimeChildren(parent);
    createSidebarHeaderText(parent, "Pulls / Releases",
                            "Browser open only. LayoutProfile/auth not claimed.");
    createSidebarActionButton(parent, IDC_GITHUB_OPEN_PULLS, "Open Pull Requests", 80);
    createSidebarActionButton(parent, IDC_GITHUB_OPEN_RELEASES, "Open Releases", 114);
    OutputDebugStringA("[SidebarRuntime] createGitHubPullReleaseView SOURCE_WIRED\n");
}

void Win32IDE::createAccountsView(HWND hwndParent)
{
    HWND parent = hwndParent ? hwndParent : m_hwndSidebarContent;
    destroySidebarRuntimeChildren(parent);
    createSidebarHeaderText(parent, "Accounts",
                            "Settings route + GitHub login URL. WHY_HELD auth.");
    createSidebarActionButton(parent, IDC_ACCOUNTS_OPEN_SETTINGS, "Open Settings", 80);
    createSidebarActionButton(parent, IDC_ACCOUNTS_OPEN_GITHUB_LOGIN, "GitHub Login (URL)", 114);
    OutputDebugStringA("[SidebarRuntime] createAccountsView FAIL_CLOSED no invent auth\n");
}

void Win32IDE::createManageView(HWND hwndParent)
{
    HWND parent = hwndParent ? hwndParent : m_hwndSidebarContent;
    destroySidebarRuntimeChildren(parent);
    createSidebarHeaderText(parent, "Manage",
                            "Extensions/Settings live. Layouts: WHY_HELD.");
    createSidebarActionButton(parent, IDC_MANAGE_OPEN_EXTENSIONS, "Extensions", 80);
    createSidebarActionButton(parent, IDC_MANAGE_OPEN_SETTINGS, "Settings", 114);
    createSidebarActionButton(parent, IDC_MANAGE_OPEN_LAYOUTS, "Layouts (held)", 148);
    OutputDebugStringA("[SidebarRuntime] createManageView LayoutProfile ABSENT WHY_HELD\n");
}

bool Win32IDE::handleSidebarRuntimeCommand(int id)
{
    switch (id)
    {
        case IDC_GITHUB_OPEN_REPO:
            ShellExecuteA(nullptr, "open", "https://github.com/ItsMehRAWRXD/RawrXD", nullptr, nullptr, SW_SHOW);
            return true;
        case IDC_GITHUB_OPEN_ISSUES:
            ShellExecuteA(nullptr, "open", "https://github.com/ItsMehRAWRXD/RawrXD/issues", nullptr, nullptr,
                          SW_SHOW);
            return true;
        case IDC_GITHUB_OPEN_PULLS:
            ShellExecuteA(nullptr, "open", "https://github.com/ItsMehRAWRXD/RawrXD/pulls", nullptr, nullptr,
                          SW_SHOW);
            return true;
        case IDC_GITHUB_OPEN_RELEASES:
            ShellExecuteA(nullptr, "open", "https://github.com/ItsMehRAWRXD/RawrXD/releases", nullptr, nullptr,
                          SW_SHOW);
            return true;
        case IDC_ACCOUNTS_OPEN_SETTINGS:
            if (m_hwndMain)
                PostMessageA(m_hwndMain, WM_COMMAND, IDM_T1_SETTINGS_GUI, 0);
            return true;
        case IDC_ACCOUNTS_OPEN_GITHUB_LOGIN:
            // Fail-closed: open login URL only — no fake auth success / token invent.
            OutputDebugStringA(
                "[SidebarRuntime] GitHub login WHY_HELD: URL open only; "
                "INVENT_SIDEBAR_PASS=0 no auth success\n");
            ShellExecuteA(nullptr, "open", "https://github.com/login", nullptr, nullptr, SW_SHOW);
            return true;
        case IDC_MANAGE_OPEN_EXTENSIONS:
            setSidebarView(SidebarView::Extensions);
            return true;
        case IDC_MANAGE_OPEN_SETTINGS:
            if (m_hwndMain)
                PostMessageA(m_hwndMain, WM_COMMAND, IDM_T1_SETTINGS_GUI, 0);
            return true;
        case IDC_MANAGE_OPEN_LAYOUTS:
            // LayoutProfile APIs exist in temp.h but NOT live product command ID.
            OutputDebugStringA(
                "[SidebarRuntime] Manage layouts WHY_HELD: IDM_VIEW_LAYOUT_PROFILE_APPLY "
                "ABSENT live; fallback IDM_T1_SETTINGS_GUI; INVENT_SIDEBAR_PASS=0\n");
            if (m_hwndMain)
                PostMessageA(m_hwndMain, WM_COMMAND, IDM_T1_SETTINGS_GUI, 0);
            return true;
        default:
            return false;
    }
}

// Cite force — /INCLUDE:RawrXD_UI_InitSidebarRuntime (like ReferencesPanelUI)
extern "C" void RawrXD_UI_SidebarRuntime_ForceKeep(void)
{
    volatile auto p0 = &Win32IDE::createGitHubView;
    volatile auto p1 = &Win32IDE::createAccountsView;
    volatile auto p2 = &Win32IDE::createManageView;
    volatile auto p3 = &Win32IDE::createGitHubPullReleaseView;
    volatile auto p4 = &Win32IDE::handleSidebarRuntimeCommand;
    (void)p0;
    (void)p1;
    (void)p2;
    (void)p3;
    (void)p4;
}

extern "C" int RawrXD_UI_InitSidebarRuntime(HWND hwndParent)
{
    (void)hwndParent;
    RawrXD_UI_SidebarRuntime_ForceKeep();
    OutputDebugStringA(
        "RawrXD_UI_InitSidebarRuntime: SOURCE_WIRED SidebarRuntime "
        "GitHub/Accounts/Manage FAIL_CLOSED INVENT_SIDEBAR_PASS=0\n");
    return 0;
}

extern "C" int RawrXD_UI_ShutdownSidebarRuntime(void)
{
    OutputDebugStringA("RawrXD_UI_ShutdownSidebarRuntime: FAIL_CLOSED\n");
    return 0;
}
