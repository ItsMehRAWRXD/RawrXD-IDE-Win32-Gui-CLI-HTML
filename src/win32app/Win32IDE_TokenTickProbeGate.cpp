// IDE link gate: token-per-tick harness entry points (Lane H).
//
// AUDIT_002_OPENISH_OTHER_DRAIN_017:
// Prior: HasFlag true-path + Run return-2 invent token-tick probe gate ready
// PASS without validated harness/product wire (fake-ready / empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include "Win32IDE_TokenTickProbe.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <windows.h>

bool HasTokenTickFlag(const char* cmdLine)
{
    auto matches = [](const char* text)
    {
        return text != nullptr && (std::strstr(text, "--token-tick-probe") != nullptr ||
                                   std::strstr(text, "--token-tick-telemetry") != nullptr);
    };
    if (matches(cmdLine) || matches(GetCommandLineA()))
    {
        // Was: invent flag-matched token-tick probe-ready PASS.
        OutputDebugStringA(
            "[token-tick] FEATURE_FICTION=1 FAIL_CLOSED HasTokenTickFlag "
            "(no invent token-tick-probe ready PASS)\n");
        return false;
    }
    return false;
}

int RunTokenTickProbe(const char* /*telemetryPath*/, std::uint64_t /*expectedQuietZoneVa*/, int /*cycles*/,
                      std::uint32_t /*tickHz*/, std::uint32_t /*nominalTps*/, std::uint32_t /*draftAcceptRatePermille*/)
{
    OutputDebugStringA(
        "[token-tick] FEATURE_FICTION=1 FAIL_CLOSED RunTokenTickProbe "
        "(no invent token-tick-probe ready PASS)\n");
    fprintf(stderr, "[token-tick] FEATURE_FICTION=1 FAIL_CLOSED — invent ready held\n");
    return 2;
}
