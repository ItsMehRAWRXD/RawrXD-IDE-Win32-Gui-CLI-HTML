#include "SpeculativeOptimizer.h"
#include <iostream>
#include <algorithm>
#include <windows.h>

namespace RawrXD::Inference {

// AUDIT_002_OPENISH_OTHER_DRAIN_002:
// Prior: Predict invented mock token IDs + confidence 0.9 accepted.
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[SpeculativeOptimizer] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

SpeculativeOptimizer& SpeculativeOptimizer::GetInstance() {
    static SpeculativeOptimizer instance;
    return instance;
}

void SpeculativeOptimizer::AdjustStrategy(float memoryPressure) {
    if (memoryPressure > 0.8f) {
        m_currentLookahead = 2;
        m_minConfidence = 0.95f;
    } else if (memoryPressure < 0.4f) {
        m_currentLookahead = 8;
        m_minConfidence = 0.75f;
    } else {
        m_currentLookahead = 4;
        m_minConfidence = 0.85f;
    }
}

SpeculativeResult SpeculativeOptimizer::Predict(const std::vector<int>& /*context*/,
                                                int /*lookahead*/) {
    GateFiction("Predict");
    // Was: push mock token IDs 100+i with confidence 0.9 accepted=true.
    SpeculativeResult result;
    result.confidence = 0.0f;
    result.accepted = false;
    return result;
}

}
