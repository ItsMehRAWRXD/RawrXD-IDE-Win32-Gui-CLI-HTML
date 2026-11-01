// PathB CMD_DIAG light-mgr: CIE+chat SOURCE_WIRE without FullAgenticBridge.
#pragma once

class AgenticEngine;

namespace RawrXD {
namespace Win32App {

/// Bind CIE + chat provider. Does NOT ProductOpen (worker __fastfail).
/// ENGINE_BIND ≠ MODEL_OPEN ≠ invent PASS — caller still needs executeSwarm.
AgenticEngine* EnsurePathBCmdDiagEngine(const char* modelPath);

/// True only after explicit ProductOpen (currently never on PathB light path).
bool PathBCmdDiagModelOpen();

/// True when CIE inference engine is bound for PathB CMD_DIAG.
bool PathBCmdDiagEngineBound();

/// BODY_EXIT_OK / COMPLETE_POST latch — UI re-enter 4111 must no-op (Send FailFast).
void PathBCmdDiagMarkSwarmBodyDone(unsigned completed);
bool PathBCmdDiagSwarmBodyDone();
unsigned PathBCmdDiagSwarmCompleted();

}  // namespace Win32App
}  // namespace RawrXD
