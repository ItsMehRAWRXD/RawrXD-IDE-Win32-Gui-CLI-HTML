// Win32IDE_ComponentManagers_Link.cpp
// This file is intentionally minimal.
// All destructor definitions are inline in Win32IDE_ComponentManagers.h
// to support unique_ptr<T> in Win32IDE.cpp without circular dependencies.
//
// AUDIT_002_OPENISH_OTHER_DRAIN_016:
// Prior: empty "intentionally minimal" TU invent ComponentManagers link-complete
// as product ready PASS without validated component-manager product wire
// (fake-ready / empty-true). Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include <windows.h>

namespace {
struct ComponentManagersLinkFailClosed {
    ComponentManagersLinkFailClosed() {
        // Was: invent empty link-complete ready PASS (no symbols / no wire).
        OutputDebugStringA(
            "[ComponentManagers_Link] FEATURE_FICTION=1 FAIL_CLOSED TU "
            "(no invent ComponentManagers link-ready PASS)\n");
    }
};
static ComponentManagersLinkFailClosed g_componentManagersLinkFailClosed;
}
