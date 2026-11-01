#include "Win32IDE_AgentExecutor.h"
#include "gguf_loader.h"
#include <windows.h>
#include <string>
#include <vector>
#include <memory>

// AUDIT_002_OPENISH_OTHER_DRAIN_001:
// Prior: Initialize/ExecuteAgentTask comment-only return true (empty-true theater).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[AgentExecutor] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

Win32IDE_AgentExecutor::Win32IDE_AgentExecutor() {
    loader_ = std::make_unique<GGUFLoader>();
}

Win32IDE_AgentExecutor::~Win32IDE_AgentExecutor() {
}

bool Win32IDE_AgentExecutor::Initialize() {
    // Was: return true with comment only.
    GateFiction("Initialize");
    return false;
}

bool Win32IDE_AgentExecutor::ExecuteAgentTask(const std::string& /*taskName*/,
                                              const std::vector<std::string>& /*params*/) {
    // Was: return true without executing any agent task.
    GateFiction("ExecuteAgentTask");
    return false;
}

bool Win32IDE_AgentExecutor::LoadModel(const std::string& modelPath) {
    if (!loader_) {
        return false;
    }
    return loader_->Load(modelPath);
}

void Win32IDE_AgentExecutor::Cleanup() {
    if (loader_) {
        loader_->Unload();
    }
}
