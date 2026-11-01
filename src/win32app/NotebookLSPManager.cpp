#include "NotebookLSPManager.h"
#include <iostream>
#include <windows.h>

namespace RawrXD::LSP {

// AUDIT_002_OPENISH_OTHER_DRAIN_002:
// Prior: GetSemanticTokens returned hard-coded Mock token array.
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[NotebookLSPManager] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

NotebookLSPManager& NotebookLSPManager::GetInstance() {
    static NotebookLSPManager instance;
    return instance;
}

void NotebookLSPManager::DidOpenNotebook(const NotebookDocument& notebook) {
    m_openNotebooks[notebook.uri] = notebook;
}

void NotebookLSPManager::DidChangeNotebook(const std::string& uri,
                                           const nlohmann::json& /*changes*/) {
    if (m_openNotebooks.find(uri) == m_openNotebooks.end()) {
        return;
    }
    // Was: cout-only "synchronizing" with no cell/LSP update.
    GateFiction("DidChangeNotebook");
}

void NotebookLSPManager::DidCloseNotebook(const std::string& uri) {
    m_openNotebooks.erase(uri);
}

std::vector<uint32_t> NotebookLSPManager::GetSemanticTokens(const std::string& /*uri*/) {
    GateFiction("GetSemanticTokens");
    // Was: return {0,0,12,1,0,1,0,8,2,0}; // Mock tokens
    return {};
}

}
