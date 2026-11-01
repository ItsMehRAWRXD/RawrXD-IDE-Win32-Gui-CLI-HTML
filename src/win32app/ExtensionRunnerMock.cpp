#include <windows.h>
#include <iostream>
#include <vector>
#include <string>
#include <nlohmann/json.hpp>
#include "ExtensionIPCChannel.h"

// AUDIT_002_OPENISH_EXTENSION_DRAIN_001:
// Prior: invent ExtensionRunnerMock connected/ready PASS without tip product wire.
// Now: FEATURE_FICTION=1 FAIL_CLOSED - no invent mock-runner ready PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

using namespace RawrXD::Extensions;
using json = nlohmann::json;

int main(int argc, char** argv) {
    // Was: invent mock runner Connected ready PASS.
    (void)argc;
    (void)argv;
    OutputDebugStringA(
        "[ExtensionRunnerMock] FEATURE_FICTION=1 FAIL_CLOSED main "
        "(no invent mock-runner ready PASS)\n");
    return 1;

    std::string extId = "unknown";
    for(int i=1; i<argc; ++i) {
        std::string arg = argv[i];
        if(arg.find("--extensionId=") == 0) extId = arg.substr(14);
    }

    std::wstring wid(extId.begin(), extId.end());
    ExtensionIPCChannel ipc(wid);
    
    // Connect back to IDE
    HANDLE hPipe = CreateFileW((L"\\\\.\\pipe\\" + wid).c_str(), GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);
    if (hPipe == INVALID_HANDLE_VALUE) return 1;

    std::cout << "[ExtensionRunner] Connected as " << extId << std::endl;

    // Send a test 'showInformationMessage' request
    json j;
    j["method"] = "window.showInformationMessage";
    j["params"]["message"] = "Hello from sandboxed extension: " + extId;
    std::string s = j.dump();
    
    IPCHeader header;
    header.type = IPCMessageType::Request;
    header.messageId = 1;
    header.payloadSize = static_cast<uint32_t>(s.size());

    DWORD written;
    WriteFile(hPipe, &header, sizeof(header), &written, NULL);
    WriteFile(hPipe, s.data(), header.payloadSize, &written, NULL);

    Sleep(2000); // Wait for processing
    CloseHandle(hPipe);
    return 0;
}
