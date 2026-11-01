; RAWR_MASM_X64_E2E_001 Test Fixture - Full version with ExitProcess
extern ExitProcess
global main

section .text

main:
    sub     rsp, 40
    mov     ecx, 42
    call    ExitProcess
    add     rsp, 40
    ret

END
