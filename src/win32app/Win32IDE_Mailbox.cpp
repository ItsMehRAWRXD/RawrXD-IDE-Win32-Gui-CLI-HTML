#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>
#include <string>

/**
 * @file Win32IDE_Mailbox.cpp
 *
 * AUDIT_002_OPENISH_OTHER_DRAIN_008:
 * Prior: Mailbox Push/PopSecure invent swarm Nervous System + fake PQC gate (empty-true).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

namespace RawrXD::Messaging {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[Mailbox] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

class Mailbox {
public:
    static Mailbox& GetInstance() {
        static Mailbox instance;
        return instance;
    }

    void Push(const std::string& address, const std::string& message) {
        (void)address; (void)message;
        GateFiction("Mailbox_Push");
    }

    std::string PopSecure(const std::string& address, const uint8_t* pqc_sig) {
        (void)address; (void)pqc_sig;
        GateFiction("Mailbox_PopSecure");
        return "";
    }

private:
    Mailbox() = default;
};

} // namespace RawrXD::Messaging

extern "C" void Mailbox_Push(const char* addr, const char* msg) {
    RawrXD::Messaging::Mailbox::GetInstance().Push(addr ? addr : "", msg ? msg : "");
}

extern "C" const char* Mailbox_Pop(const char* addr, const uint8_t* sig) {
    static thread_local std::string result;
    result = RawrXD::Messaging::Mailbox::GetInstance().PopSecure(addr ? addr : "", sig);
    return result.c_str();
}
