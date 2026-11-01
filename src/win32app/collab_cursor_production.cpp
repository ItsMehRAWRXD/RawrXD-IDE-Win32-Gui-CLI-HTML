// collab_cursor_production.cpp
// AUDIT_002_OPENISH_OTHER_DRAIN_001:
// Prior: "Provides real collaborative cursor" claimed Initialize success with
// local-only flag (no session/wire). Sibling collab_cursor_impl already GATED.
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include <windows.h>
#include <stdint.h>
#include <stdbool.h>
#include <string>
#include <vector>
#include <mutex>
#include <unordered_map>

namespace RawrXD {
namespace Collab {

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[CollabCursorProduction] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

struct CursorPosition {
    uint32_t x;
    uint32_t y;
    uint32_t line;
    uint32_t column;
    uint64_t timestamp;
    uint32_t color;
    char username[64];
};

class CursorManager {
public:
    static CursorManager& Instance() {
        static CursorManager instance;
        return instance;
    }

    bool Initialize() {
        // Was: local flag + invent username; claimed production ready.
        GateFiction("Initialize");
        return false;
    }
    
    void Shutdown() {
        std::lock_guard<std::mutex> lock(mutex_);
        if (!initialized_) {
            return;
        }
        
        remoteCursors_.clear();
        initialized_ = false;
    }
    
    void UpdateLocalCursor(uint32_t line, uint32_t column) {
        std::lock_guard<std::mutex> lock(mutex_);
        if (!initialized_) {
            return;
        }
        
        localCursor_.line = line;
        localCursor_.column = column;
        localCursor_.timestamp = GetTickCount64();
    }
    
    void UpdateRemoteCursor(uint32_t peerID, const CursorPosition& pos) {
        std::lock_guard<std::mutex> lock(mutex_);
        if (!initialized_) {
            return;
        }
        
        remoteCursors_[peerID] = pos;
    }
    
    bool GetRemoteCursor(uint32_t peerID, CursorPosition* outPos) {
        std::lock_guard<std::mutex> lock(mutex_);
        if (!initialized_ || !outPos) {
            return false;
        }
        
        auto it = remoteCursors_.find(peerID);
        if (it != remoteCursors_.end()) {
            *outPos = it->second;
            return true;
        }
        
        return false;
    }
    
    void RemoveRemoteCursor(uint32_t peerID) {
        std::lock_guard<std::mutex> lock(mutex_);
        remoteCursors_.erase(peerID);
    }
    
    size_t GetRemoteCursorCount() const {
        std::lock_guard<std::mutex> lock(mutex_);
        return remoteCursors_.size();
    }
    
    void GetLocalCursor(CursorPosition* outPos) {
        std::lock_guard<std::mutex> lock(mutex_);
        if (outPos && initialized_) {
            *outPos = localCursor_;
        }
    }
    
    bool IsInitialized() const {
        return initialized_;
    }

private:
    CursorManager() = default;
    ~CursorManager() {
        Shutdown();
    }
    
    mutable std::mutex mutex_;
    bool initialized_ = false;
    CursorPosition localCursor_;
    std::unordered_map<uint32_t, CursorPosition> remoteCursors_;
};

extern "C" {

bool RawrXD_Cursor_Initialize() {
    return CursorManager::Instance().Initialize();
}

void RawrXD_Cursor_Shutdown() {
    CursorManager::Instance().Shutdown();
}

void RawrXD_Cursor_UpdateLocal(uint32_t line, uint32_t column) {
    CursorManager::Instance().UpdateLocalCursor(line, column);
}

void RawrXD_Cursor_UpdateRemote(uint32_t peerID, const void* pos) {
    if (pos) {
        CursorManager::Instance().UpdateRemoteCursor(peerID, 
            *(const CursorPosition*)pos);
    }
}

bool RawrXD_Cursor_GetRemote(uint32_t peerID, void* outPos) {
    return CursorManager::Instance().GetRemoteCursor(peerID, 
        (CursorPosition*)outPos);
}

void RawrXD_Cursor_RemoveRemote(uint32_t peerID) {
    CursorManager::Instance().RemoveRemoteCursor(peerID);
}

size_t RawrXD_Cursor_GetRemoteCount() {
    return CursorManager::Instance().GetRemoteCursorCount();
}

bool RawrXD_Cursor_IsInitialized() {
    return CursorManager::Instance().IsInitialized();
}

void CollabCursorFallbacksStub() {
    // Kept for binary compatibility
}

} // extern "C"

} // namespace Collab
} // namespace RawrXD
