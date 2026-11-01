#include "Win32IDE.h"
#include "IDELogger.h"
#include <windows.h>
#include <cstdint>

/**
 * @file Win32IDE_RingBuffer.cpp
 * @brief Batch 3 (21/118): High-Velocity Command Ring Buffer.
 * Lock-free queue interface for MASM-to-C++ event dispatch.
 */

namespace RawrXD::Memory::Queue {

namespace {

constexpr uint32_t kOpcodeToken = 0x544F4B4Eu; // 'TOKN'

struct RingHeader {
    volatile LONG capacity;
    volatile LONG writeIdx;
    volatile LONG readIdx;
};

struct RingSlot {
    uint32_t op;
    uint64_t payload;
};

bool RingPushInternal(void* buffer, uint32_t opcode, uint64_t payload) {
    if (!buffer) {
        return false;
    }

    auto* hdr = static_cast<RingHeader*>(buffer);
    if (hdr->capacity <= 0) {
        return false;
    }

    const LONG cur = InterlockedCompareExchange(&hdr->writeIdx, 0, 0);
    const LONG next = (cur + 1) % hdr->capacity;
    if (next == InterlockedCompareExchange(&hdr->readIdx, 0, 0)) {
        return false;
    }

    auto* slots = reinterpret_cast<RingSlot*>(hdr + 1);
    slots[cur].op = opcode;
    slots[cur].payload = payload;
    MemoryBarrier();
    InterlockedExchange(&hdr->writeIdx, next);
    return true;
}

} // namespace

// Resolves: Ring_Initialize
// AUDIT_002_OPENISH_OTHER_DRAIN_014:
// Prior: Ring_Initialize invent header capacity + return true +
// "Initializing lock-free command queue" as ring product ready PASS without
// validated MASM-to-C++ dispatch product wire (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
extern "C" bool Ring_Initialize(void* buffer, size_t size) {
    (void)buffer;
    (void)size;
    // Was: invent capacity/writeIdx/readIdx + return true ready PASS.
    LOG_INFO("[Ring] FEATURE_FICTION=1 FAIL_CLOSED Ring_Initialize "
             "(no invent ring ready PASS)");
    OutputDebugStringA(
        "[Ring] FEATURE_FICTION=1 FAIL_CLOSED Ring_Initialize "
        "(no invent ring ready PASS)\n");
    return false;
}

// Resolves: Ring_PushCommand
extern "C" void Ring_PushCommand(void* buffer, uint32_t opcode, void* data) {
    (void)RingPushInternal(buffer, opcode, reinterpret_cast<uint64_t>(data));
}

extern "C" bool Ring_PushToken(void* buffer, int token_id) {
    return RingPushInternal(buffer, kOpcodeToken, static_cast<uint64_t>(static_cast<uint32_t>(token_id)));
}

extern "C" bool Ring_PopCommand(void* buffer, uint32_t* opcode, void** data) {
    if (!buffer || !opcode || !data) {
        return false;
    }

    auto* hdr = static_cast<RingHeader*>(buffer);
    if (hdr->capacity <= 0) {
        return false;
    }

    const LONG read = InterlockedCompareExchange(&hdr->readIdx, 0, 0);
    const LONG write = InterlockedCompareExchange(&hdr->writeIdx, 0, 0);
    if (read == write) {
        return false;
    }

    auto* slots = reinterpret_cast<RingSlot*>(hdr + 1);
    const RingSlot slot = slots[read];
    MemoryBarrier();
    const LONG next = (read + 1) % hdr->capacity;
    InterlockedExchange(&hdr->readIdx, next);

    *opcode = slot.op;
    *data = reinterpret_cast<void*>(slot.payload);
    return true;
}

} // namespace RawrXD::Memory::Queue
