// IDE link gate: main_win32 references KV aperture probe entry points.
// Full Vulkan aperture harness lives in dedicated tools; IDE build uses no-op gate.
//
// AUDIT_002_OPENISH_OTHER_DRAIN_017:
// Prior: HasFlag true-path + Run return-2 invent KV aperture probe gate ready
// PASS without validated harness/product wire (fake-ready / empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include "Win32IDE_KVApertureProbe.h"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <windows.h>

bool HasKVApertureProbeFlag(const char* cmdLine)
{
    auto matches = [](const char* text)
    {
        return text != nullptr && (std::strstr(text, "--kv-aperture-probe") != nullptr ||
                                   std::strstr(text, "--kv-aperture-telemetry") != nullptr);
    };
    if (matches(cmdLine) || matches(GetCommandLineA()))
    {
        // Was: invent flag-matched probe-ready PASS (then Run returns 2).
        OutputDebugStringA(
            "[kv-aperture] FEATURE_FICTION=1 FAIL_CLOSED HasKVApertureProbeFlag "
            "(no invent aperture-probe ready PASS)\n");
        return false;
    }
    return false;
}

int RunKVApertureProbe(const char* /*telemetryPath*/, std::uint64_t /*expectedQuietZoneVa*/, int /*cycles*/,
                       std::uint64_t /*bytes*/)
{
    OutputDebugStringA(
        "[kv-aperture] FEATURE_FICTION=1 FAIL_CLOSED RunKVApertureProbe "
        "(no invent aperture-probe ready PASS)\n");
    fprintf(stderr, "[kv-aperture] FEATURE_FICTION=1 FAIL_CLOSED — invent ready held\n");
    return 2;
}
