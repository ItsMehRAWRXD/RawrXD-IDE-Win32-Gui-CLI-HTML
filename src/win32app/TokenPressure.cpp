// TokenPressure.cpp — host adapter over TOKEN_PRESSURE_VALVE_001 drop (no local MASM).
//
// AUDIT_002_OPENISH_OTHER_DRAIN_010:
// Prior: ProcessStartup invent g_ready=true after TPV_InitState without valve wire
// verify (fake-ready). Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
#include "TokenPressure.hpp"
#include "RawrXD_TokenPressureValve.hpp"
#include "RawrXD_TokenPressureValveBridge.hpp"

#include <cstring>
#include <windows.h>

static TPV_State g_tpv = {};
static bool g_ready = false;

namespace token_pressure {

void ProcessStartup() noexcept
{
    // Was: invent g_ready=true after TPV_InitState without valve product wire.
    std::memset(&g_tpv, 0, sizeof(g_tpv));
    g_ready = false;
    OutputDebugStringA(
        "[TokenPressure] FEATURE_FICTION=1 FAIL_CLOSED ProcessStartup "
        "(no invent g_ready PASS)\n");
}

void SetSpray(SprayMode mode) noexcept
{
    (void)mode;
    if (!g_ready)
        return;
    TPV_SetMode(&g_tpv, static_cast<uint32_t>(mode));
}

ValveAction OnUtf8Chunk(const char* utf8, std::size_t bytes) noexcept
{
    if (!utf8 || bytes == 0)
        return ValveAction::Pass;
    // Was: auto ProcessStartup invent ready then TPV_UpdateUtf8Token theater.
    if (!g_ready)
        return ValveAction::Pass;
    return ValveAction::Pass;
}

void ObserveTerminalError() noexcept
{
    // Was: SetSpray + invent TPV_UpdateToken without ready wire.
    if (!g_ready)
        return;
}

}  // namespace token_pressure
