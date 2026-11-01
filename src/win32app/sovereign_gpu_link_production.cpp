// sovereign_gpu_link_production.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_001:
// Prior: "Provides real Sovereign GPU" claimed init/submit/wait/device success
// with flag-only / empty-true bodies (no device).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include <windows.h>
#include <stdint.h>
#include <stdbool.h>
#include <atomic>
#include <mutex>

namespace RawrXD {
namespace SovereignGPU {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[SovereignGPUProduction] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

class SovereignGPULink {
public:
    static SovereignGPULink& Instance() {
        static SovereignGPULink instance;
        return instance;
    }

    bool Initialize() {
        // Was: initialized_=true; return true; (no device open).
        GateFiction("Initialize");
        return false;
    }

    void Shutdown() {
        std::lock_guard<std::mutex> lock(mutex_);
        initialized_ = false;
        deviceHandle_ = nullptr;
    }

    bool IsInitialized() const {
        return initialized_;
    }

    bool SubmitWork(void* /*workData*/, size_t /*size*/) {
        GateFiction("SubmitWork");
        return false;
    }

    bool WaitForCompletion(uint32_t /*timeoutMs*/) {
        GateFiction("WaitForCompletion");
        return false;
    }

    bool GetDeviceInfo(char* /*info*/, size_t /*infoSize*/) {
        // Was: invent "Sovereign GPU Device" string and return true.
        GateFiction("GetDeviceInfo");
        return false;
    }

private:
    SovereignGPULink() = default;
    ~SovereignGPULink() {
        Shutdown();
    }

    mutable std::mutex mutex_;
    bool initialized_ = false;
    void* deviceHandle_ = nullptr;
};

extern "C" {

bool RawrXD_SovereignGPU_Initialize() {
    return SovereignGPULink::Instance().Initialize();
}

void RawrXD_SovereignGPU_Shutdown() {
    SovereignGPULink::Instance().Shutdown();
}

bool RawrXD_SovereignGPU_IsInitialized() {
    return SovereignGPULink::Instance().IsInitialized();
}

bool RawrXD_SovereignGPU_SubmitWork(void* workData, size_t size) {
    return SovereignGPULink::Instance().SubmitWork(workData, size);
}

bool RawrXD_SovereignGPU_WaitForCompletion(uint32_t timeoutMs) {
    return SovereignGPULink::Instance().WaitForCompletion(timeoutMs);
}

bool RawrXD_SovereignGPU_GetDeviceInfo(char* info, size_t infoSize) {
    return SovereignGPULink::Instance().GetDeviceInfo(info, infoSize);
}

void SovereignGPULinkFallbackStub() {
    // Kept for binary compatibility
}

} // extern "C"

} // namespace SovereignGPU
} // namespace RawrXD
