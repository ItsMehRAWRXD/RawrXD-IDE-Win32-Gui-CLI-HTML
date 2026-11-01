; Win32IDE_Sidebar_Pure_Minimal.asm
; AUDIT_002_OPENISH_UI_PANEL_DRAIN_001:
; Prior: invent Logger/Sidebar/DebugEngine/Theme rax=1 ready PASS (no Win32 I/O).
; Now: FEATURE_FICTION=1 FAIL_CLOSED - no invent Minimal sidebar ready PASS.
; Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
OPTION CASEMAP:NONE

.data
    g_SidebarHwnd    dq  0
    g_SidebarVisible db  0

.code

; Was: mov rax,1 invent ready. Fail-closed: return 0 (not ready).
Logger_Initialize PROC
    xor eax, eax
    ret
Logger_Initialize ENDP

Logger_Write PROC
    xor eax, eax
    ret
Logger_Write ENDP

Logger_Finalize PROC
    xor eax, eax
    ret
Logger_Finalize ENDP

Sidebar_Initialize PROC
    mov g_SidebarHwnd, rcx
    xor eax, eax
    ret
Sidebar_Initialize ENDP

Sidebar_Destroy PROC
    mov g_SidebarHwnd, 0
    mov g_SidebarVisible, 0
    xor eax, eax
    ret
Sidebar_Destroy ENDP

Sidebar_ShowPanel PROC
    mov g_SidebarVisible, 0
    xor eax, eax
    ret
Sidebar_ShowPanel ENDP

Sidebar_HidePanel PROC
    mov g_SidebarVisible, 0
    xor eax, eax
    ret
Sidebar_HidePanel ENDP

DebugEngine_Create PROC
    xor eax, eax
    ret
DebugEngine_Create ENDP

DebugEngine_Step PROC
    xor eax, eax
    ret
DebugEngine_Step ENDP

DebugEngine_Destroy PROC
    xor eax, eax
    ret
DebugEngine_Destroy ENDP

Theme_SetDarkMode PROC
    xor eax, eax
    ret
Theme_SetDarkMode ENDP

Theme_IsDarkModeEnabled PROC
    xor eax, eax
    ret
Theme_IsDarkModeEnabled ENDP

Sidebar_GetMemoryFootprint PROC
    ; Was: invent 48KB footprint ready. Fail-closed zero.
    xor eax, eax
    ret
Sidebar_GetMemoryFootprint ENDP

END
