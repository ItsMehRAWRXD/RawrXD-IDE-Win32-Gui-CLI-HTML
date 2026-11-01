#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>

/**
 * @file Win32IDE_VocabHardening.cpp
 * @brief Batch 4 (31/118): Vocabulary Integrity & Safety.
 *
 * AUDIT_002_OPENISH_OTHER_DRAIN_010:
 * Prior: Vocab_VerifyIntegrity invent crc!=0 PASS; FilterSensitiveTokens invent
 * redact theater without vocab/auth wire (fake-ready).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

namespace RawrXD::Safety::Vocab {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf, "[VocabHardening] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

// Resolves: Vocab_VerifyIntegrity
extern "C" bool Vocab_VerifyIntegrity(void* vocab_ptr) {
    (void)vocab_ptr;
    // Was: invent crc!=0 as integrity PASS without model vocab wire.
    GateFiction("Vocab_VerifyIntegrity");
    return false;
}

// Resolves: Vocab_FilterSensitiveTokens
extern "C" void Vocab_FilterSensitiveTokens(int* token_ids, int count) {
    (void)token_ids;
    (void)count;
    // Was: invent redact of [32000..32099] without vocab/policy wire.
    GateFiction("Vocab_FilterSensitiveTokens");
}

} // namespace RawrXD::Safety::Vocab
