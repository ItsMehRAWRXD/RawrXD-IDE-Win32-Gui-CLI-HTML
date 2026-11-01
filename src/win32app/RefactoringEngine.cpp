#include "RefactoringEngine.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <windows.h>

namespace RawrXD::LSP {

// AUDIT_002_OPENISH_OTHER_DRAIN_002:
// Prior: ApplyTextEditToFile simulated patch (cout-only return true);
// UndoLastOperation popped history without reversing edits.
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

namespace {
void GateFiction(const char* name) {
    char buf[224];
    wsprintfA(buf,
        "[RefactoringEngine] FEATURE_FICTION=1 FAIL_CLOSED name=%s\n", name);
    OutputDebugStringA(buf);
}
} // namespace

RefactoringEngine& RefactoringEngine::GetInstance() {
    static RefactoringEngine instance;
    return instance;
}

bool RefactoringEngine::ApplyWorkspaceEdit(const WorkspaceEdit& edit) {
    std::lock_guard<std::mutex> lock(m_mutex);
    GateFiction("ApplyWorkspaceEdit");
    (void)edit;
    return false;
}

bool RefactoringEngine::ApplyTextEditToFile(const std::string& /*uri*/,
                                            const nlohmann::json& /*edit*/) {
    // Was: cout simulate + return true (no buffer/VFS write).
    GateFiction("ApplyTextEditToFile");
    return false;
}

bool RefactoringEngine::UndoLastOperation() {
    // Was: pop history + return true without reversing edits.
    GateFiction("UndoLastOperation");
    return false;
}

void RefactoringEngine::BeginTransaction() {
    GateFiction("BeginTransaction");
}

void RefactoringEngine::CommitTransaction() {
    GateFiction("CommitTransaction");
}

void RefactoringEngine::RollbackTransaction() {
    GateFiction("RollbackTransaction");
}

}
