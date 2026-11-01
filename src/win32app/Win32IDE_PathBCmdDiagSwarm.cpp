// PathB CMD_DIAG swarm engine — chat SOURCE_WIRE without FullAgenticBridge.
// ProductOpenSession on this worker __fastfail'd (A839 → 0xC0000409).
// CIE GetSharedInstance() may be null in GUI PathB — chatProvider alone is
// enough: AgenticEngine::chat prefers m_chatProvider. ENGINE_BIND ≠ invent PASS.
// Post-BOTH_COMPLETE: UI must skip CompilerIntegration/PS bringup (Core) and
// worker quiets LOG/METRICS before merge free (SubAgent) — FailFast race.
#include "Win32IDE_PathBCmdDiagSwarm.hpp"

#include "../agentic_engine.h"
#include "../cpu_inference_engine.h"

#include <atomic>
#include <mutex>
#include <string>

namespace RawrXD {
namespace Win32App {
namespace {

AgenticEngine g_pathbEngine;
std::once_flag g_pathbOnce;
std::mutex g_pathbChatMu;
std::atomic<int> g_pathbEngineBound{0};
std::atomic<int> g_pathbModelOpen{0};
std::atomic<int> g_pathbBodyDone{0};
std::atomic<unsigned> g_pathbCompleted{0};

void InitPathBEngineOnce() {
    g_pathbEngine.initialize();
    auto cpu = RawrXD::CPUInferenceEngine::GetSharedInstance();
    if (cpu)
        g_pathbEngine.setInferenceEngine(cpu.get());
    g_pathbEngine.setChatProvider([](const std::string& /*message*/) -> std::string {
        std::lock_guard<std::mutex> lock(g_pathbChatMu);
        if (g_pathbModelOpen.load() == 0)
            return "[Agent] No model loaded.";
        return "[error] PathB CMD_DIAG model open without infer wire";
    });
    // Chat provider is the SOURCE_WIRE for empty-merge close (non-empty strings).
    g_pathbEngineBound.store(1);
}

}  // namespace

AgenticEngine* EnsurePathBCmdDiagEngine(const char* modelPath) {
    (void)modelPath;
    std::call_once(g_pathbOnce, InitPathBEngineOnce);
    if (g_pathbEngineBound.load() == 0)
        return nullptr;
    return &g_pathbEngine;
}

bool PathBCmdDiagModelOpen() {
    return g_pathbModelOpen.load() != 0;
}

bool PathBCmdDiagEngineBound() {
    return g_pathbEngineBound.load() != 0;
}

void PathBCmdDiagMarkSwarmBodyDone(unsigned completed) {
    g_pathbCompleted.store(completed, std::memory_order_release);
    g_pathbBodyDone.store(1, std::memory_order_release);
}

bool PathBCmdDiagSwarmBodyDone() {
    return g_pathbBodyDone.load(std::memory_order_acquire) != 0;
}

unsigned PathBCmdDiagSwarmCompleted() {
    return g_pathbCompleted.load(std::memory_order_acquire);
}

}  // namespace Win32App
}  // namespace RawrXD
