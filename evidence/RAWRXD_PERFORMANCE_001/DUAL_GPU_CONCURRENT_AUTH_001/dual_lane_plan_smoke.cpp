/* dual_lane_plan_smoke.cpp — ApplyPolicy DUAL_LANE openCount witness. */
#include "../../../src/deep2/Deep2DeviceManager.hpp"
#include <cstdio>
#ifdef _WIN32
#include <windows.h>
#endif

int main() {
#ifdef _WIN32
    SetEnvironmentVariableA("RAWRXD_GPU_POLICY", "DUAL_LANE");
    SetEnvironmentVariableA("DEEP2_GPU_POLICY", "DUAL_LANE");
    _putenv_s("RAWRXD_GPU_POLICY", "DUAL_LANE");
    _putenv_s("DEEP2_GPU_POLICY", "DUAL_LANE");
#endif
    Deep2::DeviceManagerSnapshot snap{};
    const int en = Deep2::Deep2Device_Enumerate(snap) ? 1 : 0;
    const int pol = Deep2::Deep2Device_ApplyPolicy(snap) ? 1 : 0;
    Deep2::Deep2Device_EmitWitnesses(nullptr, snap);
    std::printf("ENUM=%d POLICY_OK=%d OPEN_COUNT=%u MODE=%u REASON=%s\n", en,
                pol, snap.plan.openCount, (unsigned)snap.plan.mode,
                snap.plan.reason);
    if (snap.plan.openCount >= 2) {
        const int i0 = snap.plan.openIndexes[0];
        const int i1 = snap.plan.openIndexes[1];
        std::printf("OPEN0=%s\nOPEN1=%s\n", snap.devices[i0].name,
                    snap.devices[i1].name);
    }
    const int dual =
        snap.plan.mode == Deep2::ExecMode::DualSovereign &&
        snap.plan.openCount >= 2;
    std::printf("DUAL_LANE_PLAN=%s\nPROMOTE=0\n", dual ? "PASS" : "FAIL");
    return dual ? 0 : 1;
}
