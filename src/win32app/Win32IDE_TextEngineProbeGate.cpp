// IDE link gate: main_win32 references probe entry points; use RawrXD-TextEngineHarness for benchmarks.
//
// AUDIT_002_OPENISH_OTHER_DRAIN_017:
// Prior: HasFlag true-path + Run return-2 invent text-engine probe gate ready
// PASS without validated harness/product wire (fake-ready / empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include "Win32IDE_TextEngineProbe.h"

#include <cstdio>
#include <cstring>
#include <windows.h>

bool HasTextEngineProbeFlag(const char* cmdLine)
{
    auto matches = [](const char* text)
    {
        return text != nullptr && (std::strstr(text, "--text-engine-telemetry") != nullptr ||
                                   std::strstr(text, "--text-engine-invalidation-telemetry") != nullptr ||
                                   std::strstr(text, "--text-engine-probe") != nullptr);
    };
    if (matches(cmdLine) || matches(GetCommandLineA()))
    {
        // Was: invent flag-matched text-engine probe-ready PASS.
        OutputDebugStringA(
            "[text-engine] FEATURE_FICTION=1 FAIL_CLOSED HasTextEngineProbeFlag "
            "(no invent text-engine-probe ready PASS)\n");
        return false;
    }
    return false;
}

int RunTextEngineProbe(const char* /*telemetryPath*/, int /*cycles*/)
{
    OutputDebugStringA(
        "[text-engine] FEATURE_FICTION=1 FAIL_CLOSED RunTextEngineProbe "
        "(no invent text-engine-probe ready PASS)\n");
    fprintf(stderr, "[text-engine] FEATURE_FICTION=1 FAIL_CLOSED — invent ready held\n");
    return 2;
}

int RunTextEngineInvalidationProbe(const char* /*telemetryPath*/, int /*cycles*/)
{
    OutputDebugStringA(
        "[text-engine] FEATURE_FICTION=1 FAIL_CLOSED RunTextEngineInvalidationProbe "
        "(no invent invalidation-probe ready PASS)\n");
    fprintf(stderr, "[text-engine] FEATURE_FICTION=1 FAIL_CLOSED — invent ready held\n");
    return 2;
}
