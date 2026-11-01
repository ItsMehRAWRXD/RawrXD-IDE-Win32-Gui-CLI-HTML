#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>

/**
 * @file Win32IDE_VocabResolver.cpp
 * @brief Batch 4 (26/118): Vocabulary & Token Resolver.
 *
 * AUDIT_002_OPENISH_OTHER_DRAIN_010:
 * Prior: Vocab_TokenToText / Vocab_TextToToken invent static lexicon + FNV hash
 * tokens without loaded model vocab (fake-ready).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

namespace RawrXD::Models::Vocab {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf, "[VocabResolver] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

// Resolves: Vocab_TokenToText
extern "C" const char* Vocab_TokenToText(int token_id) {
    (void)token_id;
    // Was: invent byte/lexicon/fallback strings without vocab load.
    GateFiction("Vocab_TokenToText");
    return nullptr;
}

// Resolves: Vocab_TextToToken
extern "C" int Vocab_TextToToken(const char* text) {
    (void)text;
    // Was: invent hash-derived token ids without vocab load.
    GateFiction("Vocab_TextToToken");
    return -1;
}

} // namespace RawrXD::Models::Vocab
