#include "Win32IDE.h"
#include "../features/missing_features.hpp"

// AUDIT_002_OPENISH_OTHER_DRAIN_012:
// Prior: initializeMissingFeaturesCore invent facade initialize +
// "Missing-features core initialized" / isMissingFeaturesCoreReady=true
// without validated multi-cursor/snippets product wire (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

namespace
{
std::string chooseWorkspacePath(const Win32IDE* ide)
{
    if (!ide)
        return {};
    if (!ide->getProjectRoot().empty())
        return ide->getProjectRoot();
    if (!ide->getCurrentDirectory().empty())
        return ide->getCurrentDirectory();
    return ".";
}
} // namespace

void Win32IDE::initializeMissingFeaturesCore()
{
    (void)&chooseWorkspacePath;
    // Was: invent IDEFeatures facade init as product-ready core.
    m_missingFeaturesCore.reset();
    OutputDebugStringA(
        "[Features] FEATURE_FICTION=1 FAIL_CLOSED initializeMissingFeaturesCore "
        "(no invent missing-features ready PASS)\n");
    appendToOutput(
        "[Features] FEATURE_FICTION=1 FAIL_CLOSED — no invent missing-features ready PASS",
        "System", OutputSeverity::Warning);
}

void Win32IDE::syncMissingFeaturesFileContext(const std::string& filePath)
{
    if (!m_missingFeaturesCore || filePath.empty())
        return;
    m_missingFeaturesCore->openFile(filePath);
}

void Win32IDE::syncMissingFeaturesWorkspaceContext(const std::string& workspacePath)
{
    if (!m_missingFeaturesCore || workspacePath.empty())
        return;
    m_missingFeaturesCore->loadWorkspace(workspacePath);
}

bool Win32IDE::isMissingFeaturesCoreReady() const {
    // Was: invent ready=true from non-null facade pointer.
    return false;
}
