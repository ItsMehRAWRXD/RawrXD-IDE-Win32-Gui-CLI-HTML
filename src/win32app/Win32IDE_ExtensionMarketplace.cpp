#include "extension_package_local.hpp"
#include <windows.h>

// AUDIT_002_OPENISH_EXTENSION_DRAIN_002:
// Prior: invent ExtensionCount empty-true ready (always 0) + SetExtensionEnabled
//        silent false; thin Install wrapper claimed ready without tip product wire.
// Now: FEATURE_FICTION=1 FAIL_CLOSED - no invent marketplace-count/install ready PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

namespace RawrXD::IDE {

bool InstallExtensionPackage(const char* packagePath) {
    // Was: invent InstallExtensionPackage ready via Local wrapper (orphan; no tip).
    (void)packagePath;
    OutputDebugStringA(
        "[ExtensionMarketplace] FEATURE_FICTION=1 FAIL_CLOSED "
        "InstallExtensionPackage (no invent marketplace-install ready PASS)\n");
    return false;

    if (!packagePath) return false;
    return Extensions::Local::InstallPackage(packagePath).success;
}

int ExtensionIdeCatalogCount() {
    // Was: invent catalog-count ready (orphan IdeCatalog surface).
    OutputDebugStringA(
        "[ExtensionMarketplace] FEATURE_FICTION=1 FAIL_CLOSED "
        "ExtensionIdeCatalogCount (no invent catalog-count ready PASS)\n");
    return 0;

    size_t n = 0;
    Extensions::Local::IdeCatalog(n);
    return static_cast<int>(n);
}

}  // namespace RawrXD::IDE

extern "C" {

bool RawrXD_IDE_InstallVsix(const char* vsixPath) {
    return RawrXD::IDE::InstallExtensionPackage(vsixPath);
}

bool RawrXD_IDE_InstallExtensionPackage(const char* packagePath) {
    return RawrXD::IDE::InstallExtensionPackage(packagePath);
}

bool RawrXD_IDE_SetExtensionEnabled(const char*, bool) {
    // Already fail-closed; keep explicit FEATURE_FICTION marker.
    OutputDebugStringA(
        "[ExtensionMarketplace] FEATURE_FICTION=1 FAIL_CLOSED "
        "SetExtensionEnabled (no invent enable ready PASS)\n");
    return false;
}

int RawrXD_IDE_ExtensionCount() {
    // Was: invent empty-true ExtensionCount ready PASS (always 0).
    OutputDebugStringA(
        "[ExtensionMarketplace] FEATURE_FICTION=1 FAIL_CLOSED "
        "ExtensionCount (no invent extension-count ready PASS)\n");
    return 0;
}

int RawrXD_IDE_TopIdeExtensionCatalogCount() {
    return RawrXD::IDE::ExtensionIdeCatalogCount();
}

}
