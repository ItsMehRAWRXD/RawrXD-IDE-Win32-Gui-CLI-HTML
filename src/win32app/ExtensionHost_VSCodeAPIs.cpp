// ExtensionHost_VSCodeAPIs.cpp
// Phase 2 Day 8-9: VS Code API Bridge — connects ExtensionHost to VS Code API surface
// Provides command dispatch, language provider routing, and event bridging
//
// AUDIT_002_OPENISH_EXTENSION_DRAIN_002:
// Prior: invent ExecuteCommand/Register*/FireActivation/Telemetry ready PASS
//        (table-only / in-memory / log-as-success; orphan TU; no tip wire).
// Now: FEATURE_FICTION=1 FAIL_CLOSED - no invent VSCodeAPI-bridge ready PASS.
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include "ExtensionHost.h"
#include "ExtensionAPI_VSCode.h"
#include "IDELogger.h"
#include <windows.h>
#include <shlobj.h>
#include <nlohmann/json.hpp>

#pragma comment(lib, "Shell32.lib")

namespace RawrXD::Extensions {

using namespace VSCodeAPI;

// ============================================================================
// VS Code API Bridge — ExtensionHost methods
// ============================================================================

bool ExtensionHost::ExecuteCommand(const std::string& commandId, const std::string& args) {
    // Was: invent ExecuteCommand ready PASS (table lookup + callback; no tip).
    (void)commandId;
    (void)args;
    LOG_WARNING(
        "ExecuteCommand FEATURE_FICTION=1 FAIL_CLOSED "
        "(no invent VSCodeAPI ExecuteCommand ready PASS)");
    return false;

    if (!m_initialized.load()) return false;

    auto& commands = CommandsAPI::Get();
    auto allCommands = commands.GetCommands();

    bool found = false;
    for (const auto& cmd : allCommands) {
        if (cmd == commandId) {
            found = true;
            break;
        }
    }

    if (!found) {
        LOG_WARNING("Command not registered: " + commandId);
        return false;
    }

    if (args.empty()) {
        commands.ExecuteCommand(commandId);
    } else {
        commands.ExecuteCommandWithArgs(commandId, args);
    }

    ++m_totalMessages;
    return true;
}

std::vector<std::string> ExtensionHost::GetAvailableCommands() const {
    return CommandsAPI::Get().GetCommands();
}

// ============================================================================
// Language Provider Bridge
// ============================================================================

bool ExtensionHost::RegisterCompletionProvider(
    const std::string& extensionId,
    const std::string& language,
    std::shared_ptr<CompletionProvider> provider) {
    // Was: invent RegisterCompletionProvider ready PASS (in-memory only).
    (void)extensionId;
    (void)language;
    (void)provider;
    LOG_WARNING(
        "RegisterCompletionProvider FEATURE_FICTION=1 FAIL_CLOSED "
        "(no invent completion-provider ready PASS)");
    return false;

    if (!m_initialized.load() || !provider) return false;

    {
        std::lock_guard<std::mutex> lock(m_extensionsMutex);
        auto it = m_extensions.find(extensionId);
        if (it == m_extensions.end() || !it->second->isActive) {
            LOG_WARNING("Cannot register provider for inactive extension: " + extensionId);
            return false;
        }
    }

    LanguagesAPI::Get().RegisterCompletionProvider(language, provider);
    LOG_INFO("Extension " + extensionId + " registered completion provider for " + language);
    return true;
}

bool ExtensionHost::RegisterHoverProvider(
    const std::string& extensionId,
    const std::string& language,
    std::shared_ptr<HoverProvider> provider) {
    // Was: invent RegisterHoverProvider ready PASS (in-memory only).
    (void)extensionId;
    (void)language;
    (void)provider;
    LOG_WARNING(
        "RegisterHoverProvider FEATURE_FICTION=1 FAIL_CLOSED "
        "(no invent hover-provider ready PASS)");
    return false;

    if (!m_initialized.load() || !provider) return false;

    {
        std::lock_guard<std::mutex> lock(m_extensionsMutex);
        auto it = m_extensions.find(extensionId);
        if (it == m_extensions.end() || !it->second->isActive) {
            LOG_WARNING("Cannot register provider for inactive extension: " + extensionId);
            return false;
        }
    }

    LanguagesAPI::Get().RegisterHoverProvider(language, provider);
    LOG_INFO("Extension " + extensionId + " registered hover provider for " + language);
    return true;
}

std::shared_ptr<DiagnosticCollection> ExtensionHost::CreateDiagnosticCollection(
    const std::string& extensionId,
    const std::string& name) {
    // Was: invent CreateDiagnosticCollection ready PASS (in-memory only).
    (void)extensionId;
    (void)name;
    LOG_WARNING(
        "CreateDiagnosticCollection FEATURE_FICTION=1 FAIL_CLOSED "
        "(no invent diagnostic-collection ready PASS)");
    return nullptr;

    if (!m_initialized.load()) return nullptr;

    {
        std::lock_guard<std::mutex> lock(m_extensionsMutex);
        auto it = m_extensions.find(extensionId);
        if (it == m_extensions.end() || !it->second->isActive) {
            return nullptr;
        }
    }

    return LanguagesAPI::Get().CreateDiagnosticCollection(name);
}

// ============================================================================
// Window API Bridge
// ============================================================================

void ExtensionHost::ShowInformationMessage(const std::string& extensionId, const std::string& message) {
    (void)extensionId;
    WindowAPI::Get().ShowInformationMessage(message);
}

void ExtensionHost::ShowWarningMessage(const std::string& extensionId, const std::string& message) {
    (void)extensionId;
    WindowAPI::Get().ShowWarningMessage(message);
}

void ExtensionHost::ShowErrorMessage(const std::string& extensionId, const std::string& message) {
    (void)extensionId;
    WindowAPI::Get().ShowErrorMessage(message);
}

// ============================================================================
// Workspace API Bridge
// ============================================================================

std::shared_ptr<TextDocument> ExtensionHost::OpenDocument(const std::string& fileName) {
    return WorkspaceAPI::Get().OpenTextDocument(fileName);
}

std::vector<std::string> ExtensionHost::FindFiles(const std::string& include, const std::string& exclude) {
    return WorkspaceAPI::Get().FindFiles(include, exclude);
}

bool ExtensionHost::SaveAllDocuments() {
    return WorkspaceAPI::Get().SaveAll();
}

// ============================================================================
// Environment API Bridge
// ============================================================================

void ExtensionHost::OpenExternal(const std::string& url) {
    EnvironmentAPI::Get().OpenExternal(url);
}

std::string ExtensionHost::GetMachineId() const {
    return EnvironmentAPI::Get().GetMachineId();
}

std::string ExtensionHost::GetSessionId() const {
    return EnvironmentAPI::Get().GetSessionId();
}

// ============================================================================
// Extension-to-Extension Messaging
// ============================================================================

bool ExtensionHost::SendMessageToExtension(
    const std::string& fromExtensionId,
    const std::string& toExtensionId,
    const std::string& message) {
    if (!m_initialized.load()) return false;

    std::shared_ptr<ExtensionInfo> target;
    {
        std::lock_guard<std::mutex> lock(m_extensionsMutex);
        auto it = m_extensions.find(toExtensionId);
        if (it == m_extensions.end() || !it->second->isActive) {
            LOG_WARNING("Target extension not active: " + toExtensionId);
            return false;
        }
        target = it->second;
    }

    // Fail-closed: broadcast-as-success was IPC fiction (no target channel).
    // WIN32IDE_STUB_GATE_003 — ExtensionHost product-omit; still no invent PASS.
    (void)fromExtensionId;
    (void)message;
    (void)target;
    LOG_WARNING(
        "SendMessageToExtension GATED FEATURE_FICTION=1 SYNTHETIC=partial "
        "no IPC channel to " + toExtensionId);
    return false;
}

// ============================================================================
// Activation Event Handling
// ============================================================================

void ExtensionHost::FireActivationEvent(const std::string& event, const std::string& data) {
    // Was: invent FireActivationEvent ready PASS (activate+broadcast; orphan).
    (void)event;
    (void)data;
    LOG_WARNING(
        "FireActivationEvent FEATURE_FICTION=1 FAIL_CLOSED "
        "(no invent activation-event ready PASS)");
    return;

    if (!m_initialized.load() || m_shuttingDown.load()) return;

    std::vector<std::string> toActivate;
    {
        std::lock_guard<std::mutex> lock(m_extensionsMutex);
        for (const auto& [id, info] : m_extensions) {
            if (!info || info->isActive) continue;

            for (const auto& activationEvent : info->activationEvents) {
                if (activationEvent == event ||
                    (activationEvent.find("*") != std::string::npos &&
                     event.find(activationEvent.substr(0, activationEvent.find("*"))) == 0)) {
                    toActivate.push_back(id);
                    break;
                }
            }
        }
    }

    for (const auto& id : toActivate) {
        ActivateExtension(id);
    }

    BroadcastEvent(event, data);
}

// ============================================================================
// Telemetry Bridge
// ============================================================================

void ExtensionHost::LogExtensionTelemetry(
    const std::string& extensionId,
    const std::string& event,
    const std::map<std::string, std::string>& properties) {
    // Was: invent telemetry ready PASS (LOG-only / no pipeline).
    (void)extensionId;
    (void)event;
    (void)properties;
    LOG_WARNING(
        "LogExtensionTelemetry FEATURE_FICTION=1 FAIL_CLOSED "
        "(no invent telemetry ready PASS)");
    return;

    nlohmann::json telemetry;
    telemetry["extensionId"] = extensionId;
    telemetry["event"] = event;
    telemetry["timestamp"] = GetTickCount64();
    telemetry["properties"] = nlohmann::json::object();
    for (const auto& kv : properties) {
        telemetry["properties"][kv.first] = kv.second;
    }

    LOG_INFO("[Telemetry] " + extensionId + ": " + event);
    // In production, would send to telemetry pipeline
}

} // namespace RawrXD::Extensions
