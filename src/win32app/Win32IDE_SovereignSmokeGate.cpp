// IDE link gate: --sovereign-smoke CLI is handled by dedicated harness binaries.
//
// AUDIT_002_OPENISH_OTHER_DRAIN_017:
// Prior: RunSmoketests return-2 invent sovereign-smoke gate-linked ready PASS
// without validated harness/product wire (fake-ready / empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include "sovereign/sovereign_smoketests.h"

#include <cstdio>
#include <windows.h>

namespace RawrXD::Tests
{

int RunSmoketests(const wchar_t* /*journalPath*/)
{
    // Was: invent smoke-suite gate-linked ready PASS (return 2 theater).
    OutputDebugStringA(
        "[sovereign-smoke] FEATURE_FICTION=1 FAIL_CLOSED RunSmoketests "
        "(no invent sovereign-smoke ready PASS)\n");
    fprintf(stderr, "[sovereign-smoke] FEATURE_FICTION=1 FAIL_CLOSED — invent ready held\n");
    return 2;
}

}  // namespace RawrXD::Tests
