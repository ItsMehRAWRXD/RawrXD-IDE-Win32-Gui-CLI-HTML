#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>

/**
 * @file Win32IDE_MemoryStats.cpp
 * @brief Batch 3 (24/118): Global Memory Statistics.
 *
 * AUDIT_002_OPENISH_OTHER_DRAIN_009:
 * Prior: Stats_GetVRAMUsage invent return 0 empty-true (fake-ready healthy VRAM).
 * Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
 * PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
 */

namespace RawrXD::Memory::Stats {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf, "[MemoryStats] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

// Resolves: Stats_GetUsage
extern "C" void Stats_GetUsage(uint64_t* out_total, uint64_t* out_used) {
    MEMORYSTATUSEX memInfo;
    memInfo.dwLength = sizeof(MEMORYSTATUSEX);
    GlobalMemoryStatusEx(&memInfo);
    
    if (out_total) *out_total = memInfo.ullTotalPhys;
    if (out_used) *out_used = memInfo.ullTotalPhys - memInfo.ullAvailPhys;
}

// Resolves: Stats_GetVRAMUsage
extern "C" uint64_t Stats_GetVRAMUsage() {
    // Was: invent return 0 without DXGI/Vulkan query (fake-ready healthy VRAM).
    GateFiction("Stats_GetVRAMUsage");
    return UINT64_MAX;
}

} // namespace RawrXD::Memory::Stats
