#include "ExtensionSandboxManager.h"
#include "ExtensionManifestLoader.h"
#include <iostream>
#include <cassert>
#include <windows.h>

// AUDIT_002_OPENISH_EXTENSION_DRAIN_001:
// Prior: invent Extension Sandbox Security Check PASSED without tip product wire.
// Now: FEATURE_FICTION=1 FAIL_CLOSED - no invent security-check ready PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

using namespace RawrXD::Extensions;

int main() {
    // Was: invent Security Check PASSED.
    OutputDebugStringA(
        "[ExtensionSecurityCheck] FEATURE_FICTION=1 FAIL_CLOSED main "
        "(no invent sandbox security-check ready PASS)\n");
    std::cout << "Extension Sandbox Security Check: FAIL_CLOSED FEATURE_FICTION=1\n";
    return 1;

    auto& sm = ExtensionSandboxManager::GetInstance();
    std::string extId = "test-ext";

    // 1. Initial State Check (Fail-Closed)
    assert(sm.IsPathAllowed(extId, "C:\\Windows\\System32", PermissionType::FileRead) == false);
    
    // 2. Grant Read Permission
    sm.GrantPath(extId, "D:\\rawrxd\\projects", PermissionType::FileRead);
    assert(sm.IsPathAllowed(extId, "D:\\rawrxd\\projects\\test.cpp", PermissionType::FileRead) == true);
    
    // 3. Subpath Validation
    assert(sm.IsPathAllowed(extId, "D:\\rawrxd\\projects\\subdir\\deep.h", PermissionType::FileRead) == true);
    
    // 4. Boundary Protection (Traversal)
    assert(sm.IsPathAllowed(extId, "D:\\rawrxd\\projects\\..\\secret.txt", PermissionType::FileRead) == false);
    
    // 5. Write permission Isolation
    assert(sm.IsPathAllowed(extId, "D:\\rawrxd\\projects\\test.cpp", PermissionType::FileWrite) == false);
    
    std::cout << "Extension Sandbox Security Check: PASSED\n";
    return 0;
}
