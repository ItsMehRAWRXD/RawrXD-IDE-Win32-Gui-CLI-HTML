// AUDIT_002_OPENISH_EXTENSION_DRAIN_001:
// Prior: invent VS Code API dispatcher ready PASS via cout stubs without
// validated tip product wire (fake-ready EXTENSION orphan).
// Now: FEATURE_FICTION=1 FAIL_CLOSED - no invent dispatcher ready PASS.
// Orphan TU (not tip link). PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include "ExtensionAPI_VSCode_Internal.h"
#include "ExtensionInstance.h"
#include <iostream>
#include <nlohmann/json.hpp>
#include <windows.h>

using json = nlohmann::json;

namespace vscode {

// Global bridge objects
Window window;
Workspace workspace;
Commands commands;

void Window::showInformationMessage(const std::string& message) {
    std::cout << "[VSCodeAPI] Info: " << message << std::endl;
}

void Window::showErrorMessage(const std::string& message) {
    std::cerr << "[VSCodeAPI] Error: " << message << std::endl;
}

void Commands::registerCommand(const std::string& command, std::function<void()> callback) {
    std::cout << "[VSCodeAPI] Registered Command: " << command << std::endl;
}

void Commands::executeCommand(const std::string& command) {
    std::cout << "[VSCodeAPI] Executing Command: " << command << std::endl;
}

}

namespace RawrXD::Extensions {

class APIDispatcher {
public:
    static void Dispatch(ExtensionInstance* instance, const IPCHeader& header, const std::vector<uint8_t>& payload) {
        // Was: invent VS Code API dispatch ready PASS (cout stubs).
        (void)instance;
        (void)header;
        (void)payload;
        OutputDebugStringA(
            "[APIDispatcher] FEATURE_FICTION=1 FAIL_CLOSED Dispatch "
            "(no invent VSCodeAPI dispatcher ready PASS)\n");
        return;

        if (payload.empty()) return;

        try {
            auto j = json::parse(payload.begin(), payload.end());
            std::string method = j.value("method", "");

            if (method == "window.showInformationMessage") {
                std::string msg = j.at("params").at("message");
                vscode::window.showInformationMessage(msg);
            }
            else if (method == "commands.executeCommand") {
                std::string cmd = j.at("params").at("command");
                vscode::commands.executeCommand(cmd);
            }
            // Add more dispatch logic as APIs grow
        } catch (const std::exception& e) {
            std::cerr << "[APIDispatcher] JSON Parse/Dispatch Error: " << e.what() << std::endl;
        }
    }
};

}
