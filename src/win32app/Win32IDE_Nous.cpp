#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>
#include <string>
#include <vector>

/**
 * @file Win32IDE_Nous.cpp
 *
 * AUDIT_002_OPENISH_OTHER_DRAIN_008:
 * Prior: Nous IngestGoal/DecomposePlan invent autonomy planner via keyword heuristics (fake-ready).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

namespace RawrXD::Autonomy {

struct PlanStep {
    std::string description;
    uint32_t priority;
    bool is_critical;
};

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[Nous] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

class Nous {
public:
    static Nous& GetInstance() {
        static Nous instance;
        return instance;
    }

    bool IngestGoal(const std::string& goal_id, const std::string& description) {
        (void)goal_id; (void)description;
        GateFiction("Nous_IngestGoal");
        return false;
    }

    std::vector<PlanStep> DecomposePlan(const std::string& goal_id) {
        (void)goal_id;
        GateFiction("Nous_DecomposePlan");
        return {};
    }

private:
    Nous() = default;
};

}  // namespace RawrXD::Autonomy

extern "C" bool Nous_IngestGoal(const char* goal_id, const char* description)
{
    if (!goal_id || !description)
    {
        return false;
    }
    return RawrXD::Autonomy::Nous::GetInstance().IngestGoal(goal_id, description);
}

extern "C" void* Nous_DecomposePlan(const char* goal_id)
{
    (void)goal_id;
    char buf[224];
    wsprintfA(buf, "[Nous] FEATURE_FICTION=1 FAIL_CLOSED name=Nous_DecomposePlan_C\n");
    OutputDebugStringA(buf);
    return nullptr;
}

extern "C" void Nous_FreeDecomposedPlan(void* opaque_steps)
{
    auto* steps = static_cast<std::vector<RawrXD::Autonomy::PlanStep>*>(opaque_steps);
    delete steps;
}
