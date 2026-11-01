#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>

/**
 * @file Win32IDE_SettingsEvents.cpp
 * @brief Batch 2 (14/118): Settings/Config UI to Agent Event Handlers.
 *
 * AUDIT_002_OPENISH_OTHER_DRAIN_008:
 * Prior: Settings_OnConfigChanged invent Mnemosyne persist success; Reset LOG-only (empty-true).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

namespace RawrXD::UI::Settings {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[Settings] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

extern "C" bool Settings_OnConfigChanged(const char* key, const char* value) {
    (void)key;
    (void)value;
    GateFiction("Settings_OnConfigChanged");
    return false;
}

extern "C" void Settings_OnResetToDefaults() {
    GateFiction("Settings_OnResetToDefaults");
}

} // namespace RawrXD::UI::Settings
