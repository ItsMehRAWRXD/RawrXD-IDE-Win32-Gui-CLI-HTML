// Win32IDE_SlashCommands.cpp - Full Implementation
// AUDIT_002_OPENISH_OTHER_DRAIN_009:
// Prior: InitializeSlashCommandRegistry invent g_slashCommandsInitialized=true claiming
// AI fix/edit/refactor ready without MetaPlanner/Deep2 wire (fake-ready).
// Now: FEATURE_FICTION=1 FAIL_CLOSED — no invent PASS. Orphan TU (not tip link).
// PROMOTE=0 TIP_CLIMB=HOLD CERTIFIED=0 PERFECT=0 NOT_RUN!=PASS

#include "Win32IDE.h"
#include "../agentic/slash_command_parser.hpp"
#include <windows.h>
#include <string>
#include <vector>
#include <map>

namespace RawrXD {
namespace Agentic {

// ============================================================================
// Slash Command Registry
// ============================================================================

struct SlashCommandEntry
{
    std::string command;
    std::string description;
    std::string category;
    bool requiresArgs;
    bool needsApproval;
};

static std::vector<SlashCommandEntry> g_slashCommands;
static bool g_slashCommandsInitialized = false;

static void InitializeSlashCommandRegistry()
{
    // Was: invent static AI command table + g_slashCommandsInitialized=true (fake-ready).
    g_slashCommands.clear();
    g_slashCommandsInitialized = false;
    OutputDebugStringA("[SlashCommands] FEATURE_FICTION=1 FAIL_CLOSED Initialize (no invent registry PASS)\n");
}

// ============================================================================
// Public API
// ============================================================================

std::vector<std::string> GetAvailableSlashCommands()
{
    InitializeSlashCommandRegistry();
    std::vector<std::string> result;
    result.reserve(g_slashCommands.size());
    for (const auto& cmd : g_slashCommands)
    {
        result.push_back(cmd.command);
    }
    return result;
}

std::string GetSlashCommandDescription(const std::string& command)
{
    InitializeSlashCommandRegistry();
    for (const auto& cmd : g_slashCommands)
    {
        if (cmd.command == command)
            return cmd.description;
    }
    return "Unknown command";
}

std::string GetSlashCommandCategory(const std::string& command)
{
    InitializeSlashCommandRegistry();
    for (const auto& cmd : g_slashCommands)
    {
        if (cmd.command == command)
            return cmd.category;
    }
    return "Unknown";
}

bool SlashCommandNeedsApproval(const std::string& command)
{
    InitializeSlashCommandRegistry();
    for (const auto& cmd : g_slashCommands)
    {
        if (cmd.command == command)
            return cmd.needsApproval;
    }
    return false;
}

bool IsValidSlashCommand(const std::string& command)
{
    InitializeSlashCommandRegistry();
    for (const auto& cmd : g_slashCommands)
    {
        if (cmd.command == command)
            return true;
    }
    return false;
}

std::string BuildSlashCommandHelpText()
{
    InitializeSlashCommandRegistry();
    std::string help = "Available slash commands:\n";
    help += "═══════════════════════════════\n";
    
    std::map<std::string, std::vector<SlashCommandEntry>> byCategory;
    for (const auto& cmd : g_slashCommands)
    {
        byCategory[cmd.category].push_back(cmd);
    }
    
    for (const auto& [category, commands] : byCategory)
    {
        help += "\n[" + category + "]\n";
        for (const auto& cmd : commands)
        {
            help += "  /" + cmd.command;
            if (cmd.requiresArgs) help += " <args>";
            help += " - " + cmd.description;
            if (cmd.needsApproval) help += " [requires approval]";
            help += "\n";
        }
    }
    
    return help;
}

} // namespace Agentic
} // namespace RawrXD

// ============================================================================
// C API for Win32IDE Integration
// ============================================================================

extern "C" void Win32IDE_InitSlashCommands()
{
    RawrXD::Agentic::InitializeSlashCommandRegistry();
}

extern "C" const char* Win32IDE_GetSlashCommandDescription(const char* cmd)
{
    if (!cmd) return "";
    static thread_local std::string desc;
    desc = RawrXD::Agentic::GetSlashCommandDescription(cmd);
    return desc.c_str();
}

extern "C" bool Win32IDE_IsValidSlashCommand(const char* cmd)
{
    if (!cmd) return false;
    return RawrXD::Agentic::IsValidSlashCommand(cmd);
}
