// Win32IDE_DapAdapterSpawn.hpp — product DAP adapter path probe + spawn
// Fail-closed; INVENT_DAP_PASS=0. PROMOTE=0 tip748B HOLD.
#pragma once
#include <string>
#include <windows.h>

namespace RawrXD {
namespace Debug {

struct DapAdapterSpawnResult {
    bool pathPresent = false;
    bool spawnReached = false;
    DWORD spawnError = 0;
    std::string resolvedPath;
    std::string detail;
};

// Resolve debuggerPath or RAWRXD_DAP_ADAPTER. Empty => not present.
std::string DapResolveAdapterPath(const std::string& debuggerPath);

// True if path exists and is not a directory.
bool DapAdapterPathExists(const std::string& path);

// CreateProcess with inherited stdio pipes; kills child before return.
// Never claims DAP session PASS. spawnReached=true only if CreateProcess ok.
DapAdapterSpawnResult DapTrySpawnAdapterFailClosed(const std::string& adapterPath);

} // namespace Debug
} // namespace RawrXD
