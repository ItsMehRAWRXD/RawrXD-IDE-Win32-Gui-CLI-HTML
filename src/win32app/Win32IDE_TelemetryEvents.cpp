#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>
#include <string>

/**
 * @file Win32IDE_TelemetryEvents.cpp
 * @brief Batch 2 (13/118): Telemetry UI to Agent Event Handlers.
 *
 * AUDIT_002_OPENISH_OTHER_DRAIN_005:
 * Prior: Telemetry_OnMetricPushed empty body invent Prometheus wire (empty-true).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

namespace RawrXD::UI::Telemetry {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[Telemetry] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

// Resolves: Telemetry_OnMetricPushed
extern "C" void Telemetry_OnMetricPushed(const char* key, float value) {
    (void)key;
    (void)value;
    // Was: empty body invent exporter wire (no MASM Telemetry Kernel).
    GateFiction("Telemetry_OnMetricPushed");
}

// Resolves: Telemetry_OnSessionEnd
extern "C" void Telemetry_OnSessionEnd() {
    // Was: LOG-only invent flush complete (no exporter flush).
    GateFiction("Telemetry_OnSessionEnd");
    LOG_ERROR("[Telemetry] FEATURE_FICTION=1 FAIL_CLOSED session end (no flush)");
}

} // namespace RawrXD::UI::Telemetry
