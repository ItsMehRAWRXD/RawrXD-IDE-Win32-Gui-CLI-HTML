// AUDIT_002_OPENISH_OTHER_DRAIN_018:
// Prior: "Batch 3 Tensor Buffer Lifecycle" + "3.43M TPS" invent Tensor buffer
// product ready PASS via thin _aligned_malloc without validated tip MASM kernel
// wire (fake-ready / empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>

namespace {
struct TensorBuffersFailClosed {
    TensorBuffersFailClosed() {
        // Was: invent Tensor buffer lifecycle ready PASS (thin malloc fiction).
        OutputDebugStringA(
            "[TensorBuffers] FEATURE_FICTION=1 FAIL_CLOSED TU "
            "(no invent Tensor buffer lifecycle ready PASS)\n");
    }
};
static TensorBuffersFailClosed g_tensorBuffersFailClosed;
}

namespace RawrXD::Memory {

// Resolves: Tensor_AllocateAligned
extern "C" void* Tensor_AllocateAligned(size_t size, size_t alignment) {
    // Was: invent 3.43M TPS SIMD alignment product ready.
    void* ptr = _aligned_malloc(size, alignment);
    if (!ptr) {
        LOG_ERROR("[Tensor] FEATURE_FICTION=1 FAIL_CLOSED aligned alloc held.");
    }
    return ptr;
}

// Resolves: Tensor_Free
extern "C" void Tensor_Free(void* ptr) {
    if (ptr) {
        _aligned_free(ptr);
    }
}

} // namespace RawrXD::Memory
