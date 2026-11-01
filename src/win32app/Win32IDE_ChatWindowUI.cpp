// Win32IDE_ChatWindowUI.cpp — product wire Create/Show/Send/Cancel/Destroy
// /INCLUDE:RawrXD_UI_InitChatWindow  PROMOTE=0 INVENT_CHATWINDOW_PASS=0
#include <windows.h>

extern "C" {
typedef void* RawrXDChatWindowHandle;
RawrXDChatWindowHandle RawrXDChatWindow_Create(HWND hParent, HINSTANCE hInstance);
void RawrXDChatWindow_Destroy(RawrXDChatWindowHandle handle);
void RawrXDChatWindow_Show(RawrXDChatWindowHandle handle);
void RawrXDChatWindow_Hide(RawrXDChatWindowHandle handle);
void RawrXDChatWindow_SendMessage(RawrXDChatWindowHandle handle, const char* message);
void RawrXDChatWindow_Cancel(RawrXDChatWindowHandle handle);
HWND RawrXDChatWindow_GetHwnd(RawrXDChatWindowHandle handle);
}

namespace {
RawrXDChatWindowHandle g_chat = nullptr;
bool g_inited = false;
} // namespace

extern "C" {

int RawrXD_UI_InitChatWindow(HWND hwndParent) {
    if (!hwndParent || !IsWindow(hwndParent)) return 0;
    if (g_inited && g_chat) return 1;
    HINSTANCE hi = (HINSTANCE)GetWindowLongPtrW(hwndParent, GWLP_HINSTANCE);
    if (!hi) hi = GetModuleHandleW(nullptr);
    g_chat = RawrXDChatWindow_Create(hwndParent, hi);
    if (!g_chat) return 0;
    g_inited = true;
    OutputDebugStringA("RawrXD_UI_InitChatWindow: SOURCE_WIRED ChatWindow\n");
    return 1;
}

int RawrXD_UI_ShutdownChatWindow(void) {
    if (g_inited && g_chat) {
        RawrXDChatWindow_Destroy(g_chat);
        g_chat = nullptr;
        g_inited = false;
        OutputDebugStringA("RawrXD_UI_ShutdownChatWindow: teardown\n");
    }
    return 1;
}

int RawrXD_UI_ShowChatWindow(HWND hwndParent) {
    if (!hwndParent) return 0;
    if (!g_inited && !RawrXD_UI_InitChatWindow(hwndParent)) return 0;
    RawrXDChatWindow_Show(g_chat);
    OutputDebugStringA("RawrXD_UI_ShowChatWindow: shown\n");
    return 1;
}

int RawrXD_UI_HideChatWindow(void) {
    if (!g_inited || !g_chat) return 0;
    RawrXDChatWindow_Hide(g_chat);
    return 1;
}

int RawrXD_UI_ChatWindow_Send(const char* utf8) {
    if (!g_inited || !g_chat || !utf8) return 0;
    RawrXDChatWindow_SendMessage(g_chat, utf8);
    OutputDebugStringA("RawrXD_UI_ChatWindow_Send: prompt submitted\n");
    return 1;
}

int RawrXD_UI_ChatWindow_Cancel(void) {
    if (!g_inited || !g_chat) return 0;
    RawrXDChatWindow_Cancel(g_chat);
    OutputDebugStringA("RawrXD_UI_ChatWindow_Cancel: cancelStream\n");
    return 1;
}

HWND RawrXD_UI_ChatWindow_Hwnd(void) {
    if (!g_inited || !g_chat) return nullptr;
    return RawrXDChatWindow_GetHwnd(g_chat);
}

} // extern "C"
