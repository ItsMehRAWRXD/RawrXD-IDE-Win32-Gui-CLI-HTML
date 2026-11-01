// Win32IDE sovereign GPU link stubs.
// Purpose: keep RawrXD-Win32IDE linkable when RAWR_HAS_SOVEREIGN_ENGINES=0.
//
// AUDIT_002_OPENISH_OTHER_DRAIN_002:
// Prior: synthetic non-zero driver/version/alloc/telemetry invent PASS when
// engines=0 (fake-ready GPU).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — symbols remain for link; invent != ready.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD NOT_RUN!=PASS
// RELINK owned by sibling — SOURCE_WIRE only this seal.

#include <cstdint>
#include <atomic>

#include <windows.h>

#if !defined(RAWR_HAS_SOVEREIGN_ENGINES) || (RAWR_HAS_SOVEREIGN_ENGINES == 0)

extern "C"
{

    namespace {
    std::atomic<uint64_t> g_totalCalls{0};
    std::atomic<uint64_t> g_authFail{0};

    void GateFiction(const char* name)
    {
        char buf[224];
        wsprintfA(buf,
            "[SovereignGPUImpl] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
        OutputDebugStringA(buf);
    }
    }  // namespace

    uint64_t KFD_Get_Driver_Version()
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        // Was: invent synthetic non-zero version (1.2.3|rev).
        GateFiction("KFD_Get_Driver_Version");
        return 0;
    }

    void KFD_Ring_Hardware_Doorbell()
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        GateFiction("KFD_Ring_Hardware_Doorbell");
    }

    void RDNA3_Shadow_Pager_Init()
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        GateFiction("RDNA3_Shadow_Pager_Init");
    }

    void RDNA3_Power_Pulse()
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        GateFiction("RDNA3_Power_Pulse");
    }

    void RDNA3_Speculative_Preload()
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        GateFiction("RDNA3_Speculative_Preload");
    }

    void Neural_Entropy_Generate()
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        GateFiction("Neural_Entropy_Generate");
    }

    uint64_t RDNA3_MMIO_Read(uint64_t)
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        GateFiction("RDNA3_MMIO_Read");
        return 0;
    }

    uint64_t RDNA3_Telemetry_Read()
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        GateFiction("RDNA3_Telemetry_Read");
        return 0;
    }

    uint64_t RDNA3_HugePage_Allocate()
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        GateFiction("RDNA3_HugePage_Allocate");
        return 0;  // Was: synthetic 2MB-aligned token invent.
    }

    uint64_t RDNA3_3X_Virtualize(uint64_t)
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        GateFiction("RDNA3_3X_Virtualize");
        return 0;
    }

    uint64_t RDNA3_Elastic_Scale(uint64_t)
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        GateFiction("RDNA3_Elastic_Scale");
        return 0;
    }

    void RDNA3_Sovereign_Deflate(uint8_t* /*begin*/, uint8_t* /*end*/)
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        GateFiction("RDNA3_Sovereign_Deflate");
    }

    void RDNA3_3x_Expand(uint8_t* /*begin*/, uint8_t* /*end*/)
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        GateFiction("RDNA3_3x_Expand");
    }

    void RDNA3_Custom_Inflate(uint8_t* /*begin*/, uint8_t* /*end*/)
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        GateFiction("RDNA3_Custom_Inflate");
    }

    uint64_t Silicon_PUF_Generate()
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        GateFiction("Silicon_PUF_Generate");
        return 0;
    }

    bool RDNA3_Silicon_Authenticate(uint64_t /*signature*/)
    {
        g_totalCalls.fetch_add(1, std::memory_order_relaxed);
        g_authFail.fetch_add(1, std::memory_order_relaxed);
        GateFiction("RDNA3_Silicon_Authenticate");
        return false;
    }

    uint64_t RDNA3_Fallback_GetStats()
    {
        const uint64_t total = g_totalCalls.load(std::memory_order_relaxed) & 0xFFu;
        const uint64_t fail = g_authFail.load(std::memory_order_relaxed) & 0xFFFFu;
        return total | (fail << 48);
    }

    uint64_t RDNA3_Fallback_GetStatsEx()
    {
        return RDNA3_Fallback_GetStats();
    }

    void RDNA3_Fallback_ResetStats()
    {
        g_totalCalls.store(0, std::memory_order_relaxed);
        g_authFail.store(0, std::memory_order_relaxed);
    }

}  // extern "C"

#endif
