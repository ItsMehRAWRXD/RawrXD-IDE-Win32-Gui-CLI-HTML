// ============================================================================
// RawrXD Win32IDE Hotpatch Integration - Phase 5 Implementation
// AUDIT_002_OPENISH_OTHER_DRAIN_008:
// Prior: Initialize invent m_running=true; RequestHotpatch invent path-as-token success (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include "Win32IDE_HotpatchIntegration.hpp"
#include "Win32IDE.h"
#include "../cli/gguf_validator.hpp"
#include <cstdio>
#include <chrono>

namespace RawrXD {

// External router functions from MASM
extern "C" {
    uint64_t RawrXD_RequestHotpatch(void* modelDescriptor, uint64_t gpuFence);
    uint64_t RawrXD_CheckEpochSwap();
    uint64_t RawrXD_GetEpochCounter();
    uint64_t RawrXD_IsSwapPending();
    uint64_t RawrXD_GetActiveEpochSlot();
}

// ============================================================================
// IDEHotpatchIntegration Implementation
// ============================================================================

IDEHotpatchIntegration& IDEHotpatchIntegration::Instance() {
    static IDEHotpatchIntegration instance;
    return instance;
}

void IDEHotpatchIntegration::Initialize(Win32IDE* ide) {
    std::lock_guard<std::mutex> lock(m_mutex);
    (void)ide;
    // Was: invent m_running=true + monitor thread without hotpatch wire.
    m_ide = nullptr;
    m_running = false;
    printf("[IDEHotpatchIntegration] FEATURE_FICTION=1 FAIL_CLOSED Initialize (no invent running PASS)\n");
}

void IDEHotpatchIntegration::Shutdown() {
    m_running = false;
    if (m_monitorThread.joinable()) {
        m_monitorThread.join();
    }
    printf("[IDEHotpatchIntegration] Shutdown complete\n");
}

bool IDEHotpatchIntegration::RequestHotpatch(const std::string& modelPath) {
    (void)modelPath;
    // Was: invent path-as-token RawrXD_RequestHotpatch success (fake-ready).
    printf("[IDEHotpatchIntegration] FEATURE_FICTION=1 FAIL_CLOSED RequestHotpatch (no invent PASS)\n");
    m_hotpatchInProgress = false;
    return false;
}

bool IDEHotpatchIntegration::IsHotpatchInProgress() const {
    return m_hotpatchInProgress.load();
}

std::string IDEHotpatchIntegration::GetActiveModelPath() const {
    std::lock_guard<std::mutex> lock(m_mutex);
    return m_activeModelPath;
}

std::string IDEHotpatchIntegration::GetPendingModelPath() const {
    std::lock_guard<std::mutex> lock(m_mutex);
    return m_pendingModelPath;
}

// Phase 6.6: Query active architecture from inference context
std::string IDEHotpatchIntegration::GetActiveArchitecture() const {
    // Query the active inference context from the model registry
    // Returns the architecture of the currently loaded model
    std::lock_guard<std::mutex> lock(m_mutex);
    
    // Extract architecture from active model path or use default
    if (!m_activeModelPath.empty()) {
        // Parse model path for architecture hints
        std::string path = m_activeModelPath;
        std::transform(path.begin(), path.end(), path.begin(), ::tolower);
        
        if (path.find("llama") != std::string::npos) return "llama";
        if (path.find("qwen") != std::string::npos) return "qwen";
        if (path.find("mistral") != std::string::npos) return "mistral";
        if (path.find("mixtral") != std::string::npos) return "mixtral";
        if (path.find("gemma") != std::string::npos) return "gemma";
        if (path.find("phi") != std::string::npos) return "phi";
    }
    
    // Default to llama architecture
    return "llama";
}

IDEHotpatchIntegration::Status IDEHotpatchIntegration::GetStatus() const {
    std::lock_guard<std::mutex> lock(m_mutex);
    Status status;
    status.epoch = RawrXD_GetEpochCounter();
    status.swapPending = RawrXD_IsSwapPending() != 0;
    status.activeModel = m_activeModelPath;
    status.pendingModel = m_pendingModelPath;
    return status;
}

void IDEHotpatchIntegration::SetHotpatchCompleteCallback(HotpatchCompleteCallback cb) {
    std::lock_guard<std::mutex> lock(m_mutex);
    m_completeCallback = cb;
}

void IDEHotpatchIntegration::MonitorThread() {
    printf("[IDEHotpatchIntegration] Monitor thread started\n");
    
    while (m_running.load()) {
        // Check for swap completion
        if (m_hotpatchInProgress.load()) {
            RawrXD_CheckEpochSwap();
            
            // Check if swap is no longer pending
            if (RawrXD_IsSwapPending() == 0) {
                // Swap completed
                std::string completedPath;
                {
                    std::lock_guard<std::mutex> lock(m_mutex);
                    completedPath = m_pendingModelPath;
                    m_activeModelPath = completedPath;
                    m_pendingModelPath.clear();
                    m_hotpatchInProgress = false;
                }
                
                printf("[IDEHotpatchIntegration] Hotpatch completed: %s\n", completedPath.c_str());
                NotifyHotpatchComplete(completedPath, true);
            }
        }
        
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
    
    printf("[IDEHotpatchIntegration] Monitor thread exiting\n");
}

void IDEHotpatchIntegration::NotifyHotpatchComplete(const std::string& path, bool success) {
    std::lock_guard<std::mutex> lock(m_mutex);
    if (m_completeCallback) {
        m_completeCallback(path, success);
    }
    
    // Also notify IDE via window message if available
    if (m_ide && m_ide->m_hwnd) {
        // Post message to IDE window for UI updates
        // WM_USER + 0x700 = Hotpatch complete
        PostMessage(m_ide->m_hwnd, WM_USER + 0x700, success ? 1 : 0, (LPARAM)path.c_str());
    }
}

} // namespace RawrXD

// ============================================================================
// C API Implementation
// ============================================================================

extern "C" {

void RawrXD_IDE_OnHotpatchComplete(const char* modelPath, int success) {
    printf("[C API] Hotpatch complete: %s (success=%d)\n", modelPath ? modelPath : "null", success);
    
    if (modelPath) {
        RawrXD::IDEHotpatchIntegration::Instance().NotifyHotpatchComplete(modelPath, success != 0);
    }
}

const char* RawrXD_IDE_GetActiveModelPath() {
    static std::string path;
    path = RawrXD::IDEHotpatchIntegration::Instance().GetActiveModelPath();
    return path.c_str();
}

} // extern "C"

#pragma comment(linker, "/EXPORT:RawrXD_IDE_OnHotpatchComplete")
#pragma comment(linker, "/EXPORT:RawrXD_IDE_GetActiveModelPath")
