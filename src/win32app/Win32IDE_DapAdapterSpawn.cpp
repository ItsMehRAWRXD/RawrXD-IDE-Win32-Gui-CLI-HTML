// Win32IDE_DapAdapterSpawn.cpp — real adapter path I/O for product DapService
// Spawn probe only; no DAP handshake; INVENT_DAP_PASS=0.
#include "Win32IDE_DapAdapterSpawn.hpp"

namespace RawrXD {
namespace Debug {

std::string DapResolveAdapterPath(const std::string& debuggerPath) {
    if (!debuggerPath.empty()) return debuggerPath;
    char buf[MAX_PATH] = {};
    DWORD n = GetEnvironmentVariableA("RAWRXD_DAP_ADAPTER", buf, MAX_PATH);
    if (n > 0 && n < MAX_PATH) return std::string(buf);
    return {};
}

bool DapAdapterPathExists(const std::string& path) {
    if (path.empty()) return false;
    DWORD attr = GetFileAttributesA(path.c_str());
    if (attr == INVALID_FILE_ATTRIBUTES) return false;
    if (attr & FILE_ATTRIBUTE_DIRECTORY) return false;
    return true;
}

DapAdapterSpawnResult DapTrySpawnAdapterFailClosed(const std::string& adapterPath) {
    DapAdapterSpawnResult r;
    r.resolvedPath = adapterPath;
    if (!DapAdapterPathExists(adapterPath)) {
        r.detail = "adapter missing";
        return r;
    }
    r.pathPresent = true;

    SECURITY_ATTRIBUTES sa = {};
    sa.nLength = sizeof(sa);
    sa.bInheritHandle = TRUE;
    HANDLE hInR = nullptr, hInW = nullptr, hOutR = nullptr, hOutW = nullptr;
    if (!CreatePipe(&hInR, &hInW, &sa, 0) || !CreatePipe(&hOutR, &hOutW, &sa, 0)) {
        r.spawnError = GetLastError();
        r.detail = "pipe create failed";
        if (hInR) CloseHandle(hInR);
        if (hInW) CloseHandle(hInW);
        if (hOutR) CloseHandle(hOutR);
        if (hOutW) CloseHandle(hOutW);
        return r;
    }
    SetHandleInformation(hInW, HANDLE_FLAG_INHERIT, 0);
    SetHandleInformation(hOutR, HANDLE_FLAG_INHERIT, 0);

    STARTUPINFOA si = {};
    si.cb = sizeof(si);
    si.dwFlags = STARTF_USESTDHANDLES;
    si.hStdInput = hInR;
    si.hStdOutput = hOutW;
    si.hStdError = hOutW;
    PROCESS_INFORMATION pi = {};
    std::string cmd = "\"" + adapterPath + "\" --interpreter=vscode";
    BOOL ok = CreateProcessA(nullptr, &cmd[0], nullptr, nullptr, TRUE,
                             CREATE_NO_WINDOW, nullptr, nullptr, &si, &pi);
    CloseHandle(hInR);
    CloseHandle(hOutW);
    CloseHandle(hInW);
    CloseHandle(hOutR);
    if (!ok) {
        r.spawnError = GetLastError();
        r.detail = "CreateProcess failed";
        return r;
    }
    r.spawnReached = true;
    r.detail = "adapter spawn reached; handshake not certified";
    TerminateProcess(pi.hProcess, 1);
    WaitForSingleObject(pi.hProcess, 2000);
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
    return r;
}

} // namespace Debug
} // namespace RawrXD
