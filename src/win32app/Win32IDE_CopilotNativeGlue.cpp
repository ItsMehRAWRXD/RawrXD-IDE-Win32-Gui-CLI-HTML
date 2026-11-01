// Win32IDE_CopilotNativeGlue.cpp — finish local GGUF minimal-agentic Copilot turns from the UI thread.
//
// AUDIT_002_OPENISH_OTHER_DRAIN_021:
// Prior: invent Copilot minimal-agentic finish ready PASS without validated tip
// product wire (fake-ready / empty-true orphan CopilotNativeGlue TU).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include "../agentic/agent_controller_minimal.h"
#include "../config/IDEConfig.h"
#include "Win32IDE.h"

#include <memory>

void RawrXD_FinishCopilotMinimalAgentic(Win32IDE* ide, WPARAM /*wParam*/, LPARAM heapResponse)
{
    // Was: invent CopilotNativeGlue finish ready PASS.
    (void)ide;
    std::unique_ptr<rawrxd::MinimalAgenticResponse> drop(
        reinterpret_cast<rawrxd::MinimalAgenticResponse*>(heapResponse));
    OutputDebugStringA(
        "[CopilotNativeGlue] FEATURE_FICTION=1 FAIL_CLOSED FinishCopilotMinimalAgentic "
        "(no invent CopilotNativeGlue ready PASS)\n");
    return;

    std::unique_ptr<rawrxd::MinimalAgenticResponse> bundle(
        reinterpret_cast<rawrxd::MinimalAgenticResponse*>(heapResponse));
    if (!ide)
        return;
    if (bundle)
    {
        METRICS.gauge("chat.minimal_agentic.ui_finish_tool_count", static_cast<double>(bundle->tool_calls_made));
    }
    ide->m_chatSendInFlight.store(false);
    ide->setCopilotInteractionBusyOnUiThread(false);
    ide->m_streamingTokenAccumulator.clear();
    if (!bundle)
        return;
    ide->applyMinimalAgenticCompletion(std::move(*bundle));
}
