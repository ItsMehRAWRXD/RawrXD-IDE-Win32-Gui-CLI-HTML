// TIP_CANDIDATE_RELINK_STUB_FAILFAST_001 / STUB_RESIDUAL_G08_G16 —
// force-link header fail-close cites (G04/G05/G08/G12/G16).
// Candidate only. NOT tip absorb. PROMOTE=0.
#include "../agentic/include/RawrXD_AgentHost.h"
#include "../agentic/vulkan/VulkanManager.hpp"

// Exported data symbols so MAP text retains G08/G16 STRING tokens
// (volatile ptr-only cites were OPTIMIZED_OUT under LTCG).
extern "C" const char G08_checkApproval_STRING[] =
    "FEATURE_FICTION=1 FAIL_CLOSED ToolExecutor::checkApproval";
extern "C" const char G16_isRelevantToRole_STRING[] =
    "FEATURE_FICTION=1 FAIL_CLOSED BaseAgent::isRelevantToRole";

#pragma comment(linker, "/INCLUDE:G08_checkApproval_STRING")
#pragma comment(linker, "/INCLUDE:G16_isRelevantToRole_STRING")

extern "C" void Win32IDE_StubFictionCiteForce_G04_G05() {
    RawrXD::SymbolHealer healer;
    (void)healer.ResolveSymbol("RELINK_CITE");
    (void)healer.ResolveSymbol("RELINK_CITE", "module");
    (void)RawrXD::AgentHost::Instance().Initialize();
    RawrXD::Agentic::Vulkan::VulkanContext ctx{};
    (void)RawrXD::Agentic::Vulkan::VulkanManager::getDeviceMemoryUsed(ctx);
    // Touch first bytes so .rdata content cannot be DCE'd.
    volatile char sink = 0;
    sink = G08_checkApproval_STRING[0];
    sink = G16_isRelevantToRole_STRING[0];
    (void)sink;
}
