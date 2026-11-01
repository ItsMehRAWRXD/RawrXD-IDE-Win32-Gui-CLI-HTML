// Win32IDE_Hermes.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_006:
// Prior: InitializeBatch24 invent peer mesh + handshake gap (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include <windows.h>

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[Hermes] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" void Hermes_ActivateGate_Internal() {
    // Was: invent Master-TITAN / Secondary peer nodes; "P2P handshake goes here".
    GateFiction("Hermes_ActivateGate_Internal");
}

extern "C" bool Hermes_PostMessage(const char* dst, const char* msg) {
    (void)dst;
    (void)msg;
    GateFiction("Hermes_PostMessage");
    return false;
}

extern "C" void* Hermes_Listen(const char* src_id) {
    (void)src_id;
    GateFiction("Hermes_Listen");
    return nullptr;
}

extern "C" bool Hermes_InjectInbound(const char* src_id, const char* msg) {
    (void)src_id;
    (void)msg;
    GateFiction("Hermes_InjectInbound");
    return false;
}
