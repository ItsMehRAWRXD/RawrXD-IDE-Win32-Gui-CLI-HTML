// Compiled when RAWRXD_ENABLE_IDE_PROBE_GATES=OFF — satisfies main_win32 probe symbols without harness TUs.
//
// AUDIT_002_OPENISH_OTHER_DRAIN_017:
// Prior: empty false/2 returns invent probe-gates-disabled product complete
// ready PASS without validated product wire (fake-ready / empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include "Win32IDE_KVApertureProbe.h"
#include "Win32IDE_TextEngineProbe.h"
#include "Win32IDE_TokenTickProbe.h"
#include "sovereign/sovereign_smoketests.h"

#include <cstdint>
#include <windows.h>

namespace {
struct ProbeGatesDisabledFailClosed {
    ProbeGatesDisabledFailClosed() {
        // Was: invent probe-gates-disabled complete ready PASS (empty false TU).
        OutputDebugStringA(
            "[ProbeGatesDisabled] FEATURE_FICTION=1 FAIL_CLOSED TU "
            "(no invent probe-gates-disabled ready PASS)\n");
    }
};
static ProbeGatesDisabledFailClosed g_probeGatesDisabledFailClosed;
}

bool HasKVApertureProbeFlag(const char*)
{
    return false;
}

int RunKVApertureProbe(const char*, std::uint64_t, int, std::uint64_t)
{
    return 2;
}

bool HasTextEngineProbeFlag(const char*)
{
    return false;
}

int RunTextEngineProbe(const char*, int)
{
    return 2;
}

bool HasTokenTickFlag(const char*)
{
    return false;
}

int RunTokenTickProbe(const char*, std::uint64_t, int, std::uint32_t, std::uint32_t, std::uint32_t)
{
    return 2;
}

namespace RawrXD::Tests
{

int RunSmoketests(const wchar_t*)
{
    return 2;
}

}  // namespace RawrXD::Tests
