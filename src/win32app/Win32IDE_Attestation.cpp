#include "Win32IDE.h"
#include "../security/SovereignAttestation.h"
#include <nlohmann/json.hpp>

using namespace RawrXD::Security;

/**
 * AUDIT_002_OPENISH_OTHER_DRAIN_008:
 * Prior: initializeSovereignAttestation invent "NIST 800-218" active (fake-ready).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[Attestation] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

void Win32IDE::initializeSovereignAttestation() {
    // Was: invent Initialize + "SovereignAttestation active (NIST 800-218)".
    GateFiction("initializeSovereignAttestation");
    LOG_WARNING("FEATURE_FICTION=1 FAIL_CLOSED SovereignAttestation (no invent NIST PASS)");
}

void Win32IDE::recordModelLoadAttestation(const std::string& modelPath, const void* mappedBase, size_t size) {
    (void)modelPath; (void)mappedBase; (void)size;
    GateFiction("recordModelLoadAttestation");
}

void Win32IDE::exportAttestationReport() {
    GateFiction("exportAttestationReport");
    if (m_hwndMain) {
        MessageBoxA(m_hwndMain,
            "FEATURE_FICTION=1 FAIL_CLOSED — no invent attestation PASS",
            "Sovereign Attestation", MB_OK | MB_ICONWARNING);
    }
}
