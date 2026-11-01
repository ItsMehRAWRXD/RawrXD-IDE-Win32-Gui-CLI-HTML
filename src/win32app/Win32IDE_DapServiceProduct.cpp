// Win32IDE_DapServiceProduct.cpp — cand product TU for DapService
// Real adapter path probe + optional spawn I/O; fail-closed; no invent DAP PASS.
// Replaces nlohmann DapService.cpp on cand link. PROMOTE=0 INVENT_DAP_PASS=0
#include "../debug/DapService.hpp"
#include "Win32IDE_DapAdapterSpawn.hpp"
#include <mutex>

namespace RawrXD {
namespace Debug {

namespace {
constexpr const char* kNoAdapter =
    "DAP product fail-closed: adapter path empty/missing (INVENT_DAP_PASS=0)";
constexpr const char* kSpawnFail =
    "DAP product fail-closed: adapter spawn failed (INVENT_DAP_PASS=0)";
constexpr const char* kSpawnNoHandshake =
    "DAP product: adapter spawn reached; handshake not certified (INVENT_DAP_PASS=0)";
}

class DapService::Impl {
public:
    Impl() : state_(DapState::Disconnected), initialized_(false) {}
    ~Impl() { shutdown(); }

    DapResult initialize(const LaunchConfig& c) {
        std::lock_guard<std::mutex> lock(mu_);
        initialized_ = false;
        state_ = DapState::Disconnected;
        std::string path = DapResolveAdapterPath(c.debuggerPath);
        if (path.empty() || !DapAdapterPathExists(path)) {
            lastError_ = kNoAdapter;
            return DapResult::Fail(lastError_);
        }
        auto spawn = DapTrySpawnAdapterFailClosed(path);
        if (!spawn.spawnReached) {
            lastError_ = kSpawnFail;
            if (!spawn.detail.empty()) lastError_ += std::string(": ") + spawn.detail;
            return DapResult::Fail(lastError_);
        }
        // Real I/O reached — still fail-closed (no handshake / no invent PASS).
        lastError_ = kSpawnNoHandshake;
        return DapResult::Fail(lastError_);
    }

    DapResult shutdown() {
        std::lock_guard<std::mutex> lock(mu_);
        initialized_ = false;
        state_ = DapState::Disconnected;
        callbacks_ = Callbacks{};
        return DapResult::Ok();
    }

    bool isInitialized() const {
        std::lock_guard<std::mutex> lock(mu_);
        return initialized_;
    }
    DapState state() const {
        std::lock_guard<std::mutex> lock(mu_);
        return state_;
    }
    DapResult failOp() {
        std::lock_guard<std::mutex> lock(mu_);
        lastError_ = kNoAdapter;
        return DapResult::Fail(lastError_);
    }
    void setCallbacks(const Callbacks& cbs) {
        std::lock_guard<std::mutex> lock(mu_);
        callbacks_ = cbs;
    }
    DapResult sendRawRequest(const std::string&, const std::string&,
                             std::string*, uint32_t) {
        return failOp();
    }
    std::string lastError() const {
        std::lock_guard<std::mutex> lock(mu_);
        return lastError_;
    }
    bool hasPendingRequest() const { return false; }
    bool waitForIdle(uint32_t) { return true; }

    mutable std::mutex mu_;
    Callbacks callbacks_;
    DapState state_;
    bool initialized_;
    std::string lastError_;
};

DapService& DapService::instance() {
    static DapService inst;
    return inst;
}
DapService::DapService() : m_impl(std::make_unique<Impl>()) {}
DapService::~DapService() = default;
DapResult DapService::initialize(const LaunchConfig& c) { return m_impl->initialize(c); }
DapResult DapService::shutdown() { return m_impl->shutdown(); }
bool DapService::isInitialized() const { return m_impl->isInitialized(); }
DapState DapService::state() const { return m_impl->state(); }
DapResult DapService::launch() { return m_impl->failOp(); }
DapResult DapService::attach(uint32_t) { return m_impl->failOp(); }
DapResult DapService::continueExecution(uint32_t) { return m_impl->failOp(); }
DapResult DapService::pause() { return m_impl->failOp(); }
DapResult DapService::stepOver(uint32_t) { return m_impl->failOp(); }
DapResult DapService::stepInto(uint32_t) { return m_impl->failOp(); }
DapResult DapService::stepOut(uint32_t) { return m_impl->failOp(); }
DapResult DapService::restart() { return m_impl->failOp(); }
DapResult DapService::terminate() { return m_impl->failOp(); }
DapResult DapService::detach() { return m_impl->failOp(); }
DapResult DapService::setBreakpoint(const std::string&, uint32_t, const std::string&, Breakpoint*) {
    return m_impl->failOp();
}
DapResult DapService::setFunctionBreakpoint(const std::string&, Breakpoint*) {
    return m_impl->failOp();
}
DapResult DapService::removeBreakpoint(uint32_t) { return m_impl->failOp(); }
DapResult DapService::removeBreakpoints(const std::string&) { return m_impl->failOp(); }
DapResult DapService::removeAllBreakpoints() { return m_impl->failOp(); }
DapResult DapService::requestStackTrace(uint32_t, uint32_t, uint32_t) {
    return m_impl->failOp();
}
DapResult DapService::requestVariables(uint32_t) { return m_impl->failOp(); }
DapResult DapService::evaluate(const std::string&, uint32_t, Variable*) {
    return m_impl->failOp();
}
DapResult DapService::setVariable(uint32_t, const std::string&, const std::string&) {
    return m_impl->failOp();
}
DapResult DapService::requestThreads() { return m_impl->failOp(); }
void DapService::setCallbacks(const Callbacks& cbs) { m_impl->setCallbacks(cbs); }
void DapService::setStateCallback(StateChangeCallback cb) {
    Callbacks c = m_impl->callbacks_;
    c.onStateChanged = std::move(cb);
    m_impl->setCallbacks(c);
}
void DapService::setStackTraceCallback(StackTraceCallback cb) {
    Callbacks c = m_impl->callbacks_;
    c.onStackTrace = std::move(cb);
    m_impl->setCallbacks(c);
}
void DapService::setVariablesCallback(VariablesCallback cb) {
    Callbacks c = m_impl->callbacks_;
    c.onVariables = std::move(cb);
    m_impl->setCallbacks(c);
}
void DapService::setBreakpointCallbacks(BreakpointCallback onSet, BreakpointCallback onHit) {
    Callbacks c = m_impl->callbacks_;
    c.onBreakpointSet = std::move(onSet);
    c.onBreakpointHit = std::move(onHit);
    m_impl->setCallbacks(c);
}
void DapService::setOutputCallback(OutputCallback cb) {
    Callbacks c = m_impl->callbacks_;
    c.onOutput = std::move(cb);
    m_impl->setCallbacks(c);
}
void DapService::setStoppedCallback(StoppedCallback cb) {
    Callbacks c = m_impl->callbacks_;
    c.onStopped = std::move(cb);
    m_impl->setCallbacks(c);
}
void DapService::setContinuedCallback(ContinuedCallback cb) {
    Callbacks c = m_impl->callbacks_;
    c.onContinued = std::move(cb);
    m_impl->setCallbacks(c);
}
void DapService::setTerminatedCallback(TerminatedCallback cb) {
    Callbacks c = m_impl->callbacks_;
    c.onTerminated = std::move(cb);
    m_impl->setCallbacks(c);
}
void DapService::setErrorCallback(ErrorCallback cb) {
    Callbacks c = m_impl->callbacks_;
    c.onError = std::move(cb);
    m_impl->setCallbacks(c);
}
DapResult DapService::sendRawRequest(const std::string& cmd, const std::string& args,
                                     std::string* out, uint32_t timeoutMs) {
    return m_impl->sendRawRequest(cmd, args, out, timeoutMs);
}
std::string DapService::lastError() const { return m_impl->lastError(); }
bool DapService::hasPendingRequest() const { return m_impl->hasPendingRequest(); }
bool DapService::waitForIdle(uint32_t timeoutMs) { return m_impl->waitForIdle(timeoutMs); }

const char* StateToString(DapState state) {
    switch (state) {
        case DapState::Disconnected: return "Disconnected";
        case DapState::Initializing: return "Initializing";
        case DapState::Running: return "Running";
        case DapState::Paused: return "Paused";
        case DapState::Stopped: return "Stopped";
        default: return "Unknown";
    }
}
DapState StringToState(const std::string& str) {
    if (str == "Disconnected") return DapState::Disconnected;
    if (str == "Initializing") return DapState::Initializing;
    if (str == "Running") return DapState::Running;
    if (str == "Paused") return DapState::Paused;
    if (str == "Stopped") return DapState::Stopped;
    return DapState::Disconnected;
}

} // namespace Debug
} // namespace RawrXD
