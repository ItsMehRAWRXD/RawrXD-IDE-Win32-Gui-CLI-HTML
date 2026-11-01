#if !defined(_MSC_VER)

#include "OSExplorerInterceptor.h"

#include <windows.h>

#include <memory>

// AUDIT_002_OPENISH_OTHER_DRAIN_007:
// Prior: StartInterception invent m_isRunning=true without hooks (empty-true).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

std::unique_ptr<OSExplorerInterceptor> g_osInterceptor = nullptr;

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[OSExplorer] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

OSExplorerInterceptor::OSExplorerInterceptor()
    : m_interceptor(nullptr),
      m_targetPID(0),
      m_hTargetProcess(nullptr),
      m_isRunning(false),
      m_callback(nullptr),
      m_stopLogThread(false) {}

OSExplorerInterceptor::~OSExplorerInterceptor() {
    m_isRunning = false;
    m_stopLogThread.store(true, std::memory_order_relaxed);
    if (m_logThread && m_logThread->joinable()) {
        m_logThread->join();
    }
    if (m_hTargetProcess) {
        CloseHandle(m_hTargetProcess);
        m_hTargetProcess = nullptr;
    }
}

bool OSExplorerInterceptor::Initialize(DWORD targetPID, OSInterceptorCallback callback) {
    (void)targetPID;
    (void)callback;
    // Was: OpenProcess then claim init without interceptor wire.
    GateFiction("OSExplorerInterceptor::Initialize");
    return false;
}

bool OSExplorerInterceptor::StartInterception() {
    // Was: invent m_isRunning=true without hooks/detours.
    GateFiction("OSExplorerInterceptor::StartInterception");
    return false;
}

#endif  // !defined(_MSC_VER)
