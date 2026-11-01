// rtp_protocol_production.cpp — Production RTP protocol implementation
//
// AUDIT_002_OPENISH_OTHER_DRAIN_011:
// Prior: RawrXD_RTP_Initialize invent WSAStartup-only ready; CreateSession/Send
// invent UDP theater as production collab PASS (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include <windows.h>
#include <stdint.h>
#include <stdbool.h>

namespace RawrXD {
namespace RTP {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf, "[RTPProduction] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" {

bool RawrXD_RTP_Initialize() {
    // Was: invent initialized_=true after WSAStartup without collab/product wire.
    GateFiction("RawrXD_RTP_Initialize");
    return false;
}

void RawrXD_RTP_Shutdown() {
    GateFiction("RawrXD_RTP_Shutdown");
}

bool RawrXD_RTP_CreateSession(uint16_t localPort) {
    (void)localPort;
    GateFiction("RawrXD_RTP_CreateSession");
    return false;
}

bool RawrXD_RTP_Send(const void* data, size_t size, const char* destIP, uint16_t destPort) {
    (void)data;
    (void)size;
    (void)destIP;
    (void)destPort;
    GateFiction("RawrXD_RTP_Send");
    return false;
}

bool RawrXD_RTP_IsInitialized() {
    // Was: invent initialized_ true as production ready.
    return false;
}

void RTPProtocolFallbackStub() {
    GateFiction("RTPProtocolFallbackStub");
}

} // extern "C"

} // namespace RTP
} // namespace RawrXD
