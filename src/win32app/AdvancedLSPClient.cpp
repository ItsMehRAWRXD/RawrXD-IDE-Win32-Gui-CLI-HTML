#include "AdvancedLSPClient.h"
#include <iostream>
#include <memory>
#include <mutex>
#include <windows.h>

namespace RawrXD::LSP {

using json = nlohmann::json;

// AUDIT_002_OPENISH_OTHER_DRAIN_002:
// Prior: QueryWorkspaceSymbols pushed Mock symbols; PrepareGlobalRename
// simulated multi-file edit without LSP pipe.
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[AdvancedLSPClient] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

AdvancedLSPClient& AdvancedLSPClient::GetInstance() {
    static AdvancedLSPClient* instance = nullptr;
    static std::once_flag initFlag;
    std::call_once(initFlag, []() {
        instance = new AdvancedLSPClient();
    });
    return *instance;
}

std::future<std::vector<WorkspaceSymbol>> AdvancedLSPClient::QueryWorkspaceSymbols(
    const std::string& /*query*/) {
    return std::async(std::launch::async, []() {
        GateFiction("QueryWorkspaceSymbols");
        // Was: Mock MemoryOracle/ExtensionManager symbols (invent PASS).
        return std::vector<WorkspaceSymbol>{};
    });
}

std::future<WorkspaceEdit> AdvancedLSPClient::PrepareGlobalRename(
    const std::string& /*uri*/, int /*line*/, int /*character*/,
    const std::string& /*newName*/) {
    return std::async(std::launch::async, []() {
        GateFiction("PrepareGlobalRename");
        // Was: simulate WorkspaceEdit without LSP server response.
        return WorkspaceEdit{};
    });
}

}
