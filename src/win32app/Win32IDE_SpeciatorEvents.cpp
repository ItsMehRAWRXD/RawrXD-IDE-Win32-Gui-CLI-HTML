#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>
#include <string>

/**
 * @file Win32IDE_SpeciatorEvents.cpp
 * @brief Batch 2 (12/118): Speciator UI to Agent Event Handlers.
 * Routes model-selection and agent 'evolution' (finetuning) requests.
 *
 * AUDIT_002_OPENISH_OTHER_DRAIN_003:
 * Prior: Speciator_OnModelSelected LOG-only return true (empty-true; no GGUF/MASM).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

namespace RawrXD::UI::Speciator {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[SpeciatorEvents] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

// Resolves: Speciator_OnModelSelected
extern "C" bool Speciator_OnModelSelected(const char* model_name) {
    (void)model_name;
    // Was: LOG + invent true (no GGUF Loader / MASM kernel bind).
    GateFiction("Speciator_OnModelSelected");
    return false;
}

// Resolves: Speciator_OnQuantizationChange
extern "C" void Speciator_OnQuantizationChange(int bits) {
    (void)bits;
    GateFiction("Speciator_OnQuantizationChange");
    LOG_WARN("[Speciator] FEATURE_FICTION=1 FAIL_CLOSED quantization change");
}

} // namespace RawrXD::UI::Speciator
