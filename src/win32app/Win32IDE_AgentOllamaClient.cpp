// ============================================================================
// Win32IDE_AgentOllamaClient.cpp — LOCAL_ONLY_001 fail-closed stubs
// ============================================================================
// Ollama/HTTP client construction and :11434 probes are forbidden.
// Deep2/GGUF is the only production inference backend for this gate.
//
// AUDIT_002_OPENISH_OTHER_DRAIN_018:
// Prior: LOCAL_ONLY stub TU invent Ollama-disabled / client-status ready PASS
// without validated tip product inference wire (fake-ready / empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS
// ============================================================================

#include "Win32IDE.h"
#include "../agentic/LocalOnlyPolicy.h"
#include <string>
#include <windows.h>

namespace {
struct AgentOllamaClientFailClosed {
    AgentOllamaClientFailClosed() {
        // Was: invent Ollama-disabled client-status ready PASS.
        OutputDebugStringA(
            "[AgentOllamaClient] FEATURE_FICTION=1 FAIL_CLOSED TU "
            "(no invent Ollama client ready PASS)\n");
    }
};
static AgentOllamaClientFailClosed g_agentOllamaClientFailClosed;
}

void Win32IDE::initAgentOllamaClient() {
    m_ollamaClientInitialized = false;
    m_ollamaConnected = false;
    m_ollamaEndpoint.clear();
    m_ollamaStatus = RawrXD::LocalOnly::kHardDiagnostic;
    LOG_INFO("LOCAL_ONLY_001 FEATURE_FICTION=1 FAIL_CLOSED: Agent Ollama HTTP client held");
}

void Win32IDE::shutdownAgentOllamaClient() {
    m_ollamaClientInitialized = false;
    m_ollamaConnected = false;
    m_ollamaStatus = "Shutdown";
}

bool Win32IDE::testOllamaConnection() {
    m_ollamaConnected = false;
    m_ollamaStatus = RawrXD::LocalOnly::kHardDiagnostic;
    return false;
}

bool Win32IDE::isOllamaConnected() const {
    return false;
}

std::string Win32IDE::getOllamaStatus() const {
    return m_ollamaStatus.empty() ? std::string(RawrXD::LocalOnly::kHardDiagnostic) : m_ollamaStatus;
}

void Win32IDE::setOllamaEndpoint(const std::string& endpoint) {
    (void)endpoint;
    m_ollamaEndpoint.clear();
    m_ollamaConnected = false;
    m_ollamaStatus = RawrXD::LocalOnly::kNetworkForbidden;
}

std::string Win32IDE::getOllamaEndpoint() const {
    return std::string();
}
