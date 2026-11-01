// Lane B (RawrEngine): defines BulkFixOrchestrator::~BulkFixOrchestrator for SubAgentManager's
// unique_ptr member — avoids linking full autonomous_subagent.cpp (AgenticEngine / detector deps).
//
// AUDIT_002_OPENISH_OTHER_DRAIN_017:
// Prior: empty destructor-only TU invent Lane-B BulkFixOrchestrator impl ready
// PASS without validated product orchestrator wire (fake-ready / empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
#include "agent/autonomous_subagent.hpp"
#include <windows.h>

namespace {
struct BulkFixLaneBFailClosed {
    BulkFixLaneBFailClosed() {
        // Was: invent empty Lane-B impl-ready PASS (destructor-only TU).
        OutputDebugStringA(
            "[bulk_fix_orchestrator_laneb_impl] FEATURE_FICTION=1 FAIL_CLOSED TU "
            "(no invent Lane-B BulkFixOrchestrator ready PASS)\n");
    }
};
static BulkFixLaneBFailClosed g_bulkFixLaneBFailClosed;
}

BulkFixOrchestrator::~BulkFixOrchestrator() = default;
