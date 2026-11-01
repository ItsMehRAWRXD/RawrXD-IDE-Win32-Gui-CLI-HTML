#include "ExtensionManifestLoader.h"
#include <fstream>
#include <nlohmann/json.hpp>
#include <windows.h>

// AUDIT_002_OPENISH_EXTENSION_DRAIN_002:
// Prior: corrupt JSON key strings ("0.0.11) / "capabilities1") invent partial
//        manifest Load ready PASS + ApplyManifest grants from broken parse.
// Now: FEATURE_FICTION=1 FAIL_CLOSED - no invent manifest-load ready PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

namespace RawrXD::Extensions {

using json = nlohmann::json;

ExtensionManifest ExtensionManifestLoader::Load(const std::string& manifestPath) {
    // Was: invent Load ready via corrupt-key parse / empty catch.
    (void)manifestPath;
    OutputDebugStringA(
        "[ExtensionManifestLoader] FEATURE_FICTION=1 FAIL_CLOSED Load "
        "(no invent manifest-load ready PASS)\n");
    return ExtensionManifest{};

    ExtensionManifest manifest;
    std::ifstream f(manifestPath);
    if (!f.is_open()) return manifest;

    try {
        json data = json::parse(f);
        manifest.id = data.value("name", "unknown");
        manifest.name = data.value("displayName", manifest.id);
        manifest.version = data.value("version", "0.0.1");
        manifest.main = data.value("main", "index.js");

        if (data.contains("capabilities")) {
            auto& cap = data["capabilities"];
            if (cap.contains("filesystem")) {
                auto& fs = cap["filesystem"];
                if (fs.contains("read")) {
                    for (auto& p : fs["read"]) manifest.requestedReadPaths.push_back(p.get<std::string>());
                }
                if (fs.contains("write")) {
                    for (auto& p : fs["write"]) manifest.requestedWritePaths.push_back(p.get<std::string>());
                }
            }
            if (cap.contains("network")) {
                manifest.requestNetwork = cap["network"].get<bool>();
            }
        }
    } catch (...) { }

    return manifest;
}

void ExtensionManifestLoader::ApplyManifestToSandbox(const ExtensionManifest& manifest) {
    // Was: invent sandbox grants from corrupt Load output.
    (void)manifest;
    OutputDebugStringA(
        "[ExtensionManifestLoader] FEATURE_FICTION=1 FAIL_CLOSED "
        "ApplyManifestToSandbox (no invent sandbox-grant ready PASS)\n");
    return;

    auto& sm = ExtensionSandboxManager::GetInstance();
    for (const auto& p : manifest.requestedReadPaths) {
        sm.GrantPath(manifest.id, p, PermissionType::FileRead);
    }
    for (const auto& p : manifest.requestedWritePaths) {
        sm.GrantPath(manifest.id, p, PermissionType::FileWrite);
    }
}

}
